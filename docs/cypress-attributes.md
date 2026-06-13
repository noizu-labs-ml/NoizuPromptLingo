In regards to my requirements for the frontend to facilitate testing

cypress does a poor job of describing how to do this in a non fragile way so here are notes


# 1) Selector philosophy

**Goals**

* Stable across refactors (no classes, no nth-child).
* Descriptive of **role** and **instance**.
* Express **relationships** even when elements aren't nested (menus, modals, flyouts, portaled dropdowns).

**Attribute schema**

* `data-cy="<role>"` → the component's *semantic role* (e.g., `header`, `filters`, `results`, `filter-result`, `dropdown-menu`).
* `data-cy-id="<instance-id>"` → unique instance identifier (e.g., slug or id).
* `data-cy-for="<instance-id>"` → relationship pointer to another component's `data-cy-id` (think `<label for="">`).
* Optional: `data-cy-value="<value>"` for asserted scalar values (e.g., stars=3.6).
* Optional scope flag: `data-cy-scope` on containers that define a logical region.

**Naming**

* Use kebab-case for roles/ids to keep selectors compact and readable.
* Make `data-cy-id` business-stable: slugs, database IDs—**never** array index.

---

# 2) Page semantics (suggested skeleton/conceptual view of nesting to help understand how selctor logic works)

Even if parts aren't DOM-nested, communicate the logical structure:

html
<header data-cy="header" data-cy-id="site-header">
  <nav data-cy="navbar" data-cy-id="main-nav"></nav>
</header>

<main data-cy="top-rated-nonprofits" data-cy-scope>
  <section data-cy="filters" data-cy-id="search-filters">
    <ol data-cy="issue-filter">
      <li data-cy="issue-filter-option" data-cy-id="animals">Animals</li>
      <!-- ... -->
    </ol>

    <div data-cy="view-mode">
      <button data-cy="show-table-view">Table</button>
      <button data-cy="show-card-view">Cards</button>
    </div>
  </section>

  <section data-cy="results" data-cy-id="search-results">
    <span
      data-cy="filter-results"
      data-cy-filter-total="395"
      data-cy-filter-issue="all"
    >
      395 Top-Rated …
    </span>

    <div data-cy="table-view">
      <div
        class="row"
        data-cy="filter-result"
        data-cy-id="org-slug-123"
      >
        <span data-cy="location" data-cy-id="512342">Boston, MA</span>
        <span data-cy="stars" data-cy-value="3.6">★★★☆</span>
      </div>
      <!-- more rows -->
    </div>
  </section>
</main>

<footer data-cy="footer" data-cy-id="site-footer"></footer>

**Cross-linked, non-nested UI (menus, dropdowns, portals)**

html
<!-- The menu button -->
<div class="menu-item"
     data-cy="dropdown-menu"
     data-cy-id="for-nonprofits-menu">
  For Nonprofits
</div>

<!-- The portaled dropdown list -->
<div class="menu-dropdown"
     data-cy="dropdown-menu-list"
     data-cy-for="for-nonprofits-menu">
  <a data-cy="dropdown-item" data-cy-id="pricing">Pricing</a>
  <a data-cy="dropdown-item" data-cy-id="resources">Resources</a>
</div>

That pair lets you select the button and find the corresponding list via the shared id, no matter where the list is rendered.

---

# 3) Lightweight React helpers (so authors don't forget)

The `cyAttrs` utility is available in `src/utils/cypress.ts`:

tsx
// src/utils/cypress.ts
type Cy = {
  cy?: string;
  cyId?: string;
  cyFor?: string;
  cyValue?: string | number;
  cyScope?: string;
};

export const cyAttrs = ({ cy, cyId, cyFor, cyValue, cyScope }: Cy = {}) => ({
  ...(cy && { 'data-cy': cy }),
  ...(cyId && { 'data-cy-id': String(cyId) }),
  ...(cyFor && { 'data-cy-for': String(cyFor) }),
  ...(cyValue !== undefined && { 'data-cy-value': String(cyValue) }),
  ...(cyScope && { 'data-cy-scope': cyScope }),
});


**Usage patterns**

The utility spreads `data-cy-*` attributes directly into JSX props:

tsx
import { cyAttrs } from '@/utils/cypress';

// Basic element with role
<Button {...cyAttrs({ cy: 'submit-button' })}>
  Submit
</Button>

// Element with role + unique ID
<OrganizationCard {...cyAttrs({ cy: 'org-card', cyId: org.slug })}>
  {org.name}
