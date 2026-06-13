import Link from "next/link";
import { BookOpen, Network, Sparkles, AlertTriangle, Clock, ArrowRight } from "lucide-react";

const FEATURES = [
  {
    icon: BookOpen,
    title: "Canon & Generated Entries",
    description:
      "Write canonical entries by hand or let the AI generate new ones grounded in your existing material. Every entry is visually marked so you always know what's human-authored and what's machine-proposed.",
  },
  {
    icon: Network,
    title: "Knowledge Graph",
    description:
      "Connections between entries are first-class citizens. Explore your knowledge base as an interactive force-directed graph — see how concepts, people, events, and systems relate at a glance.",
  },
  {
    icon: Sparkles,
    title: "AI Generation",
    description:
      "Describe what you need and the system drafts new entries grounded in your existing content. Generated material references established facts and definitions, not generic filler.",
  },
  {
    icon: AlertTriangle,
    title: "Consistency Checking",
    description:
      "An automated engine flags contradictions, timeline conflicts, and missing cross-references. Catch conflicting dates, orphaned definitions, and logical gaps before they compound.",
  },
  {
    icon: Clock,
    title: "Timeline View",
    description:
      "Events and milestones laid out chronologically. Filter by category, region, or involvement. See where your timeline has gaps — and where it's overcrowded.",
  },
];

const PRINCIPLES = [
  {
    label: "Canon is sacred",
    detail: "Human-authored content is always visually distinct from machine-generated material. You decide what's authoritative.",
  },
  {
    label: "Connections over entries",
    detail: "A knowledge base isn't a list of nouns — it's the relationships between them. The graph is the product, not a feature.",
  },
  {
    label: "Contradiction is signal",
    detail: "Inconsistencies aren't bugs. They're the most valuable feedback a writer can get. Surface them early, resolve them intentionally.",
  },
  {
    label: "Generate, don't replace",
    detail: "AI fills gaps and suggests possibilities. It never overwrites canon. Every generated entry starts as a proposal you can promote, edit, or discard.",
  },
];

export default function AboutPage() {
  return (
    <div className="max-w-3xl">
      {/* Hero */}
      <div className="mb-12">
        <h1 className="font-serif text-[36px] font-bold text-ink leading-tight tracking-[-0.01em] mb-4">
          A living wiki that writes itself.
        </h1>
        <p className="font-body text-[18px] text-ink-secondary leading-relaxed" style={{ maxWidth: "60ch" }}>
          Knowledge Base is a structured writing tool for anyone maintaining a body of
          interconnected knowledge — fiction, non-fiction, or technical documentation. It
          combines a structured wiki with AI generation and automated consistency checking
          so your information stays accurate as it grows.
        </p>
      </div>

      {/* Who it's for */}
      <section className="mb-12">
        <h2 className="font-mono text-[11px] font-semibold uppercase tracking-[0.06em] text-ink-tertiary mb-4">
          Built for
        </h2>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          {[
            { label: "Fiction Writers", detail: "Novels, screenplays, game lore — track characters, locations, plot threads, and timelines across drafts" },
            { label: "Non-Fiction Authors", detail: "Research projects, histories, biographies — maintain sourced, cross-referenced material that stays consistent" },
            { label: "Technical Teams", detail: "API docs, architecture decisions, runbooks — a living knowledge base where every concept links to its dependencies" },
          ].map((audience) => (
            <div
              key={audience.label}
              className="bg-surface border border-rule rounded-lg p-5"
            >
              <h3 className="font-sans text-[14px] font-semibold text-ink mb-1">
                {audience.label}
              </h3>
              <p className="font-sans text-[13px] text-ink-secondary leading-relaxed">
                {audience.detail}
              </p>
            </div>
          ))}
        </div>
      </section>

      {/* Features */}
      <section className="mb-12">
        <h2 className="font-mono text-[11px] font-semibold uppercase tracking-[0.06em] text-ink-tertiary mb-4">
          Core Features
        </h2>
        <div className="space-y-6">
          {FEATURES.map((feature) => {
            const Icon = feature.icon;
            return (
              <div key={feature.title} className="flex gap-4">
                <div className="w-8 h-8 rounded-md bg-accent-muted flex items-center justify-center shrink-0 mt-0.5">
                  <Icon size={16} strokeWidth={1.5} className="text-accent" />
                </div>
                <div>
                  <h3 className="font-sans text-[15px] font-semibold text-ink mb-1">
                    {feature.title}
                  </h3>
                  <p className="font-sans text-[13px] text-ink-secondary leading-relaxed">
                    {feature.description}
                  </p>
                </div>
              </div>
            );
          })}
        </div>
      </section>

      {/* Design principles */}
      <section className="mb-12">
        <h2 className="font-mono text-[11px] font-semibold uppercase tracking-[0.06em] text-ink-tertiary mb-4">
          Design Principles
        </h2>
        <div className="border-t border-rule-subtle">
          {PRINCIPLES.map((p) => (
            <div key={p.label} className="py-4 border-b border-rule-subtle">
              <h3 className="font-serif text-[16px] font-semibold text-ink mb-1">
                {p.label}
              </h3>
              <p className="font-sans text-[13px] text-ink-secondary leading-relaxed">
                {p.detail}
              </p>
            </div>
          ))}
        </div>
      </section>

      {/* CTA */}
      <section className="bg-surface border border-rule rounded-xl p-8 text-center mb-8">
        <p className="font-serif text-[20px] font-semibold text-ink mb-2">
          Start building your knowledge base.
        </p>
        <p className="font-sans text-[14px] text-ink-secondary mb-5">
          This is a portfolio demo pre-loaded with sample universes. Explore them to see the tool in action.
        </p>
        <Link
          href="/"
          className="inline-flex items-center gap-2 bg-accent text-surface font-sans text-[14px] font-medium px-5 py-2.5 rounded-md hover:bg-accent-hover transition-colors duration-200"
        >
          View Universes
          <ArrowRight size={14} strokeWidth={2} />
        </Link>
      </section>

      {/* Footer note */}
      <p className="font-mono text-[11px] text-ink-tertiary text-center pb-4">
        Knowledge Base · kb.therobotlives.com · A portfolio project by The Robot Lives
      </p>
    </div>
  );
}
