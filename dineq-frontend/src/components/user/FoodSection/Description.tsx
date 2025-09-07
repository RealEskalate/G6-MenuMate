// src/components/user/FoodSection/Description.tsx
"use client";

import React, { useState } from "react";
import Tags from "@/components/common/Tags";
import { MenuItem } from "@/store/menuSlice";

const NutrientCard = ({ label, value, unit }: { label: string; value: number; unit: string }) => (
  <div className="flex flex-col items-center justify-center p-3 rounded-xl border border-gray-200 bg-gray-50">
    <p className="text-2xl font-bold text-gray-800">{value}</p>
    <p className="text-sm text-gray-500 font-medium mt-1">{label} ({unit})</p>
  </div>
);

const Description = ({ item }: { item: MenuItem }) => {
  const [isAmharic, setIsAmharic] = useState(false);

  const displayDescription = isAmharic && item.description_am ? item.description_am : item.description;

  return (
    <div className="bg-white rounded-xl shadow-sm p-6 mb-3">
      {/* Description Section */}
      <div className="flex flex-col mb-6">
        <div className="flex items-center justify-between mb-2">
          <h2 className="text-2xl font-semibold text-gray-800">About this Dish</h2>
          {item.description_am && (
            <button
              onClick={() => setIsAmharic(!isAmharic)}
              className="px-3 py-1 rounded-full text-sm font-medium transition-colors duration-200"
            >
              <Tags className="bg-orange-100 text-orange-600 font-medium">
                {isAmharic ? "Switch to English" : "ወደ አማርኛ ይቀይሩ"}
              </Tags>
            </button>
          )}
        </div>
        <p className="text-gray-700 leading-relaxed">{displayDescription}</p>
      </div>

      {/* Nutritional Info Section */}
      {item.nutritional_info && (
        <div className="flex flex-col mb-6">
          <h2 className="text-2xl font-semibold mb-3 text-gray-800">Nutritional Information</h2>
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
            <NutrientCard label="Calories" value={item.nutritional_info.calories} unit="kcal" />
            <NutrientCard label="Protein" value={item.nutritional_info.protein} unit="g" />
            <NutrientCard label="Carbs" value={item.nutritional_info.carbs} unit="g" />
            <NutrientCard label="Fat" value={item.nutritional_info.fat} unit="g" />
          </div>
        </div>
      )}

      {/* Categories Section */}
      <div className="flex flex-col">
        <h2 className="text-2xl font-semibold mb-3 text-gray-800">Categories</h2>
        <div className="flex flex-wrap gap-2">
          {(item.tab_tags || []).map((tag, index) => (
            <Tags key={index} className="bg-orange-100 text-orange-600 font-medium">
              {tag}
            </Tags>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Description;