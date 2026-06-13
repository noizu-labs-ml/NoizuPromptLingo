import type { StyleGuideConfig } from "../types";

export function generateCodeTerminalCSS(_config: StyleGuideConfig): string {
  return `/* ═══════════════════════════════════════
   CODE BLOCKS
   ═══════════════════════════════════════ */

/* ─── Inline code ─── */
.code-inline {
  font-family: var(--font-mono);
  font-size: 0.875em;
  background: var(--code-bg);
  color: var(--code-text);
  border: 1px solid var(--code-border);
  border-radius: var(--radius);
  padding: 0.1em 0.35em;
}

/* ─── Code window shell ─── */
.code-window {
  border: 1px solid var(--code-border);
  border-radius: var(--radius);
  overflow: hidden;
}

/* ─── Title bar ─── */
.code-title-bar {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-1) var(--space-2);
  background: var(--code-title-bar-bg, color-mix(in srgb, var(--code-bg) 85%, var(--black)));
  border-bottom: 1px solid var(--code-border);
}

.code-title-bar-dots {
  display: flex;
  gap: var(--space-half);
}

.code-title-bar-dots span {
  width: var(--font-size-2xs);
  height: var(--font-size-2xs);
  border-radius: var(--radius-circle);
  background: var(--code-border);
  display: inline-block;
}

.code-title-bar-filename {
  font-family: var(--font-mono);
  font-size: var(--font-size-xs);
  color: var(--code-comment);
}

/* ─── Code block ─── */
.code-block {
  margin: 0;
  padding: var(--space-3);
  background: var(--code-bg);
  color: var(--code-text);
  font-family: var(--font-mono);
  font-size: var(--font-size-sm);
  line-height: var(--line-height-relaxed);
  overflow-x: auto;
  tab-size: 2;
}

/* ─── Line-numbered variant ─── */
.code-block-lined {
  padding: var(--space-2) 0;
}

.code-line {
  display: flex;
  align-items: baseline;
  gap: var(--space-2);
  padding: 0 var(--space-3);
  min-height: 1.5em;
}

.code-line:hover {
  background: color-mix(in srgb, var(--code-line-number) 6%, transparent);
}

.code-line-number {
  flex-shrink: 0;
  min-width: var(--space-3);
  text-align: right;
  color: var(--code-line-number);
  font-size: var(--font-size-xs);
  user-select: none;
}

.code-line-content {
  flex: 1;
}

/* ═══════════════════════════════════════
   TERMINAL
   ═══════════════════════════════════════ */

/* ─── Terminal window shell ─── */
.terminal-window {
  border: 1px solid var(--terminal-border);
  border-radius: var(--radius);
  overflow: hidden;
  font-family: var(--font-mono);
}

/* ─── Title bar ─── */
.terminal-title-bar {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-1) var(--space-2);
  background: var(--terminal-title-bar-bg);
  border-bottom: 1px solid var(--terminal-border);
}

.terminal-dots {
  display: flex;
  gap: var(--space-half);
  align-items: center;
}

.terminal-dot {
  width: var(--font-size-2xs);
  height: var(--font-size-2xs);
  border-radius: var(--radius-circle);
  display: inline-block;
}
.terminal-dot-close    { background: var(--screen-dot-close, #ff5f56); }
.terminal-dot-minimize { background: var(--screen-dot-minimize, #ffbd2e); }
.terminal-dot-maximize { background: var(--screen-dot-maximize, #27c93f); }

.terminal-title {
  font-size: var(--font-size-xs);
  color: var(--terminal-output);
  opacity: 0.6;
}

/* ─── Terminal body ─── */
.terminal-body {
  padding: var(--space-2) var(--space-3);
  background: var(--terminal-bg);
  display: flex;
  flex-direction: column;
  gap: 1px;
}

/* ─── Rows ─── */
.terminal-row {
  display: flex;
  align-items: baseline;
  gap: var(--space-1);
  padding: var(--space-half) 0;
  line-height: var(--line-height-compact);
}

.terminal-prompt {
  color: var(--terminal-prompt);
  font-size: var(--font-size-sm);
  user-select: none;
  flex-shrink: 0;
}

.terminal-command {
  color: var(--terminal-command);
  font-size: var(--font-size-sm);
}

/* ─── Output variants ─── */
.terminal-output {
  color: var(--terminal-output);
  font-size: var(--font-size-sm);
  padding: 1px 0 1px var(--space-2);
  line-height: var(--line-height-relaxed);
}

.terminal-success { color: var(--terminal-success); }
.terminal-error   { color: var(--terminal-error); }
.terminal-warning { color: var(--terminal-warning); }
`;
}
