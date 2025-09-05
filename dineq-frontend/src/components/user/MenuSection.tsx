"use client";

import React, { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { useSession } from "next-auth/react";
import { AppDispatch, RootState } from "@/store/store";
import { 
  fetchMenusByRestaurantSlug,
  fetchMenuItemsByMenuSlug,
  clearMenuItems,
  Menu
} from "@/store/menuSlice";
import MenuCard from "./MenuCard";
import MenuItemCard from "./MenuItemCard";

interface MenuSectionProps {
  restaurantSlug: string;
}

const MenuSection: React.FC<MenuSectionProps> = ({ restaurantSlug }) => {
  const dispatch = useDispatch<AppDispatch>();
  const { data: session, status } = useSession();
  const { menus, currentMenuItems, loading, itemsLoading, error, itemsError } = useSelector(
    (state: RootState) => state.menu
  );
  
  const [selectedMenu, setSelectedMenu] = useState<Menu | null>(null);

  // Fetch menus when component mounts and session is ready
  useEffect(() => {
    if (restaurantSlug && session?.accessToken && status === "authenticated") {
      dispatch(fetchMenusByRestaurantSlug({ 
        restaurantSlug, 
        accessToken: session.accessToken 
      }));
    }
  }, [dispatch, restaurantSlug, session?.accessToken, status]);

  // Fetch menu items when a menu is selected
  useEffect(() => {
    if (selectedMenu?.slug && session?.accessToken && status === "authenticated") {
      dispatch(fetchMenuItemsByMenuSlug({ 
        menuSlug: selectedMenu.slug, 
        accessToken: session.accessToken 
      }));
    } else {
      dispatch(clearMenuItems());
    }
  }, [dispatch, selectedMenu, session?.accessToken, status]);

  const handleMenuClick = (menu: Menu) => setSelectedMenu(menu);

  // Render loading placeholders
  if (status === "loading" || loading) {
    return (
      <div className="w-full max-w-5xl animate-pulse">
        <div className="h-8 bg-gray-200 rounded w-1/4 mb-4"></div>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {[1, 2, 3].map(i => (
            <div key={i} className="h-32 bg-gray-200 rounded-lg"></div>
          ))}
        </div>
      </div>
    );
  }

  // Not authenticated
  if (status === "unauthenticated") {
    return (
      <div className="w-full max-w-5xl text-center p-8">
        <p className="text-gray-500">Please log in to view restaurant menus.</p>
      </div>
    );
  }

  // Error fetching menus
  if (error) {
    return (
      <div className="w-full max-w-5xl text-center p-8">
        <p className="text-red-600 mb-4">Error loading menus: {error}</p>
        <button
          onClick={() => session?.accessToken && dispatch(fetchMenusByRestaurantSlug({ restaurantSlug, accessToken: session.accessToken }))}
          className="px-4 py-2 bg-[var(--color-primary)] text-white rounded-lg hover:opacity-90 transition-opacity"
        >
          Try Again
        </button>
      </div>
    );
  }

  if (menus.length === 0) {
    return (
      <div className="w-full max-w-5xl text-center p-8">
        <p className="text-gray-500">No menus available for this restaurant.</p>
      </div>
    );
  }

  return (
    <div className="w-full max-w-5xl">
      <h2 className="text-2xl font-bold mb-6">Menu</h2>

      {/* Menu selection */}
      <div className="mb-6">
        <h3 className="text-lg font-semibold mb-3">Select a Menu</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {menus.map(menu => (
            <MenuCard key={menu.id} menu={menu} onMenuClick={handleMenuClick} />
          ))}
        </div>
      </div>

      {/* Menu items */}
      {selectedMenu && (
        <div className="mt-8">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold">{selectedMenu.name} - Menu Items</h3>
            <button
              onClick={() => setSelectedMenu(null)}
              className="text-sm text-gray-500 hover:text-gray-700"
            >
              Close Menu
            </button>
          </div>

          {itemsLoading ? (
            <div className="animate-pulse space-y-4">
              {[1, 2, 3].map(i => (
                <div key={i} className="h-24 bg-gray-200 rounded-lg"></div>
              ))}
            </div>
          ) : itemsError ? (
            <div className="text-center p-4">
              <p className="text-red-600 mb-2">Error loading menu items: {itemsError}</p>
              <button
                onClick={() => selectedMenu.slug && session?.accessToken && dispatch(fetchMenuItemsByMenuSlug({ menuSlug: selectedMenu.slug, accessToken: session.accessToken }))}
                className="px-3 py-1 bg-[var(--color-primary)] text-white rounded text-sm hover:opacity-90 transition-opacity"
              >
                Try Again
              </button>
            </div>
          ) : currentMenuItems.length === 0 ? (
            <div className="text-center p-4">
              <p className="text-gray-500">No items available in this menu.</p>
            </div>
          ) : (
            <div className="space-y-3">
              {currentMenuItems.map(item => (
                <MenuItemCard key={item.id} item={item} />
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default MenuSection;
