// src/components/common/LoadingSkeletons.tsx
import React from "react";

export function RestaurantCardSkeleton() {
  return (
    <div className="relative bg-white rounded-xl shadow-md overflow-hidden animate-pulse border border-gray-200">
      {/* Skeleton Image with Gradient Effect */}
      <div className="relative w-full h-48 bg-gray-200 rounded-t-xl">
        <div className="absolute inset-0 bg-gradient-to-t from-gray-300/60 to-transparent"></div>
      </div>

      {/* Skeleton Info */}
      <div className="p-4 space-y-3">
        <div className="h-6 bg-gray-200 rounded-md w-3/4" />
        <div className="h-4 bg-gray-200 rounded-md w-full" />
        <div className="h-4 bg-gray-200 rounded-md w-5/6" />
        <div className="flex items-center gap-2 pt-2">
          <div className="h-4 w-24 bg-gray-200 rounded-md" />
          <div className="h-4 w-8 bg-gray-200 rounded-md" />
        </div>
      </div>

      {/* Action Button Skeleton */}
      <div className="absolute top-4 right-4 h-8 w-8 bg-gray-200 rounded-full" />
    </div>
  );
}

export function RestaurantDetailSkeleton() {
  return (
    <div className="animate-pulse w-full max-w-5xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
      {/* Header Skeleton */}
      <div className="relative w-full h-64 sm:h-80 bg-gray-200 rounded-2xl overflow-hidden shadow-xl" />
      
      {/* Menu Tabs Skeleton */}
      <div className="mt-8 flex gap-4 overflow-x-auto pb-2">
        <div className="flex-shrink-0 w-24 h-10 bg-gray-200 rounded-full" />
        <div className="flex-shrink-0 w-28 h-10 bg-gray-200 rounded-full" />
        <div className="flex-shrink-0 w-32 h-10 bg-gray-200 rounded-full" />
      </div>

      {/* Menu Items Grid Skeleton */}
      <div className="mt-8 bg-white p-6 rounded-2xl shadow-xl">
        <div className="h-8 w-48 bg-gray-200 rounded-md mb-6" />
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
          {Array.from({ length: 6 }).map((_, i) => (
            <div key={i} className="relative bg-white rounded-2xl shadow-lg overflow-hidden">
              <div className="relative w-full h-48 bg-gray-200 rounded-t-2xl" />
              <div className="p-4 space-y-2">
                <div className="h-5 bg-gray-200 rounded w-3/4" />
                <div className="h-4 bg-gray-200 rounded w-1/2" />
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}