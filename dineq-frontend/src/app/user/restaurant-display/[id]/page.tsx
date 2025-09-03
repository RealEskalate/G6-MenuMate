import { notFound } from "next/navigation";
import Image from "next/image";
import { FaHeart } from "react-icons/fa";
import { MapPin, Phone } from "lucide-react";
import restaurants from "@/data/RestaurantData"; // Correctly import the data

interface Props {
  params: {
    id: string;
  };
}

export default function SingleRestaurant({ params }: Props) {
  // Looking up restaurant by id from static data
  
  // The .find() method should work correctly if the data is imported.
  const restaurant = restaurants.find((r) => r.id === params.id);
  
  if (!restaurant) {
    // If the restaurant is not found, render a 404 page.
    return notFound();
  }

  return (
    <div className="flex flex-col items-center p-4 sm:p-6 md:p-8">
      {/* Header Image */}
      <div className="w-full max-w-5xl h-40 sm:h-52 md:h-64 relative rounded-lg overflow-hidden shadow-lg">
        <Image
          src={restaurant.logoImage}
          alt={restaurant.name}
          fill
          className="object-cover"
        />
      </div>

      {/* Restaurant Info */}
      <div className="w-full max-w-5xl bg-gray-100 p-5 rounded-lg mt-5 shadow-md">
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center">
          <div className="flex flex-col mb-4 md:mb-0">
            <h1 className="text-3xl font-bold">{restaurant.name}</h1>
            <p className="text-yellow-500 text-lg">⭐ {restaurant.averageRating}</p>
            <p className="mt-2 text-gray-700">{restaurant.about}</p>
          </div>
          
          <button
            type="button"
            className="flex items-center justify-center gap-2 px-6 py-3 text-white rounded-full transition-colors duration-200"
            style={{ backgroundColor: "var(--color-primary)" }}
          >
            <FaHeart className="w-5 h-5" />
            Save
          </button>
        </div>

        {/* Extra Details */}
        <div className="mt-6 space-y-3">
          <p className="flex items-center gap-3 text-lg text-gray-600">
            <MapPin className="w-6 h-6 text-red-500" />
            {restaurant.location || "Location not available"}
          </p>
          <p className="flex items-center gap-3 text-lg text-gray-600">
            <Phone className="w-6 h-6 text-green-500" />
            {restaurant.contact.phone}
          </p>
        </div>
      </div>
    </div>
  );
}
