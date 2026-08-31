import {css, unsafeCSS} from 'lit';

const darkDecls = unsafeCSS(`
  --nqb-bg: #14161b;
  --nqb-surface: #1d2027;
  --nqb-surface-raised: #262a33;
  --nqb-border: #323743;
  --nqb-text: #e8eaf0;
  --nqb-text-muted: #9aa3b2;
  --nqb-accent: #818cf8;
  --nqb-accent-contrast: #101223;
  --nqb-danger: #f87171;
  --nqb-warn: #fbbf24;
  --nqb-ok: #34d399;
  --nqb-chip-bg: #262a33;
`);

export const queueBoardTokens = css`
  :host {
    --nqb-bg: #f5f6f8;
    --nqb-surface: #ffffff;
    --nqb-surface-raised: #eef0f4;
    --nqb-border: #d9dde5;
    --nqb-text: #1f2430;
    --nqb-text-muted: #5b6472;
    --nqb-accent: #4f46e5;
    --nqb-accent-contrast: #ffffff;
    --nqb-danger: #b91c1c;
    --nqb-warn: #92400e;
    --nqb-ok: #047857;
    --nqb-chip-bg: #e8ebf1;

    --nqb-radius: 10px;
    --nqb-radius-sm: 6px;
    --nqb-font: system-ui, -apple-system, 'Segoe UI', sans-serif;
    --nqb-mono: ui-monospace, 'SF Mono', Menlo, Consolas, monospace;
    --nqb-column-width: 280px;
    --nqb-gap: 12px;
    --nqb-pad: 16px;

    display: block;
    background: var(--nqb-bg);
    color: var(--nqb-text);
    font-family: var(--nqb-font);
    color-scheme: light;
  }

  :host([theme='dark']) {
    ${darkDecls}
    color-scheme: dark;
  }

  @media (prefers-color-scheme: dark) {
    :host(:not([theme='light'])) {
      ${darkDecls}
      color-scheme: dark;
    }
  }
`;
