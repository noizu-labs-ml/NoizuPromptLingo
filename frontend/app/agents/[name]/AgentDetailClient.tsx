"use client";

import Link from "next/link";
import { useParams } from "next/navigation";
import useSWR from "swr";
import clsx from "clsx";
import {
  TabGroup,
  TabList,
  Tab,
  TabPanels,
  TabPanel,
} from "@headlessui/react";
import { ArrowLeftIcon, UserGroupIcon } from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import type { AgentInfo } from "@/lib/api/types";
import { Card } from "@/components/primitives/Card";
import { Badge } from "@/components/primitives/Badge";
import type { BadgeProps } from "@/components/primitives/Badge";
import { EmptyState } from "@/components/primitives/EmptyState";
import { PageHeader } from "@/components/primitives/PageHeader";

function kindBadgeVariant(kind: AgentInfo["kind"]): BadgeProps["variant"] {
  switch (kind) {
    case "pipeline": return "info";
    case "executor": return "warning";
    case "utility":  return "default";
  }
}

export function AgentDetailClient() {
  const params = useParams();
  const name = typeof params.name === "string"
    ? params.name
    : Array.isArray(params.name) ? params.name[0] : "";

  const { data: agent, isLoading, error } = useSWR(
    name ? `agent.${name}` : null,
    () => api.agents.get(name),
  );

  if (isLoading) {
    return (
      <div className="space-y-6 animate-pulse">
        <div className="h-8 bg-surface-sunken rounded w-1/3" />
        <div className="h-4 bg-surface-sunken rounded w-1/2" />
        <div className="h-64 bg-surface-sunken rounded" />
      </div>
    );
  }

  if (error || !agent) {
    return (
      <div className="space-y-4">
        <Link
          href="/agents"
          className="inline-flex items-center gap-1.5 text-xs text-muted hover:text-foreground transition-colors"
        >
          <ArrowLeftIcon className="h-3.5 w-3.5" /> Back to agents
        </Link>
        <EmptyState
          icon={<UserGroupIcon />}
          title="Agent not found"
          description={`No agent named "${name}" was found.`}
        />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <Link
        href="/agents"
        className="inline-flex items-center gap-1.5 text-xs text-muted hover:text-foreground transition-colors"
      >
        <ArrowLeftIcon className="h-3.5 w-3.5" /> Back to agents
      </Link>

      <PageHeader
        title={agent.display_name}
        description={agent.description}
        actions={
          <div className="flex items-center gap-2">
            <Badge variant={kindBadgeVariant(agent.kind)}>{agent.kind}</Badge>
            <code className="font-mono text-xs text-muted">{agent.name}</code>
          </div>
        }
      />

      <TabGroup>
        <TabList className="flex gap-1 border-b border-border">
          {["Overview", "Full Body"].map((tab) => (
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
          <TabPanel>
            <Card>
              <dl className="grid grid-cols-1 sm:grid-cols-2 gap-x-6 gap-y-3 text-sm">
                <div>
                  <dt className="text-xs font-semibold uppercase tracking-wide text-subtle">Name</dt>
                  <dd className="font-mono text-foreground">{agent.name}</dd>
                </div>
                <div>
                  <dt className="text-xs font-semibold uppercase tracking-wide text-subtle">Kind</dt>
                  <dd>
                    <Badge variant={kindBadgeVariant(agent.kind)}>{agent.kind}</Badge>
                  </dd>
                </div>
                <div>
                  <dt className="text-xs font-semibold uppercase tracking-wide text-subtle">Model</dt>
                  <dd className="font-mono text-foreground">{agent.model ?? "—"}</dd>
                </div>
                <div>
                  <dt className="text-xs font-semibold uppercase tracking-wide text-subtle">Path</dt>
                  <dd className="font-mono text-xs text-muted break-all">{agent.path}</dd>
                </div>
                <div>
                  <dt className="text-xs font-semibold uppercase tracking-wide text-subtle">Body length</dt>
                  <dd className="text-foreground">{agent.body_length.toLocaleString()} chars</dd>
                </div>
                <div>
                  <dt className="text-xs font-semibold uppercase tracking-wide text-subtle">Allowed tools</dt>
                  <dd>
                    {agent.allowed_tools.length === 0 ? (
                      <span className="text-subtle">—</span>
                    ) : (
                      <div className="flex flex-wrap gap-1 mt-0.5">
                        {agent.allowed_tools.map((t) => (
                          <code
                            key={t}
                            className="inline-flex items-center rounded border border-border bg-surface-sunken px-1.5 py-0.5 text-[11px] font-mono text-muted"
                          >
                            {t}
                          </code>
                        ))}
                      </div>
                    )}
                  </dd>
                </div>
                <div className="sm:col-span-2">
                  <dt className="text-xs font-semibold uppercase tracking-wide text-subtle">Description</dt>
                  <dd className="text-foreground leading-relaxed">
                    {agent.description || <span className="text-subtle">No description.</span>}
                  </dd>
                </div>
              </dl>
            </Card>
          </TabPanel>

          <TabPanel>
            <Card className="p-0 overflow-hidden">
              <pre className="px-4 py-3 text-xs text-foreground whitespace-pre-wrap font-mono leading-relaxed overflow-x-auto max-h-[70vh]">
                {agent.body}
              </pre>
            </Card>
          </TabPanel>
        </TabPanels>
      </TabGroup>
    </div>
  );
}
