"use client";

import SignupForm from "@/components/common/SignUpForm";
import LoginImage from "@/components/auth/page";

export default function ManagerSignup() {
  return (
    <div className="flex flex-col lg:flex-row h-screen">
      {/* Left side - form */}
      <div className="flex items-center justify-center w-full lg:w-2/3 bg-gray-50 p-4 lg:p-8">
        <div className="w-full max-w-md bg-white p-6 lg:p-8 rounded-2xl shadow">
          <h1 className="text-2xl lg:text-3xl font-bold text-center">
            Create Manager Account
          </h1>
          <p className="text-gray-500 text-center mb-6 text-sm lg:text-base">
            Join Dineq to manage your restaurant efficiently.
          </p>

          <SignupForm role="MANAGER" />
        </div>
      </div>

      {/* Right side - full image (hidden below lg) */}
      <LoginImage />
    </div>
  );
}
