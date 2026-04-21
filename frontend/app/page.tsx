"use client";

import Link from "next/link";
import useSWR from "swr";
import {
  ClockIcon,
  BookOpenIcon,
  FolderIcon,
  WrenchScrewdriverIcon,
  ChevronRightIcon,
} from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import { Card } from "@/components/primitives/Card";
import { Badge } from "@/components/primitives/Badge";
import { PageHeader } from "@/components/primitives/PageHeader";
import { DataTable } from "@/components/primitives/DataTable";
import type { Session } from "@/lib/api/types";
import { relativeTime, truncate } from "@/lib/utils/format";

function StatTile({
  label,
  value,
  href,
  icon: Icon,
  description,
}: {
  label: string;
  value: number | string;
  href: string;
  icon: React.ComponentType<{ className?: string }>;
  description: string;
}) {
  return (
    <Link href={href} className="block group">
      <Card hoverable>
        <div className="flex items-start justify-between">
          <div>
            <div className="text-sm uppercase tracking-wide text-muted">
              {label}
            </div>
            <div className="mt-1 text-3xl font-semibold text-foreground">
              {value}
            </div>
            <div className="mt-1 text-xs text-subtle">{description}</div>
          </div>
          <Icon className="h-6 w-6 text-muted group-hover:text-accent transition-colors" />
        </div>
      </Card>
    </Link>
  );
}


export default function Home() {
  const { data: tools } = useSWR("tools.list", () => api.tools.list());
  const { data: sessions } = useSWR("sessions.list", () =>
    api.sessions.list({ limit: 10 }),
  );
  const { data: instructions } = useSWR("instructions.list", () =>
    api.instructions.list(),
  );
  const { data: projects } = useSWR("projects.list", () => api.projects.list());

  const mcpCount = tools?.filter((t) => t.category !== "Uncategorized").length ?? 0;

  return (
    <div className="space-y-8">
      <PageHeader
        title="NPL MCP Companion"
        description="A dashboard view of the Noizu Prompt Lingua MCP server — catalog, sessions, instructions, projects, and more."
        actions={
          <Badge variant="info" size="sm">
            mock data
          </Badge>
        }
      />

      <section className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <StatTile
          label="Catalog tools"
          value={tools?.length ?? "—"}
          href="/tools"
          icon={WrenchScrewdriverIcon}
          description={`${mcpCount} categorized`}
        />
        <StatTile
          label="Sessions"
          value={sessions?.length ?? "—"}
          href="/sessions"
          icon={ClockIcon}
          description="Last 24h (mock)"
        />
        <StatTile
          label="Instructions"
          value={instructions?.length ?? "—"}
          href="/instructions"
          icon={BookOpenIcon}
          description="Versioned documents"
        />
        <StatTile
          label="Projects"
          value={projects?.length ?? "—"}
          href="/projects"
          icon={FolderIcon}
          description="Personas + stories"
        />
      </section>

      <section className="space-y-3">
        <div className="flex items-center justify-between">
          <h2 className="text-lg font-semibold text-foreground">
            Recent sessions
          </h2>
          <Link
            href="/sessions"
            className="text-sm text-muted hover:text-foreground inline-flex items-center gap-1"
          >
            View all <ChevronRightIcon className="h-4 w-4" />
          </Link>
        </div>

        <Card padded={false}>
          <DataTable<Session>
            rowKey={(s) => s.uuid}
            rows={sessions ?? []}
            emptyMessage="No sessions yet."
            columns={[
              {
                key: "agent",
                header: "Agent",
                render: (s) => (
                  <span className="font-mono text-sm">{s.agent}</span>
                ),
              },
              {
                key: "brief",
                header: "Brief",
                render: (s) => (
                  <span className="text-foreground">
                    {truncate(s.brief, 60)}
                  </span>
                ),
              },
              {
                key: "project",
                header: "Project",
                render: (s) => (
                  <Badge variant="info" size="sm">
                    {s.project}
                  </Badge>
                ),
              },
              {
                key: "updated_at",
                header: "Updated",
                render: (s) => (
                  <span className="text-muted text-sm">
                    {relativeTime(s.updated_at)}
                  </span>
                ),
              },
            ]}
          />
        </Card>
      </section>
    </div>
  );
}
