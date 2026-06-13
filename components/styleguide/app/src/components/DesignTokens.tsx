"use client";

import { useState } from "react";
import type { VarGroup, SemanticClass, SemanticGroup } from "@styleguide-engine/lib/types";
import { StyleGuideTokenCard } from "@styleguide-engine/components/pkg/token-card";

interface Props {
  groups: VarGroup[];
  flatVars?: Record<string, string>;
  semanticClasses?: SemanticClass[];
  semanticGroups?: SemanticGroup[];
}

const EXTENDED_GROUPS = new Set(["Base", "Cards", "Buttons", "Tokens", "Toggle"]);

function inferTokenType(name: string, value: string): string {
  if (value.startsWith("#") || value.startsWith("rgb") || value.startsWith("rgba")) return "color";
  if (name.includes("font-family") || name.includes("font-sans") || name.includes("font-mono")) return "font";
  if (name.includes("space") || name.includes("gap") || name.includes("unit")) return "space";
  if (name.includes("radius")) return "radius";
  if (name.includes("shadow")) return "shadow";
  if (name.includes("font-size") || name.includes("line-height")) return "size";
  return "";
}

function TokenGrid({ groups, extra }: { groups: VarGroup[]; extra?: React.ReactNode }) {
  return (
    <div className="token-grid">
      {groups.map((group) => {
        const tokens: [string, string][] = group.vars.map((v) => [
          `--${v.name}`,
          v.value,
        ]);
        const type = tokens.length > 0
          ? inferTokenType(group.vars[0].name, group.vars[0].value)
          : "";
        return (
          <StyleGuideTokenCard
            key={group.name}
            title={group.name}
            type={type}
            tokens={tokens}
          />
        );
      })}
      {extra}
    </div>
  );
}

function semanticTokens(classes: SemanticClass[]): [string, string][] {
  return classes.map((sc): [string, string] => {
    const accent = sc.vars.find((v) => v.name === "accent");
    return [`--semantic-${sc.name}`, accent?.value || ""];
  });
}

function CollapsibleTokenSection({
  label,
  groups,
}: {
  label: string;
  groups: VarGroup[];
}) {
  const [open, setOpen] = useState(false);
  if (!groups.length) return null;
  return (
    <div style={{ marginTop: "var(--space-3)" }}>
      <div
        onClick={() => setOpen(!open)}
        style={{
          cursor: "pointer",
          userSelect: "none",
          display: "flex",
          alignItems: "center",
          gap: "var(--space-1)",
          fontFamily: "var(--font-mono)",
          fontSize: "var(--font-size-xs)",
          color: "var(--text-muted)",
          textTransform: "uppercase",
          letterSpacing: "0.08em",
          paddingBottom: "var(--space-1)",
          borderBottom: "1px solid var(--border)",
          marginBottom: "var(--space-2)",
        }}
      >
        <span
          style={{
            fontSize: "var(--toggle-icon-size)",
            color: "var(--toggle-icon-color)",
            transition: `transform var(--toggle-transition)`,
            display: "inline-flex",
            transform: open ? "rotate(90deg)" : "rotate(0deg)",
          }}
        >
          &#9654;
        </span>
        {label}
      </div>
      {open && <TokenGrid groups={groups} />}
    </div>
  );
}

/** Map group names to var-name prefixes for fallback from flatVars */
const GROUP_PREFIXES: Record<string, (name: string) => boolean> = {
  "Surfaces": (n) => (n.startsWith("gray-") || n === "white" || n === "black" || n === "off-white") && !n.endsWith("-lerp"),
  "Primaries - Bauhaus": (n) => n.startsWith("brand-"),
  "Semantic": (n) => n === "success" || n === "warning" || n === "error" || n === "info" || n.endsWith("-tint"),
  "Palette": (n) => ["rose","orange","amber","lime","emerald","teal","cyan","sky","indigo","violet","purple","fuchsia","pink"].some((c) => n === c || n === `${c}-light`),
  "Grid & Spacing": (n) => n.startsWith("space-") || n.startsWith("size-") || n === "unit" || n === "col-gap" || n === "radius",
  "Typography": (n) => n.startsWith("font-") || n === "line-height-base",
  "Base": (n) => n.startsWith("base-"),
  "Cards": (n) => n.startsWith("card-"),
  "Tokens": (n) => n.startsWith("token-"),
  "Buttons": (n) => n.startsWith("btn-"),
  "Toggle": (n) => n.startsWith("toggle-") || n.startsWith("collapse-"),
  "HUI: Focus & Interaction": (n) => n === "hui-focus-ring-color" || n === "hui-focus-ring-width",
  "HUI: Controls": (n) => n.startsWith("hui-control-") || n.startsWith("hui-checkbox-") || n.startsWith("hui-switch-") || n.startsWith("hui-radio-"),
  "HUI: Trigger Buttons": (n) => n.startsWith("hui-trigger-"),
  "HUI: Overlay Panels": (n) => n.startsWith("hui-panel-") || n.startsWith("hui-popover-") || n.startsWith("hui-menu-") || n.startsWith("hui-combo-"),
  "HUI: Tabs": (n) => n.startsWith("hui-tab-"),
  "HUI: Disclosure": (n) => n.startsWith("hui-disclosure-"),
  "HUI: Field Controls": (n) => n.startsWith("hui-field-") || n.startsWith("hui-label-") || n.startsWith("hui-description-") || n.startsWith("hui-textarea-"),
  "HUI: Dialog": (n) => n.startsWith("hui-dialog-"),
  "HUI: Showcase Grid": (n) => n.startsWith("hui-showcase-"),
};

