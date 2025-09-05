import CredentialsProvider from "next-auth/providers/credentials";
import type { NextAuthOptions } from "next-auth";

const API_URL = process.env.NEXT_PUBLIC_API_BASE_URL;
console.log("SERVER ENV CHECK:", {
  NEXTAUTH_URL: process.env.NEXTAUTH_URL,
  API_URL: process.env.NEXT_PUBLIC_API_BASE_URL,
});


export const options: NextAuthOptions = {
  providers: [
    CredentialsProvider({
      name: "Credentials",
      credentials: {
        identifier: { label: "Email", type: "email", placeholder: "you@example.com" },
        password: { label: "Password", type: "password" },
      },
      async authorize(credentials) {
        if (!credentials?.identifier || !credentials?.password) {
          throw new Error("Email and password are required");
        }

        const res = await fetch(`${API_URL}/auth/login`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            identifier: credentials.identifier,
            password: credentials.password,
          }),
        });

        const result = await res.json();

        if (res.ok && result?.tokens?.access_token) {
          return {
            id: result.user.id,
            email: result.user.email,
            username: result.user.username,
            firstName: result.user.first_name,
            lastName: result.user.last_name,
            role: result.user.role,
            accessToken: result.tokens.access_token,
            refreshToken: result.tokens.refresh_token,
          };
        }

        throw new Error(result.message || "Invalid email or password");
      },
    }),
  ],

  pages: {
    signIn: "/auth/signin",
    error: "/auth/signin",
  },

  session: { strategy: "jwt", maxAge: 24 * 60 * 60 },

  callbacks: {
    async jwt({ token, user, trigger }) {
      if (user) {
        token.user = {
          email: user.email,
          username: user.username,
          firstName: user.firstName,
          lastName: user.lastName,
          role: user.role,
        };
        token.accessToken = user.accessToken;
        token.refreshToken = user.refreshToken;
        token.exp = Math.floor(Date.now() / 1000) + 15 * 60;
      }

      // Refresh token logic
      if ((trigger === "update" || (token.exp && Date.now() > token.exp * 1000)) && token.refreshToken) {
        try {
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
          token.error = "RefreshAccessTokenError";
          token.errorDetails = err instanceof Error ? err.message : String(err);
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

    // Role-based redirect after sign-in
    async signIn({ user }) {
      if (!user) return false;
      const role = user.role;
      if (role === "CUSTOMER") return "/user";
      if (typeof role === "string" && ["OWNER", "MANAGER", "STAFF", "ADMIN"].includes(role)) return "/restaurant/dashboard/menu";
      return "/auth/signin";
    },

    // Keep redirect callback simple
    redirect({ url, baseUrl }) {
      if (url.startsWith(baseUrl)) return url;
      return baseUrl;
    },
  },

  secret: process.env.NEXTAUTH_SECRET,
  debug: process.env.NODE_ENV !== "production",
};

