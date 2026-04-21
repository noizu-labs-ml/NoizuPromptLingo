"use client";

import useSWR from "swr";
import clsx from "clsx";
import {
  HeartIcon,
  ServerStackIcon,
  CircleStackIcon,
  CpuChipIcon,
  Squares2X2Icon,
  BuildingLibraryIcon,
  CheckCircleIcon,
  XCircleIcon,
  ExclamationTriangleIcon,
  MinusCircleIcon,
} from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import type { HealthReport, SubsystemHealth } from "@/lib/api/types";
import { Card } from "@/components/primitives/Card";
import { PageHeader } from "@/components/primitives/PageHeader";
import { Badge } from "@/components/primitives/Badge";
import type { BadgeProps } from "@/components/primitives/Badge";

function statusBadgeVariant(status: SubsystemHealth["status"]): BadgeProps["variant"] {
  switch (status) {
    case "ok":             return "success";
    case "unavailable":    return "danger";
    case "missing":        return "warning";
    case "not_configured": return "default";
    default:               return "default";
  }
}

function StatusIcon({ status }: { status: SubsystemHealth["status"] }) {
  const cls = "h-5 w-5 shrink-0";
  switch (status) {
    case "ok":             return <CheckCircleIcon className={clsx(cls, "text-success")} />;
    case "unavailable":    return <XCircleIcon className={clsx(cls, "text-danger")} />;
    case "missing":        return <ExclamationTriangleIcon className={clsx(cls, "text-warning")} />;
    case "not_configured": return <MinusCircleIcon className={clsx(cls, "text-muted")} />;
    default:               return <MinusCircleIcon className={clsx(cls, "text-muted")} />;
  }
}

function formatUptime(seconds: number): string {
  if (seconds < 0) return "—";
  const s = Math.floor(seconds);
  const d = Math.floor(s / 86400);
  const h = Math.floor((s % 86400) / 3600);
  const m = Math.floor((s % 3600) / 60);
  const rest = s % 60;
  if (d > 0) return `${d}d ${h}h ${m}m`;
  if (h > 0) return `${h}h ${m}m`;
  if (m > 0) return `${m}m ${rest}s`;
  return `${rest}s`;
}

interface FieldRow {
  label: string;
  value: React.ReactNode;
}

function SubsystemCard({
  icon,
  title,
  subsystem,
  rows,
}: {
  icon: React.ReactNode;
  title: string;
  subsystem: SubsystemHealth;
  rows: FieldRow[];
}) {
  return (
    <Card className="flex flex-col gap-3">
      <div className="flex items-start justify-between gap-2">
        <div className="flex items-center gap-2 min-w-0">
          <div className="text-muted [&>svg]:h-5 [&>svg]:w-5 shrink-0">{icon}</div>
          <h3 className="text-sm font-semibold text-foreground truncate">{title}</h3>
        </div>
        <div className="flex items-center gap-1.5 shrink-0">
          <StatusIcon status={subsystem.status} />
          <Badge variant={statusBadgeVariant(subsystem.status)}>{subsystem.status}</Badge>
        </div>
      </div>

      {subsystem.message && (
        <p className="text-xs text-muted break-words">{subsystem.message}</p>
      )}

      <dl className="grid grid-cols-2 gap-x-3 gap-y-1.5 text-xs">
        {rows.map((row) => (
          <div key={row.label} className="contents">
            <dt className="text-subtle uppercase tracking-wide text-[10px] font-semibold self-center">
              {row.label}
            </dt>
            <dd className="text-foreground font-mono truncate">{row.value}</dd>
          </div>
        ))}
      </dl>
    </Card>
  );
}

