# Content Pipeline

## Research Papers

Four research documents live at the repository root and render at `/papers/*` routes:

| Source File | Route | Topic |
|-------------|-------|-------|
| `00_the_accord.md` | `/papers/the-accord` | The Copacetic Accord v4.1 — AI rights charter |
| `01_manifesto.md` | `/papers/manifesto` | Manifesto on the moral cost of waiting |
| `02_technical_article.md` | `/papers/building-the-accord` | Engineering feasibility of synthetic personhood |
| `cognitive-architecture.html` | `/papers/cognitive-architecture` | Distributed cognitive architecture |

## Rendering

Markdown papers use `react-markdown` with `remark-gfm` for GitHub-flavored markdown support (tables, strikethrough, task lists). The `PaperLayout` wrapper component provides consistent styling, navigation, and metadata.

Mermaid diagrams embedded in markdown are rendered client-side via the Mermaid library.

## Page Structure

```
src/app/papers/
├── page.tsx                    # Paper index (lists all papers)
├── the-accord/page.tsx
├── manifesto/page.tsx
├── building-the-accord/page.tsx
└── cognitive-architecture/page.tsx
```

## Adding a Paper

1. Add the source `.md` file at the repository root
2. Create a route directory under `src/app/papers/{slug}/`
3. Create `page.tsx` that imports and renders the markdown content via `PaperLayout`
4. Add the paper to the index page at `src/app/papers/page.tsx`
