import { DefaultSession, DefaultUser } from "next-auth";
import { DefaultJWT } from "next-auth/jwt";

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
      email?: string;
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

declare module "next-auth/jwt" {
  interface JWT extends DefaultJWT {
    user: {
      email?: string;
      username?: string;
      firstName?: string;
      lastName?: string;
      role?: string;
    };
    email?: string;
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
;
