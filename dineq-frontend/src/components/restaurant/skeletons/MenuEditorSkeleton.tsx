
"use client";

import { Skeleton } from "@/components/ui/Skeleton";

export default function MenuCardSkeleton() {
  return (
    <div className="relative w-full md:w-96 bg-white text-black rounded-xl border border-gray-200 p-4 shadow-md">
      {/* Header */}
      <div className="flex justify-between mb-2">
        <Skeleton className="h-6 w-28" />
        <div className="flex space-x-4">
          <Skeleton className="h-6 w-20 rounded-lg" />
          <Skeleton className="h-5 w-5 rounded-full" />
        </div>
      </div>

      {/* Dates */}
      <Skeleton className="h-4 w-48 mb-4" />

      {/* Empty boxes (Items + Avg rating) */}
      <div className="flex justify-between mt-6">
        <div className="space-y-2">
          <Skeleton className="h-16 w-32 rounded-md" />
          <Skeleton className="h-16 w-32 rounded-md" />
        </div>
        <Skeleton className="h-20 w-32 rounded-md" />
      </div>

      {/* Buttons */}
      <div className="flex justify-between mt-6">
        <Skeleton className="h-10 w-28 rounded-md" />
        <Skeleton className="h-10 w-32 rounded-md" />
      </div>
    </div>
  );
}
