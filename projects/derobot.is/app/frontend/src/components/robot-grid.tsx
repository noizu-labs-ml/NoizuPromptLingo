/**
 * Grid of robot body variations × pose actions.
 * 5 body types × 6 actions = 30 unique robots in a grid.
 * All isometric wireframe, stroke only, cyan visor accent.
 */

const VISOR = "var(--text-link)";

/* ═══════════════════════════════════════════════════════════
   BODY TYPES — different proportions and features
   ═══════════════════════════════════════════════════════════ */

type BodyProps = { action: ActionDef };
type ActionDef = {
  headTilt?: number;
  headDx?: number;
  headDy?: number;
  leftArm: string;
  rightArm: string;
  leftLeg: string;
  rightLeg: string;
};

/** Type A: Standard — balanced cube proportions (the default logo robot) */
function BodyStandard({ action }: BodyProps) {
  return (
    <g>
      {/* Head */}
      <g transform={`translate(${action.headDx ?? 0},${action.headDy ?? 0}) rotate(${action.headTilt ?? 0}, 24, 12)`}>
        <path d="M14 8h20v16H14z" />
        <path d="M14 8l6-5h20l-6 5" />
        <path d="M34 8l6-5v16l-6 5" />
        <rect x="18" y="13" width="12" height="4" rx="1" stroke={VISOR} />
        <path d="M24 3V1M22 3h4" />
      </g>
      {/* Torso */}
      <path d="M12 28h24v18H12z" />
      <path d="M12 28l6-4h24l-6 4" />
      <path d="M36 28l6-4v18l-6 4" />
      <path d="M12 46l6 4h24l-6-4" />
      {/* Limbs */}
      <path d={action.leftArm} />
      <path d={action.rightArm} />
      <path d={action.leftLeg} />
      <path d={action.rightLeg} />
    </g>
  );
}

/** Type B: Tall/thin — elongated torso, smaller head */
function BodyTall({ action }: BodyProps) {
  return (
    <g>
      {/* Smaller head */}
      <g transform={`translate(${(action.headDx ?? 0) + 3},${(action.headDy ?? 0) - 2}) rotate(${action.headTilt ?? 0}, 24, 10) scale(0.75)`}>
        <path d="M14 8h20v14H14z" />
        <path d="M14 8l5-4h20l-5 4" />
        <path d="M34 8l5-4v14l-5 4" />
        <rect x="18" y="12" width="12" height="3" rx="1" stroke={VISOR} />
        <path d="M24 4V1" />
      </g>
      {/* Tall torso */}
      <path d="M14 26h20v22H14z" />
      <path d="M14 26l5-3h20l-5 3" />
      <path d="M34 26l5-3v22l-5 3" />
      <path d="M14 48l5 3h20l-5-3" />
      {/* Thin limbs */}
      <path d={action.leftArm} />
      <path d={action.rightArm} />
      <path d={action.leftLeg} />
      <path d={action.rightLeg} />
    </g>
  );
}

/** Type C: Stocky/wide — broad shoulders, short legs */
function BodyStocky({ action }: BodyProps) {
  return (
    <g>
      {/* Wide head */}
      <g transform={`translate(${(action.headDx ?? 0) - 2},${(action.headDy ?? 0)}) rotate(${action.headTilt ?? 0}, 24, 12)`}>
        <path d="M11 8h26v14H11z" />
        <path d="M11 8l6-5h26l-6 5" />
        <path d="M37 8l6-5v14l-6 5" />
        <rect x="16" y="12" width="16" height="5" rx="1" stroke={VISOR} />
        <path d="M24 3V0M21 3h6" />
      </g>
      {/* Wide torso */}
      <path d="M9 26h30v16H9z" />
      <path d="M9 26l6-4h30l-6 4" />
      <path d="M39 26l6-4v16l-6 4" />
      <path d="M9 42l6 4h30l-6-4" />
      {/* Stubby limbs (shorter Y range) */}
      <path d={action.leftArm.replace(/34/g, "32").replace(/42/g, "38")} />
      <path d={action.rightArm.replace(/34/g, "32").replace(/42/g, "38")} />
      <path d="M17 42v4h5v-4" />
      <path d="M26 42v4h5v-4" />
    </g>
  );
}

/** Type D: Spherical/rounded — circular head, barrel body */
function BodyRound({ action }: BodyProps) {
  return (
    <g>
      {/* Round head */}
      <g transform={`translate(${action.headDx ?? 0},${(action.headDy ?? 0) + 2}) rotate(${action.headTilt ?? 0}, 24, 10)`}>
        <circle cx="24" cy="10" r="10" fill="none" />
        <ellipse cx="24" cy="4" rx="8" ry="3" fill="none" />
        <rect x="18" y="9" width="12" height="4" rx="2" stroke={VISOR} />
        <path d="M24 0V-2" />
      </g>
      {/* Barrel torso (rounded rect) */}
      <rect x="12" y="26" width="24" height="20" rx="6" />
      <path d="M12 28l5-3h24l-5 3" />
      <path d="M36 26l5-3v20l-5 3" />
      {/* Limbs */}
      <path d={action.leftArm} />
      <path d={action.rightArm} />
      <path d={action.leftLeg} />
      <path d={action.rightLeg} />
    </g>
  );
}

