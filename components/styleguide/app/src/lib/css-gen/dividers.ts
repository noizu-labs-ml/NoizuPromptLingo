import type { StyleGuideConfig } from "../types";

export function generateDividerCSS(_config: StyleGuideConfig): string {
  return `/* ═══════════════════════════════════════
   DIVIDERS & RULES
   ═══════════════════════════════════════ */

/* ─── Base reset ─── */
.hr {
  border: none;
  height: var(--hr-thick);
  width: 100%;
  display: block;
  margin: var(--space-3) 0;
  background: var(--border-strong);
}

/* ─── Semantic roles ─── */
/* hr.section — major content division, prominent */
.hr.section {
  height: var(--hr-section-height, var(--hr-heavy));
  background: var(--hr-section-color, var(--amber));
  margin: var(--hr-section-margin, var(--space-6) 0);
}
/* hr.subsection — minor division within a section */
.hr.subsection {
  height: var(--hr-subsection-height, var(--hr-thick));
  background: var(--hr-subsection-color, var(--sky));
  margin: var(--hr-subsection-margin, var(--space-4) 0);
}
/* hr.item — between list items or compact rows */
.hr.item {
  height: var(--hr-height);
  background: var(--border);
  margin: var(--space-2) 0;
}
/* hr.accent — brand-colored divider */
.hr.accent {
  height: var(--hr-accent-height, var(--hr-heavy));
  background: var(--hr-accent-color, var(--pink));
  margin: var(--hr-accent-margin, var(--space-3) 0);
}

/* ─── Modifier classes (composable with semantic roles) ─── */
/* hr.section.fade-right, hr.subsection.primary, etc. */
.hr.fade-right {
  background: linear-gradient(
    to right,
    currentColor 0%,
    color-mix(in srgb, currentColor 35%, transparent) 55%,
    transparent 100%
  );
}
.hr.fade-left {
  background: linear-gradient(
    to left,
    currentColor 0%,
    color-mix(in srgb, currentColor 35%, transparent) 55%,
    transparent 100%
  );
}
.hr.fade-both {
  background: linear-gradient(
    to right,
    transparent 0%,
    currentColor 20%,
    currentColor 80%,
    transparent 100%
  );
}
.hr.fade-center {
  background: linear-gradient(
    to right,
    transparent 0%,
    currentColor 40%,
    color-mix(in srgb, currentColor 25%, transparent) 100%
  );
}
.hr.primary   { color: var(--text); }
.hr.secondary { color: var(--border-strong); }
.hr.muted     { color: var(--border); }
.hr.brand     { color: var(--brand-red); }
.hr.glow      { filter: drop-shadow(0 0 4px currentColor); }
.vr {
  display: inline-block;
  width: var(--hr-height);
  align-self: stretch;
  min-height: 1em;
}

/* ─── Horizontal: solid ─── */
.hr-solid       { background: var(--text); }
.hr-muted       { background: var(--border); }
.hr-light       { background: var(--border); }
.hr-thick       { height: var(--hr-thick); background: var(--text); }
.hr-heavy       { height: var(--hr-heavy); background: var(--text); }

/* ─── Horizontal: dashed / dotted ─── */
.hr-dashed {
  height: 0;
  border-top: var(--hr-height) dashed var(--border-strong);
}
.hr-dotted {
  height: 0;
  border-top: var(--hr-height) dotted var(--border-strong);
}
.hr-double {
  height: 0;
  border-top: var(--hr-heavy) double var(--border-strong);
}

/* ─── Horizontal: gradient fades ─── */
.hr-fade-right {
  background: linear-gradient(
    to right,
    var(--text) 0%,
    color-mix(in srgb, var(--text) 40%, transparent) 55%,
    transparent 100%
  );
}
.hr-fade-left {
  background: linear-gradient(
    to left,
    var(--text) 0%,
    color-mix(in srgb, var(--text) 40%, transparent) 55%,
    transparent 100%
  );
}
.hr-fade-both {
  background: linear-gradient(
    to right,
    transparent 0%,
    var(--text) 20%,
    var(--text) 80%,
    transparent 100%
  );
}
.hr-fade-center {
  background: linear-gradient(
    to right,
    transparent 0%,
    var(--text) 40%,
    color-mix(in srgb, var(--text) 30%, transparent) 100%
  );
}

/* ─── Horizontal: brand accent ─── */
.hr-red {
  background: var(--brand-red);
}
.hr-red-fade {
  background: linear-gradient(
    to right,
    var(--brand-red) 0%,
    color-mix(in srgb, var(--brand-red) 35%, transparent) 60%,
    transparent 100%
  );
}
.hr-red-fade-both {
  background: linear-gradient(
    to right,
    transparent 0%,
    var(--brand-red) 20%,
    var(--brand-red) 80%,
    transparent 100%
  );
}

/* ─── Horizontal: glow ─── */
.hr-glow {
  background: var(--text);
  box-shadow: 0 0 6px rgba(0,0,0,0.35), 0 0 14px rgba(0,0,0,0.15);
}
.hr-red-glow {
  background: var(--brand-red);
  box-shadow: 0 0 6px color-mix(in srgb, var(--brand-red) 55%, transparent),
              0 0 16px color-mix(in srgb, var(--brand-red) 25%, transparent);
}
.hr-glow-fade {
  background: linear-gradient(to right, var(--text) 0%, transparent 100%);
  box-shadow: 0 0 8px rgba(0,0,0,0.2);
  filter: blur(var(--hr-glow-blur));
}

/* ─── Horizontal: decorative ─── */
.hr-inset {
  height: 0;
  border-top: var(--hr-height) solid var(--border);
  border-bottom: var(--hr-height) solid var(--surface);
}
.hr-overline {
  height: var(--hr-heavy);
  background: linear-gradient(to right, var(--text) 0%, var(--text) var(--hr-overline-length), transparent var(--hr-overline-length));
}
.hr-red-overline {
  height: var(--hr-thick);
  background: linear-gradient(to right, var(--brand-red) 0%, var(--brand-red) var(--hr-overline-length), transparent var(--hr-overline-length));
}

/* ─── Vertical: solid ─── */
.vr-solid       { background: var(--text); }
.vr-muted       { background: var(--border); }
.vr-light       { background: var(--border); }
.vr-thick       { width: var(--hr-thick); background: var(--text); }

/* ─── Vertical: gradient fades ─── */
.vr-fade-down {
  background: linear-gradient(
    to bottom,
    var(--text) 0%,
    color-mix(in srgb, var(--text) 30%, transparent) 60%,
    transparent 100%
  );
}
.vr-fade-up {
  background: linear-gradient(
    to top,
    var(--text) 0%,
    color-mix(in srgb, var(--text) 30%, transparent) 60%,
    transparent 100%
  );
}
.vr-fade-both {
  background: linear-gradient(
    to bottom,
    transparent 0%,
    var(--text) 20%,
    var(--text) 80%,
    transparent 100%
  );
}

/* ─── Vertical: brand ─── */
.vr-red        { background: var(--brand-red); }
.vr-red-fade   {
  background: linear-gradient(
    to bottom,
    var(--brand-red) 0%,
    color-mix(in srgb, var(--brand-red) 30%, transparent) 70%,
    transparent 100%
  );
}`;
}
