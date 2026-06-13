"use client";

import { useState, useRef, useEffect } from "react";
import Link from "next/link";
import { services, getGroupedServices, GROUP_ICONS, type Service } from "@/lib/services";

interface ServiceHeaderProps {
  current: Service;
}

export function ServiceHeader({ current }: ServiceHeaderProps) {
  const [menuOpen, setMenuOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClick(e: MouseEvent) {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) {
        setMenuOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClick);
    return () => document.removeEventListener("mousedown", handleClick);
  }, []);

  const groups = getGroupedServices();

  return (
    <header className="h-12 bg-surface-1 border-b border-surface-3 flex items-center px-3 gap-3 shrink-0">
      {/* Back to dashboard */}
      <Link
        href="/"
        className="flex items-center gap-1.5 text-muted hover:text-gray-200 transition-colors text-sm"
        title="Back to dashboard"
      >
        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
        </svg>
        <span className="hidden sm:inline">Dashboard</span>
      </Link>

      <div className="w-px h-5 bg-surface-3" />

      {/* Current service */}
      <div className="flex items-center gap-2 text-sm font-medium text-gray-100">
        <span>{current.icon}</span>
        <span>{current.name}</span>
      </div>

      {/* Quick-switch dropdown */}
      <div className="relative ml-auto" ref={menuRef}>
        <button
          onClick={() => setMenuOpen(!menuOpen)}
          className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-md text-xs text-muted hover:text-gray-200 hover:bg-surface-2 transition-colors"
        >
          Switch
          <svg
            className={`w-3 h-3 transition-transform ${menuOpen ? "rotate-180" : ""}`}
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
          </svg>
        </button>

        {menuOpen && (
          <div className="absolute right-0 top-full mt-1 w-72 max-h-[70vh] overflow-y-auto bg-surface-2 border border-surface-3 rounded-lg shadow-xl z-50">
            {groups.map((group) => (
              <div key={group.name}>
                <div className="px-3 py-2 text-[10px] font-semibold text-muted uppercase tracking-wider sticky top-0 bg-surface-2">
                  {GROUP_ICONS[group.name]} {group.name}
                </div>
                {group.services.map((s) => (
                  <Link
                    key={s.slug}
                    href={`/service/${s.slug}`}
                    onClick={() => setMenuOpen(false)}
                    className={`flex items-center gap-2 px-3 py-2 text-sm transition-colors ${
                      s.slug === current.slug
                        ? "bg-accent/10 text-accent"
                        : "text-gray-300 hover:bg-surface-3 hover:text-gray-100"
                    }`}
                  >
                    <span className="text-base">{s.icon}</span>
                    <span className="flex-1 truncate">{s.name}</span>
                    {s.status !== "active" && (
                      <span className={`status-${s.status} text-[9px] px-1.5 py-0.5 rounded-full`}>
                        {s.status}
                      </span>
                    )}
                  </Link>
                ))}
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Open in new tab */}
      <a
        href={`https://${current.domain}`}
        target="_blank"
        rel="noopener noreferrer"
        className="flex items-center gap-1 px-2.5 py-1.5 rounded-md text-xs text-muted hover:text-gray-200 hover:bg-surface-2 transition-colors"
        title="Open in new tab"
      >
        <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
          />
        </svg>
        <span className="hidden sm:inline">Open</span>
      </a>
    </header>
  );
}
