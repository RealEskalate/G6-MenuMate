import React from 'react'
import Image from 'next/image'
import { FaArrowLeft } from "react-icons/fa";

const ForgotPassword = () => {
  return (
    <>
      <div className="flex flex-col md:flex-row min-h-screen">
        {/* Left side - Form */}
        <div className="w-full md:w-2/3 flex items-center justify-center bg-gray-100">
          <div className="w-full max-w-md p-6 bg-white rounded-xl shadow-lg">
            <h1 className="text-2xl font-bold mb-6 text-center">Forgot Password ?</h1>
            <p className="text-gray-500 text-center">
              Enter your email address and we will send you a link to reset your password
            </p>

            <form action="" className="space-y-4">
              {/* Email Field */}
              <div className="flex flex-col py-5">
                <label htmlFor="email" className="mb-1 text-sm font-medium">
                  Email Address
                </label>
                <input
                  type="email"
                  name="email"
                  id="email"
                  placeholder="Enter Your Email"
                  className="border rounded-lg px-3 py-2 focus:outline-none focus:ring-2"
                  style={{ borderColor: "var(--color-primary)" }}
                />
              </div>

              {/* Send Reset Link Button */}
              <button
                type="submit"
                className="w-full md:w-1/2 flex justify-center mx-auto text-white py-2 rounded-lg"
                style={{ backgroundColor: "var(--color-primary)" }}
              >
                Send Reset Link
              </button>

              {/* Footer */}
              <p className="text-sm text-center mt-4">
                <a
                  href="/register"
                  className="flex justify-center items-center gap-2 hover:underline"
                  style={{ color: "var(--color-primary)" }}
                >
                  <FaArrowLeft />
                  <span>Back to signin</span>
                </a>
              </p>
            </form>
          </div>
        </div>

        {/* Right side - Image */}
        <div className="hidden md:block relative w-full md:w-1/3 h-64 md:h-auto">
          <Image
            src="/images/Frame.png"
            alt="food image"
            fill
            className="object-cover"
          />
        </div>
      </div>
    </>
  )
}

export default ForgotPassword
