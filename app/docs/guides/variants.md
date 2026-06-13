# Variants

Variants are alternate versions of a section file within the same theme. They let you swap out an entire section's config without creating a new theme.

## Naming convention

```
style-guide.{section}.{variant}.yaml
```

Examples:
```
style-guide.color-palette.user.yaml      # "user" variant of color-palette
style-guide.color-modes.user.yaml        # "user" variant of color-modes
style-guide.vars.minimal.yaml            # "minimal" variant of vars
```

Base files have two dot-separated parts: `style-guide.{section}.yaml`. Variant files have three: `style-guide.{section}.{variant}.yaml`.

## Activating variants

Each theme has a `style-guide.overrides.yaml` that maps section names to variant strings:

```yaml
# style-guide.overrides.yaml
overrides:
  color-palette: user
  color-modes: user
```

This tells the loader: for `color-palette`, load `style-guide.color-palette.user.yaml` instead of `style-guide.color-palette.yaml`.

An empty overrides file (or no file at all) means all sections use their base files:

```yaml
overrides: {}
```

## How the loader resolves

For each base section file in the theme directory:

1. Read `style-guide.overrides.yaml` to get the manifest
2. Look up `manifest.overrides[section]` — if no entry, use the base file
3. If an entry exists (e.g. `"user"`), construct `style-guide.{section}.user.yaml`
4. Check if that file exists on disk — if yes, load it; if no, **fall back to the base file silently**

```
resolveFiles():
  for each style-guide.{section}.yaml:
    variant = manifest.overrides[section]
    if !variant → use base
    if variant → check style-guide.{section}.{variant}.yaml exists
      exists → use variant file
      missing → use base file (no error)
```

A missing variant file is not an error. The loader falls back to the base file without warning.

## Listing available variants

`listVariants()` in `src/config/loader.ts` scans the theme directory for all three-part filenames and returns a map:

```ts
import { listVariants } from "@/config/loader";

const variants = listVariants();
// { "color-palette": ["user"], "color-modes": ["user"] }
```

Keys are section names. Values are arrays of available variant strings for that section.

## Variants vs theme inheritance

| Mechanism | Use case | Scope |
|-----------|----------|-------|
| **Variants** | Same theme, different options for a section | Single section file swap within one theme |
| **Base theme inheritance** | Different theme, shared foundation | Entire theme falls back to another theme's files |

Use variants when you want to offer alternate palettes, color modes, or component configs within a single theme. Use inheritance when building a new theme that shares structure with an existing one.

## Creating a variant

1. Copy the base section file:
   ```
   cp style-guide.color-palette.yaml style-guide.color-palette.dark.yaml
   ```

2. Edit the copy with your alternate values

3. Activate it in `style-guide.overrides.yaml`:
   ```yaml
   overrides:
     color-palette: dark
   ```

4. Run `./regen.sh` to rebuild CSS

The variant file replaces the base file entirely — it is not merged with it. Include all values you need.

## Current variants

```
theme-style-guide/
  style-guide.color-palette.user.yaml   # alternate surface/color palette
  style-guide.color-modes.user.yaml     # alternate light/dark mappings
```

Neither is currently active (`overrides: {}`).
