"use client";

import { use, useEffect, useState } from "react";
import Link from "next/link";
import { api, type Script, type Agent, type Run } from "@/lib/api";
import { PageHeader, Card, LoadingSkeleton } from "@/components/ui";
import { cyAttrs } from "@/utils/cypress";

// ─── Section cards (existing) ────────────────────────────────────────────────
const SECTIONS = [
  {
    slug: "prompts",
    label: "Prompts",
    desc: "Reusable prompt templates with variables and tool definitions.",
    stages: "Stage 1",
  },
  {
    slug: "rubrics",
    label: "Rubrics",
    desc: "LLM-as-judge scoring: weighted criteria, ladder/enum scales, n-sample confidence bands.",
    stages: "Stage 2a",
  },
  {
    slug: "personas",
    label: "Personas",
    desc: "User-voice personas with tone tags. Import from starter library (hostile, broken-english, etc.).",
    stages: "Stage 2b",
  },
  {
    slug: "scripts",
    label: "Scripts",
    desc: "Conversation graphs with nodes, edges, expectations. Publish immutable versions. YAML round-trip.",
    stages: "Stage 3",
  },
  {
    slug: "agents",
    label: "Agents",
    desc: "Adapter configs for OpenAI, Anthropic, LangChain, HTTP, Bedrock, Vertex. Health checks + cost gov.",
    stages: "Stage 4",
  },
  {
    slug: "runs",
    label: "Runs",
    desc: "Trigger runs, watch live status, see per-step scores, verdicts, freeball chains.",
    stages: "Stage 5 + 6",
  },
];

// ─── Metric tile helpers ──────────────────────────────────────────────────────
interface MetricTileProps {
  label: string;
  value: React.ReactNode;
  loading?: boolean;
  cy?: string;
}

function MetricTile({ label, value, loading, cy }: MetricTileProps) {
  return (
    <Card {...cyAttrs({ cy: cy ?? "metric-tile" })} style={{ padding: "1.25rem" }}>
      <div
        style={{
          fontSize: 11,
          fontWeight: 600,
          letterSpacing: "0.06em",
          textTransform: "uppercase",
          color: "var(--text-secondary)",
          marginBottom: "0.5rem",
          fontFamily: "var(--font-mono, monospace)",
        }}
      >
        {label}
      </div>
      {loading ? (
        <LoadingSkeleton variant="text" height={36} />
      ) : (
        <div
          style={{
            fontSize: "clamp(28px, 4vw, 40px)",
            fontWeight: 700,
            lineHeight: 1,
            color: "var(--text-primary)",
            letterSpacing: "-0.02em",
          }}
        >
          {value}
        </div>
      )}
    </Card>
  );
}

// ─── Pass-rate color helper ───────────────────────────────────────────────────
function passRateColor(rate: number | null): string {
  if (rate === null) return "var(--text-tertiary)";
  if (rate >= 0.8) return "var(--eval-pass)";
  if (rate >= 0.5) return "var(--eval-warn)";
  return "var(--eval-fail)";
}

// ─── Dashboard page ───────────────────────────────────────────────────────────
export default function OrgDashboard({
  params,
}: {
  params: Promise<{ orgId: string }>;
}) {
  const { orgId } = use(params);

  // Metric state
  const [scripts, setScripts] = useState<Script[] | null>(null);
  const [agents, setAgents] = useState<Agent[] | null>(null);
  const [runs7d, setRuns7d] = useState<Run[] | null>(null);
  const [metricsLoading, setMetricsLoading] = useState(true);

  useEffect(() => {
    const dateFrom = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
      .toISOString()
      .split("T")[0];

    const p1 = api.listScripts(orgId).then((r) => setScripts(r.scripts)).catch(() => setScripts([]));
    const p2 = api.listAgents(orgId).then((r) => setAgents(r.agents)).catch(() => setAgents([]));
    const p3 = api
      .listRuns(orgId, { date_from: dateFrom })
      .then((r) => setRuns7d(r.runs))
      .catch(() => setRuns7d([]));

    Promise.allSettled([p1, p2, p3]).finally(() => setMetricsLoading(false));
  }, [orgId]);

  // Derived metrics
  const scriptCount = scripts?.length ?? null;
  const agentCount = agents?.length ?? null;
  const runsCount = runs7d?.length ?? null;

  const passRate: number | null =
    runs7d && runs7d.length > 0
      ? runs7d.filter((r) => r.verdict === "pass").length / runs7d.length
      : runs7d !== null
      ? null
      : null;

  const passRateDisplay =
    passRate !== null ? `${Math.round(passRate * 100)}%` : "—";

  const dashCy = cyAttrs({ cyScope: "dashboard", cyId: orgId });

  return (
    <div data-cy="org-dashboard" {...dashCy}>
      {/* Page header */}
      <PageHeader
        title="Workspace"
        subtitle="Pick an area to get started. Every section is backed by a live API — the CLI (codefresh) and Python/TypeScript/Elixir SDKs hit the same endpoints."
        cy="dashboard-header"
      />

      {/* Metric tiles row */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(4, 1fr)",
          gap: "1rem",
          marginTop: "1.5rem",
          marginBottom: "2rem",
        }}
        data-cy="dashboard-metrics"
      >
        <MetricTile
          label="Scripts"
          value={scriptCount !== null ? scriptCount : "—"}
          loading={metricsLoading}
          cy="metric-scripts"
        />
        <MetricTile
          label="Agents"
          value={agentCount !== null ? agentCount : "—"}
          loading={metricsLoading}
          cy="metric-agents"
        />
        <MetricTile
          label="Runs (7d)"
          value={runsCount !== null ? runsCount : "—"}
          loading={metricsLoading}
          cy="metric-runs"
        />
        <MetricTile
          label="Pass rate (7d)"
          loading={metricsLoading}
          cy="metric-pass-rate"
          value={
            <span style={{ color: passRateColor(passRate) }}>
              {passRateDisplay}
            </span>
          }
        />
      </div>

      {/* Section cards grid */}
      <section
        data-cy="dashboard-grid"
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))",
          gap: "1rem",
        }}
      >
        {SECTIONS.map((s) => (
          <Link
            key={s.slug}
            href={`/app/${orgId}/${s.slug}`}
            data-cy="dashboard-card"
            {...cyAttrs({ cyId: s.slug })}
            style={{ textDecoration: "none", color: "inherit", display: "block" }}
          >
            <Card interactive style={{ height: "100%" }}>
              <div
                style={{
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "baseline",
                  marginBottom: "0.5rem",
                }}
              >
                <strong
                  data-cy="dashboard-card-title"
                  style={{ fontSize: "1.05rem" }}
                >
                  {s.label}
                </strong>
                <span
                  data-cy="dashboard-card-stage"
                  style={{
                    fontSize: "0.75rem",
                    color: "var(--text-tertiary)",
                    fontFamily: "var(--font-mono, monospace)",
                  }}
                >
                  {s.stages}
                </span>
              </div>
              <p
                data-cy="dashboard-card-desc"
                style={{
                  fontSize: "0.875rem",
                  color: "var(--text-secondary)",
                  margin: 0,
                  lineHeight: 1.5,
                }}
              >
                {s.desc}
              </p>
            </Card>
          </Link>
        ))}
      </section>

      {/* Legacy data-cy anchor for the dashboard title — kept for Cypress compat */}
      <span data-cy="dashboard-title" style={{ display: "none" }}>
        Workspace
      </span>
    </div>
  );
}
