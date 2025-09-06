// src/components/MenuDigitizer.tsx
"use client";

import React, { useState } from "react";
import MenuUploader from "@/components/user/MenuUploader";
import QrScanner from "@/components/user/QrScanner";
import { Upload, QrCode } from "lucide-react";

type Selection = "upload" | "qr-scan" | null;

const MenuDigitizer = () => {
  const [selection, setSelection] = useState<Selection>(null);

  const handleSelection = (option: Selection) => {
    setSelection(option);
  };

  if (selection === "upload") {
    return <MenuUploader />;
  }

  if (selection === "qr-scan") {
    return <QrScanner />;
  }

  return (
    <div className="flex flex-col items-center justify-center min-h-screen p-4">
      {/* Container with a subtle background and shadow */}
      <div className="bg-white shadow-xl rounded-3xl p-8 w-full max-w-xl text-center backdrop-blur-md bg-opacity-80 border border-gray-200 animate-fade-in">
        <h1 className="text-4xl font-extrabold mb-4 text-gray-800 tracking-tight leading-tight">
          Effortlessly Digitize Your Menu ⚡
        </h1>
        <p className="text-gray-600 text-lg mb-10 font-light">
          Choose a method to transform your physical menu into a dynamic digital experience.
        </p>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Card for Upload Option */}
          <div
            onClick={() => handleSelection("upload")}
            className="flex flex-col items-center p-8 bg-gray-50 rounded-2xl border border-gray-200 cursor-pointer hover:bg-white hover:shadow-lg transition-all duration-300 transform hover:-translate-y-1"
          >
            <div className="bg-orange-100 p-4 rounded-full mb-4">
              <Upload className="h-8 w-8 text-orange-600" />
            </div>
            <h2 className="text-xl font-semibold text-gray-800 mb-2">Upload a Photo</h2>
            <p className="text-gray-500 text-sm">
              Use our AI-powered OCR to extract text from a menu image.
            </p>
          </div>

          {/* Card for QR Code Option */}
          <div
            onClick={() => handleSelection("qr-scan")}
            className="flex flex-col items-center p-8 bg-gray-50 rounded-2xl border border-gray-200 cursor-pointer hover:bg-white hover:shadow-lg transition-all duration-300 transform hover:-translate-y-1"
          >
            <div className="bg-orange-100 p-4 rounded-full mb-4">
              <QrCode className="h-8 w-8 text-orange-600" />
            </div>
            <h2 className="text-xl font-semibold text-gray-800 mb-2">Scan a QR Code</h2>
            <p className="text-gray-500 text-sm">
              Instantly load a pre-existing digital menu by scanning its QR code.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default MenuDigitizer;