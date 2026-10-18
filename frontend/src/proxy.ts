import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

function withPrivateCache(response: NextResponse) {
  response.headers.set("Cache-Control", "private, no-store, max-age=0");
  response.headers.set("Vary", "Cookie");
  return response;
}

// NPL conventions are public for every org: the page only reads the open
// /api/v1/npl/* endpoints (router.ex "public, read-only YAML" scope), so the
// cookie-presence gate must not bounce anonymous visitors to /login. One
// segment for <orgId>, plus any trailing subpath.
const PUBLIC_APP_PATH = /^\/app\/[^/]+\/npl-conventions(\/|$)/;

function withPublicCache(response: NextResponse) {
  // The page is client-rendered, but the shell differs by auth state (the site
  // navbar swaps Sign in for the user menu), so responses stay revalidatable
  // and vary on the cookie.
  response.headers.set("Cache-Control", "public, max-age=0, must-revalidate");
  response.headers.set("Vary", "Cookie");
  return response;
}

export function proxy(request: NextRequest) {
  if (PUBLIC_APP_PATH.test(request.nextUrl.pathname)) {
    return withPublicCache(NextResponse.next());
  }

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
