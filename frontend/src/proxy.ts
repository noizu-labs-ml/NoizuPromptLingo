import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

function withPrivateCache(response: NextResponse) {
  response.headers.set("Cache-Control", "private, no-store, max-age=0");
  response.headers.set("Vary", "Cookie");
  return response;
}

export function proxy(request: NextRequest) {
  const token = request.cookies.get("access_token")?.value;

  if (!token) {
    const loginUrl = new URL("/login", request.url);
    loginUrl.searchParams.set("redirect", request.nextUrl.pathname + request.nextUrl.search);
    return withPrivateCache(NextResponse.redirect(loginUrl));
  }

  return withPrivateCache(NextResponse.next());
}

export const config = {
  matcher: ["/app/:path*"],
};
