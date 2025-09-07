"use client";
import { useState } from "react";
// import Description from "./Description";
import FoodTip from "./HowToEat";
import ReviewForm from "./WriteReview";
import Review from "./Review";

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
    audioUrl: "", 
  };

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
            onClick={() => setActiveTab(tab.key as "description" | "howtoeat" | "reviews" | "writeReview")}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {/* Tab Content */}
      <div className="mt-4">
        {activeTab === "description" && (
          <Description/>
        )}

        {activeTab === "howtoeat" && (
          <FoodTip howToEat={howToEatData} chefTip={chefTipData} />
        )}

        {activeTab === "reviews" && (
          <Review/>
        )}

        {activeTab === "writeReview" && (
          <ReviewForm />
        )}
      </div>
    </div>
  );  
}
// "use client";
// import { useState } from "react";
// import Description from "./Description";
// import FoodTip from "./HowToEat";
// import ReviewForm from "./WriteReview";
// import Review from "./Review";

// interface FoodItem {
//   description: string;
//   how_to_eat: string;
//   allergies: string[];
//   nutritional_info: {
//     calories: number;
//     protein: number;
//     carbs: number;
//     fat: number;
//   };
// }

// export default function FoodDetails({ item }: { item: FoodItem }) {
//   const [activeTab, setActiveTab] = useState<
//     "description" | "howtoeat" | "reviews" | "writeReview"
//   >("description");

//   const tabs = [
//     { key: "description", label: "Description" },
//     { key: "howtoeat", label: "How to Eat" },
//     { key: "reviews", label: "Reviews" },
//     { key: "writeReview", label: "Write a Review" },
//   ];

//   return (
//     <div className="mt-6">
//       {/* Tabs */}
//       <div className="flex gap-6 border-b">
//         {tabs.map((tab) => (
//           <button
//             key={tab.key}
//             className={`pb-2 capitalize transition ${
//               activeTab === tab.key
//                 ? "text-orange-600 border-b-2 border-orange-600"
//                 : "text-gray-500 hover:text-orange-500"
//             }`}
//             onClick={() => setActiveTab(tab.key as any)}
//           >
//             {tab.label}
//           </button>
//         ))}
//       </div>

//       {/* Tab Content */}
//       <div className="mt-4">
//         {activeTab === "description" && (
//           <Description description={item.description} allergies={item.allergies} />
//         )}
//         {activeTab === "howtoeat" && (
//           <FoodTip howToEat={item.how_to_eat} nutritional={item.nutritional_info} />
//         )}
//         {activeTab === "reviews" && <Review />}
//         {activeTab === "writeReview" && <ReviewForm />}
//       </div>
//     </div>
//   );
// }
