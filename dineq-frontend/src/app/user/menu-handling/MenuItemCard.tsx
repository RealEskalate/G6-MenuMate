// src/app/user/menu-handling/MenuItemCard.tsx
"use client";

import React from "react";
import Image from "next/image";
import { MenuItem } from "./menuApi";

interface MenuItemCardProps {
  item: MenuItem;
  onClick: () => void;
  id : string;
}

export default function MenuItemCard({ item, onClick , id }: MenuItemCardProps) {
  const imageUrl = item.image && item.image.length > 0 ? item.image[0] : "/sambusa.png";

  return (
    <div
      onClick={onClick}
      className="bg-white rounded-2xl shadow-lg overflow-hidden cursor-pointer  border-[var(--color-primary)]
                 hover:shadow-2xl transform hover:-translate-y-1 transition-all duration-300"
    >
      <div className="relative w-full h-48">
        <Image
          src={imageUrl}
          alt={item.name}
          fill
          objectFit="cover"
          className="rounded-t-2xl"
        />
      </div>
      <div className="p-4">
        <h4 className="text-xl font-semibold text-gray-900 mb-1 truncate">{item.name}</h4>
        <p className="text-sm text-gray-500 mb-3 line-clamp-2">{item.description}</p>
        <div className="flex items-center justify-between mt-2">
          <p className="text-lg font-bold text-[var(--color-primary)]">
            {item.price} {item.currency ?? "ETB"}
          </p>
          {item.average_rating > 0 && (
            <div className="flex items-center text-yellow-500">
              <span className="text-base mr-1">⭐</span>
              <span className="font-semibold">{item.average_rating.toFixed(1)}</span>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}