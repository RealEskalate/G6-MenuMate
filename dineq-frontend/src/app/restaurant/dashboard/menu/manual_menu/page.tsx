"use client";
import { v2 as cloudinary } from 'cloudinary';
import React, { useState, useEffect, useCallback } from "react";
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from "@/components/ui/collapsible";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { fetchItemImages } from "@/lib/imagesearch";
import { useMenuContext } from "@/context/MenuOcrContext";
import { ChevronDown, ChevronUp, Plus, Minus, X } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { createMenu } from "@/lib/menu";
import { useSession } from "next-auth/react";
import { fetchRestaurantMe } from "@/hooks/useRestaurant";
import { useRouter } from "next/navigation";
import toast, { Toaster } from "react-hot-toast";

interface NutritionalInfo {
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
}

export interface MenuItem {
  name: string;
  name_am?: string | "";
  image: string[];
  price: number | string;
  currency?: string;
  ingredients: string[];
  description: string;
  description_am?: string | "";
  tab_tags?: string[];
  tab_tags_am?: string[] | "";
  allergies?: string;
  allergies_am?: string | "";
  nutritional_info?: NutritionalInfo;
  preparation_time?: number;
  how_to_eat: string;
  how_to_eat_am?: string;
  voice?: string | null;
}

interface Section {
  name: string;
  items: MenuItem[];
}
interface ImageResult {
  item_name: string;
  photo_url: string;
  thumbnail_url: string;
  confidence_score: number;
  source: string;
  alt_text: string;
}

