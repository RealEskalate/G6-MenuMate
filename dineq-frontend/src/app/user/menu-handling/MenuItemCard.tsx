"use client";

import React from "react";
import { MenuItem } from "./menuApi"; // ✅ use from menuApi
import SafeImage from "@/components/common/SafeImage";

interface MenuItemCardProps {
  item: MenuItem;
}

const MenuItemCard: React.FC<MenuItemCardProps> = ({ item }) => {
  return (
    <div className="border border-[var(--color-primary)] rounded-lg hover:shadow-sm transition-shadow duration-200">
      <div className="flex p-3">
        {/* Image */}
        <div className="relative w-20 h-20 md:w-24 md:h-24 rounded-lg overflow-hidden flex-shrink-0">
          <SafeImage
            src={item.image || "/Background.png"}
            alt={item.name}
            fill
            style={{ objectFit: "cover" }}
            className="rounded-lg"
          />
        </div>

        {/* Info */}
        <div className="flex-1 ml-3 flex flex-col justify-between">
          <div>
            <div className="flex items-start justify-between">
              <h4 className="text-sm md:text-base font-semibold text-gray-800 line-clamp-1">
                {item.name}
              </h4>
              <span className="text-sm md:text-base font-bold text-[var(--color-primary)] ml-2">
                ${item.price}
              </span>
            </div>

            {item.description && (
              <p className="text-xs md:text-sm text-gray-600 mt-1 line-clamp-2">
                {item.description}
              </p>
            )}
          </div>

          {/* Tags */}
          <div className="flex flex-wrap items-center gap-2 mt-2">
            {(item.allergens?.length ?? 0) > 0 && (
              <span className="px-2 py-1 text-xs bg-red-100 text-red-800 rounded-full">
                {item.allergens?.join(", ")}
              </span>
            )}
            {(item.dietary_info?.length ?? 0) > 0 && (
              <span className="px-2 py-1 text-xs bg-green-100 text-green-800 rounded-full">
                {item.dietary_info?.join(", ")}
              </span>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default MenuItemCard;
