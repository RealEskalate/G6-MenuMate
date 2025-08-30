// export interface LoginResponse {
//   token: string; // adjust to your backend response shape
//   user?: any;
// }

// export async function login(email: string, password: string): Promise<LoginResponse> {
//   const res = await fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL}/api/v1/auth/login`, {
//     method: "POST",
//     headers: {
//       "Content-Type": "application/json",
//     },
//     body: JSON.stringify({ email, password }),
//   });

//   if (!res.ok) {
//     const error = await res.json().catch(() => ({}));
//     throw new Error(error.message || "Login failed");
//   }

//   return res.json();
// }
