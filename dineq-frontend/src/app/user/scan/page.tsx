// app/page.tsx (or any page you want)
"use client";

import { Upload, CheckCircle } from "lucide-react";

export default function MenuDigitizer() {
  return (
    <div className="min-h-screen bg-gray-50 flex flex-col items-center py-10 px-4">
      {/* Upload Card */}
      <div className="bg-white shadow-md rounded-2xl border border-gray-200 w-full max-w-lg p-6 flex flex-col items-center">
        <Upload className="w-10 h-10 text-orange-500 mb-4" />

        <p className="text-center text-gray-600 mb-6">
          Point your camera at a QR code on the menu to instantly access the
          digital version with translations and additional information.
        </p>

        {/* Drag & Drop */}
        <div className="w-full border-2 border-dashed border-gray-300 rounded-xl p-10 flex flex-col items-center justify-center mb-6">
          <p className="text-gray-500">Drag & Drop Menu Photo</p>
          <span className="text-gray-400 my-2">or</span>
          <button className="px-4 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition">
            Choose File
          </button>
          <p className="text-xs text-gray-400 mt-2">
            Supported formats: JPG, PNG, HEIC
          </p>
        </div>

        {/* Upload Button */}
        <button className="w-full bg-orange-500 text-white font-medium py-3 rounded-lg hover:bg-orange-600 transition">
          ✓ Upload & Digitize
        </button>
      </div>

      {/* Tips Section */}
      <div className="mt-16 w-full max-w-4xl grid grid-cols-1 md:grid-cols-3 gap-8 text-center">
        <div>
          <CheckCircle className="mx-auto text-orange-500 w-7 h-7 mb-2" />
          <h3 className="font-semibold">Good Lighting</h3>
          <p className="text-gray-500 text-sm">
            Ensure the menu is well-lit and clearly visible
          </p>
        </div>
        <div>
          <CheckCircle className="mx-auto text-orange-500 w-7 h-7 mb-2" />
          <h3 className="font-semibold">Flat Surface</h3>
          <p className="text-gray-500 text-sm">
            Place the menu on a flat surface to avoid distortion
          </p>
        </div>
        <div>
          <CheckCircle className="mx-auto text-orange-500 w-7 h-7 mb-2" />
          <h3 className="font-semibold">High Resolution</h3>
          <p className="text-gray-500 text-sm">
            Use the highest resolution possible for better accuracy
          </p>
        </div>
      </div>

      {/* Complete Menu Tip */}
      <div className="mt-10 text-center">
        <CheckCircle className="mx-auto text-orange-500 w-7 h-7 mb-2" />
        <h3 className="font-semibold">Complete Menu</h3>
        <p className="text-gray-500 text-sm">
          Capture the entire menu to get all available dishes
        </p>
      </div>

      {/* Demo Mode */}
      <div className="mt-16 bg-yellow-50 border border-yellow-200 rounded-xl p-6 max-w-3xl text-center">
        <h4 className="font-semibold mb-2">Demo Mode</h4>
        <p className="text-gray-600 text-sm">
          This is a static prototype. In the full version, AI will instantly
          digitize menus, extract dishes and prices, and provide translations in
          multiple languages.
        </p>
      </div>
    </div>
  );
}
