"use client";

import { useThemeConfig } from "@styleguide-engine/components/ThemeConfigContext";
import { CollapsibleSection } from "@styleguide-engine/components/CollapsibleSection";
import type { SectionProps } from "./section-props";

/* ---------- Sumi-e effects ---------- */

function SumiEffects() {
  return (
    <div className="effects-grid">
      <div className="effect-card">
        <span className="ink-bleed-kanji">{"\u58A8"}</span>
        <div className="effect-label">Ink Bleed</div>
      </div>
      <div className="effect-card">
        <span className="brush-in-text">noizu</span>
        <div className="effect-label">Brush-in</div>
      </div>
      <div className="effect-card">
        <span className="breath-circle" />
        <div className="effect-label">Breath</div>
      </div>
      <div className="effect-card">
        <span className="seal-stamp-glyph">{"\u5370"}</span>
        <div className="effect-label">{"\u5370\u9451"} Seal Stamp</div>
      </div>
      <div className="effect-card">
        <div className="ink-wash-bar" />
        <div className="effect-label">{"\u6FC3\u6DE1"} Ink Wash</div>
      </div>
      <div className="effect-card">
        <span className="fade-up-text">stillness</span>
        <div className="effect-label">Fade Up</div>
      </div>
    </div>
  );
}

/* ---------- Cyberpunk effects ---------- */

function CyberpunkCodeWidgets() {
  return (
    <div className="widget-grid">
      <div className="code-widget">
        <div className="code-widget-header">
          <span className="code-widget-title">CODE BLOCK</span>
          <span className="code-widget-badge code-widget-badge--syntax">SYNTAX</span>
        </div>
        <div className="code-widget-dots">
          <span className="code-dot code-dot--red" />
          <span className="code-dot code-dot--yellow" />
          <span className="code-dot code-dot--green" />
          <span className="code-widget-filename">orchestrator.ts</span>
        </div>
        <pre className="code-widget-body">
          <span className="code-comment">{"// Spawn a coder agent"}</span>{"\n"}
          <span className="code-keyword">const</span> agent = <span className="code-keyword">await</span> orchestrator.<span className="code-function">spawn</span>(<span className="code-string">&apos;coder&apos;</span>,{" {"}{"\n"}
          {"  "}story: <span className="code-string">&apos;INK-042&apos;</span>,{"\n"}
          {"  "}maxTokens: <span className="code-number">50_000</span>,{"\n"}
          {"}"});
        </pre>
        <div className="code-widget-desc">Void background. Traffic light dots. Neon syntax highlighting.</div>
      </div>

      <div className="code-widget code-widget--terminal">
        <div className="code-widget-header">
          <span className="code-widget-title">TERMINAL</span>
          <span className="code-widget-badge code-widget-badge--cli">CLI</span>
        </div>
        <div className="code-widget-dots">
          <span className="code-dot code-dot--red" />
          <span className="code-dot code-dot--yellow" />
          <span className="code-dot code-dot--green" />
          <span className="code-widget-filename">terminal</span>
        </div>
        <pre className="code-widget-body">
          <span className="code-prompt">$</span> noizu deploy --target vercel{"\n"}
          <span className="code-output">[deploy] Building project ...</span>{"\n"}
          <span className="code-output">[deploy] Tests ... 14/14 passed</span>{"\n"}
          <span className="code-success">&gt; Deployed successfully</span>
        </pre>
        <div className="code-widget-desc">Lime text on void. Cyan prompts. Success/error colored output.</div>
      </div>
    </div>
  );
}

function CyberpunkEffects() {
  return (
    <>
      <CyberpunkCodeWidgets />

      <h3 className="effects-subsection-title">EFFECTS SHOWCASE</h3>
      <p className="effects-subsection-desc">CSS-only animations and effects. All respect prefers-reduced-motion.</p>

      <div className="effects-grid">
        <div className="effect-card effect-card--scanline">
          <span className="scanline-demo">SCANNING</span>
          <div className="effect-label">Scanline Sweep</div>
        </div>
        <div className="effect-card">
          <span className="glitch-demo">GLITCH</span>
          <div className="effect-label">Positional Glitch</div>
        </div>
        <div className="effect-card">
          <span className="neon-flicker-demo">SIGNAL</span>
          <div className="effect-label">Neon Flicker</div>
        </div>
        <div className="effect-card">
          <span className="glow-pulse-demo" />
          <div className="effect-label">Glow Pulse</div>
        </div>
        <div className="effect-card">
          <span className="gradient-border-demo"><span className="gradient-border-inner">GRADIENT BORDER</span></span>
          <div className="effect-label">Animated Gradient Border</div>
        </div>
        <div className="effect-card">
          <span className="typing-demo">$ noizu deploy --target vercel</span>
          <div className="effect-label">Typing + Cursor</div>
        </div>
      </div>
    </>
  );
}

/* ---------- Swiss project components ---------- */

