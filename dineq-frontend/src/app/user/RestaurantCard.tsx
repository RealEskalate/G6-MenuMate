"use client";
import React from "react";
import Link from "next/link";
import { FaStar, FaRegStar } from "react-icons/fa";
import { Restaurant } from "@/Types/restaurants";
import SafeImage from "@/components/common/SafeImage";

const RestaurantCard: React.FC<Restaurant> = (props) => {
  const fullStars = Math.floor(props.averageRating);
  const hasHalfStar = props.averageRating % 1 >= 0.5;
  const totalStars = 5;

  return (
    <Link href={`/user/restaurant-display/${props.id}`} passHref>
      <div
        className="border border-[var(--color-primary)] rounded-lg cursor-pointer 
        transition-all duration-300 transform 
        hover:-translate-y-2 hover:shadow-xl"
      >
        <div className="relative flex flex-col p-2 h-full">
          {/* Restaurant Image */}
          <div className="relative w-full h-40 md:h-44 rounded-lg overflow-hidden">
            <SafeImage
              src={props.logoImage}
              alt={props.name}
              fill
              style={{ objectFit: "cover" }}
              className="rounded-lg"
            />
          </div>

          {/* Restaurant Info */}
          <div className="pt-2 pb-3 flex flex-col justify-between flex-1">
            <h1 className="text-[18px] md:text-[20px] font-semibold px-2 leading-[1.2] truncate">
              {props.name}
            </h1>
            <p className="px-2 text-sm text-gray-700 line-clamp-3">
              {props.about}
            </p>

            {/* Star Rating */}
            <div className="flex items-center gap-2 px-2 pt-2 mt-auto">
              <div className="flex">
                {Array.from({ length: totalStars }, (_, i) => {
                  if (i < fullStars) {
                    return <FaStar key={i} className="text-yellow-500" />;
                  } else if (i === fullStars && hasHalfStar) {
                    return (
                      <FaStar key={i} className="text-yellow-300 opacity-70" />
                    );
                  } else {
                    return <FaRegStar key={i} className="text-yellow-500" />;
                  }
                })}
              </div>
              <span className="text-sm text-gray-600">
                {props.averageRating.toFixed(1)}
              </span>
            </div>
          </div>
        </div>
      </div>
    </Link>
  );
};

export default RestaurantCard;
