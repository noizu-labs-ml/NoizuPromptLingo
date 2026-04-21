"use client";

import Link from "next/link";
import { useState } from "react";
import useSWR from "swr";
import { DocumentTextIcon } from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import type { PRDSummary } from "@/lib/api/types";
import { Card } from "@/components/primitives/Card";
import { PageHeader } from "@/components/primitives/PageHeader";
import { EmptyState } from "@/components/primitives/EmptyState";
import { Badge } from "@/components/primitives/Badge";
import type { BadgeProps } from "@/components/primitives/Badge";
import { FilterListbox } from "@/components/forms/FilterListbox";

// ── Helpers ────────────────────────────────────────────────────────────────

function statusVariant(status: string | null): BadgeProps["variant"] {
  if (!status) return "default";
  const s = status.toLowerCase();
  if (s === "implemented" || s === "complete") return "success";
  if (s === "documented") return "success";
  if (s === "draft") return "info";
  if (s === "in progress" || s === "in_progress") return "warning";
  return "default";
}

const STATUS_OPTIONS = [
  { value: "Implemented", label: "Implemented" },
  { value: "Documented", label: "Documented" },
  { value: "Draft", label: "Draft" },
];

// ── PRD Card ───────────────────────────────────────────────────────────────

function PRDCard({ prd }: { prd: PRDSummary }) {
  return (
    <Link href={`/prds/${prd.id}`} className="block group">
      <Card hoverable className="h-full flex flex-col gap-3">
        <div className="flex items-start gap-3">
          <span className="font-mono text-xs text-muted shrink-0 mt-0.5">
            PRD-{String(prd.number).padStart(3, "0")}
          </span>
          <div className="flex-1 min-w-0">
            <p className="font-semibold text-foreground group-hover:text-accent transition-colors text-sm leading-snug">
              {prd.title}
            </p>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-2">
          {prd.status && (
            <Badge variant={statusVariant(prd.status)}>{prd.status}</Badge>
          )}
          {prd.has_frs && (
            <span className="inline-flex items-center rounded-full bg-surface-sunken border border-border text-muted px-2 py-0.5 text-xs">
              FRs
            </span>
          )}
          {prd.has_ats && (
            <span className="inline-flex items-center rounded-full bg-surface-sunken border border-border text-muted px-2 py-0.5 text-xs">
              ATs
            </span>
          )}
        </div>
      </Card>
    </Link>
  );
}

// ── Page ───────────────────────────────────────────────────────────────────

export default function PRDsPage() {
  const { data: prds, isLoading } = useSWR("prds.list", () => api.prds.list());
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<string[]>([]);

  const filtered = (prds ?? []).filter((p) => {
    if (statusFilter.length > 0 && (!p.status || !statusFilter.includes(p.status))) return false;
    if (search) {
      const q = search.toLowerCase();
      if (!p.title.toLowerCase().includes(q) && !p.id.toLowerCase().includes(q)) return false;
    }
    return true;
  });

  return (
    <div className="space-y-8">
      <PageHeader
        title="PRDs"
        description="Product requirement documents."
      />

      {/* Controls */}
      <div className="flex flex-wrap gap-3 items-center">
        <input
          type="search"
          placeholder="Search PRDs..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="rounded-md border border-border bg-surface px-3 py-1.5 text-sm text-foreground placeholder:text-subtle focus:outline-none focus:ring-2 focus:ring-accent/50 w-64"
        />
        <FilterListbox
          label="Status"
          options={STATUS_OPTIONS}
          selected={statusFilter}
          onChange={setStatusFilter}
        />
        {(search || statusFilter.length > 0) && (
          <button
            onClick={() => { setSearch(""); setStatusFilter([]); }}
            className="text-xs text-muted hover:text-foreground transition-colors"
          >
            Clear filters
          </button>
        )}
      </div>

      {/* Loading skeleton */}
      {isLoading && (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <Card key={i} className="animate-pulse">
              <div className="h-4 bg-surface-sunken rounded w-3/4 mb-2" />
              <div className="h-3 bg-surface-sunken rounded w-1/2" />
            </Card>
          ))}
        </div>
      )}

      {/* Empty */}
      {!isLoading && filtered.length === 0 && (
        <EmptyState
          icon={<DocumentTextIcon />}
          title="No PRDs found"
          description={
            search || statusFilter.length > 0
              ? "Try adjusting the search or filters."
              : "PRDs will appear here once they are created."
          }
        />
      )}

      {/* Grid */}
      {!isLoading && filtered.length > 0 && (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {filtered.map((prd) => (
            <PRDCard key={prd.id} prd={prd} />
          ))}
        </div>
      )}
    </div>
  );
}
