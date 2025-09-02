"use client";

import { useState } from "react";
import { Pencil } from "lucide-react";
import SectionDetailsForm from "../../../app/restaurant/dashboard/menu/edit-menu/SectionDetailsForm";
import MenuCategory from "../../../app/restaurant/dashboard/menu/edit-menu/MenuCategory";

interface MenuItem {
  id: string;
  title: string;
  description: string;
  price: number;
  image: string;
}

interface Category {
  title?: string;
  items: MenuItem[];
}

export default function SectionEditor({
  sectionName,
  language,
  categories,
}: {
  sectionName: string;
  language?: string;
  categories: Category[];
}) {
  const [isEditing, setIsEditing] = useState(false);

  return (
    <div className="mb-10 border rounded-lg p-4">
      {/* Section Header */}
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-lg font-semibold">{sectionName}</h2>
        <Pencil
          className="w-5 h-5 text-gray-500 cursor-pointer hover:text-gray-700"
          onClick={() => setIsEditing((prev) => !prev)}
        />
      </div>

      {/* Toggleable Details Form */}
      {language && isEditing && (
        <div className="mb-6 transition-all duration-300 ease-in-out">
          <SectionDetailsForm sectionName={sectionName} language={language} />
        </div>
      )}

      {/* Categories */}
      <div className="space-y-6">
        {categories.map((cat, idx) => (
          <MenuCategory key={idx} title={cat.title} items={cat.items} />
        ))}
      </div>
    </div>
  );
}
