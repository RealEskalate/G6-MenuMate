"use client";

import React, { useState } from "react";
import { Plus, Trash2, Pencil } from "lucide-react";
import MenuOptionModal from "@/components/restaurant/MenuOptionModal";
import Image from "next/image";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useSession } from "next-auth/react";
import { useMenus } from "@/hooks/useMenu";
import { useRestaurant } from "@/hooks/useRestaurant"
import MenuCardSkeleton from "@/components/restaurant/skeletons/MenuEditorSkeleton";
import { useQrCode } from "@/hooks/useQrCode";
import MenuCard from "@/components/restaurant/menu/MenuCard";


export default function Dashboard() {
  const { data: session } = useSession();
  const token = session?.accessToken;
  const router = useRouter();
  const [isModalOpen, setIsModalOpen] = useState(false);

  // Get restaurant data
  const { data: restaurantData, isLoading: isLoadingRestaurant } =
    useRestaurant(token);

  const restaurantSlug = restaurantData?.slug;
  console.log(restaurantSlug, restaurantData)

  // Get all menus
  const { data: menus, isLoading: isLoadingMenus } = useMenus(
    restaurantSlug ?? "",
    token
  );
  console.log("menus:", menus)

  const { data: qrImageUrl } = useQrCode(restaurantSlug!, token!);

  
  if (isLoadingRestaurant || isLoadingMenus) {
  return (
    <div className="flex flex-col md:flex-row gap-6 p-6">
      {[...Array(1)].map((_, i) => (
        <MenuCardSkeleton key={i} />
      ))}
    </div>
  );
}


  return (
    <div>
      <div className="flex">
        <main className="flex-1 px-6">
          {/* Header */}
          <div className="flex justify-between items-center mb-6 bg-white p-4 rounded-2xl shadow-[0_4px_12px_#ffead4]">
            <div className="font-bold text-2xl">Menus</div>
            <button
              onClick={() => setIsModalOpen(true)}
              className="bg-[#FD7E14] text-white px-6 flex py-2 rounded"
            >
              <Plus size={16} />
              Add Menu
            </button>
          </div>

          {/* Menu cards */}
          <div className="flex flex-col md:flex-row gap-6">
          {menus && menus.length > 0 ? (
            menus.map((menu) => (
              <MenuCard
                key={menu.id}
                menu={menu}
                token={token!}
                restaurantSlug={restaurantSlug!}
              />
            ))
          ) : (
            <div className="w-full text-center bg-white border border-dashed border-orange-300 rounded-xl p-8 shadow-sm">
              <p className="text-gray-600 text-lg font-medium mb-2">
                There is no published menu
              </p>
              <p className="text-gray-500 mb-4">
                Scan with OCR or add manually to publish your menu
              </p>
            </div>
          )}
        </div>

        </main>
      </div>

      {/* Popup Modal */}
      <MenuOptionModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
      />
    </div>
  );
}
