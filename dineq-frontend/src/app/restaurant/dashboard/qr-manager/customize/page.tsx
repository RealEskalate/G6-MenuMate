"use client";
import { useState } from "react";
import { QRCodeSVG } from "qrcode.react"; // install: npm install qrcode.react
import { ChevronDown, Upload, Download } from "lucide-react";
import NavBar from "@/components/common/NavBar";
import SideBar from "@/components/restaurant/SideBar";

type QRStyle = "classic" | "rounded" | "dots";
type QRLogo = "none" | "restaurant" | "custom";

export default function QRCustomizer() {
  const [restaurantName, setRestaurantName] = useState("Your Restaurant");
  const [style, setStyle] = useState<QRStyle>("classic");
  const [foreground, setForeground] = useState("#ff6600");
  const [background, setBackground] = useState("#ffffff");
  const [logo, setLogo] = useState<QRLogo>("none");
  const [dropdownOpen, setDropdownOpen] = useState(false);

  return (
    <div>
      <NavBar role="MANAGER" />
      <div className="flex">
        <SideBar />
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 p-6 font-sans">
          {/* Left side - Customization */}
          <div className="p-6 border rounded-2xl shadow-sm">
            <h2 className="text-lg font-semibold mb-4">
              Customize Main Menu QR
            </h2>
            <p className="text-sm text-gray-500 mb-6">
              Customize your QR code for your restaurant menu
            </p>

            {/* Restaurant Name */}
            <div className="mb-6">
              <label className="block text-sm font-medium mb-1">
                Restaurant Name
              </label>
              <input
                type="text"
                value={restaurantName}
                onChange={(e) => setRestaurantName(e.target.value)}
                placeholder="Enter your restaurant name"
                className="w-full rounded-xl border border-gray-300 p-2 focus:outline-none focus:ring-2 focus:ring-orange-500"
              />
            </div>

            {/* QR Code Style */}
            <div className="mb-6">
              <label className="block text-sm font-medium mb-2">
                QR Code Style
              </label>
              <div className="flex gap-4">
                {[
                  { id: "classic", label: "Classic" },
                  { id: "rounded", label: "Rounded" },
                  { id: "dots", label: "Dots" },
                ].map((opt) => (
                  <button
                    key={opt.id}
                    onClick={() => setStyle(opt.id as QRStyle)}
                    className={`w-20 h-20 border rounded-xl flex items-center justify-center text-sm ${
                      style === opt.id
                        ? "border-orange-500 ring-2 ring-orange-300"
                        : "border-gray-300"
                    }`}
                  >
                    {opt.label}
                  </button>
                ))}
              </div>
            </div>

            {/* QR Code Colors */}
            <div className="mb-6">
              <label className="block text-sm font-medium mb-2">
                QR Code Colors
              </label>
              <div className="flex gap-6">
                <div>
                  <span className="text-xs mb-1 block">Foreground</span>
                  <input
                    type="color"
                    value={foreground}
                    onChange={(e) => setForeground(e.target.value)}
                    className="w-16 h-8 rounded border cursor-pointer"
                  />
                </div>
                <div>
                  <span className="text-xs mb-1 block">Background</span>
                  <input
                    type="color"
                    value={background}
                    onChange={(e) => setBackground(e.target.value)}
                    className="w-16 h-8 rounded border cursor-pointer"
                  />
                </div>
              </div>
            </div>

            {/* Add Logo */}
            <div className="mb-6">
              <label className="block text-sm font-medium mb-2">Add Logo</label>
              <div className="flex gap-4">
                {[
                  { id: "none", label: "None" },
                  { id: "restaurant", label: "Restaurant" },
                  { id: "custom", label: "Custom" },
                ].map((opt) => (
                  <button
                    key={opt.id}
                    onClick={() => setLogo(opt.id as QRLogo)}
                    className={`w-24 h-20 border rounded-xl flex items-center justify-center text-sm ${
                      logo === opt.id
                        ? "border-orange-500 ring-2 ring-orange-300"
                        : "border-gray-300"
                    }`}
                  >
                    {opt.id === "custom" ? (
                      <Upload className="w-5 h-5" />
                    ) : (
                      opt.label
                    )}
                  </button>
                ))}
              </div>
            </div>

            <button className="bg-orange-500 text-white py-2 px-4 w-full rounded-xl hover:bg-orange-600 transition">
              Generate QR Code
            </button>
          </div>

          {/* Right side - Preview */}
          <div className="p-6 border rounded-2xl shadow-sm flex flex-col items-center justify-center">
            <h2 className="text-lg font-semibold mb-4">Preview</h2>
            <div className="bg-gray-50 p-6 rounded-xl flex flex-col items-center">
              <QRCodeSVG
                value={`https://example.com/menu/${restaurantName}`}
                size={150}
                fgColor={foreground}
                bgColor={background}
                level="H"
              />
              <p className="mt-4 font-medium">{restaurantName}</p>
              <p className="text-sm text-gray-500">Scan to view our menu</p>
            </div>

            {/* Download Dropdown */}
            <div className="relative mt-6">
              <button
                onClick={() => setDropdownOpen(!dropdownOpen)}
                className="bg-orange-500 text-white py-2 px-4 rounded-xl flex items-center gap-2 hover:bg-orange-600 transition"
              >
                <Download className="w-4 h-4" />
                Download
                <ChevronDown className="w-4 h-4" />
              </button>
              {dropdownOpen && (
                <div className="absolute mt-2 w-28 bg-white border rounded-xl shadow-lg overflow-hidden">
                  <button
                    onClick={() => alert("Download PDF")}
                    className="block w-full px-4 py-2 text-sm hover:bg-gray-100"
                  >
                    .pdf
                  </button>
                  <button
                    onClick={() => alert("Download PNG")}
                    className="block w-full px-4 py-2 text-sm hover:bg-gray-100"
                  >
                    .png
                  </button>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
