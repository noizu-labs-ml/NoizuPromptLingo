# Style Guide: Ipso The Lorem — TrustShield Portal

> Corporate authority modernized with tech-minimal polish for a compliance certification hub.

**Style System:** Corporate Enterprise 80% + Minimal Tech 20%
**Source Specs:** [corporate-enterprise.md](../corporate-enterprise.md) + [minimal-tech.md](../minimal-tech.md)
**Scenario:** Compliance and security certification portal for enterprise clients

---

## Scenario

Ipso The Lorem needs a **TrustShield Portal** — a client-facing security hub where enterprise prospects can review Ipso's compliance certifications (SOC 2, ISO 27001, GDPR), download audit reports, request security questionnaire responses, and track their vendor risk assessment.

The audience overlaps with Client Gateway (see [Example 02](02-corporate-enterprise-100.md)) but skews more technical: CISOs, security engineers, and compliance officers. They need institutional trust (Corporate Enterprise) but also expect the clean data-driven interfaces they see in modern security tooling (Minimal Tech).

**Mix rationale:** Corporate Enterprise provides the trust foundation (navy authority, serif gravitas, formal structure). Minimal Tech contributes **sleek data presentation**, **monospace accents for technical content**, and **subtle component polish** — three elements that signal "we're not just compliant, we're technically sophisticated."

---

## Color Palette

```css
:root {
  /* 80% — Corporate Enterprise foundation */
  --bg-primary: #FFFFFF;
  --bg-section: #F8FAFC;
  --bg-elevated: #FFFFFF;

  --text-primary: #1E293B;
  --text-secondary: #475569;
  --text-tertiary: #94A3B8;

  --border-default: #E2E8F0;
  --border-strong: #CBD5E1;

  --primary: #1E3A5F;
  --primary-hover: #162D4A;
  --primary-light: #EFF6FF;

  /* 20% — Minimal Tech accent influence */
  --accent: #6366F1;         /* MT indigo replaces corporate gold */
  --accent-muted: rgba(99, 102, 241, 0.08);

  --success: #16A34A;
  --warning: #D97706;
  --error: #DC2626;
  --info: #2563EB;
}
```

**Usage rules:**
- Light mode only (enterprise context)
- Navy primary for header and structural elements (Corporate Enterprise)
- **Indigo accent** (Minimal Tech influence) replaces the gold accent from pure Corporate — indigo signals technical sophistication better than gold for a security audience
- Navy + indigo creates a cool, technical feel within the warm corporate structure

---

## Typography

**Font stack:**
```css
/* 80% — Corporate Enterprise: headings + body */
--font-heading: 'Merriweather', Georgia, serif;
--font-body: 'Inter', -apple-system, sans-serif;

/* 20% — Minimal Tech influence: technical content */
--font-mono: 'JetBrains Mono', Consolas, monospace;
```

| Level | Font | Size | Weight | Line Height | Use |
|-------|------|------|--------|-------------|-----|
| H1 | Serif | 32px | 700 | 1.25 | Page titles |
| H2 | Serif | 24px | 700 | 1.3 | Section headers |
| H3 | Sans | 20px | 600 | 1.35 | Subsection headers |
| Body | Sans | 16px | 400 | 1.7 | Default text |
| Body Small | Sans | 14px | 400 | 1.6 | Metadata |
| **Data Label** | **Mono** | **12px** | **500** | **1.4** | **Cert IDs, dates, version numbers** |
| Caption | Sans | 12px | 500 | 1.5 | Table headers |
| Overline | Sans | 11px | 600 | 1.4 | Category labels |

**Typography notes:**
- Serif headings and sans body from Corporate Enterprise (unchanged)
- **The 20% element:** Monospace font for technical data — certification IDs (`SOC2-2024-0847`), report hashes, version numbers, and timestamp columns. This borrows Minimal Tech's convention of mono for machine-readable data.

**Font sources:**

