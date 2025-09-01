import { withAuth } from "next-auth/middleware";
import { NextResponse } from "next/server";
import type { NextRequestWithAuth } from "next-auth/middleware";

const mockMode = true; // 🚨 turn this off once backend is ready

export default withAuth(
  async function middleware(request: NextRequestWithAuth) {
    const token = request.nextauth?.token;
    const pathname = request.nextUrl.pathname;

    console.log("Middleware triggered, pathname:", pathname);

    // ✅ Bypass all auth while backend is not ready
    if (mockMode) {
      console.log("Mock mode active → skipping auth checks");
      return NextResponse.next();
    }

    // 🔒 Actual auth logic (kept for later use)
    if (!token) {
      return NextResponse.redirect(new URL("/signin", request.nextUrl.origin));
    }

    const role = token.role as string;
    const roleRedirects: { [key: string]: string } = {
      OWNER: "/restaurant/dashboard",
      user: "/user",
    };
    const redirectUrl = roleRedirects[role] || "/dashboard";

    if (pathname.startsWith("/restaurant") && role !== "OWNER") {
      return NextResponse.redirect(
        new URL(redirectUrl, request.nextUrl.origin)
      );
    }
    if (pathname.startsWith("/user") && role !== "user") {
      return NextResponse.redirect(
        new URL(redirectUrl, request.nextUrl.origin)
      );
    }

    return NextResponse.next();
  },
  {
    callbacks: {
      authorized: ({ token }) => {
        // while in mockMode, always authorize
        return mockMode ? true : !!token;
      },
    },
    pages: {
      signIn: "/signin",
    },
  }
);

export const config = {
  matcher: ["/restaurant/:path*", "/user/:path*", "/dashboard/:path*"],
};
