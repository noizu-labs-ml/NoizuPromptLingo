interface Props {
  columns: number;
  gutterPx: number;
  marginPx: number;
}

const HATCH = `repeating-linear-gradient(
  45deg,
  var(--surface-alt),
  var(--surface-alt) 2px,
  transparent 2px,
  transparent 8px
)`;

function Annotation({ label, sub }: { label: string; sub?: string }) {
  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 2 }}>
      <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", fontWeight: 700, color: "var(--border-strong)", whiteSpace: "nowrap" }}>
        {label}
      </span>
      {sub && (
        <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)", whiteSpace: "nowrap" }}>
          {sub}
        </span>
      )}
    </div>
  );
}

export function GridVisualizer({ columns, gutterPx, marginPx }: Props) {
  return (
    <div className="flex flex-col gap-[var(--space-2)] overflow-x-auto">
      {/* Grid visual */}
      <div style={{ display: "flex", alignItems: "stretch", border: "1px solid var(--border)", overflow: "hidden", minWidth: 480 }}>
        {/* Left margin */}
        <div
          style={{
            width: marginPx,
            minWidth: marginPx,
            background: HATCH,
            borderRight: "1px dashed var(--border)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          <span style={{ fontFamily: "var(--font-mono)", fontSize: 8, color: "var(--text-muted)", writingMode: "vertical-rl" }}>
            {marginPx}px
          </span>
        </div>

        {/* Columns */}
        <div
          style={{
            flex: 1,
            display: "grid",
            gridTemplateColumns: `repeat(${columns}, 1fr)`,
            gap: gutterPx,
            padding: `var(--space-2) 0`,
            background: "var(--surface)",
          }}
        >
          {Array.from({ length: columns }).map((_, i) => (
            <div
              key={i}
              style={{
                height: "var(--space-6)",
                background: "var(--surface-alt)",
                border: "1px solid var(--border)",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
              }}
            >
              <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)" }}>
                {i + 1}
              </span>
            </div>
          ))}
        </div>

        {/* Right margin */}
        <div
          style={{
            width: marginPx,
            minWidth: marginPx,
            background: HATCH,
            borderLeft: "1px dashed var(--border)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          <span style={{ fontFamily: "var(--font-mono)", fontSize: 8, color: "var(--text-muted)", writingMode: "vertical-rl" }}>
            {marginPx}px
          </span>
        </div>
      </div>

      {/* Annotations row */}
      <div style={{ display: "flex", gap: "var(--space-4)", paddingLeft: marginPx }}>
        <Annotation label={`${columns} columns`} sub="equal width" />
        <Annotation label={`${gutterPx}px gutter`} sub="--col-gap" />
        <Annotation label={`${marginPx}px margin`} sub="--space-5" />
      </div>
    </div>
  );
}
