// Shared helper for the `?state=` contract (UX-PLAN.md §5).

export type ScreenState = "default" | "loading" | "empty" | "error" | "denied" | "suspended";

export type SearchParams = { [key: string]: string | string[] | undefined };

export function resolveState(sp: SearchParams | undefined): ScreenState {
  const raw = sp?.state;
  const value = Array.isArray(raw) ? raw[0] : raw;
  if (value === "loading" || value === "empty" || value === "error" || value === "denied" || value === "suspended") {
    return value;
  }
  return "default";
}
