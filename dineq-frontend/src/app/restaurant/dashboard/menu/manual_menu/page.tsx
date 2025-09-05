"use client";

import React, { useState, useEffect, useCallback } from "react";
import { useMenuContext } from "@/context/MenuOcrContext"; // ⬅️ Import the context hook

// --- The rest of your existing component code goes here ---
// You will need to update the types to match the context's types
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

  useEffect(() => {
    // Check if there are menu items from OCR and they haven't been initialized yet
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

      // Create a single section for the imported items
      setSections([{ name: "Imported from OCR", items: mappedItems }]);

      // Mark as initialized to prevent re-initialization on every re-render
      setInitialized(true);

      // Clear the context state after use
      clearMenuItems();
    }
  }, [ocrMenuItems, initialized, clearMenuItems]);

  const addSection = useCallback(() => {
    setSections((prev) => [...prev, { name: "", items: [] }]);
  }, []);

  const addItem = useCallback(
    (sectionIndex: number) => {
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
    },
    []
  );

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
          (newSections[sectionIndex].items[itemIndex][field] as string[]).push(
            value.trim()
          );
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
        const newArray = [
          ...(newSections[sectionIndex].items[itemIndex][field] as string[]),
        ];
        newArray.splice(arrayIndex, 1);
        (newSections[sectionIndex].items[itemIndex][field] as string[]) =
          newArray;
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
                <button
                  onClick={() => removeTag(i)}
                  className="ml-2"
                >
                  ×
                </button>
              </span>
            ))}
          </div>
        </div>
      </div>

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
                setSections((prev) => {
                  const newSections = [...prev];
                  newSections[sIndex].name = e.target.value;
                  return newSections;
                });
              }}
              className="border-b border-gray-300 focus:outline-none"
            />
          </h2>
          {section.items.map((item, iIndex) => (
            <div
              key={iIndex}
              className="mb-6 border-b pb-6"
            >
              <h3 className="font-medium mb-2">
                Item {iIndex + 1}: {item.name || "Untitled"}
              </h3>
              <input
                type="text"
                value={item.name}
                placeholder="Item name"
                onChange={(e) =>
                  updateItem(sIndex, iIndex, "name", e.target.value)
                }
                className="w-full border border-gray-300 rounded p-2 mb-2"
              />
              <input
                type="text"
                value={item.name_am}
                placeholder="Item name (Amharic)"
                onChange={(e) =>
                  updateItem(sIndex, iIndex, "name_am", e.target.value)
                }
                className="w-full border border-gray-300 rounded p-2 mb-2"
              />
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
              <textarea
                value={item.description}
                placeholder="Description"
                onChange={(e) =>
                  updateItem(sIndex, iIndex, "description", e.target.value)
                }
                className="w-full border border-gray-300 rounded p-2 mb-2"
              />
              <textarea
                value={item.description_am}
                placeholder="Description (Amharic)"
                onChange={(e) =>
                  updateItem(sIndex, iIndex, "description_am", e.target.value)
                }
                className="w-full border border-gray-300 rounded p-2 mb-2"
              />
              <input
                type="text"
                value={item.allergies}
                placeholder="Allergies"
                onChange={(e) =>
                  updateItem(sIndex, iIndex, "allergies", e.target.value)
                }
                className="w-full border border-gray-300 rounded p-2 mb-2"
              />
              <input
                type="text"
                value={item.allergies_am}
                placeholder="Allergies (Amharic)"
                onChange={(e) =>
                  updateItem(sIndex, iIndex, "allergies_am", e.target.value)
                }
                className="w-full border border-gray-300 rounded p-2 mb-2"
              />
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
              <textarea
                value={item.instructions}
                placeholder="Instructions / How to Eat"
                onChange={(e) =>
                  updateItem(sIndex, iIndex, "instructions", e.target.value)
                }
                className="w-full border border-gray-300 rounded p-2 mb-2"
              />
              <textarea
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
                className="w-full border border-gray-300 rounded p-2 mb-2"
              />
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
                  onChange={(e) =>
                    updateNutritionalInfo(
                      sIndex,
                      iIndex,
                      "calories",
                      Number(e.target.value)
                    )
                  }
                  className="border border-gray-300 rounded p-2"
                />
                <input
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
                  className="border border-gray-300 rounded p-2"
                />
                <input
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
                  className="border border-gray-300 rounded p-2"
                />
                <input
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
                  className="border border-gray-300 rounded p-2"
                />
              </div>

              {/* Ingredients */}
              <div className="mb-2">
                <h4 className="font-medium mb-1">Ingredients</h4>
                {item.ingredients.map((ing, ingIndex) => (
                  <div
                    key={ingIndex}
                    className="flex mb-1"
                  >
                    <input
                      type="text"
                      value={ing}
                      onChange={(e) => {
                        const newIngredients = [...item.ingredients];
                        newIngredients[ingIndex] = e.target.value;
                        updateItem(sIndex, iIndex, "ingredients", newIngredients);
                      }}
                      className="flex-1 border border-gray-300 rounded p-2 mr-2"
                    />
                    <button
                      onClick={() =>
                        removeArrayItem(sIndex, iIndex, "ingredients", ingIndex)
                      }
                      className="text-red-500"
                    >
                      ×
                    </button>
                  </div>
                ))}
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
                      e.preventDefault();
                    }
                  }}
                  className="flex-1 border border-gray-300 rounded p-2"
                />
              </div>

              {/* Tab Tags */}
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
                          removeArrayItem(sIndex, iIndex, "tab_tags", tagIndex)
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
                      e.preventDefault();
                    }
                  }}
                  className="w-full border border-gray-300 rounded p-2"
                />
              </div>

              {/* Tab Tags Amharic */}
              <div className="mb-2">
                <h4 className="font-medium mb-1">Tab Tags (Amharic)</h4>
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
                  className="w-full border border-gray-300 rounded p-2"
                />
              </div>

              {/* Image Upload */}
              <input
                type="file"
                accept="image/*"
                onChange={(e) => {
                  const file = e.target.files?.[0];
                  if (file) {
                    updateItem(sIndex, iIndex, "image", file);
                  }
                }}
                className="mb-2"
              />
            </div>
          ))}
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
        className="bg-orange-500 text-white px-4 py-2 rounded"
      >
        + Add Section
      </button>
    </div>
  );
};

export default ManualMenu;