function enrichGroups(groups: VarGroup[], flatVars?: Record<string, string>): VarGroup[] {
  if (!flatVars) return groups;
  return groups.map((g) => {
    if (g.vars.length > 0) return g; // YAML has entries — use as-is
    const matcher = GROUP_PREFIXES[g.name];
    if (!matcher) return g;
    const vars = Object.entries(flatVars)
      .filter(([name]) => matcher(name) && !name.endsWith("-lerp"))
      .map(([name, value]) => ({ name, value }));
    return { ...g, vars };
  });
}

export function CoreTokensSection({ groups, flatVars, semanticClasses, semanticGroups }: Props) {
  const enriched = enrichGroups(groups, flatVars);
  const core = enriched.filter((g) => !EXTENDED_GROUPS.has(g.name) && !g.name.startsWith("HUI:"));
  const semanticExtra = semanticClasses && semanticClasses.length > 0 ? (
    semanticGroups && semanticGroups.length > 0
      ? semanticGroups.map((sg) => {
          const classes = semanticClasses.filter((sc) => sc.group === sg.name);
          if (!classes.length) return null;
          return <StyleGuideTokenCard key={sg.name} title={sg.name} type="color" tokens={semanticTokens(classes)} />;
        })
      : <StyleGuideTokenCard title="Semantic Classes" type="color" tokens={semanticTokens(semanticClasses)} />
  ) : undefined;
  return <TokenGrid groups={core} extra={semanticExtra} />;
}

export function HUITokensSection({ groups, flatVars }: Omit<Props, "semanticClasses" | "semanticGroups">) {
  const enriched = enrichGroups(groups, flatVars);
  const hui = enriched.filter((g) => g.name.startsWith("HUI:"));
  if (!hui.length) return null;
  return <TokenGrid groups={hui} />;
}

export function ExtendedTokensSection({ groups, flatVars }: Omit<Props, "semanticClasses" | "semanticGroups">) {
  const enriched = enrichGroups(groups, flatVars);
  const extended = enriched.filter((g) => EXTENDED_GROUPS.has(g.name));
  if (!extended.length) return null;
  return <TokenGrid groups={extended} />;
}

export function DesignTokens({ groups, flatVars, semanticClasses, semanticGroups }: Props) {
  const [showExtended, setShowExtended] = useState(false);
  const enriched = enrichGroups(groups, flatVars);

  const core     = enriched.filter((g) => !EXTENDED_GROUPS.has(g.name) && !g.name.startsWith("HUI:"));
  const hui      = enriched.filter((g) => g.name.startsWith("HUI:"));
  const extended = enriched.filter((g) => EXTENDED_GROUPS.has(g.name));

  const semanticExtra = semanticClasses && semanticClasses.length > 0 ? (
    semanticGroups && semanticGroups.length > 0
      ? semanticGroups.map((sg) => {
          const classes = semanticClasses.filter((sc) => sc.group === sg.name);
          if (!classes.length) return null;
          return (
            <StyleGuideTokenCard
              key={sg.name}
              title={sg.name}
              type="color"
              tokens={semanticTokens(classes)}
            />
          );
        })
      : (
        <StyleGuideTokenCard
          title="Semantic Classes"
          type="color"
          tokens={semanticTokens(semanticClasses)}
        />
      )
  ) : undefined;

  return (
    <div>
      <TokenGrid groups={core} extra={semanticExtra} />

      <CollapsibleTokenSection
        label="Headless UI"
        groups={hui}
      />

      {extended.length > 0 && (
        <div style={{ marginTop: "var(--space-3)" }}>
          <div
            onClick={() => setShowExtended(!showExtended)}
            style={{
              cursor: "pointer",
              userSelect: "none",
              display: "flex",
              alignItems: "center",
              gap: "var(--space-1)",
              fontFamily: "var(--font-mono)",
              fontSize: "var(--font-size-xs)",
              color: "var(--text-muted)",
              textTransform: "uppercase",
              letterSpacing: "0.08em",
              paddingBottom: "var(--space-1)",
              borderBottom: "1px solid var(--border)",
              marginBottom: "var(--space-2)",
            }}
          >
            <span
              style={{
                fontSize: "var(--toggle-icon-size)",
                color: "var(--toggle-icon-color)",
                transition: `transform var(--toggle-transition)`,
                display: "inline-flex",
                transform: showExtended ? "rotate(90deg)" : "rotate(0deg)",
              }}
            >
              &#9654;
            </span>
            Extended ({extended.map((g) => g.name).join(", ")})
          </div>

          {showExtended && <TokenGrid groups={extended} />}
        </div>
      )}
    </div>
  );
}
