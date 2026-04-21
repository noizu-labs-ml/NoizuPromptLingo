"use client";

import useSWR from "swr";
import { api } from "@/lib/api/client";
import type { ToolCall, LLMCall, ToolError, NPLSectionCoverage } from "@/lib/api/types";
import { Card } from "@/components/primitives/Card";
import { Badge } from "@/components/primitives/Badge";
import { PageHeader } from "@/components/primitives/PageHeader";
import { DataTable } from "@/components/primitives/DataTable";

import { relativeTime, formatNumber, truncate } from "@/lib/utils/format";

// ── Response time bucket bar chart ────────────────────────────────────────

const BUCKETS = [
  { label: "0–100ms", max: 100 },
  { label: "100–500ms", max: 500 },
  { label: "500–1000ms", max: 1000 },
  { label: "1–2s", max: 2000 },
  { label: "2s+", max: Infinity },
];

function ResponseTimeChart({ calls }: { calls: ToolCall[] }) {
  const counts = BUCKETS.map(({ max }, i) => {
    const min = i === 0 ? 0 : BUCKETS[i - 1].max;
    return calls.filter((c) => c.response_time_ms > min && c.response_time_ms <= max).length;
  });
  const maxCount = Math.max(...counts, 1);

  return (
    <div className="flex flex-col gap-2 pt-2">
      {BUCKETS.map((bucket, i) => (
        <div key={bucket.label} className="flex items-center gap-3">
          <span className="text-xs text-muted w-20 shrink-0 text-right">{bucket.label}</span>
          <div className="flex-1 bg-surface rounded h-5 overflow-hidden">
            <div
              className="h-full bg-brand-500 rounded transition-all"
              style={{ width: `${(counts[i] / maxCount) * 100}%` }}
            />
          </div>
          <span className="text-xs text-muted w-6 text-right">{counts[i]}</span>
        </div>
      ))}
    </div>
  );
}

// ── NPL Coverage card ─────────────────────────────────────────────────────

function NPLCoverageCard() {
  const { data: coverage, isLoading } = useSWR(
    "npl.coverage",
    () => api.npl.coverage()
  );

  if (isLoading) {
    return (
      <Card>
        <h2 className="text-base font-semibold text-foreground mb-4">NPL Coverage</h2>
        <div className="h-48 rounded bg-surface animate-pulse" />
      </Card>
    );
  }

  if (!coverage) {
    return (
      <Card>
        <h2 className="text-base font-semibold text-foreground mb-4">NPL Coverage</h2>
        <p className="text-sm text-muted">No data available.</p>
      </Card>
    );
  }

  return (
    <Card>
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-base font-semibold text-foreground">NPL Coverage</h2>
        <span className="text-3xl font-bold text-brand-500">{formatNumber(coverage.coverage_percent)}%</span>
      </div>

      {/* Overall progress bar */}
      <div className="mb-1 text-xs text-muted">
        {formatNumber(coverage.complete_components)} / {formatNumber(coverage.total_components)} components complete
        ({formatNumber(coverage.total_sections)} sections)
      </div>
      <div className="w-full bg-surface rounded h-2 overflow-hidden mb-6">
        <div
          className="h-full bg-brand-500 rounded transition-all"
          style={{ width: `${coverage.coverage_percent}%` }}
        />
      </div>

      {/* Per-section breakdown */}
      <div className="flex flex-col gap-3">
        {coverage.by_section.map((sec: NPLSectionCoverage) => (
          <div key={sec.section}>
            <div className="flex items-center justify-between mb-1">
              <span className="text-sm font-medium text-foreground capitalize">{sec.section}</span>
              <span className="text-xs text-muted">{formatNumber(sec.complete)}/{formatNumber(sec.total)}</span>
            </div>
            <div className="w-full bg-surface rounded h-1.5 overflow-hidden mb-1">
              <div
                className="h-full bg-brand-500 rounded transition-all"
                style={{ width: `${sec.coverage_percent}%` }}
              />
            </div>
            {sec.missing.length > 0 && (
              <div className="flex flex-wrap gap-1 mt-1">
                {sec.missing.slice(0, 3).map((name) => (
                  <Badge key={name} variant="warning" size="sm">
                    {name}
                  </Badge>
                ))}
                {sec.missing.length > 3 && (
                  <span className="text-xs text-muted self-center">+{sec.missing.length - 3} more</span>
                )}
              </div>
            )}
          </div>
        ))}
      </div>
    </Card>
  );
}

// ── Page ──────────────────────────────────────────────────────────────────

