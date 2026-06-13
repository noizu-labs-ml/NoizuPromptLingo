"use client";

import { use, useEffect, useState } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { api, type Persona, type Run } from "@/lib/api";
import { cyAttrs } from "@/utils/cypress";
import {
  Button,
  EmptyState,
  LoadingSkeleton,
  PageHeader,
  StatusPill,
  toast,
} from "@/components/ui";

type Verdict = "pass" | "warn" | "fail";

function VerdictCell({ verdict }: { verdict?: Verdict | null }) {
  if (!verdict) {
    return (
      <td
        className="sg-heatmap-cell"
        title="no run"
      />
    );
  }
  return (
    <td
      className="sg-heatmap-cell"
      data-cy="heatmap-cell"
      data-verdict={verdict}
      {...cyAttrs({ cyValue: verdict })}
      title={verdict}
    />
  );
}

export default function PersonaHeatmapPage({
  params,
}: {
  params: Promise<{ orgId: string }>;
}) {
  const { orgId } = use(params);
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();

  const [personas, setPersonas] = useState<Persona[]>([]);
  const [runsByPersona, setRunsByPersona] = useState<Record<string, Run[]>>({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [limit] = useState(20);

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login");
      return;
    }
    if (!user) return;

    api
      .listPersonas(orgId)
      .then(async (res) => {
        setPersonas(res.personas);
        if (res.personas.length === 0) return;

        const runsResults = await Promise.allSettled(
          res.personas.map((p) =>
            api
              .listRuns(orgId, { persona_id: p.id, page: 1 })
              .then((r) => r.runs.slice(0, limit)),
          ),
        );

        const map: Record<string, Run[]> = {};
        res.personas.forEach((p, i) => {
          const result = runsResults[i];
          map[p.id] = result.status === "fulfilled" ? result.value : [];
        });
        setRunsByPersona(map);
      })
      .catch((err) => {
        const msg = err instanceof Error ? err.message : "failed to load";
        setError(msg);
        toast.error(msg);
      })
      .finally(() => setLoading(false));
  }, [user, authLoading, router, orgId, limit]);

  if (authLoading || loading) {
    return (
      <div data-cy="app-loading" style={{ padding: "3rem 1rem" }}>
        <LoadingSkeleton variant="row" count={6} />
      </div>
    );
  }

  const maxRuns = Math.max(...personas.map((p) => (runsByPersona[p.id] ?? []).length), 0);
  const colIndices = Array.from({ length: maxRuns }, (_, i) => i);

  return (
    <div data-cy="persona-heatmap-page" {...cyAttrs({ cyScope: "persona-heatmap" })}>
      <PageHeader
        title="Persona Heatmap"
        subtitle="Verdict per persona per recent run."
        breadcrumbs={[
          { label: "library", href: `/app/${orgId}` },
          { label: "personas", href: `/app/${orgId}/personas` },
          { label: "heatmap", current: true },
        ]}
        actions={
          <Button
            variant="ghost"
            href={`/app/${orgId}/personas`}
            cy="heatmap-back-link"
          >
            All Personas
          </Button>
        }
      />

      {error && (
        <p className="sg-field-error" data-cy="heatmap-error">
          {error}
        </p>
      )}

      {/* Legend */}
      <div
        data-cy="heatmap-legend"
        style={{
          display: "flex",
          gap: "var(--space-3)",
          marginBottom: "var(--space-4)",
          alignItems: "center",
          flexWrap: "wrap",
        }}
      >
        <StatusPill state="pass" size="sm" />
        <StatusPill state="warn" size="sm" />
        <StatusPill state="fail" size="sm" />
        <span
          style={{
            display: "inline-flex",
            alignItems: "center",
            gap: "var(--space-2)",
            fontSize: "var(--text-small)",
            color: "var(--text-secondary)",
          }}
        >
          <span className="sg-heatmap-cell" style={{ width: 14, height: 14 }} />
          no run
        </span>
      </div>

      {personas.length === 0 && (
        <EmptyState
          glyph="personas"
          cy="heatmap-empty"
          headline="No personas yet"
          body="Create your first persona to seed the heatmap."
          primaryAction={
            <Button variant="primary" href={`/app/${orgId}/personas/new`}>
              Create first persona
            </Button>
          }
        />
      )}

      {personas.length > 0 && maxRuns === 0 && (
        <EmptyState
          glyph="runs"
          cy="heatmap-no-runs"
          headline="No runs with personas yet"
          body="Trigger a run with a persona attached to populate the heatmap."
          primaryAction={
            <Button variant="primary" href={`/app/${orgId}/runs`}>
              Runs
            </Button>
          }
        />
      )}

      {personas.length > 0 && maxRuns > 0 && (
        <div style={{ overflowX: "auto" }}>
          <table
            data-cy="heatmap-table"
            style={{ borderCollapse: "collapse", tableLayout: "fixed" }}
          >
            <thead>
              <tr>
                <th
                  style={{
                    textAlign: "left",
                    padding: "var(--space-1) var(--space-2)",
                    fontSize: "var(--text-small)",
                    color: "var(--text-tertiary)",
                    width: 180,
                    whiteSpace: "nowrap",
                  }}
                >
                  Persona
                </th>
                {colIndices.map((i) => (
                  <th
                    key={i}
                    data-cy="heatmap-col-header"
                    style={{
                      width: 26,
                      fontSize: "var(--text-caption)",
                      color: "var(--text-tertiary)",
                      textAlign: "center",
                      padding: 2,
                    }}
                  >
                    {i + 1}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {personas.map((persona) => {
                const runs = runsByPersona[persona.id] ?? [];
                return (
                  <tr key={persona.id} data-cy="heatmap-row" {...cyAttrs({ cyId: persona.slug })}>
                    <td
                      style={{
                        padding: "var(--space-1) var(--space-2)",
                        fontSize: "var(--text-body)",
                        whiteSpace: "nowrap",
                        overflow: "hidden",
                        textOverflow: "ellipsis",
                        maxWidth: 180,
                      }}
                    >
                      <Link
                        href={`/app/${orgId}/personas/${persona.id}`}
                        data-cy="heatmap-persona-link"
                        {...cyAttrs({ cyId: persona.slug })}
                        style={{ color: "inherit", textDecoration: "none" }}
                      >
                        {persona.name}
                      </Link>
                    </td>
                    {colIndices.map((i) => (
                      <VerdictCell
                        key={i}
                        verdict={(runs[i]?.verdict as Verdict | null | undefined) ?? null}
                      />
                    ))}
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
