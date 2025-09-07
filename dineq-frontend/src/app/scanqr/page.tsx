"use client";

import { useRef } from "react";
import jsQR from "jsqr";

export default function QrScannerPage() {
  const fileInputRef = useRef<HTMLInputElement | null>(null);
  const canvasRef = useRef<HTMLCanvasElement | null>(null);

  const handleFileChange = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    const img = new Image();
    img.src = URL.createObjectURL(file);

    img.onload = () => {
      const canvas = canvasRef.current;
      if (!canvas) return;
      const ctx = canvas.getContext("2d");
      if (!ctx) return;

      // Resize canvas to image size
      canvas.width = img.width;
      canvas.height = img.height;
      ctx.drawImage(img, 0, 0, img.width, img.height);

      // Extract pixel data
      const imageData = ctx.getImageData(0, 0, img.width, img.height);
      const qrCode = jsQR(imageData.data, imageData.width, imageData.height);

      if (qrCode) {
        const url = qrCode.data;
        console.log("QR Code content:", url);

        // If valid URL, redirect
        if (url.startsWith("http://") || url.startsWith("https://")) {
          window.location.href = url;
        } else {
          alert(`QR Code found, but it's not a valid URL: ${url}`);
        }
      } else {
        alert("No QR code detected in this image.");
      }
    };
  };

  return (
    <div className="flex flex-col items-center justify-center min-h-screen p-6">
      <h1 className="text-xl font-bold mb-4">Upload QR Code Image</h1>

      <input
        type="file"
        accept="image/*"
        ref={fileInputRef}
        onChange={handleFileChange}
        className="mb-4"
      />

      {/* Hidden canvas used for processing */}
      <canvas ref={canvasRef} style={{ display: "none" }} />
    </div>
  );
}
