import type { StyleGuideConfig, SimpleShellLayout } from "../types";

function shellVars(shell: SimpleShellLayout): string {
  const { chrome } = shell;
  if (!chrome) return "";
  const lines: string[] = [];
  if (chrome.navbar?.height)     lines.push(`  --shell-navbar-height: ${chrome.navbar.height};`);
  if (chrome.navbar?.background) lines.push(`  --shell-navbar-bg: ${chrome.navbar.background};`);
  if (chrome.navbar?.color)      lines.push(`  --shell-navbar-color: ${chrome.navbar.color};`);
  if (chrome.sidebar?.width)     lines.push(`  --shell-sidebar-width: ${chrome.sidebar.width};`);
  if (chrome.sidebar?.background)lines.push(`  --shell-sidebar-bg: ${chrome.sidebar.background};`);
  if (chrome.sidebar?.color)     lines.push(`  --shell-sidebar-color: ${chrome.sidebar.color};`);
  if (chrome.aside?.width)       lines.push(`  --shell-aside-width: ${chrome.aside.width};`);
  if (chrome.aside?.background)  lines.push(`  --shell-aside-bg: ${chrome.aside.background};`);
  if (chrome.aside?.color)       lines.push(`  --shell-aside-color: ${chrome.aside.color};`);
  if (chrome.footer?.height)     lines.push(`  --shell-footer-height: ${chrome.footer.height};`);
  if (chrome.footer?.background) lines.push(`  --shell-footer-bg: ${chrome.footer.background};`);
  if (chrome.footer?.color)      lines.push(`  --shell-footer-color: ${chrome.footer.color};`);
  return lines.join("\n");
}

