import { nanoid, customAlphabet } from 'nanoid';

/**
 * URL-safe short IDs for diagrams and share links.
 * 12 chars from base62 = 62^12 ≈ 3.2 × 10^21 combinations.
 */
const urlSafeId = customAlphabet(
  '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
  12
);

/** Generate a short ID for diagrams (12 chars, URL-safe) */
export function generateDiagramId(): string {
  return urlSafeId();
}

/** Generate a generic ID (21 chars, nanoid default) for internal records */
export function generateId(): string {
  return nanoid();
}
