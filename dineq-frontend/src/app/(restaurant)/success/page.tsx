"use client";

import NavBar from "@/components/restaurant/NavBar";
import { CheckCircle } from "lucide-react";
import Link from "next/link";

export default function SuccessPage() {
  return (
  <>
    <NavBar />
    <div className="flex items-center justify-center min-h-screen bg-gray-100">
      <div className="bg-white rounded-xl shadow-md p-10 text-center max-w-md w-full">
        {/* Icon */}
        <CheckCircle className="mx-auto h-16 w-16 text-green-500" />

        <h1 className="mt-6 text-2xl font-bold text-gray-800">
          Your request is submitted successfully!
        </h1>

        <p className="mt-3 text-gray-600">
          We will contact you through your email after we reviewed your
          documents. Feel free to explore our features until then.
        </p>

        {/* Button */}
        <Link
          href="/"
          className="inline-block mt-6 bg-orange-500 hover:bg-orange-600 text-white px-5 py-2 rounded-lg transition"
        >
          Back to home
        </Link>
      </div>
    </div>
    </>
  );
}
