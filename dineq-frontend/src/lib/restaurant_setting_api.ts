// The base URL remains the same
const API_BASE_URL = "https://g6-menumate-1.onrender.com/api/v1";

// The helper to build FormData remains the same
function buildFormData(data: Record<string, any>): FormData {
  const formData = new FormData();
  for (const key in data) {
    const value = data[key];
    if (value === null || value === undefined) continue;
    if (value instanceof File) formData.append(key, value);
    else if (typeof value === "object")
      formData.append(key, JSON.stringify(value));
    else formData.append(key, String(value));
  }
  return formData;
}

/**
 * Fetches the restaurants for the currently authenticated user.
 * @param token - The user's JWT Bearer token.
 */
export const getMyRestaurantProfile = async (token: string) => {
  const response = await fetch(`${API_BASE_URL}/restaurants/me`, {
    headers: {
      Authorization: `Bearer ${token}`, // <-- Pass the token here
    },
  });
  if (!response.ok)
    throw new Error(`Failed to fetch data: ${response.statusText}`);
  return await response.json();
};

/**
 * Updates a specific restaurant's settings.
 * @param slug - The slug of the restaurant to update.
 * @param token - The user's JWT Bearer token for authorization.
 * @param updates - An object containing the fields to update.
 */
export const updateRestaurantProfile = async (
  slug: string,
  token: string,
  updates: Record<string, any>
) => {
  const formData = buildFormData(updates);
  const response = await fetch(`${API_BASE_URL}/restaurants/${slug}`, {
    method: "PATCH",
    headers: {
      Authorization: `Bearer ${token}`, // <-- Pass the token here
    },
    body: formData,
  });
  if (!response.ok)
    throw new Error(`Failed to update data: ${response.statusText}`);
  return await response.json();
};
