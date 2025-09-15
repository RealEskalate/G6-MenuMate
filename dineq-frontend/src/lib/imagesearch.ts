
import { useSession } from "next-auth/react"
export interface ImageResult {
  item_name: string;
  photo_url: string;
  thumbnail_url: string;
  confidence_score: number;
  source: string;
  alt_text: string;
}

export async function fetchItemImages(
  query: string,
  limit: number = 6,
  token?: string
): Promise<ImageResult[]> {
  if (!query) return [];

  try {
    const url = `${process.env.NEXT_PUBLIC_API_BASE_URL}/images/search?item=${encodeURIComponent(query)}`;
    console.log("Fetching images from:", url);

    const res = await fetch(url, {
      headers: token ? { Authorization: `Bearer ${token}` } : undefined,
    });

    if (!res.ok) {
      throw new Error(`Failed to fetch images: ${res.status}`);
    }

    const data = await res.json();
    return data?.data?.results || [];
  } catch (err) {
    console.error("Image search error:", err);
    return [];
  }
}
