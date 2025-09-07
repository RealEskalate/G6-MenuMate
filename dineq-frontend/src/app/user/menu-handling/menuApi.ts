// components/user/menu-handeling/menuApi.ts

const BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL || "https://dineq.onrender.com/api/v1";

export interface MenuItem {
  id: string;
  name: string;
  description?: string;
  price: number;
  currency?: string;
  image?: string;
  allergies?:string[];
  dietary_info?: string[];
}

export interface MenuCategory {
  name: string;
  items: MenuItem[];
}

export interface Menu {
  id: string;
  restaurant_id: string;
  restaurant_slug?: string;
  name: string;
  description?: string;
  categories: MenuCategory[];
}

/** Fetch all menus for a restaurant */
export async function getMenusByRestaurantSlug(
  restaurantSlug: string,
  token: string
): Promise<Menu[]> {
  const res = await fetch(`${BASE_URL}/menus/${restaurantSlug}`, {
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    cache: "no-store",
  });

  if (!res.ok) {
    if (res.status === 404) return []; // No menus for this restaurant
    throw new Error(`Failed to fetch menus: ${res.statusText}`);
  }

  const data = await res.json();
  return data.data?.menu || [];
}

/** Fetch single menu by restaurant slug + menu ID */
export async function getMenuByRestaurantAndId(
  restaurantSlug: string,
  menuId: string,
  token: string
): Promise<Menu> {
  const res = await fetch(`${BASE_URL}/menus/${restaurantSlug}/${menuId}`, {
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    cache: "no-store",
  });

  if (!res.ok) {
    if (res.status === 404) throw new Error("No menus available for this restaurant");
    if (res.status === 403) throw new Error("Not authorized to view this menu");
    throw new Error(`Failed to fetch menu: ${res.statusText}`);
  }

  const data = await res.json();
  return data.data as Menu;
}
