"use client";

import { useParams, useRouter } from "next/navigation";
import DishEditForm from "@/components/restaurant/menu/dish/DishEditForm";
import { menuData } from "../../data/menu";
import { ArrowLeft } from "lucide-react"; // or use a simple text button

export default function EditDishPage() {
  const { id } = useParams();
  const router = useRouter();
  const dish = menuData.find((item) => item.id === id);

  if (!dish) return <div>Dish not found</div>;

  return (
    <div className="p-6">
      <button
        onClick={() => router.back()}
        className="flex items-center text-gray-600 hover:text-gray-800 mb-4"
      >
        <ArrowLeft className="w-4 h-4 mr-2" />
        Back
      </button>
      
      <h1 className="text-2xl font-semibold mb-6">Edit dish</h1>
      <DishEditForm dish={dish} />
    </div>
  );
}