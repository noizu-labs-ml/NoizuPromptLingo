/**
 * Shared UI kit (F4) — generic, reusable, typed frontend components for the
 * tobor.locker MCP overhaul. Consumers: W3 (TabbedPopunder), W6/W7
 * (ContextMenu, SlideOverSidebar, ACLEditor, ToolTogglesGrid,
 * TempWindowEditor). All components are pure/controlled and bind against
 * plain data shapes — no backend imports.
 */
export { default as ContextMenu } from './context-menu';
export type { ContextMenuItem } from './context-menu';

export { default as SlideOverSidebar } from './slideover-sidebar';
export type { SlideOverTab } from './slideover-sidebar';

export { default as ACLEditor } from './acl-editor';

export { default as ToolTogglesGrid } from './tool-toggles-grid';

// Shared tool-state contract (F1/F2 binding) — canonical types live in
// @/types/tool-state; re-exported here so kit consumers have one import site.
export type {
  AclEffect,
  AclGroup,
  AclRule,
  AclState,
  EffectiveToolState,
  EntityRef,
  ToolEntry,
  ToolSection,
} from '@/types/tool-state';

export { default as TempWindowEditor } from './temp-window-editor';
export type { TempWindow } from './temp-window-editor';

export { default as TabbedPopunder } from './tabbed-popunder';
export type { TabbedPopunderTab } from './tabbed-popunder';

// PRD-020 FR-5: domain-neutral controlled wizard stepper (US-107).
export { default as WizardStepper } from './wizard-stepper';
export type { WizardStepperProps, WizardStepDef } from './wizard-stepper';

// Clipboard primitives (CopyField / ClipboardButton / useCopied) — the one
// copied-flash implementation for the MCP surfaces.
export { ClipboardButton, CopyField, useCopied } from './clipboard';
export type { ClipboardButtonProps, CopyFieldProps } from './clipboard';

// Confirmation modal replacing window.confirm/prompt (revoke/delete sites).
export { default as ConfirmDialog } from './confirm-dialog';
export type { ConfirmDialogProps } from './confirm-dialog';
