"use client";
import React from "react";
import Link from "next/link";
import { FaStar, FaRegHeart, FaHeart } from "react-icons/fa";
import SafeImage from "@/components/common/SafeImage";
import { useFavorites, ApiRestaurant } from "@/context/FavoritesContext";

// The empty interface `RestaurantCardProps` has been removed to fix the ESLint warning.
// The component now directly uses `ApiRestaurant` for its props.
const RestaurantCard: React.FC<ApiRestaurant> = (props) => {
  // Use the useFavorites hook to manage state
  const { addFavorite, removeFavorite, isFavorite } = useFavorites();
  const fullStars = Math.floor(props.average_rating || 0);
  const totalStars = 5;

  const handleFavoriteClick = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();

    // Toggle favorite status using the context
    if (isFavorite(props.id)) {
      removeFavorite(props.id);
    } else {
      addFavorite(props);
    }
  };

  return (
    <div
      className="h-full relative bg-gray-50 rounded-xl shadow-md overflow-hidden
                  border border-gray-200
                  transition-all duration-500 transform
                  hover:-translate-y-2 hover:shadow-2xl hover:bg-white
                  hover:border-transparent hover:ring-2 hover:ring-offset-2 hover:ring-orange-500
                  group"
    >
      {/* Link covers the image and restaurant info */}
      <Link href={`/user/restaurant-display/${props.id}`} className="block">
        {/* Restaurant Image with Gradient Overlay */}
        <div className="relative w-full h-48 overflow-hidden">
          <SafeImage
            src={props.logo_image || "/Background.png"}
            alt={props.name}
            fill
            style={{ objectFit: "cover" }}
            className="rounded-t-xl transform transition-transform duration-500 group-hover:scale-110"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"></div>
        </div>

        {/* Restaurant Info */}
        <div className="p-4 flex flex-col h-auto min-h-[140px]">
          <h1 className="text-xl md:text-2xl font-bold text-gray-900 leading-snug truncate">
            {props.name}
          </h1>
          <p className="text-sm text-gray-600 mt-1 line-clamp-2">
            {props.about}
          </p>

          {/* Star Rating */}
          <div className="flex items-center pt-2 mt-auto">
            <div className="flex text-yellow-500">
              {Array.from({ length: totalStars }, (_, i) => (
                <FaStar
                  key={i}
                  className={`w-5 h-5 ${
                    i < fullStars ? "text-yellow-500" : "text-gray-300"
                  }`}
                />
              ))}
            </div>
            <span className="ml-2 text-md font-semibold text-gray-700">
              {(props.average_rating || 0).toFixed(1)}
            </span>
          </div>
        </div>
      </Link>

      {/* Favorite Button */}
      <button
        onClick={handleFavoriteClick}
        className="absolute top-4 right-4 bg-white/70 backdrop-blur-sm p-2 rounded-full shadow-lg
                   text-orange-500 hover:scale-125 hover:bg-white transition-all duration-300"
        aria-label={
          isFavorite(props.id) ? "Remove from favorites" : "Add to favorites"
        }
      >
        {isFavorite(props.id) ? (
          <FaHeart className="w-5 h-5" />
        ) : (
          <FaRegHeart className="w-5 h-5" />
        )}
      </button>
    </div>
  );
};

export default RestaurantCard;
