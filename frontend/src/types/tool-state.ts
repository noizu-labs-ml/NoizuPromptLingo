/**
 * Shared tool-state contract (F4 binding) — the single vocabulary shared by
 * the F4 kit components (ACLEditor, ToolTogglesGrid) and the F1/F2 backend
 * shapes. Field names mirror what the backend actually exposes:
 *
 *  - `EntityRef` binds F1's `Acl.ERPRef` jsonb (`{"type": <kind>, "id": <id>}`);
 *    `label` is display-only and host-supplied.
 *  - `EffectiveToolState` binds `NoizuPromptLingua.MCP.EffectiveToolset`
 *    tool_state/0 (enabled / visible / name_override / description_override /
 *    expires_at).
 *  - `AclRule` binds F1 `Schema.ACL.Rule` (subject_ref / resource_ref / effect
 *    / scope / priority; the backend's `action` verb is host-mapped onto
 *    `scope` for now).
 */

/** Polymorphic entity reference (F1 ERPRef). */
export interface EntityRef {
  kind: string;
  id: string;
  /** Display label (host-supplied, not persisted in the ref itself). */
  label?: string;
}

export type AclEffect = 'allow' | 'deny';

export interface AclRule {
  /** Client-side id (host-assigned or generated). */
  id: string;
  subject: EntityRef;
  /** `null` while unmatched / wildcard (host decides persistence). */
  resource: EntityRef | null;
  effect: AclEffect;
  /** Permission scope label (e.g. "read", "write", "admin"); null = any. */
  scope: string | null;
  /** Tie-break weight; F1 evaluation still prefers deny on conflict. */
  priority: number;
  /** Optional F1 action verb override (e.g. "read"); host-mapped. */
  action?: string;
}

export interface AclGroup {
  id: string;
  name: string;
  /** Member subject refs. */
  members: EntityRef[];
}

export interface AclState {
  rules: AclRule[];
  groups: AclGroup[];
}

/**
 * F2 effective tool state for one tool — the merged verdict across scope
 * config, client toolset_config, overrides, and F3 temporal windows.
 */
export interface EffectiveToolState {
  /** Execution gate (ToolGuard). */
  enabled: boolean;
  /** Discovery gate (list_tools). */
  visible: boolean;
  name_override?: string | null;
  description_override?: string | null;
  /** ISO 8601 UTC instant the state expires (F3 window). */
  expires_at?: string | null;
}

/** One tool inside a section: identity + effective state. */
export interface ToolEntry {
  tool: EntityRef;
  state: EffectiveToolState;
}

/** A display section (toolset group) of tool entries. */
export interface ToolSection {
  name: string;
  label?: string;
  tools: ToolEntry[];
}
