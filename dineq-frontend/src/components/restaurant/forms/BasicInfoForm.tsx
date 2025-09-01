"use client";

import { useRegister } from "@/context/RegisterContext";
import { useRouter } from "next/navigation";
import { FaStore, FaPhoneAlt } from "react-icons/fa";
import React, { useState} from "react";
import LocationPicker from "./LocationPicker";
import FileUploadBox from "./FileUploadBox";

export default function BasicInfoForm() {
  const { data, updateData } = useRegister();

  const location = data.address || "";
  const businessLicense = data.businessLicense || null;
  const router = useRouter();

  const [error, setError] = useState<string | null>(null);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!data.restaurant || !data.phone || !location || !businessLicense) {
      setError("Please fill in all fields.");
      return;
    }
    setError(null);
    router.push("/register/review");
  };

  return (
    <div className="px-4 sm:px-8 md:pl-16 py-10 md:py-16 w-full">
      {/* Heading */}
      <div className="mb-6">
        <h2 className="text-xl sm:text-2xl font-semibold text-gray-900 text-left">
          Restaurant Information
        </h2>
      </div>

      {/* Keep everything aligned left under the heading */}
      <form className="space-y-6 max-w-3xl w-full" onSubmit={handleSubmit}>
        {/* Restaurant Name */}
        <div>
          <label className="block text-base sm:text-lg font-medium text-gray-700 mb-2 text-left">
            Restaurant Name
          </label>
          <div className="relative">
            <input
              type="text"
              value={data.restaurant}
              onChange={(e) => updateData({ restaurant: e.target.value })}
              placeholder="Enter restaurant name"
              className="w-full sm:max-w-md pl-3 pr-10 py-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-orange-500 focus:border-orange-500 text-sm sm:text-base"
            />
            <FaStore className="absolute right-3 top-4 text-gray-400" />
          </div>
        </div>

        {/* Phone Number */}
        <div>
          <label className="block text-base sm:text-lg font-medium text-gray-700 mb-2 text-left">
            Phone Number
          </label>
          <div className="relative">
            <input
              type="tel"
              value={data.phone}
              onChange={(e) => updateData({ phone: e.target.value })}
              placeholder="Enter phone number"
              className="w-full sm:max-w-md pl-3 pr-10 py-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-orange-500 focus:border-orange-500 text-sm sm:text-base"
            />
            <FaPhoneAlt className="absolute right-3 top-4 text-gray-400" />
          </div>
        </div>

        {/* Location */}
        <div className="sm:max-w-md">
          <LocationPicker value={location} onChange={(v) => updateData({ address: v })} />
        </div>

        {/* File Upload */}
        <div className="sm:max-w-md">
          <FileUploadBox
            label="Business License"
            required
            file={businessLicense}
            onFileChange={(file) => updateData({ businessLicense: file })}
          />
        </div>

        {/* Error */}
        {error && <p className="text-red-500 text-sm">{error}</p>}

        {/* Submit Button */}
        <div className="pt-4 flex justify-end sm:max-w-md">
          <button
            type="submit"
            className="bg-orange-500 hover:bg-orange-600 text-white px-5 sm:px-6 py-2 rounded-md flex items-center space-x-2 text-sm sm:text-base"
          >
            <span>Save and Continue</span>
            <span>→</span>
          </button>
        </div>
      </form>
    </div>
  );
}
