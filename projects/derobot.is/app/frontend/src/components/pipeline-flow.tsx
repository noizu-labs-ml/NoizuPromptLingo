/**
 * Full venture lab pipeline as a vertical flow diagram.
 * Matches the real process:
 *   Idea → Spec (3-5h) → Landing Page (1-8h) → Ad Validation → Decision Gate
 *   → Beta Prototype (2-14d) → KPI Gate → Scale/Backburner → Spinoff
 */

// Shared arrow marker
function Markers() {
  return (
    <defs>
      <marker id="pf-arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto">
        <path d="M0 1L9 5L0 9" fill="var(--text-link)" />
      </marker>
      <marker id="pf-arr-green" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto">
        <path d="M0 1L9 5L0 9" fill="var(--success)" />
      </marker>
      <marker id="pf-arr-red" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto">
        <path d="M0 1L9 5L0 9" fill="var(--error)" />
      </marker>
      <marker id="pf-arr-amber" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto">
        <path d="M0 1L9 5L0 9" fill="var(--warning)" />
      </marker>
    </defs>
  );
}

// Reusable node box
function Node({ x, y, w, h, label, sub, accent }: {
  x: number; y: number; w: number; h: number;
  label: string; sub?: string; accent?: boolean;
}) {
  return (
    <g>
      <rect x={x} y={y} width={w} height={h} rx={6}
        stroke={accent ? "var(--text-link)" : "var(--border)"}
        strokeWidth={accent ? 2 : 1.5}
        fill={accent ? "var(--surface-accent)" : "var(--surface-alt)"} />
      <text x={x + w / 2} y={y + (sub ? h / 2 - 4 : h / 2 + 4)} textAnchor="middle"
        fill="var(--text)" fontSize="12" fontWeight="700" fontFamily="var(--font-display)">{label}</text>
      {sub && <text x={x + w / 2} y={y + h / 2 + 10} textAnchor="middle"
        fill="var(--text-muted)" fontSize="9" fontFamily="var(--font-mono)">{sub}</text>}
    </g>
  );
}

// Diamond decision gate
function Diamond({ cx, cy, rw, rh, label, sub }: {
  cx: number; cy: number; rw: number; rh: number; label: string; sub?: string;
}) {
  return (
    <g>
      <path d={`M${cx} ${cy - rh}L${cx + rw} ${cy}L${cx} ${cy + rh}L${cx - rw} ${cy}Z`}
        stroke="var(--text-link)" strokeWidth={2} fill="var(--surface-accent)" />
      <text x={cx} y={cy - 2} textAnchor="middle" fill="var(--text)" fontSize="10" fontWeight="700" fontFamily="var(--font-display)">{label}</text>
      {sub && <text x={cx} y={cy + 10} textAnchor="middle" fill="var(--text-link)" fontSize="8" fontFamily="var(--font-mono)">{sub}</text>}
    </g>
  );
}

// Arrow line
function Arrow({ x1, y1, x2, y2, color, dashed }: {
  x1: number; y1: number; x2: number; y2: number; color?: string; dashed?: boolean;
}) {
  const c = color ?? "var(--text-link)";
  const markerId = c.includes("success") ? "pf-arr-green" : c.includes("error") ? "pf-arr-red" : c.includes("warning") ? "pf-arr-amber" : "pf-arrow";
  return <line x1={x1} y1={y1} x2={x2} y2={y2} stroke={c} strokeWidth={1.5}
    strokeDasharray={dashed ? "5 3" : undefined} markerEnd={`url(#${markerId})`} />;
}

// Label on a path
function Label({ x, y, text, color, align }: {
  x: number; y: number; text: string; color?: string; align?: "start" | "middle" | "end";
}) {
  return <text x={x} y={y} textAnchor={align ?? "middle"} fill={color ?? "var(--text-muted)"} fontSize="8"
    fontFamily="var(--font-mono)" letterSpacing="0.04em">{text}</text>;
}

