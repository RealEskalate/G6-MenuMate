"use client";

import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { signIn } from "next-auth/react";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { Mail, Lock } from "lucide-react";
import LoginImage from "@/components/auth/page";
 import { getSession } from "next-auth/react";
import { truncate } from "fs";

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
  // console.log("Form submitted:", data);
  setAuthError(null);

  const res = await signIn("credentials", {
    redirect: false,
    callbackUrl: "/dashboard/menu",
    identifier: data.email,
    password: data.password,
  });

  console.log("signIn response:", res);

  if (!res?.error) {
    console.log("Login successful, redirecting...");
    const session = await getSession();
    console.log("Session:", session);
    if (session?.user.role==="user"){
      router.push("/user")
    }
     else if (session?.user.role === "OWNER") {
      router.push("/restaurant/dashboard"); // Changed to relative path
    } else {
      router.push("/dashboard/menu"); // Changed to relative path
    }
  } else {
    console.log("Sign-in error:", res.error);
    setAuthError(res.error || "Invalid email or password");
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
                placeholder="Enter Your Password"
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
  onClick={() => signIn("google", { callbackUrl: "/dashboard/menu" })}
  className="flex items-center justify-center w-full border rounded-lg py-2 hover:bg-gray-50 transition"
>
  <img src="/icons/google.png" alt="Google" className="w-5 h-5 mr-2" />
  Sign in with Google
</button>

        </form>
      </div>

      <LoginImage />
    </div>
  );
}
// "use client";

// import React from "react";
// import Image from "next/image";
// import { useForm } from "react-hook-form";
// import { z } from "zod";
// import { zodResolver } from "@hookform/resolvers/zod";
// import { signIn } from "next-auth/react";
// import { useRouter } from "next/navigation";
// import { Input } from "@/components/ui/input";

// // ✅ Validation Schema
// const schema = z.object({
//   email: z.string().email("Invalid email address"),
//   password: z.string().min(6, "Password must be at least 6 characters"),
// });

// type FormData = z.infer<typeof schema>;

// const Signin = () => {
//   const router = useRouter();

//   // ✅ React Hook Form setup
//   const {
//     register,
//     handleSubmit,
//     formState: { errors, isSubmitting },
//   } = useForm<FormData>({
//     resolver: zodResolver(schema),
//   });

//   // ✅ Handle login
//   const onSubmit = async (data: FormData) => {
//     const res = await signIn("credentials", {
//       redirect: false, // prevent auto-redirect, handle manually
//       email: data.email,
//       password: data.password,
//     });

//     if (res?.error) {
//       alert(res.error);
//     } else {
//       router.push("/"); // middleware will send them to /restaurant or /user
//     }
//   };

//   return (
//     <div className="flex">
//       {/* Left side - form */}
//       <div className="w-2/3">
//         <div className="flex items-center justify-center min-h-screen bg-gray-100">
//           <div className="w-full max-w-md p-6 bg-white rounded-xl shadow-lg">
//             <h1 className="text-2xl font-bold mb-6 text-center">
//               Welcome Back!
//             </h1>

//             <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
//               {/* Email */}
//               <div className="flex flex-col">
//                 <Input
//                   label="Email Address"
//                   type="email"
//                   id="email"
//                   {...register("email")}
//                   placeholder="Enter Your Email"
//                 />
//                 {errors.email && (
//                   <p className="text-red-500 text-xs mt-1">
//                     {errors.email.message}
//                   </p>
//                 )}
//               </div>

//               {/* Password */}
//               <div className="flex flex-col">
//                 <Input
//                   type="password"
//                   id="password"
//                   {...register("password")}
//                   placeholder="**********"
//                   label="Password"
//                   required
//                 />
//                 {errors.password && (
//                   <p className="text-red-500 text-xs mt-1">
//                     {errors.password.message}
//                   </p>
//                 )}
//               </div>

//               {/* Login Button */}
//               <button
//                 type="submit"
//                 disabled={isSubmitting}
//                 className="w-1/2 flex justify-center mx-auto text-white py-2 rounded-lg"
//                 style={{ backgroundColor: "var(--color-primary)" }}
//               >
//                 {isSubmitting ? "Logging in..." : "Login"}
//               </button>

//               {/* Footer */}
//               <p className="text-sm text-center">
//                 Don&apos;t have an account?{" "}
//                 <a
//                   href="/signup"
//                   className="hover:underline"
//                   style={{ color: "var(--color-primary)" }}
//                 >
//                   Register
//                 </a>
//               </p>
//             </form>
//           </div>
//         </div>
//       </div>

//       {/* Right side - image */}
//       <div className="relative w-1/3 h-screen">
//         <Image src="/loginfood.png" alt="food image" fill />
//       </div>
//     </div>
//   );
// };

// export default Signin;

