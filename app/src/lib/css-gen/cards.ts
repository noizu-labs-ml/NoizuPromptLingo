export function generateCardCSS(): string {
  return `/* ═══════════════════════════════════════
   CARDS
   ═══════════════════════════════════════ */
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(var(--card-grid-min-width), 1fr));
  gap: var(--card-grid-gap);
}
.card {
  display: flex;
  flex-direction: column;
  background: var(--card-background);
  border: var(--card-border);
  transition: all var(--card-transition);
}
.card:hover { background: var(--card-hover-background); }
.card-filled {
  background: var(--card-filled-background);
  color: var(--card-filled-color);
  border: var(--card-border);
}
.card-filled:hover { background: var(--card-filled-hover-background); }
.card-filled .card-body { color: var(--card-body-filled-color); }
.card-title {
  font-size: var(--card-title-font-size);
  font-weight: var(--card-title-font-weight);
  letter-spacing: var(--card-title-letter-spacing);
  margin-bottom: var(--card-title-margin-bottom);
  line-height: var(--card-title-line-height);
}
.card-header .card-title {
  margin-bottom: 0;
}
.card-header {
  padding: var(--space-1) var(--card-padding);
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-2);
  background: var(--card-header-background);
  color: var(--card-header-color);
  position: relative;
}
.card-header .card-title {
  color: inherit;
}
/* Inset dotted separator at header bottom */
.card-header::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: var(--card-separator-inset);
  right: var(--card-separator-inset);
  border-bottom: var(--card-separator-width) var(--card-separator-style) var(--card-separator-color);
}
.card-body {
  flex: 1;
  padding: var(--card-body-padding);
  font-size: var(--card-body-font-size);
  color: var(--card-body-color);
  line-height: var(--card-body-line-height);
}
.card-filled .card-body { color: var(--card-body-filled-color); }
.card-tag {
  display: inline-block;
  font-family: var(--card-tag-font-family);
  font-size: var(--card-tag-font-size);
  font-weight: var(--card-tag-font-weight);
  padding: var(--card-tag-padding);
  background: var(--card-tag-background);
  color: var(--card-tag-color);
  margin-top: var(--card-tag-margin-top);
}
.card-footer {
  padding: var(--card-footer-padding);
  font-size: var(--card-footer-font-size);
  font-weight: var(--card-footer-font-weight);
  color: var(--card-footer-color);
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--card-footer-background);
  position: relative;
}
/* Inset dotted separator at footer top */
.card-footer::before {
  content: '';
  position: absolute;
  top: 0;
  left: var(--card-separator-inset);
  right: var(--card-separator-inset);
  border-top: var(--card-separator-width) var(--card-separator-style) var(--card-separator-color);
}
table {
  width: 100%;
  border-collapse: collapse;
}
thead tr {
  border-bottom: var(--table-header-border-width) solid var(--card-border-color);
}
th {
  text-align: left;
  padding: var(--table-cell-padding);
  font-size: var(--table-header-font-size);
  text-transform: uppercase;
  letter-spacing: var(--table-header-letter-spacing);
  font-family: var(--table-header-font-family);
}
tbody tr {
  border-bottom: var(--card-separator-width) solid var(--card-separator-color);
}
tbody tr:last-child {
  border-bottom: none;
}
td {
  padding: var(--table-cell-padding);
  vertical-align: top;
}
/* Card modifiers */
.card.rounded {
  border-radius: var(--card-rounded-radius);
  overflow: hidden;
}
.card.drop-shadow {
  box-shadow: var(--card-drop-shadow);
}

/* ─── Card layout utilities ─── */
.card-tag.inline { margin-top: 0; margin-left: auto; }
.card-body-note { margin-top: var(--space-2); font-size: var(--font-size-sm); color: var(--text-muted); }
.ml-auto { margin-left: auto; }`;
}
