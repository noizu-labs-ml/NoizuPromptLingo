import Link from "next/link";
import { Search, ChevronLeft } from "lucide-react";

interface TopBarProps {
  title: string;
  backHref?: string;
  backLabel?: string;
}

export function TopBar({ title, backHref, backLabel }: TopBarProps) {
  return (
    <header className="sticky top-0 z-10 flex items-center gap-3 px-6 h-12 bg-surface/95 backdrop-blur-sm border-b border-rule-subtle">
      {/* Back navigation */}
      {backHref && (
        <Link
          href={backHref}
          className="flex items-center gap-1 font-sans text-[13px] text-ink-secondary hover:text-ink transition-colors duration-200 shrink-0"
        >
          <ChevronLeft size={14} strokeWidth={1.5} className="text-ink-tertiary" />
          <span>{backLabel ?? "Back"}</span>
        </Link>
      )}

      {backHref && (
        <span className="text-rule-heavy font-sans text-[13px] select-none">/</span>
      )}

      {/* Page title */}
      <h1 className="font-sans text-[14px] font-semibold text-ink truncate flex-1">
        {title}
      </h1>

      {/* Search */}
      <div className="relative shrink-0">
        <Search
          size={14}
          strokeWidth={1.5}
          className="absolute left-3 top-1/2 -translate-y-1/2 text-ink-tertiary pointer-events-none"
        />
        <input
          type="search"
          placeholder="Search entries…"
          className="
            bg-elevated border border-rule-subtle rounded-lg
            pl-8 pr-3 py-1.5
            font-sans text-[13px] text-ink placeholder:text-ink-tertiary
            w-48 focus:w-64 transition-all duration-200
            focus:bg-surface focus:border-rule focus:shadow-[0_2px_8px_rgba(0,0,0,0.06)]
            outline-none
          "
        />
      </div>
    </header>
  );
}
