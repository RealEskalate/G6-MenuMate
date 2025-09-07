"use client";

import React, {
  useState,
  useEffect,
  useCallback,
  useRef,
  ChangeEvent,
} from "react";
import { useSession } from "next-auth/react";
import {
  getMyRestaurantProfile,
  updateRestaurantProfile,
} from "../../../../../lib/restaurant_setting_api";

// === TYPE DEFINITION ===
type LegalData = {
  verification_docs: string | null; // The URL from the API
};

// === HELPER FUNCTION ===
// A small utility to get the filename from a URL
const getFilenameFromUrl = (url: string): string => {
  try {
    return url.split("/").pop()?.split("?")[0] || "document.pdf";
  } catch {
    return "document.pdf";
  }
};

const LegalInfoSettings = () => {
  const { data: session, status: sessionStatus } = useSession();

  const [legalData, setLegalData] = useState<LegalData | null>(null);
  const [slug, setSlug] = useState<string | null>(null); // To store the slug for updates
  const [isLoading, setIsLoading] = useState(true);
  const [savingStatus, setSavingStatus] = useState<
    "idle" | "saving" | "saved" | "error"
  >("idle");

  // A ref to programmatically click the hidden file input
  const fileInputRef = useRef<HTMLInputElement>(null);

  // === DATA FETCHING ===
  useEffect(() => {
    if (sessionStatus === "authenticated" && session?.accessToken) {
      getMyRestaurantProfile(session.accessToken)
        .then((apiData) => {
          console.log("fetching legal info");
          if (apiData) {
            const restaurant = apiData;
            setSlug(restaurant.slug);
            setLegalData({
              verification_docs: restaurant.verification_docs || null,
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
    async (updates: Record<string, any>) => {
      if (!slug || !session?.accessToken) return;
      setSavingStatus("saving");
      try {
        const updatedData = await updateRestaurantProfile(
          slug,
          session.accessToken,
          updates
        );
        // Sync local state with the confirmed data from the server
        setLegalData((prev) => (prev ? { ...prev, ...updatedData } : null));
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

  const handleFileChange = (e: ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      // Optimistically update the UI to show the new filename
      setLegalData((prev) =>
        prev ? { ...prev, verification_docs: file.name } : null
      );
      // Trigger the upload and save
      handleAutosave({ verification_docs: file });
    }
  };

  const handleDeleteLicense = () => {
    if (window.confirm("Are you sure you want to delete this license?")) {
      // Sending `null` tells the backend to delete the file
      handleAutosave({ verification_docs: null });
      setLegalData((prev) =>
        prev ? { ...prev, verification_docs: null } : null
      );
    }
  };

  // === RENDER LOGIC ===
  if (isLoading || sessionStatus === "loading")
    return <div className="p-4">Loading legal info...</div>;
  if (!legalData)
    return (
      <div className="p-4 text-red-500">Could not load legal information.</div>
    );

  return (
    <div className="flex flex-col gap-8">
      <div className="flex justify-between items-center">
        <h2 className="text-2xl font-bold">Legal Info</h2>
        <div className="text-sm text-gray-500 h-5">
          {savingStatus === "saving" && "Saving..."}
          {savingStatus === "saved" && "✓ Changes saved"}
          {savingStatus === "error" && "✗ Error saving"}
        </div>
      </div>

      {/* Business License Section */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Business License
        </label>
        {legalData.verification_docs ? (
          // Display when a document exists
          <div className="flex items-center justify-between border rounded-lg border-gray-300 p-3 max-w-md">
            <span className="text-sm text-gray-800 truncate">
              {getFilenameFromUrl(legalData.verification_docs)}
            </span>
            <div className="flex items-center gap-3">
              <a
                href={legalData.verification_docs}
                target="_blank"
                rel="noopener noreferrer"
                className="text-gray-500 hover:text-blue-600"
                title="View Document"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  className="h-5 w-5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                  />
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"
                  />
                </svg>
              </a>
              <button
                onClick={handleDeleteLicense}
                className="text-gray-500 hover:text-red-600"
                title="Delete Document"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  className="h-5 w-5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                  />
                </svg>
              </button>
            </div>
          </div>
        ) : (
          // Display when no document exists
          <div className="text-sm text-gray-500 p-3 border border-dashed rounded-lg max-w-md">
            No business license uploaded.
          </div>
        )}
      </div>

      {/* Hidden file input and the visible upload button */}
      <input
        type="file"
        ref={fileInputRef}
        onChange={handleFileChange}
        className="hidden"
        accept=".pdf,.jpg,.jpeg,.png"
      />
      <button
        onClick={() => fileInputRef.current?.click()}
        className="bg-orange-500 text-white px-5 py-2 rounded-lg w-fit text-sm font-semibold hover:bg-orange-600 transition-colors"
      >
        {legalData.verification_docs ? "Upload New License" : "Upload License"}
      </button>
    </div>
  );
};

export default LegalInfoSettings;
