"use client";

import { useThemeConfig } from "@styleguide-engine/components/ThemeConfigContext";
import { CollapsibleSection } from "@styleguide-engine/components/CollapsibleSection";
import { SubsectionTabs } from "@styleguide-engine/components/SubsectionTabs";
import type { SectionProps } from "./section-props";

/* ---------- tiny sub-components (screen-local) ---------- */

function ScreenFrame({ url, label, nav, children }: { url: string; label: string; nav?: React.ReactNode; children: React.ReactNode }) {
  return (
    <div className="screen-frame">
      <div className="screen-titlebar">
        <span className="screen-dot" />
        <span className="screen-dot" />
        <span className="screen-dot" />
        <span className="screen-url">{url}</span>
        <span className="screen-label">{label}</span>
      </div>
      <div className="screen-body">
        <div className="content">
          {nav}
          {children}
        </div>
      </div>
    </div>
  );
}

function BrushDivider() {
  return <div className="hr section" />;
}

/* ================================================================
   Sumi-e Screens
   ================================================================ */

function LandingScreen() {
  return (
    <ScreenFrame url="noizu.ink" label="Landing — Ink Wash Hero" nav={
      <nav className="shell-navbar">
        <div className="shell-navbar-brand">noizu.ink</div>
        <div className="shell-navbar-links">
          <span className="shell-navbar-link">Features</span>
          <span className="shell-navbar-link">Pricing</span>
          <span className="shell-navbar-link">Docs</span>
          <span className="shell-navbar-link">Sign In</span>
        </div>
      </nav>
    }>
        {/* hero */}
        <div className="screen-hero">
          <h2 className="typography-display">
            Put your pen down.<br />
            Let the machines work.
          </h2>
          <p className="typography-body">
            AI agents write code, run tests, and submit diffs. You review. Each stroke deliberate. Each absence chosen.
          </p>
          <div className="btn-group">
            <button className="btn">Begin</button>
            <button className="btn btn-outline">Learn More</button>
          </div>
        </div>

        <BrushDivider />

        {/* feature cards */}
        <div className="card-grid" style={{ gridTemplateColumns: "repeat(3, 1fr)" }}>
          <div className="card">
            <div className="card-body bg-washi-cool">
              <h3 className="card-title">Agent Pipeline</h3>
              <p>Sketch → Draft → Ink → Publish. Four phases, like four seasons.</p>
            </div>
          </div>
          <div className="card">
            <div className="card-body bg-washi-cool">
              <h3 className="card-title">Test-Driven</h3>
              <p>Tests first. Code to pass. Every diff carries proof.</p>
            </div>
          </div>
          <div className="card">
            <div className="card-body bg-washi-cool">
              <h3 className="card-title">Live Review</h3>
              <p>Watch. Approve. The brush knows when to stop.</p>
            </div>
          </div>
        </div>
    </ScreenFrame>
  );
}

function SettingsScreen() {
  return (
    <ScreenFrame url="noizu.ink/settings" label="Settings — Paper Surface" nav={
      <div className="settings-header">
        <span className="shell-navbar-brand">noizu.ink</span>
        <span className="badge">Settings</span>
      </div>
    }>
        {/* two-col layout */}
        <div className="settings-layout">
          {/* sidebar */}
          <aside className="screen-sidebar">
            <span className="screen-sidebar-item active">General</span>
            <span className="screen-sidebar-item">Team</span>
            <span className="screen-sidebar-item">API Keys</span>
            <span className="screen-sidebar-item">Agents</span>
          </aside>

          {/* content */}
          <div className="settings-content">
            <label className="field-label">Project Name</label>
            <div className="field-input">noizu-ink</div>

            <label className="field-label">Auto-deploy</label>
            <div className="hui switch-wrap" data-checked>
              <div className="switch-track">
                <div className="switch-thumb" />
              </div>
            </div>

            <div className="agent-controls">
              <button className="btn">Save</button>
              <button className="btn btn-outline">Cancel</button>
            </div>
          </div>
        </div>
    </ScreenFrame>
  );
}

