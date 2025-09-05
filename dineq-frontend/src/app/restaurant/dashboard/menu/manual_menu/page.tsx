"use client";

import React, { useState, useEffect } from "react";
import { useSelector, useDispatch } from "react-redux";
import { RootState } from "@/store";
import { clearMenuItems } from "@/store/menuSlice";

// --- Types from OCR response ---
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
  const dispatch = useDispatch();
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

  // ✅ Hydrate from Redux once, then clear store
  useEffect(() => {
    if (!initialized && ocrMenuItems.length > 0) {
      const mappedItems: MenuItem[] = ocrMenuItems.map((item: any) => ({
        name: item.name ?? "",
        name_am: item.name_am ?? "",
        image: null, // replace OCR string with File later if needed
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
        instructions: item.how_to_eat ?? "",
        instructions_am: item.how_to_eat_am ?? "",
        voice: item.voice ?? null,
      }));

      setSections([
        {
          name: "Imported from OCR",
          items: mappedItems,
        },
      ]);

      setInitialized(true);
      dispatch(clearMenuItems()); // 🧹 clear store so no duplication
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
      instructions: "",
      instructions_am: "",
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

  const updateNutritionalInfo = (
    sectionIndex: number,
    itemIndex: number,
    subField: keyof NutritionalInfo,
    value: number
  ) => {
    const newSections = [...sections];
    const item = newSections[sectionIndex].items[itemIndex];
    item.nutritional_info = {
      ...item.nutritional_info,
      [subField]: value,
    };
    setSections(newSections);
  };

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

  // --- Render ---
  return (
    <div className="flex-1 p-6 bg-white">
      <h1 className="text-2xl font-bold mb-6">Manual Menu Editor</h1>

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
            return (
              <div key={iIndex} className="mb-6 border-b pb-6">
                <div
                  className="flex justify-between items-center cursor-pointer"
                  onClick={() => toggleItemExpand(sIndex, iIndex)}
                >
                  <h3 className="font-medium mb-2">
                    Item {iIndex + 1}: {item.name || "Untitled"}
                  </h3>
                  <span>{isExpanded ? "▲" : "▼"}</span>
                </div>

                {isExpanded && (
                  <div className="mt-4">
                    {/* Basic Fields */}
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
                        updateItem(
                          sIndex,
                          iIndex,
                          "description",
                          e.target.value
                        )
                      }
                      className="w-full border border-gray-300 rounded p-2 mb-2"
                    />
                    <textarea
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
                        updateItem(
                          sIndex,
                          iIndex,
                          "allergies_am",
                          e.target.value
                        )
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
                        updateItem(
                          sIndex,
                          iIndex,
                          "instructions",
                          e.target.value
                        )
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
                          }
                        }}
                        className="w-full border border-gray-300 rounded p-2"
                      />
                    </div>

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
        className="bg-orange-500 text-white px-4 py-2 rounded"
      >
        + Add Section
      </button>
    </div>
  );
};

export default ManualMenu;
