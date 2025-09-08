"use client";

import { useState } from "react";
import { MenuItem, NutritionalInfo } from "@/Types/menu";
import { useUpdateMenuItem } from "@/hooks/useMenu";
import FileUpload from "./FileUpload";
import Image from "next/image";
import { Trash2 } from "lucide-react";



export default function DishEditForm({
  dish,
  menuSlug,
  token,
}: {
  dish: MenuItem;
  menuSlug: string;
  token?: string;
}) {
  const [form, setForm] = useState<MenuItem>(dish);
  function handleChange(field: 'nutritional_info', value: NutritionalInfo): void;
  function handleChange(
  field: Exclude<keyof MenuItem, 'nutritional_info'>,
  value: string | number | string[] | boolean | null | undefined
): void;

function handleChange(
  field: keyof MenuItem,
  value: NutritionalInfo | string | number | string[] | boolean | null | undefined
) {
  setForm((prev) => ({
    ...prev,
    [field]: value as MenuItem[typeof field],
  }));
}
  const [preview, setPreview] = useState(form.image_url || "");
  const mutation = useUpdateMenuItem(menuSlug, token!);




  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0];
      const reader = new FileReader();
      reader.onloadend = () => {
        setPreview(reader.result as string);
        setForm((prev) => ({ ...prev, image_url: reader.result as string }));
      };
      reader.readAsDataURL(file);
    }
  };

  const handleDeleteImage = () => {
    setPreview("");
    setForm((prev) => ({ ...prev, image: "" }));
  };

  const handleSave = () => {
    mutation.mutate(
      {
        id: form.id,
        data: {
          name: form.name,
          name_am: form.name_am,
          description: form.description,
          description_am: form.description_am,
          price: form.price,
          currency: form.currency,
          allergies: form.allergies,
          allergies_am: form.allergies_am,
          tab_tags: Array.isArray(form.tab_tags) ? form.tab_tags : [form.tab_tags],
          tab_tags_am: Array.isArray(form.tab_tags_am) ? form.tab_tags_am : [form.tab_tags_am],
          nutritional_info: form.nutritional_info,
          preparation_time: form.preparation_time,
          how_to_eat: form.how_to_eat,
          how_to_eat_am: form.how_to_eat_am,
          image_url: form.image_url
        },
      },
      {
        onSuccess: () => alert("Dish updated successfully"),
        onError: (err: unknown) => {
          const message = err instanceof Error ? err.message : String(err);
          alert("Error: " + message);
        },
      }
    );
  };

  return (
    <div className="border rounded-lg p-6 space-y-4">
      {/* Section */}
      {/* Responsive layout for inputs + image */}
      <div className="flex flex-col md:flex-row gap-6">
        <div className="flex-1 space-y-4">
          {/* Name */}
          <div>
            <label className="block text-sm font-medium">Name (English)</label>
            <input
              type="text"
              value={form.name}
              onChange={(e) => handleChange("name", e.target.value)}
              className="w-full border rounded px-3 py-2"
            />
          </div>

          {/* Name Amharic */}
          <div>
            <label className="block text-sm font-medium">Name (Amharic)</label>
            <input
              type="text"
              value={form.name_am || ""}
              onChange={(e) => handleChange("name_am", e.target.value)}
              className="w-full border rounded px-3 py-2"
            />
          </div>

          {/* Description */}
          <div>
            <label className="block text-sm font-medium">Description</label>
            <textarea
              value={form.description}
              onChange={(e) => handleChange("description", e.target.value)}
              className="w-full border rounded px-3 py-2"
            />
          </div>

          {/* Description Amharic */}
          <div>
            <label className="block text-sm font-medium">
              Description (Amharic)
            </label>
            <textarea
              value={form.description_am || ""}
              onChange={(e) => handleChange("description_am", e.target.value)}
              className="w-full border rounded px-3 py-2"
            />
          </div>

          {/* Price */}
          <div>
            <label className="block text-sm font-medium">Price</label>
            <input
              type="number"
              value={form.price}
              onChange={(e) => handleChange("price", Number(e.target.value))}
              className="w-full border rounded px-3 py-2"
            />
          </div>

          {/* Currency */}
          <div>
            <label className="block text-sm font-medium">Currency</label>
            <input
              type="text"
              value={form.currency}
              onChange={(e) => handleChange("currency", e.target.value)}
              className="w-full border rounded px-3 py-2"
            />
          </div>
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

      {/* Allergies */}
      <div>
        <label className="block text-sm font-medium">Allergies</label>
        <input
          type="text"
          value={form.allergies || ""}
          onChange={(e) => handleChange("allergies", e.target.value)}
          className="w-full border rounded px-3 py-2"
        />
      </div>

      {/* Allergies Amharic */}
      <div>
        <label className="block text-sm font-medium">Allergies (Amharic)</label>
        <input
          type="text"
          value={form.allergies_am || ""}
          onChange={(e) => handleChange("allergies_am", e.target.value)}
          className="w-full border rounded px-3 py-2"
        />
      </div>

      {/* Tab tags */}
      <div>
        <label className="block text-sm font-medium">Tags</label>
        <input
          type="text"
          value={form.tab_tags || ""}
          onChange={(e) => handleChange("tab_tags", e.target.value)}
          className="w-full border rounded px-3 py-2"
        />
      </div>

      {/* Tab tags Amharic */}
      <div>
        <label className="block text-sm font-medium">Tags (Amharic)</label>
        <input
          type="text"
          value={form.tab_tags_am || ""}
          onChange={(e) => handleChange("tab_tags_am", e.target.value)}
          className="w-full border rounded px-3 py-2"
        />
      </div>

      {/* Nutritional Info */}
      <div>
  <label className="block text-sm font-medium mb-2">Nutritional Info</label>
  <div className="grid grid-cols-2 gap-4">
    <div>
      <label className="block text-xs text-gray-600">Calories</label>
      <input
        type="number"
        value={form.nutritional_info?.calories ?? ""}
        onChange={(e) =>
          handleChange("nutritional_info", {
            ...form.nutritional_info ?? {},
            calories: Number(e.target.value),
          })
        }
        className="w-full border rounded px-3 py-2"
      />
    </div>
    <div>
      <label className="block text-xs text-gray-600">Protein (g)</label>
      <input
        type="number"
        value={form.nutritional_info?.protein ?? ""}
        onChange={(e) =>
          handleChange("nutritional_info", {
            ...form.nutritional_info ?? {},
            protein: Number(e.target.value),
          })
        }
        className="w-full border rounded px-3 py-2"
      />
    </div>
    <div>
      <label className="block text-xs text-gray-600">Carbs (g)</label>
      <input
        type="number"
        value={form.nutritional_info?.carbs ?? ""}
        onChange={(e) =>
          handleChange("nutritional_info", {
            ...form.nutritional_info ?? {},
            carbs: Number(e.target.value),
          })
        }
        className="w-full border rounded px-3 py-2"
      />
    </div>
    <div>
      <label className="block text-xs text-gray-600">Fat (g)</label>
      <input
        type="number"
        value={form.nutritional_info?.fat ?? ""}
        onChange={(e) =>
          handleChange("nutritional_info", {
            ...form.nutritional_info ?? {},
            fat: Number(e.target.value),
          })
        }
        className="w-full border rounded px-3 py-2"
      />
    </div>
  </div>
</div>



      {/* Preparation Time */}
      <div>
        <label className="block text-sm font-medium">Preparation Time</label>
        <input
          type="text"
          value={form.preparation_time || ""}
          onChange={(e) => handleChange("preparation_time", e.target.value)}
          className="w-full border rounded px-3 py-2"
        />
      </div>

      {/* How to Eat */}
      <div>
        <label className="block text-sm font-medium">How to Eat</label>
        <input
          type="text"
          value={form.how_to_eat}
          onChange={(e) => handleChange("how_to_eat", e.target.value)}
          className="w-full border rounded px-3 py-2"
        />
      </div>

      {/* How to Eat Amharic */}
      <div>
        <label className="block text-sm font-medium">How to Eat (Amharic)</label>
        <input
          type="text"
          value={form.how_to_eat_am || ""}
          onChange={(e) => handleChange("how_to_eat_am", e.target.value)}
          className="w-full border rounded px-3 py-2"
        />
      </div>

      {/* Voice upload */}
      <div>
        <label className="block text-sm mb-1">Voice Explanation</label>
        <FileUpload />
      </div>

      {/* Save */}
      <button
        onClick={handleSave}
        className="bg-orange-500 text-white px-4 py-2 rounded"
        disabled={mutation.isPending}
      >
        {mutation.isPending ? "Saving..." : "Save changes"}
      </button>
    </div>
  );
}
