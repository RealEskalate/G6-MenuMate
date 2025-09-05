"use client";

import { useRouter } from "next/navigation";
import { Pencil, FileText, Image as ImageIcon } from "lucide-react";
import { useRegister } from "@/context/RegisterContext";
import { useState } from "react";
import { useSession } from "next-auth/react";

export default function ReviewPage() {
  const router = useRouter();
  const { data, resetData } = useRegister();
  const { data: session } = useSession(); 
  const tempToken =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NTY5MDE4NjAsImlzX3ZlcmlmaWVkIjpmYWxzZSwicm9sZSI6Ik1BTkFHRVIiLCJzdGF0dXMiOiJBQ1RJVkUiLCJzdWIiOiI2OGI2ZTUxMjhmNGY5NTJkOGEyYWI1ZTkiLCJ1c2VybmFtZSI6Im5hbmFudGkifQ.q7AusSduKNQ2gLSUUPP-tcMMUvG3VAGfMTqiwex4_HM";

  const basicInfo = {
    Name: data.name,
    Email: data.email,
    Restaurant: data.restaurant,
    Address: data.address,
    Phone: data.phone,
    About: data.about || "N/A",
    Tags: data.tags?.join(", ") || "None",
  };

  const logoFile = data.logo_image;
  const documents = data.businessLicense ? [data.businessLicense] : [];
  const bannerImage = data.cover_image;

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async () => {
    setLoading(true);
    setError(null);

    try {
      if (!session?.accessToken) {
        throw new Error("Unauthorized: No access token found");
      }

      const formData = new FormData();

      formData.append("restaurant_name", data.restaurant);
      formData.append("restaurant_phone", data.phone);
      formData.append("about", data.about || "");

      if (data.tags && data.tags.length > 0) {
        data.tags.forEach((tag: string) => {
          formData.append("tags", tag);
        });
      }

      // Append files
      if (logoFile?.file) formData.append("logo_image", logoFile.file);
      if (data.businessLicense?.file) formData.append("verification_docs", data.businessLicense.file);
      if (data.cover_image?.file) formData.append("cover_image", data.cover_image.file);

      const apiUrl = process.env.NEXT_PUBLIC_API_BASE_URL;
      const res = await fetch(`${apiUrl}/restaurants`, {
        method: "POST",
        body: formData,
        headers: {
          Authorization: `Bearer ${tempToken}`,
        },
      });

      const responseText = await res.text();
      let responseData;
      try {
          responseData = responseText ? JSON.parse(responseText) : {};
      } catch (error) {
          console.error("Failed to parse JSON response:", responseText);
          throw new Error("Received an invalid response from the server.");
      }

      if (!res.ok) {
        throw new Error(responseData.message || `Request failed with status ${res.status}`);
      }

      console.log("✅ Created restaurant:", responseData);

      resetData();
      router.push("/restaurant/success");
    } catch (err: unknown) {
      setError(
        typeof err === "object" && err !== null && "message" in err
          ? String((err as { message: unknown }).message)
          : "An unexpected error occurred"
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="px-4 sm:px-8 md:pl-16 py-10 md:py-16 w-full">
      <div className="max-w-3xl mx-auto">
        {/* Heading */}
        <h1 className="text-xl sm:text-2xl font-semibold text-left">
          Review & Submit
        </h1>
        <p className="text-gray-600 mt-2 mb-6 text-sm sm:text-base text-left">
          Please review and submit your information.
        </p>

        {/* Restaurant Info */}
        <section className="mb-10">
          <h2 className="text-xl sm:text-2xl font-semibold mb-4 text-left">
            Restaurant Information
          </h2>
          <div className="space-y-4 max-w-xl w-full">
            {Object.entries(basicInfo).map(([key, value]) => (
              <div
                key={key}
                className="flex items-center justify-between border border-gray-300 rounded-lg px-3 sm:px-4 py-2 bg-white"
              >
                <span className="text-gray-700 text-sm sm:text-base text-right ml-4 ">
                  {key}: {value}
                </span>
                <button
                  type="button"
                  className="text-gray-500 hover:text-gray-700 ml-2"
                  onClick={() => router.push("/restaurant/register/basic-info")}
                >
                  <Pencil className="w-4 h-4 sm:w-5 sm:h-5" />
                </button>
              </div>
            ))}
          </div>
        </section>

        {/* Logo Image */}
        <section className="mb-10">
          <h2 className="text-lg sm:text-xl font-semibold mb-4 text-left">
            Logo Image
          </h2>
          <div className="space-y-3 max-w-xl w-full">
            {logoFile?.file ? (
              <div className="flex items-center justify-between bg-green-50 border border-green-200 px-3 sm:px-4 py-2 rounded">
                <div className="flex items-center space-x-2">
                  <ImageIcon className="w-4 h-4 sm:w-5 sm:h-5 text-green-500" />
                  <div>
                    <p className="text-gray-700 text-sm">{logoFile.name}</p>
                    <p className="text-xs text-gray-400">{logoFile.size} MB</p>
                  </div>
                </div>
              </div>
            ) : (
              <p className="text-gray-500 italic text-sm sm:text-base">
                No logo uploaded.
              </p>
            )}
          </div>
        </section>
        

        {/* Banner Image */}
        <section className="mb-10">
          <h2 className="text-lg sm:text-xl font-semibold mb-4 text-left">
            Banner Image
          </h2>
          <div className="space-y-3 max-w-xl w-full">
            {bannerImage?.file ? (
              <div className="flex items-center justify-between bg-green-50 border border-green-200 px-3 sm:px-4 py-2 rounded">
                <div className="flex items-center space-x-2">
                  <ImageIcon className="w-4 h-4 sm:w-5 sm:h-5 text-green-500" />
                  <div>
                    <p className="text-gray-700 text-sm">{bannerImage.name}</p>
                    <p className="text-xs text-gray-400">{bannerImage.size} MB</p>
                  </div>
                </div>
              </div>
            ) : (
              <p className="text-gray-500 italic text-sm sm:text-base">
                No logo uploaded.
              </p>
            )}
          </div>
        </section>

        {/* Business License */}
        <section>
          <h2 className="text-lg sm:text-xl font-semibold mb-4 text-left">
            Business License
          </h2>
          <div className="space-y-3 max-w-xl w-full">
            {documents.length === 0 && (
              <p className="text-gray-500 italic text-sm sm:text-base">
                No documents uploaded.
              </p>
            )}
            {documents.map((doc, idx) => (
              <div
                key={idx}
                className="flex items-center justify-between bg-green-50 border border-green-200 px-3 sm:px-4 py-2 rounded"
              >
                <div className="flex items-center space-x-2">
                  <FileText className="w-4 h-4 sm:w-5 sm:h-5 text-red-500" />
                  <div>
                    <p className="text-gray-700 text-sm">{doc.name}</p>
                    <p className="text-xs text-gray-400">{doc.size} MB</p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </section>

        

        {/* Buttons */}
        <div className="flex flex-col sm:flex-row justify-between mt-10 space-y-3 sm:space-y-0 sm:space-x-4">
          <button
            type="button"
            onClick={() => router.push("/restaurant/register/basic-info")}
            className="w-full sm:w-auto px-4 py-2 rounded-md border border-gray-300 text-gray-700 hover:bg-gray-100 text-sm sm:text-base"
          >
            ← Back
          </button>
          <button
            type="button"
            onClick={handleSubmit}
            disabled={loading}
            className="w-full sm:w-auto px-5 sm:px-6 py-2 rounded-md bg-orange-500 text-white hover:bg-orange-600 text-sm sm:text-base"
          >
            {loading ? "Submitting..." : "Submit →"}
          </button>
        </div>
        {error && <p className="text-red-500 mt-4">{error}</p>}
      </div>
    </div>
  );
}
