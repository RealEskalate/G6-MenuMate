"use client";

import Image from "next/image";
import Link from "next/link";
import { Trash2 } from "lucide-react";
import { useQrCode } from "@/hooks/useQrCode";
import { Menu } from "@/Types/menu";

interface MenuCardProps {
  menu: Menu;
  token: string;
  restaurantSlug: string;
}

export default function MenuCard({ menu, token, restaurantSlug }: MenuCardProps) {
  const { data: qrImageUrl, isLoading: loadingQr, isError } =
    useQrCode(restaurantSlug, token);

  return (
    <div className="relative w-full md:w-96 bg-white text-black rounded-xl border border-orange-400 p-4 shadow-md">
      {/* Status + Delete */}
      <div className="flex justify-between mb-2">
        <span className="font-bold text-xl">{menu.name}</span>
        <div className="flex space-x-4">
          <span className="bg-orange-100 text-orange-600 text-sm px-3 py-1 rounded-lg flex items-center gap-1">
            <span className="w-2 h-2 bg-orange-500 rounded-full"></span>
            {menu.is_published ? "Published" : "Draft"}
          </span>
          <button className="text-red-500 hover:text-red-700">
            <Trash2 size={18} />
          </button>
        </div>
      </div>

      <div className="text-gray-800 text-[12px]">
        Created {new Date(menu.created_at).toDateString()} - Updated{" "}
        {new Date(menu.updated_at).toDateString()}
      </div>

      {/* Items + QR */}
      <div className="flex justify-between mt-6">
        <div className="space-y-2">
          <div className="py-3 px-5 border border-orange-400 rounded-md">
            <div className="text-[16px] text-gray-600">Items</div>
            <div className="font-normal">{menu.items.length} Dishes</div>
          </div>
          <div className="py-3 px-5 border border-orange-400 rounded-md">
            <div className="text-[16px] text-gray-600">Avg rating</div>
            <div className="font-medium">4.3</div>
          </div>
        </div>

        {/* ✅ QR image here */}
        <div className="flex flex-col items-center justify-center">
          {loadingQr ? (
            <span className="text-sm text-gray-400">Loading QR...</span>
          ) : isError || !qrImageUrl ? (
            <span className="text-sm text-red-500">QR unavailable</span>
          ) : (
            <Image
              src={qrImageUrl}
              alt={`${menu.name} QR`}
              width={110}
              height={110}
              className="pt-2"
            />
          )}
        </div>
      </div>

      {/* Buttons */}
      <div className="flex justify-between mt-6">
        <button className="border border-[#FD7E14] bg-white text-[#FD7E14] px-4 py-2 rounded-md hover:bg-gray-100 font-semibold">
          Manage QR
        </button>
        <Link href={`/restaurant/dashboard/menu/${menu.id}`}>
          <button className="bg-[#FD7E14] text-white px-4 py-2 rounded-md hover:bg-orange-600 flex items-center gap-1">
            <Image
              src="/icons/edit.png"
              alt="Edit Icon"
              width={16}
              height={16}
            />
            Edit Menu
          </button>
        </Link>
      </div>
    </div>
  );
}
