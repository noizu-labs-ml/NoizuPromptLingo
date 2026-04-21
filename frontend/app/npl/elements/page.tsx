"use client";

import { useEffect, useState, useMemo } from "react";
import { useRouter } from "next/navigation";
import { Listbox, ListboxButton, ListboxOption, ListboxOptions } from "@headlessui/react";
import { ChevronUpDownIcon } from "@heroicons/react/24/outline";
import clsx from "clsx";

import { api } from "@/lib/api/client";
import type { NPLElement } from "@/lib/api/types";
import { Badge } from "@/components/primitives/Badge";
import { Card } from "@/components/primitives/Card";
import { DataTable } from "@/components/primitives/DataTable";
import { PageHeader } from "@/components/primitives/PageHeader";
import type { ColumnDef } from "@/components/primitives/DataTable";

const SECTION_BADGE_VARIANT: Record<string, "default" | "info" | "success" | "warning" | "danger"> = {
  syntax: "info",
  directives: "success",
  pumps: "warning",
  prefix: "default",
  declarations: "danger",
};

function sectionVariant(section: string): "default" | "info" | "success" | "warning" | "danger" {
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

  return (
    <div className="space-y-6">
      <PageHeader
        title="NPL Elements"
        description="Flat index of every NPL component across all conventions."
      />

      {/* Filters */}
      <Card className="flex flex-col gap-4 sm:flex-row sm:items-center sm:gap-6">
        {/* Search */}
        <div className="flex-1">
          <input
            type="text"
            placeholder="Search by name, brief, or tag…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full rounded-md border border-border bg-surface-sunken px-3 py-2 text-sm text-foreground placeholder:text-muted focus:outline-none focus:ring-2 focus:ring-brand-500"
          />
        </div>

        {/* Section filter */}
        <div className="w-48">
          <Listbox value={selectedSection} onChange={setSelectedSection}>
            <div className="relative">
              <ListboxButton className="relative w-full cursor-default rounded-md border border-border bg-surface-sunken py-2 pl-3 pr-10 text-left text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-brand-500">
                <span className="block truncate capitalize">{selectedSection}</span>
                <span className="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-2">
                  <ChevronUpDownIcon className="h-4 w-4 text-muted" />
                </span>
              </ListboxButton>
              <ListboxOptions className="absolute z-20 mt-1 max-h-60 w-full overflow-auto rounded-md border border-border bg-surface py-1 text-sm shadow-lg focus:outline-none">
                {sections.map((s) => (
                  <ListboxOption
                    key={s}
                    value={s}
                    className={({ focus }: { focus: boolean }) =>
                      clsx(
                        "cursor-default select-none px-3 py-2 capitalize",
                        focus ? "bg-surface-raised text-foreground" : "text-muted"
                      )
                    }
                  >
                    {s}
                  </ListboxOption>
                ))}
              </ListboxOptions>
            </div>
          </Listbox>
        </div>
      </Card>

      {/* Table */}
      {error ? (
        <div className="rounded-md bg-danger/10 px-4 py-3 text-sm text-danger">{error}</div>
      ) : loading ? (
        <div className="py-16 text-center text-sm text-muted">Loading elements…</div>
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
