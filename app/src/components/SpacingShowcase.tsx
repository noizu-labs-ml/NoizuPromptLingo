import type { StyleGuideConfig, Var } from "@styleguide-engine/lib/types";
import { StyleGuideSpacingScale } from "@styleguide-engine/components/pkg/spacing-scale";
import { StyleGuidePrinciples } from "@styleguide-engine/components/pkg/principles";
import { GridVisualizer } from "@styleguide-engine/components/GridVisualizer";
import { Subsection } from "@styleguide-engine/components/pkg/subsection";

interface Props {
  config: StyleGuideConfig;
}

const PRINCIPLES = [
  {
    rule: "Use the scale.",
    detail: "All spacing values must come from the token scale — no arbitrary px values in components.",
  },
  {
    rule: "Spacing communicates grouping.",
    detail: "Elements that belong together get less space between them than elements that are separate.",
  },
  {
    rule: "Prefer multiples of the base unit.",
    detail: "The base unit is 8px. Use space-1 (8px) through space-16 (128px) to maintain vertical rhythm.",
  },
  {
    rule: "Padding before margin.",
    detail: "Use padding to create internal breathing room within a component. Use margin to control distance between components.",
  },
  {
    rule: "Whitespace is content.",
    detail: "Empty space guides the eye. A dense layout is harder to scan than a spacious one — use larger tokens between sections.",
  },
];

function pxValue(val: string, vars?: Var[]): number | null {
  // Direct px value
  const m = val.match(/^(\d+(?:\.\d+)?)px$/);
  if (m) return parseFloat(m[1]);
  // Resolve var() references
  if (vars && val.startsWith("var(--")) {
    const ref = val.replace("var(--", "").replace(")", "");
    const resolved = vars.find((v) => v.name === ref);
    if (resolved) return pxValue(resolved.value, vars);
  }
  return null;
}

function resolveToken(token: string, vars: Var[]): string {
  const v = vars.find((v) => v.name === token);
  if (!v) return `var(--${token})`;
  // If the value is a var() reference, resolve it
  if (v.value.startsWith("var(--")) {
    const ref = v.value.replace("var(--", "").replace(")", "");
    const resolved = vars.find((vv) => vv.name === ref);
    if (resolved) return resolved.value;
  }
  return v.value;
}

function resolvePx(token: string, vars: Var[]): number {
  const val = resolveToken(token, vars);
  return pxValue(val, vars) ?? 0;
}


interface SpacingDerivedProps {
  allVars: Var[];
  baseVars: Var[];
  steps: { label: string; px: number | string }[];
  columns: number;
  gutterPx: number;
  marginPx: number;
  ctx: StyleGuideConfig["spacingContexts"];
}

function useDerivedSpacing(config: StyleGuideConfig): SpacingDerivedProps {
  const allVars: Var[] = Object.entries(config.flatVars).map(([name, value]) => ({ name, value }));
  const BASE_VARS = new Set(["unit", "col-gap", "radius"]);
  const baseVars = allVars.filter((v) => BASE_VARS.has(v.name));
  const spaceVars = allVars.filter((v) => {
    if (!v.name.startsWith("space-")) return false;
    if (v.name.includes("-mid")) return false;
    const num = parseInt(v.name.replace("space-", ""), 10);
    if (!isNaN(num) && num > 32) return false;
    return true;
  });
  const steps = spaceVars.map((v) => ({
    label: `--${v.name}`,
    px: pxValue(v.value, allVars) ?? v.value,
  }));
  const ctx = config.spacingContexts;
  const gutterPx = resolvePx(ctx?.grid.gutterToken ?? "col-gap", allVars) || 16;
  const marginPx = resolvePx(ctx?.grid.marginToken ?? "space-5", allVars) || 40;
  const columns = ctx?.grid.columns ?? 12;
  return { allVars, baseVars, steps, columns, gutterPx, marginPx, ctx };
}

