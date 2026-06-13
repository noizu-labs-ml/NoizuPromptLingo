"use client";

import { useState, useEffect } from "react";
import type { SimpleShellLayout, PageLayoutChrome, ShellZone } from "@styleguide-engine/lib/types";

interface Props {
  shellLayouts: SimpleShellLayout[];
}

// ─── Wireframe diagram (same as before) ───

function WireframeDiagram({ chrome, zones }: { chrome?: PageLayoutChrome; zones?: ShellZone[] }) {
  const W = 320;
  const H = 180;
  const navH  = chrome?.navbar  ? 18 : 0;
  const footH = chrome?.footer  ? 13 : 0;
  const sideW = chrome?.sidebar ? 32 : 0;
  const asideW= chrome?.aside   ? 38 : 0;
  const midH  = H - navH - footH;
  const contentW = W - sideW - asideW;

  const totalRatio = (zones || []).reduce((s, z) => s + (z.ratio ?? 1), 0) || 1;
  let zoneY = navH;
  const zoneRects = (zones || []).map((z) => {
    const h = Math.round(midH * ((z.ratio ?? 1) / totalRatio));
    const rect = { y: zoneY, h, zone: z };
    zoneY += h;
    return rect;
  });

  return (
    <svg viewBox={`0 0 ${W} ${H}`} style={{ display: "block", width: "100%", height: "auto", borderRadius: "var(--radius)" }}>
      <rect x={0} y={0} width={W} height={H} fill="#f5f5f5" />
      {zoneRects.map(({ y, h, zone }, i) => (
        <g key={i}>
          <rect x={sideW} y={y} width={contentW} height={h} fill={zone.background || "#fafafa"} opacity={0.85} />
          <text x={sideW + contentW / 2} y={y + h / 2 + 3} textAnchor="middle" fontSize={7}
            fill={zone.color || "#9e9e9e"} fontFamily="monospace" opacity={0.8}>{zone.label}</text>
        </g>
      ))}
      {!zones?.length && (
        <>
          <rect x={sideW} y={navH} width={contentW} height={midH} fill="#fafafa" />
          {[0.2, 0.38, 0.56, 0.72].map((f, i) => (
            <rect key={i} x={sideW + 8} y={navH + Math.round(midH * f)}
              width={i === 3 ? contentW * 0.5 : contentW - 16} height={3} rx={1} fill="#bdbdbd" opacity={0.6} />
          ))}
        </>
      )}
      {chrome?.navbar && (
        <>
          <rect x={0} y={0} width={W} height={navH} fill={chrome.navbar.background || "#212121"} />
          <text x={W / 2} y={navH - 4} textAnchor="middle" fontSize={7}
            fill={chrome.navbar.color || "#fff"} fontFamily="monospace">{chrome.navbar.label || "Nav"}</text>
        </>
      )}
      {chrome?.sidebar && (
        <>
          <rect x={0} y={navH} width={sideW} height={midH} fill={chrome.sidebar.background || "#e0e0e0"} />
          {[0.15, 0.28, 0.41, 0.54, 0.67].map((f, i) => (
            <rect key={i} x={4} y={navH + Math.round(midH * f)} width={sideW - 8} height={3} rx={1}
              fill={chrome.sidebar?.color || "#9e9e9e"} opacity={0.4} />
          ))}
          <text x={sideW / 2} y={navH + midH - 4} textAnchor="middle" fontSize={6}
            fill={chrome.sidebar.color || "#757575"} fontFamily="monospace">{chrome.sidebar.label || ""}</text>
        </>
      )}
      {chrome?.aside && (
        <>
          <rect x={sideW + contentW} y={navH} width={asideW} height={midH} fill={chrome.aside.background || "#eeeeee"} />
          {[0.12, 0.26, 0.4, 0.54, 0.68].map((f, i) => (
            <rect key={i} x={sideW + contentW + 4} y={navH + Math.round(midH * f)}
              width={asideW - 8} height={3} rx={1} fill={chrome.aside?.color || "#9e9e9e"} opacity={0.35} />
          ))}
          <text x={sideW + contentW + asideW / 2} y={navH + midH - 4} textAnchor="middle" fontSize={6}
            fill={chrome.aside.color || "#757575"} fontFamily="monospace">{chrome.aside.label || ""}</text>
        </>
      )}
      {chrome?.footer && (
        <>
          <rect x={0} y={navH + midH} width={W} height={footH} fill={chrome.footer.background || "#eeeeee"} />
          <text x={W / 2} y={navH + midH + footH - 3} textAnchor="middle" fontSize={6}
            fill={chrome.footer.color || "#757575"} fontFamily="monospace">{chrome.footer.label || "Footer"}</text>
        </>
      )}
      <rect x={0} y={0} width={W} height={H} fill="none" stroke="#e0e0e0" strokeWidth={1} />
    </svg>
  );
}

