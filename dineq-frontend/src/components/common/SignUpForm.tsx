"use client";

import React from "react";
import Link from "next/link";
import { useForm, Controller } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import Image from "next/image";


import { Input } from "@/components/ui/input";   
import { Button } from "@/components/ui/button"; 
import { Checkbox } from "@/components/ui/checkbox"; 
import { registerUser } from "@/lib/api";   
import { useRouter } from "next/navigation";
import { signIn } from "next-auth/react";

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
    role: z.string(),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: "Passwords do not match",
    path: ["confirmPassword"],
  });

type FormData = z.infer<typeof schema>;

interface SignupFormProps {
  role: string;
}

export default function SignupForm({ role }: SignupFormProps) {
   const router = useRouter();
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    watch,
    control,
  } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: {
      role,
    },
  });

  const formValues = watch();
  React.useEffect(() => {
    console.log("Current form values:", formValues);
  }, [formValues]);

  React.useEffect(() => {
    if (Object.keys(errors).length > 0) {
      console.log("Form errors:", errors);
    }
  }, [errors]);

  const onSubmit = async (data: FormData) => {
    try {
      const payload = {
        username: data.username,
        email: data.email,
        password: data.password,
        first_name: data.first_name,
        last_name: data.last_name,
        auth_provider: "EMAIL",
        role: role,
      };
      const response = await registerUser(payload);
      console.log("✅ Registered:", response);

      if(role === "MANAGER"){

        const result = await signIn("credentials", {
        redirect: false, 
        identifier: data.email,
        password: data.password,
      });
      
      if (result?.error) {
        console.error("❌ Auto-login failed:", result.error);
        router.push("/auth/signin");
      } else {
        router.push("/restaurant/register/basic-info");
      }


      } else{
        router.push("/auth/signin");
      }

    } catch (err) {
      console.error("❌ Signup failed:", err);
    }
  };

  return (
    <>
    <form
      onSubmit={handleSubmit(onSubmit)}
      className="space-y-2 w-full max-w-md"
    >
      {/* Username */}
      <div>
        <label className="block text-black font-normal text-[18px] mb-1">
          User Name
        </label>
        <Input
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
        <label className="block text-black font-normal text-[18px] mb-1">
          First Name
        </label>
        <Input
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
        <label className="block text-black font-normal text-[18px] mb-1">
          Last Name
        </label>
        <Input
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
        <label className="block text-black font-normal text-[18px] mb-1">
          Email Address
        </label>
        <Input
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
        <label className="block text-black font-normal text-[18px] mb-1">
          Password
        </label>
        <Input required type="password" {...register("password")} />
        {errors.password && (
          <p className="text-red-500 text-sm">{errors.password.message}</p>
        )}
        <p className="text-xs text-gray-500">
          Must be at least 8 characters with uppercase, lowercase, and number
        </p>
      </div>

      {/* Confirm Password */}
      <div>
        <label className="block text-black font-normal text-[18px] mb-1">
          Confirm Password
        </label>
        <Input required type="password" {...register("confirmPassword")} />
        {errors.confirmPassword && (
          <p className="text-red-500 text-sm">
            {errors.confirmPassword.message}
          </p>
        )}
      </div>

      {/* Terms */}
      <div className="flex items-start space-x-2">
        <Controller
          name="agree"
          control={control}
          render={({ field }) => (
            <Checkbox
              id="agree"
              checked={field.value}
              onCheckedChange={field.onChange}
            />
          )}
        />
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
      </form>
      <div className="flex items-center my-4">
        <hr className="flex-grow border-gray-300" />
        <span className="mx-2 text-gray-500 text-sm">OR</span>
        <hr className="flex-grow border-gray-300" />
      </div>
      {/* Google Sign-in */}
      <Button
        className="w-full flex items-center justify-center gap-2 bg-white text-black border border-gray-300 hover:bg-gray-100"
        onClick={() =>
          (window.location.href =
            `${process.env.NEXT_PUBLIC_API_BASE_URL}/auth/google/login`)
        }
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
    </>
  );
}
