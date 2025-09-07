// src/app/user/menu-handling/MenuSection.tsx
"use client";

import React, { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { getMenusByRestaurantSlug, Menu, MenuItem } from "./menuApi";
import MenuItemCard from "./MenuItemCard";

interface MenuSectionProps {
  restaurantSlug: string;
  token?: string;
  id : string;
}

export default function MenuSection({ restaurantSlug, token , id}: MenuSectionProps) {
  const router = useRouter();
  const [menus, setMenus] = useState<Menu[]>([]);
  const [selectedMenu, setSelectedMenu] = useState<Menu | null>(null);
  const [items, setItems] = useState<MenuItem[]>([]);
  const [loadingMenus, setLoadingMenus] = useState(true);
  const [loadingItems, setLoadingItems] = useState(false);

  useEffect(() => {
    async function fetchMenus() {
      try {
        setLoadingMenus(true);
        const menusData = await getMenusByRestaurantSlug(restaurantSlug, token);
        setMenus(menusData);
        if (menusData.length > 0) {
          setSelectedMenu(menusData[0]);
        }
      } catch (err) {
        console.error("Failed to load menus:", err);
      } finally {
        setLoadingMenus(false);
      }
    }
    fetchMenus();
  }, [restaurantSlug, token]);

  const handleItemClick = (item: MenuItem) => {
    const encodedItem = encodeURIComponent(JSON.stringify(item));
    // Add the restaurantSlug as a new query parameter
    router.push(`/user/restaurant-display/food-display?item=${encodedItem}&restaurantSlug=${restaurantSlug}`);
  };
  return (
    <section className="mt-8">
      <h2 className="text-3xl font-bold mb-6 text-gray-800">Explore Our Menus</h2>

      {/* Menus Tabs */}
      {loadingMenus ? (
        <p className="text-gray-500">Loading menus...</p>
      ) : menus.length === 0 ? (
        <p className="text-gray-500">No menus available for this restaurant.</p>
      ) : (
        <div className="flex gap-4 mb-8 overflow-x-auto pb-2">
          {menus.map((menu) => (
            <button
              key={menu.id}
              onClick={() => setSelectedMenu(menu)}
              className={`flex-shrink-0 px-6 py-3 rounded-full font-medium transition-all duration-300 transform ${
                selectedMenu?.id === menu.id
                  ? "bg-[var(--color-primary)] text-white shadow-lg scale-105"
                  : "bg-gray-100 text-gray-700 hover:bg-gray-200"
              }`}
            >
              {menu.name}
            </button>
          ))}
        </div>
      )}

      {/* Items for selected menu */}
      {selectedMenu && (
        <div className="bg-white p-6 rounded-2xl shadow-xl">
          <h3 className="text-2xl font-semibold mb-6 text-gray-800 border-b-2 border-gray-200 pb-2">
            {selectedMenu.name}
          </h3>
          {loadingItems ? (
            <p className="text-gray-500">Loading items...</p>
          ) : selectedMenu.items.length === 0 ? (
            <p className="text-gray-500">No items found for this menu.</p>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
              {selectedMenu.items.map((item) => (
                <MenuItemCard key={item.id} id = {id} item={item} onClick={() => handleItemClick(item)} />
              ))}
            </div>
          )}
        </div>
      )}
    </section>
  );
}