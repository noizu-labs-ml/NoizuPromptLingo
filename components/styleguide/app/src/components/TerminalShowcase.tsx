"use client";

import { Subsection } from "./pkg/subsection";

function TerminalDots() {
  return (
    <span className="terminal-dots">
      <span className="terminal-dot terminal-dot-close" />
      <span className="terminal-dot terminal-dot-minimize" />
      <span className="terminal-dot terminal-dot-maximize" />
    </span>
  );
}

function TerminalWindow({ title, children }: { title?: string; children: React.ReactNode }) {
  return (
    <div className="terminal-window">
      <div className="terminal-title-bar">
        <TerminalDots />
        <span className="terminal-title">{title ?? "Terminal"}</span>
      </div>
      <div className="terminal-body">
        {children}
      </div>
    </div>
  );
}

function Prompt({ cmd }: { cmd: string }) {
  return (
    <div className="terminal-row">
      <span className="terminal-prompt">❯</span>
      <span className="terminal-command">{cmd}</span>
    </div>
  );
}

function Output({ children, variant = "default" }: {
  children: React.ReactNode;
  variant?: "default" | "success" | "error" | "warning";
}) {
  const cls =
    variant === "success" ? "terminal-output terminal-success" :
    variant === "error"   ? "terminal-output terminal-error" :
    variant === "warning" ? "terminal-output terminal-warning" :
    "terminal-output";
  return <div className={cls}>{children}</div>;
}

function BasicSessionDemo() {
  return (
    <TerminalWindow title="bash — 80×24">
      <Prompt cmd="npm install" />
      <Output>added 312 packages, and audited 313 packages in 4s</Output>
      <Output variant="success">found 0 vulnerabilities</Output>

      <Prompt cmd="npm run build" />
      <Output>{"▶ "}<span style={{ color: "var(--terminal-command)" }}>build</span> — starting production build…</Output>
      <Output variant="success">✓ compiled successfully in 2.1s</Output>
      <Output>  dist/index.js    42 kB</Output>
      <Output>  dist/index.css    8 kB</Output>

      <Prompt cmd="npm run test" />
      <Output variant="error">✗ FAIL src/utils/parse.test.ts</Output>
      <Output variant="error">  Expected: 42 — Received: undefined</Output>
      <Output variant="warning">  ⚠ 1 snapshot obsolete</Output>
    </TerminalWindow>
  );
}

function StatusVariantsDemo() {
  return (
    <TerminalWindow title="deploy.sh">
      <Prompt cmd="./deploy.sh --env production" />
      <Output>Connecting to remote…</Output>
      <Output variant="success">✓ SSH connection established</Output>
      <Output>Running pre-flight checks…</Output>
      <Output variant="warning">⚠ Disk usage at 78% — consider cleanup</Output>
      <Output variant="success">✓ All checks passed</Output>
      <Output>Pushing build artifacts…</Output>
      <Output variant="error">✗ Upload failed: connection reset by peer</Output>
      <Output variant="warning">↩ Retrying (1/3)…</Output>
      <Output variant="success">✓ Deploy complete — v2.4.1 live</Output>
    </TerminalWindow>
  );
}

export function TerminalShowcase() {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-3)" }}>
      <Subsection id="terminal-session" title="Terminal Session">
        <BasicSessionDemo />
      </Subsection>

      <Subsection id="terminal-status" title="Status Output Variants">
        <StatusVariantsDemo />
      </Subsection>
    </div>
  );
}
