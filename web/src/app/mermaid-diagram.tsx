"use client";

import { useEffect, useRef } from "react";

export function MermaidDiagram({
  chart,
  className = "",
}: {
  chart: string;
  className?: string;
}) {
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    let cancelled = false;

    async function render() {
      const mermaid = (await import("mermaid")).default;
      mermaid.initialize({
        startOnLoad: false,
        theme: "base",
        themeVariables: {
          darkMode: true,
          background: "#151820",
          primaryColor: "#D4915E",
          primaryTextColor: "#E8E5E0",
          primaryBorderColor: "#2A2D33",
          secondaryColor: "#1D2029",
          secondaryTextColor: "#908D87",
          tertiaryColor: "#0E1017",
          lineColor: "#5C5A55",
          textColor: "#E8E5E0",
          mainBkg: "#151820",
          nodeBorder: "#2A2D33",
          clusterBkg: "#1D2029",
          titleColor: "#E8E5E0",
          edgeLabelBackground: "#0E1017",
          fontFamily:
            "'Plus Jakarta Sans', -apple-system, sans-serif",
          fontSize: "11px",
        },
        flowchart: {
          htmlLabels: true,
          curve: "basis",
          padding: 10,
          nodeSpacing: 25,
          rankSpacing: 35,
        },
      });

      if (cancelled) return;

      const { svg } = await mermaid.render(
        `mermaid-${Math.random().toString(36).slice(2, 8)}`,
        chart
      );

      if (!cancelled && el) {
        el.innerHTML = svg;

        // Style the rendered SVG to fit container
        const svgEl = el.querySelector("svg");
        if (svgEl) {
          svgEl.style.maxWidth = "480px";
          svgEl.style.height = "auto";
        }
      }
    }

    render();

    return () => {
      cancelled = true;
    };
  }, [chart]);

  return <div ref={ref} className={className} />;
}
