# Project Scaffold — Full-Stack Setup from Template

How to create a new portfolio project with a working Elixir backend, Next.js frontend, nginx reverse proxy, and integrated design system — all from the `start-app` template.

---

## Agent Runbook — "Scaffold Project X"

When asked to scaffold a project, follow this sequence exactly. **Read before you run.**

### Step 0: Gather Context

Before running anything, read these files for the target project:

| File | Why |
|------|-----|
| `projects/{domain}/README.md` | Project identity, audience, technical direction |
| `projects/{domain}/design/style-guide.md` | Visual design (colors, typography, spacing, components) — if it exists |
| `projects/{domain}/design/SITEMAP.md` | Information architecture — if it exists |

If the project doesn't exist under `projects/` yet, it needs to be a git submodule first. Check with the user.

### Step 1: Look Up the Slug

Every project has a pre-registered slug in the Makefile's SLUG_MAP. **Do not guess.** Find it in the table in §"Existing Project Slugs" below, or check:

```bash
grep -A1 'SLUG_MAP' start-app/Makefile
```

### Step 2: Run the Scaffold

```bash
init-proj-scaffold <domain> <slug> <ElixirModule>
```

The script is at `bin/init-proj-scaffold`. It's on PATH via `.envrc`.

**What it does** (no user intervention needed):
1. Builds/caches tarball from `start-app/` (skips if fresh)
2. Extracts to `projects/<domain>/`
3. Hydrates all `Starter` → `<Module>` in Elixir files, Dockerfiles, package.json
4. Renames `lib/starter/` → `lib/<otp_app>/`
5. Registers DB user + databases in Postgres (if running) and in `docker/postgres/init-databases.sh`
6. Registers Redis ACL in `docker/redis/users.acl`

**It will fail if** `projects/<domain>/app/` already exists (the check is `[[ ! -d "$TARGET" ]]`). The project root (`projects/<domain>/`) is expected to already exist with design artifacts — the script creates the `app/` subdirectory inside it.

### Step 3: Initialize Environment

```bash
cd projects/<domain>/app
make init
```

This generates `.env`, `backend/.env`, `frontend/.env` with random secrets.

### Step 4: Convert Design Artifacts to Frontend

This is the key step most agents miss. After scaffolding, the frontend has a **generic base theme** (`theme-style-guide/`) with placeholder content. You need to customize it in place for your project.

Design artifacts live at the project root (`projects/<domain>/design/`). The app code lives in the `app/` subdir. You're bridging them.

**4a. Edit the existing theme YAML** in `app/frontend/src/config/theme-style-guide/`:

Do NOT create a new `theme-{slug}/` directory. Edit the files that are already there. The base theme ships with descriptive placeholder content — replace it with your project's actual values.

| File | Source | What to Change |
|------|--------|----------------|
| `style-guide.meta.yaml` | Project name + slug | `name`, `slug`, `title`, `description` |
| `branding.yaml` | Style guide §Scenario + README | `name`, `logo-text`, `intent`, `perception`, `audience`, `tone`, `keywords`, `intro` |
| `style-guide.vars.yaml` | Style guide §Color Palette + §Typography + §Spacing | Seed colors, font stacks, spacing, radius, and all component token groups |
| `style-guide.color-palette.yaml` | Style guide §Color Palette | Swatch groups, usage notes |
| `style-guide.color-modes.yaml` | Style guide §Color Palette (light/dark) | **Required.** Distinct light AND dark values for surface, text, border, accent surfaces, text-link, focus-ring. Light mode needs darkened accents for contrast on light backgrounds. |
| `style-guide.typography.yaml` | Style guide §Typography | Font families, weights, typography classes |
| `style-guide.css-snippets.yaml` | Style guide §Components | Component CSS scoped to your theme |
| `style-guide.scoped-vars.yaml` | Style guide §Color Palette + §Spacing | **Required.** Must have distinct `standard` (light) and `dark` section values for all surface/text/border tokens. |
| `style-guide.semantic-classes.yaml` | Style guide §Color Palette (states) | Danger/warning/success/info/primary/brand |
| `style-guide.globals.yaml` | (optional) | Selection color, font smoothing |
| `style-guide.page-layouts.yaml` | Style guide §Spacing (grid) | Page width, padding, chrome zones |
| `style-guide.shell-layouts.yaml` | Style guide §Layout | Navbar, sidebar, footer configs |
| `style-guide.glyphs.yaml` | Style guide §Iconography | Unicode glyph set |
| `style-guide.semantic-groups.yaml` | (optional) | Group labels for semantic classes |

