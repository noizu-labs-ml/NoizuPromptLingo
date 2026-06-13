"use client";

import { useState, useEffect } from "react";
import type { PageLayout } from "@styleguide-engine/lib/types";
import { readLayout, writeLayout } from "@styleguide-engine/lib/section-cookie";

interface Props {
  pageLayouts: PageLayout[];
}

function modifierOf(pl: PageLayout): string {
  return pl.selector.replace(".content", "").replace(".", "").trim() || "standard";
}

export function PageLayoutSummary({ pageLayouts }: Props) {
  const [selected, setSelected] = useState(() => readLayout() || "standard");

  const apply = (mod: string) => {
    setSelected(mod);
    writeLayout(mod === "standard" ? "" : mod);
    const el = document.querySelector(".content");
    if (!el) return;
    pageLayouts.forEach((pl) => {
      const m = modifierOf(pl);
      if (m && m !== "standard") el.classList.remove(m);
    });
    if (mod && mod !== "standard") el.classList.add(mod);
  };

  useEffect(() => {
    const observer = new MutationObserver(() => {
      const el = document.querySelector(".content");
      if (!el) return;
      const current = pageLayouts.find((pl) => {
        const m = modifierOf(pl);
        return m === "standard"
          ? !["wide", "full", "narrow", "article"].some((c) => el.classList.contains(c))
          : el.classList.contains(m);
      });
      if (current) setSelected(modifierOf(current));
    });
    const el = document.querySelector(".content");
    if (el) observer.observe(el, { attributes: true, attributeFilter: ["class"] });
    return () => observer.disconnect();
  }, [pageLayouts]);

  return (
    <div style={{ display: "flex", flexWrap: "wrap", gap: "var(--space-1)", padding: "var(--space-2) 0", justifyContent: "center" }}>
      {pageLayouts.map((pl) => {
        const mod = modifierOf(pl);
        const isActive = selected === mod;
        return (
          <button
            key={pl.name}
            className={`btn primary${isActive ? " btn-selected" : ""}`}
            onClick={() => apply(mod)}
          >
            {pl.title}
          </button>
        );
      })}
    </div>
  );
}
