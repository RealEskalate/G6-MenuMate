import { withAuth } from "next-auth/middleware";
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";
import type { NextRequestWithAuth } from "next-auth/middleware";
export default withAuth(
  async function middleware(request: NextRequestWithAuth) {
    const token = request.nextauth.token;
    const pathname = request.nextUrl.pathname;

    console.log("Middleware triggered, token:", token);
    console.log("Middleware pathname:", pathname);

    if (!token) {
      console.log(
        `Middleware: No token, redirecting to /signin from ${pathname}`
      );
      return NextResponse.redirect(new URL("/signin", request.nextUrl.origin));
    }

    const role = token.role as string;
    console.log("Middleware role:", role);

    const roleRedirects: { [key: string]: string } = {
      OWNER: "/restaurant/dashboard",
      user: "/user", // Add mapping for API's "user" role
    };

    const redirectUrl = roleRedirects[role] || "/dashboard";
    console.log("Middleware redirectUrl:", redirectUrl);

    if (
      pathname === "/dashboard/menu" ||
      pathname.startsWith("/dashboard/menu")
    ) {
      if (!role) {
        console.log("Middleware: No role defined, redirecting to /dashboard");
        return NextResponse.redirect(
          new URL("/dashboard", request.nextUrl.origin)
        );
      }
      console.log(`Middleware: Redirecting ${role} to ${redirectUrl}`);
      return NextResponse.redirect(
        new URL(redirectUrl, request.nextUrl.origin)
      );
    }

    if (pathname.startsWith("/restaurant") && role !== "OWNER") {
      console.log(
        `Middleware: Unauthorized restaurant access by ${role}, redirecting to ${redirectUrl}`
      );
      // Changed request.url to request.nextUrl.origin here
      return NextResponse.redirect(
        new URL(redirectUrl, request.nextUrl.origin)
      );
    }
    if (pathname.startsWith("/user") && role !== "user") {
      console.log(
        `Middleware: Unauthorized user access by ${role}, redirecting to ${redirectUrl}`
      );
      return NextResponse.redirect(
        new URL(redirectUrl, request.nextUrl.origin)
      );
    }

    console.log("Middleware: Allowing access to", pathname);
    return NextResponse.next();
  },
  {
    callbacks: {
      authorized: ({ token }) => {
        console.log("Middleware authorized check, token exists:", !!token);
        return !!token;
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
