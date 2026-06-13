# Troubleshooting

## Token not appearing in output

- Is it a seed (defined in `style-guide.vars.yaml`) or auto-generated (computed in `defaults.ts`)?
- Trace the path: YAML → `normalizer.ts` (flatten var groups) → `resolveDefaults()` (4-pass cascade) → CSS generator → scoped output
- Check the rendered style guide's **Theme Config** section — it shows all resolved values
- If it's a computed token, verify the seed it depends on exists (see [cascade.md](./cascade.md) § "What seeds control what")

## Wrong token value

- YAML always wins (Pass 4 override). If the value is wrong and it's in YAML, that's your source.
- Check which pass computes it:
  - Pass 1: derived from seeds (`buildBaseTokens`)
  - Pass 2: foundation reference (`LEVEL_2`)
  - Pass 3: component property (`LEVEL_3`)
  - Pass 4: YAML override
- Check `scoped-vars` — a more specific selector may override the token at a narrower scope
- Use DevTools: inspect the element, check which `var(--*)` is applied and where it's declared

## Theme not switching

- Check `data-design-theme` attribute on `<html>` — must match the theme slug exactly
- Check `localStorage` key `"sg-theme"` — stale value may point to a removed theme
- Verify `ThemeCSS` component is mounted and loading per-theme CSS (`public/themes/{slug}.css`)
- Verify theme directory has `style-guide.meta.yaml` with a `slug` field that matches the directory name (`theme-{slug}`)

## CSS not regenerating after YAML changes

- Run `./regen.sh` — it clears `.cache/`, regenerates all CSS, and touches `globals.css` to trigger Tailwind rebuild
- **Never run `npx next build`** — it breaks the running dev server. Use `tsc --noEmit` for type checking.
- Check `.cache/` for stale files — `regen.sh` handles this, but manual deletion works too: `rm -rf .cache/`
- Verify the YAML file is in the correct `theme-*` directory (the loader globs `src/config/theme-*/style-guide.*.yaml`)
- Check the checksum: the cache is keyed by SHA-256 of all theme YAML sources. If the file wasn't picked up by `loadConfigRawForDir()`, the checksum won't change.

## Component looks wrong

- Find the component's var prefix (e.g., `card-*`, `btn-*`, `hui-field-*`) in the cascade doc's Pass 3 table
- Inspect the generated CSS: **Theme Config > generated.css** tab in the rendered style guide
- Trace through the cascade:
  1. Seed value (e.g., `unit: 8px`)
  2. Base token (e.g., `space-3: 24px`)
  3. Foundation (e.g., `control-height: var(--space-5)`)
  4. Component property (e.g., `btn-padding-y: var(--space-1)`)
  5. YAML override (if any)
- Check that the theme selector is being applied — component CSS is auto-scoped to `html[data-design-theme="slug"]`

## Type errors after changes

- Run `tsc --noEmit` (never `next build`)
- Common cause: YAML key doesn't match the TypeScript interface in `src/lib/types.ts`
- Check that new keys use kebab-case in YAML — the normalizer converts to camelCase for TS

## New theme not appearing in theme switcher

- Must have `style-guide.meta.yaml` with a valid `slug` field
- Directory must be named `theme-{slug}` (slug in the dirname must match slug in meta YAML)
- Run `./regen.sh` to generate CSS for the new theme
- Restart the dev server after adding a new theme directory — the file watcher may not pick up new directories

## Variant not loading

- Check `style-guide.overrides.yaml` has the correct `section → variant` mapping:
  ```yaml
  overrides:
    color-palette: user
  ```
- Verify variant file exists: `style-guide.{section}.{variant}.yaml` (three dot-separated parts)
- A missing variant file falls back to the base file **silently** — no error, no warning
- `null` or missing entry in overrides = use base file
- The variant file replaces the base file entirely (no merge). Include all values you need.

## Snippet not rendering

- Check `slug` is unique across all snippets — duplicates are deduped
- Check `target-section` matches a valid section ID in the rendered style guide
- Check `dependencies` reference existing snippet slugs
- **CSS snippets:** verify `body` is valid CSS (missing semicolons, unclosed braces)
- **JSX snippets:** verify `body` exports a named component
- CSS snippets are self-scoped — the engine does not prefix their selectors. You control your own selectors.
