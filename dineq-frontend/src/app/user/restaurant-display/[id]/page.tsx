"use client";
import { FaHeart } from "react-icons/fa";
import { Phone } from "lucide-react";
import SafeImage from "@/components/common/SafeImage";
import NavBar from "@/components/common/NavBar";
import { useParams } from "next/navigation";
import { useDispatch, useSelector } from "react-redux";
import { AppDispatch, RootState } from "@/store/store";
import { useEffect } from "react";
import { fetchRestaurantById, ApiRestaurant } from "@/store/restaurantsSlice";
import { RestaurantDetailSkeleton } from "@/components/common/LoadingSkeletons";
import MenuSection from "@/components/user/MenuSection";

export default function SingleRestaurant() {
  const params = useParams<{ id: string }>();
  const id = params?.id || "";
  const dispatch = useDispatch<AppDispatch>();

  const { currentRestaurant, currentLoading, currentError } = useSelector(
    (state: RootState) => state.restaurants
  );

  useEffect(() => {
    if (id) {
      dispatch(fetchRestaurantById(id));
    }
  }, [dispatch, id]);

  const restaurant: ApiRestaurant | null = currentRestaurant;

  return (
    <>
      <NavBar role="CUSTOMER" />

      {!id ? (
        <div className="flex justify-center p-8">Invalid restaurant id.</div>
      ) : currentLoading ? (
        <RestaurantDetailSkeleton />
      ) : currentError ? (
        <div className="flex justify-center p-8 text-red-600">{currentError}</div>
      ) : !restaurant ? (
        <RestaurantDetailSkeleton />
      ) : (
        <div className="flex flex-col items-center px-4 sm:px-6 md:px-8 pb-8">
          {/* Header Image */}
          <div className="w-full max-w-5xl h-40 sm:h-52 md:h-64 relative rounded-lg overflow-hidden shadow-lg mt-4">
            <SafeImage
              src={restaurant.logo_image ?? "/Background.png"}
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
                <p className="text-yellow-500 text-lg">
                  ⭐ {restaurant.average_rating ?? 0}
                </p>
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
                <Phone className="w-6 h-6 text-green-500" />
                {restaurant.phone ?? "Phone not available"}
              </p>
            </div>
          </div>

          {/* Menu Section */}
          <div className="w-full max-w-5xl mt-8">
            {/* Pass the restaurant slug to MenuSection for fetching menus */}
            <MenuSection restaurantSlug={restaurant.slug} />
          </div>
        </div>
      )}
    </>
  );
}
