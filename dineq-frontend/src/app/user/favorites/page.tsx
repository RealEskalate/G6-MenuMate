"use client";

import React from "react";
import { useFavorites } from "@/context/FavoritesContext";
import RestaurantCard from "@/app/user/RestaurantCard";

export default function FavoritesPage() {
  const { favorites } = useFavorites();

  if (favorites.length === 0) {
    return (
      <p className="text-center p-8 text-gray-600">
        No favorite restaurants yet.
      </p>
    );
  }

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6 p-4">
      {favorites.map((restaurant) => (
        <RestaurantCard
          key={restaurant.id}
          id={restaurant.id}
          name={restaurant.name}
          logoImage={restaurant.logoImage}
          about={restaurant.about}
          averageRating={restaurant.averageRating}
          contact={restaurant.contact}
          location={restaurant.location}
        />
      ))}
    </div>
  );
}
