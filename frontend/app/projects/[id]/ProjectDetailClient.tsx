"use client";

import { useParams } from "next/navigation";
import useSWR, { useSWRConfig } from "swr";
import { useState, useRef, useEffect } from "react";
import {
  TabGroup,
  TabList,
  Tab,
  TabPanels,
  TabPanel,
  Disclosure,
  DisclosureButton,
  DisclosurePanel,
  Listbox,
  ListboxButton,
  ListboxOption,
  ListboxOptions,
} from "@headlessui/react";
import {
  ChevronDownIcon,
  FolderOpenIcon,
  CheckIcon,
} from "@heroicons/react/24/outline";
import clsx from "clsx";

import { api } from "@/lib/api/client";
import type { StoryStatus, StoryPriority } from "@/lib/api/types";
import { Card } from "@/components/primitives/Card";
import { Badge } from "@/components/primitives/Badge";
import type { BadgeProps } from "@/components/primitives/Badge";
import { Tag } from "@/components/primitives/Tag";
import { EmptyState } from "@/components/primitives/EmptyState";
import { PageHeader } from "@/components/primitives/PageHeader";
import { CodeBlock } from "@/components/primitives/CodeBlock";
import { FilterListbox } from "@/components/forms/FilterListbox";

// ── Helpers ───────────────────────────────────────────────────────────────

function formatDate(iso: string): string {
  return new Date(iso).toLocaleDateString("en-US", {
    year: "numeric",
    month: "short",
    day: "numeric",
  });
}

const STATUS_VARIANT: Record<StoryStatus, BadgeProps["variant"]> = {
  draft: "info",
  ready: "info",
  in_progress: "warning",
  done: "success",
  archived: "default",
};

const PRIORITY_VARIANT: Record<StoryPriority, BadgeProps["variant"]> = {
  critical: "danger",
  high: "warning",
  medium: "info",
  low: "default",
};

const ALL_STATUSES: StoryStatus[] = ["draft", "ready", "in_progress", "done", "archived"];
const ALL_PRIORITIES: StoryPriority[] = ["critical", "high", "medium", "low"];

const STATUS_LABEL: Record<StoryStatus, string> = {
  draft: "Draft",
  ready: "Ready",
  in_progress: "In Progress",
  done: "Done",
  archived: "Archived",
};

const PRIORITY_LABEL: Record<StoryPriority, string> = {
  critical: "Critical",
  high: "High",
  medium: "Medium",
  low: "Low",
};

// ── Overview Tab ──────────────────────────────────────────────────────────

function OverviewTab({
  project,
  storyStatusCounts,
}: {
  project: { name: string; title: string; description: string; persona_count: number; story_count: number; created_at: string };
  storyStatusCounts: Record<StoryStatus, number>;
}) {
  const total = Object.values(storyStatusCounts).reduce((a, b) => a + b, 0) || 1;

  return (
    <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
      {/* Info card */}
      <Card>
        <h3 className="text-sm font-semibold text-foreground mb-3">Info</h3>
        <dl className="space-y-2 text-sm">
          <div className="flex gap-2">
            <dt className="text-muted w-32 shrink-0">Name</dt>
            <dd className="font-mono text-foreground">{project.name}</dd>
          </div>
          <div className="flex gap-2">
            <dt className="text-muted w-32 shrink-0">Title</dt>
            <dd className="text-foreground">{project.title}</dd>
          </div>
          <div className="flex gap-2">
            <dt className="text-muted w-32 shrink-0">Description</dt>
            <dd className="text-foreground">{project.description}</dd>
          </div>
          <div className="flex gap-2">
            <dt className="text-muted w-32 shrink-0">Personas</dt>
            <dd className="text-foreground">{project.persona_count}</dd>
          </div>
          <div className="flex gap-2">
            <dt className="text-muted w-32 shrink-0">Stories</dt>
            <dd className="text-foreground">{project.story_count}</dd>
          </div>
          <div className="flex gap-2">
            <dt className="text-muted w-32 shrink-0">Created</dt>
            <dd className="text-foreground">{formatDate(project.created_at)}</dd>
          </div>
        </dl>
      </Card>

      {/* Story status card */}
      <Card>
        <h3 className="text-sm font-semibold text-foreground mb-3">Story Status</h3>
        <div className="space-y-2">
          {ALL_STATUSES.map((status) => {
            const count = storyStatusCounts[status] ?? 0;
            const pct = Math.round((count / total) * 100);
            return (
              <div key={status} className="space-y-1">
                <div className="flex items-center justify-between text-xs">
                  <span className="text-muted">{STATUS_LABEL[status]}</span>
                  <span className="text-foreground font-medium">{count}</span>
                </div>
                <div className="h-2 rounded-full bg-surface-1 overflow-hidden">
                  <div
                    className="h-full rounded-full bg-accent transition-all"
                    style={{ width: `${pct}%` }}
                  />
                </div>
              </div>
            );
          })}
        </div>
      </Card>
    </div>
  );
}

