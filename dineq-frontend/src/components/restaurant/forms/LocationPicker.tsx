// components/LocationPicker.tsx
"use client";

import { useState, useEffect } from "react";
import { FaMapMarkerAlt } from "react-icons/fa";
import dynamic from "next/dynamic";
// Removed direct Leaflet import as it's not strictly needed here anymore,
// and can cause issues with SSR if not handled carefully.

const MapModal = dynamic(() => import("./MapModal"), {
  ssr: false,
  loading: () => (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center text-white z-50">
      Loading Map...
    </div>
  ),
});

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
  const [showMapModal, setShowMapModal] = useState(false);
  const [userChoice, setUserChoice] = useState<
    "current" | "map" | null
  >(null);
  const [tempInitialMapLocation, setTempInitialMapLocation] = useState<{
    lat: number;
    lng: number;
  } | undefined>(undefined);

  // Parse the current value into a {lat, lng} object for the map
  const parsedValue = value
    ? {
        lat: parseFloat(value.split(",")[0]?.trim()),
        lng: parseFloat(value.split(",")[1]?.trim()),
      }
    : undefined;

  // Effect to set userChoice based on initial `value` prop
  useEffect(() => {
    if (value) {
      // Assuming if value is present, it was either picked from current or map
      // We can't definitively know which, but for UI feedback, we can assume it's "map" if not explicitly "current"
      if (!userChoice) { // Only set if not already set by user action
          setUserChoice("map"); // Default visual to map if value exists but no explicit choice
      }
    } else {
      setUserChoice(null);
    }
  }, [value]); // Only re-run if 'value' changes

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
        setTempInitialMapLocation({ // Also update temp for map if they switch
            lat: position.coords.latitude,
            lng: position.coords.longitude,
        });
      },
      (err) => {
        console.error("Geolocation error:", err);
        setError("Unable to retrieve your location.");
      }
    );
  };

  const handleMapSelectLocation = (location: { lat: number; lng: number }) => {
    onChange(`${location.lat}, ${location.lng}`);
    setUserChoice("map");
    setTempInitialMapLocation(location); // Update temp location so map remembers last picked spot
  };

  const handleOpenMap = () => {
    // If a location is already set, use it.
    // Otherwise, try to get current location to set as initial map center.
    if (parsedValue) {
      setTempInitialMapLocation(parsedValue);
      setShowMapModal(true);
    } else if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          setTempInitialMapLocation({
            lat: position.coords.latitude,
            lng: position.coords.longitude,
          });
          setShowMapModal(true);
        },
        (err) => {
          console.warn("Could not get current location for map:", err);
          setError("Could not get current location for map. Opening map at default view.");
          setShowMapModal(true); // Open map even if location fails, it will default to 0,0
        }
      );
    } else {
      setError("Geolocation is not supported. Cannot get current location for map.");
      setShowMapModal(true); // Open map at default view
    }
  };

  const handleCloseMap = () => {
    setShowMapModal(false);
    // Optionally reset tempInitialMapLocation if you want map to always reopen from scratch
    // setTempInitialMapLocation(undefined);
  };

  const handleClearSelection = () => {
    onChange(""); // Clear the location
    setUserChoice(null); // Reset choice
    setError(""); // Clear any errors
    setTempInitialMapLocation(undefined); // Clear temp map location
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
        <button
          type="button"
          onClick={handleOpenMap}
          className={`text-orange-600 hover:underline ${
            compact ? "text-xs" : "text-sm"
          } ${userChoice === "map" ? "font-bold" : ""}`}
        >
          🗺️ Choose on map
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

      {/* Map Modal */}
      <MapModal
        isOpen={showMapModal}
        onClose={handleCloseMap}
        onSelectLocation={handleMapSelectLocation}
        initialLocation={tempInitialMapLocation || parsedValue} // Prefer temp if set, else parsedValue
      />
    </div>
  );
}