import fs from "fs";
import path from "path";
import yaml from "js-yaml";
import { THEME_DIR, listThemes } from "./loader";

export interface BrandingIntro {
  title: string;
  "title-html"?: string;
  subtitle?: string;
  quote?: string;
  glyph?: string;
  version?: string;
  date?: string;
  repo?: string;
  colors?: string[];
  meta?: { label: string; value: string }[];
  "hide-meta"?: boolean;
  "hide-colors"?: boolean;
}

export interface BrandingLogoStyle {
  font?: string;
  color?: string;
  glow?: string;
  background?: string;
  html?: string;
}

export interface BrandingConfig {
  name: string;
  "logo-text": string;
  "logo-style"?: BrandingLogoStyle;
  "font-url"?: string;
  intent: string;
  perception: string;
  audience: string;
  tone: string;
  keywords: string[];
  intro?: BrandingIntro;
}

export function loadBranding(yamlPath?: string): BrandingConfig {
  const filePath =
    yamlPath || path.join(THEME_DIR, "branding.yaml");
  const raw = fs.readFileSync(filePath, "utf-8");
  return yaml.load(raw) as BrandingConfig;
}

/** Load branding for all themes, keyed by slug */
export function loadAllBrandings(): Record<string, BrandingConfig> {
  const result: Record<string, BrandingConfig> = {};
  for (const theme of listThemes()) {
    const file = path.join(theme.dir, "branding.yaml");
    if (fs.existsSync(file)) {
      result[theme.slug] = yaml.load(fs.readFileSync(file, "utf-8")) as BrandingConfig;
    }
  }
  return result;
}