// ── Persona Card ──────────────────────────────────────────────────────────

function PersonaCard({ persona }: { persona: { name: string; role: string; description: string; goals: string[]; pain_points: string[]; demographics: Record<string, string | number | boolean> } }) {
  return (
    <Card className="flex flex-col gap-3">
      <div>
        <p className="font-semibold text-foreground">{persona.name}</p>
        <p className="text-sm text-muted">{persona.role}</p>
      </div>

      <p className="text-sm text-muted line-clamp-3">{persona.description}</p>

      {persona.goals.length > 0 && (
        <div>
          <p className="text-xs font-semibold text-foreground uppercase tracking-wide mb-1">Goals</p>
          <ul className="space-y-1">
            {persona.goals.map((g, i) => (
              <li key={i} className="flex gap-2 text-sm text-muted">
                <span className="text-accent shrink-0">•</span>
                <span>{g}</span>
              </li>
            ))}
          </ul>
        </div>
      )}

      {persona.pain_points.length > 0 && (
        <div>
          <p className="text-xs font-semibold text-foreground uppercase tracking-wide mb-1">Pain Points</p>
          <ul className="space-y-1">
            {persona.pain_points.map((p, i) => (
              <li key={i} className="flex gap-2 text-sm text-muted">
                <span className="text-accent shrink-0">•</span>
                <span>{p}</span>
              </li>
            ))}
          </ul>
        </div>
      )}

      <Disclosure>
        {({ open }) => (
          <div>
            <DisclosureButton className="flex items-center gap-1 text-xs font-semibold text-muted hover:text-foreground uppercase tracking-wide transition-colors">
              Demographics
              <ChevronDownIcon
                className={clsx("h-3 w-3 transition-transform", open && "rotate-180")}
              />
            </DisclosureButton>
            <DisclosurePanel className="mt-2">
              <CodeBlock
                code={JSON.stringify(persona.demographics, null, 2)}
                language="json"
              />
            </DisclosurePanel>
          </div>
        )}
      </Disclosure>
    </Card>
  );
}

// ── Inline field editor (Listbox) ─────────────────────────────────────────

function InlineListbox<T extends string>({
  value,
  options,
  label,
  variant,
  onSelect,
}: {
  value: T;
  options: { value: T; label: string }[];
  label: string;
  variant: BadgeProps["variant"];
  onSelect: (newValue: T) => void;
}) {
  return (
    <Listbox value={value} onChange={onSelect}>
      <div className="relative">
        <ListboxButton className="flex items-center gap-0.5 focus:outline-none">
          <Badge variant={variant}>{label}</Badge>
          <ChevronDownIcon className="h-3 w-3 text-muted" />
        </ListboxButton>
        <ListboxOptions
          anchor="bottom start"
          className="absolute z-50 mt-1 w-36 rounded-md border border-border bg-surface-2 shadow-elevated py-1 text-sm focus:outline-none"
        >
          {options.map((opt) => (
            <ListboxOption
              key={opt.value}
              value={opt.value}
              className={({ focus }: { focus: boolean }) =>
                clsx(
                  "flex items-center gap-2 px-3 py-1.5 cursor-pointer",
                  focus ? "bg-surface-1 text-foreground" : "text-muted"
                )
              }
            >
              {({ selected }: { selected: boolean }) => (
                <>
                  <span className="w-3 shrink-0">
                    {selected && <CheckIcon className="h-3 w-3 text-accent" />}
                  </span>
                  {opt.label}
                </>
              )}
            </ListboxOption>
          ))}
        </ListboxOptions>
      </div>
    </Listbox>
  );
}

// ── Story Card ────────────────────────────────────────────────────────────

