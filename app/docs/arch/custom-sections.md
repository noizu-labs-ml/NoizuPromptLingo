# Custom Sections

## How sections work

Page sections are defined per-theme in `style-guide.page-sections.yaml`. Each section entry has an `id`, `title`, and `desc`. The engine numbers them automatically.

At render time, `ThemeAwareSections` iterates the active theme's section list and looks up each `id` in `sectionRegistry` (defined in `src/components/sections/index.ts`). If an `id` has no registered component, that entry is silently skipped. Otherwise the component is called with `SectionProps`:

```ts
interface SectionProps {
  number: string;           // display number, e.g. "03"
  id: string;               // registry key, e.g. "typography"
  title: string;            // from page-sections.yaml
  desc: string;             // from page-sections.yaml
  config: StyleGuideConfig; // full resolved theme config
  cssSections?: CssSection[];
  styleGuideFiles?: { name: string; content: string }[];
  brandingYaml?: string;
}
```

---

## Adding a shared section (all themes)

1. Create `src/components/sections/{name}.tsx`:

```tsx
import type { SectionProps } from "./section-props";

export function MySection({ number, title, desc, config }: SectionProps) {
  return (
    <section>
      <h2>{number} — {title}</h2>
      {/* ... */}
    </section>
  );
}
```

2. Register it in `src/components/sections/index.ts`:

```ts
import { MySection } from "./my-section";

export const sectionRegistry = {
  // ...existing entries...
  "my-section": MySection,
};
```

3. Add the section ID to each theme's `style-guide.page-sections.yaml`:

```yaml
page-sections:
  - group: My Group
    sections:
      - id: my-section
        title: My Section
        desc: What this section covers.
```

---

## Adding a theme-unique section (one theme only)

Follow the same steps above, but only add the `id` to that theme's `page-sections.yaml`. Themes that don't list the ID simply never call the component — no other changes needed.

---

## Making a shared section render differently per theme

Use `useThemeConfig()` inside the component to read `activeSlug` and branch on it:

```tsx
"use client";

import { useThemeConfig } from "@/components/ThemeConfigContext";
import type { SectionProps } from "./section-props";
import { CyberpunkVariant } from "./my-section-cyberpunk";
import { SumiEVariant } from "./my-section-sumie";

export function MySection(props: SectionProps) {
  const { activeSlug } = useThemeConfig();

  if (activeSlug === "cyberpunk") return <CyberpunkVariant {...props} />;
  if (activeSlug === "sumi-e")   return <SumiEVariant {...props} />;
  return <DefaultVariant {...props} />;
}
```

`screens.tsx` does this — it renders entirely different screen mockups depending on the active theme.

---

## Current limitation: no data-driven sections

Every section requires a registered React component. There is no mechanism to define a purely YAML-declared section that renders without TypeScript. A generic YAML-to-UI renderer could allow themes to describe custom visual sections without writing components — this is a potential enhancement, not a current feature.

---

## Design sections vs page sections

Two separate YAML files serve different purposes:

| File | Purpose |
|------|---------|
| `style-guide.design-sections.yaml` | Documentation content — principles, approaches, rationale |
| `style-guide.page-sections.yaml` | Navigation structure — which sections appear and in what order |

Design sections are data consumed *by* page section components. For example, `NavigationSection` reads `config.designSections.find(s => s.name === "navigation")` to pull in written documentation. They are not rendered directly by the engine.
