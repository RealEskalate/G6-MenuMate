// src/app/user/food-display/page.tsx
"use client";

import React, { useEffect, useState } from "react";
import { useSearchParams } from "next/navigation";
import FoodHeader from "@/components/user/FoodSection/FoodHeader";
import FoodMiniNavBar from "@/components/user/FoodSection/FoodMiniNavBar";
import { MenuItem } from "@/app/user/menu-handling/menuApi";

export default function FoodDisplay() {
  const searchParams = useSearchParams();
  const [item, setItem] = useState<MenuItem | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [restaurantSlug, setRestaurantSlug] = useState<string | null>(null);

  useEffect(() => {
    const itemData = searchParams.get("item");
    const slugData = searchParams.get("restaurantSlug");
    if (itemData) {
      try {
        const parsedItem: MenuItem = JSON.parse(decodeURIComponent(itemData));
        setRestaurantSlug(slugData);
        setItem(parsedItem);
      } catch (e) {
        console.error("Failed to parse menu item data:", e);
        setError("Invalid food item data. Please go back and try again.");
      }
    } else {
      setError("No food item selected. Please select an item from the menu.");
    }
  }, [searchParams]);

  if (error) {
    return (
      <div className="flex justify-center p-8 text-red-600 font-medium">
        {error}
      </div>
    );
  }

  if (!item) {
    return (
      <div className="flex justify-center p-8 text-gray-500">
        Loading food item details...
      </div>
    );
  }
  const imageUrl = item.image && item.image.length > 0 ? item.image[0] : "/sambusa.png";
  return (
    <div className="w-full max-w-5xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
      <FoodHeader
        image={imageUrl} // Replace with item.image_url if available
        title={item.name}
        price={`${item.price} ${item.currency}`}
        rating={item.average_rating}
        isFavorite={false}
        onFavorite={() => alert(`Toggling favorite for ${item.name}`)}
      />
      <FoodMiniNavBar item={item} id = {restaurantSlug}/>
    </div>
  );
}