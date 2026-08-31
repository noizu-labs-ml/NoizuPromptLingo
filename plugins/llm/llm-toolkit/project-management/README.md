# Claude Assist — Project Management

Product-management artifacts for Claude Assist: who it's for, what it should do, and where the work stands. Generated 2026-08-04.

## Contents

| Directory / file | What's in it |
|---|---|
| [`personas/`](personas/) | 8 user personas (`P-001`–`P-008`) covering primary/secondary/tertiary/edge-case segments — solo developer, staff engineer, ML engineer, skill author, eng lead, OSS maintainer, novice user, multi-provider tinkerer. `index.yaml` lists all of them. |
| [`user-stories/`](user-stories/) | 100 user stories (`US-001`–`US-100`) across 18 epics, each MoSCoW-prioritized (must/should/could/wont-have) and cross-referenced to the personas above. `index.yaml` lists all of them. |
| [`screens/`](screens/) | Screen inventory extracted from the user stories — one file per distinct UI view/flow, with the stories and components each screen touches. May still be generating; once complete it will cover every route in [`design/SITEMAP.md`](../design/SITEMAP.md) plus modal/wizard flows (Convert, Merge, first-run onboarding). |
| [`components/`](components/) | Reusable UI component inventory extracted from the screens — the scope for the design system. May still be generating; once complete it will cover shared components (SearchBar, ThreadCard, DiffView, QualityBar, etc.) with size variants and interaction notes. |
| [`ROADMAP.md`](ROADMAP.md) | Phased forward roadmap (m4–m7) derived from the epic × priority matrix in `user-stories/`, plus a shipped-feature summary (m1–m3) and outstanding design debt. |

## How these cross-reference

```
personas/  ──┐
              ├──> user-stories/  ──> screens/  ──> components/
              │         │
              │         └──> ROADMAP.md (epics × priority → phases)
              └─────────────────────────┘ (persona IDs cited in both)
```

- Every user story cites the persona(s) it serves (`personas: [P-001, ...]`).
- Every screen (once generated) cites the story IDs it satisfies.
- Every component (once generated) cites the screens it appears in.
- `ROADMAP.md` groups stories by epic and priority into forward phases — it doesn't duplicate story content, just sequences it.

For the shipped-vs-planned feature state, start with `ROADMAP.md`'s "Shipped" section. For UI/IA context, see [`../design/SITEMAP.md`](../design/SITEMAP.md) and [`../design/README.md`](../design/README.md).
