"use client";
import * as React from "react";
import { cyAttrs } from "@/utils/cypress";

export interface DataTableColumn<T> {
  key: string;
  label: React.ReactNode;
  width?: string | number;
  render?: (row: T, index: number) => React.ReactNode;
}

export interface DataTableProps<T> {
  columns: DataTableColumn<T>[];
  rows: T[];
  rowKey?: (row: T, index: number) => string;
  onRowClick?: (row: T, index: number) => void;
  compact?: boolean;
  className?: string;
  emptyContent?: React.ReactNode;
  /** Fade + translate-in stagger on rows (40ms per row). Defaults to true. */
  stagger?: boolean;
  cy?: string;
}

/**
 * Headless-ish table — j/k/Enter keyboard nav between rows.
 *
 * @example
 * <DataTable
 *   columns={[{key:"name", label:"Name"}, {key:"status", label:"Status", render: r => <StatusPill state={r.status} />}]}
 *   rows={runs}
 *   onRowClick={r => router.push(`/runs/${r.id}`)}
 * />
 */
export function DataTable<T extends object>({
  columns,
  rows,
  rowKey,
  onRowClick,
  compact = false,
  className,
  emptyContent,
  stagger = true,
  cy = "data-table",
}: DataTableProps<T>) {
  const [selectedIndex, setSelectedIndex] = React.useState<number>(-1);

  const move = React.useCallback(
    (delta: number) => {
      setSelectedIndex((prev) => {
        const next = prev + delta;
        if (next < 0) return 0;
        if (next >= rows.length) return rows.length - 1;
        return next;
      });
    },
    [rows.length]
  );

  const handleKey = (e: React.KeyboardEvent<HTMLTableElement>) => {
    if (!rows.length) return;
    if (e.key === "j" || e.key === "ArrowDown") {
      e.preventDefault();
      move(1);
    } else if (e.key === "k" || e.key === "ArrowUp") {
      e.preventDefault();
      move(-1);
    } else if (e.key === "Enter" && selectedIndex >= 0) {
      e.preventDefault();
      onRowClick?.(rows[selectedIndex], selectedIndex);
    }
  };

  if (rows.length === 0 && emptyContent) {
    return <>{emptyContent}</>;
  }

  const tableClasses = [
    "sg-table",
    compact ? "sg-table--compact" : "",
    className || "",
  ]
    .filter(Boolean)
    .join(" ");

  const tbodyClass = stagger ? "sg-stagger" : undefined;

  return (
    <table
      className={tableClasses}
      tabIndex={0}
      onKeyDown={handleKey}
      {...cyAttrs({ cy })}
    >
      <thead>
        <tr>
          {columns.map((c) => (
            <th
              key={c.key}
              style={c.width ? { width: c.width } : undefined}
              {...cyAttrs({ cy: "column", cyId: c.key })}
            >
              {c.label}
            </th>
          ))}
        </tr>
      </thead>
      <tbody className={tbodyClass}>
        {rows.map((row, i) => {
          const k = rowKey ? rowKey(row, i) : String(i);
          const isSelected = selectedIndex === i;
          return (
            <tr
              key={k}
              data-clickable={onRowClick ? "true" : undefined}
              data-selected={isSelected ? "true" : undefined}
              onClick={onRowClick ? () => onRowClick(row, i) : undefined}
              onMouseEnter={() => setSelectedIndex(i)}
              style={stagger ? ({ "--i": i } as React.CSSProperties) : undefined}
              {...cyAttrs({ cy: "row", cyId: k })}
            >
              {columns.map((c) => (
                <td key={c.key}>
                  {c.render
                    ? c.render(row, i)
                    : ((row as Record<string, unknown>)[c.key] as React.ReactNode) ?? ""}
                </td>
              ))}
            </tr>
          );
        })}
      </tbody>
    </table>
  );
}
