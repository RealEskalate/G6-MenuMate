// src/app/user/single-restaurant-display/page.tsx

import { notFound } from "next/navigation";
import Image from "next/image";
import { FaHeart } from "react-icons/fa";
import { MapPin, Phone } from "lucide-react";
import RestaurantData from "@/data/RestaurantData";

interface Props {
  params: {
    id: string;
  };
}

export default function SingleRestaurant({ params }: Props) {
  const restaurant = RestaurantData.find((r) => r && r.id === params.id);

  if (!restaurant) return notFound();

  return (
    <div className="flex flex-col items-center">
      {/* Header Image */}
      <div className="w-[1128px] h-[156px] relative m-5 mb-0">
        <Image
          src={restaurant.logoImage}
          alt={restaurant.name}
          fill
          className="object-cover rounded-lg"
        />
      </div>

      {/* Restaurant Info */}
      <div className="w-[1128px] h-auto bg-gray-200 p-5 rounded-lg">
        <div className="flex justify-between items-start">
          <div className="flex flex-col">
            <p className="text-2xl font-bold">{restaurant.name}</p>
            <p className="text-yellow-500">⭐ {restaurant.averageRating}</p>
            <p className="mt-2">{restaurant.about}</p>
          </div>

          <button
            type="button"
            className="flex items-center justify-center gap-2 px-4 py-2 mx-auto text-white rounded-lg"
            style={{ backgroundColor: "var(--color-primary)" }}
          >
            <FaHeart className="w-5 h-5" />
            Save
          </button>
        </div>

        {/* Extra Details */}
        <div className="mt-4 space-y-2">
          <p className="flex items-center gap-2">
            <MapPin className="w-6 h-6 text-red-500" />
            {restaurant.location}
          </p>
          <p className="flex items-center gap-2">
            <Phone className="w-6 h-6 text-green-500" />
            {restaurant.contact.phone}
          </p>
        </div>
      </div>
    </div>
  );
}
