import { auth } from "../../../auth";
import { NextResponse } from "next/server";

const backendUrl = process.env.BACKEND_URL || "http://localhost:4040";

export async function GET() {
  const session = await auth();
  if (!session) return NextResponse.json({ error: "unauthorized" }, { status: 401 });

  const sub = session.user.oidc_sub;
  if (!sub) return NextResponse.json({ error: "no oidc_sub" }, { status: 400 });

  const res = await fetch(`${backendUrl}/api/auth/profile?sub=${encodeURIComponent(sub)}`);
  const data = await res.json();
  return NextResponse.json(data, { status: res.status });
}

export async function PUT(request) {
  const session = await auth();
  if (!session) return NextResponse.json({ error: "unauthorized" }, { status: 401 });

  const sub = session.user.oidc_sub;
  if (!sub) return NextResponse.json({ error: "no oidc_sub" }, { status: 400 });

  const body = await request.json();
  const res = await fetch(`${backendUrl}/api/auth/profile`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ sub, name: body.name, role: body.role, bio: body.bio }),
  });
  const data = await res.json();
  return NextResponse.json(data, { status: res.status });
}