export default function MetricsPage() {
  const { data: toolCalls, isLoading: tcLoading } = useSWR(
    "metrics.toolCalls",
    () => api.metrics.recentToolCalls(20)
  );

  const { data: llmCalls, isLoading: llmLoading } = useSWR(
    "metrics.llmCalls",
    () => api.metrics.recentLLMCalls(20)
  );

  const { data: toolErrors, isLoading: errLoading } = useSWR(
    "metrics.errors",
    () => api.metrics.recentErrors(50)
  );

  const tcColumns = [
    {
      key: "tool_name",
      header: "Tool",
      render: (row: ToolCall) => (
        <span className="font-mono text-sm text-foreground">{row.tool_name}</span>
      ),
    },
    {
      key: "status",
      header: "Status",
      render: (row: ToolCall) => (
        <Badge variant={row.status === "ok" ? "success" : "danger"} size="sm">
          {row.status}
        </Badge>
      ),
    },
    {
      key: "response_time_ms",
      header: "Time (ms)",
      className: "text-right",
      render: (row: ToolCall) => (
        <span className="text-right block text-muted text-sm">{row.response_time_ms}</span>
      ),
    },
    {
      key: "created_at",
      header: "When",
      render: (row: ToolCall) => (
        <span className="text-muted text-sm">{relativeTime(row.created_at)}</span>
      ),
    },
  ];

  const llmColumns = [
    {
      key: "model",
      header: "Model",
      render: (row: LLMCall) => (
        <span className="font-mono text-xs text-foreground">{row.model}</span>
      ),
    },
    {
      key: "purpose",
      header: "Purpose",
      render: (row: LLMCall) => (
        <span className="text-sm text-muted">{row.purpose}</span>
      ),
    },
    {
      key: "tokens_in",
      header: "Tokens In",
      render: (row: LLMCall) => (
        <span className="text-sm text-muted">{formatNumber(row.tokens_in)}</span>
      ),
    },
    {
      key: "tokens_out",
      header: "Tokens Out",
      render: (row: LLMCall) => (
        <span className="text-sm text-muted">{formatNumber(row.tokens_out)}</span>
      ),
    },
    {
      key: "duration_ms",
      header: "Duration",
      render: (row: LLMCall) => (
        <span className="text-sm text-muted">{formatNumber(row.duration_ms)}ms</span>
      ),
    },
    {
      key: "created_at",
      header: "When",
      render: (row: LLMCall) => (
        <span className="text-muted text-sm">{relativeTime(row.created_at)}</span>
      ),
    },
  ];

  const errorColumns = [
    {
      key: "tool_name",
      header: "Tool",
      render: (row: ToolError) => (
        <span className="font-mono text-sm text-foreground">{row.tool_name}</span>
      ),
    },
    {
      key: "error_type",
      header: "Type",
      render: (row: ToolError) => (
        <Badge variant="danger" size="sm">
          {row.error_type}
        </Badge>
      ),
    },
    {
      key: "error_message",
      header: "Message",
      render: (row: ToolError) => (
        <span className="text-sm text-muted" title={row.error_message}>
          {truncate(row.error_message, 80)}
        </span>
      ),
    },
    {
      key: "session_id",
      header: "Session",
      render: (row: ToolError) =>
        row.session_id ? (
          <a
            href={`/sessions/${row.session_id}`}
            className="font-mono text-xs text-brand-500 hover:underline"
          >
            {row.session_id}
          </a>
        ) : (
          <span className="text-xs text-muted">—</span>
        ),
    },
    {
      key: "created_at",
      header: "When",
      render: (row: ToolError) => (
        <span className="text-muted text-sm">{relativeTime(row.created_at)}</span>
      ),
    },
  ];

  return (
    <div className="flex flex-col gap-6">
      <PageHeader
        title="Metrics"
        description="Tool call history and LLM usage."
      />

      {/* Banner */}
      <div className="rounded-md border border-warning/30 bg-warning/10 px-4 py-3 text-sm text-warning">
        <strong>Preview only — tool call history and LLM usage still use mock data. Tool errors are live.</strong>
      </div>

      {/* Two-column data tables */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Tool Call History */}
        <Card>
          <h2 className="text-base font-semibold text-foreground mb-4">Tool Call History</h2>
          {tcLoading ? (
            <div className="h-48 rounded bg-surface animate-pulse" />
          ) : (
            <DataTable<ToolCall>
              columns={tcColumns}
              rows={toolCalls ?? []}
              rowKey={(row) => row.id}
              emptyMessage="No tool calls recorded."
            />
          )}
        </Card>

        {/* LLM Usage */}
        <Card>
          <h2 className="text-base font-semibold text-foreground mb-4">LLM Usage</h2>
          {llmLoading ? (
            <div className="h-48 rounded bg-surface animate-pulse" />
          ) : (
            <DataTable<LLMCall>
              columns={llmColumns}
              rows={llmCalls ?? []}
              rowKey={(row) => row.id}
              emptyMessage="No LLM calls recorded."
            />
          )}
        </Card>
      </div>

      {/* Response Time Distribution */}
      <Card>
        <h2 className="text-base font-semibold text-foreground mb-2">Response Time Distribution</h2>
        <p className="text-xs text-muted mb-4">Tool calls bucketed by response latency.</p>
        {tcLoading ? (
          <div className="h-32 rounded bg-surface animate-pulse" />
        ) : (
          <ResponseTimeChart calls={toolCalls ?? []} />
        )}
      </Card>

      {/* Tool Errors */}
      <Card>
        <h2 className="text-base font-semibold text-foreground mb-4">Tool Errors</h2>
        {errLoading ? (
          <div className="h-48 rounded bg-surface animate-pulse" />
        ) : (
          <DataTable<ToolError>
            columns={errorColumns}
            rows={toolErrors ?? []}
            rowKey={(row) => String(row.id)}
            emptyMessage="No errors recorded."
          />
        )}
      </Card>

      {/* NPL Coverage */}
      <NPLCoverageCard />
    </div>
  );
}
