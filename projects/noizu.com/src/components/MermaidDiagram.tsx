"use client";

import { useEffect, useRef } from "react";

export function MermaidDiagram({ chart, id }: { chart: string; id: string }) {
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    let cancelled = false;
    import("mermaid").then((mod) => {
      if (cancelled || !ref.current) return;
      const mermaid = mod.default;
      mermaid.initialize({
        startOnLoad: false,
        theme: "dark",
        themeVariables: {
          darkMode: true,
          background: "#111827",
          primaryColor: "#1e3a5f",
          primaryTextColor: "#e2e8f0",
          primaryBorderColor: "#3b82f6",
          lineColor: "#475569",
          secondaryColor: "#374151",
          tertiaryColor: "#4c1d95",
          fontSize: "13px",
          fontFamily: "Segoe UI, system-ui, sans-serif",
        },
        flowchart: {
          htmlLabels: true,
          curve: "basis",
          padding: 16,
          nodeSpacing: 40,
          rankSpacing: 50,
        },
      });
      mermaid.render(`mermaid-${id}`, chart).then(({ svg }) => {
        if (!cancelled && ref.current) {
          ref.current.innerHTML = svg;
        }
      });
    });
    return () => { cancelled = true; };
  }, [chart, id]);

  return (
    <div
      ref={ref}
      className="bg-[#111827] border border-[#1e293b] rounded-lg p-6 overflow-x-auto"
    />
  );
}
