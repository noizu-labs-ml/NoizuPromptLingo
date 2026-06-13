/**
 * Robot pose variations with different body types.
 * 3D cubic wireframe style. All stroke, no fill.
 * Cyan visor is the only accent.
 *
 * Body types: standard, tall/thin, short/wide, big-head, tank,
 *             spider (many legs), orb (round body), centaur,
 *             mini (chibi proportions), sentinel (tall narrow)
 */

const S = "currentColor";
const V = "var(--text-link)";

/* ── Standard (the logo robot) ── */
function Pose1() {
  return (
    <g>
      {/* head */}
      <path d="M14 8h20v16H14z" />
      <path d="M14 8l6-5h20l-6 5" />
      <path d="M34 8l6-5v16l-6 5" />
      <rect x="18" y="13" width="12" height="4" rx="1" stroke={V} />
      <path d="M24 3V1M22 3h4" />
      {/* body */}
      <path d="M12 28h24v18H12z" />
      <path d="M12 28l6-4h24l-6 4" />
      <path d="M36 28l6-4v18l-6 4" />
      {/* arms */}
      <path d="M12 34h-4l-2 2v6l2 2h4" />
      <path d="M36 34h4l2 2v6l-2 2h-4" />
      {/* legs */}
      <path d="M18 46v6h4v-6M26 46v6h4v-6" />
    </g>
  );
}

/* ── Tall/Thin — elongated body, narrow limbs ── */
function Pose2() {
  return (
    <g>
      {/* small head */}
      <path d="M18 6h12v10H18z" />
      <path d="M18 6l4-3h12l-4 3" />
      <path d="M30 6l4-3v10l-4 3" />
      <rect x="20" y="9" width="8" height="3" rx="1" stroke={V} />
      <path d="M24 3V1" />
      {/* tall narrow body */}
      <path d="M16 20h16v26H16z" />
      <path d="M16 20l4-3h16l-4 3" />
      <path d="M32 20l4-3v26l-4 3" />
      {/* thin arms */}
      <path d="M16 26h-3v10h3" />
      <path d="M32 26h3v10h-3" />
      {/* thin legs */}
      <path d="M20 46v6h3v-6M25 46v6h3v-6" />
    </g>
  );
}

/* ── Short/Wide — squat, broad, heavy ── */
function Pose3() {
  return (
    <g>
      {/* wide head */}
      <path d="M8 6h32v14H8z" />
      <path d="M8 6l5-4h32l-5 4" />
      <path d="M40 6l5-4v14l-5 4" />
      <rect x="14" y="10" width="20" height="5" rx="1" stroke={V} />
      <path d="M24 2V0M20 2h8" />
      {/* short wide body */}
      <path d="M6 24h36v14H6z" />
      <path d="M6 24l5-3h36l-5 3" />
      <path d="M42 24l5-3v14l-5 3" />
      {/* thick arms */}
      <path d="M6 28h-4v8h4" />
      <path d="M42 28h4v8h-4" />
      {/* short thick legs */}
      <path d="M14 38v6h6v-6M28 38v6h6v-6" />
    </g>
  );
}

/* ── Big Head — oversized cranium, tiny body ── */
function Pose4() {
  return (
    <g>
      {/* huge head */}
      <path d="M6 4h36v22H6z" />
      <path d="M6 4l6-4h36l-6 4" />
      <path d="M42 4l6-4v22l-6 4" />
      <rect x="14" y="12" width="20" height="6" rx="2" stroke={V} />
      <path d="M24 0V-2M20 0h8" />
      {/* tiny body */}
      <path d="M16 30h16v10H16z" />
      <path d="M16 30l3-2h16l-3 2" />
      <path d="M32 30l3-2v10l-3 2" />
      {/* small arms */}
      <path d="M16 33h-3v4h3" />
      <path d="M32 33h3v4h-3" />
      {/* small legs */}
      <path d="M20 40v6h3v-6M25 40v6h3v-6" />
    </g>
  );
}

/* ── Tank — armored, wide stance, shoulder plates ── */
function Pose5() {
  return (
    <g>
      {/* head with visor slit */}
      <path d="M16 8h16v12H16z" />
      <path d="M16 8l4-3h16l-4 3" />
      <path d="M32 8l4-3v12l-4 3" />
      <rect x="18" y="12" width="12" height="3" rx="0" stroke={V} />
      {/* shoulder plates */}
      <path d="M8 22h6l2 2v2H8z" />
      <path d="M34 22h6v4h-8l2-2z" />
      {/* wide body */}
      <path d="M10 24h28v18H10z" />
      <path d="M10 24l5-3h28l-5 3" />
      <path d="M38 24l5-3v18l-5 3" />
      {/* thick arms */}
      <path d="M10 30H4v10h6" />
      <path d="M38 30h6v10h-6" />
      {/* wide stance legs */}
      <path d="M14 42l-2 8h6l-2-8M30 42l2 8h-6l2-8" />
    </g>
  );
}

/* ── Spider — small body, 6 articulated legs ── */
function Pose6() {
  return (
    <g>
      {/* small round-ish head */}
      <path d="M18 6h12v10H18z" />
      <path d="M18 6l3-2h12l-3 2" />
      <path d="M30 6l3-2v10l-3 2" />
      <rect x="20" y="9" width="8" height="3" rx="1" stroke={V} />
      {/* small body */}
      <path d="M16 20h16v10H16z" />
      <path d="M16 20l3-2h16l-3 2" />
      <path d="M32 20l3-2v10l-3 2" />
      {/* 6 legs — 3 per side */}
      <path d="M16 22l-8 4-4 8" />
      <path d="M16 26l-10 2-2 8" />
      <path d="M16 30l-8 6" />
      <path d="M32 22l8 4 4 8" />
      <path d="M32 26l10 2 2 8" />
      <path d="M32 30l8 6" />
    </g>
  );
}

