/**
 * Shared row-id generation for kit editors (F4). Row ids key editor state
 * (rule rows, group rows) and must be unique per entry — they are NOT DOM
 * ids; components keep React `useId()` for label/input wiring.
 *
 * Prefers `crypto.randomUUID()` (stable uniqueness across module reloads,
 * tabs, and SSR/client boundaries); falls back to a monotonic counter when
 * the crypto API is unavailable (old runtimes, insecure contexts).
 */

let counter = 0;

export function newRowId(prefix = 'row'): string {
  if (typeof globalThis.crypto?.randomUUID === 'function') {
    return `${prefix}-${globalThis.crypto.randomUUID()}`;
  }
  counter += 1;
  return `${prefix}-${Date.now().toString(36)}-${counter}`;
}
