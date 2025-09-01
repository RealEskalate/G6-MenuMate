"use client";

import { useState } from "react";
import IngredientTag from "./IngredientTag";
import FileUpload from "./FileUpload";

export default function DishEditForm({ dish }: { dish: any }) {
  const [form, setForm] = useState(dish);

  return (
    <div className="border rounded-lg p-6">
      <h2 className="text-lg font-semibold mb-4">Section 1</h2>

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
        value={form.name}
        onChange={(e) => setForm({ ...form, name: e.target.value })}
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

      {/* Ingredients */}
      <label className="block text-sm mb-2">Ingredients</label>
      <div className="flex flex-wrap gap-2 mb-4">
        {form.ingredients.map((ing: string, i: number) => (
          <IngredientTag
            key={i}
            label={ing}
            onRemove={() =>
              setForm({ ...form, ingredients: form.ingredients.filter((_:string, idx:number) => idx !== i) })
            }
          />
        ))}
      </div>
      <button className="px-3 py-1 text-sm border rounded">+ Add ingredient</button>

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
