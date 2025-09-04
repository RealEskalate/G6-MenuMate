import React from "react";
import Image from "next/image";

const EmailVerification = () => {
  return (
    <div className="flex flex-col md:flex-row min-h-screen bg-gray-100">
      {/* Left Side - Form */}
      <div className="w-full md:w-2/3 flex items-center justify-center p-6">
        <div className="w-full max-w-md p-6 bg-white rounded-xl shadow-lg">
          <h1 className="text-2xl font-bold mb-6 text-left">Email Verification</h1>
          <p>Please enter the 4-digit code sent to you at <span className="font-medium">Youremail@gmail.com</span></p>

          <p className="p-5 text-orange-600 cursor-pointer hover:underline">Resend code</p>

          <div className="w-full flex items-center justify-center gap-4 my-5">
            {[0, 1, 2, 3].map((_, idx) => (
              <input
                key={idx}
                type="text"
                maxLength={1}
                inputMode="numeric"
                pattern="\d*"
                className="w-[55px] h-[55px] rounded-full border text-center text-2xl focus:outline-none focus:ring-2 focus:ring-orange-500"
              />
            ))}
          </div>

          <button
            type="submit"
            className="w-full flex justify-center mx-auto text-white py-2 my-3 rounded-lg"
            style={{ backgroundColor: "var(--color-primary)" }}
          >
            Enter
          </button>
        </div>
      </div>

      {/* Right Side - Image (hidden on mobile) */}
      <div className="relative hidden md:block md:w-1/3 h-screen">
        <Image src="/Frame.png" alt="food image" fill className="object-cover" />
      </div>
    </div>
  );
};

export default EmailVerification;
