"use client";

import { useState, useMemo } from "react";
import useSWR from "swr";
import Link from "next/link";
import clsx from "clsx";
import { Disclosure, DisclosureButton, DisclosurePanel } from "@headlessui/react";
import { ChevronRightIcon, WrenchScrewdriverIcon } from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import type { ToolEntry, CategoryInfo } from "@/lib/api/types";

import { Card } from "@/components/primitives/Card";
import { Badge } from "@/components/primitives/Badge";
import { EmptyState } from "@/components/primitives/EmptyState";
import { PageHeader } from "@/components/primitives/PageHeader";
import { SkeletonGrid } from "@/components/primitives/SkeletonGrid";
import { Button } from "@/components/primitives/Button";
import { SearchBox } from "@/components/forms/SearchBox";
import { FilterListbox } from "@/components/forms/FilterListbox";
import { FilterBar } from "@/components/composites/FilterBar";

// ── Category tree helpers ─────────────────────────────────────────────────

interface CategoryNode {
  name: string;
  fullPath: string;
  toolCount: number;
  children: CategoryNode[];
}

function buildCategoryTree(categories: CategoryInfo[]): CategoryNode[] {
  const topLevel = new Map<string, CategoryNode>();

  for (const cat of categories) {
    const parts = cat.name.split(".");
    const top = parts[0];

    if (!topLevel.has(top)) {
      topLevel.set(top, {
        name: top,
        fullPath: top,
        toolCount: 0,
        children: [],
      });
    }

    const node = topLevel.get(top)!;

    if (parts.length === 1) {
      node.toolCount += cat.tool_count;
    } else {
      node.toolCount += cat.tool_count;
      node.children.push({
        name: parts.slice(1).join("."),
        fullPath: cat.name,
        toolCount: cat.tool_count,
        children: [],
      });
    }
  }

  return Array.from(topLevel.values()).sort((a, b) => a.name.localeCompare(b.name));
}

// ── Tool card ─────────────────────────────────────────────────────────────

function ToolCard({ tool }: { tool: ToolEntry }) {
  return (
    <Link href={`/tools/${encodeURIComponent(tool.name)}`} className="block rounded-lg focus-ring">
      <Card hoverable className="h-full flex flex-col gap-2">
        <div className="flex items-start justify-between gap-2 min-w-0">
          <span className="font-mono text-sm font-semibold text-foreground truncate">
            {tool.name}
          </span>
          <Badge variant="accent" size="sm">
            {tool.category}
          </Badge>
        </div>

        <p className="text-sm text-muted line-clamp-2 flex-1">{tool.description}</p>

        {tool.tags && tool.tags.length > 0 && (
          <div className="flex flex-wrap gap-1 mt-1">
            {tool.tags.map((tag) => (
              <Badge key={tag} variant="default" size="sm">
                {tag}
              </Badge>
            ))}
          </div>
        )}
      </Card>
    </Link>
  );
}

// ── Category sidebar ──────────────────────────────────────────────────────

function CategorySidebar({
  tree,
  selected,
  onSelect,
}: {
  tree: CategoryNode[];
  selected: string;
  onSelect: (cat: string) => void;
}) {
  return (
    <nav className="flex flex-col gap-0.5">
      <button
        type="button"
        onClick={() => onSelect("")}
        className={clsx(
          "focus-ring text-left px-3 py-2 rounded-md text-sm font-medium transition-colors",
          selected === ""
            ? "bg-accent/20 text-accent"
            : "text-muted hover:text-foreground hover:bg-surface-1"
        )}
      >
        All tools
      </button>

      {tree.map((node) =>
        node.children.length === 0 ? (
          <button
            key={node.fullPath}
            type="button"
            onClick={() => onSelect(node.fullPath)}
            className={clsx(
              "focus-ring text-left px-3 py-2 rounded-md text-sm font-medium transition-colors",
              selected === node.fullPath
                ? "bg-accent/20 text-accent"
                : "text-muted hover:text-foreground hover:bg-surface-1"
            )}
          >
            {node.name}
            <span className="ml-1 text-xs text-subtle">({node.toolCount})</span>
          </button>
        ) : (
          <Disclosure key={node.fullPath} defaultOpen={false}>
            {({ open }: { open: boolean }) => (
              <>
                <DisclosureButton
                  className={clsx(
                    "focus-ring flex w-full items-center justify-between px-3 py-2 rounded-md text-sm font-medium transition-colors",
                    selected === node.fullPath
                      ? "bg-accent/20 text-accent"
                      : "text-muted hover:text-foreground hover:bg-surface-1"
                  )}
                  onClick={(e: React.MouseEvent) => {
                    // Allow category select on name click; disclosure handles expand
                    const btn = (e.currentTarget as HTMLButtonElement);
                    // Only select if not clicking the chevron
                    if (!(e.target as HTMLElement).closest(".chevron-icon")) {
                      onSelect(node.fullPath);
                    }
                    void btn;
                  }}
                >
                  <span>
                    {node.name}
                    <span className="ml-1 text-xs text-subtle">({node.toolCount})</span>
                  </span>
                  <ChevronRightIcon
                    className={clsx(
                      "chevron-icon h-3.5 w-3.5 text-subtle transition-transform",
                      open && "rotate-90"
                    )}
                  />
                </DisclosureButton>

                <DisclosurePanel className="ml-3 flex flex-col gap-0.5">
                  {node.children.map((child) => (
                    <button
                      key={child.fullPath}
                      type="button"
                      onClick={() => onSelect(child.fullPath)}
                      className={clsx(
                        "focus-ring text-left px-3 py-1.5 rounded-md text-xs font-medium transition-colors",
                        selected === child.fullPath
                          ? "bg-accent/20 text-accent"
                          : "text-muted hover:text-foreground hover:bg-surface-1"
                      )}
                    >
                      {child.name}
                      <span className="ml-1 text-subtle">({child.toolCount})</span>
                    </button>
                  ))}
                </DisclosurePanel>
              </>
            )}
          </Disclosure>
        )
      )}
    </nav>
  );
}

