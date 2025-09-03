import React from "react";
import Image from "next/image";
import RestaurantData from "@/data/RestaurantData";
import { Restaurant } from "../../Types/restaurants";
import { FaStar, FaRegStar } from "react-icons/fa";
import Link from "next/link";

const RestaurantCard: React.FC<Restaurant> = (props) => {
  const fullStars = Math.floor(props.averageRating);
  const hasHalfStar = props.averageRating % 1 >= 0.5;
  const totalStars = 5;

  return (
    <>
      <Link href={`/user/restaurant-display/${props.id}`} passHref>
        <div className="border border-[var(--color-primary)] w-[361px] h-[335px] rounded-lg m-5">
          <div className="relative flex flex-col p-2 h-full">
            <div className="h-[160px] w-[341px] relative rounded-lg">
              <Image
                src={props.logoImage}
                alt="Background"
                layout="fill"
                objectFit="cover"
                className="rounded-lg"
              />
            </div>

            <div className="h-[160px] w-[341px] relative rounded-lg">
              <h1 className="w-[309px] h-[28px] text-[22px] font-semibold px-[16px] pt-[15.4px] pb-[20px] leading-[28px]">
                {props.name}
              </h1>
              <p className="font-normal leading-[21px] px-[16px] pb-[8px] text-[13.125px] pt-[10px]">
                {props.about}
              </p>
              <div className="flex justify-between px-[16px] w-1/2 pt-[10px]">
                {Array.from({ length: totalStars }, (_, i) => {
                  if (i < fullStars) {
                    return <FaStar key={i} className="text-yellow-500" />;
                  } else if (i === fullStars && hasHalfStar) {
                    return (
                      <FaStar key={i} className="text-yellow-300 opacity-70" />
                    ); // half-star substitute
                  } else {
                    return <FaRegStar key={i} className="text-yellow-500" />;
                  }
                })}
                <span className="ml-2 text-sm text-gray-600">
                  {props.averageRating.toFixed(1)}
                </span>
              </div>
            </div>
          </div>
        </div>
      </Link>
    </>
  );
};

const Restaurants = () => {
  const restaurants = RestaurantData.map((restaurant) => {
    return <RestaurantCard key={restaurant.id} {...restaurant} />;
  });

  return (
    <>
      <div className="flex flex-wrap justify-center gap-6">{restaurants}</div>
    </>
  );
};

export default Restaurants;
