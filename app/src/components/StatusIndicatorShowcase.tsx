"use client";

import type { SimpleDesignSection, DesignComponent } from "@styleguide-engine/lib/types";
import { FormValidationDemo } from "@styleguide-engine/components/demos/FormValidationDemo";
import { ToastsDemo } from "@styleguide-engine/components/demos/ToastsDemo";
import { PreviewCode } from "./pkg/preview-code";
import { SubsectionTabs } from "./SubsectionTabs";

interface Props {
  section: SimpleDesignSection;
}

// ─── Visual demos ───

function BadgesDemo() {
  return (
    <div className="flex flex-wrap gap-[var(--space-1)] items-center">
      <span className="badge success">Success</span>
      <span className="badge warning">Warning</span>
      <span className="badge error">Error</span>
      <span className="badge info">Info</span>
      <span className="badge default">Default</span>
      <span className="badge muted">Draft</span>
      <span className="badge count error">4</span>
      <span className="badge count info">99+</span>
    </div>
  );
}

function AlertsDemo() {
  return (
    <div className="flex flex-col gap-[var(--space-1)]">
      <div className="alert success">
        <div className="alert-title">Changes saved</div>
        <div className="alert-body">Your settings have been updated successfully.</div>
      </div>
      <div className="alert warning">
        <div className="alert-title">API rate limit approaching</div>
        <div className="alert-body">You&apos;ve used 80% of your monthly quota.</div>
      </div>
      <div className="alert error">
        <div className="alert-title">Validation failed</div>
        <div className="alert-body">Please fix the 3 errors below before submitting.</div>
      </div>
      <div className="alert info">
        <div className="alert-title">New version available</div>
        <div className="alert-body">Version 2.4.0 includes performance improvements.</div>
      </div>
    </div>
  );
}


function ProgressDemo() {
  return (
    <div className="flex flex-col gap-[var(--space-1)] max-w-[400px]">
      <div>
        <div className="text-xs font-mono text-[var(--text-muted)] mb-[var(--space-half)]">Determinate — 68%</div>
        <div className="progress"><div className="progress-bar info" style={{ width: "68%" }} /></div>
      </div>
      <div>
        <div className="text-xs font-mono text-[var(--text-muted)] mb-[var(--space-half)]">Complete</div>
        <div className="progress"><div className="progress-bar success" style={{ width: "100%" }} /></div>
      </div>
      <div>
        <div className="text-xs font-mono text-[var(--text-muted)] mb-[var(--space-half)]">Warning — 82%</div>
        <div className="progress lg"><div className="progress-bar warning" style={{ width: "82%" }} /></div>
      </div>
    </div>
  );
}

function StatusDotsDemo() {
  const states = [
    { cls: "status-dot online", label: "Online", desc: "Available" },
    { cls: "status-dot away", label: "Away", desc: "Idle 10m" },
    { cls: "status-dot offline", label: "Offline", desc: "Disconnected" },
    { cls: "status-dot error", label: "Error", desc: "Auth failed" },
  ];
  return (
    <div className="flex flex-col gap-[var(--space-1)]">
      {states.map((s) => (
        <div key={s.cls} className="status-dot-row">
          <span className={s.cls} />
          <span className="font-semibold text-sm">{s.label}</span>
          <span className="text-[var(--text-muted)] text-sm">— {s.desc}</span>
        </div>
      ))}
    </div>
  );
}

function TagsDemo() {
  return (
    <div className="flex flex-wrap gap-[var(--space-1)] items-center">
      <span className="tag success">published</span>
      <span className="tag warning">in-review</span>
      <span className="tag error">blocked</span>
      <span className="tag info">in-progress</span>
      <span className="tag default">draft</span>
      <span className="tag default">archived</span>
      <span className="tag info">v2.4</span>
    </div>
  );
}

// ─── Code strings ───

const DEMO_CODE: Record<string, string> = {
  badges: `<span class="badge success">Success</span>
<span class="badge warning">Warning</span>
<span class="badge error">Error</span>
<span class="badge info">Info</span>
<span class="badge default">Default</span>
<span class="badge muted">Draft</span>
<span class="badge count error">4</span>
<span class="badge count info">99+</span>`,

  alerts: `<div class="alert success">
  <div class="alert-title">Changes saved</div>
  <div class="alert-body">Your settings have been updated.</div>
</div>

<div class="alert error">
  <div class="alert-title">Validation failed</div>
  <div class="alert-body">Please fix the errors below.</div>
</div>`,

  toasts: `<div class="toast success">
  <div class="toast-dot"></div>
  <span>File uploaded successfully</span>
</div>

<div class="toast error">
  <div class="toast-dot"></div>
  <span>Connection lost — retrying…</span>
</div>`,

  progress: `<div class="progress">
  <div class="progress-bar info" style="width: 68%"></div>
</div>

<div class="progress lg">
  <div class="progress-bar warning" style="width: 82%"></div>
</div>`,

  "status-dots": `<div class="status-dot-row">
  <span class="status-dot online"></span>
  <span>Online</span>
</div>

<div class="status-dot-row">
  <span class="status-dot away"></span>
  <span>Away</span>
</div>`,

  tags: `<span class="tag success">published</span>
<span class="tag warning">in-review</span>
<span class="tag error">blocked</span>
<span class="tag info">in-progress</span>
<span class="tag default">draft</span>`,

  "form-validation": `<div class="field-group field-error">
  <label>Email</label>
  <input class="field-input" />
  <p class="field-error-message">Email is required</p>
</div>

<div class="field-group field-success">
  <label>Username</label>
  <input class="field-input" value="jsmith" />
  <p class="field-success-message">Username available</p>
</div>`,
};

const DEMOS: Record<string, React.ReactNode> = {
  badges: <BadgesDemo />,
  alerts: <AlertsDemo />,
  toasts: <ToastsDemo />,
  progress: <ProgressDemo />,
  "status-dots": <StatusDotsDemo />,
  tags: <TagsDemo />,
  "form-validation": <FormValidationDemo />,
};

// ─── Single indicator content ───

function IndicatorContent({ component }: { component: DesignComponent }) {
  const demo = DEMOS[component.name];
  const code = DEMO_CODE[component.name];

  return (
    <div className="flex flex-col gap-[var(--space-3)]" id={`status-${component.name}`}>
      <div className="flex flex-col gap-[var(--space-2)]">
        <PrincipleRow label="Principle" colorClass="text-principle" text={component.principle} />
        <PrincipleRow label="Approach"  colorClass="text-approach"  text={component.approach} />
        <PrincipleRow label="Why"       colorClass="text-why"       text={component.rationale} italic />
      </div>
      {demo && code ? (
        <PreviewCode html={code}>{demo}</PreviewCode>
      ) : demo ? (
        <div className="sg-demo-box">{demo}</div>
      ) : null}
    </div>
  );
}

function PrincipleRow({ label, colorClass, text, italic }: { label: string; colorClass: string; text: string; italic?: boolean }) {
  return (
    <div className="sg-principle-row">
      <div className={`sg-principle-label ${colorClass}`}>
        {label}
      </div>
      <p className={`sg-principle-text${italic ? " muted" : ""}`}>
        {text}
      </p>
    </div>
  );
}

// ─── Main component ───

export function StatusIndicatorShowcase({ section }: Props) {
  const tabs = section.components.map((c) => ({
    id: `status-${c.name}`,
    title: c.title,
    content: <IndicatorContent component={c} />,
  }));

  return (
    <div>
      <p className="sg-description">{section.description}</p>
      <SubsectionTabs tabs={tabs} />
    </div>
  );
}
