import { auth } from "../../../auth";
import { NextResponse } from "next/server";

const backendUrl = process.env.BACKEND_URL || "http://localhost:4040";

async function getUserId(session) {
  const sub = session.user.oidc_sub;
  if (!sub) throw new Error("no oidc_sub in session — re-login required");

  const res = await fetch(`${backendUrl}/api/auth/sync`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      sub,
      email: session.user.email,
      name: session.user.name,
    }),
  });
  if (!res.ok) throw new Error(`sync failed: ${res.status}`);
  return await res.json();
}

export async function POST(request) {
  const session = await auth();
  if (!session) return NextResponse.json({ error: "unauthorized" }, { status: 401 });

  try {
    const user = await getUserId(session);
    const { keyId } = await request.json();

    const res = await fetch(`${backendUrl}/api/mcp/token`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        key_id: keyId,
        user_id: user.id,
        email: user.email,
        name: user.name,
      }),
    });
    const data = await res.json();
    return NextResponse.json(data, { status: res.status });
  } catch (e) {
    return NextResponse.json({ error: e.message }, { status: 400 });
  }
}
