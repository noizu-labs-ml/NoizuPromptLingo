import type { StyleGuideConfig } from "../types";

export function generateIndicatorCSS(_config: StyleGuideConfig): string {
  return `/* ═══════════════════════════════════════
   STATUS INDICATORS
   ═══════════════════════════════════════ */

/* ─── Badge ─── */
.badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: var(--badge-padding);
  border-radius: var(--badge-radius);
  font-size: var(--badge-font-size);
  font-weight: var(--badge-font-weight);
  font-family: var(--badge-font-family);
  line-height: var(--badge-line-height);
  white-space: nowrap;
}
.badge.count {
  min-width: var(--badge-count-min-width);
  height: var(--badge-count-height);
  padding: var(--badge-count-padding);
}
.badge.success  { background: var(--success);  color: var(--on-semantic-color); }
.badge.warning  { background: var(--warning);  color: var(--on-semantic-color); }
.badge.error    { background: var(--error);    color: var(--on-semantic-color); }
.badge.info     { background: var(--info);     color: var(--on-semantic-color); }
.badge.default  { background: var(--border); color: var(--text); }
.badge.muted    { background: var(--surface-alt); color: var(--text); border: var(--border-thin) solid var(--border-strong); }

/* ─── Alert ─── */
.alert {
  padding: var(--space-2) var(--space-3);
  border-left: var(--alert-border-width) solid var(--border-strong);
  background: var(--surface-alt);
  display: flex;
  flex-direction: column;
  gap: var(--alert-gap);
}
.alert-title {
  font-weight: var(--alert-title-font-weight);
  font-size: var(--alert-title-font-size);
  line-height: var(--alert-title-line-height);
}
.alert-body {
  font-size: var(--alert-body-font-size);
  color: var(--text-secondary);
  line-height: var(--alert-body-line-height);
}
.alert.success { border-left-color: var(--success); background: var(--success-tint); }
.alert.success .alert-title { color: var(--success); }
.alert.warning { border-left-color: var(--warning); background: var(--warning-tint); }
.alert.warning .alert-title { color: var(--warning); }
.alert.error   { border-left-color: var(--error);   background: var(--error-tint);   }
.alert.error   .alert-title { color: var(--error); }
.alert.info    { border-left-color: var(--info);    background: var(--info-tint);    }
.alert.info    .alert-title { color: var(--info); }

/* ─── Toast ─── */
.toast {
  display: flex;
  align-items: center;
  gap: var(--toast-gap);
  padding: var(--toast-padding);
  background: var(--toast-bg);
  color: var(--toast-color);
  font-size: var(--toast-font-size);
  font-weight: var(--toast-font-weight);
  line-height: var(--toast-line-height);
  width: 100%;
  max-width: var(--toast-max-width);
  border-left: var(--toast-border-width) solid transparent;
  box-shadow: var(--toast-shadow);
}
.toast-icon { flex-shrink: 0; }
.toast.success { background: var(--toast-bg-success); color: var(--toast-color-success); border-left-color: var(--success); }
.toast.warning { background: var(--toast-bg-warning); color: var(--toast-color-warning); border-left-color: var(--warning); }
.toast.error   { background: var(--toast-bg-error); color: var(--toast-color-error); border-left-color: var(--error); }
.toast.info    { background: var(--toast-bg-info); color: var(--toast-color-info); border-left-color: var(--info); }

/* ─── Sonner overrides (match preview toasts) ─── */
[data-sonner-toaster] [data-sonner-toast] {
  --normal-bg: var(--toast-bg);
  --normal-text: var(--toast-color);
  --normal-border: transparent;
  --success-bg: var(--toast-bg-success);
  --success-text: var(--toast-color-success);
  --success-border: var(--success);
  --error-bg: var(--toast-bg-error);
  --error-text: var(--toast-color-error);
  --error-border: var(--error);
  --warning-bg: var(--toast-bg-warning);
  --warning-text: var(--toast-color-warning);
  --warning-border: var(--warning);
  --info-bg: var(--toast-bg-info);
  --info-text: var(--toast-color-info);
  --info-border: var(--info);
  font-size: var(--toast-font-size);
  font-weight: var(--toast-font-weight);
  line-height: var(--toast-line-height);
  box-shadow: var(--toast-shadow);
  border-left-width: var(--toast-border-width);
  border-left-style: solid;
  border-radius: 0;
}
[data-sonner-toaster] [data-sonner-toast][data-type="success"] { background: var(--toast-bg-success); color: var(--toast-color-success); border-left-color: var(--success); }
[data-sonner-toaster] [data-sonner-toast][data-type="error"]   { background: var(--toast-bg-error); color: var(--toast-color-error); border-left-color: var(--error); }
[data-sonner-toaster] [data-sonner-toast][data-type="warning"] { background: var(--toast-bg-warning); color: var(--toast-color-warning); border-left-color: var(--warning); }
[data-sonner-toaster] [data-sonner-toast][data-type="info"]    { background: var(--toast-bg-info); color: var(--toast-color-info); border-left-color: var(--info); }

/* ─── Progress ─── */
.progress {
  width: 100%;
  background: var(--border);
  border-radius: var(--progress-radius);
  overflow: hidden;
  height: var(--progress-height);
}
.progress.sm { height: var(--progress-height-sm); }
.progress.lg { height: var(--progress-height-lg); }
.progress-bar {
  height: 100%;
  border-radius: var(--progress-radius);
  background: var(--text);
  transition: var(--progress-transition);
}
.progress-bar.success { background: var(--success); }
.progress-bar.warning { background: var(--warning); }
.progress-bar.error   { background: var(--error);   }
.progress-bar.info    { background: var(--info);    }
.progress.indeterminate .progress-bar {
  width: 40% !important;
  animation: progress-slide 1.4s ease-in-out infinite;
}
@keyframes progress-slide {
  0%   { transform: translateX(-150%); }
  100% { transform: translateX(350%); }
}

/* ─── Status Dot ─── */
.status-dot-row {
  display: inline-flex;
  align-items: center;
  gap: var(--status-dot-row-gap);
  font-size: var(--status-dot-row-font-size);
}
.status-dot {
  display: inline-block;
  width: var(--status-dot-size);
  height: var(--status-dot-size);
  border-radius: 50%;
  flex-shrink: 0;
}
.status-dot.online  { background: var(--success); box-shadow: 0 0 0 var(--size-border-thick) color-mix(in srgb, var(--success) 25%, transparent); }
.status-dot.away    { background: var(--warning); }
.status-dot.offline { background: var(--text-muted); }
.status-dot.error   { background: var(--error); }

/* ─── Tag ─── */
.tag {
  display: inline-flex;
  align-items: center;
  padding: var(--tag-padding);
  border-radius: var(--tag-radius);
  font-size: var(--tag-font-size);
  font-weight: var(--tag-font-weight);
  font-family: var(--tag-font-family);
  white-space: nowrap;
  border: var(--tag-border-width) solid transparent;
}
.tag.success { background: var(--success-tint); color: var(--success); border-color: color-mix(in srgb, var(--success) 25%, transparent); }
.tag.warning { background: var(--warning-tint); color: var(--warning); border-color: color-mix(in srgb, var(--warning) 25%, transparent); }
.tag.error   { background: var(--error-tint);   color: var(--error);   border-color: color-mix(in srgb, var(--error)   25%, transparent); }
.tag.info    { background: var(--info-tint);    color: var(--info);    border-color: color-mix(in srgb, var(--info)    25%, transparent); }
.tag.default { background: var(--surface-alt); color: var(--text-secondary); border-color: var(--border-strong); }

`;
}
