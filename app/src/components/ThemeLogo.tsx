"use client";

import React, { useState, useEffect } from "react";
import type { BrandingConfig } from "@styleguide-engine/config/branding-loader";

interface Props {
  brandings: Record<string, BrandingConfig>;
  fallback: React.ReactNode;
}

export function ThemeLogo({ brandings, fallback }: Props) {
  const [theme, setTheme] = useState("");

  useEffect(() => {
    function read() {
      setTheme(document.documentElement.getAttribute("data-design-theme") || "");
    }
    read();
    const observer = new MutationObserver(read);
    observer.observe(document.documentElement, { attributes: true, attributeFilter: ["data-design-theme"] });
    return () => observer.disconnect();
  }, []);

  const branding = brandings[theme];
  const ls = branding?.["logo-style"];

  if (!ls) return <>{fallback}</>;

  if (ls.html) {
    return (
      <div
        className="theme-logo"
        dangerouslySetInnerHTML={{ __html: ls.html }}
      />
    );
  }

  return (
    <div
      className="theme-logo"
      style={{
        fontFamily: ls.font || "var(--font-sans)",
        fontSize: "var(--branding-logo-font-size)",
        fontWeight: "var(--branding-logo-font-weight)" as React.CSSProperties["fontWeight"],
        letterSpacing: "var(--branding-logo-letter-spacing)",
        textTransform: "var(--branding-logo-text-transform)" as React.CSSProperties["textTransform"],
        color: ls.color || "inherit",
        textShadow: ls.glow || "none",
        background: ls.background || "transparent",
        padding: ls.background ? "var(--branding-logo-padding, 16px 24px)" : undefined,
        borderRadius: ls.background ? "var(--branding-logo-border-radius)" : undefined,
      }}
    >
      {branding["logo-text"] || branding.name}
    </div>
  );
}
