/**
 * Egghead — 3D isometric cube construction at 10 rotational angles.
 * Wide head (38w × 16h), tiny body (12w × 8h).
 * Round eyes (circles, not squares).
 */

const V = "var(--text-link)";

interface EggView {
  label: string;
  angle: string;
  head: string;
  eyes: [number, number, number, number, number][];  // [x, y, w, h, rx] for each rounded rect
  body: string;
  arms: string;
  legs: string;
  antenna: string;
}

// Head: 38w × 16h, centered at x=24 → x range 5..43
// Body: 12w × 8h → x range 18..30

const views: EggView[] = [
  {
    label: "Front",
    angle: "0°",
    head: "M5 2h38v16H5z M5 2l6-5h38l-6 5 M43 2l6-5v16l-6 5",
    eyes: [[10, 7, 8, 6, 1], [30, 7, 8, 6, 1]],
    body: "M18 22h12v8H18z M18 22l3-2h12l-3 2 M30 22l3-2v8l-3 2",
    arms: "M18 24h-4v4h4 M30 24h4v4h-4",
    legs: "M21 30v5h3v-5 M24 30v5h3v-5",
    antenna: "M24-3V-6 M22-3h4",
  },
  {
    label: "¾ Right",
    angle: "36°",
    head: "M9 2h32v16H9z M9 2l10-5h32l-10 5 M41 2l10-5v16l-10 5",
    eyes: [[14, 7, 6, 6, 1], [32, 7, 10, 6, 1]],
    body: "M19 22h11v8H19z M19 22l4-2h11l-4 2 M30 22l4-2v8l-4 2",
    arms: "M19 24h-3v4h3 M30 24h5v4h-5",
    legs: "M22 30v5h3v-5 M25 30v5h3v-5",
    antenna: "M27-3V-6 M25-3h4",
  },
  {
    label: "Right",
    angle: "72°",
    head: "M15 2h22v16H15z M15 2l13-5h22l-13 5 M37 2l13-5v16l-13 5",
    eyes: [[35, 7, 12, 6, 1]],
    body: "M20 22h10v8H20z M20 22l5-2h10l-5 2 M30 22l5-2v8l-5 2",
    arms: "M20 25h-2v3h2 M30 24h6v4h-6",
    legs: "M22 30v5h3v-5 M26 30v5h3v-5",
    antenna: "M31-3V-6 M29-3h4",
  },
  {
    label: "¾ Back-R",
    angle: "108°",
    head: "M17 2h18v16H17z M17 2l13-5h18l-13 5 M35 2l13-5v16l-13 5 M17 2l-4-3v16l4 3",
    eyes: [],
    body: "M21 22h9v8H21z M21 22l5-2h9l-5 2 M30 22l5-2v8l-5 2",
    arms: "M30 24h6v4h-6",
    legs: "M23 30v5h3v-5 M26 30v5h3v-5",
    antenna: "M31-3V-6 M29-3h4",
  },
  {
    label: "Back",
    angle: "144°",
    head: "M5 2h38v16H5z M5 2l6-5h38l-6 5 M5 2l-4-3v16l4 3",
    eyes: [],
    body: "M18 22h12v8H18z M18 22l3-2h12l-3 2 M18 22l-2-1v8l2 1",
    arms: "M18 24h-4v4h4 M30 24h4v4h-4",
    legs: "M21 30v5h3v-5 M24 30v5h3v-5",
    antenna: "M24-3V-6 M22-3h4",
  },
  {
    label: "¾ Back-L",
    angle: "180°",
    head: "M9 2h32v16H9z M9 2l-8-5v16l8 5 M9 2l6-5h32l-6 5",
    eyes: [],
    body: "M18 22h11v8H18z M18 22l-3-2v8l3 2 M18 22l3-2h11l-3 2",
    arms: "M18 24h-6v4h6",
    legs: "M19 30v5h3v-5 M24 30v5h3v-5",
    antenna: "M20-3V-6 M18-3h4",
  },
  {
    label: "Left",
    angle: "216°",
    head: "M11 2h22v16H11z M11 2l-11-5v16l11 5 M11 2l6-5h22l-6 5",
    eyes: [[1, 7, 12, 6, 1]],
    body: "M18 22h10v8H18z M18 22l-4-2v8l4 2 M18 22l3-2h10l-3 2",
    arms: "M18 24h-6v4h6 M28 25h2v3h-2",
    legs: "M20 30v5h3v-5 M24 30v5h3v-5",
    antenna: "M18-3V-6 M16-3h4",
  },
  {
    label: "¾ Left",
    angle: "252°",
    head: "M7 2h34v16H7z M7 2l-7-5v16l7 5 M7 2l6-5h34l-6 5",
    eyes: [[0, 7, 10, 6, 1], [16, 7, 6, 6, 1]],
    body: "M18 22h11v8H18z M18 22l-3-2v8l3 2 M18 22l3-2h11l-3 2",
    arms: "M18 24h-5v4h5 M29 24h4v4h-4",
    legs: "M20 30v5h3v-5 M25 30v5h3v-5",
    antenna: "M20-3V-6 M18-3h4",
  },
  {
    label: "High",
    angle: "288°",
    head: "M5 4h38v12H5z M5 4l6-8h38l-6 8 M43 4l6-8v12l-6 8",
    eyes: [[10, 7, 8, 5, 1], [30, 7, 8, 5, 1]],
    body: "M18 20h12v7H18z M18 20l3-3h12l-3 3 M30 20l3-3v7l-3 3",
    arms: "M18 22h-4v3h4 M30 22h4v3h-4",
    legs: "M21 27v4h3v-4 M24 27v4h3v-4",
    antenna: "M24-4V-7 M22-4h4",
  },
  {
    label: "Low",
    angle: "324°",
    head: "M5 0h38v18H5z M5 18l6 3h38l-6-3 M43 0l5-2v18l-5 2",
    eyes: [[10, 5, 8, 7, 1], [30, 5, 8, 7, 1]],
    body: "M18 24h12v10H18z M18 34l3 2h12l-3-2 M30 24l3-1v10l-3 2",
    arms: "M18 28h-4v5h4 M30 28h4v5h-4",
    legs: "M21 36v5h3v-5 M24 36v5h3v-5",
    antenna: "M24 0V-4 M22 0h4",
  },
];

