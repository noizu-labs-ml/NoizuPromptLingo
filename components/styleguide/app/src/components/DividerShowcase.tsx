import { PreviewCode } from "./pkg/preview-code";
import { Subsection } from "./pkg/subsection";

const SEMANTIC_ROLES: { classes: string; label: string; desc: string }[] = [
  { classes: "hr section",    label: ".hr.section",    desc: "Major content division — large margin, prominent" },
  { classes: "hr subsection", label: ".hr.subsection", desc: "Minor division within a section" },
  { classes: "hr item",       label: ".hr.item",       desc: "Between list items or compact rows" },
  { classes: "hr accent",     label: ".hr.accent",     desc: "Brand-colored 2px rule" },
];

const FADE_EXAMPLES: { classes: string; label: string }[] = [
  { classes: "hr section fade-right",  label: ".hr.section.fade-right" },
  { classes: "hr section fade-left",   label: ".hr.section.fade-left" },
  { classes: "hr section fade-both",   label: ".hr.section.fade-both" },
  { classes: "hr section fade-center", label: ".hr.section.fade-center" },
];

const SEMANTIC_EXAMPLES: { classes: string; label: string }[] = [
  { classes: "hr subsection brand",   label: ".hr.subsection.brand" },
  { classes: "hr subsection primary", label: ".hr.subsection.primary" },
  { classes: "hr subsection danger",  label: ".hr.subsection.danger" },
  { classes: "hr subsection success", label: ".hr.subsection.success" },
  { classes: "hr section brand fade-right",   label: ".hr.section.brand.fade-right" },
  { classes: "hr section primary fade-both",  label: ".hr.section.primary.fade-both" },
  { classes: "hr accent glow",                label: ".hr.accent.glow" },
];

const VERTICAL: { cls: string; label: string }[] = [
  { cls: "vr-solid",     label: ".vr-solid" },
  { cls: "vr-muted",     label: ".vr-muted" },
  { cls: "vr-fade-down", label: ".vr-fade-down" },
  { cls: "vr-fade-both", label: ".vr-fade-both" },
  { cls: "vr-red",       label: ".vr-red" },
  { cls: "vr-red-fade",  label: ".vr-red-fade" },
];


const LABEL: React.CSSProperties = {
  fontFamily: "var(--font-mono)",
  fontSize: "var(--font-size-xs)",
  color: "var(--text-muted)",
  whiteSpace: "nowrap",
  userSelect: "all",
};

const DESC: React.CSSProperties = {
  fontFamily: "var(--font-sans)",
  fontSize: "var(--font-size-xs)",
  color: "var(--text-muted)",
  marginTop: 2,
};

function hrsToCode(items: { classes: string }[]): string {
  return items.map((i) => `<div class="${i.classes}"></div>`).join("\n");
}

function vrsToCode(items: { cls: string }[]): string {
  return items.map((i) => `<div class="vr ${i.cls}"></div>`).join("\n");
}

export function DividerShowcase() {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-6)" }}>

      <Subsection id="divider-semantic-roles" title="Semantic Roles">
        <PreviewCode html={hrsToCode(SEMANTIC_ROLES)}>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(2, 1fr)", gap: "var(--space-4) var(--space-6)" }}>
            {SEMANTIC_ROLES.map(({ classes, label, desc }) => (
              <div key={classes}>
                <div style={{ marginBottom: "var(--space-1)" }}>
                  <div className={classes} />
                </div>
                <span style={LABEL}>{label}</span>
                <div style={DESC}>{desc}</div>
              </div>
            ))}
          </div>
        </PreviewCode>
      </Subsection>

      <Subsection id="divider-fade-modifiers" title="Fade Modifiers">
        <PreviewCode html={hrsToCode(FADE_EXAMPLES)}>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(2, 1fr)", gap: "var(--space-4) var(--space-6)" }}>
            {FADE_EXAMPLES.map(({ classes, label }) => (
              <div key={classes}>
                <div style={{ marginBottom: "var(--space-1)" }}>
                  <div className={classes} />
                </div>
                <span style={LABEL}>{label}</span>
              </div>
            ))}
          </div>
        </PreviewCode>
      </Subsection>

      <Subsection id="divider-semantic-combos" title="Semantic Classes &amp; Combos">
        <PreviewCode html={hrsToCode(SEMANTIC_EXAMPLES)}>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(2, 1fr)", gap: "var(--space-4) var(--space-6)" }}>
            {SEMANTIC_EXAMPLES.map(({ classes, label }) => (
              <div key={classes}>
                <div style={{ marginBottom: "var(--space-1)" }}>
                  <div className={classes} />
                </div>
                <span style={LABEL}>{label}</span>
              </div>
            ))}
          </div>
        </PreviewCode>
      </Subsection>

      <Subsection id="divider-vertical-rules" title="Vertical Rules">
        <PreviewCode html={vrsToCode(VERTICAL)}>
          <div style={{ display: "flex", flexWrap: "wrap", gap: "var(--space-5)", alignItems: "flex-start" }}>
            {VERTICAL.map(({ cls, label }) => (
              <div key={cls} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: "var(--space-1)" }}>
                <div style={{ height: "var(--space-10)", display: "flex", alignItems: "stretch", padding: "0 var(--space-2)" }}>
                  <div className={`vr ${cls}`} />
                </div>
                <span style={LABEL}>{label}</span>
              </div>
            ))}
          </div>
        </PreviewCode>
      </Subsection>

    </div>
  );
}
