"use client";

import React from "react";
import Link from "next/link";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import Image from "next/image";

import { Input } from "@/components/ui/input";   
import { Button } from "@/components/ui/button"; 
import { Checkbox } from "@/components/ui/checkbox"; 
import { registerUser } from "@/lib/auth-api";   


const schema = z
  .object({
    username: z.string().min(3, "Username is required"),
    first_name: z.string().min(2, "First name is required"),
    last_name: z.string().min(2, "Last name is required"),
    email: z.string().email("Invalid email"),
    password: z
      .string()
      .min(8, "Password must be at least 8 characters")
      .regex(/[A-Z]/, "Must include an uppercase letter")
      .regex(/[a-z]/, "Must include a lowercase letter")
      .regex(/[0-9]/, "Must include a number"),
    confirmPassword: z.string(),
    agree: z.boolean().refine((v) => v, {
      message: "You must agree to the Terms and Privacy Policy",
    }),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: "Passwords do not match",
    path: ["confirmPassword"],
  });

type FormData = z.infer<typeof schema>;

export default function SignupForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  const onSubmit = async (data: FormData) => {
    try {
      const payload = {
        username: data.username,
        email: data.email,
        password: data.password,
        first_name: data.first_name,
        last_name: data.last_name,
      };

      const response = await registerUser(payload);
      console.log("✅ Registered:", response);

    } catch (err) {
      console.error("❌ Signup failed:", err);
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
      {/* Username */}
      <div>
        <Input
          label="Username"
          required
          placeholder="Choose a username"
          {...register("username")}
        />
        {errors.username && (
          <p className="text-red-500 text-sm">{errors.username.message}</p>
        )}
      </div>

      {/* First Name */}
      <div>
        <Input
          label="First Name"
          required
          placeholder="Enter your first name"
          {...register("first_name")}
        />
        {errors.first_name && (
          <p className="text-red-500 text-sm">{errors.first_name.message}</p>
        )}
      </div>

      {/* Last Name */}
      <div>
        <Input
          label="Last Name"
          required
          placeholder="Enter your last name"
          {...register("last_name")}
        />
        {errors.last_name && (
          <p className="text-red-500 text-sm">{errors.last_name.message}</p>
        )}
      </div>

      {/* Email */}
      <div>
        <Input
          label="Email Address"
          required
          type="email"
          placeholder="Enter your email"
          {...register("email")}
        />
        {errors.email && (
          <p className="text-red-500 text-sm">{errors.email.message}</p>
        )}
      </div>

      {/* Password */}
      <div>
        <Input
          label="Password"
          required
          type="password"
          {...register("password")}
        />
        {errors.password && (
          <p className="text-red-500 text-sm">{errors.password.message}</p>
        )}
        <p className="text-xs text-gray-500">
          Must be at least 8 characters with uppercase, lowercase, and number
        </p>
      </div>

      {/* Confirm Password */}
      <div>
        <Input
          label="Confirm Password"
          required
          type="password"
          {...register("confirmPassword")}
        />
        {errors.confirmPassword && (
          <p className="text-red-500 text-sm">{errors.confirmPassword.message}</p>
        )}
      </div>

      {/* Terms */}
      <div className="flex items-start space-x-2">
        <Checkbox id="agree" {...register("agree")} />
        <label htmlFor="agree" className="text-sm text-gray-600">
          I agree to the{" "}
          <Link href="/terms" className="text-blue-600">
            Terms of Service
          </Link>{" "}
          and{" "}
          <Link href="/privacy" className="text-blue-600">
            Privacy Policy
          </Link>{" "}
          <span className="text-red-500">*</span>
        </label>
      </div>
      {errors.agree && (
        <p className="text-red-500 text-sm">{errors.agree.message}</p>
      )}

      {/* Submit */}
      <Button type="submit" className="w-full" disabled={isSubmitting}>
        {isSubmitting ? "Creating Account..." : "Create Account"}
      </Button>

      {/* Sign In */}
      <p className="text-center mt-4 text-sm">
        Already have an account?{" "}
        <Link href="/auth/signin" className="text-[var(--color-primary)]">
          Sign in
        </Link>
      </p>

      {/* Divider */}
      <div className="flex items-center my-4">
        <hr className="flex-grow border-gray-300" />
        <span className="mx-2 text-gray-500 text-sm">OR</span>
        <hr className="flex-grow border-gray-300" />
      </div>

      {/* Google Sign-in */}
      <Button
        variant="outline"
        className="w-full flex items-center justify-center gap-2"
      >
        <Image
          src="/icons/google.png"
          width={100}
          height={120}
          alt="Google"
          className="w-5 h-5"
        />
        Sign in with Google
      </Button>
    </form>
  );
}
