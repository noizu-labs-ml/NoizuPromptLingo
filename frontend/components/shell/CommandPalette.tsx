"use client";

import { useState, useMemo } from "react";
import { useRouter } from "next/navigation";
import {
  Dialog,
  DialogBackdrop,
  DialogPanel,
  Combobox,
  ComboboxInput,
  ComboboxOptions,
  ComboboxOption,
} from "@headlessui/react";
import { MagnifyingGlassIcon, SparklesIcon } from "@heroicons/react/24/outline";
import useSWR from "swr";
import clsx from "clsx";
import { api } from "@/lib/api/client";
import { Badge } from "@/components/primitives/Badge";
import { Kbd } from "@/components/primitives/Kbd";
import { EmptyState } from "@/components/primitives/EmptyState";

// ── Types ────────────────────────────────────────────────────────────────

interface CommandItem {
  id: string;
  kind: "tool" | "session" | "instruction" | "project" | "nav";
  label: string;
  description?: string;
  href: string;
}

// ── Static nav entries ───────────────────────────────────────────────────

const NAV_ITEMS: CommandItem[] = [
  { id: "nav-/", kind: "nav", label: "Overview", href: "/" },
  { id: "nav-/tools", kind: "nav", label: "Tools", href: "/tools" },
  { id: "nav-/npl", kind: "nav", label: "NPL", href: "/npl" },
  { id: "nav-/sessions", kind: "nav", label: "Sessions", href: "/sessions" },
  { id: "nav-/instructions", kind: "nav", label: "Instructions", href: "/instructions" },
  { id: "nav-/projects", kind: "nav", label: "Projects", href: "/projects" },
  { id: "nav-/chat", kind: "nav", label: "Chat", href: "/chat" },
  { id: "nav-/artifacts", kind: "nav", label: "Artifacts", href: "/artifacts" },
  { id: "nav-/orchestration", kind: "nav", label: "Orchestration", href: "/orchestration" },
  { id: "nav-/metrics", kind: "nav", label: "Metrics", href: "/metrics" },
];

const KIND_ORDER: CommandItem["kind"][] = ["nav", "tool", "session", "instruction", "project"];

const KIND_LABELS: Record<CommandItem["kind"], string> = {
  nav: "Navigation",
  tool: "Tools",
  session: "Sessions",
  instruction: "Instructions",
  project: "Projects",
};

// ── CommandPalette ────────────────────────────────────────────────────────

interface CommandPaletteProps {
  open: boolean;
  onClose: () => void;
}

