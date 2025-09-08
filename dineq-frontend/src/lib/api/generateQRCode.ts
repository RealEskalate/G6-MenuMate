const baseURL = process.env.NEXT_PUBLIC_API_BASE_URL

export type QRCustomization = {
  background: string;
  foreground: string;
  gradientFrom: string;
  gradientTo: string;
  gradientDirection: string;
  logoURL: string;
  logoSize: number;
  margin: number;
  labelText: string;
  labelColor: string;
  labelSize: number;
};

export async function generateQRCodeFromAPI({
  restaurantSlug,
  menuId,
  authToken,
  customization,
}: {
  restaurantSlug: string;
  menuId: string;
  authToken: string;
  customization: QRCustomization;
}): Promise<Blob> {
  const apiUrl = `${baseURL}/menus/${restaurantSlug}/qrcode/${menuId}`;

  const payload = {
    format: "png",
    size: 600,
    quality: 92,
    include_label: true,
    customization: {
      background_color: customization.background,
      foreground_color: customization.foreground,
      gradient_from: customization.gradientFrom,
      gradient_to: customization.gradientTo,
      gradient_direction: customization.gradientDirection,
      logo: customization.logoURL,
      logo_size_percent: customization.logoSize / 100,
      margin: customization.margin,
      label_text: customization.labelText,
      label_color: customization.labelColor,
      label_font_size: customization.labelSize,
    },
  };

  const response = await fetch(apiUrl, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${authToken}`,
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }

  const qrCodeBlob = await response.blob();
  return qrCodeBlob;
}
