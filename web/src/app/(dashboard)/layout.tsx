import Link from "next/link";
import { KnowledgeBaseLogo } from "@/components/layout/knowledge-base-logo";

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen bg-page">
      {/* Top bar */}
      <header className="sticky top-0 z-10 bg-surface/95 backdrop-blur-sm border-b border-rule-subtle">
        <div className="max-w-6xl mx-auto px-6 h-14 flex items-center gap-3">
          {/* Logo mark */}
          <Link href="/" className="flex items-center gap-2.5 shrink-0">
            <KnowledgeBaseLogo size={28} className="text-ink" />
            <span className="font-serif text-[15px] font-semibold tracking-[0.04em] text-ink uppercase">
              Knowledge Base
            </span>
          </Link>

          <div className="flex-1" />

          {/* Nav links */}
          <nav className="flex items-center gap-1">
            <Link
              href="/"
              className="font-sans text-[13px] text-ink-secondary hover:text-ink px-3 py-1.5 rounded transition-colors duration-200"
            >
              Universes
            </Link>
            <Link
              href="/about"
              className="font-sans text-[13px] text-ink-secondary hover:text-ink px-3 py-1.5 rounded transition-colors duration-200"
            >
              About
            </Link>
          </nav>
        </div>
      </header>

      {/* Content */}
      <main className="max-w-6xl mx-auto px-6 py-10">{children}</main>
    </div>
  );
}