function DashboardScreen() {
  return (
    <ScreenFrame url="noizu.ink/dashboard" label="Dashboard — Active Sprint" nav={
      <nav className="shell-navbar">
        <div className="shell-navbar-brand">noizu.ink</div>
        <div className="shell-navbar-links">
          <span className="shell-navbar-link">Dashboard</span>
          <span className="shell-navbar-link">Stories</span>
          <span className="shell-navbar-link">Agents</span>
          <span className="shell-navbar-link">Settings</span>
        </div>
      </nav>
    }>
        <div className="agent-dashboard">
          {/* backlog */}
          <div className="dashboard-panel">
            <div className="typography-label">Backlog</div>
            <div className="story-item story-item--done">
              <span className="tag">INK-038</span>
              <span>Auth middleware</span>
            </div>
            <div className="story-item story-item--done">
              <span className="tag">INK-039</span>
              <span>Token refresh</span>
            </div>
            <div className="story-item story-item--active">
              <span className="tag">INK-040</span>
              <span>Rate limiter</span>
              <span className="status-dot online" />
            </div>
            <div className="story-item story-item--queued">
              <span className="tag">INK-041</span>
              <span>Error boundary</span>
            </div>
          </div>

          {/* output */}
          <div className="dashboard-panel dashboard-panel--output">
            <div className="typography-label">Live Output</div>
            <div className="code-block">
              <div><span className="output-ts">14:32:01</span> Spawning coder agent...</div>
              <div><span className="output-ts">14:32:03</span> Reading INK-040 spec</div>
              <div><span className="output-ts">14:32:08</span> Generating rate-limiter middleware</div>
              <div><span className="output-ts">14:32:14</span> Running test suite (12 cases)</div>
              <div className="output-line output-line--active"><span className="output-ts">14:32:18</span> 11/12 passing — fixing edge case</div>
            </div>
          </div>

          {/* criteria */}
          <div className="dashboard-panel">
            <div className="typography-label">Criteria</div>
            <div className="criteria-item criteria-item--done">Token bucket algorithm</div>
            <div className="criteria-item criteria-item--done">Per-route configuration</div>
            <div className="criteria-item criteria-item--done">Redis backing store</div>
            <div className="criteria-item criteria-item--pending">Retry-After headers</div>
            <div className="criteria-item criteria-item--pending">Dashboard metrics</div>
          </div>
        </div>
    </ScreenFrame>
  );
}

/* ================================================================
   Cyberpunk Screens
   ================================================================ */

function CyberpunkLandingScreen() {
  return (
    <ScreenFrame url="noizu.ink" label="Landing — Neon Hero" nav={
      <nav className="shell-navbar">
        <div className="shell-navbar-brand">noizu.ink</div>
        <div className="shell-navbar-links">
          <span className="shell-navbar-link">Features</span>
          <span className="shell-navbar-link">Pricing</span>
          <span className="shell-navbar-link">Docs</span>
          <span className="shell-navbar-link">Sign In</span>
        </div>
      </nav>
    }>
        {/* hero */}
        <div className="screen-hero">
          <h2 className="typography-display">
            SHIP PRODUCTS<br />
            NOT TICKETS
          </h2>
          <p className="typography-body">
            AI agents draft, test, and deploy. You approve. Zero tickets. Zero standups. Just shipped code.
          </p>
          <div className="btn-group">
            <button className="btn">INITIALIZE</button>
            <button className="btn btn-outline">DOCS</button>
          </div>
        </div>

        <BrushDivider />

        {/* feature cards */}
        <div className="card-grid" style={{ gridTemplateColumns: "repeat(3, 1fr)" }}>
          <div className="card">
            <div className="card-body">
              <h3 className="card-title">Agent Pipeline</h3>
              <p>Sketch → Draft → Build → Ship. Automated end to end.</p>
            </div>
          </div>
          <div className="card">
            <div className="card-body">
              <h3 className="card-title">Test-Driven</h3>
              <p>Every commit tested. Every merge proven. Zero regressions.</p>
            </div>
          </div>
          <div className="card">
            <div className="card-body">
              <h3 className="card-title">Live Review</h3>
              <p>Watch agents work. Approve diffs. Ship with confidence.</p>
            </div>
          </div>
        </div>
    </ScreenFrame>
  );
}

