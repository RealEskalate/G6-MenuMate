"use client";

import { useParams, useRouter } from "next/navigation";
import { useMenuItem } from "@/hooks/useMenu"; 
import DishEditForm from "@/components/restaurant/menu/dish/DishEditForm";
import { ArrowLeft } from "lucide-react";
import { useSession } from "next-auth/react";

export default function EditDishPage() {
  const { menuSlug, id } = useParams<{ menuSlug: string; id: string }>();
  const router = useRouter();
  const {data: session} = useSession();
  const token = session?.accessToken;

  const { data, isLoading, error } = useMenuItem(menuSlug, id);

  if (isLoading) return <div>Loading...</div>;
  if (error || !data) return <div>Dish not found</div>;

  return (
    <div className="p-6">
      <button
        onClick={() => router.back()}
        className="flex items-center text-gray-600 hover:text-gray-800 mb-4"
      >
        <ArrowLeft className="w-4 h-4 mr-2" />
        Back
      </button>

      <h1 className="text-2xl font-semibold mb-6">Edit Dish</h1>
      <DishEditForm dish={data} menuSlug={menuSlug} token={token} />
    </div>
  );
}
