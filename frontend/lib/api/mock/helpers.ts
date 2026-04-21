/**
 * Deterministic seeded helpers for generating mock data.
 *
 * Using a seeded PRNG ensures the UI looks the same across reloads,
 * which matters for snapshot tests and visual stability.
 */

/**
 * Mulberry32 — fast 32-bit PRNG. Good enough for mocks.
 */
export function makeRandom(seed: number) {
  let state = seed >>> 0;
  return () => {
    state = (state + 0x6d2b79f5) >>> 0;
    let t = state;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 0x100000000;
  };
}

export type Rng = () => number;

export function pick<T>(rng: Rng, items: readonly T[]): T {
  return items[Math.floor(rng() * items.length)];
}

export function pickMany<T>(rng: Rng, items: readonly T[], count: number): T[] {
  const pool = [...items];
  const out: T[] = [];
  for (let i = 0; i < count && pool.length > 0; i++) {
    const idx = Math.floor(rng() * pool.length);
    out.push(pool.splice(idx, 1)[0]);
  }
  return out;
}

export function range(n: number): number[] {
  return Array.from({ length: n }, (_, i) => i);
}

/** ISO timestamp offset N days before "now" (frozen to a fixed date for determinism). */
const MOCK_NOW = new Date("2026-04-21T12:00:00.000Z");

export function daysAgo(days: number): string {
  return new Date(MOCK_NOW.getTime() - days * 86_400_000).toISOString();
}

export function hoursAgo(hours: number): string {
  return new Date(MOCK_NOW.getTime() - hours * 3_600_000).toISOString();
}

export function minutesAgo(minutes: number): string {
  return new Date(MOCK_NOW.getTime() - minutes * 60_000).toISOString();
}

/** Generate a shortuuid-like lowercase base62 string of fixed length. */
export function shortUuid(rng: Rng, length = 8): string {
  const alphabet = "abcdefghijklmnopqrstuvwxyz0123456789";
  let out = "";
  for (let i = 0; i < length; i++) {
    out += alphabet[Math.floor(rng() * alphabet.length)];
  }
  return out;
}

export function slug(rng: Rng, words: readonly string[], count = 3): string {
  return pickMany(rng, words, count).join("-");
}
