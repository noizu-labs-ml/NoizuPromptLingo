"use client";

import useSWR from "swr";
import { TabGroup, TabList, Tab, TabPanels, TabPanel } from "@headlessui/react";
import clsx from "clsx";
import { api } from "@/lib/api/client";
import type { AgentDefinition, PipelineRun } from "@/lib/api/types";
import { Card } from "@/components/primitives/Card";
import { Badge } from "@/components/primitives/Badge";
import { PageHeader } from "@/components/primitives/PageHeader";
import { DataTable } from "@/components/primitives/DataTable";

import { relativeTime } from "@/lib/utils/format";

// ── Helpers ───────────────────────────────────────────────────────────────

function statusVariant(
  status: PipelineRun["status"]
): "default" | "success" | "warning" | "danger" | "info" {
  switch (status) {
    case "complete": return "success";
    case "running": return "info";
    case "failed": return "danger";
    default: return "default";
  }
}

function kindVariant(
  kind: AgentDefinition["kind"]
): "default" | "success" | "warning" | "danger" | "info" {
  switch (kind) {
    case "pipeline": return "info";
    case "utility": return "default";
    case "executor": return "warning";
  }
}

// ── Pipelines panel ───────────────────────────────────────────────────────

function PipelinesPanel() {
  const { data: runs, isLoading } = useSWR("orchestration.recentRuns", () =>
    api.orchestration.recentRuns()
  );

  const columns = [
    {
      key: "feature",
      header: "Feature",
      render: (row: PipelineRun) => (
        <span className="text-sm text-foreground">{row.feature}</span>
      ),
    },
    {
      key: "stage",
      header: "Stage",
      render: (row: PipelineRun) => (
        <span className="font-mono text-xs text-muted">{row.stage}</span>
      ),
    },
    {
      key: "status",
      header: "Status",
      render: (row: PipelineRun) => (
        <Badge variant={statusVariant(row.status)} size="sm">
          {row.status}
        </Badge>
      ),
    },
    {
      key: "started_at",
      header: "Started",
      render: (row: PipelineRun) => (
        <span className="text-sm text-muted">{relativeTime(row.started_at)}</span>
      ),
    },
    {
      key: "completed_at",
      header: "Completed",
      render: (row: PipelineRun) => (
        <span className="text-sm text-muted">
          {row.completed_at ? relativeTime(row.completed_at) : "—"}
        </span>
      ),
    },
  ];

  return (
    <div className="flex flex-col gap-6">
      {/* Trigger form */}
      <Card>
        <h2 className="text-sm font-semibold text-foreground mb-4">Trigger TDD Pipeline</h2>
        <div className="flex flex-col gap-3">
          <label className="flex flex-col gap-1.5">
            <span className="text-sm text-muted">Feature description</span>
            <textarea
              className="rounded-md border border-border bg-surface px-3 py-2 text-sm text-foreground placeholder:text-subtle resize-none h-24 focus:outline-none focus:ring-2 focus:ring-brand-500/50"
              placeholder="Describe the feature to implement via the TDD pipeline…"
            />
          </label>
          <div className="flex justify-end">
            <button
              type="button"
              onClick={() => alert("Pipeline triggering not implemented — preview only.")}
              className="px-4 py-2 rounded-md bg-brand-500 text-white text-sm font-medium hover:opacity-90 transition-opacity"
            >
              Trigger TDD pipeline
            </button>
          </div>
        </div>
      </Card>

      {/* Recent runs */}
      <Card>
        <h2 className="text-sm font-semibold text-foreground mb-4">Recent Runs</h2>
        {isLoading ? (
          <div className="h-48 rounded bg-surface animate-pulse" />
        ) : (
          <DataTable<PipelineRun>
            columns={columns}
            rows={runs ?? []}
            rowKey={(row) => row.id}
            emptyMessage="No pipeline runs recorded."
          />
        )}
      </Card>
    </div>
  );
}

// ── Agents panel ──────────────────────────────────────────────────────────

function AgentsPanel() {
  const { data: agents, isLoading } = useSWR("orchestration.agents", () =>
    api.orchestration.agents()
  );

  if (isLoading) {
    return (
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {Array.from({ length: 6 }).map((_, i) => (
          <div
            key={i}
            className="h-28 rounded-lg bg-surface-raised border border-border animate-pulse"
          />
        ))}
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
      {(agents ?? []).map((agent) => (
        <Card key={agent.name} className="flex flex-col gap-2">
          <div className="flex items-start justify-between gap-2">
            <span className="font-mono text-sm font-semibold text-foreground">{agent.name}</span>
            <Badge variant={kindVariant(agent.kind)} size="sm">
              {agent.kind}
            </Badge>
          </div>
          <p className="text-sm text-muted flex-1">{agent.purpose}</p>
        </Card>
      ))}
    </div>
  );
}

// ── Page ──────────────────────────────────────────────────────────────────

const TABS = ["Pipelines", "Agents"];

export default function OrchestrationPage() {
  return (
    <div className="flex flex-col gap-6">
      <PageHeader
        title="Orchestration"
        description="Pipeline execution and agent coordination."
      />

      {/* Banner */}
      <div className="rounded-md border border-warning/30 bg-warning/10 px-4 py-3 text-sm text-warning">
        <strong>Preview only — pipeline execution coming with PRD-011/012.</strong> Agent list and
        pipeline runs shown for preview only.
      </div>

      {/* Tabs */}
      <TabGroup>
        <TabList className="flex gap-1 rounded-lg bg-surface-raised border border-border p-1 w-fit">
          {TABS.map((tab) => (
            <Tab
              key={tab}
              className={({ selected }: { selected: boolean }) =>
                clsx(
                  "px-4 py-1.5 rounded-md text-sm font-medium transition-colors focus:outline-none",
                  selected
                    ? "bg-brand-500 text-white"
                    : "text-muted hover:text-foreground hover:bg-surface"
                )
              }
            >
              {tab}
            </Tab>
          ))}
        </TabList>

        <TabPanels className="mt-4">
          <TabPanel>
            <PipelinesPanel />
          </TabPanel>
          <TabPanel>
            <AgentsPanel />
          </TabPanel>
        </TabPanels>
      </TabGroup>
    </div>
  );
}
