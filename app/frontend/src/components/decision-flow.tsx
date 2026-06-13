/**
 * SVG validation loop diagram — the ad testing → decision gate detail.
 * Shows the mini ad runs against theme variants,
 * KPI measurement, and the CAC vs LTV decision.
 */

export function DecisionFlow() {
  const W = 760;
  const H = 420;

  return (
    <div style={{ overflowX: "auto", margin: "2rem 0" }}>
      <svg width="100%" height={H} viewBox={`0 0 ${W} ${H}`} fill="none"
        xmlns="http://www.w3.org/2000/svg" style={{ minWidth: 600, display: "block" }}>

        <defs>
          <marker id="df-arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto">
            <path d="M0 1L9 5L0 9" fill="var(--text-link)" />
          </marker>
          <marker id="df-arr-green" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto">
            <path d="M0 1L9 5L0 9" fill="var(--success)" />
          </marker>
          <marker id="df-arr-red" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto">
            <path d="M0 1L9 5L0 9" fill="var(--error)" />
          </marker>
          <marker id="df-arr-amber" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto">
            <path d="M0 1L9 5L0 9" fill="var(--warning)" />
          </marker>
        </defs>

        {/* ═══ Title ═══ */}
        <text x={380} y={20} textAnchor="middle" fill="var(--text)" fontSize="14" fontWeight="700" fontFamily="var(--font-display)">
          Validation Loop — Ad Testing Detail
        </text>

        {/* ═══ Landing Page Variants ═══ */}
        {/* Three theme variants side by side */}
        <rect x={30} y={50} width={100} height={60} rx={4} stroke="var(--text-link)" strokeWidth={1.5} fill="var(--surface-accent)" />
        <text x={80} y={72} textAnchor="middle" fill="var(--text)" fontSize="10" fontWeight="700" fontFamily="var(--font-display)">Theme A</text>
        <text x={80} y={86} textAnchor="middle" fill="var(--text-muted)" fontSize="8" fontFamily="var(--font-mono)">Nocturne</text>
        <text x={80} y={98} textAnchor="middle" fill="var(--text-muted)" fontSize="8" fontFamily="var(--font-mono)">variant</text>

        <rect x={150} y={50} width={100} height={60} rx={4} stroke="var(--border)" strokeWidth={1.5} fill="var(--surface-alt)" />
        <text x={200} y={72} textAnchor="middle" fill="var(--text)" fontSize="10" fontWeight="700" fontFamily="var(--font-display)">Theme B</text>
        <text x={200} y={86} textAnchor="middle" fill="var(--text-muted)" fontSize="8" fontFamily="var(--font-mono)">Minimal</text>
        <text x={200} y={98} textAnchor="middle" fill="var(--text-muted)" fontSize="8" fontFamily="var(--font-mono)">variant</text>

        <rect x={270} y={50} width={100} height={60} rx={4} stroke="var(--border)" strokeWidth={1.5} fill="var(--surface-alt)" />
        <text x={320} y={72} textAnchor="middle" fill="var(--text)" fontSize="10" fontWeight="700" fontFamily="var(--font-display)">Theme C</text>
        <text x={320} y={86} textAnchor="middle" fill="var(--text-muted)" fontSize="8" fontFamily="var(--font-mono)">Bold</text>
        <text x={320} y={98} textAnchor="middle" fill="var(--text-muted)" fontSize="8" fontFamily="var(--font-mono)">variant</text>

        {/* Label */}
        <text x={200} y={42} textAnchor="middle" fill="var(--text-link)" fontSize="9" fontWeight="600" fontFamily="var(--font-mono)" letterSpacing="0.06em">
          LANDING PAGE VARIANTS
        </text>

        {/* Arrows from variants down to ad channels */}
        <line x1={80} y1={110} x2={200} y2={146} stroke="var(--text-link)" strokeWidth={1} strokeDasharray="4 2" />
        <line x1={200} y1={110} x2={200} y2={146} stroke="var(--text-link)" strokeWidth={1} strokeDasharray="4 2" />
        <line x1={320} y1={110} x2={200} y2={146} stroke="var(--text-link)" strokeWidth={1} strokeDasharray="4 2" />

        {/* ═══ Ad Channels ═══ */}
        <rect x={130} y={148} width={140} height={40} rx={4} stroke="var(--border)" strokeWidth={1.5} fill="var(--surface-alt)" />
        <text x={200} y={164} textAnchor="middle" fill="var(--text)" fontSize="10" fontWeight="700" fontFamily="var(--font-display)">Mini Ad Runs</text>
        <text x={200} y={178} textAnchor="middle" fill="var(--text-muted)" fontSize="8" fontFamily="var(--font-mono)">Meta · Google · LinkedIn</text>

        {/* Arrow to KPIs */}
        <line x1={200} y1={188} x2={200} y2={218} stroke="var(--text-link)" strokeWidth={1.5} markerEnd="url(#df-arrow)" />

        {/* ═══ KPI Measurement ═══ */}
        <rect x={440} y={50} width={290} height={160} rx={6} stroke="var(--border)" strokeWidth={1.5} fill="var(--surface-alt)" />
        <text x={585} y={72} textAnchor="middle" fill="var(--text-link)" fontSize="10" fontWeight="700" fontFamily="var(--font-mono)" letterSpacing="0.06em">
          KPI DASHBOARD
        </text>

        {/* KPI items */}
        <text x={460} y={96} fill="var(--text)" fontSize="9" fontWeight="600" fontFamily="var(--font-display)">Click-through rate</text>
        <text x={460} y={108} fill="var(--text-muted)" fontSize="8" fontFamily="var(--font-body)">Do users click ads → landing page?</text>

        <text x={460} y={128} fill="var(--text)" fontSize="9" fontWeight="600" fontFamily="var(--font-display)">Engagement depth</text>
        <text x={460} y={140} fill="var(--text-muted)" fontSize="8" fontFamily="var(--font-body)">Do they scroll, click sections, explore?</text>

        <text x={460} y={160} fill="var(--text)" fontSize="9" fontWeight="600" fontFamily="var(--font-display)">Signup / interest</text>
        <text x={460} y={172} fill="var(--text-muted)" fontSize="8" fontFamily="var(--font-body)">Beta access, email capture, waitlist</text>

        <text x={460} y={192} fill="var(--text)" fontSize="9" fontWeight="600" fontFamily="var(--font-display)">Best variant winner</text>
        <text x={460} y={204} fill="var(--text-muted)" fontSize="8" fontFamily="var(--font-body)">Which theme/positioning converts?</text>

        {/* Arrow from ad runs → KPI box */}
        <line x1={270} y1={168} x2={434} y2={168} stroke="var(--text-link)" strokeWidth={1.5} markerEnd="url(#df-arrow)" />
        <text x={352} y={160} textAnchor="middle" fill="var(--text-muted)" fontSize="8" fontFamily="var(--font-mono)">DATA FLOWS</text>

        {/* ═══ Decision: Best variant → CAC vs LTV ═══ */}
        <line x1={585} y1={210} x2={585} y2={248} stroke="var(--text-link)" strokeWidth={1.5} markerEnd="url(#df-arrow)" />

        {/* LTV comparison */}
        <rect x={480} y={250} width={210} height={44} rx={4} stroke="var(--text-link)" strokeWidth={2} fill="var(--surface-accent)" />
        <text x={585} y={268} textAnchor="middle" fill="var(--text)" fontSize="10" fontWeight="700" fontFamily="var(--font-display)">
          Customer Acquisition Cost
        </text>
        <text x={585} y={282} textAnchor="middle" fill="var(--text-link)" fontSize="9" fontFamily="var(--font-mono)">vs. Lifetime Value</text>

        {/* Arrow down to diamond */}
        <line x1={585} y1={294} x2={585} y2={325} stroke="var(--text-link)" strokeWidth={1.5} markerEnd="url(#df-arrow)" />

        {/* ═══ Decision Diamond ═══ */}
        <path d="M585 330 L645 360 L585 390 L525 360Z" stroke="var(--text-link)" strokeWidth={2} fill="var(--surface-accent)" />
        <text x={585} y={358} textAnchor="middle" fill="var(--text)" fontSize="9" fontWeight="700" fontFamily="var(--font-display)">CAC</text>
        <text x={585} y={370} textAnchor="middle" fill="var(--text-link)" fontSize="8" fontFamily="var(--font-mono)">{"< LTV?"}</text>

        {/* ── YES → Build ── */}
        <line x1={645} y1={360} x2={720} y2={360} stroke="var(--success)" strokeWidth={1.5} markerEnd="url(#df-arr-green)" />
        <text x={682} y={352} textAnchor="middle" fill="var(--success)" fontSize="9" fontWeight="700" fontFamily="var(--font-mono)">YES</text>
        <text x={730} y={356} fill="var(--success)" fontSize="10" fontWeight="700" fontFamily="var(--font-display)">→</text>
        <text x={730} y={370} fill="var(--success)" fontSize="9" fontWeight="600" fontFamily="var(--font-display)">BUILD</text>

        {/* ── NO → Kill ── */}
        <line x1={525} y1={360} x2={440} y2={360} stroke="var(--error)" strokeWidth={1.5} markerEnd="url(#df-arr-red)" />
        <text x={482} y={352} textAnchor="middle" fill="var(--error)" fontSize="9" fontWeight="700" fontFamily="var(--font-mono)">NO</text>

        <rect x={340} y={340} width={96} height={40} rx={4} stroke="var(--error)" strokeWidth={1.5} fill="var(--surface-danger)" />
        <text x={388} y={356} textAnchor="middle" fill="var(--error)" fontSize="10" fontWeight="700" fontFamily="var(--font-mono)">KILL</text>
        <text x={388} y={370} textAnchor="middle" fill="var(--text-secondary)" fontSize="8" fontFamily="var(--font-body)">Reclaim budget</text>

        {/* ── Marginal → Iterate ── */}
        <line x1={585} y1={390} x2={585} y2={410} stroke="var(--warning)" strokeWidth={1.5} />
        <path d="M585 410 L200 410 L200 218" stroke="var(--warning)" strokeWidth={1.5} strokeDasharray="5 3" fill="none" markerEnd="url(#df-arr-amber)" />
        <text x={390} y={404} textAnchor="middle" fill="var(--warning)" fontSize="8" fontWeight="700" fontFamily="var(--font-mono)">
          MARGINAL — ITERATE VARIANT / AUDIENCE
        </text>

      </svg>
    </div>
  );
}
