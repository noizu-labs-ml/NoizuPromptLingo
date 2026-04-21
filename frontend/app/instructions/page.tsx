"use client";

import { useState, useMemo } from "react";
import useSWR from "swr";
import Link from "next/link";
import clsx from "clsx";
import { BookOpenIcon } from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import type { Instruction } from "@/lib/api/types";

import { Card } from "@/components/primitives/Card";
import { Badge } from "@/components/primitives/Badge";
import { Tag } from "@/components/primitives/Tag";
import { EmptyState } from "@/components/primitives/EmptyState";
import { PageHeader } from "@/components/primitives/PageHeader";
import { SearchBox } from "@/components/forms/SearchBox";

import { relativeTime } from "@/lib/utils/format";

// ── Instruction card ──────────────────────────────────────────────────────

function InstructionCard({ instruction }: { instruction: Instruction }) {
  return (
    <Link href={`/instructions/${instruction.uuid}`} className="block">
      <Card hoverable className="h-full flex flex-col gap-2">
        <div className="flex items-start justify-between gap-2 min-w-0">
          <span className="font-semibold text-sm text-foreground truncate flex-1">
            {instruction.title}
          </span>
          <Badge variant="info" size="sm">
            v{instruction.active_version}
          </Badge>
        </div>

        <p className="text-sm text-muted line-clamp-2 flex-1">
          {instruction.description}
        </p>

        <div className="flex items-center justify-between gap-2 mt-1">
          <div className="flex flex-wrap gap-1 min-w-0">
            {instruction.tags.map((tag) => (
              <Badge key={tag} variant="default" size="sm">
                {tag}
              </Badge>
            ))}
          </div>
          <span className="text-xs text-subtle shrink-0">
            {relativeTime(instruction.updated_at)}
          </span>
        </div>
      </Card>
    </Link>
  );
}

// ── Page ──────────────────────────────────────────────────────────────────

export default function InstructionsPage() {
  const [search, setSearch] = useState("");
  const [searchMode, setSearchMode] = useState<"text" | "intent">("text");
  const [activeTags, setActiveTags] = useState<Set<string>>(new Set());

  const { data: instructions, isLoading } = useSWR(
    "instructions.list",
    () => api.instructions.list()
  );

  // Collect all unique tags from all instructions
  const allTags = useMemo(() => {
    const set = new Set<string>();
    (instructions ?? []).forEach((instr) =>
      instr.tags.forEach((tag) => set.add(tag))
    );
    return Array.from(set).sort();
  }, [instructions]);

  const toggleTag = (tag: string) => {
    setActiveTags((prev) => {
      const next = new Set(prev);
      if (next.has(tag)) {
        next.delete(tag);
      } else {
        next.add(tag);
      }
      return next;
    });
  };

  // Client-side filtering
  const filtered = useMemo(() => {
    if (!instructions) return [];
    let list = instructions;

    // Tag filter (AND semantics)
    if (activeTags.size > 0) {
      list = list.filter((i) =>
        Array.from(activeTags).every((t) => i.tags.includes(t))
      );
    }

    // Text/intent filter (same mock behaviour for both modes)
    if (search.trim()) {
      const q = search.trim().toLowerCase();
      list = list.filter(
        (i) =>
          i.title.toLowerCase().includes(q) ||
          i.description.toLowerCase().includes(q) ||
          i.tags.some((t) => t.toLowerCase().includes(q))
      );
    }

    return list;
  }, [instructions, activeTags, search]);

  return (
    <div className="flex flex-col gap-6">
      <PageHeader
        title="Instructions"
        description="Versioned instruction documents with text and intent search."
      />

      {/* Tag cloud */}
      {allTags.length > 0 && (
        <div className="flex gap-2 overflow-x-auto pb-1 scrollbar-thin">
          {allTags.map((tag) => (
            <button
              key={tag}
              type="button"
              onClick={() => toggleTag(tag)}
              className="shrink-0"
              aria-pressed={activeTags.has(tag)}
            >
              <Tag label={tag} active={activeTags.has(tag)} />
            </button>
          ))}
        </div>
      )}

      {/* Search + mode toggle */}
      <div className="flex flex-wrap items-center gap-3">
        <div className="flex-1 min-w-[180px]">
          <SearchBox
            value={search}
            onChange={setSearch}
            onClear={() => setSearch("")}
            placeholder="Search instructions…"
          />
        </div>

        {/* Mode pills */}
        <div className="flex gap-1 rounded-lg bg-surface-raised border border-border p-1 shrink-0">
          {(["text", "intent"] as const).map((mode) => (
            <button
              key={mode}
              type="button"
              onClick={() => setSearchMode(mode)}
              className={clsx(
                "rounded-md px-3 py-1 text-xs font-medium capitalize transition-colors",
                searchMode === mode
                  ? "bg-brand-500 text-white"
                  : "text-muted hover:text-foreground"
              )}
            >
              {mode === "intent" ? "Intent (mock)" : "Text"}
            </button>
          ))}
        </div>
      </div>

      {/* Result count hint */}
      {!isLoading && instructions && (
        <p className="text-xs text-muted -mt-2">
          {filtered.length} {filtered.length === 1 ? "instruction" : "instructions"}
          {activeTags.size > 0 && ` · ${activeTags.size} tag${activeTags.size > 1 ? "s" : ""} active`}
          {searchMode === "intent" && search.trim() && (
            <span className="ml-1 text-subtle italic">(intent search is simulated)</span>
          )}
        </p>
      )}

      {/* Grid */}
      {isLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
          {Array.from({ length: 6 }).map((_, i) => (
            <div
              key={i}
              className="h-32 rounded-lg bg-surface-raised border border-border animate-pulse"
            />
          ))}
        </div>
      ) : filtered.length === 0 ? (
        <EmptyState
          icon={<BookOpenIcon />}
          title="No instructions match your filters"
          description="Try adjusting your search query or clearing active tags."
          action={
            <button
              type="button"
              onClick={() => {
                setSearch("");
                setActiveTags(new Set());
              }}
              className="text-sm text-accent hover:underline"
            >
              Clear all filters
            </button>
          }
        />
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
          {filtered.map((instr) => (
            <InstructionCard key={instr.uuid} instruction={instr} />
          ))}
        </div>
      )}
    </div>
  );
}
