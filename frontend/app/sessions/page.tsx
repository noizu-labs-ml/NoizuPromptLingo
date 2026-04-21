"use client";

import { useState, useMemo } from "react";
import useSWR from "swr";
import { useRouter } from "next/navigation";

import { api } from "@/lib/api/client";
import type { Session } from "@/lib/api/types";

import { Badge } from "@/components/primitives/Badge";
import { DataTable } from "@/components/primitives/DataTable";
import { EmptyState } from "@/components/primitives/EmptyState";
import { PageHeader } from "@/components/primitives/PageHeader";
import { SearchBox } from "@/components/forms/SearchBox";
import { FilterListbox } from "@/components/forms/FilterListbox";

import { ClockIcon } from "@heroicons/react/24/outline";
import { relativeTime, truncate } from "@/lib/utils/format";

// ── Page ──────────────────────────────────────────────────────────────────

export default function SessionsPage() {
  const router = useRouter();
  const [search, setSearch] = useState("");
  const [selectedProjects, setSelectedProjects] = useState<string[]>([]);
  const [selectedAgents, setSelectedAgents] = useState<string[]>([]);

  const { data: sessions, isLoading } = useSWR("sessions.list", () =>
    api.sessions.list()
  );

  const projectOptions = useMemo(() => {
    const set = new Set<string>();
    (sessions ?? []).forEach((s) => set.add(s.project));
    return Array.from(set)
      .sort()
      .map((v) => ({ value: v, label: v }));
  }, [sessions]);

  const agentOptions = useMemo(() => {
    const set = new Set<string>();
    (sessions ?? []).forEach((s) => set.add(s.agent));
    return Array.from(set)
      .sort()
      .map((v) => ({ value: v, label: v }));
  }, [sessions]);

  const filtered = useMemo(() => {
    if (!sessions) return [];
    let list = sessions;

    if (selectedProjects.length > 0) {
      list = list.filter((s) => selectedProjects.includes(s.project));
    }

    if (selectedAgents.length > 0) {
      list = list.filter((s) => selectedAgents.includes(s.agent));
    }

    if (search.trim()) {
      const q = search.trim().toLowerCase();
      list = list.filter(
        (s) =>
          s.brief.toLowerCase().includes(q) ||
          (s.notes ?? "").toLowerCase().includes(q)
      );
    }

    return list;
  }, [sessions, selectedProjects, selectedAgents, search]);

  const columns = [
    {
      key: "agent",
      header: "Agent",
      render: (row: Session) => (
        <span className="font-mono text-sm text-foreground">{row.agent}</span>
      ),
    },
    {
      key: "brief",
      header: "Brief",
      render: (row: Session) => (
        <span className="text-foreground">
          {truncate(row.brief, 60)}
        </span>
      ),
    },
    {
      key: "task",
      header: "Task",
      render: (row: Session) => (
        <span className="text-muted text-sm">{row.task}</span>
      ),
    },
    {
      key: "project",
      header: "Project",
      render: (row: Session) => <Badge variant="info">{row.project}</Badge>,
    },
    {
      key: "updated_at",
      header: "Updated",
      render: (row: Session) => (
        <span className="text-muted text-sm">{relativeTime(row.updated_at)}</span>
      ),
    },
  ];

  return (
    <div className="flex flex-col gap-6">
      <PageHeader
        title="Sessions"
        description="Agent sessions keyed by (project, agent, task) with parent hierarchy."
        actions={
          sessions ? (
            <Badge variant="info" size="md">
              {sessions.length} total
            </Badge>
          ) : undefined
        }
      />

      {/* Filter row */}
      <div className="flex flex-wrap items-center gap-3">
        <div className="flex-1 min-w-[200px]">
          <SearchBox
            value={search}
            onChange={setSearch}
            onClear={() => setSearch("")}
            placeholder="Search brief or notes…"
          />
        </div>
        <FilterListbox
          label="Project"
          options={projectOptions}
          selected={selectedProjects}
          onChange={setSelectedProjects}
        />
        <FilterListbox
          label="Agent"
          options={agentOptions}
          selected={selectedAgents}
          onChange={setSelectedAgents}
        />
      </div>

      {/* Table */}
      {isLoading ? (
        <div className="h-64 rounded-lg bg-surface-raised border border-border animate-pulse" />
      ) : filtered.length === 0 ? (
        <EmptyState
          icon={<ClockIcon />}
          title="No sessions found"
          description="Try adjusting your search or filter criteria."
          action={
            <button
              type="button"
              onClick={() => {
                setSearch("");
                setSelectedProjects([]);
                setSelectedAgents([]);
              }}
              className="text-sm text-accent hover:underline"
            >
              Clear all filters
            </button>
          }
        />
      ) : (
        <DataTable<Session>
          columns={columns}
          rows={filtered}
          rowKey={(row) => row.uuid}
          onRowClick={(row) => router.push(`/sessions/${row.uuid}`)}
          emptyMessage="No sessions match your filters."
        />
      )}
    </div>
  );
}
