"use client";

import * as React from "react";
import { GenerationForm } from "@/components/generation/generation-form";
import { SourceList } from "@/components/generation/source-list";
import { GenerationOutput } from "@/components/generation/generation-output";
import { RecentGenerations } from "@/components/generation/recent-generations";
import type { EntryType } from "@/lib/constants";
import type { Generation } from "@/types/generation";

// ── Mock sources ──────────────────────────────────────────────────────────
const INITIAL_SOURCES = [
  { id: "thornwall",   type: "location" as EntryType, label: "Thornwall",         included: true  },
  { id: "blacksmiths", type: "faction"  as EntryType, label: "Blacksmith Guild",  included: true  },
  { id: "north-reach", type: "location" as EntryType, label: "Northern Reach",    included: true  },
  { id: "iron-routes", type: "concept"  as EntryType, label: "Iron Trade Routes", included: true  },
  {
    id: "war-stones",
    type: "event" as EntryType,
    label: "War of Stones",
    included: false,
    note: "post-dates founding",
  },
];

// ── Mock recent generations ───────────────────────────────────────────────
const MOCK_RECENT: Generation[] = [
  {
    id: "gen-1",
    prompt: "Write climate patterns for the Northern Reach",
    entryType: "concept",
    status: "complete",
    outputTitle: "Northern Reach Climate Patterns",
    outputBody: "",
    sourceEntryIds: ["north-reach"],
    createdAt: new Date(Date.now() - 3_600_000).toISOString(),
  },
  {
    id: "gen-2",
    prompt: "Write Mira Ashward's backstory",
    entryType: "character",
    status: "promoted",
    outputTitle: "Mira Ashward Backstory",
    outputBody: "",
    sourceEntryIds: ["kael", "thornwall"],
    createdAt: new Date(Date.now() - 7_200_000).toISOString(),
  },
  {
    id: "gen-3",
    prompt: "Describe the hierarchy of the Blacksmith Guild",
    entryType: "faction",
    status: "pending",
    outputTitle: "Guild Hierarchy",
    outputBody: "",
    sourceEntryIds: ["blacksmiths"],
    createdAt: new Date(Date.now() - 14_400_000).toISOString(),
  },
];

// ── Mock generated content ────────────────────────────────────────────────
const MOCK_OUTPUT_TITLE = "Founding of Thornwall — An Elder's Account";
const MOCK_OUTPUT_BODY = `In the years before the iron roads ran straight, when the Northern Reach was still a name men whispered rather than a territory they mapped, there came to the coastal cliffs a company of smiths led by a woman whose name the records have not kept but whose hammer-mark we still know. She called the place Thornwall for the sea-bramble that had to be cleared before the first forge could be set.

The Guild was not founded — it accreted, the way trade always does. The first season there were four smiths and a boy who carried charcoal. By the third winter there were forty, and the coastal merchants had begun rerouting their iron shipments east to avoid the tolls on the old lowland passes. Thornwall became, almost without deciding to, the linchpin of the Northern iron trade.

What the elders remember — and what the merchants prefer to forget — is that the Guild's first law was not a law about iron at all. It was a law about water. Every smith who joined the Guild pledged to keep the coastal wells shared and untaxed. The iron trade made Thornwall wealthy. The water law is what kept it a town worth living in.

The cold-singing technique comes later, three generations on, brought down from the high passes by a journeyman whose name was recorded only as Kael's grandfather. He taught the hammer-tone method to anyone who would learn it, which is how the Guild stayed a Guild and did not become a monopoly.`;
// ──────────────────────────────────────────────────────────────────────────