function CyberpunkDashboardScreen() {
  return (
    <ScreenFrame url="noizu.ink/dashboard" label="Dashboard — Active Sprint" nav={
      <nav className="shell-navbar">
        <div className="shell-navbar-brand">noizu.ink</div>
        <div className="shell-navbar-links">
          <span className="shell-navbar-link">Dashboard</span>
          <span className="shell-navbar-link">Stories</span>
          <span className="shell-navbar-link">Agents</span>
          <span className="shell-navbar-link">Settings</span>
        </div>
      </nav>
    }>
        <div className="agent-dashboard">
          {/* backlog */}
          <div className="dashboard-panel">
            <div className="typography-label">Stories</div>
            <div className="story-item story-item--done">
              <span className="tag">INK-040</span>
              <span>Token audit</span>
            </div>
            <div className="story-item story-item--done">
              <span className="tag">INK-041</span>
              <span>Breath keyframes</span>
            </div>
            <div className="story-item story-item--active">
              <span className="tag">INK-042</span>
              <span>Dashboard grid</span>
              <span className="status-dot online" />
            </div>
            <div className="story-item story-item--queued">
              <span className="tag">INK-043</span>
              <span>A11y pass</span>
            </div>
          </div>

          {/* output */}
          <div className="dashboard-panel dashboard-panel--output">
            <div className="typography-label">Live Output</div>
            <div className="code-block">
              <div><span className="output-ts">14:02:01</span> token scan complete — 42 vars</div>
              <div><span className="output-ts">14:02:03</span> breath keyframe injected</div>
              <div><span className="output-ts">14:02:04</span> dashboard grid rendered</div>
              <div className="output-line output-line--active"><span className="output-ts">14:02:05</span> awaiting acceptance...</div>
            </div>
          </div>

          {/* criteria */}
          <div className="dashboard-panel">
            <div className="typography-label">Acceptance Criteria</div>
            <div className="criteria-item criteria-item--done">Effects grid renders 6 cards</div>
            <div className="criteria-item criteria-item--done">Animations respect prefers-reduced-motion</div>
            <div className="criteria-item criteria-item--done">Dashboard 3-panel layout</div>
            <div className="criteria-item criteria-item--pending">Responsive below 900px</div>
            <div className="criteria-item criteria-item--pending">Screen reader labels</div>
          </div>
        </div>
    </ScreenFrame>
  );
}

function CyberpunkSettingsScreen() {
  return (
    <ScreenFrame url="noizu.ink/settings" label="Settings — Neon Interface" nav={
      <div className="settings-header">
        <span className="shell-navbar-brand">noizu.ink</span>
        <span className="badge">Settings</span>
      </div>
    }>
        {/* two-col layout */}
        <div className="settings-layout">
          {/* sidebar */}
          <aside className="screen-sidebar">
            <span className="screen-sidebar-item active">General</span>
            <span className="screen-sidebar-item">Agents</span>
            <span className="screen-sidebar-item">API Keys</span>
            <span className="screen-sidebar-item">Deploys</span>
          </aside>

          {/* content */}
          <div className="settings-content">
            <label className="field-label">Project Name</label>
            <div className="field-input">noizu-ink</div>

            <label className="field-label">Auto-deploy</label>
            <div className="hui switch-wrap" data-checked>
              <div className="switch-track">
                <div className="switch-thumb" />
              </div>
            </div>

            <label className="field-label">Agent Model</label>
            <div className="field-input">claude-opus-4-6</div>

            <div className="agent-controls">
              <button className="btn">Save</button>
              <button className="btn btn-outline">Cancel</button>
            </div>
          </div>
        </div>
    </ScreenFrame>
  );
}

/* ================================================================
   Swiss Screens
   ================================================================ */

