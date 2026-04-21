"use client";

import clsx from "clsx";
import { PageHeader } from "@/components/primitives/PageHeader";
import { Tokens } from "./sections/Tokens";
import { Typography } from "./sections/Typography";
import { Primitives } from "./sections/Primitives";
import { Composites } from "./sections/Composites";
import { Patterns } from "./sections/Patterns";
import { Accessibility } from "./sections/Accessibility";

const SECTIONS: { id: string; label: string }[] = [
  { id: "tokens", label: "Tokens" },
  { id: "typography", label: "Typography" },
  { id: "primitives", label: "Primitives" },
  { id: "composites", label: "Composites" },
  { id: "patterns", label: "Patterns" },
  { id: "accessibility", label: "Accessibility" },
];

export default function StyleGuidePage() {
  return (
    <div className="flex flex-col gap-6">
      <PageHeader
        title="Style Guide"
        description="Tokens, primitives, composites, and patterns for NPL Studio."
      />

      <div className="flex gap-8">
        <aside className="w-56 shrink-0 hidden lg:block sticky top-6 self-start">
          <nav className="flex flex-col gap-1 text-sm" aria-label="Style guide sections">
            <p className="text-label uppercase text-subtle px-2 mb-1">Jump to</p>
            {SECTIONS.map((s) => (
              <a
                key={s.id}
                href={`#${s.id}`}
                className={clsx(
                  "rounded-md px-2 py-1.5 text-muted hover:bg-surface-1 hover:text-foreground",
                  "focus-ring transition-colors",
                )}
              >
                {s.label}
              </a>
            ))}
          </nav>
        </aside>

        <main className="flex-1 min-w-0 flex flex-col gap-16 scroll-smooth">
          <section id="tokens" className="scroll-mt-6">
            <Tokens />
          </section>
          <section id="typography" className="scroll-mt-6">
            <Typography />
          </section>
          <section id="primitives" className="scroll-mt-6">
            <Primitives />
          </section>
          <section id="composites" className="scroll-mt-6">
            <Composites />
          </section>
          <section id="patterns" className="scroll-mt-6">
            <Patterns />
          </section>
          <section id="accessibility" className="scroll-mt-6">
            <Accessibility />
          </section>
        </main>
      </div>
    </div>
  );
}