export default function GeneratePage() {
  const [sources, setSources]         = React.useState(INITIAL_SOURCES);
  const [isGenerating, setIsGenerating] = React.useState(false);
  const [showOutput, setShowOutput]   = React.useState(false);
  const [isPromoted, setIsPromoted]   = React.useState(false);
  const [recentGens, setRecentGens]   = React.useState<Generation[]>(MOCK_RECENT);

  function handleGenerate() {
    setIsGenerating(true);
    setShowOutput(false);
    setIsPromoted(false);
    setTimeout(() => {
      setIsGenerating(false);
      setShowOutput(true);
    }, 1_800);
  }

  function handleToggleSource(id: string) {
    setSources((prev) =>
      prev.map((s) => (s.id === id ? { ...s, included: !s.included } : s))
    );
  }

  function handlePromote() {
    setIsPromoted(true);
    const newGen: Generation = {
      id: `gen-${Date.now()}`,
      prompt: MOCK_OUTPUT_TITLE,
      entryType: "event",
      status: "promoted",
      outputTitle: MOCK_OUTPUT_TITLE,
      outputBody: MOCK_OUTPUT_BODY,
      sourceEntryIds: sources.filter((s) => s.included).map((s) => s.id),
      createdAt: new Date().toISOString(),
    };
    setRecentGens((prev) => [newGen, ...prev]);
  }

  function handleDiscard() {
    setShowOutput(false);
    setIsPromoted(false);
  }

  return (
    <div className="min-h-full bg-page">
      {/* Page header */}
      <div className="px-6 pt-8 pb-6 border-b border-rule-subtle">
        <h2 className="font-serif text-[28px] font-bold text-ink">Generation Studio</h2>
        <p className="font-sans text-[14px] text-ink-secondary mt-1">
          Describe what to generate — the AI reads all referenced canon before writing.
        </p>
      </div>

      {/* Two-column layout */}
      <div className="grid grid-cols-1 lg:grid-cols-2 divide-y lg:divide-y-0 lg:divide-x divide-rule-subtle">
        {/* Left: Form + sources */}
        <div className="p-6 space-y-6">
          <GenerationForm onGenerate={handleGenerate} isGenerating={isGenerating} />
          <SourceList
            sources={sources}
            onToggle={handleToggleSource}
            onEditSources={() => {}}
          />
        </div>

        {/* Right: Output + recent */}
        <div className="p-6 space-y-6">
          {/* Loading skeleton */}
          {isGenerating && (
            <div className="rounded-md border border-rule-subtle bg-surface p-6">
              <div className="space-y-2.5">
                <div className="h-2.5 bg-elevated rounded animate-pulse w-1/3" />
                <div className="h-2.5 bg-elevated rounded animate-pulse w-full" />
                <div className="h-2.5 bg-elevated rounded animate-pulse w-5/6" />
                <div className="h-2.5 bg-elevated rounded animate-pulse w-full" />
                <div className="h-2.5 bg-elevated rounded animate-pulse w-4/5" />
              </div>
              <p className="font-mono text-[11px] text-ink-tertiary mt-4 animate-pulse">
                Reading canon entries…
              </p>
            </div>
          )}

          {/* Generated output */}
          {showOutput && !isGenerating && (
            <GenerationOutput
              title={MOCK_OUTPUT_TITLE}
              body={MOCK_OUTPUT_BODY}
              onPromoteToCanon={handlePromote}
              onEdit={() => {}}
              onDiscard={handleDiscard}
              isPromoted={isPromoted}
            />
          )}

          {/* Empty state */}
          {!showOutput && !isGenerating && (
            <div className="rounded-md border border-dashed border-rule p-8 text-center bg-surface">
              <p className="font-serif text-[15px] text-ink-tertiary italic">
                Generated content will appear here.
              </p>
              <p className="font-sans text-[12px] text-ink-tertiary mt-1">
                Write a prompt on the left and click Generate.
              </p>
            </div>
          )}

          {/* Recent generations */}
          <div className="border-t border-rule-subtle pt-6">
            <RecentGenerations generations={recentGens} onSelect={() => {}} />
          </div>
        </div>
      </div>
    </div>
  );
}
