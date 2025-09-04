import React from "react";

export function RestaurantCardSkeleton() {
  return (
    <div className="border border-[var(--color-primary)] rounded-lg p-2 animate-pulse">
      <div className="relative w-full h-40 md:h-44 rounded-lg bg-gray-200" />
      <div className="pt-2 pb-3 space-y-2">
        <div className="h-5 bg-gray-200 rounded w-3/4" />
        <div className="h-4 bg-gray-200 rounded w-full" />
        <div className="h-4 bg-gray-200 rounded w-5/6" />
        <div className="flex items-center gap-2 pt-2">
          <div className="h-4 w-24 bg-gray-200 rounded" />
          <div className="h-4 w-8 bg-gray-200 rounded" />
        </div>
      </div>
    </div>
  );
}

export function RestaurantDetailSkeleton() {
  return (
    <div className="flex flex-col items-center px-4 sm:px-6 md:px-8 pb-8 animate-pulse">
      <div className="w-full max-w-5xl h-40 sm:h-52 md:h-64 rounded-lg bg-gray-200 mt-4" />
      <div className="w-full max-w-5xl bg-gray-100 p-5 rounded-lg mt-5">
        <div className="space-y-3">
          <div className="h-7 bg-gray-200 rounded w-1/2" />
          <div className="h-5 bg-gray-200 rounded w-24" />
          <div className="h-4 bg-gray-200 rounded w-full" />
          <div className="h-4 bg-gray-200 rounded w-5/6" />
        </div>
        <div className="mt-6 space-y-3">
          <div className="h-5 bg-gray-200 rounded w-1/3" />
          <div className="h-5 bg-gray-200 rounded w-1/4" />
        </div>
      </div>
    </div>
  );
}
