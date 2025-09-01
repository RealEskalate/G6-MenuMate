"use client";

import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { signIn } from "next-auth/react";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { Mail, Lock } from "lucide-react";
import LoginImage from "@/components/auth/page";

const schema = z.object({
  email: z.string().email("Invalid email address"),
  password: z.string().min(6, "Password must be at least 6 characters"),
});

type FormData = z.infer<typeof schema>;

export default function LoginPage() {
  const router = useRouter();
  const [authError, setAuthError] = useState<string | null>(null);

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
      email: data.email,
      password: data.password,
    });

    if (res?.error) {
      setAuthError(res.error);
    } else {
      router.push("/dashboard");
    }
  };

  return (
    <div className="flex space-x-5">
      {/* Left side: form */}
      <div className="flex flex-col justify-center items-center w-full md:w-1/2 px-9 md:px-16">
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
          <div className="mb-4">
            <label className="block text-sm mb-1">Password</label>
            <div className="relative">
              <input
                type="password"
                {...register("password")}
                placeholder="************"
                className="w-full border rounded-lg p-2 pr-10 focus:ring-2 focus:ring-orange-500"
              />
              <Lock className="absolute right-3 top-2.5 text-gray-500 w-5 h-5" />
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
            className="bg-orange-500 text-white w-full py-2 rounded-lg hover:bg-orange-600 transition disabled:opacity-50"
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
            className="flex items-center justify-center w-full border rounded-lg py-2 hover:bg-gray-50 transition"
          >
            <img
              src="/icons/google.png"
              alt="Google"
              className="w-5 h-5 mr-2"
            />
            Sign up with Google
          </button>
        </form>
      </div>

      <LoginImage />
    </div>
  );
}
