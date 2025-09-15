"use client";

import React, { useState, useEffect, useCallback, ChangeEvent } from "react";
import { useSession } from "next-auth/react";
import {
  getMyRestaurantProfile,
  updateRestaurantProfile,
} from "../../../../../lib/restaurant_setting_api";

// === TYPE DEFINITION ===
type BrandingData = {
  primary_color: string;
  accent_color: string;
  default_currency: string;
  default_language: string;
  default_vat: number | string; // Use string for input, number for API
};

const BrandingSettings = () => {
  const { data: session, status: sessionStatus } = useSession();

  const [brandingData, setBrandingData] = useState<BrandingData | null>(null);
  const [slug, setSlug] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [savingStatus, setSavingStatus] = useState<
    "idle" | "saving" | "saved" | "error"
  >("idle");

  // === DATA FETCHING ===
  useEffect(() => {
    if (sessionStatus === "authenticated" && session?.accessToken) {
      getMyRestaurantProfile(session.accessToken)
        .then((apiData) => {
          if (apiData) {
            const restaurant = apiData;
            setSlug(restaurant.slug);
            setBrandingData({
              primary_color: restaurant.primary_color || "#000000",
              accent_color: restaurant.accent_color || "#FFFFFF",
              default_currency: restaurant.default_currency || "USD",
              default_language: restaurant.default_language || "English",
              default_vat: restaurant.default_vat || 0,
            });
          }
        })
        .catch(() => setSavingStatus("error"))
        .finally(() => setIsLoading(false));
    }
    if (sessionStatus === "unauthenticated") setIsLoading(false);
  }, [sessionStatus, session]);

  // === UPDATE HANDLER ===
  const handleAutosave = useCallback(
    async (updates: Partial<BrandingData>) => {
      if (!slug || !session?.accessToken) return;
      setSavingStatus("saving");
      try {
        const updatedData = await updateRestaurantProfile(
          slug,
          session.accessToken,
          updates
        );
        // Sync local state with the confirmed data from the server
        setBrandingData((prev) => (prev ? { ...prev, ...updatedData } : null));
        setSavingStatus("saved");
      } catch (error) {
        setSavingStatus("error");
      } finally {
        setTimeout(() => setSavingStatus("idle"), 2000);
      }
    },
    [slug, session]
  );

  // === EVENT HANDLERS ===
  const handleInputChange = (
    e: ChangeEvent<HTMLInputElement | HTMLSelectElement>
  ) => {
    const { name, value } = e.target;
    if (brandingData) {
      setBrandingData({ ...brandingData, [name]: value });
    }
  };

  // For dropdowns, we save on change for a better UX
  const handleSelectChangeAndSave = (e: ChangeEvent<HTMLSelectElement>) => {
    const { name, value } = e.target;
    if (brandingData) {
      setBrandingData({ ...brandingData, [name]: value });
      handleAutosave({ [name]: value });
    }
  };

  // === RENDER LOGIC ===
  if (isLoading || sessionStatus === "loading")
    return <div className="p-4">Loading branding settings...</div>;
  if (!brandingData)
    return (
      <div className="p-4 text-red-500">
        Could not load branding information.
      </div>
    );

  return (
    <div className="flex flex-col gap-8">
      <div className="flex justify-between items-center">
        <h2 className="text-2xl font-bold">Branding & Preferences</h2>
        <div className="text-sm text-gray-500 h-5">
          {savingStatus === "saving" && "Saving..."}
          {savingStatus === "saved" && "✓ Changes saved"}
          {savingStatus === "error" && "✗ Error saving"}
        </div>
      </div>

      {/* Branding Section */}
      <div>
        <h3 className="text-lg font-semibold mb-4 text-gray-800">Colors</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
          <div>
            <label
              htmlFor="primary_color"
              className="block text-sm font-medium text-gray-700 mb-2"
            >
              Primary Color
            </label>
            <div className="flex items-center gap-2">
              <input
                id="primary_color_picker"
                type="color"
                value={brandingData.primary_color}
                onChange={handleInputChange}
                onBlur={() =>
                  handleAutosave({ primary_color: brandingData.primary_color })
                }
                className="p-1 h-10 w-10 border border-gray-300 rounded-lg cursor-pointer"
              />
              <input
                id="primary_color"
                name="primary_color"
                type="text"
                value={brandingData.primary_color}
                onChange={handleInputChange}
                onBlur={() =>
                  handleAutosave({ primary_color: brandingData.primary_color })
                }
                className="w-full border border-gray-300 rounded-lg px-3 py-2"
              />
            </div>
          </div>
          <div>
            <label
              htmlFor="accent_color"
              className="block text-sm font-medium text-gray-700 mb-2"
            >
              Accent Color
            </label>
            <div className="flex items-center gap-2">
              <input
                id="accent_color_picker"
                type="color"
                value={brandingData.accent_color}
                onChange={handleInputChange}
                onBlur={() =>
                  handleAutosave({ accent_color: brandingData.accent_color })
                }
                className="p-1 h-10 w-10 border border-gray-300 rounded-lg cursor-pointer"
              />
              <input
                id="accent_color"
                name="accent_color"
                type="text"
                value={brandingData.accent_color}
                onChange={handleInputChange}
                onBlur={() =>
                  handleAutosave({ accent_color: brandingData.accent_color })
                }
                className="w-full border border-gray-300 rounded-lg px-3 py-2"
              />
            </div>
          </div>
        </div>
      </div>

      {/* Menu Preferences Section */}
      <div>
        <h3 className="text-lg font-semibold mb-4 text-gray-800">
          Menu Preferences
        </h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
          <div>
            <label
              htmlFor="default_currency"
              className="block text-sm font-medium text-gray-700 mb-2"
            >
              Default Currency
            </label>
            <select
              id="default_currency"
              name="default_currency"
              value={brandingData.default_currency}
              onChange={handleSelectChangeAndSave}
              className="w-full border border-gray-300 rounded-lg px-3 py-2"
            >
              <option>ETB</option>
              <option>USD</option>
              <option>EUR</option>
              <option>KES</option>
            </select>
          </div>
          <div>
            <label
              htmlFor="default_language"
              className="block text-sm font-medium text-gray-700 mb-2"
            >
              Default Language
            </label>
            <select
              id="default_language"
              name="default_language"
              value={brandingData.default_language}
              onChange={handleSelectChangeAndSave}
              className="w-full border border-gray-300 rounded-lg px-3 py-2"
            >
              <option>English</option>
              <option>Amharic</option>
              <option>French</option>
              <option>Swahili</option>
            </select>
          </div>
          <div className="sm:col-span-2">
            <label
              htmlFor="default_vat"
              className="block text-sm font-medium text-gray-700 mb-2"
            >
              Default VAT/Service Charge (%)
            </label>
            <input
              id="default_vat"
              name="default_vat"
              type="number"
              value={brandingData.default_vat}
              onChange={handleInputChange}
              onBlur={() =>
                handleAutosave({
                  default_vat: Number(brandingData.default_vat),
                })
              }
              className="w-full border border-gray-300 rounded-lg px-3 py-2"
            />
          </div>
        </div>
      </div>
    </div>
  );
};

export default BrandingSettings;