</OrganizationCard>

// Scoped container (identifies a logical region/module)
<section {...cyAttrs({ cy: 'search-results', cyScope: 'top-rated-nonprofits' })}>
  {/* ... */}
</section>

// Element with dynamic value assertion
<StarRating
  {...cyAttrs({ cy: 'stars', cyValue: rating })}
  value={rating}
/>

// Cross-linked UI (menu button + portaled dropdown)
<MenuButton {...cyAttrs({ cy: 'dropdown-menu', cyId: 'for-nonprofits' })}>
  For Nonprofits
</MenuButton>

// Somewhere else in the DOM (portal):
<MenuList {...cyAttrs({ cy: 'dropdown-menu-list', cyFor: 'for-nonprofits' })}>
  <MenuItem>Pricing</MenuItem>
</MenuList>


**Mixing with other props**

The spread operator lets you combine `cyAttrs` with any other props:

tsx
// Merge with existing props on MUI components
<TextField
  fullWidth
  label="Email"
  value={email}
  onChange={handleChange}
  {...cyAttrs({ cy: 'email-input', cyId: 'login-email' })}
/>

// Conditional attributes
<Button
  type="submit"
  disabled={!isValid}
  {...cyAttrs({
    cy: 'submit-button',
    cyValue: isValid ? 'enabled' : 'disabled'
  })}
>
  Sign In
</Button>

// Last-in-wins for attribute override
<div
  data-testid="legacy-id"
  {...cyAttrs({ cy: 'new-role' })}
>
  {/* cyAttrs merges cleanly with other data-* attributes */}
</div>


**Reusable component example**

tsx
type MenuItemProps = React.PropsWithChildren<{
  id: string;
  cy?: string;
  cyId?: string;
}>;

export function MenuItem({ id, children, cy = 'dropdown-menu', cyId }: MenuItemProps) {
  return (
    <div {...cyAttrs({ cy, cyId: cyId ?? id })}>
      {children}
    </div>
  );
}

type MenuListProps = React.PropsWithChildren<{ forId: string; cy?: string }>;

export function MenuList({ forId, children, cy = 'dropdown-menu-list' }: MenuListProps) {
  return (
    <div {...cyAttrs({ cy, cyFor: forId })}>
      {children}
    </div>
  );
}

**Patterns to bake into reusable components**

* Every component that renders a "thing that can be addressed" accepts `cy`, `cyId`, (and if related, `cyFor`).
* Page templates place `data-cy-scope` on their main region wrapper (e.g., `data-cy="top-rated-nonprofits"`).
* Lists use domain ids/slugs as `data-cy-id` for each row/card.

---

# 4) Cypress-side ergonomics (custom commands)

Create ergonomic commands so tests read like plain English.

ts
// cypress/support/commands.ts
declare global {
  namespace Cypress {
    interface Chainable {
      getByCy(name: string, options?: Partial<Loggable & Timeoutable>): Chainable<JQuery<HTMLElement>>;
      getByCyId(name: string, id: string | number): Chainable<JQuery<HTMLElement>>;
      getByCyFor(name: string, forId: string | number): Chainable<JQuery<HTMLElement>>;
      withinScope(scopeName: string, fn: () => void): Chainable<void>;
      pair(name: string, id: string | number): Chainable<{ root: JQuery<HTMLElement>, mate: JQuery<HTMLElement> }>;
    }
  }
}

Cypress.Commands.add('getByCy', (name, options) =>
  cy.get(`[data-cy="${name}"]`, options)
);

Cypress.Commands.add('getByCyId', (name, id) =>
  cy.get(`[data-cy="${name}"][data-cy-id="${id}"]`)
);

Cypress.Commands.add('getByCyFor', (name, forId) =>
  cy.get(`[data-cy="${name}"][data-cy-for="${forId}"]`)
);

Cypress.Commands.add('withinScope', (scopeName, fn) => {
  cy.get(`[data-cy="${scopeName}"][data-cy-scope]`).within(fn);
});

Cypress.Commands.add('pair', (name, id) =>
  cy.wrap(null).then(() => {
    const rootSel = `[data-cy="${name}"][data-cy-id="${id}"]`;
    const mateSel = `[data-cy="${name}-list"][data-cy-for="${id}"]`;
    return cy.get(rootSel).then(root => {
      return cy.get(mateSel).then(mate => ({ root, mate }));
    });
  })
);

Now tests don't need to know about layout tricks—just the semantics.

---

