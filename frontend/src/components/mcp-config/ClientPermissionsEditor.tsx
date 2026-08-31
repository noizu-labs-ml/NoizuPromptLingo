'use client';

import { useMemo, useState } from 'react';
import { ToolTogglesGrid, TempWindowEditor, ACLEditor, type AclState, type ToolSection } from '@/components/kit';

// ---------------------------------------------------------------------------
// ClientPermissionsEditor — shared per-client permission stack (W7).
//
// Wraps the F4 kit primitives (ToolTogglesGrid + TempWindowEditor + ACLEditor)
// into one editor used by both the W6 scope-manager "Manage Clients" flow and
// the W7 MCP Config hub per-item editors (/app/admin/mcp-config/[kind]/[id]).
//
// Value semantics follow F2 EffectiveToolset: an absent tool entry means
// enabled + visible (inverted semantics); `hide_until` / `enable_for_hours`
// are F3 temporal-window fields and are mutually exclusive.
//
// Kit imports resolve once feat/ui-kit merges; until then tsc fails on this
// file (acceptable per TOBOR-CONTRACTS.md §8).
// ---------------------------------------------------------------------------

// F5-integration: the kit's ACL shapes (feat/ui-kit) are canonical — the
// former local stand-ins (ClientAclRule/ClientAclGroup) are dropped in favor
// of AclRule/AclGroup/AclState exported from @/components/kit.

export interface ClientPermissionsToolState {
  enabled: boolean;
  visible: boolean;
  /** F3: ISO timestamp — hide the tool until this instant. */
  hide_until: string | null;
  /** F3: hours the tool stays enabled once triggered. Mutually exclusive with hide_until. */
  enable_for_hours: number | null;
}

export interface ClientPermissionsValue {
  /** Keyed by canonical underscore tool name (F5). */
  tools: Record<string, ClientPermissionsToolState>;
  acl: AclState;
}

export interface ClientPermissionsCatalogGroup {
  /** Catalog group id (used as the toolset_config groups key on save). */
  id: string;
  group: string;
  tools: { name: string; description?: string }[];
}

const DEFAULT_TOOL_STATE: ClientPermissionsToolState = {
  enabled: true,
  visible: true,
  hide_until: null,
  enable_for_hours: null,
};

type GridGroups = ToolSection[];
type WindowValue = { hide_until: string | null; enable_for_hours: number | null };

export function defaultClientPermissions(
  catalog: ClientPermissionsCatalogGroup[] = [],
): ClientPermissionsValue {
  const tools: Record<string, ClientPermissionsToolState> = {};
  for (const group of catalog) {
    for (const tool of group.tools) {
      tools[tool.name] = { ...DEFAULT_TOOL_STATE };
    }
  }
  return { tools, acl: { rules: [], groups: [] } };
}

interface ClientPermissionsEditorProps {
  /** Display name of the client being edited (API key label / OAuth client name). */
  label?: string;
  /** Full tool catalog grouped for display. */
  catalog: ClientPermissionsCatalogGroup[];
  value: ClientPermissionsValue;
  onChange: (next: ClientPermissionsValue) => void;
  readOnly?: boolean;
  /** Hide the ACL section for clients that don't take ACL grants. */
  showAcl?: boolean;
}

type Section = 'tools' | 'windows' | 'acl';

