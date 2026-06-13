"use client";
import * as React from "react";
import { Button } from "@/components/ui";
import type { ScriptNodeKind } from "@/lib/api";
import { cyAttrs } from "@/utils/cypress";

export interface NodePaletteItem {
  kind: ScriptNodeKind;
  label: string;
  accent: string;
  glyph: React.ReactNode;
}

/** 56 px left rail palette. Each button adds a node of the given kind. */
export interface NodePaletteProps {
  items: readonly NodePaletteItem[];
  onAdd: (kind: ScriptNodeKind) => void;
  edgeSourceActive?: boolean;
  onCancelEdgeSource?: () => void;
}

export function NodePalette({
  items,
  onAdd,
  edgeSourceActive,
  onCancelEdgeSource,
}: NodePaletteProps) {
  return (
    <aside
      className="sg-scripts-editor__palette"
      aria-label="Add node"
      data-cy="script-palette"
    >
      {items.map(({ kind, label, accent, glyph }) => (
        <Button
          key={kind}
          variant="ghost"
          size="sm"
          onClick={() => onAdd(kind)}
          title={label}
          aria-label={`Add ${label}`}
          cy="palette-add-node"
          cyId={kind}
          style={{ borderLeft: `3px solid ${accent}` }}
        >
          <span aria-hidden="true">{glyph}</span>
        </Button>
      ))}
      {edgeSourceActive ? (
        <button
          type="button"
          className="sg-btn sg-btn--ghost sg-btn--sm"
          onClick={onCancelEdgeSource}
          aria-label="Cancel edge source"
          {...cyAttrs({ cy: "edge-source-cancel" })}
          style={{ marginTop: "auto", color: "var(--eval-freeball)" }}
          title="Cancel edge source"
        >
          ✕
        </button>
      ) : null}
    </aside>
  );
}

/** Lucide-ish icon glyphs for each node kind. 18px, 1.5 stroke. */
export const NODE_GLYPHS: Record<ScriptNodeKind, React.ReactElement> = {
  user_turn: (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="8" r="4" />
      <path d="M4 21a8 8 0 0116 0" />
    </svg>
  ),
  assistant_turn: (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round">
      <circle cx="12" cy="12" r="8" />
      <circle cx="12" cy="12" r="3" fill="currentColor" stroke="none" />
    </svg>
  ),
  system: (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      <rect x="4" y="5" width="16" height="14" rx="2" />
      <line x1="8" y1="10" x2="16" y2="10" />
      <line x1="8" y1="14" x2="13" y2="14" />
    </svg>
  ),
  terminal: (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round">
      <circle cx="12" cy="12" r="7" />
      <circle cx="12" cy="12" r="3.5" fill="currentColor" stroke="none" />
    </svg>
  ),
  freeball_anchor: (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      <rect x="4" y="5" width="16" height="14" rx="3" strokeDasharray="4 3" />
      <path d="M10 14l4.5-4.5" />
      <path d="M11.5 9.5h3v3" />
    </svg>
  ),
};

/** Default palette set with Forge eval-family accents per kind. */
export const DEFAULT_PALETTE_ITEMS: readonly NodePaletteItem[] = [
  { kind: "user_turn", label: "User turn", accent: "var(--copper)", glyph: NODE_GLYPHS.user_turn },
  { kind: "assistant_turn", label: "Assistant turn", accent: "var(--eval-pass)", glyph: NODE_GLYPHS.assistant_turn },
  { kind: "system", label: "System", accent: "var(--text-secondary)", glyph: NODE_GLYPHS.system },
  { kind: "terminal", label: "Terminal", accent: "var(--eval-fail)", glyph: NODE_GLYPHS.terminal },
  { kind: "freeball_anchor", label: "Freeball anchor", accent: "var(--eval-freeball)", glyph: NODE_GLYPHS.freeball_anchor },
] as const;
