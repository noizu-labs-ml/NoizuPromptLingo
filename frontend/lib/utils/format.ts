/**
 * Format an ISO timestamp as a relative time string like "5m ago", "3h ago", "2d ago".
 */
export function relativeTime(iso: string): string {
  const diffMs = Date.now() - new Date(iso).getTime();
  const diffMin = Math.floor(diffMs / 60_000);
  const diffHr = Math.floor(diffMin / 60);
  const diffDay = Math.floor(diffHr / 24);
  const diffMonth = Math.floor(diffDay / 30);

  if (diffMin < 1) return "just now";
  if (diffMin < 60) return `${diffMin}m ago`;
  if (diffHr < 24) return `${diffHr}h ago`;
  if (diffDay < 30) return `${diffDay}d ago`;
  return `${diffMonth}mo ago`;
}

/**
 * Format a large integer with comma separators: 12345 → "12,345".
 */
export function formatNumber(n: number): string {
  return n.toLocaleString();
}

/**
 * Truncate a string to max chars, appending "…" if truncated.
 */
export function truncate(s: string, max: number): string {
  return s.length > max ? s.slice(0, max) + "…" : s;
}
