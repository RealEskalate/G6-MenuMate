"use client";

import React, { createContext, useContext, useState, useEffect } from "react";

// Types
export interface Contact {
  phone: string;
  email: string;
}

export interface Restaurant {
  id: string;
  name: string;
  about: string;
  contact: Contact;
  averageRating: number;
  logoImage: string;
  location: string;
}

// This is what comes from your API
export interface ApiRestaurant {
  id: string;
  name: string;
  about?: string;
  phone?: string;
  email?: string;
  average_rating?: number;
  logo_image?: string;
  location?: string;
}

// Context value
interface FavoritesContextValue {
  favorites: Restaurant[];
  addFavorite: (restaurant: ApiRestaurant) => void;
  removeFavorite: (id: string) => void;
  isFavorite: (id: string) => boolean;
}

const FavoritesContext = createContext<FavoritesContextValue | undefined>(undefined);

export const FavoritesProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [favorites, setFavorites] = useState<Restaurant[]>([]);

  // Load from localStorage on mount
  useEffect(() => {
    const stored = localStorage.getItem("favorites");
    if (stored) setFavorites(JSON.parse(stored));
  }, []);

  // Save to localStorage whenever favorites change
  useEffect(() => {
    localStorage.setItem("favorites", JSON.stringify(favorites));
  }, [favorites]);

  // Map API restaurant to our Restaurant type
  const mapRestaurant = (restaurant: ApiRestaurant): Restaurant => ({
    id: restaurant.id,
    name: restaurant.name,
    about: restaurant.about || "",
    averageRating: restaurant.average_rating || 0,
    logoImage: restaurant.logo_image || "/Background.png",
    location: restaurant.location || "",
    contact: { phone: restaurant.phone || "", email: restaurant.email || "" },
  });

  const addFavorite = (restaurant: ApiRestaurant) => {
    const mapped = mapRestaurant(restaurant);
    if (!favorites.find((r) => r.id === mapped.id)) {
      setFavorites((prev) => [...prev, mapped]);
    }
  };

  const removeFavorite = (id: string) => {
    setFavorites((prev) => prev.filter((r) => r.id !== id));
  };

  const isFavorite = (id: string) => {
    return favorites.some((r) => r.id === id);
  };

  return (
    <FavoritesContext.Provider value={{ favorites, addFavorite, removeFavorite, isFavorite }}>
      {children}
    </FavoritesContext.Provider>
  );
};

export const useFavorites = () => {
  const context = useContext(FavoritesContext);
  if (!context) throw new Error("useFavorites must be used within a FavoritesProvider");
  return context;
};
