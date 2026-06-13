# Asset Manifest Schema

> v0.1 — Optional index file for multi-asset projects with dependency-aware batch generation.

---

## Purpose

An asset manifest (`assets.yaml`) is a lightweight index that lists which `.prompt` files belong to a project. It does **not** contain prompt content — that lives in individual `.prompt` files (see `asset-prompt-payload-schema.md`).

The manifest serves two purposes:
1. **Scoping** — explicitly declares which `.prompt` files are part of a generation batch (vs. scanning an entire directory tree)
2. **Cross-directory DAG** — enables dependency resolution across directories that wouldn't be discovered by a simple directory scan

---

## Schema

```yaml
# asset-manifest v0.1
project: string                    # Project identifier (e.g., "codefresh-styleguide")
description: string                # What this manifest generates

assets:
  - path: string                   # Relative path to a .prompt file (required)
    tags: [string]                 # Optional grouping tags (e.g., ["hero", "tier-1", "print"])

settings:
  output_dir: string               # Override output directory (default: same dir as .prompt file)
  default_model: string            # Default Gemini model for image generation
  default_variants: integer        # Default -n count (default: 1)
```

---

## Example

```yaml
# assets.yaml
project: codefresh-landing
description: Landing page demo assets — screenshots, animations, components

assets:
  - path: screens/landing-hero.png.prompt
    tags: [hero, tier-0]
  - path: screens/signup-modal.png.prompt
    tags: [modal, tier-1]
  - path: screens/pricing-page.png.prompt
    tags: [page, tier-1]
  - path: animations/hero-animation.mp4.prompt
    tags: [animation, tier-1]
  - path: components/signup-modal.ts.prompt
    tags: [component, tier-2]
  - path: audio/click-feedback.mp3.prompt
    tags: [audio, tier-0]

settings:
  default_model: imagen-3.0-generate-002
  default_variants: 1
```

---

## Usage with `generate-media-prompt`

```bash
# Generate all assets listed in the manifest
generate-media-prompt --manifest assets.yaml

# Generate only assets tagged "hero"
generate-media-prompt --manifest assets.yaml --tag hero

# Dry-run the full manifest
generate-media-prompt --manifest assets.yaml --dry-run
```

The tool reads the manifest, collects all referenced `.prompt` files, builds the dependency DAG from their `depends_on` fields, and processes in topological order. The manifest itself does not define dependencies — those live in the individual `.prompt` files.

---

## When to Use a Manifest vs. Directory Scan

| Approach | When |
|----------|------|
| `generate-media-prompt assets/` | All `.prompt` files in one directory, simple project |
| `generate-media-prompt --manifest assets.yaml` | Multi-directory layout, need tags/filtering, or cross-directory deps |

---

*Version: 0.1.0*
