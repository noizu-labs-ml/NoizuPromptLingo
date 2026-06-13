import { auth } from "../../../auth";
import { NextResponse } from "next/server";

const backendUrl = process.env.BACKEND_URL || "http://localhost:4040";

async function getUserId(session) {
  const sub = session.user.oidc_sub;
  if (!sub) {
    throw new Error("no oidc_sub in session — re-login required");
  }
  const res = await fetch(`${backendUrl}/api/auth/sync`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      sub,
      email: session.user.email,
      name: session.user.name,
    }),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`sync failed: ${res.status} ${text}`);
  }
  const data = await res.json();
  return data.id;
}

export async function GET() {
  const session = await auth();
  if (!session) return NextResponse.json({ error: "unauthorized" }, { status: 401 });

  try {
    const userId = await getUserId(session);
    const res = await fetch(`${backendUrl}/api/keys/${userId}`);
    const data = await res.json();
    return NextResponse.json(data);
  } catch (e) {
    return NextResponse.json({ error: e.message }, { status: 400 });
  }
}

export async function POST(request) {
  const session = await auth();
  if (!session) return NextResponse.json({ error: "unauthorized" }, { status: 401 });

  try {
    const userId = await getUserId(session);
    const body = await request.json();

    const res = await fetch(`${backendUrl}/api/keys`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ user_id: userId, label: body.label || "default" }),
    });
    const data = await res.json();
    return NextResponse.json(data, { status: res.status });
  } catch (e) {
    return NextResponse.json({ error: e.message }, { status: 400 });
  }
}

export async function DELETE(request) {
  const session = await auth();
  if (!session) return NextResponse.json({ error: "unauthorized" }, { status: 401 });

  try {
    const userId = await getUserId(session);
    const { keyId } = await request.json();

    const res = await fetch(`${backendUrl}/api/keys/${keyId}`, {
      method: "DELETE",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ user_id: userId }),
    });
    const data = await res.json();
    return NextResponse.json(data, { status: res.status });
  } catch (e) {
    return NextResponse.json({ error: e.message }, { status: 400 });
  }
}
