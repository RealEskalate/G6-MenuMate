// src/components/user/FoodSection/FoodHeader.tsx
"use client";

import { FaHeart } from "react-icons/fa";
import Image from "next/image";
import { StaticImageData } from "next/image";

interface FoodHeaderProps {
  image: string | StaticImageData;
  title: string;
  price: string;
  rating?: number;
  isFavorite: boolean;
  onFavorite?: () => void;
}

export default function FoodHeader({
  image,
  title,
  price,
  rating,
  isFavorite,
  onFavorite,
}: FoodHeaderProps) {
  return (
    <div className="relative w-full overflow-hidden rounded-2xl shadow-xl">
      {/* Background Image */}
      <div className="relative w-full h-64 sm:h-80">
        <Image
          src={image}
          alt={title}
          fill
          className="object-cover"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-black/70 to-transparent"></div>
      </div>

      {/* Content */}
      <div className="absolute inset-x-0 bottom-0 p-6 sm:p-8 text-white flex flex-col sm:flex-row justify-between items-start sm:items-end">
        <div className="flex-1">
          <h1 className="text-3xl sm:text-4xl font-bold">{title}</h1>
          <p className="text-xl font-semibold mt-1">{price}</p>
          {rating !== undefined && rating > 0 && (
            <div className="flex items-center mt-2">
              <span className="text-yellow-400 text-2xl">★</span>
              <span className="ml-1 text-lg font-bold">{rating.toFixed(1)}</span>
            </div>
          )}
        </div>
        
        {/* Favorite Button */}
        <button
          onClick={onFavorite}
          className={`flex items-center gap-2 px-6 py-3 mt-4 sm:mt-0 rounded-full transition-colors duration-200 ${
            isFavorite
              ? "bg-red-500 hover:bg-red-600"
              : "bg-white/20 hover:bg-white/30 backdrop-blur-sm"
          }`}
        >
          <FaHeart className={`w-5 h-5 ${isFavorite ? "text-white" : "text-gray-200"}`} />
          <span className="text-white font-medium hidden sm:inline">
            {isFavorite ? "Remove Favorite" : "Add to Favorites"}
          </span>
        </button>
      </div>
    </div>
  );
}