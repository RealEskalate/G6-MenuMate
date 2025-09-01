"use client";

import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { signIn, getSession } from "next-auth/react";
import { useState } from "react";
import { Mail, Lock, Unlock } from "lucide-react";
import LoginImage from "@/components/auth/page";
import Image from "next/image";
import { useRouter } from "next/navigation";

const schema = z.object({
  email: z.string().email("Invalid email address"),
  password: z.string().min(6, "Password must be at least 6 characters"),
});

type FormData = z.infer<typeof schema>;

export default function LoginPage() {
  const [authError, setAuthError] = useState<string | null>(null);
  const [showPassword, setShowPassword] = useState(false);
  const router = useRouter();

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  const onSubmit = async (data: FormData) => {
    setAuthError(null);

    const res = await signIn("credentials", {
      redirect: false,
      callbackUrl: "/dashboard/menu",
      identifier: data.email,
      password: data.password,
    });

    if (!res?.error) {
      console.log("Login successful, redirecting...");
      const session = await getSession();

      if (session?.user.role === "user") {
        router.push("/user/restaurant/food-display");
      } else if (session?.user.role === "OWNER") {
        router.push("/restaurant/dashboard");
      } else {
        router.push("/user/dashboard");
      }
    } else {
      console.log("Sign-in error:", res.error);
      setAuthError(res.error || "Invalid email or password");
    }
  };

  return (
    <div className="md:space-x-5 sm:flex sm:items-center sm:space-x-1">
      {/* Left side: form */}
      <div className="px-6 md:px-16 md:flex md:flex-col md:justify-center md:items-center md:w-2/3 pt-8 md:pt-0">
        <form onSubmit={handleSubmit(onSubmit)} className="max-w-md w-full">
          <h1 className="text-2xl font-bold mb-6">Welcome back!</h1>

          {/* Email */}
          <div className="mb-4">
            <label className="block text-sm mb-1">Email Address</label>
            <div className="relative">
              <input
                type="email"
                {...register("email")}
                placeholder="Enter your email"
                className="w-full border rounded-lg p-2 pr-10 focus:ring-2 focus:ring-orange-500"
              />
              <Mail className="absolute right-3 top-2.5 text-gray-400 w-5 h-5" />
            </div>
            {errors.email && (
              <p className="text-red-500 text-xs mt-1">
                {errors.email.message}
              </p>
            )}
          </div>

          {/* Password */}
          <div>
            <label className="block text-sm mb-1">Password</label>
            <div className="relative">
              <input
                type={showPassword ? "text" : "password"}
                {...register("password")}
                placeholder="Enter Your Password"
                className="w-full border rounded-lg p-2 pr-10 focus:ring-2 focus:ring-orange-500"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-2.5 text-gray-500 hover:text-gray-700"
              >
                {showPassword ? (
                  <Unlock className="w-5 h-5" />
                ) : (
                  <Lock className="w-5 h-5" />
                )}
              </button>
            </div>
            {errors.password && (
              <p className="text-red-500 text-xs mt-1">
                {errors.password.message}
              </p>
            )}
          </div>

          {authError && (
            <p className="text-red-500 text-sm mb-2">{authError}</p>
          )}

          <div className="text-right mb-4">
            <a href="#" className="text-sm text-orange-500 hover:underline">
              Forgot password?
            </a>
          </div>

          {/* Login Button */}
          <button
            type="submit"
            disabled={isSubmitting}
            className="bg-[#FD7E14] text-white w-full py-2 rounded-lg hover:bg-orange-500 transition disabled:opacity-50"
          >
            {isSubmitting ? "Logging in..." : "Log in"}
          </button>

          <p className="text-sm mt-4 text-center">
            Don’t have an account?{" "}
            <a
              href="/signup"
              className="text-orange-500 font-medium hover:underline"
            >
              Register
            </a>
          </p>

          <div className="my-6 flex items-center">
            <hr className="flex-grow border-gray-300" />
            <span className="px-3 text-gray-500 text-sm">OR</span>
            <hr className="flex-grow border-gray-300" />
          </div>

          {/* Google Sign-in */}
          <button
            type="button"
            onClick={() => {
              window.location.href = `${process.env.NEXT_PUBLIC_API_BASE_URL}/api/v1/auth/google/login`;
            }}
            className="flex items-center justify-center w-full border rounded-lg py-2 
            hover:bg-gray-50 transition"
          >
            <Image
              src="/icons/google.png"
              alt="Google"
              className="w-5 h-5 mr-2"
              width={24}
              height={24}
            />
            Sign in with Google
          </button>
        </form>
      </div>

      <LoginImage />
    </div>
  );
}
