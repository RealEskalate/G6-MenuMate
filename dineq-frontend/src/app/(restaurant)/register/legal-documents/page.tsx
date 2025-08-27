"use client";

import { useRouter } from "next/navigation";
import LegalDocumentsForm from "@/components/restaurant/forms/LegalDocumentsForm";
export default function LegalDocumentsPage() {
  const router = useRouter();

  return (
    <div className="flex-1 p-3">
      <div className="max-w-3xl ">
        <h1 className="text-2xl font-semibold text-black mb-2">
          Upload Your Legal Documents
        </h1>
        <p className="text-gray-800 mb-6">
          Please upload required documents to verify your restaurant. Accepted formats: PDF, JPG, PNG (max 10MB each)
        </p>

        {/* Form Component */}
        <LegalDocumentsForm />

        {/* Buttons */}
        <div className="flex justify-between mt-8">
          <button
            onClick={() => router.push("/register/basic-info")}
            className="px-4 py-2 rounded-md border border-gray-300 text-gray-700 hover:bg-gray-100"
          >
            ← Back
          </button>
          <div className="space-x-3">
            <button
              className="px-4 py-2 rounded-md border border-gray-300 text-gray-700 hover:bg-gray-100"
            >
              Skip for now
            </button>
            <button
              onClick={() => router.push("/register/review")}
              className="px-6 py-2 rounded-md bg-orange-500 text-white hover:bg-orange-600"
            >
              Save and Continue →
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
