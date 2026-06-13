"use client";

import { useState, useEffect } from "react";
import { readColorMode, writeColorMode } from "@styleguide-engine/lib/section-cookie";

export function ColorModeToggle() {
  const [mode, setMode] = useState<"light" | "dark">("light");

  useEffect(() => {
    const stored = readColorMode();
    if (stored === "dark" || (!stored && document.documentElement.classList.contains("dark"))) {
      setMode("dark");
      document.documentElement.classList.add("dark");
    }
  }, []);

  const apply = (next: "light" | "dark") => {
    setMode(next);
    document.documentElement.classList.toggle("dark", next === "dark");
    writeColorMode(next);
  };

  const toggle = () => apply(mode === "light" ? "dark" : "light");

  return (
    <div className="sg-mode-toggle">
      <button
        type="button"
        className={`sg-mode-toggle-option sg-mode-toggle-left${mode === "light" ? " sg-mode-toggle-active" : ""}`}
        onClick={toggle}
      >
        ☀ Light
      </button>
      <button
        type="button"
        className={`sg-mode-toggle-option sg-mode-toggle-right${mode === "dark" ? " sg-mode-toggle-active" : ""}`}
        onClick={toggle}
      >
        ☾ Dark
      </button>
    </div>
  );
}
