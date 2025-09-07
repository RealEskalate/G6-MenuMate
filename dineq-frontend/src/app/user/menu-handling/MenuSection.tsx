"use client";

import React, { useEffect, useState } from "react";
import { getMenusByRestaurantSlug, getMenuItemsBySlug, Menu, MenuItem } from "./menuApi";
import MenuItemCard from "./MenuItemCard";

interface MenuSectionProps {
  restaurantSlug: string;
  token?: string;
}

export default function MenuSection({ restaurantSlug, token }: MenuSectionProps) {
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

  // fetch items whenever selectedMenu changes
  useEffect(() => {
    if (!selectedMenu) return;

    async function fetchItems() {
      try {
        setLoadingItems(true);
        if (!selectedMenu) return;
        const itemsData = await getMenuItemsBySlug(selectedMenu.slug, token);
        setItems(itemsData);
      } catch (err) {
        console.error("Failed to load items:", err);
        setItems([]);
      } finally {
        setLoadingItems(false);
      }
    }

    fetchItems();
  }, [selectedMenu, token]);

  return (
    <section className="mt-8">
      <h2 className="text-2xl font-bold mb-4">Menus</h2>

      {/* Menus tabs */}
      {loadingMenus ? (
        <p>Loading menus...</p>
      ) : menus.length === 0 ? (
        <p>No menus available for this restaurant.</p>
      ) : (
        <div className="flex gap-3 mb-6 flex-wrap">
          {menus.map((menu) => (
            <button
              key={menu.id}
              onClick={() => setSelectedMenu(menu)}
              className={`px-4 py-2 rounded-lg border ${
                selectedMenu?.id === menu.id
                  ? "bg-[var(--color-primary)] text-white border-[var(--color-primary)]"
                  : "bg-[var(--color-primary)] text-gray-700 border-[var(--color-primary)]"
              }`}
            >
              {menu.name}
            </button>
          ))}
        </div>
      )}

      {/* Items for selected menu */}
      {selectedMenu && (
        <div>
          <h3 className="text-xl font-semibold mb-4">{selectedMenu.name}</h3>
          {loadingItems ? (
            <p>Loading items...</p>
          ) : selectedMenu.items.length === 0 ? (
            <p>No items found for this menu.</p>
          ) : (
            <div className="flex flex-wrap justify-center gap-6">
              {selectedMenu.items.map((item) => (
                <MenuItemCard key={item.id} item={item} />
              ))}
            </div>

          )}
        </div>
      )}
    </section>
  );
}