// ─── Main ───

export function ShellLayoutShowcase({ shellLayouts }: Props) {
  const [active, setActive] = useState<string | null>(null);

  // Sync with body data attribute and notify ShellChrome
  const activate = (name: string | null) => {
    setActive(name);
    window.dispatchEvent(new CustomEvent("shell-change", { detail: name }));
  };

  // Keep local state in sync if shell is dismissed externally (e.g. Escape key)
  useEffect(() => {
    const handler = (e: Event) => {
      const name = (e as CustomEvent<string>).detail || null;
      setActive(name);
    };
    window.addEventListener("shell-change", handler);
    return () => window.removeEventListener("shell-change", handler);
  }, []);

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-3)" }}>
      <p style={{ fontSize: "var(--font-size-sm)", color: "var(--text-muted)" }}>
        Click a layout to apply its shell — navbar, sidebar, aside, and footer render as real elements styled by the styleguide CSS.
        Press <kbd style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", background: "var(--surface-alt)", padding: "var(--space-half) var(--space-1)", border: "1px solid var(--border)", borderRadius: "var(--radius)" }}>Esc</kbd> or click again to dismiss.
      </p>
      <div style={{
        display: "grid",
        gridTemplateColumns: "repeat(auto-fill, minmax(220px, 1fr))",
        gap: "var(--card-grid-gap)",
      }}>
        {shellLayouts.map((shell) => {
          const isActive = active === shell.name;
          return (
            <button
              key={shell.name}
              onClick={() => activate(isActive ? null : shell.name)}
              style={{
                all: "unset", cursor: "pointer",
                display: "flex", flexDirection: "column", gap: "var(--space-1)",
                outline: isActive ? "2px solid var(--text)" : "none",
                outlineOffset: 2,
                transition: "outline 0.12s",
              }}
            >
              {/* Screen frame */}
              <div className="screen-frame">
                <div className="screen-titlebar">
                  <div className="screen-dots">
                    <div className="screen-dot" />
                    <div className="screen-dot" />
                    <div className="screen-dot" />
                  </div>
                  <div className="screen-url">
                    {shell.name}.app/
                  </div>
                </div>
                <div className="screen-body">
                  <WireframeDiagram chrome={shell.chrome} zones={shell.zones} />
                </div>
              </div>

              {/* Label */}
              <div>
                <div style={{ fontSize: "var(--font-size-sm)", fontWeight: 700, letterSpacing: "-0.01em", display: "flex", alignItems: "center", gap: "var(--space-1)" }}>
                  {shell.title}
                  {isActive && (
                    <span style={{ fontSize: "var(--font-size-xs)", fontFamily: "var(--font-mono)", background: "var(--surface-inverse)", color: "var(--text-inverse)", padding: "var(--space-half) var(--space-1)", borderRadius: "var(--radius)" }}>
                      active
                    </span>
                  )}
                </div>
                <div style={{ fontSize: "var(--font-size-xs)", color: "var(--text-muted)", lineHeight: 1.4, marginTop: "var(--space-half)" }}>
                  {shell.description}
                </div>
              </div>
            </button>
          );
        })}
      </div>
    </div>
  );
}
