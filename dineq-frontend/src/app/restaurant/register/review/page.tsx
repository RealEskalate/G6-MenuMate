"use client";

import { useRouter } from "next/navigation";
import { Pencil, FileText, Image as ImageIcon, Tag } from "lucide-react";
import { useRegister } from "@/context/RegisterContext";
import Image from "next/image";

export default function ReviewPage() {
  const router = useRouter();
  const { data } = useRegister();

  const basicInfo = {
    "Restaurant Name": data.restaurant,
    "Phone Number": data.phone,
    Location: data.address,
    About: data.about || "-",
    Tags: data.tags && data.tags.length > 0 ? data.tags.join(", ") : "-",
  };

  const documents = data.businessLicense ? [data.businessLicense] : [];
  const logoImage = data.logo_image;

  const handleSubmit = async () => {
    // submission logic here (API call)
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
                <span className="text-gray-700 text-sm sm:text-base ">
                  {key}:{value}
                </span>
                <button
                  type="button"
                  className="text-gray-500 hover:text-gray-700"
                  onClick={() => router.push("/register/basic-info")}
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
          <div className="max-w-xl w-full">
            {!logoImage ? (
              <p className="text-gray-500 italic text-sm sm:text-base">
                No logo uploaded.
              </p>
            ) : (
              <div className="flex items-center space-x-3 border border-gray-300 rounded-lg px-3 sm:px-4 py-2 bg-white">
                <ImageIcon className="w-5 h-5 text-gray-500" />
                <Image
                  src={logoImage.url || "/placeholder.png"}
                  alt="Restaurant Logo"
                  width={60}
                  height={60}
                  className="rounded-md object-cover"
                />
              </div>
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
            className="w-full sm:w-auto px-5 sm:px-6 py-2 rounded-md bg-orange-500 text-white hover:bg-orange-600 text-sm sm:text-base"
          >
            Submit →
          </button>
        </div>
      </div>
    </div>
  );
}
