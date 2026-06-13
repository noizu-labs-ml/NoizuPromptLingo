"use client";

import { Fragment } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { MagnifyingGlassIcon, Bars3Icon, XMarkIcon, SparklesIcon } from "@heroicons/react/24/outline";
import clsx from "clsx";
import { ThemeToggle } from "./ThemeToggle";
import { Kbd } from "@/components/primitives/Kbd";
import { Button } from "@/components/primitives/Button";
import { heading } from "@/lib/ui/typography";

interface TopBarProps {
  onMobileMenuOpen?: () => void;
  mobileMenuOpen?: boolean;
  onOpenPalette?: () => void;
  onOpenQuickCreate?: () => void;
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

export function TopBar({ onMobileMenuOpen, mobileMenuOpen, onOpenPalette, onOpenQuickCreate }: TopBarProps) {
  const pathname = usePathname();
  const breadcrumbs = deriveBreadcrumbs(pathname);

  return (
    <header
      className={clsx(
        "flex h-12 shrink-0 items-center gap-3 border-b border-border px-4",
        // Frosted pane over the aurora gradient beneath.
        "backdrop-blur-sm bg-canvas/80"
      )}
    >
      {/* Mobile menu toggle */}
      <button
        type="button"
        className="lg:hidden -ml-1 flex h-8 w-8 items-center justify-center rounded-md text-muted hover:bg-surface-1 hover:text-foreground focus-ring transition-colors"
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
        className={clsx(
          "hidden lg:flex items-center gap-2 focus-ring rounded-sm",
          heading.heading
        )}
      >
        <span className="text-accent font-semibold tracking-tight">NPL</span>
        <span className="text-muted font-normal">MCP</span>
      </Link>

      {/* Divider */}
      <span className="hidden lg:block h-4 w-px bg-border" aria-hidden />

      {/* Breadcrumbs */}
      <nav
        aria-label="Breadcrumb"
        className="flex items-center gap-1 text-xs text-muted overflow-hidden"
      >
        {breadcrumbs.map((crumb, idx) => (
          <Fragment key={crumb.href}>
            {idx > 0 && <span className="text-subtle shrink-0">/</span>}
            {idx === breadcrumbs.length - 1 ? (
              <span className="text-foreground font-medium truncate">{crumb.label}</span>
            ) : (
              <Link
                href={crumb.href}
                className="text-muted hover:text-foreground focus-ring rounded-sm transition-colors truncate"
              >
                {crumb.label}
              </Link>
            )}
          </Fragment>
        ))}
      </nav>

      {/* Spacer */}
      <div className="flex-1" />

      {/* Quick create button */}
      <Button
        variant="primary"
        size="sm"
        leadingIcon={<SparklesIcon className="h-4 w-4" />}
        onClick={onOpenQuickCreate}
      >
        <span className="hidden sm:inline">New</span>
      </Button>

      {/* Theme toggle */}
      <ThemeToggle />

      {/* Command palette trigger */}
      <button
        type="button"
        onClick={onOpenPalette}
        className={clsx(
          "inline-flex items-center gap-2 rounded-md border border-border bg-surface-1",
          "px-2.5 py-1.5 text-xs text-muted hover:border-border-strong hover:text-foreground",
          "focus-ring transition-colors"
        )}
        aria-label="Open command palette"
      >
        <MagnifyingGlassIcon className="h-3.5 w-3.5 shrink-0" />
        <span className="hidden sm:inline">Search…</span>
        <Kbd className="hidden sm:inline-flex">⌘K</Kbd>
      </button>
    </header>
  );
}
