"use client";

import { CheckCircle } from "lucide-react";
import Link from "next/link";

export default function SuccessPage() {
  return (
    <div className="w-screen h-screen bg-gray-100 overflow-hidden flex items-center justify-center">
      <div className="bg-white rounded-xl shadow-md p-6 sm:p-8 md:p-10 text-center w-full max-w-md">
        <CheckCircle className="mx-auto h-12 w-12 sm:h-14 sm:w-14 md:h-16 md:w-16 text-green-500" />

        <h1 className="mt-6 text-xl sm:text-2xl md:text-3xl font-bold text-gray-800 font-headings">
          Your request is submitted successfully!
        </h1>

        <p className="mt-3 text-sm sm:text-base text-gray-600 leading-relaxed">
          We will contact you through your email after we review your
          documents. Feel free to explore our features until then.
        </p>

        <Link
          href="/"
          className="inline-block mt-6 bg-orange-500 hover:bg-orange-600 text-white px-4 sm:px-5 py-2 sm:py-2.5 rounded-lg transition text-sm sm:text-base"
        >
          Back to home
        </Link>
      </div>
    </div>
  );
}
