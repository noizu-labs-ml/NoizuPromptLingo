# Component bundles (W7 component-exchange registry)

Served keyed via `GET /api/v1/components/:name/bundle`
(`NoizuPromptLinguaWeb.ComponentController` + `NoizuPromptLingua.Components`).

These files are **build artifacts** synced from the authored Lit packages —
do not edit by hand. Source of truth per component:

| Component         | Authored package                                   | Synced file                        |
|-------------------|----------------------------------------------------|------------------------------------|
| `npl-queue-board` | `frontend/packages/npl-queue-board` (build → dist) | `npl-queue-board/npl-queue-board.js` |

To sync after rebuilding a package:

```bash
cp frontend/packages/<name>/dist/<entry>.js backend/priv/components/<name>/<entry>.js
```

Bundles are immutable per version: bump `version` in
`NoizuPromptLingua.Components` whenever the synced bytes change, and commit
both together. The registry endpoint advertises the version and serves the
bundle with `cache-control: public, max-age=31536000, immutable`.
