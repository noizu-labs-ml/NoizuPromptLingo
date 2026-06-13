"use client";

import React, { useState, useMemo } from "react";

/**
 * DataTable — Multi-column sortable table with inline actions, bulk select, and pagination.
 * Used across 9 screens — the highest-complexity T2 component.
 *
 * @example
 * ```tsx
 * <DataTable
 *   columns={[
 *     { id: "title", label: "Title", sortable: true },
 *     { id: "status", label: "Status", width: 100 },
 *     { id: "date", label: "Created", sortable: true, width: 120 },
 *   ]}
 *   data={[{ id: "1", title: "Fix auth", status: "open", date: "2026-05-20" }]}
 *   sortable selectable
 *   actions={[{ label: "Edit", onClick: (row) => edit(row) }]}
 * />
 * ```
 */

// ── Types ───────────────────────────────────────────────────────

interface Column {
  id: string;
  label: string;
  sortable?: boolean;
  width?: number | string;
  render?: (value: unknown, row: Row) => React.ReactNode;
}

type Row = Record<string, unknown> & { id: string };

interface RowAction {
  label: string;
  icon?: string;
  onClick: (row: Row) => void;
  danger?: boolean;
}

interface PaginationConfig {
  pageSize: number;
  totalRows?: number;
}

type SortDir = "asc" | "desc";
type TableVariant = "compact" | "expanded" | "full_page";

interface DataTableProps {
  columns: Column[];
  data: Row[];
  sortable?: boolean;
  selectable?: boolean;
  actions?: RowAction[];
  pagination?: PaginationConfig;
  variant?: TableVariant;
  onBulkAction?: (selectedIds: string[], action: string) => void;
  emptyMessage?: string;
}

// ── Component ───────────────────────────────────────────────────

