"use client";

import { useParams } from "next/navigation";
import DishEditForm from "@/components/restaurant/menu/dish/DishEditForm";

// Mock data for now
const dishes = {
  "1": {
    id: "1",
    section: "Breakfast",
    name: "Shiro",
    price: 100,
    ingredients: ["Berbere Spice", "Onions", "Chickpea", "Garlic", "Injera"],
    description: "Ground chickpea stew with Ethiopian spices and herbs.",
    howToEat: "",
    image: "/images/shiro.jpg",
  },
};

export default function EditDishPage() {
  const { id } = useParams();
  const dish = dishes[id as keyof typeof dishes];

  if (!dish) return <div>Dish not found</div>;

  return (
    <div className="p-6">
      <h1 className="text-2xl font-semibold mb-6">Edit dish</h1>
      <DishEditForm dish={dish} />
    </div>
  );
}
