"use client";

import { useEffect, useState, useMemo } from "react";
import { useRouter } from "next/navigation";

import { api } from "@/lib/api/client";
import type { NPLElement } from "@/lib/api/types";
import { Badge } from "@/components/primitives/Badge";
import { DataTable } from "@/components/primitives/DataTable";
import { PageHeader } from "@/components/primitives/PageHeader";
import { Input } from "@/components/primitives/Input";
import { Select } from "@/components/primitives/Select";
import { FormField } from "@/components/primitives/FormField";
import { SkeletonGrid } from "@/components/primitives/SkeletonGrid";
import { FilterBar } from "@/components/composites/FilterBar";
import type { ColumnDef } from "@/components/primitives/DataTable";

const SECTION_BADGE_VARIANT: Record<string, "default" | "info" | "success" | "warning" | "danger" | "accent"> = {
  syntax: "info",
  directives: "success",
  pumps: "warning",
  prefix: "default",
  declarations: "danger",
};

function sectionVariant(section: string): "default" | "info" | "success" | "warning" | "danger" | "accent" {
  return SECTION_BADGE_VARIANT[section] ?? "default";
}

function truncate(text: string, max = 80): string {
  if (text.length <= max) return text;
  return text.slice(0, max - 1) + "…";
}

const COLUMNS: ColumnDef<NPLElement>[] = [
  {
    key: "section",
    header: "Section",
    render: (row) => (
      <Badge variant={sectionVariant(row.section)}>{row.section}</Badge>
    ),
  },
  {
    key: "name",
    header: "Name",
    render: (row) => (
      <code className="font-mono text-sm text-accent">{row.name}</code>
    ),
  },
  {
    key: "friendly_name",
    header: "Friendly Name",
    render: (row) => <span>{row.friendly_name ?? row.name}</span>,
  },
  {
    key: "brief",
    header: "Brief",
    render: (row) => (
      <span className="text-muted text-sm">{truncate(row.brief)}</span>
    ),
  },
  {
    key: "priority",
    header: "Priority",
    render: (row) => (
      <span className="font-mono text-sm">{row.priority}</span>
    ),
    className: "w-20 text-center",
  },
  {
    key: "tags",
    header: "Tags",
    render: (row) => (
      <div className="flex flex-wrap gap-1">
        {(row.tags ?? []).map((tag) => (
          <Badge key={tag} variant="default" size="sm">
            {tag}
          </Badge>
        ))}
      </div>
    ),
  },
];

export default function NPLElementsPage() {
  const router = useRouter();
  const [elements, setElements] = useState<NPLElement[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const [selectedSection, setSelectedSection] = useState<string>("all");

  useEffect(() => {
    setLoading(true);
    api.npl
      .elements()
      .then(setElements)
      .catch((err) => setError(err instanceof Error ? err.message : "Failed to load elements"))
      .finally(() => setLoading(false));
  }, []);

  const sections = useMemo(() => {
    const unique = Array.from(new Set(elements.map((e) => e.section))).sort();
    return ["all", ...unique];
  }, [elements]);

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    return elements.filter((e) => {
      const matchSection = selectedSection === "all" || e.section === selectedSection;
      const matchSearch =
        !q ||
        e.name.toLowerCase().includes(q) ||
        (e.friendly_name ?? "").toLowerCase().includes(q) ||
        e.brief.toLowerCase().includes(q) ||
        (e.tags ?? []).some((t) => t.toLowerCase().includes(q));
      return matchSection && matchSearch;
    });
  }, [elements, search, selectedSection]);

  const handleRowClick = (row: NPLElement) => {
    const expr = `${row.section}#${row.name}`;
    router.push(`/npl?expr=${encodeURIComponent(expr)}`);
  };

  const hasActive = Boolean(search) || selectedSection !== "all";

  return (
    <div className="space-y-6">
      <PageHeader
        title="NPL Elements"
        description="Flat index of every NPL component across all conventions."
      />

      {/* Filters */}
      <FilterBar
        search={
          <FormField label="Search" htmlFor="npl-elements-search">
            <Input
              id="npl-elements-search"
              type="text"
              placeholder="Search by name, brief, or tag…"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </FormField>
        }
        filters={
          <FormField label="Section" htmlFor="npl-elements-section" className="w-48">
            <Select
              id="npl-elements-section"
              value={selectedSection}
              onChange={(e) => setSelectedSection(e.target.value)}
            >
              {sections.map((s) => (
                <option key={s} value={s} className="capitalize">
                  {s}
                </option>
              ))}
            </Select>
          </FormField>
        }
        hasActive={hasActive}
        onClear={() => {
          setSearch("");
          setSelectedSection("all");
        }}
        summary={
          !loading && !error
            ? `${filtered.length} ${filtered.length === 1 ? "element" : "elements"}`
            : undefined
        }
      />

      {/* Table */}
      {error ? (
        <div
          role="alert"
          className="rounded-md border border-danger/20 bg-danger/10 px-4 py-3 text-sm text-danger"
        >
          {error}
        </div>
      ) : loading ? (
        <SkeletonGrid as="table" count={8} />
      ) : (
        <DataTable
          columns={COLUMNS}
          rows={filtered}
          rowKey={(r) => `${r.section}-${r.name}`}
          emptyMessage="No elements match your filter."
          onRowClick={handleRowClick}
        />
      )}
    </div>
  );
}
