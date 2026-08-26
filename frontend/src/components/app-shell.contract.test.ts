import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const src = resolve(here, '..');
const read = (relativePath: string) => readFileSync(resolve(src, relativePath), 'utf8');

const appLayout = read('app/app/layout.tsx');
const appNav = read('components/app-nav.tsx');
const appSidebar = read('components/app-sidebar.tsx');
const mobileNav = read('components/mobile-nav.tsx');
const navbar = read('components/navbar.tsx');
const css = read('app/globals.css');

function contract(source: string, pattern: RegExp, message: string) {
  assert.ok(pattern.test(source), message);
}

test('workspace shell exposes a skip link and semantic main landmark', () => {
  contract(appLayout, /href=["']#main-content["']/, 'app layout must render a skip link');
  contract(appLayout, /<main\b[^>]*id=["']main-content["'][^>]*>/, 'app layout must expose #main-content');
  contract(css, /\.skip-link\s*\{[^}]*transform:\s*translateY\(/, 'skip link must remain off-screen until focused');
  contract(css, /\.skip-link:focus-visible\s*\{[^}]*transform:\s*translateY\(0\)/, 'skip link must become visible on keyboard focus');
});

test('navigation retains task-oriented groups and established destinations', () => {
  for (const label of [
    'Workspace',
    'Delivery',
    'Knowledge',
    'Integrations',
    'Configuration',
    'Admin',
  ]) {
    contract(appNav, new RegExp(`label: ['"]${label}['"]`), `missing ${label} nav group`);
  }

  for (const href of [
    '/app/organizations',
    '/members',
    '/projects',
    '/sessions',
    '/tickets',
    '/boards',
    '/reviews',
    '/chat',
    '/personas',
    '/memory',
    '/instructions',
    '/wiki',
    '/artifacts',
    '/assets',
    '/npl-conventions',
    '/unicode-codex',
    '/browser',
    '/github',
    '/mock-mcp',
    '/app/mcp-keys',
    '/ticket-types',
    '/ticket-fields',
    '/settings',
    '/app/admin',
    '/app/admin/users',
    '/app/admin/orgs',
    '/app/admin/github',
    '/app/admin/llm-models',
    '/app/admin/media-providers',
    '/app/admin/authz',
    '/app/admin/oauth-clients',
  ]) {
    contract(appNav, new RegExp(`href: ['"]${href.replaceAll('/', '\\/')}['"]`), `route changed or missing: ${href}`);
  }
});

test('desktop and mobile navigation expose the current page semantically', () => {
  const currentPage = /aria-current=\{item\.active\s*\?\s*['"]page['"]\s*:\s*undefined\}/;
  contract(appSidebar, currentPage, 'desktop active link must expose aria-current="page"');
  contract(mobileNav, currentPage, 'mobile active link must expose aria-current="page"');
});

test('header provides a persistent, stateful appearance control', () => {
  contract(navbar, /appearance-toggle/, 'header must expose a visible appearance control');
  contract(navbar, /aria-pressed=/, 'appearance control must expose its current state');
  contract(navbar, /color-mode/, 'appearance choice must persist through color-mode');
  contract(navbar, /aria-label=[\s\S]*(?:light|dark|appearance|theme)/i, 'appearance control needs an accessible name');
});

test('mobile navigation replaces the desktop rail at the established breakpoint', () => {
  contract(
    css,
    /@media\s*\(max-width:\s*820px\)[\s\S]*?\.app-sidebar\s*\{\s*display:\s*none;[\s\S]*?\.nav-mobile-trigger\s*\{\s*display:\s*inline-flex;/,
    '820px breakpoint must swap the desktop rail for mobile navigation',
  );
});

test('mobile navigation controls meet the 44px minimum hit target', () => {
  for (const selector of ['.nav-mobile-btn', '.nav-menu-section__toggle', '.nav-menu-item']) {
    const escaped = selector.replace('.', '\\.');
    contract(
      css,
      new RegExp(`${escaped}\\s*\\{[^}]*min-height:\\s*(?:44px|var\\(--tap-target-min\\))`),
      `${selector} must declare a minimum 44px hit target`,
    );
  }
});

test('reduced-motion mode covers shell and navigation transitions', () => {
  contract(
    css,
    /@media\s*\(prefers-reduced-motion:\s*reduce\)\s*\{[^@]*--shell-transition-duration:\s*(?:0s|0\.01ms)/,
    'reduced-motion mode must zero the shared shell transition duration',
  );
});
