import { Session, User, JWT } from 'next-auth';

declare module 'next-auth' {
  interface User {
    id?: string;
    email?: string | null;
    name?: string | null;
    image?: string | null;
    role?: 'OWNER' | 'CUSTOMER' ;
    accessToken?: string;
    refreshToken?: string;
  }

  interface Session {
    user: {
      id?: string;
      email?: string | null;
      name?: string | null;
      image?: string | null;
      role?: 'OWNER' | 'CUSTOMER' ;
    };
    accessToken?: string;
    refreshToken?: string;
    exp?: number;
    error?: string;
    errorDetails?: string;
  }
}

declare module 'next-auth/jwt' {
  interface JWT {
    user?: {
      email?: string | null;
      role?: 'OWNER' | 'CUSTOMER' ;
    };
    email?: string | null;
    role?:'OWNER' | 'CUSTOMER' ;
    accessToken?: string;
    refreshToken?: string;
    exp?: number;
    error?: string;
    errorDetails?: string;
  }
}