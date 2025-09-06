type QRCustomization = {
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
  const apiUrl = `https://g6-menumate-1.onrender.com/api/v1/menus/${restaurantSlug}/qrcode/${menuId}`;

  const payload = {
    format: "png",
    size: 600,
    quality: 92,
    include_label: true,
    customization: {
