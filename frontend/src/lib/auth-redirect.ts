export const AUTH_COOKIE_MAX_AGE_SEC = 60 * 60 * 24 * 7;
export const AUTH_REDIRECT_STORAGE_KEY = "npl_auth_redirect";

export function safePostLoginPath(raw: string | null | undefined, fallback = "/app"): string {
  if (!raw) return fallback;
  const path = raw.trim();
  if (!path.startsWith("/")) return fallback;
  if (path.startsWith("//") || path.startsWith("/\\")) return fallback;
  if (path.includes("://")) return fallback;
  return path;
}

export function rememberAuthRedirect(path: string | null | undefined) {
  if (typeof window === "undefined") return;
  const safe = safePostLoginPath(path, "");
  try {
    if (!safe || safe === "/app") sessionStorage.removeItem(AUTH_REDIRECT_STORAGE_KEY);
    else sessionStorage.setItem(AUTH_REDIRECT_STORAGE_KEY, safe);
  } catch {
    /* private mode */
  }
}

export function takeAuthRedirect(fallback = "/app"): string {
  if (typeof window === "undefined") return fallback;
  try {
    const stored = sessionStorage.getItem(AUTH_REDIRECT_STORAGE_KEY);
    sessionStorage.removeItem(AUTH_REDIRECT_STORAGE_KEY);
    return safePostLoginPath(stored, fallback);
  } catch {
    return fallback;
  }
}

function cookieSecureAttribute() {
  if (typeof window === "undefined") return "";
  return window.location.protocol === "https:" ? "; Secure" : "";
}

export function authCookieSetSuffix() {
  return `; path=/; max-age=${AUTH_COOKIE_MAX_AGE_SEC}; SameSite=Lax${cookieSecureAttribute()}${cookieDomainAttribute()}`;
}

export function authCookieClearSuffix() {
  return `; path=/; max-age=0; SameSite=Lax${cookieSecureAttribute()}${cookieDomainAttribute()}`;
}

/** Share the session cookie across MCP subdomains (wiki.tobor.locker, …). */
export function cookieDomainAttribute() {
  if (typeof window === "undefined") return "";
  const host = window.location.hostname.toLowerCase();
  if (host === "localhost" || host.endsWith(".local") || /^\d+\.\d+\.\d+\.\d+$/.test(host)) {
    return "";
  }
  const fromEnv = (window as unknown as { __ENV?: { COOKIE_DOMAIN?: string } }).__ENV?.COOKIE_DOMAIN?.trim();
  if (fromEnv) {
    const normalized = fromEnv.replace(/^\./, "").toLowerCase();
    if (host === normalized || host.endsWith(`.${normalized}`)) {
      return `; Domain=${fromEnv.startsWith(".") ? fromEnv : `.${fromEnv}`}`;
    }
  }
  const parts = host.split(".");
  if (parts.length < 2) return "";
  return `; Domain=.${parts.slice(-2).join(".")}`;
}