# 5) Example E2E flows for the page you described

### A) Switch to table view, assert header counts & an org row

ts
cy.withinScope('top-rated-nonprofits', () => {
  cy.getByCy('show-table-view').click();

  cy.getByCy('filter-results')
    .should('have.attr', 'data-cy-filter-issue', 'all')
    .and('have.attr', 'data-cy-filter-total')
    .then(total => {
      expect(Number(total)).to.be.greaterThan(0);
    });

  const orgSlug = 'org-slug-123';
  cy.getByCyId('filter-result', orgSlug).as('row');

  cy.get('@row').should('be.visible');
  cy.get('@row').find('[data-cy="location"][data-cy-id="512342"]').should('contain.text', 'Boston');
  cy.get('@row').find('[data-cy="stars"]').should('have.attr', 'data-cy-value', '3.6');

  // Visual checkpoint (optional)
  cy.get('@row').screenshot(`row-${orgSlug}`);
});

### B) Cross-linked dropdown without DOM nesting

ts
const menuId = 'for-nonprofits-menu';

cy.getByCyId('dropdown-menu', menuId).click();
cy.getByCyFor('dropdown-menu-list', menuId)
  .should('be.visible')
  .within(() => {
    cy.getByCyId('dropdown-item', 'resources').click();
  });

### C) Sorting by stars & verifying order

ts
cy.withinScope('top-rated-nonprofits', () => {
  cy.getByCy('sort-by-stars').click();

  // Assert descending order by data-cy-value
  cy.get('[data-cy="filter-result"] [data-cy="stars"]')
    .then(nodes => [...nodes].map(n => parseFloat(n.getAttribute('data-cy-value') || '0')))
    .then(values => {
      const sorted = [...values].sort((a,b) => b - a);
      expect(values, 'stars sorted desc').to.deep.equal(sorted);
    });
});

---

# 6) Handling async data and stability

* **Network intercepts**: alias the queries that power results so you can wait on them deterministically.

ts
  cy.intercept('GET', '/api/search*').as('search');
  cy.getByCy('apply-filters').click();
  cy.wait('@search');
  
* **Pagination/infinite scroll**: emit a `data-cy` on the "load more" trigger (`data-cy="load-more"`) and add `data-cy-id` with the page number or cursor for precise targeting.
* **Portals/modals**: same attributes; portals don't affect `cy.get(...)` since queries are document-wide.

---

# 7) Component design tips (to make it simple later)

* **All reusable components** accept `cy`, `cyId`, `cyFor` props and pass them to the root element (or the focusable/interactive element if more appropriate).
* **List items** take a **required** `id` or `slug` prop—used for `data-cy-id`.
* **Derived values** you'll assert (rating, counts, etc.) are reflected in `data-cy-value` attributes. That avoids brittle text parsing.
* **Scopes in templates**: page templates define one `data-cy-scope` region (e.g., the main content area) so tests can constrain `within(...)` and remain immune to header/footer side effects.

---

# 8) Should these attributes ship to prod?

Yes. They're harmless and stable:

* Zero visual impact; minuscule payload cost; huge debugging upside in production screenshots.
* Don't gate by `NODE_ENV`; tests that hit staging vs prod will keep working.

---

# 9) Linting & conventions you can enforce

* ESLint rule (or PR checklist) to **forbid class-based Cypress selectors**.
* Require `data-cy` on interactive controls and region wrappers in app templates.
* Ban selectors using `nth-*`, `.class`, inline text, and SVG paths in the test code.

---

# 10) Quick migration guide

1. Identify **page regions** (header, navbar, filters, results, footer) → add `data-cy`.
2. For **cross-linked UI** (menus, dropdowns, modals), add `data-cy-id` on the trigger and `data-cy-for` on the portaled content (or vice-versa).
3. For **lists**, add `data-cy-id` per item using a stable slug/id. Mirror key numeric/textual data in `data-cy-value`.
4. Add the **Cypress custom commands** so all tests use the new API.
5. Update old tests to the new selectors; delete class-based selectors.

---

# 11) Extra niceties

* **ARIA-first when possible**: you can combine `role` queries with `data-cy` for readability (`[role="navigation"][data-cy="navbar"]`), but don't *depend* on role only.
* **Visual testing**: your semantic structure makes scoping screenshots trivial (e.g., `cy.getByCy('results').screenshot('results-after-filter')`).
* **i18n-proof**: because assertions prefer `data-cy-*` and values, locale changes won't break tests.

---
