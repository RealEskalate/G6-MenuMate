"use client";

import { useState } from "react";
import IngredientTag from "./IngredientTag";
import FileUpload from "./FileUpload";
import Image from "next/image";
import { Trash2 } from "lucide-react";

interface Dish {
  section: string;
  title: string;
  price: number | string;
  ingredients: string[];
  description?: string;
  howToEat?: string;
  image?: string; // dish image
}

export default function DishEditForm({ dish }: { dish: Dish }) {
  const [form, setForm] = useState(dish);
  const [preview, setPreview] = useState(dish.image || ""); // preview for uploaded image

  // Handle image selection
  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0];
      const reader = new FileReader();
      reader.onloadend = () => {
        setPreview(reader.result as string);
        setForm({ ...form, image: reader.result as string });
      };
      reader.readAsDataURL(file);
    }
  };

  // Handle image delete
  const handleDeleteImage = () => {
    setPreview("");
    setForm({ ...form, image: "" });
  };

  return (
    <div className="border rounded-lg p-6">
      <h2 className="text-lg font-semibold mb-4">Section 1</h2>

      {/* Responsive layout for inputs + image */}
      <div className="flex flex-col md:flex-row gap-6">
        <div className="flex-1">
          {/* Section name */}
          <label className="block text-sm mb-1">Section name</label>
          <input
            type="text"
            value={form.section}
            onChange={(e) => setForm({ ...form, section: e.target.value })}
            className="w-full border rounded px-3 py-2 mb-4"
          />

          {/* Dish name */}
          <label className="block text-sm mb-1">Item</label>
          <input
            type="text"
            value={form.title}
            onChange={(e) => setForm({ ...form, title: e.target.value })}
            className="w-full border rounded px-3 py-2 mb-4"
          />

          {/* Price */}
          <label className="block text-sm mb-1">Price (ETB)</label>
          <input
            type="number"
            value={form.price}
            onChange={(e) => setForm({ ...form, price: e.target.value })}
            className="w-full border rounded px-3 py-2 mb-4"
          />
        </div>

        {/* Image upload + preview */}
          <div className="flex flex-col items-center md:w-1/3">
            {preview ? (
              <div className="relative w-full h-48 md:h-36 border rounded-lg overflow-hidden">
                <Image
                  src={preview}
                  alt="Dish preview"
                  fill
                  className="object-cover"
                />
                {/* Delete icon */}
                <button
                  onClick={handleDeleteImage}
                  className="absolute top-2 right-2 bg-white rounded-full p-1 shadow hover:bg-gray-100"
                >
                  <Trash2 className="w-4 h-4 text-red-500" />
                </button>
              </div>
            ) : (
              <label className="w-full h-48 md:h-36 border-2 border-dashed rounded-lg flex items-center justify-center text-gray-400 cursor-pointer hover:border-orange-400">
                <span className="text-sm">Upload image</span>
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleImageChange}
                  className="hidden"
                />
              </label>
            )}
          </div>

      </div>

      {/* Ingredients */}
      <label className="block text-sm mb-2 mt-4">Ingredients</label>
      <div className="flex flex-wrap gap-2 mb-4">
        {form.ingredients.map((ing: string, i: number) => (
          <IngredientTag
            key={i}
            label={ing}
            onRemove={() =>
              setForm({
                ...form,
                ingredients: form.ingredients.filter(
                  (_: string, idx: number) => idx !== i
                ),
              })
            }
          />
        ))}
      </div>
      <button className="px-3 py-1 text-sm border rounded">
        + Add ingredient
      </button>

      {/* Description */}
      <label className="block text-sm mb-1 mt-4">Description</label>
      <textarea
        value={form.description}
        onChange={(e) => setForm({ ...form, description: e.target.value })}
        className="w-full border rounded px-3 py-2 h-24"
      />

      {/* How to eat */}
      <label className="block text-sm mb-1 mt-4">How to eat</label>
      <input
        type="text"
        maxLength={100}
        value={form.howToEat}
        onChange={(e) => setForm({ ...form, howToEat: e.target.value })}
        className="w-full border rounded px-3 py-2"
      />

      {/* Voice upload */}
      <label className="block text-sm mb-1 mt-4">Voice Explanation</label>
      <FileUpload />

      {/* Save */}
      <button className="mt-6 bg-orange-500 text-white px-4 py-2 rounded">
        Save changes
      </button>
    </div>
  );
}
