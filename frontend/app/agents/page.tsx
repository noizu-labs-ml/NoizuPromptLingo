"use client";

import Link from "next/link";
import { useState } from "react";
import useSWR from "swr";
import { UserGroupIcon } from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import type { AgentInfo } from "@/lib/api/types";
import { Card } from "@/components/primitives/Card";
import { PageHeader } from "@/components/primitives/PageHeader";
import { EmptyState } from "@/components/primitives/EmptyState";
import { Badge } from "@/components/primitives/Badge";
import type { BadgeProps } from "@/components/primitives/Badge";
import { FilterListbox } from "@/components/forms/FilterListbox";

function kindBadgeVariant(kind: AgentInfo["kind"]): BadgeProps["variant"] {
  switch (kind) {
    case "pipeline": return "info";
    case "executor": return "warning";
    case "utility":  return "default";
  }
}

const KIND_OPTIONS = [
  { value: "pipeline", label: "Pipeline" },
  { value: "utility",  label: "Utility"  },
  { value: "executor", label: "Executor" },
];

function AgentCard({ agent }: { agent: AgentInfo }) {
  return (
    <Link href={`/agents/${agent.name}`} className="block group">
      <Card hoverable className="h-full flex flex-col gap-3">
        <div className="flex items-start justify-between gap-2">
          <div className="flex flex-col min-w-0">
            <p className="font-semibold text-foreground group-hover:text-accent transition-colors text-sm leading-snug truncate">
              {agent.display_name}
            </p>
            <code className="text-[11px] font-mono text-subtle truncate">{agent.name}</code>
          </div>
          <Badge variant={kindBadgeVariant(agent.kind)}>{agent.kind}</Badge>
        </div>

        <p className="text-xs text-muted leading-relaxed line-clamp-3">
          {agent.description || "No description provided."}
        </p>

        <div className="flex items-center justify-between gap-2 mt-auto pt-2 border-t border-border text-[11px] text-subtle">
          <span className="truncate">
            {agent.model ? <>model: <span className="text-muted font-mono">{agent.model}</span></> : "no model"}
          </span>
          <span className="shrink-0">
            {agent.allowed_tools.length} tool{agent.allowed_tools.length === 1 ? "" : "s"}
          </span>
        </div>
      </Card>
    </Link>
  );
}

export default function AgentsPage() {
  const { data: agents, isLoading, error } = useSWR("agents.list", () => api.agents.list());
  const [search, setSearch] = useState("");
  const [kindFilter, setKindFilter] = useState<string[]>([]);

  const filtered = (agents ?? []).filter((a) => {
    if (kindFilter.length > 0 && !kindFilter.includes(a.kind)) return false;
    if (search) {
      const q = search.toLowerCase();
      if (
        !a.name.toLowerCase().includes(q) &&
        !a.display_name.toLowerCase().includes(q) &&
        !a.description.toLowerCase().includes(q)
      ) return false;
    }
    return true;
  });

  return (
    <div className="space-y-8">
      <PageHeader
        title="Agents"
        description="TDD pipeline agents and utility/executor agents defined in agents/*.md."
      />

      <div className="flex flex-wrap gap-3 items-center">
        <input
          type="search"
          placeholder="Search agents..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="rounded-md border border-border bg-surface px-3 py-1.5 text-sm text-foreground placeholder:text-subtle focus:outline-none focus:ring-2 focus:ring-accent/50 w-64"
        />
        <FilterListbox
          label="Kind"
          options={KIND_OPTIONS}
          selected={kindFilter}
          onChange={setKindFilter}
        />
        {(search || kindFilter.length > 0) && (
          <button
            onClick={() => { setSearch(""); setKindFilter([]); }}
            className="text-xs text-muted hover:text-foreground transition-colors"
          >
            Clear filters
          </button>
        )}
      </div>

      {error && (
        <div className="rounded-md border border-danger/30 bg-danger/10 px-4 py-3 text-sm text-danger">
          Failed to load agents: {String(error)}
        </div>
      )}

      {isLoading && (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <Card key={i} className="animate-pulse">
              <div className="h-4 bg-surface-sunken rounded w-3/4 mb-2" />
              <div className="h-3 bg-surface-sunken rounded w-1/2 mb-3" />
              <div className="h-3 bg-surface-sunken rounded w-full" />
            </Card>
          ))}
        </div>
      )}

      {!isLoading && filtered.length === 0 && (
        <EmptyState
          icon={<UserGroupIcon />}
          title="No agents found"
          description={
            search || kindFilter.length > 0
              ? "Try adjusting the search or filters."
              : "No agents are defined in the agents/ directory."
          }
        />
      )}

      {!isLoading && filtered.length > 0 && (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {filtered.map((agent) => (
            <AgentCard key={agent.name} agent={agent} />
          ))}
        </div>
      )}
    </div>
  );
}