| Font | Source | License | Link |
|------|--------|---------|------|
| Merriweather | Adobe Fonts | Free / OFL | [Adobe Fonts](https://fonts.adobe.com/fonts/merriweather) \| [Google Fonts](https://fonts.google.com/specimen/Merriweather) |
| Inter | Adobe Fonts | Free / OFL | [Adobe Fonts](https://fonts.adobe.com/fonts/inter) \| [Google Fonts](https://fonts.google.com/specimen/Inter) |
| JetBrains Mono | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/JetBrains+Mono) \| [GitHub](https://github.com/JetBrains/JetBrainsMono) |

---

## Spacing & Layout

**Spacing scale:** 4, 8, 16, 24, 32, 48, 64, 80, 120px (Corporate Enterprise — unchanged)

**Grid:** Identical to [Example 02 (Client Gateway)](02-corporate-enterprise-100.md).

**Layout pattern:** Corporate Enterprise's top nav + single-column/sidebar structure. The security portal adds a compliance dashboard as the landing view with summary metrics.

---

## Component Styling

### Buttons

Identical to [Example 02 (Client Gateway)](02-corporate-enterprise-100.md) — navy primary buttons, 4px radius, 200ms transitions. Corporate Enterprise controls all button styling.

### Form Inputs

Corporate Enterprise foundation with one Minimal Tech refinement:

```css
.input {
  /* Corporate Enterprise base — identical to Example 02 */
  background: var(--bg-primary);
  color: var(--text-primary);
  padding: 12px 16px;
  border: 1px solid var(--border-default);
  border-radius: 4px;
  font-size: 16px;
  transition: border-color 200ms ease;
}
.input:focus {
  /* 20% MT influence: indigo accent focus ring instead of navy */
  border-color: var(--accent);
  box-shadow: 0 0 0 3px var(--accent-muted);
  outline: none;
}
```

### Cards — Compliance Status Cards (20% Minimal Tech Influence)

```css
/* Corporate Enterprise base card */
.card {
  background: var(--bg-primary);
  border: 1px solid var(--border-default);
  border-radius: 8px;
  padding: 32px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
}

/* Compliance metric card — MT data density influence */
.card--metric {
  background: var(--bg-primary);
  border: 1px solid var(--border-default);
  border-radius: 6px;           /* slightly tighter than CE's 8px */
  padding: 20px;                 /* denser than CE's 32px */
}
.card--metric__value {
  font-family: var(--font-mono); /* MT influence: mono for data */
  font-size: 32px;
  font-weight: 600;
  color: var(--text-primary);
  letter-spacing: -0.02em;
}
.card--metric__label {
  font-size: 12px;
  font-weight: 500;
  color: var(--text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.06em;
  margin-top: 4px;
}
```

### Navigation

Identical to [Example 02](02-corporate-enterprise-100.md) — navy header with white text. Corporate Enterprise controls navigation completely.

### Data Tables (20% Minimal Tech Influence)

```css
/* Corporate Enterprise table base with MT data treatment */
.table th {
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: var(--text-secondary);
  background: var(--bg-section);
  padding: 12px 16px;
  border-bottom: 1px solid var(--border-strong);
}
.table td {
  font-size: 14px;
  padding: 12px 16px;
  border-bottom: 1px solid var(--border-default);
}
/* MT influence: mono for IDs and technical data */
.table td.data--technical {
  font-family: var(--font-mono);
  font-size: 12px;
  color: var(--text-secondary);
}
.table tr:hover { background: var(--bg-section); }
```

---

## Interaction & Motion

Identical to [Example 02](02-corporate-enterprise-100.md) — 200-300ms deliberate pacing, no bounces, no springs. Corporate Enterprise's measured interaction philosophy applies throughout.

One addition: compliance status indicators pulse subtly (a 2s opacity cycle from 1.0 to 0.7) for "in progress" states — borrowed from Minimal Tech's convention for active/loading indicators in data-heavy interfaces.

---

## Trust Elements

Identical to Corporate Enterprise. SOC 2, ISO 27001, GDPR badges — but displayed more prominently here (hero section, not just footer) since compliance IS the product of this portal.

---

## Asset Guidelines

Same as Example 02 with one addition: data visualization for compliance dashboards (audit timeline charts, risk score gauges) follows Minimal Tech conventions — single accent color (indigo), clean axes, no 3D effects.

---

## Mixing Notes

### Elements Carrying the 20% Minimal Tech Accent (4 elements)

| Element | What Changed | Why |
|---------|-------------|-----|
| **Accent color** | Corporate gold → Indigo (#6366F1) | Security audience associates blue/violet tones with technology. Gold signaled "premium" which is wrong for a compliance context that needs to signal "precision." |
| **Monospace data labels** | Sans → JetBrains Mono for cert IDs, hashes, versions | Technical data in monospace reads as machine-verified and precise. Sans-serif for cert numbers would look like marketing, not engineering. |
| **Compliance metric cards** | 32px padding → 20px, 8px radius → 6px | Borrowed Minimal Tech's information density for the dashboard view. Enterprise padding is generous for prose; data dashboards need tighter packing. |
| **Focus ring accent** | Navy → Indigo | Consistent with the accent color swap. Focus rings using the primary navy would be hard to distinguish from the navy header. |

### What Was Considered and Rejected

| Candidate | Why Rejected |
|-----------|-------------|
| Dark mode | Conflicts with enterprise trust signaling. CISOs reviewing compliance docs in dark mode feels less authoritative. |
| Single sans-serif font (dropping serif headings) | Serif headings provide the gravitas that differentiates this from a generic dashboard. Dropping them would make it look like a SaaS app, not an institutional trust portal. |
| MT's 150ms transitions (faster than CE's 200ms) | Faster transitions would undermine the deliberate, measured feeling. Speed signals "startup"; this needs to signal "established." |
| Sidebar navigation (MT pattern) | CE's top navigation is more appropriate for a portal with shallow IA. Sidebar implies deep hierarchy (appropriate for docs, not a compliance portal). |

---

## Implementation Checklist

- [ ] Serif headings (Merriweather) + sans body (Inter) + mono data (JetBrains Mono)
- [ ] Navy primary for header and structure
- [ ] Indigo accent (not gold) for focus states, active items, chart highlights
- [ ] Monospace for all machine-readable data (cert IDs, hashes, versions, timestamps)
- [ ] Metric cards at 20px padding (denser than standard corporate cards)
- [ ] All other components follow Corporate Enterprise (buttons, nav, form inputs)
- [ ] Trust badges prominently placed (hero section)
- [ ] 200-300ms transitions throughout (Corporate Enterprise pacing)
- [ ] Light mode only
- [ ] WCAG AA compliance: all text meets contrast requirements
- [ ] Data tables use mono for technical columns, sans for descriptive columns

---

*Derived from: [corporate-enterprise.md](../corporate-enterprise.md) + [minimal-tech.md](../minimal-tech.md)*
*Example #7 of 10 — See [README.md](README.md) for full series*
