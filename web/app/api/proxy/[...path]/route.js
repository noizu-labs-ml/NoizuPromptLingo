import { NextResponse } from "next/server";
const BACKEND_URL = process.env.BACKEND_URL || "http://localhost:4040";

async function proxyRequest(request, { params }, method) {
  const { path } = await params;
  const apiPath = path.join("/");
  const url = new URL(request.url);
  const qs = url.search;
  const opts = {
    method,
    headers: { "Content-Type": "application/json" },
  };
  if (method !== "GET" && method !== "DELETE") {
    try { opts.body = JSON.stringify(await request.json()); } catch {}
  }
  try {
    const res = await fetch(`${BACKEND_URL}/api/${apiPath}${qs}`, opts);
    const data = await res.json();
    return NextResponse.json(data, { status: res.status });
  } catch (e) {
    return NextResponse.json({ error: e.message }, { status: 502 });
  }
}

export async function GET(req, ctx) { return proxyRequest(req, ctx, "GET"); }
export async function POST(req, ctx) { return proxyRequest(req, ctx, "POST"); }
export async function PUT(req, ctx) { return proxyRequest(req, ctx, "PUT"); }
export async function DELETE(req, ctx) { return proxyRequest(req, ctx, "DELETE"); }