// ── Page ──────────────────────────────────────────────────────────────────

export default function ToolsPage() {
  const [search, setSearch] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("");
  const [selectedTags, setSelectedTags] = useState<string[]>([]);

  const { data: tools, isLoading: toolsLoading } = useSWR("tools.list", () =>
    api.tools.list()
  );

  const { data: categories } = useSWR("tools.categories", () =>
    api.tools.categories()
  );

  const categoryTree = useMemo(
    () => buildCategoryTree(categories ?? []),
    [categories]
  );

  // Collect all unique tags from catalog
  const allTags = useMemo(() => {
    const set = new Set<string>();
    (tools ?? []).forEach((t) => (t.tags ?? []).forEach((tag) => set.add(tag)));
    return Array.from(set).sort();
  }, [tools]);

  const tagOptions = allTags.map((t) => ({ value: t, label: t }));

  const filtered = useMemo(() => {
    if (!tools) return [];
    let list = tools;

    if (selectedCategory) {
      list = list.filter(
        (t) =>
          t.category === selectedCategory ||
          t.category.startsWith(selectedCategory + ".")
      );
    }

    if (search.trim()) {
      const q = search.trim().toLowerCase();
      list = list.filter(
        (t) =>
          t.name.toLowerCase().includes(q) ||
          t.description.toLowerCase().includes(q) ||
          (t.tags ?? []).some((tag) => tag.toLowerCase().includes(q))
      );
    }

    if (selectedTags.length > 0) {
      list = list.filter((t) =>
        selectedTags.every((tag) => (t.tags ?? []).includes(tag))
      );
    }

    return list;
  }, [tools, selectedCategory, search, selectedTags]);

  return (
    <div className="flex flex-col gap-6">
      <PageHeader
        title="Tools Catalog"
        description="Browse and explore all registered MCP tools."
      />

      <div className="flex gap-6 items-start">
        {/* ── Category sidebar ─────────────────────────────────────────── */}
        <aside className="hidden lg:block w-56 shrink-0 sticky top-6">
          <div className="flex flex-col gap-1">
            <p className="px-3 text-xs font-semibold text-subtle uppercase tracking-wider mb-1">
              Categories
            </p>
            <CategorySidebar
              tree={categoryTree}
              selected={selectedCategory}
              onSelect={setSelectedCategory}
            />
          </div>
        </aside>

        {/* ── Right pane ───────────────────────────────────────────────── */}
        <div className="flex-1 min-w-0 flex flex-col gap-4">
          {/* Filters row */}
          <FilterBar
            search={
              <SearchBox
                value={search}
                onChange={setSearch}
                onClear={() => setSearch("")}
                placeholder="Search tools…"
              />
            }
            filters={
              tagOptions.length > 0 ? (
                <FilterListbox
                  label="Tags"
                  options={tagOptions}
                  selected={selectedTags}
                  onChange={setSelectedTags}
                />
              ) : undefined
            }
            hasActive={Boolean(search || selectedCategory || selectedTags.length > 0)}
            onClear={() => {
              setSearch("");
              setSelectedCategory("");
              setSelectedTags([]);
            }}
            summary={
              tools
                ? `${filtered.length} ${filtered.length === 1 ? "tool" : "tools"}${
                    selectedCategory ? ` in ${selectedCategory}` : ""
                  }`
                : undefined
            }
          />

          {/* Tool grid */}
          {toolsLoading ? (
            <SkeletonGrid as="card" count={6} />
          ) : filtered.length === 0 ? (
            <EmptyState
              icon={<WrenchScrewdriverIcon />}
              title="No tools match your filters"
              description="Try adjusting your search query, category selection, or tag filters."
              action={
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => {
                    setSearch("");
                    setSelectedCategory("");
                    setSelectedTags([]);
                  }}
                >
                  Clear all filters
                </Button>
              }
            />
          ) : (
            <>
              <p className="text-xs text-muted">
                {filtered.length} {filtered.length === 1 ? "tool" : "tools"}
                {selectedCategory && ` in ${selectedCategory}`}
              </p>
              <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                {filtered.map((tool) => (
                  <ToolCard key={tool.name} tool={tool} />
                ))}
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