export function CommandPalette({ open, onClose }: CommandPaletteProps) {
  const router = useRouter();
  const [query, setQuery] = useState("");

  const { data: tools } = useSWR("tools", () => api.tools.list(), { suspense: false });
  const { data: sessions } = useSWR("sessions", () => api.sessions.list(), { suspense: false });
  const { data: instructions } = useSWR("instructions", () => api.instructions.list(), { suspense: false });
  const { data: projects } = useSWR("projects", () => api.projects.list(), { suspense: false });

  const allItems: CommandItem[] = useMemo(() => {
    const items: CommandItem[] = [...NAV_ITEMS];

    if (tools) {
      for (const t of tools) {
        items.push({
          id: `tool-${t.name}`,
          kind: "tool",
          label: t.name,
          description: t.description,
          href: `/tools/${t.name}`,
        });
      }
    }

    if (sessions) {
      for (const s of sessions) {
        const brief = s.brief.length > 40 ? s.brief.slice(0, 40) + "…" : s.brief;
        items.push({
          id: `session-${s.uuid}`,
          kind: "session",
          label: `${s.agent} · ${brief}`,
          href: `/sessions/${s.uuid}`,
        });
      }
    }

    if (instructions) {
      for (const i of instructions) {
        items.push({
          id: `instruction-${i.uuid}`,
          kind: "instruction",
          label: i.title,
          description: i.description,
          href: `/instructions/${i.uuid}`,
        });
      }
    }

    if (projects) {
      for (const p of projects) {
        items.push({
          id: `project-${p.id}`,
          kind: "project",
          label: p.title,
          description: p.description,
          href: `/projects/${p.id}`,
        });
      }
    }

    return items;
  }, [tools, sessions, instructions, projects]);

  const filtered = useMemo(() => {
    if (!query.trim()) return allItems;
    const q = query.toLowerCase();
    return allItems.filter(
      (item) =>
        item.label.toLowerCase().includes(q) ||
        (item.description?.toLowerCase().includes(q) ?? false)
    );
  }, [allItems, query]);

  // Group filtered items by kind in KIND_ORDER order
  const grouped = useMemo(() => {
    const map = new Map<CommandItem["kind"], CommandItem[]>();
    for (const kind of KIND_ORDER) {
      const group = filtered.filter((i) => i.kind === kind);
      if (group.length > 0) map.set(kind, group);
    }
    return map;
  }, [filtered]);

  function handleSelect(item: CommandItem | null) {
    if (!item) return;
    router.push(item.href);
    onClose();
    setQuery("");
  }

  function handleClose() {
    onClose();
    setQuery("");
  }

  return (
    <Dialog open={open} onClose={handleClose} className="relative z-50">
      <DialogBackdrop
        transition
        className="fixed inset-0 bg-black/60 backdrop-blur-sm transition-opacity data-[closed]:opacity-0 data-[enter]:duration-150 data-[leave]:duration-100"
      />

      <div className="fixed inset-0 flex items-start justify-center pt-[20vh] px-4">
        <DialogPanel
          transition
          className="w-full max-w-lg rounded-xl border border-border-strong bg-elevated/95 backdrop-blur-md shadow-elevated overflow-hidden transition data-[closed]:opacity-0 data-[closed]:scale-95 data-[enter]:duration-150 data-[leave]:duration-100"
        >
          <Combobox onChange={handleSelect}>
            {/* Input */}
            <div className="flex items-center gap-2 border-b border-border px-4 py-3">
              <MagnifyingGlassIcon className="h-4 w-4 shrink-0 text-muted" />
              <ComboboxInput
                autoFocus
                className="flex-1 bg-transparent focus-ring rounded-sm text-sm text-foreground placeholder:text-subtle outline-none"
                placeholder="Jump to…"
                value={query}
                onChange={(e) => setQuery(e.target.value)}
              />
              {query && (
                <button
                  type="button"
                  onClick={() => setQuery("")}
                  className="text-xs text-muted hover:text-foreground focus-ring rounded-sm transition-colors"
                >
                  Clear
                </button>
              )}
              <Kbd className="shrink-0">ESC</Kbd>
            </div>

            {/* Screen-reader result count announcer */}
            <span className="sr-only" role="status" aria-live="polite">
              {filtered.length} result{filtered.length === 1 ? "" : "s"}
            </span>

            {/* Results — Combobox already applies listbox semantics; aria-live is handled by the sr-only status above */}
            <ComboboxOptions
              static
              className="max-h-80 overflow-y-auto scrollbar-thin py-2"
            >
              {grouped.size === 0 ? (
                <div className="px-4 py-4">
                  <EmptyState
                    icon={<SparklesIcon />}
                    title="No results"
                    description={`Nothing matches “${query}”.`}
                  />
                </div>
              ) : (
                Array.from(grouped.entries()).map(([kind, items]) => (
                  <div key={kind}>
                    <div className="px-4 py-1.5">
                      <span className="text-[11px] font-semibold uppercase tracking-widest text-subtle">
                        {KIND_LABELS[kind]}
                      </span>
                    </div>
                    {items.map((item) => (
                      <ComboboxOption
                        key={item.id}
                        value={item}
                        className={({ focus }: { focus: boolean }) =>
                          clsx(
                            "flex items-center gap-3 px-4 py-2 cursor-pointer transition-colors",
                            focus
                              ? "bg-accent/15 text-accent shadow-ring"
                              : "text-muted hover:bg-surface-1 hover:text-foreground"
                          )
                        }
                      >
                        <div className="flex-1 min-w-0">
                          <div className="text-sm font-medium truncate">{item.label}</div>
                          {item.description && (
                            <div className="text-xs text-subtle truncate mt-0.5">
                              {item.description}
                            </div>
                          )}
                        </div>
                        <Badge variant="default" size="sm">
                          {item.kind}
                        </Badge>
                      </ComboboxOption>
                    ))}
                  </div>
                ))
              )}
            </ComboboxOptions>
          </Combobox>
        </DialogPanel>
      </div>
    </Dialog>
  );
}
