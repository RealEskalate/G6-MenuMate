export const uploadImage = async (
  file: File,
  token: string
): Promise<string> => {
  const formData = new FormData();
  formData.append("file", file);

  const res = await fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL}/uploads`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
    },
    body: formData,
  });

  if (!res.ok) {
    throw new Error("Image upload failed");
  }

  const data = await res.json();
  return data.url; // <- Adjust if API returns differently
};

export const createMenu = async (
  sections: any[],
  token: string,
  restaurantSlug: string
) => {
  const res = await fetch(
    `${process.env.NEXT_PUBLIC_API_BASE_URL}/menus/${restaurantSlug}`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify(sections),
    }
  );

  if (!res.ok) {
    const err = await res.text();
    throw new Error(`Menu creation failed: ${err}`);
  }

  return res.json();
};
