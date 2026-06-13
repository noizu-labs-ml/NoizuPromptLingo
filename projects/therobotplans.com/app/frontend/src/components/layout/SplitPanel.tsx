"use client";

import React, { useState, useRef, useCallback } from "react";

/**
 * SplitPanel — Two-panel layout with resizable divider, collapse support.
 *
 * @example
 * ```tsx
 * <SplitPanel left={<Sidebar />} right={<Main />} defaultSplit={0.3} />
 * <SplitPanel left={<List />} right={<Detail />} collapsibleSide="left" />
 * ```
 */

interface SplitPanelProps {
  left: React.ReactNode;
  right: React.ReactNode;
  defaultSplit?: number;
  resizable?: boolean;
  collapsibleSide?: "left" | "right" | "none";
  direction?: "horizontal" | "vertical";
  minSize?: number;
}

export function SplitPanel({ left, right, defaultSplit = 0.4, resizable = true, collapsibleSide = "none", direction = "horizontal", minSize = 200 }: SplitPanelProps) {
  const [split, setSplit] = useState(defaultSplit);
  const [collapsed, setCollapsed] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);
  const dragging = useRef(false);

  const isHorizontal = direction === "horizontal";

  const handleMouseDown = useCallback((e: React.MouseEvent) => {
    if (!resizable) return;
    e.preventDefault();
    dragging.current = true;

    const handleMouseMove = (e: MouseEvent) => {
      if (!dragging.current || !containerRef.current) return;
      const rect = containerRef.current.getBoundingClientRect();
      const pos = isHorizontal ? (e.clientX - rect.left) / rect.width : (e.clientY - rect.top) / rect.height;
      const minFrac = minSize / (isHorizontal ? rect.width : rect.height);
      setSplit(Math.max(minFrac, Math.min(1 - minFrac, pos)));
    };

    const handleMouseUp = () => {
      dragging.current = false;
      document.removeEventListener("mousemove", handleMouseMove);
      document.removeEventListener("mouseup", handleMouseUp);
    };

    document.addEventListener("mousemove", handleMouseMove);
    document.addEventListener("mouseup", handleMouseUp);
  }, [resizable, isHorizontal, minSize]);

  const leftSize = collapsed && collapsibleSide === "left" ? "0px" : collapsed && collapsibleSide === "right" ? "100%" : `${split * 100}%`;
  const rightSize = collapsed && collapsibleSide === "right" ? "0px" : collapsed && collapsibleSide === "left" ? "100%" : `${(1 - split) * 100}%`;

  return (
    <div ref={containerRef} style={{ display: "flex", flexDirection: isHorizontal ? "row" : "column", width: "100%", height: "100%", overflow: "hidden", position: "relative" }}>
      {/* Left panel */}
      <div style={{ width: isHorizontal ? leftSize : "100%", height: isHorizontal ? "100%" : leftSize, overflow: "auto", transition: collapsed ? "all 0.2s" : "none", flexShrink: 0 }}>
        {!(collapsed && collapsibleSide === "left") && left}
      </div>

      {/* Divider */}
      {!collapsed && (
        <div
          onMouseDown={handleMouseDown}
          style={{
            width: isHorizontal ? 4 : "100%",
            height: isHorizontal ? "100%" : 4,
            background: "var(--border)",
            cursor: resizable ? (isHorizontal ? "col-resize" : "row-resize") : "default",
            flexShrink: 0,
            position: "relative",
            zIndex: 1,
          }}
        >
          {collapsibleSide !== "none" && (
            <button type="button" onClick={() => setCollapsed(!collapsed)} aria-label={collapsed ? "Expand panel" : "Collapse panel"} style={{ position: "absolute", top: isHorizontal ? "50%" : "auto", left: isHorizontal ? "50%" : "50%", transform: "translate(-50%, -50%)", width: 16, height: 16, borderRadius: "50%", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text-muted)", fontSize: "8px", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", zIndex: 2 }}>
              {isHorizontal ? (collapsibleSide === "left" ? "◀" : "▶") : (collapsibleSide === "left" ? "▲" : "▼")}
            </button>
          )}
        </div>
      )}

      {/* Collapse expand button when collapsed */}
      {collapsed && (
        <button type="button" onClick={() => setCollapsed(false)} aria-label="Expand panel" style={{ width: isHorizontal ? 20 : "100%", height: isHorizontal ? "100%" : 20, background: "var(--surface)", border: "1px solid var(--border)", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", color: "var(--text-muted)", fontSize: "10px", flexShrink: 0 }}>
          {isHorizontal ? (collapsibleSide === "left" ? "▶" : "◀") : (collapsibleSide === "left" ? "▼" : "▲")}
        </button>
      )}

      {/* Right panel */}
      <div style={{ flex: 1, overflow: "auto", transition: collapsed ? "all 0.2s" : "none" }}>
        {!(collapsed && collapsibleSide === "right") && right}
      </div>
    </div>
  );
}

export default SplitPanel;
