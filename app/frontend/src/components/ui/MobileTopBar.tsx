"use client";
import * as React from "react";
import Link from "next/link";
import { cyAttrs } from "@/utils/cypress";
import { UserMenu } from "./UserMenu";
import type { TopBarNavItem } from "./TopBar";

export interface MobileTopBarProps {
  base: string;
  orgId: string;
  navOpen: boolean;
  setNavOpen: (v: boolean) => void;
  navItems: TopBarNavItem[];
  onOpenPalette: () => void;
}

/**
 * Mobile (<768px) version of the top bar: logo + hamburger + palette + user.
 * Hamburger opens a slide-in left drawer with the nav items.
 */
export function MobileTopBar({
  base,
  orgId,
  navOpen,
  setNavOpen,
  navItems,
  onOpenPalette,
}: MobileTopBarProps) {
  return (
    <>
      <header
        className="sg-topbar"
        style={{ justifyContent: "space-between" }}
        {...cyAttrs({ cy: "topbar-mobile" })}
      >
        <div className="sg-topbar__group">
          <button
            type="button"
            onClick={() => setNavOpen(!navOpen)}
            aria-label="Open menu"
            aria-expanded={navOpen}
            className="sg-btn sg-btn--ghost sg-btn--sm"
            {...cyAttrs({ cy: "topbar-hamburger" })}
          >
            <span style={{ fontSize: 18, lineHeight: 1 }}>≡</span>
          </button>
          <Link
            href={base}
            className="sg-topbar__logo"
            {...cyAttrs({ cy: "topbar-logo-mobile" })}
          >
            codefre<span className="sg-topbar__logo-dot">.</span>sh
          </Link>
        </div>
        <div className="sg-topbar__group">
          <button
            type="button"
            onClick={onOpenPalette}
            aria-label="Open command palette"
            className="sg-btn sg-btn--ghost sg-btn--sm"
            {...cyAttrs({ cy: "palette-trigger-mobile" })}
          >
            <span style={{ fontFamily: "var(--font-mono)", fontSize: 12 }}>
              ⌘K
            </span>
          </button>
          <UserMenu orgId={orgId} />
        </div>
      </header>
      {navOpen ? (
        <>
          <div
            className="sg-overlay"
            onClick={() => setNavOpen(false)}
            aria-hidden="true"
          />
          <aside
            role="dialog"
            aria-label="Mobile navigation"
            style={{
              position: "fixed",
              top: 0,
              left: 0,
              bottom: 0,
              width: 280,
              background: "var(--bg-elevated)",
              borderRight: "1px solid var(--border-default)",
              zIndex: 80,
              padding: "var(--space-4)",
              overflowY: "auto",
            }}
            {...cyAttrs({ cy: "mobile-nav-drawer" })}
          >
            <nav style={{ display: "flex", flexDirection: "column", gap: 4 }}>
              {navItems.map((n) => (
                <Link
                  key={n.href}
                  href={n.href}
                  onClick={() => setNavOpen(false)}
                  className={[
                    "sg-nav-tab",
                    n.active ? "sg-nav-tab--active" : "",
                  ]
                    .filter(Boolean)
                    .join(" ")}
                  style={{
                    display: "block",
                    padding: "var(--space-3) var(--space-4)",
                    border: "none",
                    borderRadius: "var(--radius-sm)",
                  }}
                  {...cyAttrs({
                    cy: "mobile-nav-item",
                    cyId: n.label.toLowerCase(),
                  })}
                >
                  {n.label}
                </Link>
              ))}
            </nav>
          </aside>
        </>
      ) : null}
    </>
  );
}
