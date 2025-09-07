"use client";

import { useParams } from "next/navigation";
import { useMenus } from "@/hooks/useMenu";
import { Menu, MenuItem } from "@/Types/menu";
import MenuItemCard from "@/components/user/MenuItemCard"; // adjust path

function extractNameFromSlug(slugOrName: string) {
  const parts = slugOrName.split(/[-\s]/);
  const lastPart = parts[parts.length - 1];
  if (/^[0-9a-f]{8,}$/.test(lastPart)) {
    parts.pop();
  }
  
  return parts
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join(" ");
}

export default function MenuPage() {
  const params = useParams<{ restaurantSlug: string }>();
  const restaurantSlug = params.restaurantSlug;

  const { data: menus, isLoading, isError, error } = useMenus(restaurantSlug);

  if (isLoading) return <p className="p-6">Loading menus...</p>;
  if (isError) return <p className="p-6 text-red-600">Error: {(error as Error).message}</p>;
  if (!menus || menus.length === 0) return <p className="p-6">No menus available.</p>;

  return (
    <div className="p-6 space-y-8 max-w-5xl mx-auto">
      <h1 className="text-3xl font-bold capitalize">
        {extractNameFromSlug(restaurantSlug)} Menu
      </h1>

      {menus.map((menu: Menu) => (
        <div key={menu.id} className="space-y-4">
          <h2 className="text-2xl font-semibold">
            {extractNameFromSlug(menu.name)}
          </h2>

          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            {menu.items.map((item: MenuItem) => (
              <MenuItemCard key={item.id} item={item} />
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}
