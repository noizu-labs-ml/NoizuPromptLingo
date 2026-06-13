const COOKIE_NAME = "sg-sections";
const MAX_AGE = 60 * 60 * 24 * 365; // 1 year

export function readAllSectionState(): Record<string, boolean> {
  if (typeof document === "undefined") return {};
  const match = document.cookie.match(
    new RegExp(`(?:^|; )${COOKIE_NAME}=([^;]*)`)
  );
  if (!match) return {};
  try {
    return JSON.parse(decodeURIComponent(match[1]));
  } catch {
    return {};
  }
}

export function writeSectionState(key: string, value: boolean) {
  const state = readAllSectionState();
  state[key] = value;
  document.cookie = `${COOKIE_NAME}=${encodeURIComponent(
    JSON.stringify(state)
  )}; path=/; max-age=${MAX_AGE}; SameSite=Lax`;
}

export function slugify(label: string): string {
  return label.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "");
}

export function sectionAnchor(number: string): string {
  return `section-${number}`;
}

export function groupAnchor(label: string): string {
  return `group-${slugify(label)}`;
}

// ─── Layout persistence ───

const LAYOUT_COOKIE = "sg-layout";

export function readLayout(): string {
  if (typeof document === "undefined") return "";
  const match = document.cookie.match(new RegExp(`(?:^|; )${LAYOUT_COOKIE}=([^;]*)`));
  return match ? decodeURIComponent(match[1]) : "";
}

export function writeLayout(modifier: string) {
  document.cookie = `${LAYOUT_COOKIE}=${encodeURIComponent(modifier)}; path=/; max-age=${MAX_AGE}; SameSite=Lax`;
}

// ─── Color mode persistence ───

const COLOR_MODE_KEY = "color-mode";

export function readColorMode(): string {
  if (typeof window === "undefined" || typeof localStorage?.getItem !== "function") return "";
  return localStorage.getItem(COLOR_MODE_KEY) || "";
}

export function writeColorMode(mode: string) {
  if (typeof window === "undefined" || typeof localStorage?.getItem !== "function") return;
  localStorage.setItem(COLOR_MODE_KEY, mode);
}

// ─── Theme persistence ───

const THEME_KEY = "sg-theme";

export function readTheme(): string {
  if (typeof window === "undefined" || typeof localStorage?.getItem !== "function") return "";
  return localStorage.getItem(THEME_KEY) || "";
}

export function writeTheme(slug: string) {
  if (typeof window === "undefined" || typeof localStorage?.getItem !== "function") return;
  localStorage.setItem(THEME_KEY, slug);
}