function SwissCodeWidgets() {
  return (
    <div className="widget-grid">
      <div className="code-widget">
        <div className="code-widget-header">
          <span className="code-widget-title">CODE BLOCK</span>
          <span className="code-widget-badge code-widget-badge--syntax">SYNTAX</span>
        </div>
        <div className="code-widget-dots">
          <span className="code-dot code-dot--red" />
          <span className="code-dot code-dot--yellow" />
          <span className="code-dot code-dot--green" />
          <span className="code-widget-filename">orchestrator.ts</span>
          <span className="code-widget-badge code-widget-badge--lang">TS</span>
        </div>
        <pre className="code-widget-body">
          <span className="code-comment">{"// Spawn a coder agent"}</span>{"\n"}
          <span className="code-keyword">const</span> agent = <span className="code-keyword">await</span> orchestrator.<span className="code-function">spawn</span>(<span className="code-string">&apos;coder&apos;</span>,{" {"}{"\n"}
          {"  "}story: <span className="code-string">&apos;INK-042&apos;</span>,{"\n"}
          {"  "}maxTokens: <span className="code-number">50_000</span>,{"\n"}
          {"}"});
        </pre>
        <div className="code-widget-desc">Dark background. Red accent bar. Language tag. No rounded corners.</div>
      </div>

      <div className="code-widget code-widget--terminal">
        <div className="code-widget-header">
          <span className="code-widget-title">TERMINAL</span>
          <span className="code-widget-badge code-widget-badge--cli">CLI</span>
        </div>
        <div className="code-widget-dots">
          <span className="code-dot code-dot--red" />
          <span className="code-dot code-dot--yellow" />
          <span className="code-dot code-dot--green" />
          <span className="code-widget-filename">terminal</span>
          <span className="code-widget-badge code-widget-badge--lang">SH</span>
        </div>
        <pre className="code-widget-body">
          <span className="code-prompt">$</span> noizu deploy --target vercel{"\n"}
          <span className="code-output">[deploy] Building project...</span>{"\n"}
          <span className="code-output">[deploy] Running tests... 14/14 passed</span>{"\n"}
          <span className="code-output">[deploy] Pushing to Vercel...</span>{"\n"}
          <span className="code-success">&gt; Deployed successfully</span>
        </pre>
        <div className="code-widget-desc">Terminal output with timestamps, agent names, and status colors.</div>
      </div>
    </div>
  );
}

