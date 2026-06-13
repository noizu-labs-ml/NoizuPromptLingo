"use client";

import { use, useEffect, useState } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { api, type Rubric } from "@/lib/api";
import { cyAttrs } from "@/utils/cypress";
import {
  PageHeader,
  Button,
  Card,
  EmptyState,
  LoadingSkeleton,
} from "@/components/ui";

export default function RubricsPage({
  params,
}: {
  params: Promise<{ orgId: string }>;
}) {
  const { orgId } = use(params);
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();

  const [rubrics, setRubrics] = useState<Rubric[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login");
      return;
    }
    if (!user) return;

    api
      .listRubrics(orgId)
      .then((res) => setRubrics(res.rubrics))
      .catch((err) => setError(err instanceof Error ? err.message : "failed to load"))
      .finally(() => setLoading(false));
  }, [user, authLoading, router, orgId]);

  if (authLoading) {
    return (
      <div data-cy="app-loading" className="sg-app-loading">
        Loading…
      </div>
    );
  }

  return (
    <div data-cy="rubrics-page" {...cyAttrs({ cyScope: "rubrics" })}>
      <PageHeader
        title="Rubrics"
        subtitle="LLM-as-judge scoring: weighted criteria, ladder/enum scales, n-sample confidence bands."
        actions={
          <>
            <Link
              href={`/app/${orgId}/rubrics/marketplace`}
              className="sg-btn sg-btn--ghost"
              data-cy="rubrics-marketplace-link"
            >
              Browse marketplace
            </Link>
            <Button
              variant="primary"
              cy="rubrics-create"
              href={`/app/${orgId}/rubrics/new`}
            >
              + New Rubric
            </Button>
          </>
        }
      />

      {error && (
        <p className="sg-error" data-cy="rubrics-error">
          {error}
        </p>
      )}

      {loading ? (
        <LoadingSkeleton variant="card" count={4} />
      ) : rubrics.length === 0 ? (
        <EmptyState
          glyph="rubrics"
          headline="No rubrics yet"
          body="Create your first rubric to score agent responses with weighted criteria."
          primaryAction={
            <Button
              variant="primary"
              cy="rubrics-empty-create"
              href={`/app/${orgId}/rubrics/new`}
            >
              + Create Rubric
            </Button>
          }
          secondaryAction={
            <Button
              variant="ghost"
              cy="rubrics-empty-marketplace"
              href={`/app/${orgId}/rubrics/marketplace`}
            >
              Browse marketplace
            </Button>
          }
        />
      ) : (
        <div
          data-cy="rubrics-list"
          {...cyAttrs({ cyId: "rubrics" })}
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))",
            gap: "1rem",
          }}
        >
          {rubrics.map((rubric) => (
            <Card
              key={rubric.id}
              interactive
              cy="rubric-row"
              cyId={rubric.slug}
              onClick={() => router.push(`/app/${orgId}/rubrics/${rubric.id}`)}
            >
              <div
                style={{
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "baseline",
                  gap: "0.5rem",
                  marginBottom: "0.5rem",
                }}
              >
                <Link
                  href={`/app/${orgId}/rubrics/${rubric.id}`}
                  data-cy="rubric-detail-link"
                  onClick={(e) => e.stopPropagation()}
                  style={{ textDecoration: "none", color: "inherit" }}
                >
                  <strong data-cy="rubric-name" style={{ fontSize: "1.05rem" }}>
                    {rubric.name}
                  </strong>
                </Link>
                {rubric.current_version_id && (
                  <span
                    className="sg-pill sg-pill--sm eval-pass"
                    data-cy="rubric-version-badge"
                  >
                    published
                  </span>
                )}
              </div>
              <div
                data-cy="rubric-slug"
                {...cyAttrs({ cyValue: rubric.slug })}
                style={{
                  fontSize: "0.8rem",
                  color: "var(--text-tertiary)",
                  fontFamily: "var(--font-mono, monospace)",
                  marginBottom: "0.5rem",
                }}
              >
                {rubric.slug}
              </div>
              {rubric.description && (
                <p
                  data-cy="rubric-description"
                  style={{
                    margin: 0,
                    fontSize: "0.875rem",
                    color: "var(--text-secondary)",
                    lineHeight: 1.5,
                  }}
                >
                  {rubric.description}
                </p>
              )}
              <div style={{ marginTop: "0.75rem", display: "flex", justifyContent: "flex-end" }}>
                <Button
                  variant="ghost"
                  size="sm"
                  cy="rubric-edit-link"
                  cyId={rubric.slug}
                  href={`/app/${orgId}/rubrics/${rubric.id}`}
                  onClick={(e) => e.stopPropagation()}
                >
                  Edit
                </Button>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
