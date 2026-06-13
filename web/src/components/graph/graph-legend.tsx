import * as React from "react";

export function GraphLegend() {
  return (
    <div className="flex items-center gap-6 px-4 py-2 border-t border-rule bg-surface">
      {/* Canon */}
      <div className="flex items-center gap-2">
        <div
          className="w-8 h-5 bg-surface rounded-sm border border-rule"
          style={{ borderLeft: "3px solid #1A1714" }}
        />
        <span className="font-mono text-[11px] uppercase tracking-[0.04em] text-ink-secondary">
          Canon
        </span>
      </div>

      {/* Generated */}
      <div className="flex items-center gap-2">
        <div
          className="w-8 h-5 bg-surface rounded-sm border border-rule"
          style={{ borderLeft: "3px dashed #8B7355" }}
        />
        <span className="font-mono text-[11px] uppercase tracking-[0.04em] text-ink-secondary">
          Generated
        </span>
      </div>

      {/* Flagged */}
      <div className="flex items-center gap-2">
        <div
          className="w-8 h-5 bg-flag-error-muted rounded-sm"
          style={{ border: "1px solid #C4432B" }}
        />
        <span className="font-mono text-[11px] uppercase tracking-[0.04em] text-ink-secondary">
          Flagged
        </span>
      </div>

      {/* Edge */}
      <div className="flex items-center gap-2">
        <svg width="32" height="10" viewBox="0 0 32 10">
          <line
            x1="0"
            y1="5"
            x2="32"
            y2="5"
            stroke="#C4BDB3"
            strokeWidth="1"
            strokeLinecap="round"
          />
        </svg>
        <span className="font-mono text-[11px] uppercase tracking-[0.04em] text-ink-secondary">
          Connection
        </span>
      </div>
    </div>
  );
}
