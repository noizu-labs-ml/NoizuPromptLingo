import { NextResponse, type NextRequest } from "next/server";
import {
  trpEmbedConfig,
  resolveProxySegments,
  proxyAccessAllowed,
  upstreamUrl,
} from "@/lib/pm/trp-board-embed";

/**
 * Same-origin key proxy for the TRP item-timeline embed (W7 v2 reverse
 * exchange — mirrors /api/npl-board/* from W7 v1).
 *
 *   GET /api/trp-board/component-bundle              → Lit bundle from the TRP host
 *   GET /api/trp-board/api/v1/organizations/...      → items/activity data plane
 *
 * The shared TRP API key (TRP_EMBED_API_KEY) is attached HERE, server-side —
 * it never reaches the browser. Gated on the same access_token cookie the
 * /app/* middleware requires. Data authorization is the key's org scope on
 * the TRP side (shared-key plane, docs/api/shared-key-api.md §1.4).
 */
export const dynamic = "force-dynamic";

export async function GET(request: NextRequest, ctx: { params: Promise<{ path: string[] }> }) {
  if (!proxyAccessAllowed(Boolean(request.cookies.get("access_token")?.value))) {
    return NextResponse.json({ error: "unauthorized" }, { status: 401 });
  }

  const config = trpEmbedConfig();
  if (!config) {
    return NextResponse.json({ error: "trp embed not configured" }, { status: 503 });
  }

  const { path } = await ctx.params;
  const resolved = resolveProxySegments(path ?? []);
  const target = upstreamUrl(config, resolved);
  if (!target) {
    return NextResponse.json({ error: "not found" }, { status: 404 });
  }

  let upstream: Response;
  try {
    upstream = await fetch(target, {
      headers: { Authorization: `Bearer ${config.apiKey}` },
      cache: "no-store",
      signal: request.signal,
    });
  } catch {
    return NextResponse.json({ error: "trp unreachable" }, { status: 502 });
  }

  if (resolved!.kind === "bundle") {
    const body = await upstream.text();
    return new NextResponse(body, {
      status: upstream.status,
      headers: {
        "Content-Type": upstream.headers.get("content-type") || "text/javascript; charset=utf-8",
        // Bundles are immutable per component version.
        "Cache-Control": "private, max-age=3600",
      },
    });
  }

  const body = await upstream.text();
  return new NextResponse(body, {
    status: upstream.status,
    headers: {
      "Content-Type": upstream.headers.get("content-type") || "application/json",
      "Cache-Control": "private, no-store, max-age=0",
    },
  });
}
