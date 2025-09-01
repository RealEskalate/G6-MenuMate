"use client";

import { useRouter } from "next/navigation";
import { Pencil, FileText } from "lucide-react";
import { useRegister } from "@/context/RegisterContext";

export default function ReviewPage() {
  const router = useRouter();
  const { data } = useRegister();

  const basicInfo = {
    "Restaurant Name": data.restaurant,
    "Phone Number": data.phone,
    Location: data.address,
  };

  const documents = data.businessLicense ? [data.businessLicense] : [];

  const handleSubmit = async () => {
    // try {
    //   const response = await fetch("/api/register", {
    //     method: "POST",
    //     headers: {
    //       "Content-Type": "application/json",
    //     },
    //     body: JSON.stringify(data),
    //   });

    //   if (!response.ok) {
    //     throw new Error("Failed to submit");
    //   }

    //   alert("Form submitted successfully!");
    //   router.push("/thank-you"); // or wherever after submission
    // } catch (error) {
    //   alert("Error submitting form. Please try again.");
    //   console.error(error);
    // }
  };

  return (
    <div className="flex-1 pl-16 py-16">
      <div className="max-w-3xl mx-auto">
        <div className="">
          <h1 className="text-2xl font-semibold">Review & Submit</h1>
        </div>
        <p className="text-gray-600 mt-1 mb-4">
          Please review and submit your information.
        </p>

        <section className="mb-10">
          <h2 className="text-lg font-semibold mb-4">Restaurant Information</h2>
          <div className="space-y-4 max-w-xl">
            {Object.entries(basicInfo).map(([key, value]) => (
              <div
                key={key}
                className="flex items-center justify-between border border-gray-300 rounded-lg px-4 py-2 bg-white"
              >
                <span className="text-gray-700">{value || "-"}</span>
                <button
                  className="text-gray-500 hover:text-gray-700"
                  onClick={() => router.push("/register/basic-info")}
                >
                  <Pencil className="w-4 h-4" />
                </button>
              </div>
            ))}
          </div>
        </section>

        <section>
          <h2 className="text-lg font-semibold mb-4">Business License</h2>
          <div className="space-y-3 max-w-xl">
            {documents.length === 0 && (
              <p className="text-gray-500 italic">No documents uploaded.</p>
            )}
            {documents.map((doc, idx) => (
              <div
                key={idx}
                className="flex items-center justify-between bg-green-50 border border-green-200 px-4 py-2 rounded"
              >
                <div className="flex items-center space-x-2">
                  <FileText className="w-5 h-5 text-red-500" />
                  <div>
                    <p className="text-gray-700 text-sm">{doc.name}</p>
                    <p className="text-xs text-gray-400">{doc.size} MB</p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </section>

        <div className="flex justify-between mt-10">
          <button
            onClick={() => router.push("/register/basic-info")}
            className="px-4 py-2 rounded-md border border-gray-300 text-gray-700 hover:bg-gray-100"
          >
            ← Back
          </button>
          <button
            onClick={handleSubmit}
            className="px-6 py-2 rounded-md bg-orange-500 text-white hover:bg-orange-600"
          >
            Submit →
          </button>
        </div>
      </div>
    </div>
  );
}
