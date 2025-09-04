const BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL;

import { RegisterPayload, RegisterResponse } from "@/Types/auth";

export async function registerUser(
  data: RegisterPayload
): Promise<RegisterResponse> {
  console.log("📤 Sending payload:", data, "to", `${BASE_URL}/auth/register`);

  const res = await fetch(`${BASE_URL}/auth/register`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });

  if (!res.ok) {
    throw new Error("Failed to register");
  }

  return res.json();
}

export interface ForgotPasswordPayload {
  email: string;
}

export interface ForgotPasswordResponse {
  message: string;
}

export async function forgotPassword(
  data: ForgotPasswordPayload
): Promise<ForgotPasswordResponse> {
  console.log(
    "📤 Sending payload:",
    data,
    "to",
    `${BASE_URL}/auth/forgot-password`
  );

  const res = await fetch(`${BASE_URL}/auth/forgot-password`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });

  if (!res.ok) {
    throw new Error("❌ Failed to send reset link");
  }

  return res.json();
}
