"use client";

import { createContext, useContext, useState, useEffect } from "react";
import type { StyleGuideConfig } from "@styleguide-engine/lib/types";
import type { BrandingConfig } from "@styleguide-engine/config/branding-loader";

interface ThemeConfigCtx {
  activeSlug: string;
  config: StyleGuideConfig;
  branding: BrandingConfig;
  allConfigs: Record<string, StyleGuideConfig>;
  allBrandings: Record<string, BrandingConfig>;
}

const ThemeConfigContext = createContext<ThemeConfigCtx | null>(null);

interface Props {
  primaryConfig: StyleGuideConfig;
  primaryBranding: BrandingConfig;
  allConfigs: Record<string, StyleGuideConfig>;
  allBrandings: Record<string, BrandingConfig>;
  children: React.ReactNode;
}

export function ThemeConfigProvider({ primaryConfig, primaryBranding, allConfigs, allBrandings, children }: Props) {
  const [slug, setSlug] = useState(primaryConfig.slug);

  useEffect(() => {
    function read() {
      setSlug(document.documentElement.getAttribute("data-design-theme") || primaryConfig.slug);
    }
    read();
    const observer = new MutationObserver(read);
    observer.observe(document.documentElement, { attributes: true, attributeFilter: ["data-design-theme"] });
    return () => observer.disconnect();
  }, [primaryConfig.slug]);

  const config = allConfigs[slug] || primaryConfig;
  const branding = allBrandings[slug] || primaryBranding;

  return (
    <ThemeConfigContext.Provider value={{ activeSlug: slug, config, branding, allConfigs, allBrandings }}>
      {children}
    </ThemeConfigContext.Provider>
  );
}

export function useThemeConfig(): ThemeConfigCtx {
  const ctx = useContext(ThemeConfigContext);
  if (!ctx) throw new Error("useThemeConfig must be used within ThemeConfigProvider");
  return ctx;
}
