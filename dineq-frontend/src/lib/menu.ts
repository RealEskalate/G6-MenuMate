export const createMenu = async (
  restaurantSlug: string,
  menuData: any,
  token: string
) => {
  try {
    const response = await fetch(
      `https://g6-menumate-1.onrender.com/api/v1/menus/${restaurantSlug}`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(menuData),
      }
    );

    if (!response.ok) {
      throw new Error(`Error: ${response.status} - ${response.statusText}`);
    }

    return await response.json();
  } catch (error) {
    console.error("Create Menu Error:", error);
    throw error;
  }
};