**Seed mapping** — `style-guide.vars.yaml` has named groups. The engine's cascade needs these seeds at minimum:

| Engine Seed | Where to Find in Style Guide |
|-------------|------------------------------|
| `white` | Lightest background or `#ffffff` |
| `black` | Darkest background or text color |
| `red` (or primary accent) | Primary accent color |
| `blue` (or secondary accent) | Secondary accent / info color |
| `font-sans` | Body font stack |
| `font-mono` | Monospace font stack |
| `radius` | Border radius base value |
| `success`, `warning`, `error`, `info` | State colors |

The cascade expands ~12 seeds into ~300 CSS custom properties. The base theme has all groups pre-populated with placeholder values — edit them to match your style guide.

**Important:** When editing `style-guide.css-snippets.yaml` and `style-guide.scoped-vars.yaml`, update the CSS selectors from `html[data-design-theme="style-guide"]` to match whatever slug you set in `style-guide.meta.yaml`.

**4b. Update layout.tsx** — set the `data-design-theme` attribute to match your slug, and update the page metadata:

```tsx
<html lang="en" data-design-theme="<slug>">
```

File: `app/frontend/src/app/layout.tsx`

**4c. Convert SITEMAP.md to sitemap page.tsx**:

The sitemap page at `app/frontend/src/app/sitemap/page.tsx` ships with a generic template. Replace its mermaid diagrams and inventory table with content from `design/SITEMAP.md`:

| SITEMAP.md Section | → sitemap/page.tsx |
|---|---|
| Page Flow `graph LR` | Top `<pre className="mermaid">` block |
| Per-page `graph TD` diagrams | Individual `<section>` blocks with `<pre className="mermaid">` |
| Page Inventory table | `<table className="spec-table">` rows |

See `outputs/sitemap.md` §5 for the exact translation.

**4d. Regenerate CSS**:

```bash
make regen
```

### Step 5: Generate Product Management Artifacts

After the scaffold is in place, generate the product management foundation:

```
Personas → User Stories → Screens → Components
```

This creates `projects/<domain>/project-management/` with personas, 100 user stories, screen inventory, and component library. These artifacts feed into the sitemap and inform wireframing.

See `outputs/product-management-artifacts.md` for the full pipeline.

### Step 6: Verify

```bash
cd frontend && npm install && npm run dev
```

Check:
- `http://localhost:3000/` — landing page loads
- `http://localhost:3000/styleguide` — shows project theme (not base theme)
- `http://localhost:3000/sitemap` — shows project-specific diagrams

### Reference Chain

When you need deeper detail, read in this order:

| Question | Read |
|----------|------|
| How does the scaffold script work? | This file §"What the Script Does" or `bin/init-proj-scaffold` directly |
| How do I generate personas and stories? | `outputs/product-management-artifacts.md` |
| How do I structure theme YAML? | `outputs/engine-styleguide.md` §5-6 (section-to-YAML mapping + templates) |
| How do I convert SITEMAP.md to TSX? | `outputs/sitemap.md` §5 (translation process) |
| What components can I import? | `outputs/engine-styleguide.md` §10 (component reference) |
| What does the full-stack architecture look like? | `start-app/docs/PROJ-ARCH.md` |
| What files are in the template? | `start-app/docs/PROJ-LAYOUT.md` |

---

## Prerequisites

- Docker running with `lets-go` compose stack (`docker compose up -d` from repo root)
- `bin/` on PATH (handled by `.envrc` / direnv)
- `@noizu/styleguide` package available via Verdaccio (`npm.noizu.com`)

## Quick Start

```bash
init-proj-scaffold <project_dir> <slug> <elixir_module>
```

