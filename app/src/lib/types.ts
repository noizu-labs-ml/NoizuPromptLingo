// ─── Glyph Language ───

export interface GlyphPrinciple {
  rule: string;
  detail: string;
}

export interface GlyphEntry {
  glyph: string;
  name: string;
  code?: string;
  use: string;
  example: string;
}

export interface GlyphSection {
  name: string;
  title: string;
  description: string;
  glyphs: GlyphEntry[];
}

export interface GlyphLanguage {
  description: string;
  principles: GlyphPrinciple[];
  sections: GlyphSection[];
}

// ─── Spacing Contexts ───

export interface SpacingGrid {
  columns: number;
  gutterToken: string;
  marginToken: string;
}

export interface SpacingPageContainer {
  maxWidth: string;
  paddingXToken: string;
  paddingYToken: string;
}

export interface SpacingSlot {
  role: string;
  token: string;
}

export interface SpacingContexts {
  grid: SpacingGrid;
  pageContainer: SpacingPageContainer;
  sectionSpacing: SpacingSlot[];
}

// ─── Accent style union ───

export type AccentStyle =
  | "bottom-bar"
  | "bottom-bar-glow"
  | "left-border"
  | "left-dashed"
  | "outer-shadow"
  | "inner-shadow"
  | "outer-glow"
  | "inner-glow"
  | "none";

// ─── Simple Input Format (what authors write in YAML) ───

export interface SimpleVarGroup {
  name: string;
  vars: Record<string, string>;
}

export interface SimpleSemanticGroup {
  name: string;
  description: string;
}

export interface SimpleSemanticClass {
  name: string;
  class: string;
  group?: string;
  title: string;
  description: string;
  note?: string;
  "accent-style": AccentStyle;
  vars: Record<string, string>;
}

export interface ShellZone {
  label: string;
  background?: string;
  color?: string;
  ratio?: number;
}

export interface SimpleShellLayout {
  name: string;
  title: string;
  description: string;
  chrome?: PageLayoutChrome;
  zones?: ShellZone[];
}

export interface PageLayoutChromeItem {
  height?: string;
  width?: string;
  background?: string;
  color?: string;
  label?: string;
}

export interface PageLayoutChrome {
  navbar?: PageLayoutChromeItem;
  sidebar?: PageLayoutChromeItem;
  aside?: PageLayoutChromeItem;
  footer?: PageLayoutChromeItem;
}

export interface SimplePageLayout {
  name: string;
  title: string;
  description: string;
  selector: string;
  vars: Record<string, string>;
  chrome?: PageLayoutChrome;
}

export interface SimpleColorNote {
  swatch: string;
  label: string;
  text: string;
}

export interface SimpleColorGroup {
  group: string;
  description?: string;
  colors: { name: string; value: string }[];
  notes?: SimpleColorNote[];
}

export interface DesignComponent {
  name: string;
  title: string;
  principle: string;
  approach: string;
  rationale: string;
}

export interface SimpleDesignSection {
  name: string;
  title: string;
  description: string;
  icon?: string;
  components: DesignComponent[];
}

export interface TypographyClass {
  name: string;
  class: string;
  sample?: string;
  usage?: string;
  "font-family"?: string;
  "font-size"?: string;
  "font-weight"?: string;
  "font-style"?: string;
  "line-height"?: string;
  "letter-spacing"?: string;
  "text-transform"?: string;
  color?: string;
}

export interface SimpleSpacingContexts {
  grid?: { columns: number; "gutter-token": string; "margin-token": string };
  "page-container"?: { "max-width": string; "padding-x-token": string; "padding-y-token": string };
  "section-spacing"?: { role: string; token: string }[];
}

export interface ToastSettings {
  position?: "top-left" | "top-right" | "top-center" | "bottom-left" | "bottom-right" | "bottom-center";
  duration?: number;
  gap?: number;
  expand?: boolean;
  "visible-toasts"?: number;
}

