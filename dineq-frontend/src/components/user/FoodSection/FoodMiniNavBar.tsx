// src/components/user/FoodSection/FoodMiniNavBar.tsx
"use client";

import { useState } from "react";
// import Description from "./Description";
import FoodTip from "./HowToEat";
import Review from "./Review";
import ReviewForm from "./WriteReview";
import { MenuItem } from "@/app/user/menu-handling/menuApi";
import Description from "./Description";
interface FoodMiniNavBarProps {
  item: MenuItem;
  id : string | null;
}
export default function FoodMiniNavBar({ item , id }: FoodMiniNavBarProps) {
  const [activeTab, setActiveTab] = useState<
    "description" | "howtoeat" | "reviews" | "writeReview"
  >("description");

  const tabs = [
    { key: "description", label: "Description" },
    { key: "howtoeat", label: "How to Eat" },
    { key: "reviews", label: "Reviews" },
    { key: "writeReview", label: "Write a Review" },
  ];

  return (
    <div className="mt-8">
      {/* Navbar Tabs */}
      <div className="flex gap-6 border-b-2 border-gray-200">
        {tabs.map((tab) => (
          <button
            key={tab.key}
            className={`pb-3 capitalize font-semibold transition-colors duration-200 ${
              activeTab === tab.key
                ? "text-orange-600 border-b-2 border-orange-600"
                : "text-gray-500 hover:text-orange-500"
            }`}
            onClick={() => setActiveTab(tab.key as "description" | "howtoeat" | "reviews" | "writeReview")}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {/* Tab Content */}
      <div className="mt-6">
        {activeTab === "description" && <Description item={item} />}
        {activeTab === "howtoeat" && <FoodTip item={item} />}
        {activeTab === "reviews" && <Review id = {id} />}
        {activeTab === "writeReview" && <ReviewForm id = {id}  />}
      </div>
    </div>
  );
}