// Outcome box (Kill/Backburner)
function Outcome({ x, y, w, h, label, lines, color }: {
  x: number; y: number; w: number; h: number; label: string; lines: string[]; color: string;
}) {
  const bgVar = color.includes("error") ? "var(--surface-danger)" : color.includes("warning") ? "var(--surface-warning)" : "var(--surface-accent)";
  return (
    <g>
      <rect x={x} y={y} width={w} height={h} rx={6} stroke={color} strokeWidth={1.5} fill={bgVar} />
      <text x={x + w / 2} y={y + 16} textAnchor="middle" fill={color} fontSize="11" fontWeight="700" fontFamily="var(--font-mono)">{label}</text>
      {lines.map((l, i) => (
        <text key={i} x={x + w / 2} y={y + 30 + i * 12} textAnchor="middle" fill="var(--text-secondary)" fontSize="8" fontFamily="var(--font-body)">{l}</text>
      ))}
    </g>
  );
}

export function PipelineFlow() {
  const W = 800;
  const H = 880;
  const cx = 320; // center column x
  const nw = 180; // node width
  const nh = 48;  // node height

  return (
    <div style={{ overflowX: "auto", margin: "2rem 0" }}>
      <svg width="100%" height={H} viewBox={`0 0 ${W} ${H}`} fill="none"
        xmlns="http://www.w3.org/2000/svg" style={{ minWidth: 640, display: "block" }}>
        <Markers />

        {/* ═══ Stage 1: Idea to Spec ═══ */}
        <Node x={cx - nw / 2} y={10} w={nw} h={nh} label="Idea → Spec" sub="3–5 hours" accent />
        <Label x={cx + nw / 2 + 10} y={30} text="Personas, user stories," align="start" />
        <Label x={cx + nw / 2 + 10} y={42} text="components, branding options" align="start" />
        <Arrow x1={cx} y1={58} x2={cx} y2={88} />

        {/* ═══ Stage 2: Landing Page ═══ */}
        <Node x={cx - nw / 2} y={90} w={nw} h={nh} label="Landing Page" sub="1–8 hours" />
        <Label x={cx + nw / 2 + 10} y={110} text="Spec + stories → conversion page" align="start" />
        <Arrow x1={cx} y1={138} x2={cx} y2={168} />

        {/* ═══ Stage 3: LTV Model ═══ */}
        <Node x={cx - nw / 2} y={170} w={nw} h={nh} label="LTV Estimation" sub="Price model analysis" />
        <Label x={cx + nw / 2 + 10} y={190} text="Gauge lifetime value across" align="start" />
        <Label x={cx + nw / 2 + 10} y={202} text="different pricing tiers" align="start" />
        <Arrow x1={cx} y1={218} x2={cx} y2={248} />

        {/* ═══ Stage 4: Ad Validation ═══ */}
        <Node x={cx - nw / 2} y={250} w={nw} h={56} label="Ad Validation" sub="Mini ad runs × theme variants" />
        <Label x={cx + nw / 2 + 10} y={264} text="KPI: Click-through rate" align="start" />
        <Label x={cx + nw / 2 + 10} y={276} text="KPI: Signup / interest check" align="start" />
        <Label x={cx + nw / 2 + 10} y={288} text="KPI: Section engagement depth" align="start" />
        <Arrow x1={cx} y1={306} x2={cx} y2={340} />

        {/* ═══ Decision Gate 1: CAC vs LTV ═══ */}
        <Diamond cx={cx} cy={370} rw={90} rh={30} label="CAC < LTV?" sub="Acquisition cost viable?" />

        {/* ── NO → Kill ── */}
        <line x1={cx - 90} y1={370} x2={80} y2={370} stroke="var(--error)" strokeWidth={1.5} markerEnd="url(#pf-arr-red)" />
        <Label x={140} y={362} text="NO" color="var(--error)" />
        <Outcome x={10} y={390} w={140} h={54} label="KILL" color="var(--error)"
          lines={["Reclaim domain budget.", "Free resources. Move on."]} />

        {/* ── YES → Beta ── */}
        <line x1={cx} y1={400} x2={cx} y2={440} stroke="var(--success)" strokeWidth={1.5} markerEnd="url(#pf-arr-green)" />
        <Label x={cx + 14} y={424} text="YES" color="var(--success)" align="start" />

        {/* ═══ Stage 5: Beta Prototype ═══ */}
        <Node x={cx - nw / 2} y={445} w={nw} h={56} label="Beta Prototype" sub="2–14 days" />
        <Label x={cx + nw / 2 + 10} y={462} text="Next.js + Elixir build" align="start" />
        <Label x={cx + nw / 2 + 10} y={474} text="Real features, purchase integration" align="start" />
        <Arrow x1={cx} y1={501} x2={cx} y2={535} />

        {/* ═══ Stage 6: KPI + Usage Gate ═══ */}
        <Node x={cx - nw / 2} y={537} w={nw} h={48} label="KPI Monitoring" sub="Conversion + usage metrics" />
        <Label x={cx + nw / 2 + 10} y={554} text="Target usage level + conversion" align="start" />
        <Label x={cx + nw / 2 + 10} y={566} text="Tolerate lag unless far off target" align="start" />
        <Arrow x1={cx} y1={585} x2={cx} y2={620} />

        {/* ═══ Decision Gate 2: KPI targets ═══ */}
        <Diamond cx={cx} cy={650} rw={90} rh={30} label="KPIs on track?" sub="Hitting milestones?" />

        {/* ── Diverging → Backburner ── */}
        <line x1={cx - 90} y1={650} x2={80} y2={650} stroke="var(--warning)" strokeWidth={1.5} markerEnd="url(#pf-arr-amber)" />
        <Label x={140} y={642} text="DIVERGING" color="var(--warning)" />
        <Outcome x={10} y={670} w={140} h={54} label="BACKBURNER" color="var(--warning)"
          lines={["Pause active dev.", "Revisit when data shifts."]} />

        {/* ── Lagging but acceptable → continue (loop back to KPI) ── */}
        <path d={`M${cx + 90} 650 L${cx + 140} 650 L${cx + 140} 560 L${cx + nw / 2 + 6} 560`}
          stroke="var(--text-link)" strokeWidth={1.5} strokeDasharray="5 3" fill="none" markerEnd="url(#pf-arrow)" />
        <Label x={cx + 150} y={610} text="LAG OK" color="var(--text-muted)" align="start" />
        <Label x={cx + 150} y={622} text="CONTINUE" color="var(--text-muted)" align="start" />

        {/* ── On target → Scale ── */}
        <line x1={cx} y1={680} x2={cx} y2={720} stroke="var(--success)" strokeWidth={1.5} markerEnd="url(#pf-arr-green)" />
        <Label x={cx + 14} y={704} text="ON TARGET" color="var(--success)" align="start" />

        {/* ═══ Stage 7: Scale ═══ */}
        <Node x={cx - nw / 2} y={725} w={nw} h={56} label="Scale" sub="Ongoing" />
        <Label x={cx + nw / 2 + 10} y={742} text="Feature build-out, marketing," align="start" />
        <Label x={cx + nw / 2 + 10} y={754} text="refinement. Ongoing until spinoff." align="start" />
        <Arrow x1={cx} y1={781} x2={cx} y2={815} />

        {/* ═══ Stage 8: Spinoff ═══ */}
        <Node x={cx - nw / 2} y={820} w={nw} h={48} label="Spinoff" sub="Own BV · Own P&L" accent />
        <Label x={cx + nw / 2 + 10} y={840} text="Dutch BV registered." align="start" />
        <Label x={cx + nw / 2 + 10} y={852} text="Portfolio equity retained." align="start" />

      </svg>
    </div>
  );
}
