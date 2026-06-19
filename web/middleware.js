import { auth } from "./auth";

export async function middleware(request) {
  const session = await auth();
  const { pathname } = request.nextUrl;

  // Public routes — no auth required
  if (pathname === "/" || pathname === "/login") {
    return;
  }

  // Protected routes — redirect to landing if not authenticated
  if (!session) {
    return Response.redirect(new URL("/", request.url));
  }

  // Redirect to profile setup if profile is incomplete (but not if already on /profile)
  if (session.user?.profileComplete === false && pathname !== "/profile") {
    return Response.redirect(new URL("/profile", request.url));
  }
}

export const config = {
  matcher: ["/((?!api/auth|api/|_next/static|_next/image|favicon.ico).*)"],
};
