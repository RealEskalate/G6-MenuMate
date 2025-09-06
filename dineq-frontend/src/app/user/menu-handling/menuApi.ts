// components/user/menu-handeling/menuApi.ts

const BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL ||
  "https://g6-menumate-1.onrender.com/api/v1";

export interface MenuItem {
  id: string;
  name: string;
  description?: string;
  price: number;
  image?: string;
  allergens?: string[];
  dietary_info?: string[];
}

export interface MenuCategory {
  name: string;
  items: MenuItem[];
}

export interface Menu {
  id: string;
  restaurant_id: string;
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
  });

  if (!res.ok) {
    throw new Error(`Failed to fetch menus: ${res.statusText}`);
  }

  const data = await res.json();
  return data.data.menu as Menu[];
}

/** Fetch one menu by ID (with categories/items) */
export async function getMenuById(
  menuId: string,
  token: string
): Promise<Menu> {
  const res = await fetch(`${BASE_URL}/menus/${menuId}`, {
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
  });

  if (!res.ok) {
    throw new Error(`Failed to fetch menu details: ${res.statusText}`);
  }

  const data = await res.json();
  return data.data as Menu;
}
