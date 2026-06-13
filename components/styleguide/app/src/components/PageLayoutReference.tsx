"use client";

import { useState, useEffect } from "react";
import type { PageLayout, PageLayoutChrome } from "@styleguide-engine/lib/types";
import { readLayout, writeLayout } from "@styleguide-engine/lib/section-cookie";

interface Props {
  pageLayouts: PageLayout[];
}

function modifierOf(pl: PageLayout): string {
  return pl.selector.replace(".content", "").replace(".", "").trim();
}

// ─── Wireframe diagram ───

function WireframeDiagram({ chrome }: { chrome?: PageLayoutChrome }) {
  const W = 160;
  const H = 108;

  const navH = chrome?.navbar ? 16 : 0;
  const footerH = chrome?.footer ? 12 : 0;
  const sideW = chrome?.sidebar ? 30 : 0;
  const asideW = chrome?.aside ? 36 : 0;
  const midH = H - navH - footerH;
  const contentW = W - sideW - asideW;

  // Content fill lines
  const lineY = [0.25, 0.45, 0.65, 0.82].map((f) => Math.round(navH + midH * f));
  const shortLineY = Math.round(navH + midH * 0.82);

  return (
    <svg
      width={W}
      height={H}
      viewBox={`0 0 ${W} ${H}`}
      style={{ display: "block", borderRadius: 2, overflow: "hidden" }}
    >
      {/* Body background */}
      <rect x={0} y={0} width={W} height={H} fill="#f5f5f5" />

      {/* Navbar */}
      {chrome?.navbar && (
        <>
          <rect
            x={0} y={0} width={W} height={navH}
            fill={chrome.navbar.background || "#212121"}
          />
          <text x={W / 2} y={navH - 4} textAnchor="middle" fontSize={7} fill={chrome.navbar.color || "#fff"} fontFamily="monospace">
            {chrome.navbar.label || "Nav"}
          </text>
        </>
      )}

      {/* Sidebar */}
      {chrome?.sidebar && (
        <>
          <rect
            x={0} y={navH} width={sideW} height={midH}
            fill={chrome.sidebar.background || "#e0e0e0"}
          />
          {/* sidebar nav items */}
          {[0.15, 0.28, 0.41, 0.54].map((f, i) => (
            <rect
              key={i}
              x={4} y={navH + Math.round(midH * f)}
              width={sideW - 8} height={4}
              rx={1} fill={chrome.sidebar?.color || "#9e9e9e"} opacity={0.5}
            />
          ))}
          <text
            x={sideW / 2} y={navH + midH - 5}
            textAnchor="middle" fontSize={6}
            fill={chrome.sidebar.color || "#616161"} fontFamily="monospace"
          >
            {chrome.sidebar.label || ""}
          </text>
        </>
      )}

      {/* Content area */}
      <rect
        x={sideW} y={navH} width={contentW} height={midH}
        fill="#fafafa"
      />
      {/* Content lines */}
      {lineY.map((y, i) => (
        <rect
          key={i}
          x={sideW + 8}
          y={y}
          width={i === lineY.length - 1 ? contentW * 0.55 : contentW - 16}
          height={3}
          rx={1}
          fill="#bdbdbd"
          opacity={0.7}
        />
      ))}
      {/* Content heading stub */}
      <rect x={sideW + 8} y={navH + 8} width={contentW * 0.6} height={5} rx={1} fill="#9e9e9e" />

      {/* Aside */}
      {chrome?.aside && (
        <>
          <rect
            x={sideW + contentW} y={navH} width={asideW} height={midH}
            fill={chrome.aside.background || "#eeeeee"}
          />
          {[0.12, 0.28, 0.44, 0.6, 0.75].map((f, i) => (
            <rect
              key={i}
              x={sideW + contentW + 4}
              y={navH + Math.round(midH * f)}
              width={asideW - 8} height={3}
              rx={1} fill={chrome.aside?.color || "#9e9e9e"} opacity={0.4}
            />
          ))}
          <text
            x={sideW + contentW + asideW / 2} y={navH + midH - 5}
            textAnchor="middle" fontSize={6}
            fill={chrome.aside.color || "#757575"} fontFamily="monospace"
          >
            {chrome.aside.label || ""}
          </text>
        </>
      )}

      {/* Footer */}
      {chrome?.footer && (
        <>
          <rect
            x={0} y={navH + midH} width={W} height={footerH}
            fill={chrome.footer.background || "#eeeeee"}
          />
          <text
            x={W / 2} y={navH + midH + footerH - 3}
            textAnchor="middle" fontSize={6}
            fill={chrome.footer.color || "#757575"} fontFamily="monospace"
          >
            {chrome.footer.label || "Footer"}
          </text>
        </>
      )}

      {/* Border */}
      <rect x={0} y={0} width={W} height={H} fill="none" stroke="#e0e0e0" strokeWidth={1} />
    </svg>
  );
}

