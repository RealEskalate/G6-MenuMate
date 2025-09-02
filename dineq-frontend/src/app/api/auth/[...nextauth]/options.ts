import CredentialsProvider from "next-auth/providers/credentials";
import type { NextAuthOptions } from "next-auth";

const API_URL = process.env.NEXT_PUBLIC_API_BASE_URL;

export const options: NextAuthOptions = {
  providers: [
    CredentialsProvider({
      name: "Credentials",
      credentials: {
        identifier: {
          label: "Email",
          type: "email",
          placeholder: "you@example.com",
        },
        password: { label: "Password", type: "password" },
      },

      async authorize(credentials) {
        console.log("authorize received:", credentials);

        if (!credentials?.identifier) {
          throw new Error("Email required");
        }
        if (!credentials?.password) {
          throw new Error("Password required");
        }

        try {
          const res = await fetch(`${API_URL}/auth/login`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              identifier: credentials.identifier,
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
              refreshToken: result.tokens.refresh_token ,
            };
          }

          throw new Error(result.message || "Invalid email or password");
        } catch (err) {
          console.error("Login error:", err);
          throw new Error("Authentication failed");
        }
      },
    }),
    CredentialsProvider({
      id: "google-backend",
      name: "Google (Backend)",
      credentials: {},
      async authorize() {
        // NOTE: This won’t be called directly, since Google flow happens in backend.
        // You’ll only use this if you trigger it after your API callback.
        return null;
      },
    }),
  ],

  pages: {
    signIn: "/auth/signin",
    error: "/auth/signin", // Error code passed in query string as ?error=
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
          username: user.username,
          firstName: user.firstName,
          lastName: user.lastName,
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
          const res = await fetch(`${API_URL}/auth/refresh`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ refresh_token: token.refreshToken }),
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

      return session;
    },
  
    async redirect({ url, baseUrl }) {
      // If it’s an internal callback, just go to the dashboard
      if (url.startsWith(baseUrl)) {
        return `${baseUrl} `;
      }
      return baseUrl;
    },
  },
  secret: process.env.NEXTAUTH_SECRET,
  debug: true,
  // debug: process.env.NODE_ENV !== "production",
};