export function SpacingScaleAndPrinciples({ config }: Props) {
  const { allVars, baseVars, steps } = useDerivedSpacing(config);
  return (
    <div className="grid grid-cols-1 @sm:grid-cols-2 gap-[var(--space-4)] items-start">
      <div>
        <div className="sg-subsection">Spacing Scale</div>
        <StyleGuideSpacingScale steps={steps} />
      </div>
      <div>
        <div className="sg-subsection">Principles</div>
        <StyleGuidePrinciples items={PRINCIPLES} />
        <div className="token-card" style={{ marginTop: "var(--space-3)" }}>
          <div className="token-card-title">Base Tokens</div>
          <div className="token-list">
            {baseVars.map((v) => (
              <div key={v.name} className="token-row">
                <span className="token-name">--{v.name}</span>
                <span className="token-value">{v.value}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

export function SpacingColumnGrid({ config }: Props) {
  const { columns, gutterPx, marginPx } = useDerivedSpacing(config);
  return <GridVisualizer columns={columns} gutterPx={gutterPx} marginPx={marginPx} />;
}

export function SpacingPageRhythm({ config }: Props) {
  const { allVars, ctx } = useDerivedSpacing(config);
  if (!ctx) return null;
  return (
    <div className="grid grid-cols-1 @sm:grid-cols-2 gap-[var(--space-4)] items-start">
      <div className="token-card">
        <div className="token-card-title">Section Spacing</div>
        <div className="token-list">
          {ctx.sectionSpacing.map((slot) => {
            const val = resolveToken(slot.token, allVars);
            const px = pxValue(val);
            return (
              <div key={slot.token} className="token-row">
                <span className="token-name">--{slot.token}</span>
                <span style={{ flex: 1, fontSize: "var(--font-size-xs)", color: "var(--text-muted)", fontFamily: "var(--font-sans)" }}>
                  {slot.role}
                </span>
                <span className="token-value">{px != null ? `${px}px` : val}</span>
              </div>
            );
          })}
        </div>
      </div>
      <div className="token-card">
        <div className="token-card-title">Page Container</div>
        <div className="token-list">
          <div className="token-row">
            <span className="token-name">max-width</span>
            <span className="token-value">{ctx.pageContainer.maxWidth}</span>
          </div>
          <div className="token-row">
            <span className="token-name">padding-x</span>
            <span style={{ flex: 1, fontSize: "var(--font-size-xs)", color: "var(--text-muted)", fontFamily: "var(--font-sans)" }}>
              horizontal margin
            </span>
            <span className="token-value">
              {pxValue(resolveToken(ctx.pageContainer.paddingXToken, allVars)) ?? resolveToken(ctx.pageContainer.paddingXToken, allVars)}px
            </span>
          </div>
          <div className="token-row">
            <span className="token-name">padding-y</span>
            <span style={{ flex: 1, fontSize: "var(--font-size-xs)", color: "var(--text-muted)", fontFamily: "var(--font-sans)" }}>
              vertical padding
            </span>
            <span className="token-value">
              {pxValue(resolveToken(ctx.pageContainer.paddingYToken, allVars)) ?? resolveToken(ctx.pageContainer.paddingYToken, allVars)}px
            </span>
          </div>
        </div>
        <div style={{ margin: "var(--space-2) var(--space-2) 0" }}>
          <div style={{
            border: "2px solid var(--border)",
            padding: `${resolvePx(ctx.pageContainer.paddingYToken, allVars)}px ${Math.min(resolvePx(ctx.pageContainer.paddingXToken, allVars), 40)}px`,
            position: "relative",
            background: "var(--surface-alt)",
          }}>
            <div style={{ height: "var(--space-4)", background: "var(--border)", display: "flex", alignItems: "center", justifyContent: "center" }}>
              <span style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)" }}>content area</span>
            </div>
            <div style={{
              position: "absolute",
              top: 0, left: 0, right: 0,
              textAlign: "center",
              fontFamily: "var(--font-mono)",
              fontSize: "var(--font-size-xs)",
              color: "var(--text-muted)",
              paddingTop: 3,
            }}>
              padding-y: {resolvePx(ctx.pageContainer.paddingYToken, allVars)}px
            </div>
          </div>
          <div style={{ textAlign: "center", fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", color: "var(--text-muted)", marginTop: "var(--space-half)" }}>
            max-width: {ctx.pageContainer.maxWidth}
          </div>
        </div>
      </div>
    </div>
  );
}

export function SpacingShowcase({ config }: Props) {
  const { allVars, baseVars, steps, columns, gutterPx, marginPx, ctx } = useDerivedSpacing(config);

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "var(--space-2)" }}>
      <Subsection id="spacing-scale-principles" title="Scale & Principles">
        <SpacingScaleAndPrinciples config={config} />
      </Subsection>

      <Subsection id="spacing-column-grid" title={`${columns}-Column Grid`}>
        <SpacingColumnGrid config={config} />
      </Subsection>

      {ctx && (
        <Subsection id="spacing-page-rhythm" title="Page Rhythm">
          <SpacingPageRhythm config={config} />
        </Subsection>
      )}
    </div>
  );
}
