"use client";

import Image from "next/image";
import SignupForm from "@/components/common/SignUpForm";

export default function UserSignup() {
  return (
    <div className="flex flex-col md:flex-row h-screen">
      {/* Left side - form */}
      <div className="flex items-center justify-center w-full md:w-1/2 bg-gray-50 p-4 md:p-8">
        <div className="w-full max-w-md bg-white p-6 md:p-8 rounded-2xl shadow">
          <h1 className="text-2xl md:text-3xl font-bold text-center">
            Create Your Account
          </h1>
          <p className="text-gray-500 text-center mb-6 text-sm md:text-base">
            Join Dineq to discover amazing Ethiopian cuisine.
          </p>

          <SignupForm />
        </div>
      </div>

      {/* Right side - full image */}
      <div className="hidden md:flex w-1/2 h-screen relative">
        <Image
          src="/loginfood.png"
          alt="Food"
          fill
          className="object-cover rounded-t-2xl md:rounded-none"
          priority
        />
      </div>
    </div>
  );
}
