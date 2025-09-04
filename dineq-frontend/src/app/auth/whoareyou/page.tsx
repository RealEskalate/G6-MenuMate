"use client";

import AuthImage from "@/components/auth/page";
import React from "react";
import Link from "next/link";
import Image from "next/image";

const WhoAreYouPage = () => {
  return (
    <div className="md:space-x-5 sm:flex sm:items-center sm:space-x-1">
      <div className="px-6 md:px-16  md:flex md:flex-col md:justify-center md:items-center md:w-2/3 pt-10 md:pt-0">
        <h1 className="text-3xl font-bold mb-6 text-left">Who are You ?</h1>
        <p className="font-normal mb-4">
          Choose your role to get the most out of Dineq
        </p>

        {/* Restaurant */}
        <Link
          href="/auth/manager-signup"
          className="w-full flex justify-center"
        >
          <div className="w-120 min-h-[120px] rounded-lg border border-[var(--color-primary)] flex items-center gap-4 my-4 p-3 hover:bg-orange-50">
            {/* Image Circle */}
            <div className="relative w-[85px] h-[85px] overflow-hidden flex-shrink-0">
              <Image
                src="/icons/restaurant.png"
                alt="Restaurant"
                fill
                className="object-cover"
              />
            </div>

            {/* Text Section */}
            <div className="flex flex-col justify-center flex-1 ">
              <p className="text-lg font-semibold text-gray-800">Restaurant</p>
              <p className="text-sm text-gray-600">
                Create and manage digital menus, generate QR codes, and track
                performance
              </p>
            </div>
          </div>
        </Link>

        {/* Customer */}
        <Link href="/auth/user-signup" className="w-full flex justify-center">
          <div className="w-120 min-h-[120px] rounded-lg border border-[var(--color-primary)] flex items-center gap-4 my-4 p-3 hover:bg-orange-50">
            {/* Image Circle */}
            <div className="relative w-[85px] h-[85px] overflow-hidden flex-shrink-0">
              <Image
                src="/icons/user.png"
                alt="Customer"
                fill
                className="object-cover"
              />
            </div>

            {/* Text Section */}
            <div className="flex flex-col justify-center flex-1">
              <p className="text-lg font-semibold text-gray-800">Customer</p>
              <p className="text-sm text-gray-600">
                Discover dishes, scan QR menus and share reviews
              </p>
            </div>
          </div>
        </Link>
      </div>

      <AuthImage />
    </div>
  );
};

export default WhoAreYouPage;
