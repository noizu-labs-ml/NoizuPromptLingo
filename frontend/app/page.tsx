"use client";

import Link from "next/link";
import useSWR from "swr";
import {
  ClockIcon,
  BookOpenIcon,
  FolderIcon,
  WrenchScrewdriverIcon,
  ChevronRightIcon,
  ClipboardDocumentListIcon,
  ArchiveBoxIcon,
} from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import { Card } from "@/components/primitives/Card";
import { Badge } from "@/components/primitives/Badge";
import { PageHeader } from "@/components/primitives/PageHeader";
import { DataTable } from "@/components/primitives/DataTable";
import { StatTile } from "@/components/primitives/StatTile";
import type { Session } from "@/lib/api/types";
import { relativeTime, truncate } from "@/lib/utils/format";


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
  const fmt = (n: number | undefined): string =>
    typeof n === "number" ? n.toLocaleString() : "—";

  return (
    <div className="space-y-8">
      <div className="space-y-3">
        <PageHeader
          title="NPL MCP Companion"
          description="Build structured prompts with the NoizuPromptLingo (NPL) syntax system. Catalog tools, compose instructions, version docs, collaborate with your team."
        />
        <p className="text-sm text-muted max-w-2xl">
          New here? <Link href="/style-guide" className="text-accent hover:text-accent-soft">View the style guide</Link> to learn NPL syntax and explore the UI.
        </p>
      </div>

      <section className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <StatTile
          label="Catalog tools"
          value={fmt(tools?.length)}
          href="/tools"
          icon={<WrenchScrewdriverIcon className="h-4 w-4" />}
          delta={{ value: `${mcpCount} categorized`, trend: "flat" }}
        />
        <StatTile
          label="Sessions"
          value={fmt(sessions?.length)}
          href="/sessions"
          icon={<ClockIcon className="h-4 w-4" />}
          delta={{ value: "Last 24h (mock)", trend: "flat" }}
        />
        <StatTile
          label="Instructions"
          value={fmt(instructions?.length)}
          href="/instructions"
          icon={<BookOpenIcon className="h-4 w-4" />}
          delta={{ value: "Versioned docs", trend: "flat" }}
        />
        <StatTile
          label="Projects"
          value={fmt(projects?.length)}
          href="/projects"
          icon={<FolderIcon className="h-4 w-4" />}
          delta={{ value: "Personas + stories", trend: "flat" }}
        />
      </section>

      <section className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <StatTile
          label="Tasks"
          value="—"
          href="/tasks"
          icon={<ClipboardDocumentListIcon className="h-4 w-4" />}
          delta={{ value: "Browse queue", trend: "flat" }}
        />
        <StatTile
          label="Sessions"
          value={fmt(sessions?.length)}
          href="/sessions"
          icon={<ClockIcon className="h-4 w-4" />}
          delta={{ value: "Recent", trend: "flat" }}
        />
        <StatTile
          label="Artifacts"
          value="—"
          href="/artifacts"
          icon={<ArchiveBoxIcon className="h-4 w-4" />}
          delta={{ value: "Versioned outputs", trend: "flat" }}
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
