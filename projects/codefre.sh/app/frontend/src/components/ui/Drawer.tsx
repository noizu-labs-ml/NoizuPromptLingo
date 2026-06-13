"use client";
import * as React from "react";
import { cyAttrs } from "@/utils/cypress";

export interface DrawerProps {
  open: boolean;
  onClose: () => void;
  side?: "left" | "right";
  title?: React.ReactNode;
  children?: React.ReactNode;
  className?: string;
  cy?: string;
}

/**
 * Side-sheet drawer; slides from left (default, mobile nav) or right.
 * Esc closes; overlay click dismisses.
 *
 * @example
 * <Drawer open={open} onClose={close} title="Menu" side="left">
 *   <nav>{links}</nav>
 * </Drawer>
 */
export function Drawer({
  open,
  onClose,
  side = "left",
  title,
  children,
  className,
  cy = "drawer",
}: DrawerProps) {
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

  const classes = [
    "sg-drawer",
    side === "right" ? "sg-drawer--right" : "",
    className || "",
  ]
    .filter(Boolean)
    .join(" ");

  return (
    <>
      <div className="sg-overlay" onClick={onClose} aria-hidden="true" />
      <aside
        className={classes}
        role="dialog"
        aria-modal="true"
        aria-label={typeof title === "string" ? title : undefined}
        {...cyAttrs({ cy })}
      >
        {title ? (
          <div
            style={{
              padding: "var(--space-4)",
              borderBottom: "1px solid var(--border-subtle)",
              fontSize: "var(--text-h3)",
              fontWeight: 600,
            }}
          >
            {title}
          </div>
        ) : null}
        <div
          style={{
            padding: "var(--space-4)",
            overflow: "auto",
            flex: 1,
          }}
        >
          {children}
        </div>
      </aside>
    </>
  );
}
