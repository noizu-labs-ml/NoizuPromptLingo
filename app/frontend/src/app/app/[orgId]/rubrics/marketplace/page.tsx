"use client";

import { use, useEffect, useState } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import { api, type MarketplaceEntry, type MarketplaceRubricVersion } from "@/lib/api";
import { cyAttrs } from "@/utils/cypress";
import {
  Button,
  Card,
  EmptyState,
  LoadingSkeleton,
  PageHeader,
  ScoreBadge,
  Select,
  TextInput,
  toast,
} from "@/components/ui";

const DOMAINS = ["all", "safety", "RAG", "code-gen"] as const;
type Domain = (typeof DOMAINS)[number];

interface MarketplaceItem {
  entry: MarketplaceEntry;
  rubric_version: MarketplaceRubricVersion;
}

export default function RubricsMarketplacePage({
  params,
}: {
  params: Promise<{ orgId: string }>;
}) {
  const { orgId } = use(params);
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();

  const [items, setItems] = useState<MarketplaceItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [domain, setDomain] = useState<Domain>("all");
  const [search, setSearch] = useState("");
  const [importing, setImporting] = useState<string | null>(null);

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login");
      return;
    }
    if (!user) return;

    setLoading(true);
    api
      .listMarketplaceRubrics(domain === "all" ? undefined : domain)
      .then((res) => setItems(res.entries as MarketplaceItem[]))
      .catch((err) =>
        toast.error(err instanceof Error ? err.message : "Failed to load marketplace"),
      )
      .finally(() => setLoading(false));
  }, [user, authLoading, router, domain]);

  const filtered = search.trim()
    ? items.filter((i) => {
        const q = search.trim().toLowerCase();
        return (
          i.entry.title.toLowerCase().includes(q) ||
          (i.entry.description ?? "").toLowerCase().includes(q) ||
          i.entry.author_organization.toLowerCase().includes(q)
        );
      })
    : items;

  async function handleImport(entryId: string) {
    setImporting(entryId);
    try {
      const res = await api.importMarketplaceRubric(orgId, entryId);
      toast.success(`Imported "${res.rubric.name}" to your library`);
      router.push(`/app/${orgId}/rubrics/${res.rubric.id}`);
    } catch (err) {
      const msg = err instanceof Error ? err.message : "Import failed";
      if (msg.includes("judge_prompt_requires_local_copy")) {
        toast.error("Judge prompt missing", {
          description:
            "This rubric requires a judge prompt. Import a compatible prompt first, then retry.",
          duration: 8000,
          action: {
            label: "Prompts",
            onClick: () => router.push(`/app/${orgId}/prompts`),
          },
        });
      } else {
        toast.error(msg);
      }
      setImporting(null);
    }
  }

  if (authLoading) {
    return (
      <div data-cy="app-loading" style={{ padding: "3rem 1rem", textAlign: "center" }}>
        Loading…
      </div>
    );
  }

  return (
    <div data-cy="rubrics-marketplace-page" {...cyAttrs({ cyScope: "rubrics-marketplace" })}>
      <PageHeader
        title="Rubric Marketplace"
        subtitle="Browse curated rubrics from the community."
        breadcrumbs={[
          { label: "library", href: `/app/${orgId}` },
          { label: "rubrics", href: `/app/${orgId}/rubrics` },
          { label: "marketplace", current: true },
        ]}
      />

      {/* Filter bar */}
      <div
        style={{
          display: "flex",
          gap: "var(--space-3)",
          marginBottom: "var(--space-5)",
          alignItems: "center",
          flexWrap: "wrap",
        }}
      >
        <Select
          cy="marketplace-domain-filter"
          value={domain}
          onChange={(e) => setDomain(e.target.value as Domain)}
          options={DOMAINS.map((d) => ({ value: d, label: d }))}
          style={{ width: 160 }}
        />
        <TextInput
          cy="marketplace-search"
          type="search"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Search title, description, author…"
          style={{ flex: 1, minWidth: 240 }}
        />
      </div>

      {loading && (
        <div data-cy="marketplace-loading">
          <LoadingSkeleton variant="card" count={3} />
        </div>
      )}

      {!loading && filtered.length === 0 && (
        <EmptyState
          glyph="search"
          cy="marketplace-empty"
          headline="No rubrics found"
          body={
            search.trim()
              ? `No results for "${search}"${domain !== "all" ? ` in ${domain}` : ""}.`
              : "No rubrics are published for this domain yet."
          }
          primaryAction={
            search.trim() ? (
              <Button variant="secondary" onClick={() => setSearch("")}>
                Clear search
              </Button>
            ) : undefined
          }
        />
      )}

      {!loading && filtered.length > 0 && (
        <div
          data-cy="marketplace-list"
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fill, minmax(320px, 1fr))",
            gap: "var(--space-4)",
          }}
        >
          {filtered.map(({ entry, rubric_version }) => (
            <Card
              key={entry.id}
              cy="marketplace-entry"
              cyId={entry.id}
              className="sg-stack-sm"
            >
              <div style={{ display: "flex", alignItems: "center", gap: "var(--space-2)", flexWrap: "wrap" }}>
                <strong data-cy="marketplace-entry-title" style={{ fontSize: "1rem" }}>
                  {entry.title}
                </strong>
                {entry.domain && (
                  <span
                    className="sg-pill sg-pill--sm"
                    data-cy="marketplace-entry-domain"
                  >
                    {entry.domain}
                  </span>
                )}
                <span
                  data-cy="marketplace-entry-scale"
                  className="sg-pill sg-pill--sm"
                >
                  {rubric_version.scale.method}
                </span>
              </div>

              {entry.description && (
                <p
                  data-cy="marketplace-entry-description"
                  style={{ margin: 0, fontSize: "0.875rem", color: "var(--text-secondary)" }}
                >
                  {entry.description}
                </p>
              )}

              <div
                style={{
                  display: "flex",
                  gap: "var(--space-3)",
                  fontSize: "0.8rem",
                  color: "var(--text-tertiary)",
                  flexWrap: "wrap",
                  alignItems: "center",
                }}
              >
                <span data-cy="marketplace-entry-author">by {entry.author_organization}</span>
                <span data-cy="marketplace-entry-downloads">
                  {entry.download_count.toLocaleString()} imports
                </span>
                {entry.sample_score !== null && entry.sample_score !== undefined && (
                  <span data-cy="marketplace-entry-sample-score">
                    <ScoreBadge
                      score={entry.sample_score}
                      state={
                        entry.sample_score >= 0.85
                          ? "pass"
                          : entry.sample_score >= 0.6
                          ? "warn"
                          : "fail"
                      }
                    />
                  </span>
                )}
                {rubric_version.criteria.length > 0 && (
                  <span data-cy="marketplace-entry-criteria-count">
                    {rubric_version.criteria.length} criteria
                  </span>
                )}
              </div>

              <div style={{ display: "flex", justifyContent: "flex-end", marginTop: "auto" }}>
                <Button
                  variant="primary"
                  size="sm"
                  cy="marketplace-import-btn"
                  cyId={entry.id}
                  loading={importing === entry.id}
                  onClick={() => handleImport(entry.id)}
                >
                  Import
                </Button>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
