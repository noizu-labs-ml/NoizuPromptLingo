export function Skeleton({ lines = 4 }: { lines?: number }) {
  return (
    <div role="status" aria-label="Loading">
      {Array.from({ length: lines }).map((_, i) => (
        <div className="skeleton-line" key={i} style={{ width: `${90 - i * 8}%` }} />
      ))}
      <span className="sr-only">Loading content</span>
    </div>
  );
}

export function SkeletonTable({ rows = 5, cols = 4 }: { rows?: number; cols?: number }) {
  return (
    <table role="status" aria-label="Loading table">
      <thead>
        <tr>
          {Array.from({ length: cols }).map((_, i) => (
            <th key={i}>
              <div className="skeleton-line" style={{ width: "60%" }} />
            </th>
          ))}
        </tr>
      </thead>
      <tbody>
        {Array.from({ length: rows }).map((_, r) => (
          <tr key={r}>
            {Array.from({ length: cols }).map((_, c) => (
              <td key={c}>
                <div className="skeleton-line" />
              </td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
}
