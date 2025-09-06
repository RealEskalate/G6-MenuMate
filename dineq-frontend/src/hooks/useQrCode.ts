// hooks/useQrCode.ts
import { useQuery } from "@tanstack/react-query";

const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL;

async function fetchQrCode(restaurantSlug: string, token: string) {
  const res = await fetch(`${API_BASE}/qr-code/${restaurantSlug}`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  if (!res.ok) throw new Error("Failed to fetch QR code");

  const json = await res.json();

  // Extract the image URL from the response
  return json?.data?.qr_code?.ImageURL as string;
}

export function useQrCode(restaurantSlug?: string, token?: string) {
  return useQuery({
    queryKey: ["qr-code", restaurantSlug],
    queryFn: () => fetchQrCode(restaurantSlug!, token!),
    enabled: !!restaurantSlug && !!token,
    staleTime: 1000 * 60 * 5,
  });
}