function SwissLandingScreen() {
  return (
    <ScreenFrame url="noizu.ink" label="Landing — Hero + CTA" nav={
      <nav className="shell-navbar">
        <div className="shell-navbar-brand">noizu.ink</div>
        <div className="shell-navbar-links">
          <span className="shell-navbar-link">Features</span>
          <span className="shell-navbar-link">Pricing</span>
          <span className="shell-navbar-link">Docs</span>
          <span className="shell-navbar-link" style={{ fontWeight: 700 }}>Sign In</span>
        </div>
      </nav>
    }>
        <div className="screen-hero">
          <h2 className="typography-display" style={{ fontSize: 40, fontWeight: 700, lineHeight: 1.05, letterSpacing: "-0.03em" }}>
            Ship products<span style={{ color: "var(--red, #e20613)" }}>.</span><br />
            Not tickets<span style={{ color: "var(--red, #e20613)" }}>.</span>
          </h2>
          <p style={{ fontSize: 15, lineHeight: 1.6, color: "var(--gray-700, #424242)", maxWidth: 480, marginTop: "var(--space-2)" }}>
            AI agents write code, run tests, and submit diffs. You review and approve. From PRD to production in minutes, not sprints.
          </p>
          <div className="btn-group" style={{ marginTop: "var(--space-3)" }}>
            <button className="btn" style={{ background: "var(--black)", color: "var(--white)", border: "2px solid var(--black)", padding: "14px 32px", fontSize: 15, fontWeight: 600 }}>Start Building</button>
            <button className="btn btn-outline" style={{ border: "2px solid var(--black)", padding: "14px 32px", fontSize: 15, fontWeight: 600 }}>Watch Demo</button>
          </div>
        </div>

        <div style={{ display: "flex", height: 6, margin: "var(--space-4) 0" }}>
          <span style={{ flex: 3, background: "var(--red, #e20613)" }} />
          <span style={{ flex: 2, background: "var(--blue, #0047ab)" }} />
          <span style={{ flex: 3, background: "var(--yellow, #f5c518)" }} />
        </div>

        <div className="card-grid" style={{ gridTemplateColumns: "repeat(3, 1fr)" }}>
          <div className="card">
            <div className="card-body">
              <h3 className="card-title" style={{ color: "var(--black, #000)" }}>Agent Pipeline</h3>
              <p style={{ color: "var(--gray-700, #424242)" }}>Sketch → Draft → Ink → Publish. Four phases, fully automated. You steer; agents build.</p>
            </div>
          </div>
          <div className="card" style={{ borderTop: "6px solid var(--red, #e20613)" }}>
            <div className="card-body">
              <h3 className="card-title" style={{ color: "var(--black, #000)" }}>Test-Driven</h3>
              <p style={{ color: "var(--gray-700, #424242)" }}>Tests written first. Code generated to pass. Every diff ships with proof it works.</p>
            </div>
          </div>
          <div className="card">
            <div className="card-body">
              <h3 className="card-title" style={{ color: "var(--black, #000)" }}>Live Review</h3>
              <p style={{ color: "var(--gray-700, #424242)" }}>Watch agents work in real time. Approve, request changes, or rollback with one click.</p>
            </div>
          </div>
        </div>
    </ScreenFrame>
  );
}

