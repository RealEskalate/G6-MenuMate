// src/app/user/Restaurants.tsx
"use client";
import React, { useEffect, useMemo, useState } from "react";
import RestaurantCard from "@/app/user/RestaurantCard";
import { useDispatch, useSelector } from "react-redux";
import { fetchRestaurants, ApiRestaurant } from "@/store/restaurantsSlice";
import { RootState, AppDispatch } from "@/store/store";
import { Search } from "lucide-react";
import { RestaurantCardSkeleton } from "@/components/common/LoadingSkeletons";
import { Restaurant } from "@/Types/restaurants";

const Restaurants = () => {
  const dispatch = useDispatch<AppDispatch>();
  const { restaurants, loading, error } = useSelector((state: RootState) => state.restaurants);

  const [query, setQuery] = useState("");
  const [debouncedQuery, setDebouncedQuery] = useState("");

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedQuery(query);
    }, 300);
    return () => clearTimeout(handler);
  }, [query]);

  useEffect(() => {
    dispatch(fetchRestaurants({ page: 1, pageSize: 20 }));
  }, [dispatch]);

  const normalizedRestaurants = useMemo<Restaurant[]>(() => {
    return (restaurants || []).map((apiRestaurant: ApiRestaurant) => ({
      id: String(apiRestaurant.id),
      name: apiRestaurant.name ?? "Unnamed Restaurant",
      about: apiRestaurant.about ?? "",
      contact: { phone: apiRestaurant.phone ?? "", email: "" },
      averageRating: Number(apiRestaurant.average_rating ?? 0),
      logoImage: apiRestaurant.logo_image ?? "/Background.png",
      location: "",
    }));
  }, [restaurants]);

  const filteredRestaurants = useMemo(() => {
    if (!debouncedQuery.trim()) return normalizedRestaurants;
    const q = debouncedQuery.toLowerCase();
    return normalizedRestaurants.filter(
      (r) => r.name.toLowerCase().includes(q) || r.about.toLowerCase().includes(q)
    );
  }, [normalizedRestaurants, debouncedQuery]);

  const nearbyRestaurants = useMemo(() => {
    return [...filteredRestaurants]
      .sort((a, b) => b.averageRating - a.averageRating)
      .slice(0, Math.min(6, filteredRestaurants.length));
  }, [filteredRestaurants]);

  const allButNearby = useMemo(() => {
    const nearbyIds = new Set(nearbyRestaurants.map((r) => r.id));
    return filteredRestaurants.filter((r) => !nearbyIds.has(r.id));
  }, [filteredRestaurants, nearbyRestaurants]);

  // Loading / Error states
  if (loading) return (
    <div className="w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 border border-gray-200 rounded-lg p-6 my-8">
      <div className="w-full mt-4 mb-6 flex justify-center">
        <div className="w-full max-w-xl relative">
          <div className="h-10 bg-gray-200 rounded-md animate-pulse" />
        </div>
      </div>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        {Array.from({ length: 6 }).map((_, i) => (
          <RestaurantCardSkeleton key={i} />
        ))}
      </div>
    </div>
  );
  if (error) return <div className="flex justify-center p-8 text-red-600">Failed to load restaurants: {error}</div>;
  if (!normalizedRestaurants.length) return (
    <div className="w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col items-center justify-center min-h-[50vh]">
      <div className="text-center">
        <h2 className="text-2xl font-bold text-gray-700">No Restaurants Found</h2>
        <p className="text-gray-500 mt-2">There are no restaurants available at the moment.</p>
      </div>
    </div>
  );

  return (
    <div className="w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 border border-gray-200 rounded-lg bg-gray-50">
      {/* Sticky Search Bar */}
      <div className="w-full sticky top-0 bg-gray-50 z-10 py-4 -mt-4 mb-6">
        <div className="w-full flex justify-center">
          <div className="w-full max-w-xl relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
            <input
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Search for restaurants..."
              className="w-full rounded-full border border-gray-300 pl-10 pr-4 py-2 text-gray-700 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[var(--color-primary)] focus:border-transparent transition-all duration-300"
            />
          </div>
        </div>
      </div>

      {/* Nearby Restaurants Section */}
      <section className="mb-10">
        <h2 className="text-2xl font-bold text-gray-800 mb-6">Top Rated Restaurants</h2>
        {nearbyRestaurants.length === 0 ? (
          <div className="text-gray-500 text-center">No top-rated restaurants match your search.</div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
            {nearbyRestaurants.map((r) => (
              <RestaurantCard key={`nearby-${r.id}`} {...r} />
            ))}
          </div>
        )}
      </section>

      {/* All Restaurants Section */}
      <section className="mb-8">
        <h2 className="text-2xl font-bold text-gray-800 mb-6">All Restaurants</h2>
        {allButNearby.length === 0 ? (
          <div className="text-gray-500 text-center">No other restaurants match your search.</div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
            {allButNearby.map((r) => (
              <RestaurantCard key={r.id} {...r} />
            ))}
          </div>
        )}
      </section>
    </div>
  );
};

export default Restaurants;