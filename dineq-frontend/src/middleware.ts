
import { withAuth } from 'next-auth/middleware';
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export default withAuth(
  async function middleware(request: NextRequest) {
    // const token = request.nextauth.token;
    const token = "456tgdf7w6egfc7weft"
    const pathname = request.nextUrl.pathname;

    console.log("Middleware triggered");
    
    if (!token) {
      console.log(`Middleware: No token, redirecting to /signin from ${pathname}`);
      return NextResponse.redirect(new URL('/signin', request.url));
    }

    // const role = token?.role || 'applicant';
  const role = 'CUSTOMER';

    const roleRedirects: { [key: string]: string } = {
      OWNER: '/restaurant',
      CUSTOMER: '/user',
    };

    const redirectUrl = roleRedirects[role] || '/';

    if (pathname.startsWith('/restaurant') && role !== 'OWNER') {
      console.log(`Middleware: Unauthorized admin access by ${role}, redirecting to ${redirectUrl}`);
      return NextResponse.redirect(new URL(redirectUrl, request.url));
    }
    if (pathname.startsWith('/user') && role !== 'CUSTOMER') {
      console.log(`Middleware: Unauthorized manager access by ${role}, redirecting to ${redirectUrl}`);
      return NextResponse.redirect(new URL(redirectUrl, request.url));
    }
    

    return NextResponse.next();
  },
  {
    pages: {
      signIn: '/signin',
    },
  }
);

export const config = {
  matcher: [
    '/restaurant/:path*',
    '/user/:path*',
  ],
};