function StoryCard({
  story,
  projectId,
}: {
  story: { id: string; title: string; status: StoryStatus; priority: StoryPriority; story_points: number; acceptance_criteria: string[]; tags: string[] };
  projectId: string;
}) {
  const { mutate } = useSWRConfig();
  const [saving, setSaving] = useState(false);
  const [saveOk, setSaveOk] = useState(false);
  const [saveError, setSaveError] = useState<string | null>(null);
  const okTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => () => { if (okTimer.current) clearTimeout(okTimer.current); }, []);

  async function handleUpdate(
    field: "status" | "priority",
    value: StoryStatus | StoryPriority
  ) {
    setSaving(true);
    setSaveError(null);
    setSaveOk(false);
    try {
      await api.stories.update(story.id, { [field]: value });
      await mutate(`stories.${projectId}`);
      setSaveOk(true);
      okTimer.current = setTimeout(() => setSaveOk(false), 1500);
    } catch (err) {
      setSaveError(err instanceof Error ? err.message : "Update failed");
    } finally {
      setSaving(false);
    }
  }

  const statusOptions = ALL_STATUSES.map((s) => ({ value: s, label: STATUS_LABEL[s] }));
  const priorityOptions = ALL_PRIORITIES.map((p) => ({ value: p, label: PRIORITY_LABEL[p] }));

  return (
    <Card className="flex flex-col gap-2">
      <p className="font-semibold text-foreground text-sm">{story.title}</p>

      <div className="flex flex-wrap gap-2 items-center">
        <InlineListbox
          value={story.status}
          options={statusOptions}
          label={STATUS_LABEL[story.status]}
          variant={STATUS_VARIANT[story.status]}
          onSelect={(v) => handleUpdate("status", v)}
        />
        <InlineListbox
          value={story.priority}
          options={priorityOptions}
          label={PRIORITY_LABEL[story.priority]}
          variant={PRIORITY_VARIANT[story.priority]}
          onSelect={(v) => handleUpdate("priority", v)}
        />
        {story.story_points > 0 && (
          <span className="inline-flex items-center rounded-full bg-surface-1 border border-border text-muted px-2 py-0.5 text-xs">
            {story.story_points} pts
          </span>
        )}
        <span
          className="inline-flex items-center gap-1 text-xs"
          role={saveError ? "alert" : "status"}
          aria-live="polite"
        >
          {saving && (
            <span className="inline-flex items-center text-muted animate-pulse">saving…</span>
          )}
          {saveOk && !saving && (
            <span className="inline-flex items-center text-success">
              <CheckIcon className="h-3 w-3 mr-0.5" /> saved
            </span>
          )}
          {saveError && !saving && (
            <span className="inline-flex items-center text-danger" title={saveError}>
              error
            </span>
          )}
        </span>
      </div>

      {story.acceptance_criteria.length > 0 && (
        <ul className="space-y-0.5">
          {story.acceptance_criteria.slice(0, 3).map((c, i) => (
            <li key={i} className="flex gap-2 text-xs text-muted">
              <span className="text-accent shrink-0">✓</span>
              <span className="line-clamp-1">{c}</span>
            </li>
          ))}
        </ul>
      )}

      {story.tags.length > 0 && (
        <div className="flex flex-wrap gap-1 pt-1">
          {story.tags.map((tag) => (
            <Tag key={tag} label={tag} />
          ))}
        </div>
      )}
    </Card>
  );
}

// ── Stories Tab ───────────────────────────────────────────────────────────

