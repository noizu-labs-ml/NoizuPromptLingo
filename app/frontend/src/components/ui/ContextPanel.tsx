"use client";
import * as React from "react";
import { cyAttrs } from "@/utils/cypress";

export interface ContextPanelProps {
  open: boolean;
  onClose: () => void;
  title?: React.ReactNode;
  children?: React.ReactNode;
  footer?: React.ReactNode;
  className?: string;
  cy?: string;
}

/**
 * 360 px right-slide inspection panel. Esc closes.
 *
 * @example
 * <ContextPanel open={selected !== null} onClose={deselect} title={selected?.name}>
 *   <NodeInspector node={selected} />
 * </ContextPanel>
 */
export function ContextPanel({
  open,
  onClose,
  title,
  children,
  footer,
  className,
  cy = "context-panel",
}: ContextPanelProps) {
  React.useEffect(() => {
    if (!open) return;
    const handleKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        e.preventDefault();
        onClose();
      }
    };
    document.addEventListener("keydown", handleKey);
    return () => document.removeEventListener("keydown", handleKey);
  }, [open, onClose]);

  if (!open) return null;

  return (
    <aside
      role="complementary"
      aria-label={typeof title === "string" ? title : "Context panel"}
      className={["sg-context-panel", className || ""]
        .filter(Boolean)
        .join(" ")}
      {...cyAttrs({ cy })}
    >
      <div className="sg-context-panel__header">
        <div style={{ fontWeight: 600 }}>{title}</div>
        <button
          type="button"
          onClick={onClose}
          className="sg-btn sg-btn--ghost sg-btn--sm"
          aria-label="Close panel"
          {...cyAttrs({ cy: "context-panel-close" })}
        >
          ✕
        </button>
      </div>
      <div className="sg-context-panel__body">{children}</div>
      {footer ? (
        <div
          style={{
            padding: "var(--space-4)",
            borderTop: "1px solid var(--border-subtle)",
          }}
        >
          {footer}
        </div>
      ) : null}
    </aside>
  );
}