function SwissGeometricElements() {
  return (
    <>
      <h3 className="effects-subsection-title">GEOMETRIC ELEMENTS — BAUHAUS VOCABULARY</h3>
      <div className="shapes-grid" style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(160px, 1fr))", gap: "var(--space-2, 16px)", marginTop: "var(--space-3, 24px)" }}>
        <div style={{ border: "2px solid var(--black, #000)", padding: "var(--space-4, 32px) var(--space-2, 16px)", textAlign: "center", display: "flex", flexDirection: "column", alignItems: "center", gap: "var(--space-2, 16px)", minHeight: 140, justifyContent: "center" }}>
          <div style={{ width: 60, height: 60, borderRadius: "50%", background: "var(--red, #e20613)" }} />
          <div style={{ fontFamily: "var(--font-mono)", fontSize: 9, fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.1em", color: "var(--gray-500, #757575)" }}>CIRCLE / RED / ACTION</div>
        </div>
        <div style={{ border: "2px solid var(--black, #000)", padding: "var(--space-4, 32px) var(--space-2, 16px)", textAlign: "center", display: "flex", flexDirection: "column", alignItems: "center", gap: "var(--space-2, 16px)", minHeight: 140, justifyContent: "center" }}>
          <div style={{ width: 60, height: 60, background: "var(--blue, #0047ab)" }} />
          <div style={{ fontFamily: "var(--font-mono)", fontSize: 9, fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.1em", color: "var(--gray-500, #757575)" }}>SQUARE / BLUE / STRUCTURE</div>
        </div>
        <div style={{ border: "2px solid var(--black, #000)", padding: "var(--space-4, 32px) var(--space-2, 16px)", textAlign: "center", display: "flex", flexDirection: "column", alignItems: "center", gap: "var(--space-2, 16px)", minHeight: 140, justifyContent: "center" }}>
          <div style={{ width: 0, height: 0, borderLeft: "35px solid transparent", borderRight: "35px solid transparent", borderBottom: "60px solid var(--yellow, #f5c518)" }} />
          <div style={{ fontFamily: "var(--font-mono)", fontSize: 9, fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.1em", color: "var(--gray-500, #757575)" }}>TRIANGLE / YELLOW / ATTENTION</div>
        </div>
        <div style={{ border: "2px solid var(--black, #000)", padding: "var(--space-4, 32px) var(--space-2, 16px)", textAlign: "center", display: "flex", flexDirection: "column", alignItems: "center", gap: "var(--space-2, 16px)", minHeight: 140, justifyContent: "center" }}>
          <div style={{ width: "100%", height: 20, background: "linear-gradient(90deg, var(--red, #e20613) 33.33%, var(--blue, #0047ab) 33.33%, var(--blue, #0047ab) 66.67%, var(--yellow, #f5c518) 66.67%)" }} />
          <div style={{ fontFamily: "var(--font-mono)", fontSize: 9, fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.1em", color: "var(--gray-500, #757575)" }}>COLOR BAR / BRAND SIGNATURE</div>
        </div>
        <div style={{ border: "2px solid var(--black, #000)", padding: "var(--space-4, 32px) var(--space-2, 16px)", textAlign: "center", display: "flex", flexDirection: "column", alignItems: "center", gap: "var(--space-2, 16px)", minHeight: 140, justifyContent: "center" }}>
          <div style={{ display: "grid", gridTemplateColumns: "2fr 1fr", gridTemplateRows: "1fr 1fr", gap: 3, width: 80, height: 60 }}>
            <div style={{ background: "var(--black, #000)", gridRow: "span 2" }} />
            <div style={{ background: "var(--red, #e20613)" }} />
            <div style={{ background: "var(--blue, #0047ab)" }} />
          </div>
          <div style={{ fontFamily: "var(--font-mono)", fontSize: 9, fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.1em", color: "var(--gray-500, #757575)" }}>GRID COMPOSITION</div>
        </div>
        <div style={{ border: "2px solid var(--black, #000)", padding: "var(--space-4, 32px) var(--space-2, 16px)", textAlign: "center", display: "flex", flexDirection: "column", alignItems: "center", gap: "var(--space-2, 16px)", minHeight: 140, justifyContent: "center" }}>
          <div style={{ display: "grid", gridTemplateColumns: "3fr 1fr 2fr", gridTemplateRows: "2fr 1fr 1fr", gap: 3, width: 100, height: 70, background: "var(--black, #000)" }}>
            <div style={{ background: "var(--red, #e20613)", gridRow: "span 2" }} />
            <div style={{ background: "var(--white, #fff)" }} />
            <div style={{ background: "var(--white, #fff)" }} />
            <div style={{ background: "var(--blue, #0047ab)" }} />
            <div style={{ background: "var(--white, #fff)" }} />
            <div style={{ background: "var(--yellow, #f5c518)" }} />
          </div>
          <div style={{ fontFamily: "var(--font-mono)", fontSize: 9, fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.1em", color: "var(--gray-500, #757575)" }}>MONDRIAN LAYOUT</div>
        </div>
      </div>
    </>
  );
}

function SwissProjectComponents() {
  return (
    <>
      <SwissCodeWidgets />
      <SwissGeometricElements />
    </>
  );
}

/* ---------- Agent Dashboard (shared structure, themed via CSS) ---------- */

function AgentDashboard() {
  return (
    <div className="agent-dashboard">
      <div className="dashboard-panel dashboard-panel--stories">
        <div className="dashboard-panel-title">Stories</div>
        <ul className="story-list">
          <li className="story-item story-item--done"><span className="story-id">INK-040</span> Token audit</li>
          <li className="story-item story-item--done"><span className="story-id">INK-041</span> Breath keyframes</li>
          <li className="story-item story-item--active"><span className="story-id">INK-042</span> Dashboard grid</li>
          <li className="story-item story-item--queued"><span className="story-id">INK-043</span> A11y pass</li>
          <li className="story-item story-item--queued"><span className="story-id">INK-044</span> Responsive</li>
        </ul>
      </div>

      <div className="dashboard-panel dashboard-panel--output">
        <div className="dashboard-panel-title">Live Output</div>
        <div className="live-output">
          <div className="output-line"><span className="output-ts">14:02:01</span> token scan complete — 42 vars</div>
          <div className="output-line"><span className="output-ts">14:02:03</span> breath keyframe injected</div>
          <div className="output-line"><span className="output-ts">14:02:04</span> dashboard grid rendered</div>
          <div className="output-line output-line--active"><span className="output-ts">14:02:05</span> awaiting acceptance...</div>
        </div>
        <div className="agent-controls">
          <button className="agent-btn" type="button">Pause</button>
          <button className="agent-btn" type="button">Step</button>
          <button className="agent-btn agent-btn--primary" type="button">Accept</button>
        </div>
      </div>

      <div className="dashboard-panel dashboard-panel--criteria">
        <div className="dashboard-panel-title">Acceptance Criteria</div>
        <ul className="criteria-list">
          <li className="criteria-item criteria-item--done">Effects grid renders 6 cards</li>
          <li className="criteria-item criteria-item--done">Animations respect prefers-reduced-motion</li>
          <li className="criteria-item criteria-item--done">Dashboard 3-panel layout</li>
          <li className="criteria-item criteria-item--pending">Responsive below 900px</li>
          <li className="criteria-item criteria-item--pending">Screen reader labels</li>
        </ul>
      </div>
    </div>
  );
}

/* ---------- Exported section ---------- */

export function InkEffectsSection({ number, id, title, desc }: SectionProps) {
  const { activeSlug } = useThemeConfig();

  const effects = activeSlug === "cyberpunk"
    ? <CyberpunkEffects />
    : activeSlug === "swiss"
    ? <SwissProjectComponents />
    : <SumiEffects />;

  return (
    <CollapsibleSection number={number} id={id} title={title} desc={desc} defaultOpen={true}>
      {effects}
      <AgentDashboard />
    </CollapsibleSection>
  );
}
