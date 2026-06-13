"use client";

import { useState, useEffect } from "react";
import type { SimpleShellLayout, PageLayoutChrome } from "@styleguide-engine/lib/types";

interface Props {
  shellLayouts: SimpleShellLayout[];
}

function MiniShell({ chrome }: { chrome?: PageLayoutChrome }) {
  const W = 36;
  const H = 24;
  const navH = chrome?.navbar ? 5 : 0;
  const footH = chrome?.footer ? 3 : 0;
  const sideW = chrome?.sidebar ? 8 : 0;
  const asideW = chrome?.aside ? 8 : 0;
  const midH = H - navH - footH;
  const contentW = W - sideW - asideW;

  return (
    <svg width={W} height={H} viewBox={`0 0 ${W} ${H}`} style={{ display: "block" }}>
      <rect x={0} y={0} width={W} height={H} fill="var(--surface-alt)" rx={2} />
      {chrome?.navbar && <rect x={0} y={0} width={W} height={navH} fill="var(--border-strong)" rx={2} />}
      {chrome?.sidebar && <rect x={0} y={navH} width={sideW} height={midH} fill="var(--border)" />}
      <rect x={sideW} y={navH} width={contentW} height={midH} fill="var(--surface-alt)" />
      {chrome?.aside && <rect x={sideW + contentW} y={navH} width={asideW} height={midH} fill="var(--border)" />}
      {chrome?.footer && <rect x={0} y={navH + midH} width={W} height={footH} fill="var(--border)" rx={1} />}
      <rect x={0} y={0} width={W} height={H} fill="none" stroke="var(--border)" strokeWidth={1} rx={2} />
    </svg>
  );
}

export function ShellLayoutSummary({ shellLayouts }: Props) {
  const [active, setActive] = useState<string | null>(null);

  const activate = (name: string | null) => {
    setActive(name);
    window.dispatchEvent(new CustomEvent("shell-change", { detail: name }));
  };

  useEffect(() => {
    const handler = (e: Event) => {
      setActive((e as CustomEvent<string>).detail || null);
    };
    window.addEventListener("shell-change", handler);
    return () => window.removeEventListener("shell-change", handler);
  }, []);

  return (
    <div style={{ display: "flex", flexWrap: "wrap", gap: "var(--space-1)", padding: "var(--space-2) 0", justifyContent: "center" }}>
      {shellLayouts.map((shell) => {
        const isActive = active === shell.name;
        return (
          <button
            key={shell.name}
            onClick={() => activate(isActive ? null : shell.name)}
            className={`btn btn-sm primary${isActive ? " btn-selected" : ""}`}
            style={{ display: "flex", alignItems: "center", gap: "var(--space-1)" }}
          >
            <MiniShell chrome={shell.chrome} />
            <span>{shell.title}</span>
          </button>
        );
      })}
    </div>
  );
}