function SwissDashboardScreen() {
  return (
    <ScreenFrame url="noizu.ink/dashboard" label="Dashboard — Active Sprint" nav={
      <nav className="shell-navbar">
        <div className="shell-navbar-brand">noizu.ink</div>
        <div className="shell-navbar-links">
          <span className="shell-navbar-link">Dashboard</span>
          <span className="shell-navbar-link">Stories</span>
          <span className="shell-navbar-link">Agents</span>
          <span className="shell-navbar-link">Settings</span>
        </div>
      </nav>
    }>
        <div className="agent-dashboard">
          <div className="dashboard-panel">
            <div className="typography-label">Backlog</div>
            <div className="story-item story-item--done">
              <span className="tag">INK-040</span>
              <span>Auth middleware</span>
            </div>
            <div className="story-item story-item--done">
              <span className="tag">INK-041</span>
              <span>Token refresh</span>
            </div>
            <div className="story-item story-item--active">
              <span className="tag">INK-042</span>
              <span>Rate limiter</span>
              <span className="status-dot online" />
            </div>
            <div className="story-item story-item--queued">
              <span className="tag">INK-043</span>
              <span>Error boundary</span>
            </div>
          </div>

          <div className="dashboard-panel dashboard-panel--output">
            <div className="typography-label">Live Output</div>
            <div className="code-block">
              <div><span className="output-ts">14:32:01</span> Spawning coder agent...</div>
              <div><span className="output-ts">14:32:03</span> Reading INK-042 spec</div>
              <div><span className="output-ts">14:32:08</span> Generating rate-limiter middleware</div>
              <div><span className="output-ts">14:32:14</span> Running test suite (12 cases)</div>
              <div className="output-line output-line--active"><span className="output-ts">14:32:18</span> 11/12 passing — fixing edge case</div>
            </div>
          </div>

          <div className="dashboard-panel">
            <div className="typography-label">Criteria</div>
            <div className="criteria-item criteria-item--done">Token bucket algorithm</div>
            <div className="criteria-item criteria-item--done">Per-route configuration</div>
            <div className="criteria-item criteria-item--done">Redis backing store</div>
            <div className="criteria-item criteria-item--pending">Retry-After headers</div>
            <div className="criteria-item criteria-item--pending">Dashboard metrics</div>
          </div>
        </div>
    </ScreenFrame>
  );
}

function SwissSettingsScreen() {
  return (
    <ScreenFrame url="noizu.ink/settings" label="Settings — Configuration" nav={
      <div className="settings-header">
        <span className="shell-navbar-brand">noizu.ink</span>
        <span className="badge">Settings</span>
      </div>
    }>
        <div className="settings-layout">
          <aside className="screen-sidebar">
            <span className="screen-sidebar-item active">General</span>
            <span className="screen-sidebar-item">Team</span>
            <span className="screen-sidebar-item">API Keys</span>
            <span className="screen-sidebar-item">Agents</span>
          </aside>

          <div className="settings-content">
            <label className="field-label">Project Name</label>
            <div className="field-input">noizu-ink</div>

            <label className="field-label">Auto-deploy</label>
            <div className="hui switch-wrap" data-checked>
              <div className="switch-track">
                <div className="switch-thumb" />
              </div>
            </div>

            <label className="field-label">Agent Model</label>
            <div className="field-input">claude-opus-4-6</div>

            <div className="agent-controls">
              <button className="btn" style={{ background: "var(--black)", color: "var(--white)" }}>Save</button>
              <button className="btn btn-outline">Cancel</button>
            </div>
          </div>
        </div>
    </ScreenFrame>
  );
}

/* ---------- Exported section ---------- */

export function ScreensSection({ number, id, title, desc }: SectionProps) {
  const { activeSlug } = useThemeConfig();

  const tabs = activeSlug === "cyberpunk"
    ? [
        { id: "screen-landing",   title: "Landing",   content: <CyberpunkLandingScreen /> },
        { id: "screen-dashboard", title: "Dashboard", content: <CyberpunkDashboardScreen /> },
        { id: "screen-settings",  title: "Settings",  content: <CyberpunkSettingsScreen /> },
      ]
    : activeSlug === "swiss"
    ? [
        { id: "screen-landing",   title: "Landing",   content: <SwissLandingScreen /> },
        { id: "screen-dashboard", title: "Dashboard", content: <SwissDashboardScreen /> },
        { id: "screen-settings",  title: "Settings",  content: <SwissSettingsScreen /> },
      ]
    : [
        { id: "screen-landing",   title: "Landing",   content: <LandingScreen /> },
        { id: "screen-dashboard", title: "Dashboard", content: <DashboardScreen /> },
        { id: "screen-settings",  title: "Settings",  content: <SettingsScreen /> },
      ];

  return (
    <CollapsibleSection number={number} id={id} title={title} desc={desc} defaultOpen={true}>
      <SubsectionTabs tabs={tabs} />
    </CollapsibleSection>
  );
}
