"use client";

import Image from "next/image";
import SignupForm from "@/components/common/SignUpForm";

export default function ManagerSignup() {
  return (
    <div className="flex h-screen">
      {/* Left side - form */}
      <div className="flex items-center justify-center w-1/2 bg-gray-50">
        <div className="w-full max-w-md bg-white p-8 rounded-2xl shadow">
          <h1 className="text-2xl font-bold text-center">Create Your Account</h1>
          <p className="text-gray-500 text-center mb-6">
            Join Dineq to discover amazing Ethiopian cuisine.
          </p>

          <SignupForm />
        </div>
      </div>

      {/* Right side - full image */}
      <div className="relative w-1/2 h-full">
        <Image
          src="/loginfood.png"
          alt="Restaurant"
          fill
          className="object-cover"
          priority
        />
      </div>
    </div>
  );
}
