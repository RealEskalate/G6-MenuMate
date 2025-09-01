
import { DefaultSession, DefaultUser } from "next-auth";
import { DefaultJWT } from "next-auth/jwt";
import { NextRequest } from "next/server";

declare module "next-auth" {
  interface User extends DefaultUser {
    username?: string;
    firstName?: string;
    lastName?: string;
    role?: string;
    accessToken?: string;
    refreshToken?: string | null;
  }

  interface Session extends DefaultSession {
    user: {
      id?: string;
      email?: string|null;
      username?: string;
      firstName?: string;
      lastName?: string;
      role?: string;
    };
    accessToken?: string;
    refreshToken?: string | null;
    exp?: number;
    error?: string;
    errorDetails?: string;
  }
}

// Extend next-auth/jwt JWT
declare module "next-auth/jwt" {
  interface JWT extends DefaultJWT {
    user: {
      email?: string | null;
      username?: string;
      firstName?: string;
      lastName?: string;
      role?: string;
    };
    email?: string|null;
    username?: string;
    firstName?: string;
    lastName?: string;
    role?: string;
    accessToken?: string;
    refreshToken?: string | null;
    exp?: number;
    error?: string;
    errorDetails?: string;
  }
}

// Extend NextRequest to include nextauth
declare module "next/server" {
  interface NextRequest {
    nextauth: {
      token: {
        user?: {
          email?: string|null;
          username?: string;
          firstName?: string;
          lastName?: string;
          role?: string;
        };
        email?: string|null;
        username?: string;
        firstName?: string;
        lastName?: string;
        role?: string;
        accessToken?: string;
        refreshToken?: string | null;
        exp?: number;
        error?: string;
        errorDetails?: string;
      } | null;
    };
  }
}
