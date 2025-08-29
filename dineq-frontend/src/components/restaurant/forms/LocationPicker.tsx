"use client";

import { useState } from "react";
import { FaMapMarkerAlt } from "react-icons/fa";

type LocationPickerProps = {
  value: string;
  onChange: (location: string) => void;
};

export default function LocationPicker({ value, onChange }: LocationPickerProps) {
  const [error, setError] = useState("");

  const handleLocationFetch = () => {
    if (!navigator.geolocation) {
      setError("Geolocation is not supported by your browser.");
      return;
    }

    navigator.geolocation.getCurrentPosition(
      (position) => {
        const coords = `${position.coords.latitude}, ${position.coords.longitude}`;
        onChange(coords);
        setError("");
      },
      () => {
        setError("Unable to retrieve your location.");
      }
    );
  };

  return (
    <div className="max-w-xl space-y-1">
      <label className="block text-lg font-medium text-gray-700">
        Location (auto-filled)
      </label>
      <div className="relative">
        <input
          type="text"
          value={value}
          readOnly
          placeholder="Latitude, Longitude"
          className="w-full pl-3 pr-4 py-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-orange-500 focus:border-orange-500 text-sm bg-gray-50 cursor-not-allowed"
        />
        <FaMapMarkerAlt className="absolute right-3 top-4 text-gray-400" />
      </div>
      <button
        type="button"
        onClick={handleLocationFetch}
        className="text-sm text-orange-600 hover:underline"
      >
        📍 Use my current location
      </button>
      {error && <p className="text-sm text-red-500 font-medium">{error}</p>}
    </div>
  );
}
