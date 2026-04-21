/**
 * Typography const maps for NPL Studio.
 *
 * Import these rather than re-typing long className strings.
 * Every value is composed of Tailwind classes that resolve to tokens
 * defined in tailwind.config.ts / globals.css.
 *
 *   import { heading, text } from "@/lib/ui/typography";
 *   <h1 className={heading.display}>Title</h1>
 *   <p className={text.muted}>Subtle body copy.</p>
 */

export const heading = {
  /** Page titles (h1) — 2.25rem, 600 weight, tight tracking. */
  display: "text-display font-sans text-foreground",

  /** Section headers (h2) — 1.125rem. */
  title: "text-title font-sans text-foreground",

  /** Card / panel titles (h3) — 0.875rem, medium weight. */
  heading: "text-heading font-sans text-foreground",

  /** Uppercase eyebrow labels — filter captions, stat keys. */
  label: "text-label font-sans uppercase text-subtle",
} as const;

export const text = {
  /** Default body. */
  default: "text-sm text-foreground",

  /** Secondary copy (muted gray). */
  muted: "text-sm text-muted",

  /** Tertiary copy — captions, timestamps, hints. */
  subtle: "text-xs text-subtle",

  /** Inline mono — IDs, short code references. */
  mono: "text-xs font-mono text-muted",

  /** Descriptive body (slightly larger than default). */
  body: "text-sm leading-relaxed text-foreground",

  /** Lead copy — first paragraph under a display heading. */
  lead: "text-base leading-relaxed text-muted",
} as const;

/** Unified focus-ring helper. Use on every interactive element. */
export const focusRing =
  "outline-none focus-visible:shadow-ring focus-visible:border-accent transition-shadow";

/**
 * Density profile helpers — used by Card and ListRow.
 * Values are padding shortcuts; composition lets downstream callers
 * still append margins/gaps without collision.
 */
export const density = {
  compact:  "p-3",
  normal:   "p-4",
  spacious: "p-6",
} as const;
export type Density = keyof typeof density;
