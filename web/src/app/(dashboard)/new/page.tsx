import Link from "next/link";
import { ArrowLeft } from "lucide-react";

export default function NewUniversePage() {
  return (
    <div className="max-w-xl mx-auto text-center py-16">
      <span className="font-serif text-accent text-[48px] leading-none select-none block mb-6" aria-hidden="true">
        ◊
      </span>
      <h1 className="font-serif text-[28px] font-bold text-ink mb-3">
        Create a New Universe
      </h1>
      <p className="font-sans text-[15px] text-ink-secondary leading-relaxed mb-2">
        Name your world, choose a genre, and start building. The knowledge graph, consistency engine, and AI generator activate as soon as you add your first entry.
      </p>
      <p className="font-mono text-[12px] text-ink-tertiary mb-8">
        This feature is not available in the portfolio demo.
      </p>
      <Link
        href="/"
        className="inline-flex items-center gap-2 font-sans text-[14px] text-link hover:text-link-hover transition-colors duration-200"
      >
        <ArrowLeft size={14} strokeWidth={2} />
        Back to Universes
      </Link>
    </div>
  );
}
