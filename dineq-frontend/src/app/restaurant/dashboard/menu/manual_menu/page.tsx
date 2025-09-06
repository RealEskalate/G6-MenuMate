"use client";

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
import { useMenuContext } from "@/context/MenuOcrContext";
import { ChevronDown, ChevronUp, Plus, Minus, X } from "lucide-react";
import { Badge } from "@/components/ui/badge";

interface NutritionalInfo {
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
}

interface MenuItem {
  name: string;
  name_am?: string;
  image: File | null | string;
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
  instructions: string;
  instructions_am?: string;
  voice?: string | null;
}

interface Section {
  name: string;
  items: MenuItem[];
}

const ManualMenu = () => {
  const { menuItems: ocrMenuItems, clearMenuItems } = useMenuContext();
  console.log("OCR Menu Items from Context:", ocrMenuItems);

  const [initialized, setInitialized] = useState(false);
  const [menuName, setMenuName] = useState("Untitled menu");
  const [language, setLanguage] = useState("Amharic");
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
      newSections[sectionIndex].items.push({
        name: "",
        name_am: "",
        image: null,
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
        instructions: "",
        instructions_am: "",
        voice: null,
      });
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
        newSections[sectionIndex].items[itemIndex].nutritional_info =
          updatedNutritionalInfo;
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
          if (Array.isArray(newSections[sectionIndex].items[itemIndex][field])) {
            (newSections[sectionIndex].items[itemIndex][field] as string[]).push(
              value.trim()
            );
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
  }, []);

  return (
    <div className="flex-1 p-6 bg-white">
      <h1 className="text-2xl font-bold mb-6">Manual Menu Editor</h1>

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
              <Plus className="h-4 w-4 mr-2" /> Add Tag
            </Button>
          </div>
          <div className="flex flex-wrap gap-2">
            {tags.map((tag, i) => (
              <Badge key={i} variant="secondary" className="flex items-center">
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
                  className="inline-block border-b border-gray-300 focus:outline-none p-0"
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
                        placeholder="Item name"
                        onChange={(e) =>
                          updateItem(sIndex, iIndex, "name", e.target.value)
                        }
                      />
                    </div>
                    <div>
                      <Label htmlFor={`itemNameAmharic-${sIndex}-${iIndex}`}>
                        Item Name (Amharic)
                      </Label>
                      <Input
                        id={`itemNameAmharic-${sIndex}-${iIndex}`}
                        type="text"
                        value={item.name_am}
                        placeholder="Item name (Amharic)"
                        onChange={(e) =>
                          updateItem(sIndex, iIndex, "name_am", e.target.value)
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
                  <div>
                    <Label htmlFor={`itemDescriptionAmharic-${sIndex}-${iIndex}`}>
                      Description (Amharic)
                    </Label>
                    <Textarea
                      id={`itemDescriptionAmharic-${sIndex}-${iIndex}`}
                      value={item.description_am}
                      placeholder="Description (Amharic)"
                      onChange={(e) =>
                        updateItem(
                          sIndex,
                          iIndex,
                          "description_am",
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
                    <div>
                      <Label htmlFor={`itemAllergiesAmharic-${sIndex}-${iIndex}`}>
                        Allergies (Amharic)
                      </Label>
                      <Input
                        id={`itemAllergiesAmharic-${sIndex}-${iIndex}`}
                        type="text"
                        value={item.allergies_am}
                        placeholder="Allergies (Amharic)"
                        onChange={(e) =>
                          updateItem(
                            sIndex,
                            iIndex,
                            "allergies_am",
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
                    <Label htmlFor={`itemInstructions-${sIndex}-${iIndex}`}>
                      Instructions / How to Eat
                    </Label>
                    <Textarea
                      id={`itemInstructions-${sIndex}-${iIndex}`}
                      value={item.instructions}
                      placeholder="Instructions / How to Eat"
                      onChange={(e) =>
                        updateItem(
                          sIndex,
                          iIndex,
                          "instructions",
                          e.target.value
                        )
                      }
                      rows={3}
                    />
                  </div>
                  <div>
                    <Label htmlFor={`itemInstructionsAmharic-${sIndex}-${iIndex}`}>
                      Instructions (Amharic)
                    </Label>
                    <Textarea
                      id={`itemInstructionsAmharic-${sIndex}-${iIndex}`}
                      value={item.instructions_am}
                      placeholder="Instructions (Amharic)"
                      onChange={(e) =>
                        updateItem(
                          sIndex,
                          iIndex,
                          "instructions_am",
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
                    <h4 className="font-medium mb-2">Nutritional Information</h4>
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
                        <div key={ingIndex} className="flex items-center gap-2">
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
                  <div>
                    <h4 className="font-medium mb-2">Tab Tags (Amharic)</h4>
                    <div className="flex flex-wrap gap-2 mb-2">
                      {item.tab_tags_am?.map((tag, tagIndex) => (
                        <Badge key={tagIndex} variant="secondary">
                          {tag}
                          <Button
                            onClick={() =>
                              removeArrayItem(
                                sIndex,
                                iIndex,
                                "tab_tags_am",
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
                      placeholder="Add tab tag (Amharic)"
                      onKeyDown={(e) => {
                        if (e.key === "Enter") {
                          addArrayItem(
                            sIndex,
                            iIndex,
                            "tab_tags_am",
                            e.currentTarget.value
                          );
                          e.currentTarget.value = "";
                          e.preventDefault();
                        }
                      }}
                    />
                  </div>

                  {/* Image Upload */}
                  <div>
                    <Label htmlFor={`itemImage-${sIndex}-${iIndex}`}>
                      Item Image
                    </Label>
                    <Input
                      id={`itemImage-${sIndex}-${iIndex}`}
                      type="file"
                      accept="image/*"
                      onChange={(e) => {
                        const file = e.target.files?.[0];
                        if (file) {
                          updateItem(sIndex, iIndex, "image", file);
                        }
                      }}
                    />
                  </div>
                </CollapsibleContent>
              </Collapsible>
            ))}
            <Button
              onClick={() => addItem(sIndex)}
              variant="outline"
              className="mt-4"
            >
              <Plus className="h-4 w-4 mr-2" /> Add Item
            </Button>
          </CollapsibleContent>
        </Collapsible>
      ))}

      <Button onClick={addSection}>
        <Plus className="h-4 w-4 mr-2" /> Add Section
      </Button>
    </div>
  );
};

export default ManualMenu;