const ManualMenu = () => {
  const { menuItems: ocrMenuItems, clearMenuItems } = useMenuContext();
  console.log("OCR Menu Items from Context:", ocrMenuItems);

  const [initialized, setInitialized] = useState(false);
  const [menuName, setMenuName] = useState("Untitled menu");
  const [language, setLanguage] = useState("English");
  const [tags, setTags] = useState<string[]>([]);
  const [newTag, setNewTag] = useState("");
  const [sections, setSections] = useState<Section[]>([
    { name: "Starters", items: [] },
  ]);

  const [expandedSections, setExpandedSections] = useState<{
    [key: number]: boolean;
  }>({});
  const [expandedItems, setExpandedItems] = useState<{
    [key: string]: boolean;
  }>({});
  const [loading, setLoading] = useState(false);
  const [restaurantSlug, setRestaurantSlug] = useState<string | null>(null);
  const { data: session } = useSession(); // token from session?
  const [showPublishModal, setShowPublishModal] = useState(false);
  const [createdMenu, setCreatedMenu] = useState<any>(null);
  const router = useRouter();
  const [searchResults, setSearchResults] = useState<ImageResult[]>([]);
  const [imageSearchResults, setImageSearchResults] = useState<{
    [key: string]: ImageResult[];
  }>({});

  useEffect(() => {
    if (!initialized && ocrMenuItems.length > 0) {
      const mappedItems: MenuItem[] = ocrMenuItems.map((item: any) => ({
        ...item,
        name: item.name ?? "",
        price: item.price ?? "",
        ingredients: item.ingredients ?? [],
        nutritional_info: item.nutritional_info ?? {
          calories: 0,
          protein: 0,
          carbs: 0,
          fat: 0,
        },
        image: [], // Initialize as empty array
      }));

      setSections([{ name: "Imported from OCR", items: mappedItems }]);
      setInitialized(true);
      clearMenuItems();
    }
  }, [ocrMenuItems, initialized, clearMenuItems]);

  const toggleItem = useCallback((sectionIndex: number, itemIndex: number) => {
    const key = `${sectionIndex}-${itemIndex}`;
    setExpandedItems((prev) => ({
      ...prev,
      [key]: !prev[key],
    }));
  }, []);

  const addSection = useCallback(() => {
    setSections((prev) => [...prev, { name: "", items: [] }]);
  }, []);

  const addItem = useCallback((sectionIndex: number) => {
    setSections((prev) => {
      const newSections = [...prev];
      newSections[sectionIndex] = {
        ...newSections[sectionIndex],
        items: [
          ...newSections[sectionIndex].items,
          {
            name: "",
            name_am: "",
            image: [],
            price: "",
            currency: "",
            ingredients: [],
            description: "",
            description_am: "",
            tab_tags: [],
            tab_tags_am: [],
            allergies: "",
            allergies_am: "",
            nutritional_info: { calories: 0, protein: 0, carbs: 0, fat: 0 },
            preparation_time: 0,
            how_to_eat: "",
            how_to_eat_am: "",
            voice: null,
          },
        ],
      };
      return newSections;
    });
  }, []);

  const updateSectionName = useCallback((index: number, name: string) => {
    setSections((prev) => {
      const newSections = [...prev];
      newSections[index].name = name;
      return newSections;
    });
  }, []);

  const updateItem = useCallback(
    (
      sectionIndex: number,
      itemIndex: number,
      field: keyof MenuItem,
      value: any
    ) => {
      setSections((prevSections) => {
        const newSections = [...prevSections];
        const updatedItem = {
          ...newSections[sectionIndex].items[itemIndex],
          [field]: value,
        };
        newSections[sectionIndex].items[itemIndex] = updatedItem;
        return newSections;
      });

      // If the user typed the name, fetch images separately
      if (field === "name" && value.trim()) {
        const key = `${sectionIndex}-${itemIndex}`;
        fetchItemImages(value, 6, session?.accessToken).then((images) => {
          setImageSearchResults((prev) => ({
            ...prev,
            [key]: images.slice(0, 6), // limit to 6
          }));
        });
      }
    },
    [session]
  );

  const handleImageSelect = useCallback(
    (sectionIndex: number, itemIndex: number, url: string) => {
      setSections((prevSections) => {
        const newSections = [...prevSections];
        const item = newSections[sectionIndex].items[itemIndex];
        const images = item.image || [];
        const newImages = images.includes(url)
          ? images.filter((u) => u !== url)
          : [...images, url];
        newSections[sectionIndex].items[itemIndex].image = newImages;
        return newSections;
      });
    },
    []
  );

  const updateNutritionalInfo = useCallback(
    (
      sectionIndex: number,
      itemIndex: number,
      subField: keyof NutritionalInfo,
      value: number
    ) => {
      setSections((prevSections) => {
        const newSections = [...prevSections];
        const item = newSections[sectionIndex].items[itemIndex];
        const updatedNutritionalInfo = {
          ...item.nutritional_info,
          [subField]: value,
        };
        // newSections[sectionIndex].items[itemIndex].nutritional_info =
        //   updatedNutritionalInfo;
        return newSections;
      });
    },
    []
  );

  const addArrayItem = useCallback(
    (
      sectionIndex: number,
      itemIndex: number,
      field: "ingredients" | "tab_tags" | "tab_tags_am",
      value: string
    ) => {
      if (value.trim()) {
        setSections((prev) => {
          const newSections = [...prev];
          if (
            Array.isArray(newSections[sectionIndex].items[itemIndex][field])
          ) {
            (
              newSections[sectionIndex].items[itemIndex][field] as string[]
            ).push(value.trim());
          }
          return newSections;
        });
      }
    },
    []
  );

  const removeArrayItem = useCallback(
    (
      sectionIndex: number,
      itemIndex: number,
      field: "ingredients" | "tab_tags" | "tab_tags_am",
      arrayIndex: number
    ) => {
      setSections((prev) => {
        const newSections = [...prev];
        if (Array.isArray(newSections[sectionIndex].items[itemIndex][field])) {
          const newArray = [
            ...(newSections[sectionIndex].items[itemIndex][field] as string[]),
          ];
          newArray.splice(arrayIndex, 1);
          (newSections[sectionIndex].items[itemIndex][field] as string[]) =
            newArray;
        }
        return newSections;
      });
    },
    []
  );

  const handleAddTag = useCallback(() => {
    if (newTag.trim()) {
      setTags((prev) => [...prev, newTag.trim()]);
      setNewTag("");
    }
  }, [newTag]);

  const removeTag = useCallback((index: number) => {
    setTags((prev) => prev.filter((_, i) => i !== index));
  }, []); // to get token if using next-auth
  const handleSubmit = async () => {
    const restaurantData = await fetchRestaurantMe(
      session?.accessToken as string
    );
    console.log("Fetched restaurant data:", restaurantData);
    const restaurantSlug = restaurantData?.slug;
    console.log("Fetched restaurant slug:", restaurantSlug);

    if (!restaurantSlug) {
      alert("Restaurant slug is missing!");
      return;
    }

    const token = session?.accessToken;
    if (!token) {
      alert("No token found!");
      return;
    }

    const menuData = {
      name: menuName,
      language,
      tags,
      sections,
    };

    try {
      setLoading(true);
      const result = await createMenu(restaurantSlug, menuData, token);
      console.log("Menu created:", result);

      // pull values from API response
      const menu = result.data.menu;

      setCreatedMenu({
        id: menu.id,
        restaurantSlug: restaurantSlug, // Fixed: Use the original slug, not menu.restaurant_id (which is likely an ID)
        slug: menu.slug,
      });
      setShowPublishModal(true);
    } catch (error: any) {
      toast.error("Failed to create menu: " + error.message);
    } finally {
      setLoading(false);
    }
  };

  const handlePublish = async () => {
    if (!createdMenu) return;

    const { restaurantSlug, id } = createdMenu;
    try {
      const res = await fetch(
        `${process.env.NEXT_PUBLIC_API_BASE_URL}/menus/${restaurantSlug}/publish/${id}`,
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${session?.accessToken}`,
          },
        }
      );

      if (!res.ok) throw new Error("Failed to publish menu");

      toast.success("Menu published successfully!");
      setShowPublishModal(false);

      // ✅ redirect to QR customization page
      router.push(
        `/restaurant/dashboard/qr-manager/customize?slug=${restaurantSlug}&menu=${id}`
      );
    } catch (error: any) {
      toast.error("Failed to publish: " + error.message);
    }
  };
  const handleLocalUpload = useCallback(
    async (
      sectionIndex: number,
      itemIndex: number,
      event: React.ChangeEvent<HTMLInputElement>
    ) => {
      const file = event.target.files?.[0];
      if (!file) return;

      try {
        // Optional: Validate file type/size
        if (!file.type.startsWith("image/")) {
          throw new Error("Please upload an image file.");
        }

        const formData = new FormData();
        formData.append("file", file);
        formData.append(
          "upload_preset",
          `${process.env.NEXT_PUBLIC_CLOUDINARY_UPLOAD_PRESET}`
        ); // Pull from env

        const response = await fetch(
          `https://api.cloudinary.com/v1_1/${process.env.NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME}/image/upload`, // Dynamic cloud name
          {
            method: "POST",
            body: formData,
          }
        );

        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(
            `Upload failed: ${errorData.error?.message || "Unknown error"}`
          );
        }

        const data = await response.json();
        const url = data.secure_url;

        // Add the uploaded URL to the image array
        setSections((prevSections) => {
          const newSections = [...prevSections];
          const item = newSections[sectionIndex].items[itemIndex];
          const images = item.image || [];
          newSections[sectionIndex].items[itemIndex].image = [...images, url];
          return newSections;
        });

        toast.success("Image uploaded successfully!");
      } catch (error: any) {
        toast.error("Failed to upload image: " + error.message);
      } finally {
        event.target.value = ""; // Reset for re-upload
      }
    },
    []
  );

  return (
    <>
      <div className="flex-1 p-6 bg-white">
        <h1 className="text-2xl font-bold mb-6">Add Menu Manually</h1>

        <div className="border border-orange-300 rounded-lg p-6 mb-6">
          <h2 className="text-lg font-semibold mb-4">Basic Details</h2>
          <div className="grid md:grid-cols-2 gap-4 mb-4">
            <div>
              <Label htmlFor="menuName">Menu Name</Label>
              <Input
                id="menuName"
                type="text"
                value={menuName}
                onChange={(e) => setMenuName(e.target.value)}
                placeholder="Enter menu name"
              />
            </div>
            <div>
              <Label htmlFor="menuLanguage">Default Language</Label>
              <Select onValueChange={setLanguage} defaultValue={language}>
                <SelectTrigger id="menuLanguage">
                  <SelectValue placeholder="Select a language" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="Amharic">Amharic</SelectItem>
                  <SelectItem value="English">English</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
          <div>
            <Label htmlFor="menuTagInput">Menu Tags</Label>
            <div className="flex gap-2 mb-2">
              <Input
                id="menuTagInput"
                type="text"
                value={newTag}
                onChange={(e) => setNewTag(e.target.value)}
                className="flex-1"
                placeholder="Enter tag"
              />
              <Button onClick={handleAddTag}>
                <Plus className="h-4 w-4 " /> Add Tag
              </Button>
            </div>
            <div className="flex flex-wrap gap-2">
              {tags.map((tag, i) => (
                <Badge
                  key={i}
                  variant="secondary"
                  className="flex items-center"
                >
                  {tag}
                  <Button
                    onClick={() => removeTag(i)}
                    variant="ghost"
                    size="icon"
                    className="ml-2 h-4 w-4"
                  >
                    <X className="h-3 w-3" />
                  </Button>
                </Badge>
              ))}
            </div>
          </div>
        </div>

        {sections.map((section, sIndex) => (
          <Collapsible
            key={sIndex}
            className="border border-orange-300 rounded-lg p-6 mb-6"
            open={expandedSections[sIndex]}
            onOpenChange={() =>
              setExpandedSections((prev) => ({
                ...prev,
                [sIndex]: !prev[sIndex],
              }))
            }
          >
            <CollapsibleTrigger asChild>
              <div className="flex justify-between items-center cursor-pointer mb-4">
                <h2 className="text-lg font-semibold">
                  Section {sIndex + 1}:{" "}
                  <Input
                    type="text"
                    value={section.name}
                    onChange={(e) => updateSectionName(sIndex, e.target.value)}
                    className="inline-block border-b border-gray-300 focus:outline-none w-35 text-center "
                    placeholder="Section Name"
                    onClick={(e) => e.stopPropagation()} // Prevents collapsible from closing
                  />
                </h2>
                <Button variant="ghost" size="icon">
                  {expandedSections[sIndex] ? (
                    <ChevronUp className="h-5 w-5" />
                  ) : (
                    <ChevronDown className="h-5 w-5" />
                  )}
                </Button>
              </div>
            </CollapsibleTrigger>
            <CollapsibleContent className="space-y-4">
              {section.items.map((item, iIndex) => (
                <Collapsible
                  key={iIndex}
                  className="mb-6 border-b pb-6"
                  open={expandedItems[`${sIndex}-${iIndex}`]}
                  onOpenChange={() => toggleItem(sIndex, iIndex)}
                >
                  <CollapsibleTrigger asChild>
                    <div className="flex justify-between items-center cursor-pointer">
                      <h3 className="font-medium mb-2">
                        Item {iIndex + 1}: {item.name || "Untitled"}
                      </h3>
                      <Button variant="ghost" size="icon">
                        {expandedItems[`${sIndex}-${iIndex}`] ? (
                          <ChevronUp className="h-5 w-5" />
                        ) : (
                          <ChevronDown className="h-5 w-5" />
                        )}
                      </Button>
                    </div>
                  </CollapsibleTrigger>
                  <CollapsibleContent className="space-y-4">
                    <div className="grid md:grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor={`itemName-${sIndex}-${iIndex}`}>
                          Item Name
                        </Label>
                        <Input
                          id={`itemName-${sIndex}-${iIndex}`}
                          type="text"
                          value={item.name}
                          required
                          placeholder="Item name"
                          onChange={(e) =>
                            updateItem(sIndex, iIndex, "name", e.target.value)
                          }
                        />
                      </div>
                    </div>
                    <div className="grid md:grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor={`itemPrice-${sIndex}-${iIndex}`}>
                          Price
                        </Label>
                        <Input
                          id={`itemPrice-${sIndex}-${iIndex}`}
                          required
                          type="text"
                          value={item.price as string}
                          placeholder="Price"
                          onChange={(e) =>
                            updateItem(sIndex, iIndex, "price", e.target.value)
                          }
                        />
                      </div>
                      <div>
                        <Label htmlFor={`itemCurrency-${sIndex}-${iIndex}`}>
                          Currency
                        </Label>
                        <Input
                          id={`itemCurrency-${sIndex}-${iIndex}`}
                          type="text"
                          required
                          value={item.currency}
                          placeholder="Currency"
                          onChange={(e) =>
                            updateItem(
                              sIndex,
                              iIndex,
                              "currency",
                              e.target.value
                            )
                          }
                        />
                      </div>
                    </div>
                    <div>
                      <Label htmlFor={`itemDescription-${sIndex}-${iIndex}`}>
                        Description
                      </Label>
                      <Textarea
                        id={`itemDescription-${sIndex}-${iIndex}`}
                        value={item.description}
                        placeholder="Description"
                        onChange={(e) =>
                          updateItem(
                            sIndex,
                            iIndex,
                            "description",
                            e.target.value
                          )
                        }
                        rows={3}
                      />
                    </div>

                    <div className="grid md:grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor={`itemAllergies-${sIndex}-${iIndex}`}>
                          Allergies
                        </Label>
                        <Input
                          id={`itemAllergies-${sIndex}-${iIndex}`}
                          type="text"
                          value={item.allergies}
                          placeholder="Allergies"
                          onChange={(e) =>
                            updateItem(
                              sIndex,
                              iIndex,
                              "allergies",
                              e.target.value
                            )
                          }
                        />
                      </div>
                    </div>
                    <div>
                      <Label htmlFor={`itemPrepTime-${sIndex}-${iIndex}`}>
                        Preparation Time (minutes)
                      </Label>
                      <Input
                        id={`itemPrepTime-${sIndex}-${iIndex}`}
                        type="number"
                        value={item.preparation_time ?? ""}
                        placeholder="Preparation Time (minutes)"
                        onChange={(e) =>
                          updateItem(
                            sIndex,
                            iIndex,
                            "preparation_time",
                            Number(e.target.value)
                          )
                        }
                      />
                    </div>
                    <div>
                      <Label htmlFor={`itemHowToEat-${sIndex}-${iIndex}`}>
                        Instructions / How to Eat
                      </Label>
                      <Textarea
                        id={`itemHowToEat-${sIndex}-${iIndex}`}
                        value={item.how_to_eat}
                        placeholder="Instructions / How to Eat"
                        onChange={(e) =>
                          updateItem(
                            sIndex,
                            iIndex,
                            "how_to_eat",
                            e.target.value
                          )
                        }
                        rows={3}
                      />
                    </div>

                    <div>
                      <Label htmlFor={`itemVoiceUrl-${sIndex}-${iIndex}`}>
                        Voice URL
                      </Label>
                      <Input
                        id={`itemVoiceUrl-${sIndex}-${iIndex}`}
                        type="text"
                        value={item.voice || ""}
                        placeholder="Voice URL"
                        onChange={(e) =>
                          updateItem(sIndex, iIndex, "voice", e.target.value)
                        }
                      />
                    </div>

                    {/* Nutritional Info */}
                    <div>
                      <h4 className="font-medium mb-2">
                        Nutritional Information
                      </h4>
                      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                        <div>
                          <Label htmlFor={`itemCalories-${sIndex}-${iIndex}`}>
                            Calories
                          </Label>
                          <Input
                            id={`itemCalories-${sIndex}-${iIndex}`}
                            type="number"
                            placeholder="Calories"
                            value={item.nutritional_info?.calories ?? ""}
                            onChange={(e) =>
                              updateNutritionalInfo(
                                sIndex,
                                iIndex,
                                "calories",
                                Number(e.target.value)
                              )
                            }
                          />
                        </div>
                        <div>
                          <Label htmlFor={`itemProtein-${sIndex}-${iIndex}`}>
                            Protein (g)
                          </Label>
                          <Input
                            id={`itemProtein-${sIndex}-${iIndex}`}
                            type="number"
                            placeholder="Protein (g)"
                            value={item.nutritional_info?.protein ?? ""}
                            onChange={(e) =>
                              updateNutritionalInfo(
                                sIndex,
                                iIndex,
                                "protein",
                                Number(e.target.value)
                              )
                            }
                          />
                        </div>
                        <div>
                          <Label htmlFor={`itemCarbs-${sIndex}-${iIndex}`}>
                            Carbs (g)
                          </Label>
                          <Input
                            id={`itemCarbs-${sIndex}-${iIndex}`}
                            type="number"
                            placeholder="Carbs (g)"
                            value={item.nutritional_info?.carbs ?? ""}
                            onChange={(e) =>
                              updateNutritionalInfo(
                                sIndex,
                                iIndex,
                                "carbs",
                                Number(e.target.value)
                              )
                            }
                          />
                        </div>
                        <div>
                          <Label htmlFor={`itemFat-${sIndex}-${iIndex}`}>
                            Fat (g)
                          </Label>
                          <Input
                            id={`itemFat-${sIndex}-${iIndex}`}
                            type="number"
                            placeholder="Fat (g)"
                            value={item.nutritional_info?.fat ?? ""}
                            onChange={(e) =>
                              updateNutritionalInfo(
                                sIndex,
                                iIndex,
                                "fat",
                                Number(e.target.value)
                              )
                            }
                          />
                        </div>
                      </div>
                    </div>

                    {/* Ingredients */}
                    <div>
                      <h4 className="font-medium mb-2">Ingredients</h4>
                      <div className="space-y-2">
                        {item.ingredients.map((ing, ingIndex) => (
                          <div
                            key={ingIndex}
                            className="flex items-center gap-2"
                          >
                            <Input
                              type="text"
                              value={ing}
                              onChange={(e) => {
                                const newIngredients = [...item.ingredients];
                                newIngredients[ingIndex] = e.target.value;
                                updateItem(
                                  sIndex,
                                  iIndex,
                                  "ingredients",
                                  newIngredients
                                );
                              }}
                              className="flex-1"
                            />
                            <Button
                              onClick={() =>
                                removeArrayItem(
                                  sIndex,
                                  iIndex,
                                  "ingredients",
                                  ingIndex
                                )
                              }
                              variant="destructive"
                              size="icon"
                            >
                              <Minus className="h-4 w-4" />
                            </Button>
                          </div>
                        ))}
                      </div>
                      <Input
                        type="text"
                        placeholder="Add ingredient"
                        onKeyDown={(e) => {
                          if (e.key === "Enter") {
                            addArrayItem(
                              sIndex,
                              iIndex,
                              "ingredients",
                              e.currentTarget.value
                            );
                            e.currentTarget.value = "";
                            e.preventDefault();
                          }
                        }}
                        className="mt-2"
                      />
                    </div>

                    {/* Tab Tags */}
                    <div>
                      <h4 className="font-medium mb-2">Tab Tags</h4>
                      <div className="flex flex-wrap gap-2 mb-2">
                        {item.tab_tags?.map((tag, tagIndex) => (
                          <Badge key={tagIndex} variant="secondary">
                            {tag}
                            <Button
                              onClick={() =>
                                removeArrayItem(
                                  sIndex,
                                  iIndex,
                                  "tab_tags",
                                  tagIndex
                                )
                              }
                              variant="ghost"
                              size="icon"
                              className="ml-2 h-4 w-4"
                            >
                              <X className="h-3 w-3" />
                            </Button>
                          </Badge>
                        ))}
                      </div>
                      <Input
                        type="text"
                        placeholder="Add tab tag"
                        onKeyDown={(e) => {
                          if (e.key === "Enter") {
                            addArrayItem(
                              sIndex,
                              iIndex,
                              "tab_tags",
                              e.currentTarget.value
                            );
                            e.currentTarget.value = "";
                            e.preventDefault();
                          }
                        }}
                      />
                    </div>

                    {/* Tab Tags Amharic */}

                    {/* Image Upload */}
                    <div>
                      <Label>Item Images</Label>
                      <div className="grid grid-cols-2 md:grid-cols-3 gap-2 mt-2">
                        {(() => {
                          const key = `${sIndex}-${iIndex}`;
                          const searchedImages = imageSearchResults[key] || [];
                          const allImages = [
                            ...searchedImages,
                            ...item.image.map((url) => ({
                              photo_url: url,
                              thumbnail_url: url, // Use full URL for thumbnail if no separate thumbnail
                              alt_text: "Uploaded image",
                              // Dummy values for other fields if needed
                              item_name: "",
                              confidence_score: 0,
                              source: "local",
                            })),
                          ];

                          if (allImages.length === 0) {
                            return (
                              <p className="text-sm text-gray-500 col-span-2">
                                No images yet
                              </p>
                            );
                          }

                          return allImages.map((img, idx) => (
                            <div
                              key={idx}
                              className={`border rounded-lg cursor-pointer overflow-hidden ${
                                item.image.includes(img.photo_url)
                                  ? "border-orange-500"
                                  : "border-gray-300"
                              }`}
                              onClick={() =>
                                handleImageSelect(sIndex, iIndex, img.photo_url)
                              }
                            >
                              <img
                                src={img.thumbnail_url || img.photo_url}
                                alt={img.alt_text}
                                className="w-full h-24 object-cover"
                              />
                            </div>
                          ));
                        })()}
                      </div>

                      {/* Add this for local upload */}
                      <div className="mt-4">
                        <Label
                          htmlFor={`localUpload-${sIndex}-${iIndex}`}
                          className="cursor-pointer"
                        >
                          <Button variant="outline" asChild>
                            <span>Upload Local Image</span>
                          </Button>
                        </Label>
                        <Input
                          id={`localUpload-${sIndex}-${iIndex}`}
                          type="file"
                          accept="image/*" // Restrict to images
                          className="hidden" // Hide the native input for better styling
                          onChange={(e) => handleLocalUpload(sIndex, iIndex, e)}
                        />
                      </div>
                    </div>
                  </CollapsibleContent>
                </Collapsible>
              ))}
              <Button
                type="button"
                onClick={() => addItem(sIndex)}
                variant="outline"
                className="mt-4"
              >
                <Plus className="h-4 w-4 " /> Add Item
              </Button>
            </CollapsibleContent>
          </Collapsible>
        ))}

        <div className="mt-2.5 flex justify-between pr-5 pb-2 ">
          <Button onClick={addSection}>
            <Plus className="h-4 w-4 " /> Add Section
          </Button>
          <Button onClick={handleSubmit} disabled={loading}>
            {loading ? "Submitting..." : "Submit Menu"}
          </Button>
        </div>
      </div>

      {showPublishModal && (
        <div
          style={{
            position: "fixed",
            top: 0,
            left: 0,
            width: "100%",
            height: "100%",
            backgroundColor: "rgba(0, 0, 0, 0.5)",
            backdropFilter: "blur(5px)",
            display: "flex",
            justifyContent: "center",
            alignItems: "center",
            zIndex: 1000,
          }}
          onClick={() => setShowPublishModal(false)} // Optional: Close on overlay click
        >
          <div
            style={{
              backgroundColor: "white",
              padding: "30px",
              border: "1px solid #ccc",
              borderRadius: "8px",
              boxShadow: "0 4px 12px rgba(0,0,0,0.15)",
              width: "400px", // Adjusted width for better appeal
              maxWidth: "90%",
              textAlign: "center",
            }}
            onClick={(e) => e.stopPropagation()} // Prevent closing when clicking inside modal
          >
            <h2>Publish Menu</h2>
            <p>Your menu has been created. Would you like to publish it now?</p>
            <Button onClick={handlePublish} style={{ marginRight: "10px" }}>
              Publish
            </Button>
            <Button onClick={() => setShowPublishModal(false)}>Cancel</Button>
          </div>
        </div>
      )}
    </>
  );
};

export default ManualMenu;