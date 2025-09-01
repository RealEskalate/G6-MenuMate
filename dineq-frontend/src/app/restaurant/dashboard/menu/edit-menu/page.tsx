"use client";

import SectionEditor from "@/components/restaurant/menu/SectionEditor";

export default function MenuEditorPage() {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-semibold mb-6">Edit menu</h1>

      {/* Main Dishes Section */}
      <SectionEditor
        sectionName="Main Dishes"
        language="Amharic"
        categories={[
          {
            title: "Breakfast",
            items: [
              {
                id: "1",
                title: "Doro Wat",
                description: "Spicy chicken stew with berbere sauce, served with injera.",
                price: 350,
                image: "/images/doro_wat.jpg",
              },
              {
                id: "2",
                title: "Tibs",
                description: "Sour flatbread served with sautéed meat and vegetables.",
                price: 350,
                image: "/images/tibs.jpg",
              },
              {
                id: "3",
                title: "Gomen",
                description: "Collard greens cooked with garlic, ginger, and spices.",
                price: 350,
                image: "/images/gomen.jpg",
              },
            ],
          },
          {
            title: "Lunch",
            items: [
              {
                id: "4",
                title: "Kitfo",
                description: "Minced beef tartare with spices and clarified butter.",
                price: 350,
                image: "/images/kitfo.jpg",
              },
              {
                id: "5",
                title: "Shiro",
                description: "Ground chickpea stew with Ethiopian spices and herbs.",
                price: 350,
                image: "/images/shiro.jpg",
              },
            ],
          },
        ]}
      />

      {/* Appetizers Section */}
      <SectionEditor
        sectionName="Appetizers"
        categories={[
          {
            title: "",
            items: [
              {
                id: "6",
                title: "Kolo",
                description:
                  "Roasted barley and chickpeas with spices. Traditional Ethiopian snack.",
                price: 80,
                image: "/images/kolo.jpg",
              },
              {
                id: "7",
                title: "Dabo Kolo",
                description:
                  "Small pieces of bread seasoned with spices. Perfect appetizer or snack.",
                price: 80,
                image: "/images/dabo_kolo.jpg",
              },
            ],
          },
        ]}
      />

      {/* Beverages Section */}
      <SectionEditor
        sectionName="Beverages"
        categories={[
          {
            title: "",
            items: [
              {
                id: "8",
                title: "Ethiopian Coffee",
                description:
                  "Traditional Ethiopian coffee served in a traditional ceremony. Rich and aromatic.",
                price: 30,
                image: "/images/coffee.jpg",
              },
              {
                id: "9",
                title: "Tej",
                description:
                  "Traditional Ethiopian honey wine. Sweet and refreshing alcoholic beverage.",
                price: 120,
                image: "/images/tej.jpg",
              },
            ],
          },
        ]}
      />
    </div>
  );
}