/** Type E: Angular/military — sharp edges, V-shaped torso */
function BodyAngular({ action }: BodyProps) {
  return (
    <g>
      {/* Angular head — pentagon */}
      <g transform={`translate(${action.headDx ?? 0},${action.headDy ?? 0}) rotate(${action.headTilt ?? 0}, 24, 12)`}>
        <path d="M16 6h16l4 6v10H12V12z" />
        <path d="M16 6l4-4h16l-4 4" />
        <path d="M32 6l4-4v6l-4 6v-2" />
        <rect x="17" y="13" width="14" height="3" rx="0" stroke={VISOR} />
        <path d="M24 2V-1M22 2h4" />
      </g>
      {/* V-shaped torso — wider shoulders */}
      <path d="M8 26h32v4l-4 14H12l-4-14z" />
      <path d="M8 26l6-4h32l-6 4" />
      <path d="M40 26l6-4v4l-4 14l-2 0" />
      {/* Limbs */}
      <path d={action.leftArm.replace("M12", "M8")} />
      <path d={action.rightArm.replace("M36", "M40")} />
      <path d={action.leftLeg} />
      <path d={action.rightLeg} />
    </g>
  );
}

/* ═══════════════════════════════════════════════════════════
   ACTIONS — limb positions for different activities
   ═══════════════════════════════════════════════════════════ */

const actions: Record<string, ActionDef> = {
  standing: {
    leftArm: "M12 34h-4l-2 2v6l2 2h4",
    rightArm: "M36 34h4l2 2v6l-2 2h-4",
    leftLeg: "M18 46v6h4v-6",
    rightLeg: "M26 46v6h4v-6",
  },
  waving: {
    leftArm: "M12 34h-4l-2 2v6l2 2h4",
    rightArm: "M36 30h4l2-2v-6l2-2h2",
    leftLeg: "M18 46v6h4v-6",
    rightLeg: "M26 46v6h4v-6",
  },
  running: {
    headDx: 2,
    leftArm: "M12 32h-4l-3-2v-4l3-2h4",
    rightArm: "M36 36h4l3 2v4l-3 2h-4",
    leftLeg: "M18 46l-4 6h4l4-6",
    rightLeg: "M26 46l4 6h4l-4-6",
  },
  building: {
    leftArm: "M12 34h-4l-2 2v6l2 2h4",
    rightArm: "M36 32h8l2-1v-2l-2-1h-2M44 28l2-3M44 28l-2-3",
    leftLeg: "M18 46v6h4v-6",
    rightLeg: "M26 46v6h4v-6",
  },
  celebrating: {
    leftArm: "M12 30h-4l-2-2v-6l-2-2h-2",
    rightArm: "M36 30h4l2-2v-6l2-2h2",
    leftLeg: "M16 46l-3 6h4l3-6",
    rightLeg: "M28 46l3 6h-4l-3-6",
  },
  pointing: {
    leftArm: "M12 34h-4l-2 2v6l2 2h4",
    rightArm: "M36 36h10M46 34v4M44 35l4 1-4 1",
    leftLeg: "M18 46v6h4v-6",
    rightLeg: "M26 46v6h4v-6",
  },
};

const bodyTypes = [
  { name: "Standard", Component: BodyStandard },
  { name: "Tall", Component: BodyTall },
  { name: "Stocky", Component: BodyStocky },
  { name: "Round", Component: BodyRound },
  { name: "Angular", Component: BodyAngular },
];

const actionNames = Object.keys(actions);
const actionLabels: Record<string, string> = {
  standing: "Standing",
  waving: "Waving",
  running: "Running",
  building: "Building",
  celebrating: "Victory",
  pointing: "Pointing",
};

export function RobotGrid() {
  const cellW = 56;
  const cellH = 66;
  const labelH = 16;
  const headerW = 70;
  const headerH = 20;
  const gap = 8;

  const gridW = headerW + actionNames.length * (cellW + gap);
  const gridH = headerH + bodyTypes.length * (cellH + labelH + gap);

  return (
    <div style={{ overflowX: "auto", padding: "1rem 0" }}>
      <svg
        width="100%"
        height={gridH}
        viewBox={`0 0 ${gridW} ${gridH}`}
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        style={{ minWidth: gridW, display: "block" }}
      >
        {/* Column headers (action names) */}
        {actionNames.map((action, col) => (
          <text
            key={action}
            x={headerW + col * (cellW + gap) + cellW / 2}
            y={14}
            textAnchor="middle"
            fill="var(--text-link)"
            fontSize="9"
            fontFamily="var(--font-mono)"
            fontWeight="600"
            letterSpacing="0.06em"
          >
            {actionLabels[action].toUpperCase()}
          </text>
        ))}

        {/* Rows */}
        {bodyTypes.map((body, row) => {
          const y = headerH + row * (cellH + labelH + gap);
          return (
            <g key={body.name}>
              {/* Row label */}
              <text
                x={headerW - 8}
                y={y + cellH / 2 + 4}
                textAnchor="end"
                fill="var(--text-muted)"
                fontSize="9"
                fontFamily="var(--font-mono)"
                letterSpacing="0.04em"
              >
                {body.name}
              </text>

              {/* Cells */}
              {actionNames.map((action, col) => {
                const x = headerW + col * (cellW + gap);
                const Comp = body.Component;
                return (
                  <g key={`${body.name}-${action}`} transform={`translate(${x},${y})`}>
                    {/* Cell background */}
                    <rect
                      x={0}
                      y={0}
                      width={cellW}
                      height={cellH}
                      rx={4}
                      fill="var(--surface-alt)"
                      stroke="var(--border)"
                      strokeWidth={0.5}
                    />
                    {/* Robot scaled to fit */}
                    <g transform="translate(4,3) scale(0.88)" stroke="currentColor" strokeWidth={1.3} strokeLinejoin="round" strokeLinecap="round">
                      <Comp action={actions[action]} />
                    </g>
                  </g>
                );
              })}
            </g>
          );
        })}
      </svg>
    </div>
  );
}
