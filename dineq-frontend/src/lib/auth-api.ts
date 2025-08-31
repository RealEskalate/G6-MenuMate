export interface RegisterPayload {
  username: string;
  email: string;
  password: string;
  first_name: string;
  last_name: string;
  provider?: string;
}

export async function registerUser(data: RegisterPayload) {
  try {
    const res = await fetch("https://dineq-backend.onrender.com/api/v1/auth/register", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ ...data, provider: "manual" }),
    });

    if (!res.ok) {
      const errorData = await res.json();
      throw new Error(errorData.message || "Failed to register");
    }

    return res.json();
  } catch (err) {
    console.error("Register error:", err);
    throw err;
  }
}