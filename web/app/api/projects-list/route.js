import { NextResponse } from "next/server";

const BACKEND_URL = process.env.BACKEND_URL || "http://localhost:4040";

export async function GET() {
  try {
    const res = await fetch(`${BACKEND_URL}/api/projects`, {
      headers: { "Content-Type": "application/json" },
      cache: "no-store",
    });
    if (!res.ok) return NextResponse.json({ projects: [] });
    const data = await res.json();
    return NextResponse.json(data);
  } catch {
    return NextResponse.json({ projects: [] });
  }
}
