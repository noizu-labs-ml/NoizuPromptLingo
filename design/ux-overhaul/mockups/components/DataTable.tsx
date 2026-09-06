import type { ReactNode } from "react";

export type Column<T> = {
  key: string;
  label: string;
  render: (row: T) => ReactNode;
  sortable?: boolean;
};

export function DataTable<T extends { id: string }>({
  columns,
  rows,
  nextCursorHref,
  caption,
}: {
  columns: Column<T>[];
  rows: T[];
  nextCursorHref?: string;
  caption: string;
}) {
  return (
    <div>
      <table>
        <caption className="sr-only">{caption}</caption>
        <thead>
          <tr>
            {columns.map((c) => (
              <th key={c.key} scope="col">
                {c.sortable ? (
                  <button type="button" aria-label={`Sort by ${c.label}`}>
                    {c.label} ↕
                  </button>
                ) : (
                  c.label
                )}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.length === 0 ? (
            <tr>
              <td colSpan={columns.length}>No rows.</td>
            </tr>
          ) : (
            rows.map((row) => (
              <tr key={row.id}>
                {columns.map((c) => (
                  <td key={c.key}>{c.render(row)}</td>
                ))}
              </tr>
            ))
          )}
        </tbody>
      </table>
      {nextCursorHref && (
        <p>
          <a href={nextCursorHref}>Next →</a>
        </p>
      )}
    </div>
  );
}
