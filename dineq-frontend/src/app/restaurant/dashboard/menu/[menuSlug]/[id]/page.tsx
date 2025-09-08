"use client";

import { useParams, useRouter } from "next/navigation";
import { useMenuItem } from "@/hooks/useMenu"; 
import DishEditForm from "@/components/restaurant/menu/dish/DishEditForm";
import { ArrowLeft } from "lucide-react";
import { useSession } from "next-auth/react";
import BackButton from "@/components/common/BackButton";

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
      <div className="flex items-center justify-between mb-6">
      <h1 className="text-2xl font-semibold">Edit Dish</h1>
      <BackButton />
    </div>

      <DishEditForm dish={data} menuSlug={menuSlug} token={token} />
    </div>
  );
}