export default function HealthPage() {
  const { data, error, isLoading, mutate } = useSWR<HealthReport>(
    "health.check",
    () => api.health.check(),
    { refreshInterval: 5000, revalidateOnFocus: true },
  );

  const pingSwr = useSWR(
    "health.ping",
    () => api.health.ping(),
    { refreshInterval: 5000 },
  );

  const overall: "ok" | "degraded" | "down" = (() => {
    if (!data) return "down";
    const statuses = [
      data.server.status,
      data.database.status,
      data.litellm.status,
      data.catalog.status,
      data.frontend_build.status,
    ];
    if (statuses.every((s) => s === "ok" || s === "not_configured")) return "ok";
    if (statuses.some((s) => s === "unavailable")) return "down";
    return "degraded";
  })();

  const overallClass =
    overall === "ok" ? "text-success"
    : overall === "degraded" ? "text-warning"
    : "text-danger";
  const overallLabel =
    overall === "ok" ? "Healthy"
    : overall === "degraded" ? "Degraded"
    : "Unavailable";

  return (
    <div className="space-y-8">
      <PageHeader
        title="System Health"
        description="Live status of server, database, LLM proxy, catalog, and frontend build. Polls every 5s."
        actions={
          <div className="flex items-center gap-3">
            <div className="flex items-center gap-1.5 text-xs">
              <HeartIcon className={clsx("h-4 w-4", overallClass)} />
              <span className={clsx("font-semibold", overallClass)}>{overallLabel}</span>
            </div>
            <button
              onClick={() => mutate()}
              className="text-xs rounded-md border border-border px-3 py-1.5 text-muted hover:text-foreground hover:bg-surface-raised transition-colors"
            >
              Refresh now
            </button>
          </div>
        }
      />

      {error && (
        <div className="rounded-md border border-danger/30 bg-danger/10 px-4 py-3 text-sm text-danger">
          Failed to fetch health report: {String(error)}
        </div>
      )}

      {isLoading && !data && (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {[1, 2, 3, 4, 5].map((i) => (
            <Card key={i} className="animate-pulse">
              <div className="h-4 bg-surface-sunken rounded w-1/2 mb-3" />
              <div className="h-3 bg-surface-sunken rounded w-full mb-1.5" />
              <div className="h-3 bg-surface-sunken rounded w-3/4" />
            </Card>
          ))}
        </div>
      )}

      {data && (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <SubsystemCard
            icon={<ServerStackIcon />}
            title="Server"
            subsystem={data.server}
            rows={[
              { label: "Uptime",  value: formatUptime(data.server.uptime_seconds) },
              { label: "FastMCP", value: data.server.fastmcp_version },
              {
                label: "Ping",
                value: pingSwr.data
                  ? <span className="text-success">ok</span>
                  : pingSwr.error
                  ? <span className="text-danger">error</span>
                  : <span className="text-muted">…</span>,
              },
            ]}
          />

          <SubsystemCard
            icon={<CircleStackIcon />}
            title="Database"
            subsystem={data.database}
            rows={[
              {
                label: "Latency",
                value: typeof data.database.latency_ms === "number"
                  ? `${data.database.latency_ms} ms`
                  : "—",
              },
            ]}
          />

          <SubsystemCard
            icon={<CpuChipIcon />}
            title="LiteLLM"
            subsystem={data.litellm}
            rows={[
              { label: "URL", value: data.litellm.url ?? "—" },
              {
                label: "Latency",
                value: typeof data.litellm.latency_ms === "number"
                  ? `${data.litellm.latency_ms} ms`
                  : "—",
              },
            ]}
          />

          <SubsystemCard
            icon={<Squares2X2Icon />}
            title="Catalog"
            subsystem={data.catalog}
            rows={[
              { label: "Total",   value: data.catalog.tool_count.toLocaleString() },
              { label: "MCP",     value: data.catalog.mcp_tools.toLocaleString() },
              { label: "Hidden",  value: data.catalog.hidden_tools.toLocaleString() },
              { label: "Stubs",   value: data.catalog.stub_tools.toLocaleString() },
            ]}
          />

          <SubsystemCard
            icon={<BuildingLibraryIcon />}
            title="Frontend Build"
            subsystem={data.frontend_build}
            rows={[
              { label: "Path", value: <span className="break-all">{data.frontend_build.dist_path}</span> },
            ]}
          />
        </div>
      )}
    </div>
  );
}
