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
        console.log("authorize received:", credentials);


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

          if (res.ok && result?.tokens?.access_token) {
            return {
              id: result.user.id,
              email: result.user.email,
              username: result.user.username,
              firstName: result.user.first_name,
              lastName: result.user.last_name,
              role: result.user.role,
              accessToken: result.tokens.access_token,
              refreshToken: result.tokens.refresh_token ?? null,
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
    signIn: "/login",
  },
  session: {
    strategy: "jwt",
    maxAge: 24 * 60 * 60, // 1 day
  },
  callbacks: {
    async jwt({ token, user, trigger }) {
      if (user) {
        console.log("Initial sign-in:", {
          email: user.email,
          username: user.username,
          role: user.role,
        });
        token.user = {
          email: user.email,
          // name: user.username,
          // firstName: user.firstName,
          // lastName: user.lastName,
          role: user.role,
        };
        token.email = user.email;
        token.username = user.username;
        token.firstName = user.firstName;
        token.lastName = user.lastName;
        token.role = user.role;
        token.accessToken = user.accessToken;
        token.refreshToken = user.refreshToken;
        token.exp = Math.floor(Date.now() / 1000) + 15 * 60; // 15 min
      }

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

          if (res.ok && result?.tokens?.access_token) {
            token.accessToken = result.tokens.access_token;
            token.exp = Math.floor(Date.now() / 1000) + 15 * 60;
            delete token.error;
            delete token.errorDetails;
          } else {
            throw new Error(result.message || "Token refresh failed");
          }
        } catch (err) {
          console.error("Token refresh error:", err);
          const errorDetails = err instanceof Error ? err.message : String(err);
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
        username: session.user?.name,
        exp: session.exp,
        error: session.error,
        errorDetails: session.errorDetails,
      });
      return session;
    },
    async redirect({ url, baseUrl }) {
      if (url.includes("/api/auth/callback")) {
        return `${baseUrl}/dashboard/menu`;
      }
      return url;
    },
  },
  secret: process.env.NEXTAUTH_SECRET,
  debug: process.env.NODE_ENV !== "production",
};