/* ── Orb — spherical/round body ── */
function Pose7() {
  return (
    <g>
      {/* dome head */}
      <circle cx="24" cy="10" r="8" />
      <rect x="19" y="9" width="10" height="4" rx="1" stroke={V} />
      <path d="M24 2V0" />
      {/* round body */}
      <ellipse cx="24" cy="32" rx="14" ry="12" />
      {/* stubby arms */}
      <path d="M10 30l-4 2v4l4 2" />
      <path d="M38 30l4 2v4l-4 2" />
      {/* stubby legs */}
      <path d="M18 43v5h4v-4M26 43v5h4v-4" />
    </g>
  );
}

/* ── Centaur — humanoid top, quadruped bottom ── */
function Pose8() {
  return (
    <g>
      {/* head */}
      <path d="M10 4h14v10H10z" />
      <path d="M10 4l4-3h14l-4 3" />
      <path d="M24 4l4-3v10l-4 3" />
      <rect x="12" y="7" width="10" height="3" rx="1" stroke={V} />
      {/* upper body */}
      <path d="M8 18h18v12H8z" />
      <path d="M8 18l4-3h18l-4 3" />
      <path d="M26 18l4-3v12l-4 3" />
      {/* arms */}
      <path d="M8 22h-4v6h4" />
      <path d="M26 22h4v6h-4" />
      {/* horizontal lower body (horse) */}
      <path d="M12 30h28v8H12z" />
      <path d="M40 30l4-2v8l-4 2" />
      {/* 4 legs */}
      <path d="M14 38v8h3v-8M22 38v8h3v-8M30 38v8h3v-8M38 38v8h3v-8" />
    </g>
  );
}

/* ── Mini/Chibi — oversized head, tiny stubby everything ── */
function Pose9() {
  return (
    <g>
      {/* huge head relative to body */}
      <path d="M8 2h32v20H8z" />
      <path d="M8 2l5-3h32l-5 3" />
      <path d="M40 2l5-3v20l-5 3" />
      <rect x="14" y="9" width="20" height="6" rx="2" stroke={V} />
      {/* circle eyes inside visor */}
      <circle cx="20" cy="12" r="1.5" fill={V} />
      <circle cx="28" cy="12" r="1.5" fill={V} />
      <path d="M24 -1V-3M22 -1h4" />
      {/* tiny body */}
      <path d="M18 26h12v8H18z" />
      <path d="M18 26l2-1h12l-2 1" />
      {/* stub arms */}
      <path d="M18 28h-4v4h4" />
      <path d="M30 28h4v4h-4" />
      {/* stub legs */}
      <path d="M20 34v5h4v-5M24 34v5h4v-5" />
    </g>
  );
}

/* ── Sentinel — tall narrow tower, single eye ── */
function Pose10() {
  return (
    <g>
      {/* narrow tall head with single eye */}
      <path d="M18 2h12v12H18z" />
      <path d="M18 2l3-2h12l-3 2" />
      <path d="M30 2l3-2v12l-3 2" />
      <circle cx="24" cy="8" r="3" stroke={V} />
      <circle cx="24" cy="8" r="1" fill={V} />
      {/* tall narrow body */}
      <path d="M17 18h14v28H17z" />
      <path d="M17 18l3-2h14l-3 2" />
      <path d="M31 18l3-2v28l-3 2" />
      {/* thin arms */}
      <path d="M17 24h-3v8h3" />
      <path d="M31 24h3v8h-3" />
      {/* narrow legs */}
      <path d="M20 46v6h3v-6M25 46v6h3v-6" />
    </g>
  );
}

const poses = [Pose1, Pose2, Pose3, Pose4, Pose5, Pose6, Pose7, Pose8, Pose9, Pose10];
const labels = ["Standard", "Slender", "Stout", "Brainy", "Tank", "Spider", "Orb", "Centaur", "Mini", "Sentinel"];

export function RobotPoses({ size = 56 }: { size?: number }) {
  const gap = 20;
  const cellW = 48;
  const cellH = 56;
  const svgItemW = cellW + gap;
  const totalW = poses.length * svgItemW - gap;

  return (
    <div style={{ overflowX: "auto", padding: "1rem 0" }}>
      <svg
        width={poses.length * (size + gap) - gap}
        height={size + 24}
        viewBox={`0 0 ${totalW} ${cellH + 16}`}
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        style={{ display: "block" }}
      >
        {poses.map((PoseComponent, i) => (
          <g key={i} transform={`translate(${i * svgItemW}, 0)`}>
            <g
              stroke={S}
              strokeWidth={1.5}
              strokeLinejoin="round"
              strokeLinecap="round"
            >
              <PoseComponent />
            </g>
            <text
              x={24}
              y={cellH + 12}
              textAnchor="middle"
              fill="var(--text-muted)"
              fontSize="7"
              fontFamily="var(--font-mono)"
              letterSpacing="0.05em"
            >
              {labels[i]}
            </text>
          </g>
        ))}
      </svg>
    </div>
  );
}
