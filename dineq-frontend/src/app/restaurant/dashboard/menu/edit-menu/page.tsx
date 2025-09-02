"use client";

import SectionEditor from "@/components/restaurant/menu/SectionEditor";
import { menuData, MenuItem } from "../data/menu";
import { useRouter } from "next/navigation";
import { ArrowLeft } from "lucide-react";

export default function MenuEditorPage() {
  const router = useRouter();

  // group by section
  const sections = menuData.reduce<Record<string, MenuItem[]>>((acc, dish) => {
    if (!acc[dish.section]) acc[dish.section] = [];
    acc[dish.section].push(dish);
    return acc;
  }, {});

  return (
    <div className="p-6">
      <button
        onClick={() => router.back()}
        className="flex items-center text-gray-600 hover:text-gray-800 mb-4"
      >
        <ArrowLeft className="w-4 h-4 mr-2" />
        Back
      </button>
      <h1 className="text-2xl font-semibold mb-6">Edit menu</h1>

      {Object.entries(sections).map(([sectionName, items]) => {
        // group items into categories
        const categories = items.reduce<Record<string, MenuItem[]>>(
          (acc, dish) => {
            const cat = dish.category || "Uncategorized";
            if (!acc[cat]) acc[cat] = [];
            acc[cat].push(dish);
            return acc;
          },
          {}
        );

        return (
          <SectionEditor
            key={sectionName}
            sectionName={sectionName}
            language={items[0]?.language ?? "Unknown"}
            categories={Object.entries(categories).map(([title, catItems]) => ({
              title,
              items: catItems,
            }))}
          />
        );
      })}
    </div>
  );
}
