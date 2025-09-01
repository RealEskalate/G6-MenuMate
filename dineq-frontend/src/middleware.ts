// import { withAuth } from "next-auth/middleware";
// import { NextResponse } from "next/server";
// // import type { NextRequest } from "next/server";
// import type { NextRequestWithAuth } from "next-auth/middleware"; 
// export default withAuth(
//   async function middleware(request: NextRequestWithAuth) {
//     const token = request.nextauth.token;
//     const pathname = request.nextUrl.pathname;

//     console.log("Middleware triggered, token:", token);
//     console.log("Middleware pathname:", pathname);

//     if (!token) {
//       console.log(
//         `Middleware: No token, redirecting to /signin from ${pathname}`
//       );
//       return NextResponse.redirect(new URL("/signin", request.nextUrl.origin));
//     }

//     const role = token.role as string;
//     console.log("Middleware role:", role);

//     const roleRedirects: { [key: string]: string } = {
//       OWNER: "/restaurant/dashboard",
//       user: "/user", // Add mapping for API's "user" role
//     };

//     const redirectUrl = roleRedirects[role] || "/dashboard";
//     console.log("Middleware redirectUrl:", redirectUrl);

//     if (
//       pathname === "/dashboard/menu" ||
//       pathname.startsWith("/dashboard/menu")
//     ) {
//       if (!role) {
//         console.log("Middleware: No role defined, redirecting to /dashboard");
//         return NextResponse.redirect(new URL("/dashboard", request.nextUrl.origin));
//       }
//       console.log(`Middleware: Redirecting ${role} to ${redirectUrl}`);
//       return NextResponse.redirect(new URL(redirectUrl, request.nextUrl.origin));
//     }

//     if (pathname.startsWith("/restaurant") && role !== "OWNER") {
//       console.log(
//         `Middleware: Unauthorized restaurant access by ${role}, redirecting to ${redirectUrl}`
//       );
//       return NextResponse.redirect(new URL(redirectUrl, request.url));
//     }
//     if (
//       pathname.startsWith("/user") &&
//       role !== "user"
//     ) {
//       console.log(
//         `Middleware: Unauthorized user access by ${role}, redirecting to ${redirectUrl}`
//       );
//       return NextResponse.redirect(new URL(redirectUrl, request.nextUrl.origin));
//     }

//     console.log("Middleware: Allowing access to", pathname);
//     return NextResponse.next();
//   },
//   {
//     callbacks: {
//       authorized: ({ token }) => {
//         console.log("Middleware authorized check, token exists:", !!token);
//         return !!token;
//       },
//     },
//     pages: {
//       signIn: "/signin",
//     },
//   }
// );

// export const config = {
//   matcher: ["/restaurant/:path*", "/user/:path*", "/dashboard/:path*"],
// };
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

