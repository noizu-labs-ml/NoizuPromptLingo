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
export type { AclEffect, AclRule, AclGroup, AclState } from './acl-editor';

export { default as ToolTogglesGrid } from './tool-toggles-grid';
export type { ToolToggleEntry, ToolToggleGroup } from './tool-toggles-grid';

export { default as TempWindowEditor } from './temp-window-editor';
export type { TempWindow } from './temp-window-editor';

export { default as TabbedPopunder } from './tabbed-popunder';
export type { TabbedPopunderTab } from './tabbed-popunder';
