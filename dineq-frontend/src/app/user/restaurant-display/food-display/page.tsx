"use client";
import React from "react";
import FoodHeader from "@/components/user/FoodSection/FoodHeader";
import FoodMiniNavBar from "@/components/user/FoodSection/FoodMiniNavBar";

interface FoodItem {
  id: string;
  name: string;
  description: string;
  price: number;
  currency: string;
  how_to_eat: string;
  allergies: string[];
  nutritional_info: {
    calories: number;
    protein: number;
    carbs: number;
    fat: number;
  };
}

export default function FoodCard({ item }: { item: FoodItem }) {
  return (
    <div className="w-full max-w-[80%] flex flex-col gap-4">
      <FoodHeader
        image="/logo.png" // later replace with item.image if API provides it
        title={item.name}
        price={`${item.price} ${item.currency}`}
        onFavorite={() => alert(`Added ${item.name} to favorites!`)}
      />
      <FoodMiniNavBar  />
      {/* <FoodMiniNavBar item={item} /> */}
      
    </div>
  );
}
