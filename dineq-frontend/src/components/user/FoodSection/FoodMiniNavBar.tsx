"use client";
import { useState } from "react";

export default function FoodDetails() {
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
    <div className="mt-6">
      {/* Navbar Tabs */}
      <div className="flex gap-6 border-b">
        {tabs.map((tab) => (
          <button
            key={tab.key}
            className={`pb-2 capitalize transition ${
              activeTab === tab.key
                ? "text-orange-600 border-b-2 border-orange-600"
                : "text-gray-500 hover:text-orange-500"
            }`}
            onClick={() => setActiveTab(tab.key as any)}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {/* Tab Content */}
      <div className="mt-4">
        {activeTab === "description" && (
          <p className="text-gray-700">
            Traditional Ethiopian chicken stew simmered with berbere spices and
            served with injera.
          </p>
        )}

        {activeTab === "howtoeat" && (
          <p className="text-gray-700">
            Tear a piece of injera, scoop the doro wat and egg, and enjoy. It’s
            usually shared in a communal style meal.
          </p>
        )}

        {activeTab === "reviews" && (
          <div className="space-y-4">
            <div className="space-y-2">
              <p className="font-semibold">Selamawit ⭐⭐⭐⭐</p>
              <p className="text-gray-600">
                The spice was just right! Reminded me of home.
              </p>
            </div>
            <div className="space-y-2">
              <p className="font-semibold">Mikias ⭐⭐⭐⭐⭐</p>
              <p className="text-gray-600">
                Best doro wat I’ve had in a long time!
              </p>
            </div>
          </div>
        )}

        {activeTab === "writeReview" && (
          <div>
            <textarea
              className="w-full p-2 border rounded-lg"
              placeholder="Write your review..."
            ></textarea>
            <button className="mt-2 bg-orange-500 text-white px-4 py-2 rounded-lg hover:bg-orange-600">
              Submit Review
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