export function generateShellCSS(config: StyleGuideConfig): string {
  const perShell = config.shellLayouts
    .map((shell) => {
      const vars = shellVars(shell);
      if (!vars) return "";
      const { chrome } = shell;
      // Zero-out dimensions for chrome pieces this shell doesn't use
      const overrides: string[] = [];
      if (!chrome?.navbar)  overrides.push("  --shell-navbar-height: 0px;");
      if (!chrome?.sidebar) overrides.push("  --shell-sidebar-width: 0px;");
      if (!chrome?.aside)   overrides.push("  --shell-aside-width: 0px;");
      if (!chrome?.footer)  overrides.push("  --shell-footer-height: 0px;");
      const allVars = [vars, ...overrides].filter(Boolean).join("\n");
      // Hide chrome elements this shell doesn't use
      const hideRules: string[] = [];
      if (!chrome?.navbar)  hideRules.push(`body[data-shell="${shell.name}"] .shell-grid > .shell-navbar { display: none; }`);
      if (!chrome?.sidebar) hideRules.push(`body[data-shell="${shell.name}"] .shell-grid > .shell-sidebar { display: none; }`);
      if (!chrome?.aside)   hideRules.push(`body[data-shell="${shell.name}"] .shell-grid > .shell-aside { display: none; }`);
      if (!chrome?.footer)  hideRules.push(`body[data-shell="${shell.name}"] .shell-grid > .shell-footer { display: none; }`);
      return `/* Shell: ${shell.name} */
body[data-shell="${shell.name}"] {
${allVars}
}
${hideRules.join("\n")}`;
    })
    .filter(Boolean)
    .join("\n\n");

  return `/* ═══════════════════════════════════════
   SHELL LAYOUTS — CSS Grid on .shell-grid
   ═══════════════════════════════════════ */

/* ─── Default: chrome hidden ─── */
.shell-navbar, .shell-sidebar, .shell-aside, .shell-footer { display: none; }

/* ─── Grid wrapper ─── */
.shell-grid {
  min-height: 100vh;
}
body[data-shell] .shell-grid {
  display: grid;
  height: 100vh;
  grid-template-areas:
    "nav    nav    nav"
    "side   main   aside"
    "foot   foot   foot";
  grid-template-rows: var(--shell-navbar-height, 0px) 1fr var(--shell-footer-height, 0px);
  grid-template-columns: var(--shell-sidebar-width, 0px) 1fr var(--shell-aside-width, 0px);
}

/* ─── Navbar ─── */
body[data-shell] .shell-grid > .shell-navbar {
  display: flex;
  grid-area: nav;
  z-index: var(--shell-navbar-z-index);
  height: var(--shell-navbar-height);
  background: var(--shell-navbar-bg, var(--surface-inverse));
  color: var(--shell-navbar-color, var(--text-inverse));
  align-items: center;
  padding: 0 var(--space-3);
  gap: var(--space-3);
  font-size: var(--shell-navbar-font-size);
  border-bottom: var(--shell-navbar-border-width) solid color-mix(in srgb, var(--shell-navbar-color, var(--text-inverse)) 12%, transparent);
}
.shell-navbar-brand {
  display: flex; align-items: center; gap: var(--space-2);
  font-weight: var(--font-weight-bold); font-size: var(--shell-navbar-action-font-size); letter-spacing: var(--btn-letter-spacing); white-space: nowrap;
}
.shell-navbar-links {
  display: flex; align-items: center; gap: var(--shell-navbar-link-gap);
}
.shell-navbar-link {
  padding: var(--shell-navbar-link-padding); font-size: var(--shell-navbar-link-font-size); border-radius: var(--shell-navbar-link-radius); cursor: pointer;
  opacity: var(--shell-navbar-link-opacity); transition: var(--shell-navbar-link-transition);
}
.shell-navbar-link:hover { opacity: 1; background: color-mix(in srgb, currentColor 8%, transparent); }
.shell-navbar-link.active { opacity: 1; font-weight: var(--shell-navbar-link-active-weight); }
.shell-navbar-actions {
  display: flex; align-items: center; gap: var(--space-1); margin-left: auto;
}
.shell-navbar-action {
  width: var(--shell-navbar-action-size); height: var(--shell-navbar-action-size); display: flex; align-items: center; justify-content: center;
  border-radius: var(--shell-navbar-action-radius); cursor: pointer; font-size: var(--shell-navbar-action-font-size);
  transition: var(--shell-navbar-action-transition);
}
.shell-navbar-action:hover { background: color-mix(in srgb, currentColor 10%, transparent); }
.shell-navbar-dismiss {
  padding: var(--shell-navbar-dismiss-padding); font-size: var(--shell-navbar-dismiss-font-size); font-family: var(--font-mono);
  background: color-mix(in srgb, var(--shell-navbar-color, var(--text-inverse)) 15%, transparent);
  border: var(--border-thin) solid color-mix(in srgb, var(--shell-navbar-color, var(--text-inverse)) 20%, transparent);
  border-radius: var(--shell-navbar-dismiss-radius); cursor: pointer; color: inherit; white-space: nowrap;
  transition: var(--shell-navbar-dismiss-transition);
}
.shell-navbar-dismiss:hover { background: color-mix(in srgb, var(--shell-navbar-color, var(--text-inverse)) 25%, transparent); }

/* ─── Sidebar ─── */
body[data-shell] .shell-grid > .shell-sidebar {
  display: flex;
  grid-area: side;
  background: var(--shell-sidebar-bg, var(--surface-alt));
  color: var(--shell-sidebar-color, var(--text));
  flex-direction: column;
  overflow-y: auto;
  border-right: var(--shell-sidebar-border-width) solid color-mix(in srgb, var(--shell-sidebar-color, var(--text)) 10%, transparent);
}
.shell-sidebar-section {
  padding: var(--space-2) var(--space-3) var(--space-half);
  font-size: var(--shell-sidebar-section-font-size); font-family: var(--font-mono);
  letter-spacing: var(--shell-sidebar-section-letter-spacing); text-transform: uppercase;
  opacity: var(--shell-sidebar-section-opacity); user-select: none;
}
.shell-sidebar-item {
  display: flex; align-items: center; gap: var(--shell-sidebar-item-gap);
  padding: var(--shell-sidebar-item-padding);
  font-size: var(--shell-sidebar-item-font-size); cursor: pointer;
  transition: var(--shell-sidebar-item-transition);
}
.shell-sidebar-item:hover {
  background: color-mix(in srgb, var(--shell-sidebar-color, var(--text)) 8%, transparent);
}
.shell-sidebar-item.active {
  background: color-mix(in srgb, var(--shell-sidebar-color, var(--text)) 14%, transparent);
  font-weight: var(--shell-sidebar-item-active-weight);
}
.shell-sidebar-glyph { font-size: var(--shell-sidebar-glyph-font-size); width: var(--shell-sidebar-glyph-size); text-align: center; flex-shrink: 0; }
.shell-sidebar-divider {
  margin: var(--space-1) var(--space-3);
  border-top: var(--shell-sidebar-divider-width) solid color-mix(in srgb, var(--shell-sidebar-color, var(--text)) 10%, transparent);
}

/* ─── Aside ─── */
body[data-shell] .shell-grid > .shell-aside {
  display: flex;
  grid-area: aside;
  background: var(--shell-aside-bg, var(--surface-alt));
  color: var(--shell-aside-color, var(--text));
  flex-direction: column;
  overflow-y: auto;
  border-left: var(--shell-aside-border-width) solid color-mix(in srgb, var(--shell-aside-color, var(--text)) 10%, transparent);
}
.shell-aside-header {
  padding: var(--space-2) var(--space-3);
  font-size: var(--shell-aside-section-font-size); font-family: var(--font-mono);
  letter-spacing: var(--shell-aside-section-letter-spacing); text-transform: uppercase;
  opacity: var(--shell-aside-section-opacity); border-bottom: var(--shell-aside-row-border-width) solid color-mix(in srgb, currentColor 10%, transparent);
}
.shell-aside-row {
  display: flex; justify-content: space-between; align-items: center;
  padding: var(--shell-aside-row-padding);
  font-size: var(--shell-aside-row-font-size); border-bottom: var(--shell-aside-row-border-width) solid color-mix(in srgb, currentColor 6%, transparent);
}
.shell-aside-label { opacity: var(--shell-aside-meta-opacity); font-size: var(--shell-aside-meta-font-size); }
.shell-aside-value { font-family: var(--font-mono); font-size: var(--shell-aside-meta-font-size); }

/* ─── Footer ─── */
body[data-shell] .shell-grid > .shell-footer {
  display: flex;
  grid-area: foot;
  z-index: var(--shell-footer-z-index);
  height: var(--shell-footer-height);
  background: var(--shell-footer-bg, var(--surface-alt));
  color: var(--shell-footer-color, var(--text-muted));
  align-items: center;
  padding: 0 var(--space-3);
  font-size: var(--shell-footer-font-size);
  font-family: var(--font-mono);
  gap: var(--space-3);
  border-top: var(--shell-footer-border-width) solid var(--border);
}
.shell-footer-dot {
  width: var(--shell-footer-dot-size); height: var(--shell-footer-dot-size); border-radius: 50%; flex-shrink: 0;
}
.shell-footer-sep { opacity: var(--shell-footer-dot-opacity); }

/* ─── Main content area ─── */
body[data-shell] .shell-grid > .content {
  grid-area: main;
  padding-top: var(--space-4);
  min-width: 0;
  overflow-y: auto;
  container-type: normal;
}

/* ─── Per-shell vars ─── */
${perShell}

/* ═══════════════════════════════════════
   SCREEN FRAME
   ═══════════════════════════════════════ */
.screen-frame {
  border-radius: var(--screen-frame-radius);
  overflow: hidden;
  box-shadow: var(--screen-frame-shadow);
  border: var(--screen-frame-border-width) solid var(--border-strong);
  background: var(--surface);
}
.screen-titlebar {
  display: flex;
  align-items: center;
  gap: var(--screen-titlebar-gap);
  padding: var(--screen-titlebar-padding);
  background: var(--surface-alt);
  border-bottom: var(--border-thin) solid var(--border);
}
.screen-dots {
  display: flex;
  gap: var(--screen-dots-gap);
  flex-shrink: 0;
}
.screen-dot {
  width: var(--screen-dot-size);
  height: var(--screen-dot-size);
  border-radius: 50%;
}
.screen-dot:nth-child(1) { background: var(--screen-dot-close); }
.screen-dot:nth-child(2) { background: var(--screen-dot-minimize); }
.screen-dot:nth-child(3) { background: var(--screen-dot-maximize); }
.screen-url {
  flex: 1;
  text-align: center;
  font-size: var(--screen-titlebar-font-size);
  font-family: var(--font-mono);
  color: var(--text-muted);
  background: var(--surface);
  border: var(--screen-url-border-width) solid var(--border-strong);
  border-radius: var(--screen-url-radius);
  padding: var(--screen-url-padding);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: var(--screen-url-max-width);
  margin: 0 auto;
}
.screen-body {
  overflow: hidden;
}`;
}
