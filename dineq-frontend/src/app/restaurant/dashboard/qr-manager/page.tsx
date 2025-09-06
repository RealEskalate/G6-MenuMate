"use client";

import Image from "next/image";
import Link from "next/link";
import React from "react";
import { useRestaurant } from "@/hooks/useRestaurant";
import { useQrCode } from "@/hooks/useQrCode";
import { useSession } from "next-auth/react"; // Adjust if not using next-auth

function QrManager() {
  const { data: session } = useSession();
  const token = session?.accessToken || "your-token-here";

  const { data: restaurant, isLoading: loadingRestaurant } =
    useRestaurant(token);
  const slug = restaurant?.slug;

  const {
    data: qrImageUrl,
    isLoading: loadingQr,
    isError: qrError,
  } = useQrCode(slug, token);

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
              width={110}
              height={110}
              className="mb-3"
            />
          )}

          <span className="font-bold mb-4">Main Menu</span>

          <div className="flex space-x-4">
            <button className="flex items-center rounded-lg bg-white border border-orange-200 hover:shadow-orange-500 transition text-orange-500 px-3 py-2">
              <Image
                src="/icons/share.png"
                alt="Share"
                className="w-4 h-4 mr-2"
                width={16}
                height={16}
              />
              <span>Share</span>
            </button>

            <Link href="/restaurant/dashboard/qr-manager/customize">
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
