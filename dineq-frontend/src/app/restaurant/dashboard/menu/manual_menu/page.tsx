"use client";

import React, { useState, useEffect } from "react";
import { useSelector, useDispatch } from "react-redux";
import { useSession } from "next-auth/react";
import { useRouter } from "next/navigation";
import { RootState } from "@/store";
import { clearMenuItems } from "@/store/menuSlice";
import { createMenu, uploadImage } from "@/lib/menuApi";

// --- Types ---
export interface NutritionalInfo {
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
}

export interface MenuItem {
  name: string;
  name_am?: string;
  image: string | File | null;
  price: number | string;
  currency?: string;
  ingredients: string[];
  description: string;
  description_am?: string;
  tab_tags?: string[];
  tab_tags_am?: string[];
  allergies?: string;
  allergies_am?: string;
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

const ManualMenu = () => {
  const dispatch = useDispatch();
  const { data: session } = useSession();
  const router = useRouter();
  const ocrMenuItems = useSelector(
    (state: RootState) => state.menu?.menuItems ?? []
  );

  console.log("OCR Menu Items from Redux:", ocrMenuItems);

  const [initialized, setInitialized] = useState(false);
  const [menuName, setMenuName] = useState("Untitled menu");
  const [language, setLanguage] = useState("Amharic");
  const [tags, setTags] = useState<string[]>([]);
  const [newTag, setNewTag] = useState("");
  const [sections, setSections] = useState<Section[]>([
    { name: "Starters", items: [] },
  ]);
  const [expandedItems, setExpandedItems] = useState<{
    [key: string]: boolean;
  }>({});
  const [loading, setLoading] = useState(false);
  const [restaurantSlug, setRestaurantSlug] = useState<string | null>(null);

  // ✅ Fetch restaurant slug on login
  useEffect(() => {
    const fetchRestaurantSlug = async () => {
      if (!session?.accessToken) return;

      try {
        const res = await fetch(
          `${process.env.NEXT_PUBLIC_API_BASE_URL}/restaurants/me`,
          {
            headers: {
              Authorization: `Bearer ${session.accessToken}`,
            },
          }
        );

        if (!res.ok) throw new Error("Failed to fetch restaurant info");

        const data = await res.json();
        console.log("🍽 Restaurant info:", data);

        if (data?.restaurants?.length > 0) {
          setRestaurantSlug(data.restaurants[0].slug);
        }
      } catch (err) {
        console.error("❌ Error fetching restaurant slug:", err);
      }
    };

    fetchRestaurantSlug();
  }, [session?.accessToken]);

  // ✅ Hydrate OCR items from Redux then clear store
  useEffect(() => {
    if (!initialized && ocrMenuItems.length > 0) {
      const mappedItems: MenuItem[] = ocrMenuItems.map((item: any) => ({
        name: item.name ?? "",
        name_am: item.name_am ?? "",
        image: null,
        price: item.price ?? "",
        currency: item.currency ?? "",
        ingredients: item.ingredients ?? [],
        description: item.description ?? "",
        description_am: item.description_am ?? "",
        tab_tags: item.tab_tags ?? [],
        tab_tags_am: item.tab_tags_am ?? [],
        allergies: item.allergies ?? "",
        allergies_am: item.allergies_am ?? "",
        nutritional_info: item.nutritional_info ?? {
          calories: 0,
          protein: 0,
          carbs: 0,
          fat: 0,
        },
        preparation_time: item.preparation_time ?? 0,
        how_to_eat: item.how_to_eat ?? "",
        how_to_eat_am: item.how_to_eat_am ?? "",
        voice: item.voice ?? null,
      }));

      setSections([{ name: "Imported from OCR", items: mappedItems }]);
      setInitialized(true);
      dispatch(clearMenuItems()); // 🧹 clear store
    }
  }, [ocrMenuItems, initialized, dispatch]);

  // --- Handlers ---
  const addSection = () => {
    setSections([...sections, { name: "", items: [] }]);
  };

  const addItem = (sectionIndex: number) => {
    const newSections = [...sections];
    newSections[sectionIndex].items.push({
      name: "",
      name_am: "",
      image: null,
      price: "",
      currency: "",
      ingredients: [""],
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
    });
    setSections(newSections);
  };

  const updateItem = (
    sectionIndex: number,
    itemIndex: number,
    field: keyof MenuItem,
    value: any
  ) => {
    const newSections = [...sections];
    (newSections[sectionIndex].items[itemIndex] as any)[field] = value;
    setSections(newSections);
  };

  // const updateNutritionalInfo = (
  //   sectionIndex: number,
  //   itemIndex: number,
  //   subField: keyof NutritionalInfo,
  //   value: number
  // ) => {
  //   const newSections = [...sections];
  //   const item = newSections[sectionIndex].items[itemIndex];
  //   item.nutritional_info = {
  //     ...item.nutritional_info,
  //     [subField]: value,
  //   };
  //   setSections(newSections);
  // };

  const addArrayItem = (
    sectionIndex: number,
    itemIndex: number,
    field: "ingredients" | "tab_tags" | "tab_tags_am",
    value: string
  ) => {
    if (value.trim()) {
      const newSections = [...sections];
      (newSections[sectionIndex].items[itemIndex][field] as string[]).push(
        value.trim()
      );
      setSections(newSections);
    }
  };

  const removeArrayItem = (
    sectionIndex: number,
    itemIndex: number,
    field: "ingredients" | "tab_tags" | "tab_tags_am",
    arrayIndex: number
  ) => {
    const newSections = [...sections];
    (newSections[sectionIndex].items[itemIndex][field] as string[]).splice(
      arrayIndex,
      1
    );
    setSections(newSections);
  };

  const handleImageSelect = (
    e: React.ChangeEvent<HTMLInputElement>,
    sectionIndex: number,
    itemIndex: number
  ) => {
    const file = e.target.files?.[0];
    if (file) {
      updateItem(sectionIndex, itemIndex, "image", file);
    }
  };

  const handleAddTag = () => {
    if (newTag.trim()) {
      setTags([...tags, newTag.trim()]);
      setNewTag("");
    }
  };

  const removeTag = (index: number) => {
    setTags(tags.filter((_, i) => i !== index));
  };

  const toggleItemExpand = (sectionIndex: number, itemIndex: number) => {
    const key = `${sectionIndex}-${itemIndex}`;
    setExpandedItems((prev) => ({ ...prev, [key]: !prev[key] }));
  };

  const handleSubmit = async () => {
    if (!session?.accessToken || !restaurantSlug) {
      console.error("Missing access token or restaurant slug");
      return;
    }

    setLoading(true);

    try {
      const processedSections = await Promise.all(
        sections.map(async (s) => ({
          name: s.name,
          menu_items: await Promise.all(
            s.items.map(async (i) => {
              let imageUrl: string | null = null;
              if (i.image  instanceof File) {
                imageUrl = await uploadImage(i.image, session.accessToken!);
              } else if (typeof i.image === "string") {
                imageUrl = i.image;
              }

              // ✅ Drop *_am fields before sending
              const {
                name_am,
                description_am,
                tab_tags_am,
                allergies_am,
                how_to_eat_am,
                ...rest
              } = i;

              return {
                ...rest,
                image: imageUrl,
              };
            })
          ),
        }))
      );

      const payload = processedSections;

      const response = await createMenu(
        payload,
        session.accessToken,
        restaurantSlug
      );
      console.log("✅ Menu created:", response);
      router.push("/restaurant/dashboard/menu");
    } catch (err) {
      console.error("❌ Error submitting menu:", err);
    } finally {
      setLoading(false);
    }
  };

  // --- Render ---
  return (
    <div className="flex-1 p-6 bg-white">
      <h1 className="text-2xl font-bold mb-6">Add Menu Manually</h1>

      {/* Basic Details */}
      <div className="border border-orange-300 rounded-lg p-6 mb-6">
        <h2 className="text-lg font-semibold mb-4">Basic Details</h2>
        <div className="flex flex-col md:flex-row gap-4 mb-4">
          <input
            type="text"
            value={menuName}
            onChange={(e) => setMenuName(e.target.value)}
            className="flex-1 border border-gray-300 rounded p-2"
            placeholder="Menu name"
          />
          <select
            value={language}
            onChange={(e) => setLanguage(e.target.value)}
            className="flex-1 border border-gray-300 rounded p-2"
          >
            <option>Amharic</option>
            <option>English</option>
          </select>
        </div>

        {/* Tags */}
        <div>
          <input
            type="text"
            value={newTag}
            onChange={(e) => setNewTag(e.target.value)}
            className="border border-gray-300 rounded p-2 mr-2"
            placeholder="Enter tag"
          />
          <button
            onClick={handleAddTag}
            className="bg-orange-500 text-white px-4 py-2 rounded"
          >
            Add Tag
          </button>
          <div className="flex flex-wrap gap-2 mt-2">
            {tags.map((tag, i) => (
              <span
                key={i}
                className="bg-orange-100 text-orange-700 px-3 py-1 rounded-full flex items-center"
              >
                {tag}
                <button onClick={() => removeTag(i)} className="ml-2">
                  ×
                </button>
              </span>
            ))}
          </div>
        </div>
      </div>

      {/* Sections + Items */}
      {sections.map((section, sIndex) => (
        <div
          key={sIndex}
          className="border border-orange-300 rounded-lg p-6 mb-6"
        >
          <h2 className="text-lg font-semibold mb-4">
            Section {sIndex + 1}:{" "}
            <input
              type="text"
              value={section.name}
              onChange={(e) => {
                const newSections = [...sections];
                newSections[sIndex].name = e.target.value;
                setSections(newSections);
              }}
              className="border-b border-gray-300 focus:outline-none"
            />
          </h2>

          {section.items.map((item, iIndex) => {
            const key = `${sIndex}-${iIndex}`;
            const isExpanded = expandedItems[key] || false;
            const displayName =
              language === "Amharic"
                ? item.name_am || "Untitled"
                : item.name || "Untitled";
            return (
              <div key={iIndex} className="mb-6 border-b pb-6">
                <div className="flex justify-between items-center">
                  <h3 className="font-medium mb-2">
                    Item {iIndex + 1}: {displayName}
                  </h3>
                  <span
                    className="cursor-pointer"
                    onClick={() => toggleItemExpand(sIndex, iIndex)}
                  >
                    {isExpanded ? "▲" : "▼"}
                  </span>
                </div>

                {isExpanded && (
                  <div className="mt-4">
                    {/* Basic Fields */}
                    <label className="block mb-1 font-medium">Item Name</label>
                    {language === "English" ? (
                      <input
                        type="text"
                        value={item.name}
                        placeholder="Item name"
                        onChange={(e) =>
                          updateItem(sIndex, iIndex, "name", e.target.value)
                        }
                        className="w-full border border-gray-300 rounded p-2 mb-2"
                      />
                    ) : (
                      <input
                        type="text"
                        value={item.name_am}
                        placeholder="Item name"
                        onChange={(e) =>
                          updateItem(sIndex, iIndex, "name_am", e.target.value)
                        }
                        className="w-full border border-gray-300 rounded p-2 mb-2"
                      />
                    )}
                    <input
                      type="text"
                      value={item.price as string}
                      placeholder="Price"
                      onChange={(e) =>
                        updateItem(sIndex, iIndex, "price", e.target.value)
                      }
                      className="w-full border border-gray-300 rounded p-2 mb-2"
                    />
                    <input
                      type="text"
                      value={item.currency}
                      placeholder="Currency"
                      onChange={(e) =>
                        updateItem(sIndex, iIndex, "currency", e.target.value)
                      }
                      className="w-full border border-gray-300 rounded p-2 mb-2"
                    />
                    {language === "English" ? (
                      <textarea
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
                        className="w-full border border-gray-300 rounded p-2 mb-2"
                      />
                    ) : (
                      <textarea
                        value={item.description_am}
                        placeholder="Description"
                        onChange={(e) =>
                          updateItem(
                            sIndex,
                            iIndex,
                            "description_am",
                            e.target.value
                          )
                        }
                        className="w-full border border-gray-300 rounded p-2 mb-2"
                      />
                    )}
                    {language === "English" ? (
                      <input
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
                        className="w-full border border-gray-300 rounded p-2 mb-2"
                      />
                    ) : (
                      <input
                        type="text"
                        value={item.allergies_am}
                        placeholder="Allergies"
                        onChange={(e) =>
                          updateItem(
                            sIndex,
                            iIndex,
                            "allergies_am",
                            e.target.value
                          )
                        }
                        className="w-full border border-gray-300 rounded p-2 mb-2"
                      />
                    )}
                    <input
                      type="number"
                      value={item.preparation_time}
                      placeholder="Preparation Time (minutes)"
                      onChange={(e) =>
                        updateItem(
                          sIndex,
                          iIndex,
                          "preparation_time",
                          Number(e.target.value)
                        )
                      }
                      className="w-full border border-gray-300 rounded p-2 mb-2"
                    />
                    {language === "English" ? (
                      <textarea
                        value={item.how_to_eat}
                        placeholder="How to Eat"
                        onChange={(e) =>
                          updateItem(
                            sIndex,
                            iIndex,
                            "how_to_eat",
                            e.target.value
                          )
                        }
                        className="w-full border border-gray-300 rounded p-2 mb-2"
                      />
                    ) : (
                      <textarea
                        value={item.how_to_eat_am}
                        placeholder="How to Eat"
                        onChange={(e) =>
                          updateItem(
                            sIndex,
                            iIndex,
                            "how_to_eat_am",
                            e.target.value
                          )
                        }
                        className="w-full border border-gray-300 rounded p-2 mb-2"
                      />
                    )}
                    <input
                      type="text"
                      value={item.voice || ""}
                      placeholder="Voice URL"
                      onChange={(e) =>
                        updateItem(sIndex, iIndex, "voice", e.target.value)
                      }
                      className="w-full border border-gray-300 rounded p-2 mb-2"
                    />

                    {/* Nutritional Info */}
                    <div className="grid grid-cols-4 gap-2 mb-2">
                      <input
                        type="number"
                        placeholder="Calories"
                        value={item.nutritional_info?.calories ?? ""}
                        // onChange={(e) =>
                        //   updateNutritionalInfo(
                        //     sIndex,
                        //     iIndex,
                        //     "calories",
                        //     Number(e.target.value)
                        //   )
                        //}
                        className="border border-gray-300 rounded p-2"
                      />
                      <input
                        type="number"
                        placeholder="Protein (g)"
                        value={item.nutritional_info?.protein ?? ""}
                        // onChange={(e) =>
                        //   updateNutritionalInfo(
                        //     sIndex,
                        //     iIndex,
                        //     "protein",
                        //     Number(e.target.value)
                        //   )
                        // }
                        className="border border-gray-300 rounded p-2"
                      />
                      <input
                        type="number"
                        placeholder="Carbs (g)"
                        value={item.nutritional_info?.carbs ?? ""}
                        // onChange={(e) =>
                        //   updateNutritionalInfo(
                        //     sIndex,
                        //     iIndex,
                        //     "carbs",
                        //     Number(e.target.value)
                        //   )
                        // }
                        className="border border-gray-300 rounded p-2"
                      />
                      <input
                        type="number"
                        placeholder="Fat (g)"
                        value={item.nutritional_info?.fat ?? ""}
                        // onChange={(e) =>
                        //   updateNutritionalInfo(
                        //     sIndex,
                        //     iIndex,
                        //     "fat",
                        //     Number(e.target.value)
                        //   )
                        // }
                        className="border border-gray-300 rounded p-2"
                      />
                    </div>

                    {/* Ingredients */}
                    <div className="mb-2">
                      <h4 className="font-medium mb-1">Ingredients</h4>
                      {item.ingredients.map((ing, ingIndex) => (
                        <div key={ingIndex} className="flex mb-1">
                          <input
                            type="text"
                            value={ing}
                            onChange={(e) => {
                              const newSections = [...sections];
                              newSections[sIndex].items[iIndex].ingredients[
                                ingIndex
                              ] = e.target.value;
                              setSections(newSections);
                            }}
                            className="flex-1 border border-gray-300 rounded p-2 mr-2"
                          />
                          <button
                            onClick={() =>
                              removeArrayItem(
                                sIndex,
                                iIndex,
                                "ingredients",
                                ingIndex
                              )
                            }
                            className="text-red-500"
                          >
                            ×
                          </button>
                        </div>
                      ))}
                      <div className="flex">
                        <input
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
                            }
                          }}
                          className="flex-1 border border-gray-300 rounded p-2"
                        />
                      </div>
                    </div>

                    {/* Tab Tags */}
                    {language === "English" ? (
                      <div className="mb-2">
                        <h4 className="font-medium mb-1">Tab Tags</h4>
                        <div className="flex flex-wrap gap-2 mb-2">
                          {item.tab_tags?.map((tag, tagIndex) => (
                            <span
                              key={tagIndex}
                              className="bg-orange-100 text-orange-700 px-3 py-1 rounded-full flex items-center"
                            >
                              {tag}
                              <button
                                onClick={() =>
                                  removeArrayItem(
                                    sIndex,
                                    iIndex,
                                    "tab_tags",
                                    tagIndex
                                  )
                                }
                                className="ml-2"
                              >
                                ×
                              </button>
                            </span>
                          ))}
                        </div>
                        <input
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
                            }
                          }}
                          className="w-full border border-gray-300 rounded p-2"
                        />
                      </div>
                    ) : (
                      <div className="mb-2">
                        <h4 className="font-medium mb-1">Tab Tags</h4>
                        <div className="flex flex-wrap gap-2 mb-2">
                          {item.tab_tags_am?.map((tag, tagIndex) => (
                            <span
                              key={tagIndex}
                              className="bg-orange-100 text-orange-700 px-3 py-1 rounded-full flex items-center"
                            >
                              {tag}
                              <button
                                onClick={() =>
                                  removeArrayItem(
                                    sIndex,
                                    iIndex,
                                    "tab_tags_am",
                                    tagIndex
                                  )
                                }
                                className="ml-2"
                              >
                                ×
                              </button>
                            </span>
                          ))}
                        </div>
                        <input
                          type="text"
                          placeholder="Add tab tag"
                          onKeyDown={(e) => {
                            if (e.key === "Enter") {
                              addArrayItem(
                                sIndex,
                                iIndex,
                                "tab_tags_am",
                                e.currentTarget.value
                              );
                              e.currentTarget.value = "";
                            }
                          }}
                          className="w-full border border-gray-300 rounded p-2"
                        />
                      </div>
                    )}

                    {/* Image Upload */}
                    <input
                      type="file"
                      accept="image/*"
                      onChange={(e) => handleImageSelect(e, sIndex, iIndex)}
                      className="mb-2"
                    />
                  </div>
                )}
              </div>
            );
          })}

          <button
            onClick={() => addItem(sIndex)}
            className="bg-orange-100 text-orange-500 px-4 py-2 rounded"
          >
            + Add Item
          </button>
        </div>
      ))}

      <button
        onClick={addSection}
        className="bg-orange-500 text-white px-4 py-2 rounded mr-4"
      >
        + Add Section
      </button>
      <button
        onClick={handleSubmit}
        disabled={loading}
        className="bg-orange-500 text-white px-4 py-2 rounded"
      >
        {loading ? "Submitting..." : "Submit Menu"}
      </button>
    </div>
  );
};

export default ManualMenu;
