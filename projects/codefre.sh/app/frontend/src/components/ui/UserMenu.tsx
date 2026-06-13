"use client";
import * as React from "react";
import Link from "next/link";
import { useAuth } from "@/context/auth";
import { cyAttrs } from "@/utils/cypress";

export interface UserMenuProps {
  orgId?: string;
  cy?: string;
}

/**
 * User menu — avatar/initial + popover with Settings + Log out.
 * Settings lives here (not in nav) per Phase B IA.
 */
export function UserMenu({ orgId, cy = "user-menu" }: UserMenuProps) {
  const { user, logout } = useAuth();
  const [open, setOpen] = React.useState(false);
  const rootRef = React.useRef<HTMLDivElement>(null);

  React.useEffect(() => {
    if (!open) return;
    const onDown = (e: MouseEvent) => {
      if (!rootRef.current) return;
      if (!rootRef.current.contains(e.target as Node)) setOpen(false);
    };
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") setOpen(false);
    };
    document.addEventListener("mousedown", onDown);
    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("mousedown", onDown);
      document.removeEventListener("keydown", onKey);
    };
  }, [open]);

  if (!user) return null;
  const initial = user.email.slice(0, 1).toUpperCase();

  return (
    <div
      ref={rootRef}
      style={{ position: "relative" }}
      {...cyAttrs({ cy })}
    >
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        aria-haspopup="menu"
        aria-expanded={open}
        aria-label="User menu"
        className="sg-user-menu-trigger"
        style={{
          width: 32,
          height: 32,
          borderRadius: "50%",
          background: "var(--copper)",
          color: "var(--bg-void)",
          border: "none",
          fontWeight: 600,
          fontSize: 13,
          cursor: "pointer",
          display: "inline-flex",
          alignItems: "center",
          justifyContent: "center",
        }}
        {...cyAttrs({ cy: "user-menu-trigger" })}
      >
        {initial}
      </button>
      {open ? (
        <div
          role="menu"
          className="sg-popover"
          style={{
            position: "absolute",
            top: "calc(100% + 6px)",
            right: 0,
            minWidth: 220,
            background: "var(--bg-elevated)",
            border: "1px solid var(--border-default)",
            borderRadius: "var(--radius-md)",
            boxShadow: "var(--shadow-3)",
            padding: "var(--space-2)",
            zIndex: 70,
          }}
          {...cyAttrs({ cy: "user-menu-popover" })}
        >
          <div
            style={{
              padding: "var(--space-2) var(--space-3)",
              fontSize: "var(--text-small)",
              color: "var(--text-secondary)",
              borderBottom: "1px solid var(--border-subtle)",
              marginBottom: "var(--space-2)",
              overflow: "hidden",
              textOverflow: "ellipsis",
              whiteSpace: "nowrap",
            }}
          >
            {user.email}
          </div>
          {orgId ? (
            <Link
              href={`/app/${orgId}/settings`}
              onClick={() => setOpen(false)}
              role="menuitem"
              className="sg-popover__item"
              style={{
                display: "block",
                padding: "var(--space-2) var(--space-3)",
                borderRadius: "var(--radius-sm)",
                fontSize: "var(--text-body)",
                color: "var(--text-primary)",
                textDecoration: "none",
              }}
              {...cyAttrs({ cy: "user-menu-settings" })}
            >
              Settings
            </Link>
          ) : null}
          <button
            type="button"
            role="menuitem"
            onClick={() => {
              setOpen(false);
              logout();
            }}
            className="sg-popover__item"
            style={{
              display: "block",
              width: "100%",
              textAlign: "left",
              padding: "var(--space-2) var(--space-3)",
              borderRadius: "var(--radius-sm)",
              fontSize: "var(--text-body)",
              color: "var(--text-primary)",
              background: "transparent",
              border: "none",
              cursor: "pointer",
            }}
            {...cyAttrs({ cy: "user-menu-logout" })}
          >
            Log out
          </button>
        </div>
      ) : null}
    </div>
  );
}
