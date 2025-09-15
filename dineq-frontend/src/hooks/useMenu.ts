import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { Menu, MenuItem } from "@/Types/menu";

const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL;

// --- Fetch functions ---

// Fetch all menus for a restaurant
async function fetchMenus(
  restaurantSlug: string,
  token?: string
): Promise<Menu[]> {
  const res = await fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL}/menus/${restaurantSlug}`, {
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });

  const data = await res.json();
  console.log("menu data:",data)
  console.log("menu data zerzer",data.menu)

  if (!res.ok) throw new Error(data.message || "Failed to fetch menus");
  

  return data.data?.menus ?? []; 
}

// Fetch a single menu by ID
async function fetchMenuById(
  restaurantSlug: string,
  id: string,
): Promise<Menu> {
  const res = await fetch(`${API_BASE}/menus/${restaurantSlug}/${id}`,);

  const data = await res.json();

  if (!res.ok) throw new Error(data.message || "Failed to fetch menu");

  const menu = data.data?.menu;
  if (!menu) throw new Error("Menu not found");

  return menu;
}

//  Fetch a single menu item
async function fetchMenuItem(
  menuSlug: string,
  id: string,
  token?: string
): Promise<MenuItem> {
  const res = await fetch(`${API_BASE}/menu-items/${menuSlug}/${id}`, {
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });

  const data = await res.json();

  if (!res.ok) throw new Error(data.message || "Failed to fetch menu item");

  const item = data.data?.item;
  if (!item) throw new Error("Menu item not found");

  return item;
}

// --- Update functions ---

//  Update a menu
async function updateMenu(
  restaurantSlug: string,
  id: string,
  data: Partial<Menu>,
  token: string
): Promise<Menu> {
  const res = await fetch(`${API_BASE}/menus/${restaurantSlug}/${id}`, {
    method: "PATCH",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(data),
  });

  const json = await res.json();

  if (!res.ok) throw new Error(json.message || "Failed to update menu");

  return json.data?.menu;
}

// Update a menu item
async function updateMenuItem(
  menuSlug: string,
  id: string,
  data: Partial<MenuItem>,
  token: string
): Promise<MenuItem> {
  const res = await fetch(`${API_BASE}/menu-items/${menuSlug}/${id}`, {
    method: "PATCH",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(data),
  });

  const json = await res.json();

  if (!res.ok) throw new Error(json.message || "Failed to update menu item");

  return json.data?.item;
}



// --- React Query Hooks ---

// Fetch all menus for a restaurant
export function useMenus(restaurantSlug: string, token?: string) {
  return useQuery({
    queryKey: ["menus", restaurantSlug],
    queryFn: () => fetchMenus(restaurantSlug, token),
  });
}

// Fetch a single menu by ID
export function useMenu(restaurantSlug?: string, id?: string, token?: string) {
  return useQuery({
    queryKey: ["menu", restaurantSlug, id],
    queryFn: () => fetchMenuById(restaurantSlug!, id!),
    enabled: !!(restaurantSlug && id), // Only fetch when both are available
  });
}
// Fetch a single menu item
export function useMenuItem(menuSlug: string, id: string, token?: string) {
  return useQuery({
    queryKey: ["menu-item", menuSlug, id],
    queryFn: () => fetchMenuItem(menuSlug, id, token),
  });
}


// Update menu
export function useUpdateMenu(restaurantSlug: string, token: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<Menu> }) =>
      updateMenu(restaurantSlug, id, data, token), 
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["menus", restaurantSlug] });
    },
  });
}


// Update menu item
export function useUpdateMenuItem(menuSlug: string, token: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<MenuItem> }) =>
      updateMenuItem(menuSlug, id, data, token),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["menu-item", menuSlug] });
    },
  });
}