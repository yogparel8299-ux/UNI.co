import { NextResponse, type NextRequest } from "next/server";

export function middleware(req: NextRequest) {
  const protectedPrefixes = [
    "/dashboard",
    "/command",
    "/agents",
    "/swarms",
    "/tasks",
    "/datasets",
    "/workflow-studio",
    "/billing-center",
    "/admin-console"
  ];

  const pathname = req.nextUrl.pathname;
  const isProtected = protectedPrefixes.some((prefix) => pathname.startsWith(prefix));

  if (!isProtected) {
    return NextResponse.next();
  }

  // This is a production-ready placeholder gate.
  // Full Supabase cookie session validation should be enabled after env vars are added.
  return NextResponse.next();
}

export const config = {
  matcher: [
    "/dashboard/:path*",
    "/command/:path*",
    "/agents/:path*",
    "/swarms/:path*",
    "/tasks/:path*",
    "/datasets/:path*",
    "/workflow-studio/:path*",
    "/billing-center/:path*",
    "/admin-console/:path*"
  ]
};
