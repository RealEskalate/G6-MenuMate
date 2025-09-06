"use client";

import { useMenu, useMenus } from "@/hooks/useMenu";
import { ArrowLeft, Pencil } from "lucide-react";
import { MenuItem } from "@/Types/menu";
import { useRouter, useParams } from "next/navigation";
import { useSession } from "next-auth/react";
import { useRestaurant } from "@/hooks/useRestaurant";

export default function MenuEditorPage() {
  const { data: session } = useSession();
  const token = session?.accessToken;
  const router = useRouter();
  const params = useParams<{ menuSlug: string }>();
  const menuSlugParam = params?.menuSlug;

  // Get restaurant data
  const {
    data: restaurantData,
    isLoading: isLoadingRestaurant,
    error: errorRestaurant,
  } = useRestaurant(token);

  const restaurantSlug = restaurantData.slug;

  // Get all menus for this restaurant
  const {
    data: menus,
    isLoading: isLoadingMenus,
    error: errorMenus,
  } = useMenus(restaurantSlug!, token);

  // Select menu based on URL param, fallback to first menu
  const selectedMenu =
    menus?.find((m) => m.slug === menuSlugParam) ?? menus?.[0];
  const menuId = selectedMenu?.id;
  const menuSlug = selectedMenu?.slug;

  // Get full menu data
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
      <button
        onClick={() => router.back()}
        className="flex items-center text-gray-600 hover:text-gray-800 mb-4"
      >
        <ArrowLeft className="w-4 h-4 mr-2" />
        Back
      </button>

      <h1 className="text-2xl font-semibold mb-6">Edit Menu</h1>

      {Object.entries(sections).map(([sectionName, items]) => (
        <div key={sectionName} className="mb-8">
          <h2 className="text-xl font-semibold mb-4">{sectionName}</h2>
          <div className="space-y-4">
            {items.map((item) => (
              <div
                key={item.id}
                className="relative border rounded-lg p-3 bg-white flex items-start"
              >
                {item.image_url && (
                  <img
                    src={item.image_url}
                    alt={item.name}
                    className="w-20 h-20 rounded-md object-cover"
                  />
                )}
                <div className="ml-3 flex-1">
                  <h5 className="font-medium">{item.name}</h5>
                  <p className="text-sm text-gray-600">{item.description}</p>
                  <p className="text-orange-500 font-semibold mt-1">
                    {item.currency} {item.price}
                  </p>
                </div>
                <Pencil
                  className="w-4 h-4 text-gray-500 absolute top-2 right-2 cursor-pointer"
                  onClick={() =>
                    menuSlug && router.push(`/restaurant/dashboard/menu/${menuSlug}/${item.id}`)
                  }
                />
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}