export function RobotEgghead() {
  return (
    <div className="bg-[var(--surface-alt)] border border-[var(--border)] rounded-lg p-6">
      <h3 className="text-center font-[family-name:var(--font-mono)] text-xs uppercase tracking-widest text-[var(--text-muted)] border-b border-[var(--border)] pb-3 mb-2">
        03. Egghead — Turntable
      </h3>
      <p className="text-center text-[8px] font-[family-name:var(--font-mono)] text-[var(--text-muted)] mb-4">
        3D isometric cube · 10 rotational angles · rounded-rect eyes · head:body 3:1
      </p>
      <div className="flex flex-wrap justify-center gap-4">
        {views.map((v, i) => (
          <div key={i} className="flex flex-col items-center" style={{ width: 76 }}>
            <svg
              viewBox="-12 -10 72 52"
              className="w-[72px] h-[52px]"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.2"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <path d={v.antenna} />
              <path d={v.head} />
              {v.eyes.map(([x, y, w, h, rx], ei) => (
                <rect key={ei} x={x} y={y} width={w} height={h} rx={rx} stroke={V} strokeWidth="1.2" fill={V} fillOpacity="0.2" />
              ))}
              <path d={v.body} />
              <path d={v.arms} />
              <path d={v.legs} />
            </svg>
            <span className="text-[8px] text-[var(--text-muted)] font-[family-name:var(--font-mono)] uppercase mt-1">
              {v.label}
            </span>
            <span className="text-[7px] text-[var(--text-link)] font-[family-name:var(--font-mono)]">
              {v.angle}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}
