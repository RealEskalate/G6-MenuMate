import { withAuth } from "next-auth/middleware";
import { NextResponse } from "next/server";
// import type { NextRequest } from "next/server";
import type { NextRequestWithAuth } from "next-auth/middleware";
export default withAuth(
  async function middleware(request: NextRequestWithAuth) {
    const token = request.nextauth.token;
    const pathname = request.nextUrl.pathname;

 
    console.log("Middleware pathname:", pathname);

    if (!token) {
      
      return NextResponse.redirect(
        new URL("/auth/signin", request.nextUrl.origin)
      );
    }

    const role = token.role as string;
    console.log("Middleware role:", role);

    const roleRedirects: { [key: string]: string } = {
      OWNER: "/restaurant/dashboard",
      MANAGER: "/restaurant/dashboard",
      STAFF: "/restaurant/dashboard",
      ADMIN: "/restaurant/dashboard",
      CUSTOMER: "/user",
    };

    const redirectUrl = roleRedirects[role] || "/auth/signin";
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

    if (
      pathname.startsWith("/restaurant") &&
      role !== "OWNER" &&
      role !== "MANAGER" &&
      role !== "STAFF"
    ) {
      return NextResponse.redirect(new URL(redirectUrl, request.url));
    }
    if (pathname.startsWith("/user") && role !== "CUSTOMER") {
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
      signIn: "/auth/signin",
    },
  }
);

export const config = {
  matcher: ["/user/:path*"],
};
