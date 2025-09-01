"use client";
import { useState } from "react";
<<<<<<< HEAD
=======
import Description from "./Description";
import FoodTip from "./HowToEat";
import ReviewForm from "./WriteReview";
>>>>>>> origin/frontend-main

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
<<<<<<< HEAD
=======
  const howToEatData = {
    steps: [
      "Place a piece of injera on your plate as the base",
      "Scoop a small portion of Doro Wat onto the injera",
      "Use your right hand to tear off a piece of injera",
      "Wrap the injera around the chicken and sauce",
      "Eat the wrapped portion in one bite",
      "Continue until you’ve finished your portion",
      "Don’t forget to enjoy the hard-boiled egg that comes with the dish",
    ],
    tip: "Tip: Ethiopian cuisine is traditionally eaten with hands, but utensils are available if preferred.",
  };

  const chefTipData = {
    chefName: "Chef Abebe",
    message:
      "The key to perfect Doro Wat is in the berbere spice blend. We make our own berbere using dried red chilies, garlic, ginger, and 15 other spices. The chicken should be cooked slowly until it’s tender and the sauce has thickened. Always serve with fresh injera and don’t forget the hard-boiled egg – it’s not just decoration, it’s part of the traditional presentation.",
    audioUrl: "", // can add an mp3 path later e.g. "/audio/chef-tip.mp3"
  };
>>>>>>> origin/frontend-main

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
<<<<<<< HEAD
            onClick={() => setActiveTab(tab.key as any)}
=======
            onClick={() => setActiveTab(tab.key as "description" | "howtoeat" | "reviews" | "writeReview")}
>>>>>>> origin/frontend-main
          >
            {tab.label}
          </button>
        ))}
      </div>

      {/* Tab Content */}
      <div className="mt-4">
        {activeTab === "description" && (
<<<<<<< HEAD
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
=======
          <Description/>
        )}

        {activeTab === "howtoeat" && (
          <FoodTip howToEat={howToEatData} chefTip={chefTipData} />
>>>>>>> origin/frontend-main
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
<<<<<<< HEAD
          <div>
            <textarea
              className="w-full p-2 border rounded-lg"
              placeholder="Write your review..."
            ></textarea>
            <button className="mt-2 bg-orange-500 text-white px-4 py-2 rounded-lg hover:bg-orange-600">
              Submit Review
            </button>
          </div>
=======
          <ReviewForm />
>>>>>>> origin/frontend-main
        )}
      </div>
    </div>
  );
}