export interface SimpleStyleGuideConfig {
  name: string;
  slug: string;
  title: string;
  description: string;
  vars: { groups: SimpleVarGroup[] };
  "semantic-groups"?: SimpleSemanticGroup[];
  "semantic-classes": SimpleSemanticClass[];
  "page-layouts": SimplePageLayout[];
  "color-palette"?: SimpleColorGroup[];
  typography?: TypographyEntry[];
  "typography-classes"?: TypographyClass[];
  "design-sections"?: SimpleDesignSection[];
  "shell-layouts"?: SimpleShellLayout[];
  "spacing-contexts"?: SimpleSpacingContexts;
  "glyph-language"?: GlyphLanguage;
  "color-modes"?: { light: Record<string, string>; dark: Record<string, string> };
  "scoped-vars"?: { prefix?: string; sections?: Record<string, { selector: string; prefix?: string }>; vars?: ScopedVar[] };
  "css-snippets"?: CssSnippet[];
  "jsx-snippets"?: JsxSnippet[];
  "css-snippets-defaults"?: { "target-section"?: string };
  "jsx-snippets-defaults"?: { "target-section"?: string; imports?: string[] };
  "css-load"?: CssLoad[];
  "jsx-load"?: JsxLoad[];
  toast?: ToastSettings;
  globals: string;
}

// ─── Normalized Internal Format (what the engine consumes) ───

export interface Var {
  name: string;
  value: string;
  key?: string;
}

export interface VarGroup {
  name: string;
  vars: Var[];
}

export interface SemanticGroup {
  name: string;
  description: string;
}

export interface SemanticClass {
  name: string;
  class: string;
  group?: string;
  title: string;
  description: string;
  note?: string;
  accentStyle: AccentStyle;
  vars: Var[];
}

export interface PageLayout {
  name: string;
  title: string;
  description: string;
  selector: string;
  vars: Var[];
  chrome?: PageLayoutChrome;
}

export interface TypographyEntry {
  var: string;
  name: string;
  description: string;
  usage: string;
  weights: number[];
  colors?: { label: string; value: string; background?: string; note?: string }[];
}

export interface ColorNote {
  swatch?: string;
  label: string;
  text: string;
  cssClass?: string;
}

export interface ColorEntry {
  name: string;
  value: string;
  dark?: string;
  cssClass?: string;
}

export interface ColorGroup {
  group: string;
  description?: string;
  colors: ColorEntry[];
  notes?: ColorNote[];
}

// ─── Page Sections Layout ───

export interface PageSectionDef {
  id: string;
  title: string;
  desc: string;
}

export interface PageSectionGroup {
  group: string;
  desc?: string;
  sections: PageSectionDef[];
}

// ─── Scoped Variables ───

export interface ScopedVarSection {
  selector: string;
  prefix?: string;
}

export interface ScopedVarSectionValue {
  section: string;
  value?: string;
  suffix?: string;
  values?: Record<string, string>;
}

export interface ScopedVar {
  name: string;
  value?: string | ScopedVarSectionValue[];
  values?: Record<string, string>;   // suffix → value map (simple, no sections)
  selector?: string;
  "selector-body"?: string;
}

export interface ScopedVarsConfig {
  prefix: string;
  sections: Record<string, ScopedVarSection>;
  vars: ScopedVar[];
}

// ─── Snippets & Loaders ───

export interface CssSnippet {
  name?: string;
  slug: string;
  title?: string;
  description?: string;
  "target-section"?: string;
  dependencies?: string[];
  body: string;
}

export interface JsxSnippet {
  name?: string;
  slug: string;
  title?: string;
  description?: string;
  "target-section": string;
  imports?: string[];
  dependencies?: string[];
  body: string;
}

export interface CssLoad {
  path: string;
  "target-section": string;
  force?: boolean;
}

export interface JsxLoad {
  path: string;
  "target-section": string;
  force?: boolean;
}

export interface StyleGuideConfig {
  name: string;
  slug: string;
  title: string;
  description: string;
  /** Absolute path to the theme directory — used to resolve css-load/jsx-load paths */
  themeDir: string;
  vars: { groups: VarGroup[] };
  flatVars: Record<string, string>;
  semanticGroups: SemanticGroup[];
  semanticClasses: SemanticClass[];
  pageLayouts: PageLayout[];
  colorPalette: ColorGroup[];
  typography: TypographyEntry[];
  typographyClasses: TypographyClass[];
  designSections: SimpleDesignSection[];
  shellLayouts: SimpleShellLayout[];
  spacingContexts?: SpacingContexts;
  glyphLanguage?: GlyphLanguage;
  colorModes?: { light: Record<string, string>; dark: Record<string, string> };
  scopedVars?: ScopedVarsConfig;
  cssSnippets: CssSnippet[];
  jsxSnippets: JsxSnippet[];
  cssLoads: CssLoad[];
  jsxLoads: JsxLoad[];
  toast: ToastSettings;
  globals: string;
}
