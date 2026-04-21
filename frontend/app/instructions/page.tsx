"use client";

import { useState, useMemo } from "react";
import useSWR from "swr";
import Link from "next/link";
import { BookOpenIcon } from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import type { Instruction } from "@/lib/api/types";

import { Card } from "@/components/primitives/Card";
import { Badge } from "@/components/primitives/Badge";
import { Tag } from "@/components/primitives/Tag";
import { EmptyState } from "@/components/primitives/EmptyState";
import { PageHeader } from "@/components/primitives/PageHeader";
import { Button } from "@/components/primitives/Button";
import { Segmented } from "@/components/primitives/Segmented";
import { SkeletonGrid } from "@/components/primitives/SkeletonGrid";
import { SearchBox } from "@/components/forms/SearchBox";
import { FilterBar } from "@/components/composites/FilterBar";

import { relativeTime } from "@/lib/utils/format";

// ── Instruction card ──────────────────────────────────────────────────────

function InstructionCard({ instruction }: { instruction: Instruction }) {
  return (
    <Link href={`/instructions/${instruction.uuid}`} className="block rounded-lg focus-ring">
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

        <div className="grid gap-2 mt-1">
          {instruction.tags.length > 0 && (
            <div className="flex flex-wrap gap-1 min-w-0">
              {instruction.tags.map((tag) => (
                <Badge key={tag} variant="default" size="sm">
                  {tag}
                </Badge>
              ))}
            </div>
          )}
          <div className="flex items-center justify-between gap-2 text-xs text-subtle">
            <span>Updated {relativeTime(instruction.updated_at)}</span>
            <span>{instruction.tags.length} {instruction.tags.length === 1 ? "tag" : "tags"}</span>
          </div>
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

      {/* Search + mode toggle (row 1) + tag cloud (row 2) */}
      <FilterBar
        search={
          <SearchBox
            value={search}
            onChange={setSearch}
            onClear={() => setSearch("")}
            placeholder="Search instructions…"
          />
        }
        filters={
          <Segmented
            aria-label="Search mode"
            value={searchMode}
            onChange={setSearchMode}
            options={[
              { value: "text", label: "Text" },
              { value: "intent", label: "Intent (mock)" },
            ]}
          />
        }
        secondary={
          allTags.length > 0 ? (
            <div
              className="flex flex-wrap gap-2"
              role="group"
              aria-label="Filter by tag"
            >
              {allTags.map((tag) => (
                <button
                  key={tag}
                  type="button"
                  onClick={() => toggleTag(tag)}
                  className="focus-ring rounded-full shrink-0"
                  aria-pressed={activeTags.has(tag)}
                >
                  <Tag label={tag} active={activeTags.has(tag)} />
                </button>
              ))}
            </div>
          ) : undefined
        }
        hasActive={Boolean(search) || activeTags.size > 0}
        onClear={() => {
          setSearch("");
          setActiveTags(new Set());
        }}
        summary={
          !isLoading && instructions ? (
            <>
              {filtered.length} {filtered.length === 1 ? "instruction" : "instructions"}
              {activeTags.size > 0 && ` · ${activeTags.size} tag${activeTags.size > 1 ? "s" : ""} active`}
              {searchMode === "intent" && search.trim() && (
                <span className="ml-1 text-subtle italic">(intent search is simulated)</span>
              )}
            </>
          ) : undefined
        }
      />

      {/* Grid */}
      {isLoading ? (
        <SkeletonGrid as="card" count={6} />
      ) : filtered.length === 0 ? (
        <EmptyState
          icon={<BookOpenIcon />}
          title="No instructions match your filters"
          description="Try adjusting your search query or clearing active tags."
          action={
            <Button
              variant="ghost"
              size="sm"
              onClick={() => {
                setSearch("");
                setActiveTags(new Set());
              }}
            >
              Clear all filters
            </Button>
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
