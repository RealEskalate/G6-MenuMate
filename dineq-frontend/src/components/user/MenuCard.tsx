"use client";

import React from "react";
import { Menu } from "@/store/menuSlice";
// import SafeImage from "@/components/common/SafeImage";

interface MenuCardProps {
  menu: Menu;
  onMenuClick?: (menu: Menu) => void;
}

const MenuCard: React.FC<MenuCardProps> = ({ menu, onMenuClick }) => {
  return (
    <div 
      className="border border-[var(--color-primary)] rounded-lg cursor-pointer hover:shadow-sm transition-shadow duration-200"
      onClick={() => onMenuClick?.(menu)}
    >
      <div className="relative flex flex-col p-4">
        {/* Menu Header */}
        <div className="flex items-center justify-between mb-3">
          <h3 className="text-lg font-semibold text-gray-800">{menu.name}</h3>
          {menu.is_active && (
            <span className="px-2 py-1 text-xs bg-green-100 text-green-800 rounded-full">
              Active
            </span>
          )}
        </div>

        {/* Menu Description */}
        {menu.description && (
          <p className="text-sm text-gray-600 mb-3 line-clamp-2">
            {menu.description}
          </p>
        )}

        {/* Menu Items Count */}
        <div className="flex items-center justify-between text-sm text-gray-500">
          <span>{menu.items?.length || 0} items</span>
          <span className="text-xs">
            {new Date(menu.created_at).toLocaleDateString()}
          </span>
        </div>
      </div>
    </div>
  );
};

export default MenuCard;