**Example:**
```bash
init-proj-scaffold therobotlives.com trl Trl
```

| Argument | Description | Example |
|----------|-------------|---------|
| `project_dir` | Domain name — becomes directory under `projects/` | `therobotlives.com` |
| `slug` | Short name for DB user, Redis prefix, npm package name | `trl` |
| `elixir_module` | PascalCase Elixir module name | `Trl`, `TheRobotLives` |

## What the Script Does

### 1. Builds/caches a tarball from `start-app/`

Excludes build artifacts (`node_modules`, `_build`, `deps`, `.next`), generated files (`design-system.generated.css`, `*.tsbuildinfo`), and secrets (`.env`). Rebuilds automatically when source files change.

### 2. Extracts to `projects/<project_dir>/app/`

Creates the `app/` subdirectory inside the existing project:

```
projects/<project_dir>/
├── README.md               # Already exists — project identity
├── design/                 # Already exists — style guide, SITEMAP.md
├── docs/                   # Already exists — project documentation
└── app/                    # ← created by scaffold
    ├── Makefile                # Docker build, env init, lifecycle
    ├── docker-compose.yaml     # Backend + frontend + nginx
    ├── .env.example            # Template env vars
    ├── scripts/gen-env.sh      # Generates .env files with secrets
    ├── frontend/               # Next.js 15 app
    │   ├── package.json
    │   ├── src/app/            # Pages: /, /styleguide, /sitemap
    │   ├── src/config/         # Theme YAML files
    │   └── src/scripts/        # CSS generation
    ├── backend/                # Phoenix/Elixir
    │   ├── mix.exs
    │   ├── lib/<otp_app>/      # Contexts (Accounts, etc.)
    │   ├── lib/<otp_app>_web/  # Controllers, router, endpoint
    │   └── config/             # dev.exs, runtime.exs, etc.
    └── nginx/                  # Reverse proxy
        └── nginx.conf
```

### 3. Hydrates all template names

Replaces every occurrence of the template placeholders with project-specific names:

| Template Token | Replaced With | Where |
|----------------|---------------|-------|
| `Starter` | `<elixir_module>` (e.g. `Trl`) | All `.ex`, `.exs` files |
| `StarterWeb` | `<elixir_module>Web` (e.g. `TrlWeb`) | All `.ex`, `.exs` files |
| `:starter` | `:<otp_app>` (e.g. `:trl`) | OTP app name in configs |
| `"starter"` | `"<otp_app>"` | Guardian issuer, DB defaults |
| `starter_dev` | `<slug>_dev` | DB password defaults |
| `rel/starter` | `rel/<otp_app>` | Dockerfile release path |
| `bin/starter` | `bin/<otp_app>` | Dockerfile entrypoint |
| `starter-frontend` | `<slug>-frontend` | package.json name |

**Derived values:**
- `otp_app` — snake_case of elixir_module: `Trl` → `trl`, `TheRobotLives` → `the_robot_lives`
- `db_name` — project_dir with `.`/`-` → `_` + `_dev`: `therobotlives.com` → `therobotlives_com_dev`

**File/directory renames:**
```
backend/lib/starter.ex      → backend/lib/<otp_app>.ex
backend/lib/starter_web.ex  → backend/lib/<otp_app>_web.ex
backend/lib/starter/        → backend/lib/<otp_app>/
backend/lib/starter_web/    → backend/lib/<otp_app>_web/
```

### 4. Registers DB + Redis

- **Postgres:** Creates role + dev/test databases against running container, enables timescaledb + age extensions
- **init-databases.sh:** Appends entries so future `docker compose up` with fresh volumes auto-creates the DBs
- **Redis ACL:** Appends user entry scoped to project's key prefix

### 5. Prints summary with next steps

## Post-Scaffold Setup

After `init-proj-scaffold` completes:

```bash
cd projects/<project_dir>/app
```

### Generate Environment

```bash
make init
```

Creates `.env`, `backend/.env`, `frontend/.env` with generated secrets, correct DB credentials, and Redis URLs.

### Set Up the Design System

