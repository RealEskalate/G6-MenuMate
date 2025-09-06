"use client";

import React, { useEffect, useState } from "react";
import { useSession } from "next-auth/react";
import { getMenusByRestaurantSlug, getMenuById, Menu } from "./menuApi";
import MenuItemCard from "./MenuItemCard";

interface MenuSectionProps {
  restaurantSlug: string;
}

const MenuSection: React.FC<MenuSectionProps> = ({ restaurantSlug }) => {
  const { data: session, status } = useSession();

  const [menus, setMenus] = useState<Menu[]>([]);
  const [selectedMenu, setSelectedMenu] = useState<Menu | null>(null);
  const [selectedMenuId, setSelectedMenuId] = useState<string | null>(null);

  const [loadingMenus, setLoadingMenus] = useState(false);
  const [loadingMenuDetails, setLoadingMenuDetails] = useState(false);
  const [errorMenus, setErrorMenus] = useState<string | null>(null);
  const [errorMenuDetails, setErrorMenuDetails] = useState<string | null>(null);

  // Fetch menus
  useEffect(() => {
    const fetchMenus = async () => {
      if (!restaurantSlug || status !== "authenticated" || !session?.accessToken) return;

      setLoadingMenus(true);
      setErrorMenus(null);

      try {
        const menusData = await getMenusByRestaurantSlug(restaurantSlug, session.accessToken);
        setMenus(menusData); // ✅ now directly Menu[]
      } catch (err: any) {
        setErrorMenus(err.message || "Failed to fetch menus");
      } finally {
        setLoadingMenus(false);
      }
    };

    fetchMenus();
  }, [restaurantSlug, session?.accessToken, status]);

  // Fetch selected menu
  useEffect(() => {
    const fetchMenuDetails = async () => {
      if (!selectedMenuId || status !== "authenticated" || !session?.accessToken) return;

      setLoadingMenuDetails(true);
      setErrorMenuDetails(null);

      try {
        const menuData = await getMenuById(selectedMenuId, session.accessToken);
        setSelectedMenu(menuData); // ✅ now directly Menu
      } catch (err: any) {
        setErrorMenuDetails(err.message || "Failed to fetch menu details");
      } finally {
        setLoadingMenuDetails(false);
      }
    };

    fetchMenuDetails();
  }, [selectedMenuId, session?.accessToken, status]);

  if (status === "unauthenticated") {
    return <p className="text-center p-4">Please log in to view menus.</p>;
  }

  if (loadingMenus) {
    return <p className="text-center p-4">Loading menus...</p>;
  }

  if (errorMenus) {
    return <p className="text-red-600 text-center p-4">{errorMenus}</p>;
  }

  if (!menus) {
    return <p className="text-center p-4">No menus available for this restaurant.</p>;
  }

  return (
    <div className="w-full max-w-5xl mx-auto">
      <h2 className="text-2xl font-bold mb-4">Menus</h2>

      {/* Menu List */}
      <div className="flex flex-wrap gap-4 mb-6">
        {menus.map((menu) => (
          <button
            key={menu.id}
            className={`px-4 py-2 rounded-lg ${
              selectedMenuId === menu.id
                ? "bg-[var(--color-primary)] text-white"
                : "bg-gray-100"
            }`}
            onClick={() => setSelectedMenuId(menu.id)}
          >
            {menu.name}
          </button>
        ))}
      </div>

      {/* Menu Details */}
      {loadingMenuDetails && <p className="p-4">Loading menu details...</p>}
      {errorMenuDetails && <p className="text-red-600 p-4">{errorMenuDetails}</p>}
      {selectedMenu && (
        <div className="space-y-6">
          {selectedMenu.categories.map((category) => (
            <div key={category.name}>
              <h3 className="text-lg font-semibold mb-2">{category.name}</h3>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                {category.items.map((item) => (
                  <MenuItemCard key={item.id} item={item} />
                ))}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default MenuSection;
