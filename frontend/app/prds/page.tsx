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
import { SkeletonGrid } from "@/components/primitives/SkeletonGrid";
import { FilterBar } from "@/components/composites/FilterBar";
import { SearchBox } from "@/components/forms/SearchBox";
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
    <Link href={`/prds/${prd.id}`} className="block rounded-lg group focus-ring">
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
            <span className="inline-flex items-center rounded-full bg-surface-1 border border-border text-muted px-2 py-0.5 text-xs">
              FRs
            </span>
          )}
          {prd.has_ats && (
            <span className="inline-flex items-center rounded-full bg-surface-1 border border-border text-muted px-2 py-0.5 text-xs">
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

  const hasActive = Boolean(search) || statusFilter.length > 0;

  return (
    <div className="space-y-8">
      <PageHeader
        title="PRDs"
        description="Product requirement documents."
      />

      <FilterBar
        search={
          <SearchBox
            value={search}
            onChange={setSearch}
            placeholder="Search PRDs..."
            onClear={() => setSearch("")}
          />
        }
        filters={
          <FilterListbox
            label="Status"
            options={STATUS_OPTIONS}
            selected={statusFilter}
            onChange={setStatusFilter}
          />
        }
        hasActive={hasActive}
        onClear={() => { setSearch(""); setStatusFilter([]); }}
        summary={`${filtered.length} result${filtered.length === 1 ? "" : "s"}`}
      />

      {/* Loading skeleton */}
      {isLoading && <SkeletonGrid as="card" count={6} />}

      {/* Empty */}
      {!isLoading && filtered.length === 0 && (
        <EmptyState
          icon={<DocumentTextIcon />}
          title="No PRDs found"
          description={
            hasActive
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
