"use client";

import { useState, useEffect } from "react";
import type { BrandingConfig } from "@styleguide-engine/config/branding-loader";

interface Props {
  brandings: Record<string, BrandingConfig>;
}

export function IntroHero({ brandings }: Props) {
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
  const intro = branding?.intro;
  if (!intro) return null;

  return (
    <div className="sg-intro-hero">
      {intro["title-html"] ? (
        <h1 className="sg-intro-title" dangerouslySetInnerHTML={{ __html: intro["title-html"] }} />
      ) : (
        <h1 className="sg-intro-title" data-text={intro.title}>{intro.title}</h1>
      )}
      {intro.glyph && <div className="sg-intro-glyph">{intro.glyph}</div>}
      {intro.subtitle && <div className="sg-intro-subtitle">{intro.subtitle}</div>}
      {intro.quote && (
        <div className="sg-intro-quote">{intro.quote}</div>
      )}
      {!intro["hide-meta"] && (intro.version || intro.date || intro.repo) && (
        <div className="sg-intro-meta">
          {[intro.version, intro.date, intro.repo].filter(Boolean).join(" · ")}
        </div>
      )}
      {!intro["hide-colors"] && intro.colors && (
        <div className="sg-intro-color-bar">
          {intro.colors.map((c, i) => (
            <span key={i} style={{ background: c }} />
          ))}
        </div>
      )}
      {intro.meta && intro.meta.length > 0 && (
        <div className="sg-intro-meta-cards">
          {intro.meta.map((m: { label: string; value: string }) => (
            <div key={m.label} className="sg-intro-meta-card">
              <div className="sg-intro-meta-card-label">{m.label}</div>
              <div className="sg-intro-meta-card-value">{m.value}</div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
