import { useQuery } from "@tanstack/react-query";

const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL;
console.log(API_BASE)

async function fetchRestaurantMe(token: string) {
  console.log("Fetching restaurant with token:", token);
  const res = await fetch(`${API_BASE}/restaurants/me`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  const data = await res.json();
  // console.log("Restaurant data fetched:", data);

  if (!res.ok) throw new Error("Failed to fetch restaurant");
  return data;
}

export function useRestaurant(token?: string) {
  return useQuery({
    queryKey: ["restaurant"],
    queryFn: () => fetchRestaurantMe(token!),
    enabled: !!token,
    staleTime: 1000 * 60 * 5,
  });
}
