"use client";

import { useMenu, useMenus } from "@/hooks/useMenu";
import { ArrowLeft } from "lucide-react";
import { MenuItem } from "@/Types/menu";
import { useRouter, useParams } from "next/navigation";
import { useSession } from "next-auth/react";
import { useRestaurant } from "@/hooks/useRestaurant";
import MenuItemCard from "../../../../user/menu-handling/MenuItemCard"
import BackButton from "@/components/common/BackButton";

export default function MenuEditorPage() {
  const { data: session } = useSession();
  const token = session?.accessToken;
  const router = useRouter();
  const params = useParams<{ menuSlug: string }>();
  const menuSlugParam = params?.menuSlug;

  const {
    data: restaurantData,
    isLoading: isLoadingRestaurant,
    error: errorRestaurant,
  } = useRestaurant(token);

  const restaurantSlug = restaurantData?.slug;

  const {
    data: menus,
    isLoading: isLoadingMenus,
    error: errorMenus,
  } = useMenus(restaurantSlug!, token);

  const selectedMenu =
    menus?.find((m) => m.slug === menuSlugParam) ?? menus?.[0];
  const menuId = selectedMenu?.id;
  const menuSlug = selectedMenu?.slug;

  const {
    data: menu,
    isLoading: isLoadingMenu,
    error: errorMenu,
  } = useMenu(restaurantSlug!, menuId, token);

  if (isLoadingRestaurant || isLoadingMenus || isLoadingMenu)
    return <div>Loading menu...</div>;

  if (
    errorRestaurant ||
    errorMenus ||
    errorMenu ||
    !restaurantSlug ||
    !menu?.items
  ) {
    return <div>Failed to load menu</div>;
  }

  // Group items by section
  const sections = menu.items.reduce<Record<string, MenuItem[]>>(
    (acc, dish) => {
      const sectionName = dish.tab_tags?.[0] || "Default";
      if (!acc[sectionName]) acc[sectionName] = [];
      acc[sectionName].push(dish);
      return acc;
    },
    {}
  );

  return (
    <div className="p-6">
      <div className="flex items-center justify-between mb-6">
      <h1 className="text-2xl font-semibold">Edit Menu</h1>
      <BackButton />
    </div>


      {Object.entries(sections).map(([sectionName, items]) => (
        <div key={sectionName} className="mb-8">
          <h2 className="text-xl font-semibold mb-4">{sectionName}</h2>
          <div className="space-y-4">
            {items.map((item) => (
              <div
                key={item.id}
                className="relative cursor-pointer group"
                onClick={() =>
                  menuSlug &&
                  router.push(`/restaurant/dashboard/menu/${menuSlug}/${item.id}`)
                }
              >
                {/* <MenuItemCard item={{
                  ...item,
                  allergies:
                    typeof item.allergies === "string" ? [item.allergies] : item.allergies,
                }} /> */}

                {/* Optional Pencil Icon on Hover */}
                <div className="absolute bottom-3 right-3 opacity-0 group-hover:opacity-100 transition-opacity">
                  ✏️
                </div>
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}