1. **Theme YAML files** live in `app/frontend/src/config/theme-style-guide/`. The scaffold includes placeholder content with documentation comments. Edit these files in place to match your `design/style-guide.md` — do not create a separate theme directory.
   - See `outputs/engine-styleguide.md` for YAML structure and field reference

2. **Regenerate CSS** from theme YAML:
   ```bash
   make regen
   ```

3. **Preview in the engine** (from repo root):
   ```bash
   ./serve-project.sh <project_dir>
   ```
   This symlinks the project's themes into the styleguide-engine for interactive preview.

### Set Up the Frontend

The frontend is a Next.js 15 app using `@noizu/styleguide` for components and the design system.

1. **Install dependencies:**
   ```bash
   cd app/frontend && npm install
   ```

2. **Verify `.npmrc`** points to Verdaccio (`npm.noizu.com`) for the `@noizu` scope.

3. **Run dev server:**
   ```bash
   npm run dev
   ```
   Frontend serves on `http://localhost:3000` by default.

4. **Key pages:**
   - `/` — Landing page (edit `app/frontend/src/app/page.tsx`)
   - `/styleguide` — Interactive style guide viewer
   - `/sitemap` — Site architecture with mermaid diagrams

### Set Up the Backend

The backend is an Elixir/Phoenix API with Guardian auth, Ecto/Postgres, and Redis.

1. **Install dependencies:**
   ```bash
   cd app/backend
   source .env     # Load DB credentials
   mix deps.get
   ```

2. **Run migrations:**
   ```bash
   mix ecto.create   # (skip if init-proj-scaffold already created the DB)
   mix ecto.migrate
   ```

3. **Seed data:**
   ```bash
   mix run priv/repo/seeds.exs
   ```

4. **Run dev server:**
   ```bash
   mix phx.server
   ```
   Backend serves on `http://localhost:4000`.

5. **Key modules:**
   - `lib/<otp_app>/accounts.ex` — User context
   - `lib/<otp_app>/guardian.ex` — JWT auth
   - `lib/<otp_app>_web/router.ex` — API routes
   - `lib/<otp_app>_web/controllers/` — Controllers

### Docker Build & Run

For the full containerized stack (backend + frontend + nginx):

```bash
make build    # Build all Docker images
make run      # Start containers (nginx on :8080)
```

The nginx proxy routes:
- `/` → frontend (Next.js)
- `/api/*` → backend (Phoenix)
- `/health` → backend health check

### Other Makefile Commands

| Command | Purpose |
|---------|---------|
| `make init` | Generate .env files with secrets |
| `make regen` | Regenerate CSS from theme YAML |
| `make build` | Build all Docker images |
| `make run` | Start all containers |
| `make stop` | Stop containers |
| `make logs` | Tail container logs |
| `make restart` | Stop + rebuild + start |
| `make clean` | Remove containers, volumes, images |

## Existing Project Slugs

These are already registered in the Makefile's SLUG_MAP:

| Project | Slug | Redis DB |
|---------|------|----------|
| `bladeofeternity.com` | `boe` | 0 |
| `aifighter.com` | `aifighter` | 1 |
| `codefre.sh` | `codefresh` | 2 |
| `derobot.is` | `derobot` | 3 |
| `gotta.cc` | `gotta_cc` | 4 |
| `iotgo.io` | `iotgo` | 5 |
| `jailbreakingsite.com` | `jailbreaking` | 6 |
| `noizurpg.com` | `noizurpg` | 7 |
| `robots-unite.com` | `robots_unite` | 8 |
| `therobotknows.com` | `therobotknows` | 9 |
| `therobotlives.com` | `therobotlives` | 10 |
| `therobotmakes.com` | `therobotmakes` | 11 |

## Template Source

The scaffold is built from `start-app/` at the repo root. Changes to the template are automatically picked up on the next `init-proj-scaffold` run (tarball rebuilds when source is newer).

**Template stack:**
- **Backend:** Phoenix 1.8, Ecto, Guardian (JWT), Bandit, Postgres 16, Redis 7
- **Frontend:** Next.js 15, React 19, Tailwind CSS 4, `@noizu/styleguide`
- **Infra:** nginx reverse proxy, Docker Compose on shared `lets-go_default` network
