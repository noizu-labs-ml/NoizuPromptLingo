"use client";
import * as React from "react";
import { cyAttrs } from "@/utils/cypress";
import { getGlyph, type GlyphName } from "./glyphs";

export type EmptyGlyphPreset =
  | GlyphName
  | "search"
  | "none";

export interface EmptyStateProps {
  glyph?: React.ReactNode | EmptyGlyphPreset;
  headline: string;
  body?: React.ReactNode;
  primaryAction?: React.ReactNode;
  secondaryAction?: React.ReactNode;
  className?: string;
  cy?: string;
}

/**
 * Fallback presets for names not in the domain-glyph registry.
 */
const fallbackPreset: Record<string, React.ReactElement> = {
  search: (
    <svg
      width="64"
      height="64"
      viewBox="0 0 64 64"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.5"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      <circle cx="28" cy="28" r="14" />
      <line x1="38" y1="38" x2="52" y2="52" />
    </svg>
  ),
  none: <></>,
};

/**
 * Centered empty state — headline, body, actions; optional glyph.
 *
 * `glyph` accepts either a ReactNode (custom) or a string preset.
 * Preset names resolve via the domain glyph registry
 * (see `./glyphs/index.ts`).
 *
 * @example
 * <EmptyState
 *   glyph="scripts"
 *   headline="No scripts yet"
 *   body="Create your first evaluation script."
 *   primaryAction={<Button>+ New</Button>}
 * />
 */
export function EmptyState({
  glyph,
  headline,
  body,
  primaryAction,
  secondaryAction,
  className,
  cy = "empty-state",
}: EmptyStateProps) {
  let renderedGlyph: React.ReactNode = null;
  if (typeof glyph === "string") {
    renderedGlyph = getGlyph(glyph) ?? fallbackPreset[glyph] ?? null;
  } else if (glyph) {
    renderedGlyph = glyph;
  }

  return (
    <div
      className={["sg-empty-state", className || ""].filter(Boolean).join(" ")}
      {...cyAttrs({ cy })}
    >
      {renderedGlyph ? (
        <div className="sg-empty-state__glyph" aria-hidden="true">
          {renderedGlyph}
        </div>
      ) : null}
      <h2
        className="sg-empty-state__headline"
        {...cyAttrs({ cy: "empty-state-headline" })}
      >
        {headline}
      </h2>
      {body ? <p className="sg-empty-state__body">{body}</p> : null}
      {(primaryAction || secondaryAction) && (
        <div className="sg-empty-state__actions">
          {primaryAction}
          {secondaryAction}
        </div>
      )}
    </div>
  );
}
