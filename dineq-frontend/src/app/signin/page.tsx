"use client";

import React from "react";
import Image from "next/image";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { signIn } from "next-auth/react";
import { useRouter } from "next/navigation";
import { Input } from "@/components/ui/input";

// ✅ Validation Schema
const schema = z.object({
  email: z.string().email("Invalid email address"),
  password: z.string().min(6, "Password must be at least 6 characters"),
});

type FormData = z.infer<typeof schema>;

const Signin = () => {
  const router = useRouter();

  // ✅ React Hook Form setup
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  // ✅ Handle login
  const onSubmit = async (data: FormData) => {
    const res = await signIn("credentials", {
      redirect: false, // prevent auto-redirect, handle manually
      email: data.email,
      password: data.password,
    });

    if (res?.error) {
      alert(res.error); 
    } else {

      router.push("/"); // middleware will send them to /restaurant or /user
    }
  };

  return (
    <div className="flex">
      {/* Left side - form */}
      <div className="w-2/3">
        <div className="flex items-center justify-center min-h-screen bg-gray-100">
          <div className="w-full max-w-md p-6 bg-white rounded-xl shadow-lg">
            <h1 className="text-2xl font-bold mb-6 text-center">
              Welcome Back!
            </h1>

            <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
              {/* Email */}
              <div className="flex flex-col">

                <Input
                label="Email Address"
                  type="email"
                  id="email"
                  {...register("email")}
                  placeholder="Enter Your Email"
                />
                {errors.email && (
                  <p className="text-red-500 text-xs mt-1">
                    {errors.email.message}
                  </p>
                )}
              </div>

              {/* Password */}
              <div className="flex flex-col">

                <Input
                  type="password"
                  id="password"
                  {...register("password")}
                  placeholder="**********"
                  label="Password"
                  required
                />
                {errors.password && (
                  <p className="text-red-500 text-xs mt-1">
                    {errors.password.message}
                  </p>
                )}
              </div>

              {/* Login Button */}
              <button
                type="submit"
                disabled={isSubmitting}
                className="w-1/2 flex justify-center mx-auto text-white py-2 rounded-lg"
                style={{ backgroundColor: "var(--color-primary)" }}
              >
                {isSubmitting ? "Logging in..." : "Login"}
              </button>

              {/* Footer */}
              <p className="text-sm text-center">
                Don&apos;t have an account?{" "}
                <a
                  href="/signup"
                  className="hover:underline"
                  style={{ color: "var(--color-primary)" }}
                >
                  Register
                </a>
              </p>
            </form>
          </div>
        </div>
      </div>

      {/* Right side - image */}
      <div className="relative w-1/3 h-screen">
        <Image src="/images/Frame.png" alt="food image" fill />
      </div>
    </div>
  );
};

export default Signin;
