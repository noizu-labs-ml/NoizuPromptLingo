"use client";

import { Fragment } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { MagnifyingGlassIcon, Bars3Icon, XMarkIcon } from "@heroicons/react/24/outline";
import clsx from "clsx";
import { ThemeToggle } from "./ThemeToggle";

interface TopBarProps {
  onMobileMenuOpen?: () => void;
  mobileMenuOpen?: boolean;
  onOpenPalette?: () => void;
}

function deriveBreadcrumbs(pathname: string): { label: string; href: string }[] {
  if (pathname === "/") return [{ label: "Home", href: "/" }];

  const segments = pathname.split("/").filter(Boolean);
  const crumbs = [{ label: "Home", href: "/" }];

  let accumulated = "";
  for (const seg of segments) {
    accumulated += `/${seg}`;
    crumbs.push({
      label: seg.charAt(0).toUpperCase() + seg.slice(1).replace(/-/g, " "),
      href: accumulated,
    });
  }
  return crumbs;
}

export function TopBar({ onMobileMenuOpen, mobileMenuOpen, onOpenPalette }: TopBarProps) {
  const pathname = usePathname();
  const breadcrumbs = deriveBreadcrumbs(pathname);

  return (
    <>
      <header className="flex h-12 shrink-0 items-center gap-3 border-b border-border bg-surface px-4">
        {/* Mobile menu toggle */}
        <button
          type="button"
          className="lg:hidden -ml-1 flex h-8 w-8 items-center justify-center rounded-md text-muted hover:bg-surface-raised hover:text-foreground transition-colors"
          onClick={onMobileMenuOpen}
          aria-label={mobileMenuOpen ? "Close menu" : "Open menu"}
        >
          {mobileMenuOpen ? (
            <XMarkIcon className="h-5 w-5" />
          ) : (
            <Bars3Icon className="h-5 w-5" />
          )}
        </button>

        {/* Brand */}
        <Link
          href="/"
          className="hidden lg:flex items-center gap-2 font-semibold text-sm text-foreground hover:text-accent transition-colors"
        >
          <span className="text-accent font-bold tracking-tight">NPL</span>
          <span className="text-muted font-normal">MCP</span>
        </Link>

        {/* Divider */}
        <span className="hidden lg:block h-4 w-px bg-border" aria-hidden />

        {/* Breadcrumbs */}
        <nav aria-label="Breadcrumb" className="flex items-center gap-1 text-xs text-muted overflow-hidden">
          {breadcrumbs.map((crumb, idx) => (
            <Fragment key={crumb.href}>
              {idx > 0 && <span className="text-subtle shrink-0">/</span>}
              {idx === breadcrumbs.length - 1 ? (
                <span className="text-foreground font-medium truncate">{crumb.label}</span>
              ) : (
                <Link href={crumb.href} className="hover:text-foreground transition-colors truncate">
                  {crumb.label}
                </Link>
              )}
            </Fragment>
          ))}
        </nav>

        {/* Spacer */}
        <div className="flex-1" />

        {/* Theme toggle */}
        <ThemeToggle />

        {/* Command palette trigger */}
        <button
          type="button"
          onClick={onOpenPalette}
          className={clsx(
            "flex items-center gap-2 rounded-md border border-border bg-surface-raised",
            "px-2.5 py-1.5 text-xs text-muted hover:border-accent/40 hover:text-foreground",
            "transition-colors"
          )}
          aria-label="Open command palette"
        >
          <MagnifyingGlassIcon className="h-3.5 w-3.5 shrink-0" />
          <span className="hidden sm:inline">Search…</span>
          <kbd className="hidden sm:inline-flex items-center gap-0.5 rounded border border-border px-1 text-[10px] font-mono text-subtle">
            ⌘K
          </kbd>
        </button>
      </header>
    </>
  );
}
