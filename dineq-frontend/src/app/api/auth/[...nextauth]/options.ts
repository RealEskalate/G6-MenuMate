import CredentialsProvider from "next-auth/providers/credentials";
import type { NextAuthOptions } from "next-auth";

const API_URL = process.env.NEXT_PUBLIC_API_BASE_URL; 

export const options: NextAuthOptions = {
  providers: [
    CredentialsProvider({
      name: "Credentials",
      credentials: {
        email: {
          label: "Email",
          type: "email",
          placeholder: "you@example.com",
        },
        password: { label: "Password", type: "password" },
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) {
          throw new Error("Email and password are required");
        }

        try {
          const res = await fetch(`${API_URL}/api/v1/auth/login`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              email: credentials.email,
              password: credentials.password,
            }),
          });

          const result = await res.json();
          console.log("Authorize response:", result);

          // ✅ Adapt this depending on your backend response
          if (res.ok && result?.token) {
            return {
              id: result.user?.id || credentials.email,
              email: result.user?.email || credentials.email,
              role: result.user?.role || "user",
              accessToken: result.token,
              refreshToken: result.refresh_token ?? null, // if your backend gives it
            };
          }

          throw new Error(result.message || "Invalid email or password");
        } catch (err) {
          console.error("Login error:", err);
          throw new Error("Authentication failed");
        }
      },
    }),
  ],
  pages: {
    signIn: "/login", // ✅ match your page name
  },
  session: {
    strategy: "jwt",
    maxAge: 24 * 60 * 60, // 1 day
  },
  callbacks: {
    async jwt({ token, user, trigger }) {
      if (user) {
        console.log("Initial sign-in:", { email: user.email, role: user.role });
        token.user = {
          email: user.email,
          role: user.role,
        };
        token.email = user.email;
        token.role = user.role;
        token.accessToken = user.accessToken;
        token.refreshToken = user.refreshToken;
        token.exp = Math.floor(Date.now() / 1000) + 15 * 60; // 15 min
      }

      // ✅ refresh logic (if your backend supports it)
      if (
        trigger === "update" ||
        (token.exp && Date.now() > token.exp * 1000)
      ) {
        console.log("Refreshing token...", {
          exp: token.exp,
          currentTime: Math.floor(Date.now() / 1000),
        });

        try {
          if (!token.refreshToken) {
            throw new Error("No refresh token available");
          }
          const res = await fetch(`${API_URL}/api/v1/auth/refresh`, {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${token.refreshToken}`,
            },
          });
          const result = await res.json();

          if (res.ok && result?.token) {
            token.accessToken = result.token;
            token.exp = Math.floor(Date.now() / 1000) + 15 * 60;
            delete token.error;
            delete token.errorDetails;
          } else {
            throw new Error(result.message || "Token refresh failed");
          }
        } catch (err) {
          console.error("Token refresh error:", err);
          const errorDetails =
            typeof err === "object" && err !== null && "message" in err
              ? (err as { message?: string }).message
              : String(err);
          return { ...token, error: "RefreshAccessTokenError", errorDetails };
        }
      }

      return token;
    },
    async session({ session, token }) {
      if (token.user) {
        session.user = token.user;
        session.accessToken = token.accessToken;
        session.refreshToken = token.refreshToken;
        session.exp = token.exp;
        session.error = token.error;
        session.errorDetails = token.errorDetails;
      }
      console.log("Session updated:", {
        email: session.user?.email,
        exp: session.exp,
        error: session.error,
        errorDetails: session.errorDetails,
      });
      return session;
    },
  },
  secret: process.env.NEXTAUTH_SECRET,
  debug: true,
};
