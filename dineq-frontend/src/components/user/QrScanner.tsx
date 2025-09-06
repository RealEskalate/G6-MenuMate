// src/components/QrScanner.tsx
"use client";

import React, { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { Html5QrcodeScanner, Html5QrcodeResult, QrcodeSuccessCallback, QrcodeErrorCallback } from "html5-qrcode";
import { Scan, XCircle } from "lucide-react";

const QrScanner = () => {
  const router = useRouter();
  const [scanner, setScanner] = useState<Html5QrcodeScanner | null>(null);

  useEffect(() => {
    const html5QrCodeScanner = new Html5QrcodeScanner(
      "qr-reader",
      { fps: 10, qrbox: { width: 250, height: 250 } },
      false
    );

    const onScanSuccess: QrcodeSuccessCallback = (decodedText, result) => {
      console.log("QR Code Scanned:", decodedText);
      html5QrCodeScanner.clear().catch(error => console.error("Failed to clear scanner:", error));
      
      const urlParts = decodedText.split("/");
      const menuSlug = urlParts[urlParts.length - 1];
      router.push(`/restaurant/dashboard/menu/manual_menu?menu_slug=${menuSlug}`);
    };

    const onScanFailure: QrcodeErrorCallback = (error) => {
      console.warn("QR Scan Failure:", error);
    };

    html5QrCodeScanner.render(onScanSuccess, onScanFailure);
    setScanner(html5QrCodeScanner);

    return () => {
      if (scanner) {
        scanner.clear().catch(error => console.error("Failed to clear scanner on unmount:", error));
      }
    };
  }, []);

  const handleClose = () => {
    if (scanner) {
      scanner.clear().catch(error => console.error("Failed to clear scanner on close:", error));
    }
    // You'll need to handle a back button or state reset in your main component
    window.history.back(); 
  };

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-100 p-4">
      <div className="bg-white shadow-lg rounded-2xl p-8 w-full max-w-md text-center relative">
        <button
          onClick={handleClose}
          className="absolute top-4 right-4 text-gray-500 hover:text-gray-700 transition"
        >
          <XCircle size={28} />
        </button>
        <h1 className="text-2xl font-bold mb-4 text-gray-800">Scan QR Code</h1>
        <p className="text-gray-600 mb-6">
          Point your camera at the menu QR code.
        </p>
        <div id="qr-reader" className="w-full max-w-xs mx-auto"></div>
        <div className="mt-6 flex items-center justify-center">
          <Scan className="w-8 h-8 text-orange-500" />
          <p className="ml-2 text-gray-500">Scanning for a code...</p>
        </div>
      </div>
    </div>
  );
};

export default QrScanner;