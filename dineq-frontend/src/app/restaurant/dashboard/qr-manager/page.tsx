"use client";

import Image from "next/image";
import Link from "next/link";
import React from "react";
import { useRestaurant } from "@/hooks/useRestaurant";
import { useQrCode } from "@/hooks/useQrCode";
import { useSession } from "next-auth/react";
import { useMenus } from "@/hooks/useMenu";
import { Download } from "lucide-react";

function QrManager() {
  const { data: session } = useSession();
  const token = session?.accessToken || "your-token-here";

  const { data: restaurant, isLoading: loadingRestaurant } =
    useRestaurant(token);
  const slug = restaurant?.slug;

  const { data: menus } = useMenus(slug, token);
  const menuId = menus?.[0]?.id;

  const {
    data: qrImageUrl,
    isLoading: loadingQr,
    isError: qrError,
  } = useQrCode(slug, token);

  
  const handleDownload = async () => {
  if (!qrImageUrl) return;

  try {
    const response = await fetch(qrImageUrl);
    const blob = await response.blob();
    const url = URL.createObjectURL(blob);

    const a = document.createElement("a");
    a.href = url;
    a.download = "menu-qr.png"; // 👈 filename
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);

    URL.revokeObjectURL(url); // cleanup
  } catch (error) {
    console.error("Failed to download image:", error);
  }
};


  return (
    <main className="flex-1 px-6">
      <div className="mb-6 bg-white p-4 rounded-2xl shadow-[0_4px_12px_#ffead4]">
        <div className="font-bold text-2xl">QR Manager</div>
      </div>

      <div className="flex px-2 space-x-5">
        {/* QR Card */}
        <div className="rounded-2xl px-12 py-8 border border-orange-200 flex flex-col items-center">
          {loadingQr ? (
            <span className="mb-3 text-gray-500">Loading QR...</span>
          ) : qrError ? (
            <span className="mb-3 text-red-500">Failed to load QR</span>
          ) : (
            <Image
            src={qrImageUrl!}
            alt="QR Code"
            width={300}
            height={300}
            className="mb-3 w-48 h-48 md:w-64 md:h-64 object-contain"
            priority
          />

          )}

          <span className="font-bold mb-4">Main Menu</span>

          <div className="flex space-x-4">
            {/* Share Button */}
            <button 
            onClick={handleDownload}
            disabled={!qrImageUrl}
            className="flex items-center rounded-lg bg-white border border-orange-200 hover:shadow-orange-500 transition text-orange-500 px-3 py-2">
               <Download className="w-5 h-5 mr-2" />
              <span>Download</span>
            </button>

            {/* Customize Button */}
            <Link
              href={`/restaurant/dashboard/qr-manager/customize?slug=${slug}&menu=${menuId}`}
            >
              <button className="flex items-center rounded-lg bg-orange-500 text-white px-3 py-2 hover:shadow-orange-500 transition">
                <Image
                  src="/icons/edit.png"
                  alt="Edit"
                  className="w-4 h-4 mr-2"
                  width={16}
                  height={16}
                />
                Customize
              </button>
            </Link>
          </div>
        </div>
      </div>
    </main>
  );
}

export default QrManager;