function StoriesTab({ projectId }: { projectId: string }) {
  const { data: stories } = useSWR(`stories.${projectId}`, () =>
    api.stories.listByProject(projectId)
  );

  const [viewMode, setViewMode] = useState<"list" | "kanban">("list");
  const [statusFilter, setStatusFilter] = useState<string[]>([]);
  const [priorityFilter, setPriorityFilter] = useState<string[]>([]);

  const filtered = (stories ?? []).filter((s) => {
    if (statusFilter.length > 0 && !statusFilter.includes(s.status)) return false;
    if (priorityFilter.length > 0 && !priorityFilter.includes(s.priority)) return false;
    return true;
  });

  const statusOptions = ALL_STATUSES.map((s) => ({ value: s, label: STATUS_LABEL[s] }));
  const priorityOptions = ALL_PRIORITIES.map((p) => ({ value: p, label: PRIORITY_LABEL[p] }));

  return (
    <div className="space-y-4">
      {/* Controls */}
      <div className="flex flex-wrap gap-3 items-center">
        {/* View toggle */}
        <div className="flex rounded-md border border-border overflow-hidden">
          <button
            type="button"
            onClick={() => setViewMode("list")}
            className={clsx(
              "focus-ring px-3 py-1.5 text-sm font-medium transition-colors",
              viewMode === "list"
                ? "bg-accent text-accent-on"
                : "bg-surface-1 text-muted hover:text-foreground"
            )}
          >
            List
          </button>
          <button
            type="button"
            onClick={() => setViewMode("kanban")}
            className={clsx(
              "focus-ring px-3 py-1.5 text-sm font-medium transition-colors border-l border-border",
              viewMode === "kanban"
                ? "bg-accent text-accent-on"
                : "bg-surface-1 text-muted hover:text-foreground"
            )}
          >
            Kanban
          </button>
        </div>

        <FilterListbox
          label="Status"
          options={statusOptions}
          selected={statusFilter}
          onChange={setStatusFilter}
        />
        <FilterListbox
          label="Priority"
          options={priorityOptions}
          selected={priorityFilter}
          onChange={setPriorityFilter}
        />

        {(statusFilter.length > 0 || priorityFilter.length > 0) && (
          <button
            type="button"
            onClick={() => { setStatusFilter([]); setPriorityFilter([]); }}
            className="focus-ring rounded text-xs text-muted hover:text-foreground transition-colors"
          >
            Clear filters
          </button>
        )}
      </div>

      {/* List mode */}
      {viewMode === "list" && (
        filtered.length === 0 ? (
          <EmptyState title="No stories match filters" description="Try adjusting the filters above." />
        ) : (
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
            {filtered.map((s) => (
              <StoryCard key={s.id} story={s} projectId={projectId} />
            ))}
          </div>
        )
      )}

      {/* Kanban mode */}
      {viewMode === "kanban" && (
        <div className="flex gap-4 overflow-x-auto pb-4">
          {ALL_STATUSES.map((status) => {
            const colStories = filtered.filter((s) => s.status === status);
            return (
              <div key={status} className="flex-shrink-0 w-64 flex flex-col gap-2">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-semibold text-foreground">
                    {STATUS_LABEL[status]}
                  </span>
                  <Badge variant={STATUS_VARIANT[status]}>{colStories.length}</Badge>
                </div>
                <div className="flex flex-col gap-2 overflow-y-auto max-h-[70vh]">
                  {colStories.length === 0 ? (
                    <div className="rounded-lg border border-dashed border-border p-3 text-center text-xs text-subtle">
                      Empty
                    </div>
                  ) : (
                    colStories.map((s) => <StoryCard key={s.id} story={s} projectId={projectId} />)
                  )}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

// ── Main Component ────────────────────────────────────────────────────────

export function ProjectDetailClient() {
  const params = useParams();
  const id = typeof params.id === "string" ? params.id : Array.isArray(params.id) ? params.id[0] : "";

  const { data: project, isLoading: projectLoading } = useSWR(
    id ? `project.${id}` : null,
    () => api.projects.get(id)
  );
  const { data: personas } = useSWR(
    id ? `personas.${id}` : null,
    () => api.personas.listByProject(id)
  );
  const { data: stories } = useSWR(
    id ? `stories.${id}` : null,
    () => api.stories.listByProject(id)
  );

  if (projectLoading) {
    return (
      <div className="space-y-6 animate-pulse">
        <div className="h-8 bg-surface-1 rounded w-1/3" />
        <div className="h-4 bg-surface-1 rounded w-1/2" />
      </div>
    );
  }

  if (!project) {
    return (
      <EmptyState
        icon={<FolderOpenIcon />}
        title="Project not found"
        description={`No project with id "${id}" exists.`}
      />
    );
  }

  // Build status counts
  const storyStatusCounts = ALL_STATUSES.reduce(
    (acc, s) => ({ ...acc, [s]: 0 }),
    {} as Record<StoryStatus, number>
  );
  (stories ?? []).forEach((s) => {
    storyStatusCounts[s.status] = (storyStatusCounts[s.status] ?? 0) + 1;
  });

  return (
    <div className="space-y-6">
      <PageHeader
        title={project.title}
        description={project.description}
        actions={
          <span className="text-sm text-muted">
            Created {formatDate(project.created_at)}
          </span>
        }
      />

      <TabGroup>
        <TabList className="flex gap-1 border-b border-border">
          {["Overview", "Personas", "Stories"].map((tab) => (
            <Tab
              key={tab}
              className={({ selected }: { selected: boolean }) =>
                clsx(
                  "px-4 py-2 text-sm font-medium transition-colors border-b-2 -mb-px",
                  selected
                    ? "border-accent text-accent"
                    : "border-transparent text-muted hover:text-foreground"
                )
              }
            >
              {tab}
            </Tab>
          ))}
        </TabList>

        <TabPanels className="mt-4">
          {/* Overview */}
          <TabPanel>
            <OverviewTab project={project} storyStatusCounts={storyStatusCounts} />
          </TabPanel>

          {/* Personas */}
          <TabPanel>
            {(!personas || personas.length === 0) ? (
              <EmptyState title="No personas" description="This project has no personas yet." />
            ) : (
              <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
                {personas.map((p) => (
                  <PersonaCard key={p.id} persona={p} />
                ))}
              </div>
            )}
          </TabPanel>

          {/* Stories */}
          <TabPanel>
            <StoriesTab projectId={id} />
          </TabPanel>
        </TabPanels>
      </TabGroup>
    </div>
  );
}
