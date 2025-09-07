// src/components/user/FoodSection/HowToEat.tsx
"use client";

import React, { useState } from "react";
import { MenuItem } from "@/app/user/menu-handling/menuApi";
import { AlertCircle } from "lucide-react";
import Tags from "@/components/common/Tags";

const FoodTip = ({ item }: { item: MenuItem }) => {
  const [isAmharic, setIsAmharic] = useState(false);

  const displayHowToEat = isAmharic && item.how_to_eat_am ? item.how_to_eat_am : item.how_to_eat;
  const displayAllergies = isAmharic && item.allergies_am ? item.allergies_am : item.allergies;

  return (
    <div className="bg-white rounded-xl shadow-sm p-6">
      {/* How to Eat Section */}
      <div className="mb-6">
        <div className="flex items-center justify-between mb-2">
          <h2 className="text-2xl font-semibold text-gray-800">
            How to Eat {item.name}
          </h2>
          {item.how_to_eat_am && (
            <button
              onClick={() => setIsAmharic(!isAmharic)}
              className="px-3 py-1 rounded-full text-sm font-medium transition-colors duration-200"
            >
              <Tags color="orange" >
                {isAmharic ? "Switch to English" : "ወደ አማርኛ ይቀይሩ"}
              </Tags>
            </button>
          )}
        </div>
        <p className="text-gray-700 leading-relaxed">
          {displayHowToEat ?? "Instructions not available for this item."}
        </p>
      </div>

      {/* Allergies Notice */}
      {Array.isArray(displayAllergies) && displayAllergies.length > 0 && (
        <div className="mt-4 p-4 rounded-lg bg-red-50 border border-red-200 flex items-start gap-3">
          <AlertCircle className="w-6 h-6 text-red-500 flex-shrink-0 mt-1" />
          <div className="flex-1">
            <h3 className="font-semibold text-red-800 text-lg">Allergen Notice</h3>
            <ul className="text-red-700 mt-1 list-disc list-inside">
              {displayAllergies.map((allergy, index) => (
                <li key={index} className="text-sm">{allergy}</li>
              ))}
            </ul>
          </div>
        </div>
      )}
      
      {/* Chef's Voice Tip Section (remains a placeholder)
      <div className="mt-6">
        <h2 className="text-2xl font-semibold mb-3 text-gray-800">Chef&apos;s Voice Tip</h2>
        <div className=" p-4 rounded-lg border border-orange-200">
          <p className="font-semibold ">Chef Abebe says:</p>
          <p className=" mt-2 italic leading-relaxed">
            The key to perfect Doro Wat is in the berbere spice blend. We make our own berbere using dried red chilies, garlic, ginger, and 15 other spices. The chicken should be cooked slowly until it’s tender and the sauce has thickened. Always serve with fresh injera and don’t forget the hard-boiled egg – it’s not just decoration, it’s part of the traditional presentation.
          </p>
        </div> 
      </div>
      */}
    </div>
  );
};

export default FoodTip;