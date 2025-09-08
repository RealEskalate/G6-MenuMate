"use client";
import { useState, useRef } from "react";
import { QRCode } from "react-qrcode-logo";
import { Download, Upload } from "lucide-react";
import { toast } from "react-hot-toast";
import { useRouter } from "next/navigation";
import { useSession } from "next-auth/react";
import { useSearchParams } from "next/navigation";
import { getGradientFromColor } from "@/utils/colorGradient";
import BackButton from "@/components/common/BackButton";



export default function QRCustomizer() {
  const [foreground, setForeground] = useState("#000000");
  const [background, setBackground] = useState("#ffffff");

  const [logo, setLogo] = useState<string | null>(null);
  const [logoSize, setLogoSize] = useState(20); // % relative to QR size
  const [margin, setMargin] = useState(4);

  const [labelText, setLabelText] = useState("Sample QR Code");
  const [labelColor, setLabelColor] = useState("#374151");
  const [labelSize, setLabelSize] = useState(12);

  const qrWrapperRef = useRef<HTMLDivElement>(null);
  const qrSize = 180;

  // logo urls
  const [logoPreview, setLogoPreview] = useState<string | null>(null); // for preview
  const [logoURL, setLogoURL] = useState<string | null>(null);         // for API usage

  const apiBaseURL = process.env.NEXT_PUBLIC_API_BASE_URL
  const { data: session } = useSession();
  const token = session?.accessToken;
  const router = useRouter();
  //handle slug and id from route

  const searchParams = useSearchParams();
  const restaurantSlug = searchParams.get("slug");
  const menuId = searchParams.get("menu");

  //  gradient data

  const { light, dark } = getGradientFromColor(foreground);

  const gradientFrom = light;
  const gradientTo = dark
  const gradientDirection = "vertical";

  

  


const handleLogoUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
  const file = e.target.files?.[0];
  if (!file) return;

  // Preview locally
  const reader = new FileReader();
  reader.onload = () => {
    setLogoPreview(reader.result as string); // For preview
  };
  reader.readAsDataURL(file);

  // Upload to remote server
  const formData = new FormData();
  formData.append("image", file);

  try {
    const response = await fetch(`${apiBaseURL}/uploads/image`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`, // replace this
      },
      body: formData
    });

    const result = await response.json();
    if (result.success && result.data?.url) {
      setLogoURL(result.data.url); // For sending to QR API
    } else {
      console.error("Upload failed:", result);
    }
  } catch (err) {
    console.error("Error uploading logo:", err);
  }
};



  const handleDownload = () => {
    const canvas = qrWrapperRef.current?.querySelector("canvas");
    if (!canvas) return;
    const url = canvas.toDataURL("image/png");
    const a = document.createElement("a");
    a.href = url;
    a.download = "qr-code.png";
    a.click();
  };

  const generateQRCodeFromAPI = async (restaurantSlug: string, menuId: string) => {
    const apiUrl = `${apiBaseURL}/menus/${restaurantSlug}/qrcode/${menuId}`;

    const payload = {
      format: "png",
      size: 600,
      quality: 92,
      include_label: true,
      customization: {
        background_color: background,
        foreground_color: foreground, 
        gradient_from: gradientFrom, 
        gradient_to: gradientTo,   
        gradient_direction: gradientDirection,
        logo: logoURL || "https://res.cloudinary.com/dmahwet/image/upload/v1757007077/dineQ/general/huafbulre2yxgkxi0flu.png", 
        logo_size_percent: logoSize / 100, 
        margin: margin,
        label_text: labelText,
        label_color: labelColor,
        label_font_size: labelSize * 2, 
        label_font_url: "https://github.com/google/fonts/raw/main/apache/opensans/OpenSans-SemiBold.ttf"
      }
    };

    try {
      toast.loading("Generating QR code...");

      const response = await fetch(apiUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token}` 
        },
        body: JSON.stringify(payload)
      });

      toast.dismiss();

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const qrCodeBlob = await response.blob();
      console.log("QR Code generated successfully from API:", qrCodeBlob);
      const imageUrl = URL.createObjectURL(qrCodeBlob);
      toast.success("QR Code generated successfully!");
      console.log("Image URL:", imageUrl);

      setTimeout(() => {
      router.push("/restaurant/dashboard/qr-manager");
    }, 1500); 

    } catch (error) {
      toast.dismiss();
      console.error("Error generating QR code from API:", error);
      toast.error("Failed to generate QR code")
    }
  };

  return (
    <div className="relative w-full">
    {/* Back button top-right */}
    <div className="w-full flex justify-start px-6 pt-4">
      <BackButton />
    </div>
      <div className="flex">
        <div className="grid grid-cols-1 md:grid-cols-[2fr_1fr] gap-6 p-6 w-full items-start">
          {/* Left side - Customization */}
          <div className="p-6">
            <h2 className="text-lg font-semibold mb-4">Customize Menu QR</h2>
            <p className="text-sm text-gray-500 mb-6">
              Customize your QR code for your restaurant menu
            </p>

            {/* Colors */}
            <div className="mb-6">
              <label className="block text-sm font-medium mb-2">Colors</label>
              <div className="flex gap-6">
                <div>
                  <span className="text-xs block mb-1">Background</span>
                  <input
                    type="color"
                    value={background}
                    onChange={(e) => setBackground(e.target.value)}
                    className="w-16 h-8 border rounded cursor-pointer"
                  />
                </div>
                <div>
                  <span className="text-xs block mb-1">Foreground</span>
                  <input
                    type="color"
                    value={foreground}
                    onChange={(e) => setForeground(e.target.value)}
                    className="w-16 h-8 border rounded cursor-pointer"
                  />
                </div>
              </div>
            </div>

            {/* Logo */}
            <div className="mb-6">
              <label className="block text-sm font-medium mb-2">Logo</label>
              <label className="w-full h-20 border-2 border-dashed rounded-xl flex items-center justify-center cursor-pointer">
                {logo ? (
                  <img src={logo} alt="logo" className="h-12 object-contain" />
                ) : (
                  <div className="flex flex-col items-center text-gray-400">
                    <Upload className="w-5 h-5 mb-1" />
                    <span className="text-xs">Tap to upload logo</span>
                  </div>
                )}
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleLogoUpload}
                  className="hidden"
                />
              </label>
              <input
                type="range"
                min={10}
                max={40}
                value={logoSize}
                onChange={(e) => setLogoSize(Number(e.target.value))}
                className="w-full mt-2"
              />
              <p className="text-xs text-gray-500">Size: {logoSize}%</p>
            </div>

            {/* Layout */}
            <div className="mb-6">
              <label className="block text-sm font-medium mb-2">Layout</label>
              <input
                type="range"
                min={0}
                max={20}
                value={margin}
                onChange={(e) => setMargin(Number(e.target.value))}
                className="w-full"
              />
              <p className="text-xs text-gray-500">Margin: {margin}px</p>
            </div>

            {/* Label */}
            <div className="mb-6">
              <label className="block text-sm font-medium mb-2">Label</label>
              <input
                type="text"
                value={labelText}
                onChange={(e) => setLabelText(e.target.value)}
                placeholder="Enter label text"
                className="w-full rounded border p-2 text-sm mb-2"
              />
              <div className="flex gap-6 mb-2">
                <input
                  type="color"
                  value={labelColor}
                  onChange={(e) => setLabelColor(e.target.value)}
                  className="w-16 h-8 border rounded cursor-pointer"
                />
                <input
                  type="number"
                  min={8}
                  max={32}
                  value={labelSize}
                  onChange={(e) => setLabelSize(Number(e.target.value))}
                  className="w-20 border rounded p-1 text-sm"
                />
              </div>
            </div>
            {/* Button to trigger API call */}
            

          </div>

          {/* Right side - Preview */}
          <div className="p-6 border rounded-2xl shadow-sm flex flex-col items-center">
            
            <h2 className="text-lg font-semibold mb-4">Preview</h2>
            <div
              ref={qrWrapperRef}
              className="bg-gray-50 p-4 rounded-xl flex flex-col items-center"
              style={{ width: qrSize + 40 }}
            >
              {/* This QR Code is generated client-side, it won't have the gradient unless you use a library that supports it */}
              <QRCode
                value="https://example.com/menu"
                size={qrSize}
                bgColor={background}
                fgColor={foreground}
                qrStyle="squares"
                removeQrCodeBehindLogo
                logoImage={logoPreview || undefined}
                logoWidth={(logoSize / 100) * qrSize}
                logoHeight={(logoSize / 100) * qrSize}
                quietZone={Math.floor((margin / 20) * qrSize / 10)}
                eyeRadius={2}
                ecLevel="H"
              />
              {labelText && (
                <p
                  className="mt-2 text-center"
                  style={{ color: labelColor, fontSize: `${labelSize}px` }}
                >
                  {labelText}
                </p>
              )}
            </div>
            <button
                onClick={
                  () => {
                  if (restaurantSlug && menuId) {
                    generateQRCodeFromAPI(restaurantSlug, menuId);
                  } else {
                    toast.error("Missing restaurant or menu information.");
                  }
                }}
                className="mt-6 bg-orange-500 text-white py-2 px-6 rounded-xl hover:bg-orange-600 transition disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Generate QR
              </button>
          </div>
        </div>
      </div>
    </div>
  );
}