export default function ClientPermissionsEditor({
  label,
  catalog,
  value,
  onChange,
  readOnly = false,
  showAcl = true,
}: ClientPermissionsEditorProps) {
  const [section, setSection] = useState<Section>('tools');
  const [windowTool, setWindowTool] = useState<string>('');

  const toolNames = useMemo(
    () => catalog.flatMap((g) => g.tools.map((t) => t.name)),
    [catalog],
  );

  // Keep the window-section tool selection valid as the catalog changes.
  const selectedWindowTool = windowTool && toolNames.includes(windowTool) ? windowTool : toolNames[0] ?? '';

  function stateFor(name: string): ClientPermissionsToolState {
    return value.tools[name] ?? { ...DEFAULT_TOOL_STATE };
  }

  function patchTool(name: string, patch: Partial<ClientPermissionsToolState>) {
    onChange({
      ...value,
      tools: { ...value.tools, [name]: { ...stateFor(name), ...patch } },
    });
  }

  // --- Tools section (ToolTogglesGrid) ------------------------------------
  const gridGroups: GridGroups = catalog.map((g) => ({
    name: g.group,
    tools: g.tools.map((t) => {
      const s = stateFor(t.name);
      return {
        tool: { kind: 'mcp_tool', id: t.name },
        state: { enabled: s.enabled, visible: s.visible },
      };
    }),
  }));

  function handleGridChange(nextGroups: GridGroups) {
    const tools = { ...value.tools };
    for (const section of nextGroups) {
      for (const entry of section.tools) {
        const name = entry.tool.id;
        // Preserve window fields; take enabled/visible from the grid.
        tools[name] = {
          ...stateFor(name),
          enabled: entry.state.enabled,
          visible: entry.state.visible,
        };
      }
    }
    onChange({ ...value, tools });
  }

  // --- Windows section (TempWindowEditor, one tool at a time) --------------
  const windowState: WindowValue = selectedWindowTool
    ? (() => {
        const s = stateFor(selectedWindowTool);
        return { hide_until: s.hide_until, enable_for_hours: s.enable_for_hours };
      })()
    : { hide_until: null, enable_for_hours: null };

  function handleWindowChange(next: WindowValue) {
    if (!selectedWindowTool) return;
    // Mutual exclusion: setting one window field clears the other.
    patchTool(selectedWindowTool, {
      hide_until: next.hide_until ?? null,
      enable_for_hours: next.enable_for_hours ?? null,
    });
  }

  // --- ACL section (ACLEditor) ---------------------------------------------
  function handleAclChange(next: AclState) {
    onChange({ ...value, acl: next });
  }

  const sections: { id: Section; label: string }[] = [
    { id: 'tools', label: 'Tools' },
    { id: 'windows', label: 'Access windows' },
    ...(showAcl ? [{ id: 'acl' as const, label: 'Access control' }] : []),
  ];

  return (
    <section className="dash-panel">
      <div className="dash-panel__head">
        <h2 className="dash-panel__title">
          Client permissions{label ? ` — ${label}` : ''}
        </h2>
        {readOnly && <span className="dash-badge">read-only</span>}
      </div>

      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 16 }}>
        {sections.map((s) => (
          <button
            key={s.id}
            type="button"
            className={`sg-btn sg-btn--sm ${section === s.id ? 'sg-btn--black' : 'sg-btn--outline'}`}
            onClick={() => setSection(s.id)}
          >
            {s.label}
          </button>
        ))}
      </div>

      {section === 'tools' && (
        <div>
          <p className="sg-page-intro" style={{ marginBottom: 12 }}>
            Toggle whether each tool is executable (enabled) and discoverable via listing
            (visible). Untouched tools stay enabled and visible.
          </p>
          <ToolTogglesGrid sections={gridGroups} onChange={handleGridChange} readOnly={readOnly} />
        </div>
      )}

      {section === 'windows' && (
        <div>
          <p className="sg-page-intro" style={{ marginBottom: 12 }}>
            Optional temporal windows per tool. A tool can be hidden until a date
            (<span className="font-mono">hide until</span>) or enabled for a limited window
            (<span className="font-mono">enable for hours</span>) — not both.
          </p>
          <div className="sg-field" style={{ maxWidth: 360 }}>
            <label htmlFor="cpe-window-tool">Tool</label>
            <select
              id="cpe-window-tool"
              value={selectedWindowTool}
              onChange={(e) => setWindowTool(e.target.value)}
              disabled={readOnly || toolNames.length === 0}
            >
              {toolNames.map((name) => (
                <option key={name} value={name}>
                  {name}
                </option>
              ))}
            </select>
          </div>
          {selectedWindowTool ? (
            <div style={{ marginTop: 12 }}>
              <TempWindowEditor
                value={windowState}
                onChange={handleWindowChange}
                readOnly={readOnly}
              />
            </div>
          ) : (
            <p className="sg-page-intro">No tools in the catalog yet.</p>
          )}
        </div>
      )}

      {section === 'acl' && showAcl && (
        <div>
          <p className="sg-page-intro" style={{ marginBottom: 12 }}>
            ACL rules and group bindings scoped to this client. Deny wins; no match keeps the
            tool enabled (inverted semantics).
          </p>
          <ACLEditor value={value.acl} onChange={handleAclChange} />
        </div>
      )}
    </section>
  );
}
