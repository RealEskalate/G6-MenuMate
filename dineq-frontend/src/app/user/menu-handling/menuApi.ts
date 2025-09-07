// src/api/menuApi.ts
export const BASE_URL = "https://dineq.onrender.com/api/v1";

/** Menu item shape */
export interface MenuItem {
  id: string;
  name: string;
  description?: string;
  price: number;
  currency?: string;
  image?: string;
  allergies?: string[];
  tab_tags?: string[];
}

/** Menu shape (without items at first) */
export interface Menu {
  id: string;
  name: string;
  restaurant_id: string;
  slug: string;
  is_published: boolean;
  view_count?: number;
  average_rating?: number;
}

/** Fetch all menus for a restaurant by slug */
export async function getMenusByRestaurantSlug(
  restaurantSlug: string,
  token?: string
): Promise<Menu[]> {
  const res = await fetch(`${BASE_URL}/menus/${restaurantSlug}`, {
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    cache: "no-store",
  });

  if (!res.ok) {
    if (res.status === 404) return [];
    throw new Error(`Failed to fetch menus: ${res.statusText}`);
  }

  const data = await res.json();
  console.log("🍽️ Menus API response:", data);

  // ✅ API returns { data: { menus: [...] } }
  return data.data?.menus ?? [];
}

/** Fetch items for a given menu slug */
export async function getMenuItemsBySlug(
  menuSlug: string,
  token?: string
): Promise<MenuItem[]> {
  const res = await fetch(`${BASE_URL}/menu-items/${menuSlug}`, {
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    cache: "no-store",
  });

  if (!res.ok) {
    if (res.status === 404) return [];
    throw new Error(`Failed to fetch menu items: ${res.statusText}`);
  }

  const data = await res.json();
  console.log("🥘 Menu Items API response:", data);

  return data.data?.items ?? [];
}
