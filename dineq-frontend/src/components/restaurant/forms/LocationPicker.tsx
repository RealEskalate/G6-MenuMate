
"use client";

import { useState, useEffect } from "react";
import { FaMapMarkerAlt } from "react-icons/fa";

type LocationPickerProps = {
  value: string; // "latitude, longitude"
  onChange: (location: string) => void;
  compact?: boolean;
};

export default function LocationPicker({
  value,
  onChange,
  compact = false,
}: LocationPickerProps) {
  const [error, setError] = useState("");
  const [userChoice, setUserChoice] = useState<"current" | null>(null);

  
  useEffect(() => {
    if (value) {
      if (!userChoice) {
        setUserChoice("current");
      }
    } else {
      setUserChoice(null);
    }
  }, [value]);

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
        setUserChoice("current");
      },
      (err) => {
        console.error("Geolocation error:", err);
        setError("Unable to retrieve your location.");
      }
    );
  };

  const handleClearSelection = () => {
    onChange("");
    setUserChoice(null);
    setError("");
  };

  return (
    <div className={`${compact ? "space-y-1" : "space-y-2"}`}>
      <label
        className={`block ${
          compact ? "text-md" : "text-lg"
        } font-medium text-gray-700`}
      >
        Location
      </label>
      <div className="relative">
        <input
          type="text"
          value={value}
          readOnly
          placeholder="Latitude, Longitude"
          className={`w-full pl-3 pr-4 border border-gray-300 rounded-md focus:ring-2 focus:ring-orange-500 focus:border-orange-500 text-sm bg-gray-50 cursor-not-allowed ${
            compact ? "py-2" : "py-3"
          }`}
        />
        <FaMapMarkerAlt
          className={`absolute right-3 text-gray-400 ${
            compact ? "top-2.5" : "top-3.5"
          }`}
        />
      </div>

      <div className="flex gap-4">
        <button
          type="button"
          onClick={handleLocationFetch}
          className={`text-orange-600 hover:underline ${
            compact ? "text-xs" : "text-sm"
          } ${userChoice === "current" ? "font-bold" : ""}`}
        >
          📍 Use my current location
        </button>
      </div>

      {value && (
        <button
          type="button"
          onClick={handleClearSelection}
          className={`text-gray-500 hover:underline ${
            compact ? "text-xs" : "text-sm"
          }`}
        >
          Clear Location Selection
        </button>
      )}

      {error && (
        <p
          className={`text-red-500 font-medium ${
            compact ? "text-xs" : "text-sm"
          }`}
        >
          {error}
        </p>
      )}
    </div>
  );
}
