/**
 * TRP item-timeline embed (W7 v2 reverse exchange) — server-only config +
 * proxy path helpers.
 *
 * The embed consumes a TRP-authored Lit component with a shared TRP API key.
 * The key lives ONLY in server env (TRP_EMBED_API_KEY): the browser never sees
 * it — both the component bundle and the item/activity data flow through the
 * same-origin proxy route handler at /api/trp-board/*, which attaches the key
 * server-side ("host page proxies fetches server-side", per
 * docs/api/shared-key-api.md §6/§9).
 *
 * Missing config ⇒ embed disabled with a graceful empty state; nothing throws.
 */

/** Same-origin prefix that maps onto the TRP host (route handler in src/app/api/trp-board). */
export const TRP_PROXY_BASE = "/api/trp-board";

export interface TrpEmbedConfig {
  /** TRP app host, e.g. https://app.therobotplans.com (trailing slashes trimmed). */
  baseUrl: string;
  /** Component name; also the bundle's directory + file stem on the TRP host. */
  componentName: string;
  /** Shared API key minted by TRP — server-only, never serialized to the client. */
  apiKey: string;
  /** Optional org override; falls back to the route's [orgId] segment. */
  orgIdOverride: string | null;
}

/**
 * Read the embed config from env. Returns null (embed disabled) when the TRP
 * host or the shared key is not provisioned (W10 wires Infisical).
 */
export function trpEmbedConfig(env: NodeJS.ProcessEnv = process.env): TrpEmbedConfig | null {
  const baseUrl = (env.TRP_COMPONENT_BASE_URL || "").trim().replace(/\/+$/, "");
  const apiKey = (env.TRP_EMBED_API_KEY || "").trim();
  if (!baseUrl || !apiKey) return null;

  const componentName = (env.TRP_COMPONENT_NAME || "trp-item-timeline").trim();
  const orgIdOverride = (env.TRP_EMBED_ORG_ID || "").trim() || null;
  return { baseUrl, componentName, apiKey, orgIdOverride };
}

/**
 * Component bundle URL on the TRP host. TRP serves bundles as public static
 * assets from its Next.js public dir (docs/api/shared-key-api.md §9):
 * /components/<name>/<name>.js — no key needed for the asset itself.
 */
export function trpBundleUrl(config: TrpEmbedConfig): string {
  return `${config.baseUrl}/components/${encodeURIComponent(config.componentName)}/${encodeURIComponent(config.componentName)}.js`;
}

/**
 * Map a proxy route's catch-all segments onto an upstream action.
 *
 *   ["component-bundle"]                              → { kind: "bundle" }
 *   ["api","v1","organizations", ...]                 → { kind: "data", path }
 *   anything else (incl. any ".." traversal attempt)  → null (404)
 */
export function resolveProxySegments(
  segments: string[]
): { kind: "bundle" } | { kind: "data"; path: string } | null {
  if (segments.some((s) => s === ".." || s.includes("/") || s.trim() === "")) return null;

  if (segments.length === 1 && segments[0] === "component-bundle") return { kind: "bundle" };

  if (
    segments.length >= 4 &&
    segments[0] === "api" &&
    segments[1] === "v1" &&
    segments[2] === "organizations"
  ) {
    return { kind: "data", path: `/${segments.join("/")}` };
  }

  return null;
}

/** Upstream URL for a resolved proxy action. */
export function upstreamUrl(config: TrpEmbedConfig, resolved: ReturnType<typeof resolveProxySegments>): string | null {
  if (!resolved) return null;
  if (resolved.kind === "bundle") return trpBundleUrl(config);
  return `${config.baseUrl}${resolved.path}`;
}

/** Proxy access gate: same session-cookie presence the middleware requires for /app/*. */
export function proxyAccessAllowed(hasSessionCookie: boolean): boolean {
  return hasSessionCookie;
}
