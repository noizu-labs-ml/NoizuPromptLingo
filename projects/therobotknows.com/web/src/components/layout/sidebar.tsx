"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  LayoutDashboard,
  BookOpen,
  Network,
  Clock,
  Sparkles,
  AlertTriangle,
} from "lucide-react";
import { cn } from "@/lib/cn";
import type { Entry } from "@/types/entry";

interface NavItem {
  label: string;
  href: string;
  icon: React.ComponentType<{ className?: string; size?: number; strokeWidth?: number }>;
}

interface SidebarProps {
  universeId: string;
  universeName: string;
  entries?: Entry[];
}

export function Sidebar({ universeId, universeName, entries = [] }: SidebarProps) {
  const pathname = usePathname();
  const base = `/${universeId}`;

  const navItems: NavItem[] = [
    { label: "Overview", href: base, icon: LayoutDashboard },
    { label: "Entries", href: `${base}/entries`, icon: BookOpen },
    { label: "Graph", href: `${base}/graph`, icon: Network },
    { label: "Timeline", href: `${base}/timeline`, icon: Clock },
    { label: "Generate", href: `${base}/generate`, icon: Sparkles },
    { label: "Flags", href: `${base}/consistency`, icon: AlertTriangle },
  ];

  function isActive(href: string) {
    if (href === base) {
      return pathname === base;
    }
    return pathname.startsWith(href);
  }

  return (
    <aside className="w-60 shrink-0 h-screen sticky top-0 bg-elevated border-r border-rule flex flex-col overflow-y-auto">
      {/* Universe name / back to dashboard */}
      <div className="px-5 pt-6 pb-4 border-b border-rule-subtle">
        <Link
          href="/"
          className="text-ink-tertiary hover:text-ink-secondary font-mono text-[11px] uppercase tracking-widest transition-colors duration-200 block mb-2"
        >
          ← All Universes
        </Link>
        <Link
          href={base}
          className="font-serif text-[15px] font-semibold text-ink leading-snug hover:text-accent transition-colors duration-200 block"
        >
          {universeName}
        </Link>
      </div>

      {/* Primary navigation */}
      <nav className="pt-2 flex-1">
        <p className="px-5 pt-4 pb-1 font-mono text-[11px] font-semibold uppercase tracking-[0.06em] text-ink-tertiary">
          Navigate
        </p>
        {navItems.map((item) => {
          const active = isActive(item.href);
          const Icon = item.icon;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "flex items-center gap-2.5 px-5 py-2 font-sans text-sm transition-colors duration-200",
                active
                  ? "text-accent bg-accent-muted font-semibold"
                  : "text-ink-secondary hover:text-ink hover:bg-accent/[0.04]"
              )}
            >
              <Icon
                size={16}
                strokeWidth={1.5}
                className={cn(active ? "text-accent" : "text-ink-tertiary")}
              />
              {item.label}
            </Link>
          );
        })}

        {/* Entries sub-list */}
        {entries.length > 0 && (
          <>
            <p className="px-5 pt-5 pb-1 font-mono text-[11px] font-semibold uppercase tracking-[0.06em] text-ink-tertiary">
              Entries
            </p>
            <ul>
              {entries.slice(0, 20).map((entry) => (
                <li key={entry.id}>
                  <Link
                    href={`${base}/entries/${entry.id}`}
                    className={cn(
                      "flex items-center gap-2 pl-8 pr-5 py-1.5 font-serif text-sm transition-colors duration-200",
                      pathname === `${base}/entries/${entry.id}`
                        ? "text-accent font-semibold"
                        : "text-ink-secondary hover:text-ink"
                    )}
                  >
                    <span
                      className={cn(
                        "text-[8px] shrink-0",
                        entry.status === "canon" ? "text-canon" : "text-generated"
                      )}
                    >
                      {entry.status === "canon" ? "■" : "□"}
                    </span>
                    <span className="truncate">{entry.title}</span>
                  </Link>
                </li>
              ))}
            </ul>
          </>
        )}
      </nav>
    </aside>
  );
}
