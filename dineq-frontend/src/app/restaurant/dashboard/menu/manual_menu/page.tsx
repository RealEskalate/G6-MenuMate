"use client";

import React, { useState } from "react";

const ManualMenu = () => {
  const [menuName, setMenuName] = useState("Untitled menu");
  const [language, setLanguage] = useState("Amharic");
  const [tags, setTags] = useState<string[]>([]);
  const [newTag, setNewTag] = useState("");
  type MenuItem = {
    name: string;
    image: File | null;
    price: string;
    ingredients: string[];
    description: string;
    instructions: string;
    voice: File | null;
  };

  type Section = {
    name: string;
    items: MenuItem[];
  };

  const [sections, setSections] = useState<Section[]>([
    {
      name: "Starters",
      items: [
        {
          name: "",
          image: null,
          price: "",
          ingredients: ["Ingredient 1"],
          description: "",
          instructions: "",
          voice: null,
        },
      ],
    },
  ]);

  const addSection = () => {
    setSections([...sections, { name: "", items: [] }]);
  };

  const addItem = (sectionIndex: number) => {
    const newSections = [...sections];
    newSections[sectionIndex].items.push({
      name: "",
      image: null,
      price: "",
      ingredients: ["Ingredient 1"],
      description: "",
      instructions: "",
      voice: null,
    });
    setSections(newSections);
  };

  const addIngredient = (sectionIndex: number, itemIndex: number) => {
    const newSections = [...sections];
    newSections[sectionIndex].items[itemIndex].ingredients.push("");
    setSections(newSections);
  };

  const handleSectionNameChange = (sectionIndex: number, value: string) => {
    const newSections = [...sections];
    newSections[sectionIndex].name = value;
    setSections(newSections);
  };

  const handleItemNameChange = (
    sectionIndex: number,
    itemIndex: number,
    value: string
  ) => {
    const newSections = [...sections];
    newSections[sectionIndex].items[itemIndex].name = value;
    setSections(newSections);
  };

  const handlePriceChange = (
    sectionIndex: number,
    itemIndex: number,
    value: string
  ) => {
    const newSections = [...sections];
    newSections[sectionIndex].items[itemIndex].price = value;
    setSections(newSections);
  };

  const handleIngredientChange = (
    sectionIndex: number,
    itemIndex: number,
    ingIndex: number,
    value: string
  ) => {
    const newSections = [...sections];
    newSections[sectionIndex].items[itemIndex].ingredients[ingIndex] = value;
    setSections(newSections);
  };

  const handleDescriptionChange = (
    sectionIndex: number,
    itemIndex: number,
    value: string
  ) => {
    const newSections = [...sections];
    newSections[sectionIndex].items[itemIndex].description = value;
    setSections(newSections);
  };

  const handleInstructionsChange = (
    sectionIndex: number,
    itemIndex: number,
    value: string
  ) => {
    const newSections = [...sections];
    newSections[sectionIndex].items[itemIndex].instructions = value;
    setSections(newSections);
  };

  const handleImageDrop = (
    e: React.DragEvent<HTMLDivElement>,
    sectionIndex: number,
    itemIndex: number
  ) => {
    e.preventDefault();
    const file = e.dataTransfer.files[0];
    if (file && file.type.startsWith("image/")) {
      const newSections = [...sections];
      newSections[sectionIndex].items[itemIndex].image = file;
      setSections(newSections);
    }
  };

  const handleImageSelect = (
    e: React.ChangeEvent<HTMLInputElement>,
    sectionIndex: number,
    itemIndex: number
  ) => {
    const files = e.target.files;
    const file = files && files[0];
    if (file && file.type.startsWith("image/")) {
      const newSections = [...sections];
      newSections[sectionIndex].items[itemIndex].image = file;
      setSections(newSections);
    }
  };

  const handleVoiceDrop = (
    e: React.DragEvent<HTMLDivElement>,
    sectionIndex: number,
    itemIndex: number
  ) => {
    e.preventDefault();
    const file = e.dataTransfer.files[0];
    if (file && file.type === "audio/mpeg" && file.size <= 10 * 1024 * 1024) {
      const newSections = [...sections];
      newSections[sectionIndex].items[itemIndex].voice = file;
      setSections(newSections);
    }
  };

  const handleVoiceSelect = (
    e: React.ChangeEvent<HTMLInputElement>,
    sectionIndex: number,
    itemIndex: number
  ) => {
    const file = e.target.files && e.target.files[0];
    if (file && file.type === "audio/mpeg" && file.size <= 10 * 1024 * 1024) {
      const newSections = [...sections];
      newSections[sectionIndex].items[itemIndex].voice = file;
      setSections(newSections);
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

  const preventDefault = (e: { preventDefault: () => void }) => {
    e.preventDefault();
  };

  return (
    <div className="flex-1 p-6 bg-white">
      <h1 className="text-2xl font-bold mb-6">Add menu Manually</h1>

      <div className="border border-orange-300 rounded-lg p-6 mb-6">
        <h2 className="text-lg font-semibold mb-4">Basic Details</h2>
        <div className="flex flex-col md:flex-row gap-4 mb-4">
          <div className="flex-1">
            <label className="block text-sm font-medium mb-1">Menu name</label>
            <input
              type="text"
              value={menuName}
              onChange={(e) => setMenuName(e.target.value)}
              className="w-full border border-gray-300 rounded p-2"
              placeholder="Untitled menu"
            />
          </div>
          <div className="flex-1">
            <label className="block text-sm font-medium mb-1">Language</label>
            <select
              value={language}
              onChange={(e) => setLanguage(e.target.value)}
              className="w-full border border-gray-300 rounded p-2"
            >
              <option>Amharic</option>
              {/* Add more languages as needed */}
            </select>
          </div>
        </div>
        <div>
          <button
            onClick={() => setNewTag("")} // Show input on click if needed, but for simplicity, always show
            className="bg-gray-200 text-gray-700 px-4 py-2 rounded flex items-center"
          >
            <span className="mr-2">📎</span> Add Tag
          </button>
          {newTag !== null && (
            <div className="mt-2">
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
                Add
              </button>
            </div>
          )}
          <div className="flex flex-wrap gap-2 mt-2">
            {tags.map((tag, index) => (
              <span
                key={index}
                className="bg-orange-100 text-orange-700 px-3 py-1 rounded-full flex items-center"
              >
                {tag}
                <button
                  onClick={() => removeTag(index)}
                  className="ml-2 text-orange-700"
                >
                  ×
                </button>
              </span>
            ))}
          </div>
        </div>
      </div>

      {sections.map((section, sectionIndex) => (
        <div
          key={sectionIndex}
          className="border border-orange-300 rounded-lg p-6 mb-6"
        >
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-lg font-semibold">
              Section {sectionIndex + 1}
            </h2>
            <button className="text-orange-500 flex items-center">
              <span className="mr-1">✨</span> AI Assistant
            </button>
          </div>
          <div className="mb-4">
            <label className="block text-sm font-medium mb-1">
              Section name
            </label>
            <input
              type="text"
              value={section.name}
              onChange={(e) =>
                handleSectionNameChange(sectionIndex, e.target.value)
              }
              className="w-full border border-gray-300 rounded p-2"
              placeholder="Starters"
            />
          </div>

          {section.items.map((item, itemIndex) => (
            <div
              key={itemIndex}
              className="mb-6 border-b border-gray-200 pb-6 last:border-b-0"
            >
              <h3 className="text-md font-medium mb-2">Item {itemIndex + 1}</h3>
              <div className="mb-4">
                <label className="block text-sm font-medium mb-1">
                  Item name
                </label>
                <input
                  type="text"
                  value={item.name}
                  onChange={(e) =>
                    handleItemNameChange(
                      sectionIndex,
                      itemIndex,
                      e.target.value
                    )
                  }
                  className="w-full border border-gray-300 rounded p-2"
                />
              </div>
              <div className="mb-4">
                <label className="block text-sm font-medium mb-1">
                  Food image
                </label>
                <div
                  className="border border-dashed border-gray-300 rounded p-4 text-center"
                  onDrop={(e) => handleImageDrop(e, sectionIndex, itemIndex)}
                  onDragOver={preventDefault}
                >
                  {item.image ? (
                    <p>&quot;{item.image.name}</p>
                  ) : (
                    <>
                      <div className="text-gray-500 mb-2">📷</div>
                      <p className="text-gray-500">Drag and drop food image</p>
                      <p className="text-gray-500">OR</p>
                      <label className="bg-orange-500 text-white px-4 py-2 rounded cursor-pointer inline-block">
                        Choose from Gallery
                        <input
                          type="file"
                          accept="image/*"
                          onChange={(e) =>
                            handleImageSelect(e, sectionIndex, itemIndex)
                          }
                          className="hidden"
                        />
                      </label>
                    </>
                  )}
                </div>
              </div>
              <div className="mb-4">
                <label className="block text-sm font-medium mb-1">
                  ETB Price
                </label>
                <input
                  type="text"
                  value={item.price}
                  onChange={(e) =>
                    handlePriceChange(sectionIndex, itemIndex, e.target.value)
                  }
                  className="w-full border border-gray-300 rounded p-2"
                />
              </div>
              <div className="mb-4">
                <label className="block text-sm font-medium mb-1">
                  Ingredients
                </label>
                {item.ingredients.map((ing, ingIndex) => (
                  <input
                    key={ingIndex}
                    type="text"
                    value={ing}
                    onChange={(e) =>
                      handleIngredientChange(
                        sectionIndex,
                        itemIndex,
                        ingIndex,
                        e.target.value
                      )
                    }
                    className="w-full border border-gray-300 rounded p-2 mb-2"
                    placeholder={`Ingredient ${ingIndex + 1}`}
                  />
                ))}
                <button
                  onClick={() => addIngredient(sectionIndex, itemIndex)}
                  className="text-orange-500 flex items-center"
                >
                  <span className="mr-1">⊕</span> Add Ingredient
                </button>
              </div>
              <div className="mb-4">
                <label className="block text-sm font-medium mb-1">
                  Description (max 100 chars)
                </label>
                <textarea
                  value={item.description}
                  onChange={(e) =>
                    handleDescriptionChange(
                      sectionIndex,
                      itemIndex,
                      e.target.value
                    )
                  }
                  maxLength={100}
                  className="w-full border border-gray-300 rounded p-2"
                  rows={3}
                />
              </div>
              <div className="mb-4">
                <label className="block text-sm font-medium mb-1">
                  How to eat
                </label>
                <textarea
                  value={item.instructions}
                  onChange={(e) =>
                    handleInstructionsChange(
                      sectionIndex,
                      itemIndex,
                      e.target.value
                    )
                  }
                  maxLength={100}
                  className="w-full border border-gray-300 rounded p-2"
                  rows={3}
                  placeholder="Instructions (max 100 chars)"
                />
              </div>
              <div className="mb-4">
                <label className="block text-sm font-medium mb-1">
                  Voice Explanation
                </label>
                <div
                  className="border border-dashed border-gray-300 rounded p-4 text-center"
                  onDrop={(e) => handleVoiceDrop(e, sectionIndex, itemIndex)}
                  onDragOver={preventDefault}
                >
                  {item.voice ? (
                    <p>{item.voice.name}</p>
                  ) : (
                    <>
                      <div className="text-gray-500 mb-2">☁️</div>
                      <p className="text-gray-500">
                        Drag and drop your file or click to browse
                      </p>
                      <p className="text-blue-500">mp3 up to 10MB</p>
                      <input
                        type="file"
                        accept=".mp3"
                        onChange={(e) =>
                          handleVoiceSelect(e, sectionIndex, itemIndex)
                        }
                        className="hidden"
                      />
                    </>
                  )}
                </div>
              </div>
            </div>
          ))}

          <button
            onClick={() => addItem(sectionIndex)}
            className="bg-orange-100 text-orange-500 px-4 py-2 rounded flex items-center"
          >
            <span className="mr-1">⊕</span> Add Item
          </button>
        </div>
      ))}

      <button
        onClick={addSection}
        className="bg-orange-500 text-white px-4 py-2 rounded flex items-center"
      >
        <span className="mr-1">⊕</span> Add Section
      </button>
    </div>
  );
};

export default ManualMenu;
