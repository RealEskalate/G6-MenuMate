// app/register/review/page.tsx
"use client";

import { useRouter } from "next/navigation";
import { Pencil, Eye, Trash2, FileText } from "lucide-react";

export default function ReviewPage() {
  const router = useRouter();

  // Mocked data (replace with props or context later)
  const basicInfo = {
    name: "Yohannes Tamirat",
    email: "yohannesT@gmail.com",
    restaurant: "yohannes Restaurant",
    address: "Addis Ababa, Ethiopia",
  };

  const documents = [
    { name: "business-license.pdf", size: 2.3 },
    { name: "Food-safety-certificate.pdf", size: 2.3 },
    { name: "Tax ID / EIN Certificate.png", size: 2.3 },
    { name: "Liquor License.pdf", size: 2.3 },
  ];

  return (
    <div className="flex-1  p-8">
      <div className="max-w-3xl mx-auto">
        {/* Title */}
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-2xl font-semibold">Review & Submit</h1>
          <p className="text-gray-500 text-sm">Step 3 of 3</p>
        </div>
        <p className="text-gray-600 mb-8">
          Please review and submit your information.
        </p>

        {/* Basic Information */}
        <section className="mb-10">
          <h2 className="text-lg font-semibold mb-4">Basic Information</h2>
          <div className="space-y-4 max-w-md">
            {Object.entries(basicInfo).map(([key, value]) => (
              <div
                key={key}
                className="flex items-center justify-between border border-gray-300 rounded-lg px-4 py-2 bg-white"
              >
                <span className="text-gray-700">{value}</span>
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

        {/* Legal Documents */}
        <section>
          <h2 className="text-lg font-semibold mb-4">Legal Documents</h2>
          <div className="space-y-3 max-w-md">
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
                <div className="flex space-x-3">
                  <button className="text-gray-500 hover:text-gray-700">
                    <Eye className="w-4 h-4" />
                  </button>
                  <button className="text-red-500 hover:text-red-700">
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </section>

        {/* Buttons */}
        <div className="flex justify-between mt-10">
          <button
            onClick={() => router.push("/register/legal-documents")}
            className="px-4 py-2 rounded-md border border-gray-300 text-gray-700 hover:bg-gray-100"
          >
            ← Back
          </button>
          <button
            onClick={() => alert("Form Submitted!")}
            className="px-6 py-2 rounded-md bg-orange-500 text-white hover:bg-orange-600"
          >
            Submit →
          </button>
        </div>
      </div>
    </div>
  );
}
