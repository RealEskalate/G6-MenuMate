"use client";

import React from "react";
import { Menu } from "./menuApi"; // ✅ import Menu type from menuApi

interface MenuCardProps {
  menu: Menu; // full Menu type from API
  onMenuClick?: (menu: Menu) => void;
}

const MenuCard: React.FC<MenuCardProps> = ({ menu, onMenuClick }) => {
  // Calculate number of items safely
  const totalItems =
    menu.categories?.reduce(
      (acc, cat) => acc + (cat.items?.length || 0),
      0
    ) || 0;

  return (
    <div
      className="border border-[var(--color-primary)] rounded-lg cursor-pointer hover:shadow-sm transition-shadow duration-200 p-4"
      onClick={() => onMenuClick?.(menu)}
    >
      <div className="flex flex-col">
        {/* Menu Title */}
        <h3 className="text-lg font-semibold text-gray-800 mb-2">
          {menu.name}
        </h3>

        {/* Number of Items */}
        <p className="text-sm text-gray-600 mb-2">{totalItems} items</p>

        {/* Categories Preview */}
        {menu.categories && menu.categories.length > 0 && (
          <div className="text-sm text-gray-500">
            Categories: {menu.categories.map((c) => c.name).join(", ")}
          </div>
        )}
      </div>
    </div>
  );
};

export default MenuCard;