// ─── Chrome legend ───

function ChromeLegend({ chrome }: { chrome?: PageLayoutChrome }) {
  if (!chrome) return null;
  const items = [
    chrome.navbar && { label: chrome.navbar.label || "Navbar", sub: chrome.navbar.height, bg: chrome.navbar.background },
    chrome.sidebar && { label: chrome.sidebar.label || "Sidebar", sub: chrome.sidebar.width, bg: chrome.sidebar.background },
    chrome.aside && { label: chrome.aside.label || "Aside", sub: chrome.aside.width, bg: chrome.aside.background },
    chrome.footer && { label: chrome.footer.label || "Footer", sub: chrome.footer.height, bg: chrome.footer.background },
  ].filter(Boolean) as { label: string; sub?: string; bg?: string }[];

  if (!items.length) return null;

  return (
    <div style={{ display: "flex", flexWrap: "wrap", gap: "var(--space-1)", marginTop: "var(--space-1)" }}>
      {items.map((item) => (
        <div
          key={item.label}
          style={{
            display: "flex",
            alignItems: "center",
            gap: "var(--space-1)",
            fontSize: "var(--font-size-xs)",
            color: "var(--text-secondary)",
          }}
        >
          <div
            style={{
              width: "var(--space-1)", height: "var(--space-1)",
              background: item.bg || "var(--border)",
              border: "1px solid var(--border)",
              borderRadius: "var(--radius)",
              flexShrink: 0,
            }}
          />
          <span style={{ fontFamily: "var(--font-mono)" }}>{item.label}</span>
          {item.sub && (
            <span style={{ color: "var(--text-muted)" }}>{item.sub}</span>
          )}
        </div>
      ))}
    </div>
  );
}

// ─── Main component ───

export function PageLayoutReference({ pageLayouts }: Props) {
  const [selected, setSelected] = useState(() => {
    const stored = readLayout();
    if (stored) return stored;
    return "standard";
  });

  useEffect(() => {
    const el = document.querySelector(".content");
    if (!el) return;
    pageLayouts.forEach((pl) => {
      const m = modifierOf(pl);
      if (m && m !== "standard") el.classList.remove(m);
    });
    if (selected && selected !== "standard") el.classList.add(selected);
    writeLayout(selected === "standard" ? "" : selected);
  }, [selected, pageLayouts]);

  return (
    <div
      style={{
        display: "grid",
        gridTemplateColumns: "repeat(auto-fill, minmax(200px, 1fr))",
        gap: "var(--card-grid-gap)",
      }}
    >
      {pageLayouts.map((pl) => {
        const mod = modifierOf(pl);
        const isSelected = selected === (mod || "standard");

        return (
          <button
            key={pl.name}
            onClick={() => setSelected(mod || "standard")}
            style={{
              all: "unset",
              cursor: "pointer",
              display: "flex",
              flexDirection: "column",
              border: isSelected ? "2px solid var(--text)" : "1px solid var(--border)",
              background: isSelected ? "var(--surface)" : "var(--surface-alt)",
              padding: "var(--space-2)",
              gap: "var(--space-1)",
              transition: "all 0.15s",
              boxShadow: isSelected
                ? "0 4px 16px rgba(0,0,0,0.12)"
                : "none",
            }}
          >
            <WireframeDiagram chrome={pl.chrome} />

            <div style={{ marginTop: "var(--space-half)" }}>
              <div
                style={{
                  fontSize: "var(--font-size-sm)",
                  fontWeight: 700,
                  letterSpacing: "-0.01em",
                  display: "flex",
                  alignItems: "center",
                  gap: "var(--space-1)",
                }}
              >
                {pl.title}
                {isSelected && (
                  <span
                    style={{
                      fontSize: "var(--font-size-xs)",
                      fontFamily: "var(--font-mono)",
                      background: "var(--surface-inverse)",
                      color: "var(--text-inverse)",
                      padding: "var(--space-half) var(--space-1)",
                      borderRadius: "var(--radius)",
                    }}
                  >
                    active
                  </span>
                )}
              </div>
              <div
                style={{
                  fontSize: "var(--font-size-xs)",
                  color: "var(--text-muted)",
                  lineHeight: 1.4,
                  marginTop: "var(--space-half)",
                }}
              >
                {pl.description}
              </div>
              <ChromeLegend chrome={pl.chrome} />
            </div>
          </button>
        );
      })}
    </div>
  );
}
