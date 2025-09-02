const BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL;

import { RegisterPayload, RegisterResponse } from "@/Types/auth";

export async function registerUser(
  data: RegisterPayload
): Promise<RegisterResponse> {
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
