# Blade of Eternity — Docs

## Cypress Test Attributes

### Specification

See [cypress-attributes.md](./cypress-attributes.md) for the full attribute schema, naming conventions, React helper (`cyAttrs`), custom Cypress commands, and example E2E flows.

### YAML Sidecar Files

Every component with `cyAttrs()` calls has a co-located `.cy.yaml` file documenting its test selectors. These files are the single source of truth for what selectors exist on each page — use them when writing or reviewing Cypress tests.

#### File locations

| Route / Component | Sidecar file |
|---|---|
| `/` (landing) | `web/src/app/page.tsx.cy.yaml` |
| `/create-character` | `web/src/app/create-character/page.tsx.cy.yaml` |
| `/game` | `web/src/app/game/page.tsx.cy.yaml` |
| `/login` | `web/src/app/login/page.tsx.cy.yaml` |
| `/signup` | `web/src/app/signup/page.tsx.cy.yaml` |
| `SiteHeader` / `SiteFooter` | `web/src/app/components/site-shell.tsx.cy.yaml` |

#### Schema

Each YAML file follows this structure:

```yaml
page: /route          # URL path (omitted for shared components)
component: PageName   # React component name(s)

selectors:
  - cy: role-name           # data-cy value (required)
    cy-id: instance-id      # data-cy-id — unique instance identifier
    cy-for: related-id      # data-cy-for — relationship pointer
    cy-value: assertable     # data-cy-value — scalar for assertions
    scope: scope-name        # data-cy-scope — logical region flag
    element: element-type    # DOM element or selector hint
    notes: context           # Conditional rendering, dynamic values, etc.
```

**Dynamic values** are wrapped in `{braces}` (e.g., `cy-id: "{race.id}"`) to indicate they vary at runtime. The comment after each describes the possible values.

#### Quick reference by page

**`/`** (12 selectors) — Page scope `landing`. Carousel has its own scope with `carousel-slide cy-value` tracking the active index, prev/next buttons, and dot indicators with `cy-id: slide-N` and `cy-value: active/inactive`. Cookie banner selectors for essential/accept-all buttons.

**`/create-character`** (27 selectors) — Page scope `create-character`. Race/class cards use `cy-id` for the slug and `cy-value: selected` on the active choice. Attribute rows use `cy-for` to link decrease/increase buttons, base/bonus/final values back to the attribute key. Preview section has its own scope.

**`/game`** (20 selectors) — Page scope `game`. Stats bar uses `cy-value` on progress bars for HP/energy/XP/gold. Action buttons are `cy-id`'d by kebab-cased action text. Effects are individually `cy-id`'d by name.

**`/login`** (8 selectors) — Scope `login`. Standard form selectors with `cy-id` distinguishing login-specific inputs (e.g., `login-email`, `login-password`).

**`/signup`** (8 selectors) — Scope `signup`. Same pattern as login, plus honeypot and confirm password fields.

**`SiteHeader` + `SiteFooter`** (14 selectors) — Header nav links use `cy-id` to distinguish login/signup/play. Footer modals use `cy-id`/`cy-for` pairing (e.g., `modal cy-id="terms"` + `modal-close cy-for="terms"`).

#### Keeping sidecars in sync

When you add or change a `cyAttrs()` call in a component, update the corresponding `.cy.yaml` file. The YAML is not auto-generated — it's maintained alongside the source as documentation for test authors.
