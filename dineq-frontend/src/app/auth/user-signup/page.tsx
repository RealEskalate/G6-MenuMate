"use client";

import SignupForm from "@/components/common/SignUpForm";
import AuthImage from "@/components/auth/page";

export default function UserSignup() {
  return (
    <div className="flex h-screen overflow-hidden">
      {/* Left side - scrollable form */}
      <div className="flex-1 flex flex-col items-center justify-start overflow-y-auto py-5 w-3/5     scrollbar-hide">
        <div className="w-full max-w-md">
          <h1 className="text-2xl lg:text-3xl font-bold text-center">
            Create User Account
          </h1>
          <p className="text-gray-500 text-center mb-3 text-sm lg:text-base pt-2">
            Join Dineq to discover amazing Ethiopian cuisine.
          </p>
          <SignupForm role="MANAGER" />
        </div>
      </div>

      {/* Right side - full image */}
      <div className="w-2/5">
        <AuthImage />
      </div>
    </div>
  );
}
