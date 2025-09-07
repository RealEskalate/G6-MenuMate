"use client";

import React from "react";
import { Menu } from "./menuApi";

interface MenuCardProps {
  menu: Menu;
  onMenuClick?: (menu: Menu) => void;
}

const MenuCard: React.FC<MenuCardProps> = ({ menu, onMenuClick }) => {
  return (
    <div
      className="flex w-[535.25px] h-[110.86px] border border-[var(--color-primary)] rounded-lg cursor-pointer hover:shadow-lg hover:-translate-y-1 transform transition-all duration-200 p-[10px]"
      onClick={() => onMenuClick?.(menu)}
    >
      {/* Info Section */}
      <div className="flex flex-col justify-between flex-1 ml-[10px]">
        {/* Title and Status */}
        <div className="flex justify-between items-start">
          <h3 className="text-[20px] font-semibold leading-[23.35px] text-gray-800">
            {menu.name}
          </h3>
          <span
            className={`text-xs font-medium ${
              menu.is_published ? "text-green-600" : "text-red-600"
            }`}
          >
            {menu.is_published ? "Published" : "Unpublished"}
          </span>
        </div>

        {/* Slug or Additional Info */}
        <p className="text-xs text-gray-500 mt-2 line-clamp-1">Slug: {menu.slug}</p>
      </div>

      {/* Optional Right Side Preview (like image placeholder) */}
      <div className="w-[152.43px] h-[97px] bg-gray-100 rounded-lg flex-shrink-0 ml-[10px]" />
    </div>
  );
};

export default MenuCard;
