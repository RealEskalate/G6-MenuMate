"use client";

import { useRegister } from "@/context/RegisterContext";
import { useRouter } from "next/navigation";
import { FaStore, FaPhoneAlt, FaTags, FaInfoCircle } from "react-icons/fa";
import React, { useState } from "react";
import LocationPicker from "./LocationPicker";
import FileUploadBox, { UploadedFile } from "./FileUploadBox";

export default function BasicInfoForm() {
  const { data, updateData } = useRegister();

  const location = data.address || "";
  const businessLicense = data.businessLicense || null;
  const logoImage = data.logo_image || null;
  const router = useRouter();

  const [error, setError] = useState<string | null>(null);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!data.restaurant || !data.phone || !location || !businessLicense) {
      setError("Please fill in all required fields.");
      return;
    }
    setError(null);
    router.push("/restaurant/register/review");
  };

  // ✅ Helper to wrap File into UploadedFile format
  const handleFileChange = (file: UploadedFile | null, key: "logo_image" | "businessLicense") => {
    if (file) {
      updateData({
        [key]: {
          name: file.name,
          size: Math.round(file.size / (1024 * 1024)), // size in MB
          file,
        },
      });
    } else {
      updateData({ [key]: null });
    }
  };

  return (
    <div className="flex items-center justify-center px-4 py-4">
      <form
        className="bg-white rounded-lg p-6 w-full max-w-3xl space-y-4"
        onSubmit={handleSubmit}
      >
        {/* Heading */}
        <div>
          <h2 className="text-xl font-semibold text-gray-900 text-left">
            Restaurant Information
          </h2>
        </div>

        {/* Restaurant Name */}
        <div>
          <label className="block text-md font-medium text-gray-700 mb-1 text-left">
            Restaurant Name
          </label>
          <div className="relative w-full">
            <input
              type="text"
              value={data.restaurant}
              onChange={(e) => updateData({ restaurant: e.target.value })}
              placeholder="Enter restaurant name"
              className="w-full pl-3 pr-10 py-2 border border-gray-300 rounded-md text-sm 
                         focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
            />
            <span className="absolute inset-y-0 right-2 flex items-center pointer-events-none">
              <FaStore className="text-gray-400 text-sm" />
            </span>
          </div>
        </div>

        {/* Phone Number */}
        <div>
          <label className="block text-md font-medium text-gray-700 mb-1 text-left">
            Phone Number
          </label>
          <div className="relative w-full">
            <input
              type="tel"
              value={data.phone}
              onChange={(e) => updateData({ phone: e.target.value })}
              placeholder="Enter phone number"
              className="w-full pl-3 pr-10 py-2 border border-gray-300 rounded-md text-sm
                         focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
            />
            <span className="absolute inset-y-0 right-2 flex items-center pointer-events-none">
              <FaPhoneAlt className="text-gray-400 text-sm" />
            </span>
          </div>
        </div>

        {/* About */}
        <div>
          <label className="block text-md font-medium text-gray-700 mb-1 text-left">
            About (optional)
          </label>
          <div className="relative w-full">
            <textarea
              value={data.about || ""}
              onChange={(e) => updateData({ about: e.target.value })}
              placeholder="Write a short description about your restaurant"
              rows={2}
              className="w-full pl-3 pr-10 py-2 border border-gray-300 rounded-md text-sm
                         focus:ring-2 focus:ring-orange-500 focus:border-orange-500 resize-none"
            />
            <span className="absolute top-2 right-2 pointer-events-none">
              <FaInfoCircle className="text-gray-400 text-sm" />
            </span>
          </div>
        </div>

        {/* Tags */}
        <div>
          <label className="block text-md font-medium text-gray-700 mb-1 text-left">
            Tags (optional)
          </label>
          <div className="relative w-full">
            <input
              type="text"
              value={data.tags?.join(", ") || ""}
              onChange={(e) =>
                updateData({
                  tags: e.target.value
                    .split(",")
                    .map((t) => t.trim())
                    .filter((t) => t.length > 0),
                })
              }
              placeholder="Enter tags separated by commas (e.g. Ethiopian, Vegan, Fast Food)"
              className="w-full pl-3 pr-10 py-2 border border-gray-300 rounded-md text-sm
                         focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
            />
            <span className="absolute inset-y-0 right-2 flex items-center pointer-events-none">
              <FaTags className="text-gray-400 text-sm" />
            </span>
          </div>
        </div>

        {/* Location */}
        <LocationPicker
          value={location}
          onChange={(v) => updateData({ address: v })}
          compact={true}
        />

        {/* Logo Upload */}
        <FileUploadBox
          label="Logo Image (optional)"
          required={false}
          file={logoImage}
          onFileChange={(file) => handleFileChange(file, "logo_image")}
          compact={true}
        />

        {/* License Upload */}
        <FileUploadBox
          label="Business License"
          required
          file={businessLicense}
          onFileChange={(file) => handleFileChange(file, "businessLicense")}
          compact={true}
        />

        {error && <p className="text-red-500 text-xs">{error}</p>}
        <div className="flex justify-end pt-2">
          <button
            type="submit"
            className="px-4 py-2 bg-orange-500 text-white rounded-md text-sm 
                      hover:bg-orange-600 focus:outline-none focus:ring-2 
                      focus:ring-orange-500"
          >
            Save and Continue →
          </button>
        </div>
      </form>
    </div>
  );
}
