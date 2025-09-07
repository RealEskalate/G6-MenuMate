"use client";

import { useRouter } from "next/navigation";
import { ArrowLeft } from "lucide-react"; // using Lucide for the icon
import React from "react";

interface BackButtonProps {
  className?: string;
}

export default function BackButton({ className = "" }: BackButtonProps) {
  const router = useRouter();

  return (
    <button
      type="button"
      onClick={() => router.back()}
      className={`w-10 h-10 flex items-center justify-center rounded-full bg-orange-500 text-white hover:bg-orange-600 transition focus:outline-none focus:ring-2 focus:ring-orange-500 ${className}`}
    >
      <ArrowLeft className="w-5 h-5" />
    </button>
  );
}
