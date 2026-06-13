"use client";
import * as React from "react";
import { cyAttrs } from "@/utils/cypress";

export interface TopBarNavItem {
  label: string;
  href: string;
  active?: boolean;
}

export interface TopBarProps {
  logoHref?: string;
  logoLabel?: string;
  navItems?: TopBarNavItem[];
  onOpenPalette?: () => void;
  orgSwitcher?: React.ReactNode;
  primaryAction?: React.ReactNode;
  userMenu?: React.ReactNode;
  className?: string;
  cy?: string;
}

/**
 * 52 px sticky top bar — logo · nav · ⌘K · org · CTA · user.
 *
 * @example
 * <TopBar
 *   navItems={[{label:"Library", href:"/library"}, {label:"Scripts", href:"/scripts", active: true}]}
 *   onOpenPalette={open}
 *   userMenu={<UserMenu />}
 * />
 */
export function TopBar({
  logoHref = "/",
  logoLabel = "codefre",
  navItems = [],
  onOpenPalette,
  orgSwitcher,
  primaryAction,
  userMenu,
  className,
  cy = "topbar",
}: TopBarProps) {
  return (
    <header
      className={["sg-topbar", className || ""].filter(Boolean).join(" ")}
      {...cyAttrs({ cy })}
    >
      <div className="sg-topbar__group">
        <a
          href={logoHref}
          className="sg-topbar__logo"
          {...cyAttrs({ cy: "topbar-logo" })}
        >
          {logoLabel}
          <span className="sg-topbar__logo-dot">.</span>
          sh
        </a>
        <nav
          aria-label="Primary"
          style={{ display: "flex", gap: "var(--space-1)" }}
        >
          {navItems.map((n) => (
            <a
              key={n.href}
              href={n.href}
              className={[
                "sg-nav-tab",
                n.active ? "sg-nav-tab--active" : "",
              ]
                .filter(Boolean)
                .join(" ")}
              {...cyAttrs({ cy: "nav-tab", cyId: n.label.toLowerCase() })}
            >
              {n.label}
            </a>
          ))}
        </nav>
      </div>
      <div className="sg-topbar__group">
        {onOpenPalette ? (
          <button
            type="button"
            onClick={onOpenPalette}
            className="sg-btn sg-btn--ghost sg-btn--sm"
            aria-label="Open command palette"
            {...cyAttrs({ cy: "palette-trigger" })}
          >
            <span style={{ fontFamily: "var(--font-mono)", fontSize: 12 }}>⌘K</span>
          </button>
        ) : null}
        {orgSwitcher}
        {primaryAction}
        {userMenu}
      </div>
    </header>
  );
}
