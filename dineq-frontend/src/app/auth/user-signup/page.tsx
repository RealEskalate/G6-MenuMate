"use client";

import SignupForm from "@/components/common/SignUpForm";
import LoginImage from "@/components/auth/page";

export default function UserSignup() {
  return (
    <div className="flex lg:flex-row min-h-screen">
      {/* Left side - form */}
      <div className="flex justify-center w-full lg:w-2/3">
        <div className="w-full max-w-md mt-5 ">
          <h1 className="text-2xl lg:text-3xl font-bold text-center">
            Create Your Account
          </h1>
          <p className="text-gray-500 text-center mb-3 text-sm lg:text-base pt-2">
            Join Dineq to discover amazing Ethiopian cuisine.
          </p>
          <SignupForm role="CUSTOMER" />
        </div>
      </div>

      {/* Right side - full image */}
      <LoginImage />
    </div>
  );
}
