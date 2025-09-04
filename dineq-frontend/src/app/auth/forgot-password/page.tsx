"use client";
import React, { useState } from "react";
import { FaArrowLeft } from "react-icons/fa";
import { Mail } from "lucide-react";
import AuthImage from "@/components/auth/page";
import { forgotPassword } from "@/lib/api";

const ForgotPassword = () => {
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setMessage("");

    try {
      const res = await forgotPassword({ email });
      setMessage(res.message || "✅ Reset link sent to your email.");
    } catch (err) {
      setMessage( "❌ Something went wrong.");
      console.error("❌ Error:", err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="md:space-x-5 sm:flex sm:items-center ">
      {/* Left side: form */}
      <div className="px-6 md:px-16 md:flex md:flex-col md:justify-center md:items-center md:w-2/3 pt-8 md:pt-0">
        <form onSubmit={handleSubmit} className="max-w-md w-full">
          <h1 className="text-[28px] font-bold mb-4 text-center mt-0">
            Forgot Password?
          </h1>
          <p className="text-gray-600 mb-6 text-center">
            Enter your email address below and we&apos;ll send you a link to
            reset your password.
          </p>

          {/* Email */}
          <div className="mb-4">
            <label className="block text-[16px] font-semibold mb-2.5">
              Email Address
            </label>
            <div className="relative">
              <input
                type="email"
                placeholder="Enter your email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full border rounded-lg p-2 pr-10 focus:ring-2 focus:ring-orange-500"
                required
              />
              <Mail className="absolute right-3 top-2.5 text-gray-400 w-5 h-5" />
            </div>
          </div>

          {/* Centered button */}
          <div className="flex justify-center py-3">
            <button
              type="submit"
              disabled={loading}
              className="text-white w-2/3 py-2 rounded-lg hover:bg-orange-500 transition disabled:opacity-50"
              style={{ backgroundColor: "var(--color-primary)" }}
            >
              {loading ? "Sending..." : "Send Reset Link"}
            </button>
          </div>

          {/* Show response message */}
          {message && (
            <p className="text-center mt-2 text-sm text-gray-600">{message}</p>
          )}

          {/* Footer */}
          <div className="text-[16px] text-center mt-1.5">
            <a
              href="/auth/signin"
              className="flex justify-center hover:underline"
              style={{ color: "var(--color-primary)" }}
            >
              <div className="flex items-center gap-2">
                <FaArrowLeft />
                <span>Back to signin</span>
              </div>
            </a>
          </div>
        </form>
      </div>

      <AuthImage />
    </div>
  );
};

export default ForgotPassword;