export function DataTable({
  columns,
  data,
  sortable = false,
  selectable = false,
  actions,
  pagination,
  variant = "expanded",
  onBulkAction,
  emptyMessage = "No data",
}: DataTableProps) {
  const [sortCol, setSortCol] = useState<string | null>(null);
  const [sortDir, setSortDir] = useState<SortDir>("asc");
  const [selected, setSelected] = useState<Set<string>>(new Set());
  const [page, setPage] = useState(0);

  const handleSort = (colId: string) => {
    if (!sortable) return;
    if (sortCol === colId) {
      setSortDir((d) => (d === "asc" ? "desc" : "asc"));
    } else {
      setSortCol(colId);
      setSortDir("asc");
    }
  };

  const sorted = useMemo(() => {
    if (!sortCol) return data;
    return [...data].sort((a, b) => {
      const av = String(a[sortCol] ?? "");
      const bv = String(b[sortCol] ?? "");
      const cmp = av.localeCompare(bv, undefined, { numeric: true });
      return sortDir === "asc" ? cmp : -cmp;
    });
  }, [data, sortCol, sortDir]);

  const pageSize = pagination?.pageSize ?? sorted.length;
  const totalPages = Math.ceil(sorted.length / pageSize);
  const paged = pagination ? sorted.slice(page * pageSize, (page + 1) * pageSize) : sorted;

  const toggleSelect = (id: string) => {
    setSelected((s) => { const next = new Set(s); next.has(id) ? next.delete(id) : next.add(id); return next; });
  };
  const toggleAll = () => {
    if (selected.size === paged.length) setSelected(new Set());
    else setSelected(new Set(paged.map((r) => r.id)));
  };

  const isCompact = variant === "compact";
  const rowPad = isCompact ? "4px 8px" : "8px 12px";
  const fontSize = isCompact ? "var(--font-size-2xs, 10px)" : "var(--font-size-xs)";

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-2)" }}>
      {/* Bulk actions bar */}
      {selectable && selected.size > 0 && onBulkAction && (
        <div style={{ display: "flex", alignItems: "center", gap: "8px", padding: "var(--space-1) var(--space-2)", background: "color-mix(in srgb, var(--info, var(--blue)) 8%, transparent)", borderRadius: "var(--radius, 6px)" }}>
          <span style={{ fontFamily: "var(--font-mono)", fontSize, fontWeight: 600, color: "var(--info, var(--blue))" }}>{selected.size} selected</span>
          <button type="button" onClick={() => onBulkAction(Array.from(selected), "delete")} style={{ padding: "2px 8px", borderRadius: 4, border: "1px solid var(--error)", background: "none", color: "var(--error)", fontSize, fontFamily: "var(--font-body)", cursor: "pointer" }}>Delete</button>
          <button type="button" onClick={() => setSelected(new Set())} style={{ padding: "2px 8px", borderRadius: 4, border: "1px solid var(--border)", background: "none", color: "var(--text-muted)", fontSize, fontFamily: "var(--font-body)", cursor: "pointer", marginLeft: "auto" }}>Clear</button>
        </div>
      )}

      {/* Table */}
      <div style={{ overflowX: "auto", border: "1px solid var(--border)", borderRadius: "var(--radius, 6px)", background: "var(--surface)" }}>
        <table style={{ width: "100%", borderCollapse: "collapse", fontFamily: "var(--font-body)", fontSize }}>
          <thead>
            <tr style={{ borderBottom: "1px solid var(--border)" }}>
              {selectable && (
                <th style={{ padding: rowPad, width: 32, textAlign: "center" }}>
                  <input type="checkbox" checked={paged.length > 0 && selected.size === paged.length} onChange={toggleAll} aria-label="Select all" />
                </th>
              )}
              {columns.map((col) => (
                <th
                  key={col.id}
                  onClick={col.sortable && sortable ? () => handleSort(col.id) : undefined}
                  style={{
                    padding: rowPad,
                    textAlign: "left",
                    fontFamily: "var(--font-mono)",
                    fontSize: "var(--font-size-2xs, 10px)",
                    fontWeight: 600,
                    textTransform: "uppercase",
                    letterSpacing: "0.06em",
                    color: "var(--text-muted)",
                    cursor: col.sortable && sortable ? "pointer" : "default",
                    userSelect: "none",
                    width: col.width,
                    whiteSpace: "nowrap",
                  }}
                >
                  {col.label}
                  {sortable && sortCol === col.id && (
                    <span style={{ marginLeft: 4 }}>{sortDir === "asc" ? "↑" : "↓"}</span>
                  )}
                </th>
              ))}
              {actions && actions.length > 0 && (
                <th style={{ padding: rowPad, width: 80, textAlign: "right", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.06em", color: "var(--text-muted)" }}>Actions</th>
              )}
            </tr>
          </thead>
          <tbody>
            {paged.length === 0 ? (
              <tr>
                <td colSpan={columns.length + (selectable ? 1 : 0) + (actions ? 1 : 0)} style={{ padding: "var(--space-4)", textAlign: "center", color: "var(--text-muted)", fontStyle: "italic" }}>
                  {emptyMessage}
                </td>
              </tr>
            ) : (
              paged.map((row) => (
                <tr key={row.id} style={{ borderBottom: "1px solid var(--border)", background: selected.has(row.id) ? "color-mix(in srgb, var(--info, var(--blue)) 5%, transparent)" : "transparent" }}>
                  {selectable && (
                    <td style={{ padding: rowPad, textAlign: "center" }}>
                      <input type="checkbox" checked={selected.has(row.id)} onChange={() => toggleSelect(row.id)} aria-label={`Select row ${row.id}`} />
                    </td>
                  )}
                  {columns.map((col) => (
                    <td key={col.id} style={{ padding: rowPad, color: "var(--text)", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", maxWidth: 300 }}>
                      {col.render ? col.render(row[col.id], row) : String(row[col.id] ?? "")}
                    </td>
                  ))}
                  {actions && actions.length > 0 && (
                    <td style={{ padding: rowPad, textAlign: "right" }}>
                      <div style={{ display: "flex", gap: "4px", justifyContent: "flex-end" }}>
                        {actions.map((a, i) => (
                          <button key={i} type="button" onClick={(e) => { e.stopPropagation(); a.onClick(row); }} title={a.label} style={{ padding: "2px 6px", borderRadius: 4, border: "1px solid var(--border)", background: "none", color: a.danger ? "var(--error)" : "var(--text-secondary)", fontSize: "var(--font-size-2xs, 10px)", fontFamily: "var(--font-body)", cursor: "pointer" }}>
                            {a.icon ?? a.label}
                          </button>
                        ))}
                      </div>
                    </td>
                  )}
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      {pagination && totalPages > 1 && (
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
          <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-2xs, 10px)", color: "var(--text-muted)" }}>
            {page * pageSize + 1}–{Math.min((page + 1) * pageSize, sorted.length)} of {sorted.length}
          </span>
          <div style={{ display: "flex", gap: "4px" }}>
            <button type="button" onClick={() => setPage(Math.max(0, page - 1))} disabled={page === 0} style={{ padding: "2px 8px", borderRadius: 4, border: "1px solid var(--border)", background: "var(--surface)", color: page === 0 ? "var(--text-muted)" : "var(--text)", fontSize: "var(--font-size-xs)", cursor: page === 0 ? "default" : "pointer" }}>← Prev</button>
            <button type="button" onClick={() => setPage(Math.min(totalPages - 1, page + 1))} disabled={page >= totalPages - 1} style={{ padding: "2px 8px", borderRadius: 4, border: "1px solid var(--border)", background: "var(--surface)", color: page >= totalPages - 1 ? "var(--text-muted)" : "var(--text)", fontSize: "var(--font-size-xs)", cursor: page >= totalPages - 1 ? "default" : "pointer" }}>Next →</button>
          </div>
        </div>
      )}
    </div>
  );
}

export default DataTable;
