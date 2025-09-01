"use client";

import { useRegister } from "@/context/RegisterContext";
import { useRouter } from "next/navigation";
import { FaStore, FaPhoneAlt } from "react-icons/fa";
import React, { useState, useEffect } from "react";
import LocationPicker from "./LocationPicker";
import FileUploadBox, { UploadedFile } from "./FileUploadBox";

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
    <div className="pl-16 py-16"> 
    <div className="flex justify-between items-center mb-4 ">
        <h2 className="text-2xl font-semibold text-gray-900">Restaurant Information</h2>
      </div>
    <form className="space-y-5 " onSubmit={handleSubmit}>
      <div className="max-w-xl">
        <label className="block text-lg font-medium text-gray-700 mb-2">
          Restaurant Name
        </label>
        <div className="relative">
          <input
            type="text"
            value={data.restaurant}
            onChange={(e) => updateData({ restaurant: e.target.value })}
            placeholder="Enter restaurant name"
            className="w-full pl-3 pr-4 py-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-orange-500 focus:border-orange-500 text-sm"
          />
          <FaStore className="absolute right-3 top-4 text-gray-400" />
        </div>
      </div>

      <div className="max-w-xl">
        <label className="block text-lg font-medium text-gray-700 mb-2">
          Phone Number
        </label>
        <div className="relative">
          <input
            type="tel"
            value={data.phone}
            onChange={(e) => updateData({ phone: e.target.value })}
            placeholder="Enter phone number"
            className="w-full pl-3 pr-4 py-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-orange-500 focus:border-orange-500 text-sm"
          />
          <FaPhoneAlt className="absolute right-3 top-4 text-gray-400" />
        </div>
      </div>

      <LocationPicker value={location} onChange={(v) => updateData({ address: v })} />

      <FileUploadBox
        label="Business License"
        required
        file={businessLicense}
        onFileChange={(file) => updateData({ businessLicense: file })}
      />

      {error && <p className="text-red-500 text-sm">{error}</p>}

      <div className="pt-6 flex justify-end mt-10">
        <button
          type="submit"
          className="bg-orange-500 hover:bg-orange-600 text-white px-6 py-2 rounded-md flex items-center space-x-2"
        >
          <span>Save and Continue</span>
          <span>→</span>
        </button>
      </div>
    </form>
    </div>
  );
}
