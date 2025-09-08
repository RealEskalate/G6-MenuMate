
import { useSession } from "next-auth/react"
export interface ImageResult {
  item_name: string;
  photo_url: string;
  thumbnail_url: string;
  confidence_score: number;
  source: string;
  alt_text: string;
}

// export async function fetchItemImages(
//   query: string,
//   limit: number = 6
// ): Promise<ImageResult[]> {
//   if (!query) return [];

//   try {
//     // const res = await fetch(
//     //   `${process.env.NEXT_PUBLIC_API_URL}/imagesearch?item=${encodeURIComponent(
//     //     query
//     //   )}&limit=${limit}`
//     // );
//     const url = `https://dineq.onrender.com/api/v1/images/search?item=${encodeURIComponent(query)}&limit=${limit}`;
//     console.log("Fetching images from:", url);
//     const res = await fetch(url);


//     if (!res.ok) {
//       throw new Error(`Failed to fetch images: ${res.status}`);
//     }

//     const data = await res.json();
//     return data?.data?.results || [];
//   } catch (err) {
//     console.error("Image search error:", err);
//     return [];
//   }
// }
export async function fetchItemImages(
  query: string,
  limit: number = 6,
  token?: string
): Promise<ImageResult[]> {
  if (!query) return [];

  try {
    const url = `https://dineq.onrender.com/api/v1/images/search?item=${encodeURIComponent(query)}`;
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
