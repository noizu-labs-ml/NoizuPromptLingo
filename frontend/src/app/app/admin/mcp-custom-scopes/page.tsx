'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { toast } from 'sonner';
import {
  api,
  type McpCustomGroup,
  type McpCustomScope,
  type McpCustomScopeConfig,
  type McpCustomTool,
} from '@/lib/api';
import {
  ContextMenu,
  SlideOverSidebar,
  ACLEditor,
  ToolTogglesGrid,
  TempWindowEditor,
  type ContextMenuItem,
  type AclState,
  type ToolToggleGroup,
  type TempWindow,
} from '@/components/kit';
import {
  fetchAclGroups,
  fetchClientPermissions,
  fetchScopeClients,
  saveClientPermissions,
  type ClientPermissions,
  type ScopeClient,
} from '@/lib/acl-api';
import McpEndpointSetupPopunder from '@/components/mcp-endpoint-setup-popunder';

type ScopeForm = {
  originalSlug?: string;
  slug: string;
  name: string;
  description: string;
  kind: string;
  config: McpCustomScopeConfig;
};

const DEFAULT_SLUG = 'tobor';

const emptyConfig = (): McpCustomScopeConfig => ({ groups: {} });

const emptyTempWindow = (): TempWindow => ({ hide_until: null, enable_for_hours: null });

function slugify(value: string) {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 63);
}

function normalizeConfig(config?: McpCustomScopeConfig | null): McpCustomScopeConfig {
  return { groups: { ...(config?.groups ?? {}) } };
}

function blankForm(): ScopeForm {
  return { slug: '', name: '', description: '', kind: 'custom', config: emptyConfig() };
}

function formFromScope(scope: McpCustomScope): ScopeForm {
  return {
    originalSlug: scope.slug,
    slug: scope.slug,
    name: scope.name,
    description: scope.description ?? '',
    kind: scope.kind || 'custom',
    config: normalizeConfig(scope.config),
  };
}

function stubScopeUrl(scope?: McpCustomScope | null): string {
  if (!scope) return 'https://tobor.locker/org/:org_slug/custom/:slug/mcp';
  return (
    scope.url || `https://tobor.locker/org/:org_slug/custom/${encodeURIComponent(scope.slug)}/mcp`
  );
}

function included(config: McpCustomScopeConfig, groupId: string) {
  return !!config.groups[groupId] && config.groups[groupId].disabled !== true;
}

function toolOverride(config: McpCustomScopeConfig, groupId: string, toolName: string) {
  return config.groups[groupId]?.tools?.[toolName] ?? {};
}

function toolEnabled(config: McpCustomScopeConfig, groupId: string, toolName: string) {
  return toolOverride(config, groupId, toolName).disabled !== true;
}

function toolVisible(config: McpCustomScopeConfig, groupId: string, tool: McpCustomTool) {
  const override = toolOverride(config, groupId, tool.name);
  return override.hidden === undefined ? !tool.hidden : override.hidden !== true;
}

function nextConfig(
  config: McpCustomScopeConfig,
  update: (draft: McpCustomScopeConfig) => void,
) {
  const draft: McpCustomScopeConfig = {
    groups: Object.fromEntries(
      Object.entries(config.groups ?? {}).map(([groupId, group]) => [
        groupId,
        { ...group, tools: { ...(group.tools ?? {}) } },
      ]),
    ),
  };
  update(draft);
  return draft;
}

export default function AdminMcpCustomScopesPage() {
  const [catalog, setCatalog] = useState<McpCustomGroup[]>([]);
  const [scopes, setScopes] = useState<McpCustomScope[]>([]);
  const [form, setForm] = useState<ScopeForm>(blankForm());
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  // W6: settings sidebar (double-click a scope to toggle) + its tabs.
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [activeTab, setActiveTab] = useState('edit');

  // W6: Manage Clients tab state.
  const [clients, setClients] = useState<ScopeClient[]>([]);
  const [clientsLoading, setClientsLoading] = useState(false);
  const [selectedClientId, setSelectedClientId] = useState<string | null>(null);
  const [clientPerms, setClientPerms] = useState<ClientPermissions | null>(null);
  const [clientPermsLoading, setClientPermsLoading] = useState(false);
  const [clientSaving, setClientSaving] = useState(false);
  const [aclGroups, setAclGroups] = useState<{ id: string; name: string }[]>([]);
  const [tempTool, setTempTool] = useState('');
  const [newGroupName, setNewGroupName] = useState('');
  const [setupScope, setSetupScope] = useState<McpCustomScope | null>(null);

  const selectedScope = useMemo(
    () => scopes.find((s) => s.slug === form.originalSlug) ?? null,
    [form.originalSlug, scopes],
  );

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const [catalogRes, scopesRes] = await Promise.all([
        api.adminMcpCustomScopeCatalog(),
        api.adminListMcpCustomScopes(),
      ]);
      setCatalog(catalogRes.groups ?? []);
      setScopes(scopesRes.scopes ?? []);
      setForm((current) => {
        if (current.originalSlug) {
          const updated = scopesRes.scopes.find((s) => s.slug === current.originalSlug);
          return updated ? formFromScope(updated) : current;
        }
        const def = scopesRes.scopes.find((s) => s.slug === DEFAULT_SLUG);
        return def ? formFromScope(def) : current;
      });
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load custom scopes');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  // Load clients + ACL group names when a scope with clients context is active.
  useEffect(() => {
    if (!sidebarOpen || activeTab !== 'clients' || !form.originalSlug) return;
    let cancelled = false;
    setClientsLoading(true);
    Promise.all([fetchScopeClients(form.originalSlug), fetchAclGroups()])
      .then(([clientList, groups]) => {
        if (cancelled) return;
        setClients(clientList);
        setAclGroups(groups);
        setSelectedClientId((current) =>
          current && clientList.some((c) => c.id === current) ? current : clientList[0]?.id ?? null,
        );
      })
      .catch((err) => {
        if (!cancelled) toast.error(err instanceof Error ? err.message : 'Failed to load clients');
      })
      .finally(() => {
        if (!cancelled) setClientsLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [sidebarOpen, activeTab, form.originalSlug]);

  // Load the selected client's permission bundle.
  useEffect(() => {
    if (!sidebarOpen || activeTab !== 'clients' || !form.originalSlug || !selectedClientId) {
      setClientPerms(null);
      return;
    }
    const client = clients.find((c) => c.id === selectedClientId);
    if (!client) return;
    let cancelled = false;
    setClientPermsLoading(true);
    fetchClientPermissions(form.originalSlug, client)
      .then((perms) => {
        if (!cancelled) setClientPerms(perms);
      })
      .catch((err) => {
        if (!cancelled) toast.error(err instanceof Error ? err.message : 'Failed to load client permissions');
      })
      .finally(() => {
        if (!cancelled) setClientPermsLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [sidebarOpen, activeTab, form.originalSlug, selectedClientId, clients]);

  // ── Scope config editing (persisted via existing scope-update API) ──

  function updateConfig(update: (draft: McpCustomScopeConfig) => void) {
    setForm((current) => ({ ...current, config: nextConfig(current.config, update) }));
  }

  function setGroupIncluded(groupId: string, value: boolean) {
    updateConfig((draft) => {
      if (value) {
        draft.groups[groupId] = draft.groups[groupId] ?? { tools: {} };
        delete draft.groups[groupId].disabled;
      } else {
        delete draft.groups[groupId];
      }
    });
  }

  function setGroupVisible(groupId: string, value: boolean) {
    updateConfig((draft) => {
      draft.groups[groupId] = draft.groups[groupId] ?? { tools: {} };
      draft.groups[groupId].hidden = !value;
    });
  }

  function setToolEnabled(groupId: string, toolName: string, value: boolean) {
    updateConfig((draft) => {
      const group = draft.groups[groupId] ?? { tools: {} };
      group.tools = group.tools ?? {};
      const tool = group.tools[toolName] ?? {};
      if (value) delete tool.disabled;
      else tool.disabled = true;
      group.tools[toolName] = tool;
      draft.groups[groupId] = group;
    });
  }

  function setToolVisible(groupId: string, toolName: string, value: boolean) {
    updateConfig((draft) => {
      const group = draft.groups[groupId] ?? { tools: {} };
      group.tools = group.tools ?? {};
      group.tools[toolName] = { ...(group.tools[toolName] ?? {}), hidden: !value };
      draft.groups[groupId] = group;
    });
  }

  async function save(e: React.FormEvent) {
    e.preventDefault();
    if (!form.name.trim()) {
      toast.error('Name is required');
      return;
    }
    if (!form.slug.trim()) {
      toast.error('Slug is required');
      return;
    }

    setSaving(true);
    try {
      const payload = {
        slug: form.slug.trim(),
        name: form.name.trim(),
        description: form.description.trim(),
        kind: form.kind || 'custom',
        config: form.config,
      };
      const res = form.originalSlug
        ? await api.adminUpdateMcpCustomScope(form.originalSlug, payload)
        : await api.adminCreateMcpCustomScope(payload);
      setScopes((prev) => [res.scope, ...prev.filter((s) => s.id !== res.scope.id)]);
      setForm(formFromScope(res.scope));
      toast.success(form.originalSlug ? 'Scope updated' : 'Scope created');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Save failed');
    } finally {
      setSaving(false);
    }
  }

  async function remove(scope: McpCustomScope) {
    if (scope.slug === DEFAULT_SLUG) {
      toast.error('The default Tobor Locker package cannot be deleted');
      return;
    }
    if (!confirm(`Delete ${scope.name}?`)) return;
    try {
      await api.adminDeleteMcpCustomScope(scope.slug);
      setScopes((prev) => prev.filter((s) => s.id !== scope.id));
      if (form.originalSlug === scope.slug) {
        setForm(blankForm());
        setSidebarOpen(false);
      }
      toast.success('Scope deleted');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Delete failed');
    }
  }

  async function renameScope(scope: McpCustomScope) {
    const name = prompt('Rename scope', scope.name);
    if (name === null) return;
    const trimmed = name.trim();
    if (!trimmed) {
      toast.error('Name is required');
      return;
    }
    try {
      const res = await api.adminUpdateMcpCustomScope(scope.slug, { name: trimmed });
      setScopes((prev) => [res.scope, ...prev.filter((s) => s.id !== res.scope.id)]);
      if (form.originalSlug === scope.slug) setForm(formFromScope(res.scope));
      toast.success('Scope renamed');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Rename failed');
    }
  }

  async function cloneScope(scope: McpCustomScope) {
    setSaving(true);
    try {
      const res = await api.adminCreateMcpCustomScope({
        slug: slugify(`${scope.slug}-clone`),
        name: `${scope.name} clone`,
        description: scope.description ?? '',
        kind: scope.kind === 'all_in_one' ? 'custom' : scope.kind || 'custom',
        config: normalizeConfig(scope.config),
      });
      setScopes((prev) => [res.scope, ...prev.filter((s) => s.id !== res.scope.id)]);
      setForm(formFromScope(res.scope));
      setSidebarOpen(true);
      setActiveTab('edit');
      toast.success('Cloned to a new endpoint');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Clone failed');
    } finally {
      setSaving(false);
    }
  }

  async function duplicate() {
    if (!form.originalSlug) {
      toast.error('Save the endpoint before copying it');
      return;
    }
    setSaving(true);
    try {
      const res = await api.adminCreateMcpCustomScope({
        slug: slugify(`${form.slug}-copy`),
        name: `${form.name} copy`,
        description: form.description.trim(),
        kind: form.kind === 'all_in_one' ? 'custom' : form.kind || 'custom',
        config: form.config,
      });
      setScopes((prev) => [res.scope, ...prev.filter((s) => s.id !== res.scope.id)]);
      setForm(formFromScope(res.scope));
      toast.success('Copied to a new endpoint');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Copy failed');
    } finally {
      setSaving(false);
    }
  }

  async function copy(text?: string | null) {
    if (!text) return;
    try {
      await navigator.clipboard.writeText(text);
      toast.success('Copied');
    } catch {
      toast.error('Copy failed');
    }
  }

  // ── W6: context menu + sidebar wiring ──

  function openSettings(scope: McpCustomScope) {
    setForm(formFromScope(scope));
    setSidebarOpen(true);
    setActiveTab('edit');
  }

  function toggleSettings(scope: McpCustomScope) {
    if (form.originalSlug === scope.slug) {
      setSidebarOpen((open) => !open);
    } else {
      setForm(formFromScope(scope));
      setSidebarOpen(true);
      setActiveTab('edit');
    }
  }

  function scopeMenuItems(scope: McpCustomScope): ContextMenuItem[] {
    const isDefault = scope.slug === DEFAULT_SLUG;
    return [
      { id: 'open-settings', label: 'Open settings' },
      { id: 'rename', label: 'Rename', disabled: isDefault },
      {
        id: 'clone',
        label: 'Clone endpoint',
        separatorBefore: true,
        disabled: saving,
      },
      { id: 'setup', label: 'Setup MCP' },
      { id: 'delete', label: 'Delete', destructive: true, disabled: isDefault },
    ];
  }

  function onScopeMenu(scope: McpCustomScope, id: string) {
    if (id === 'open-settings') openSettings(scope);
    else if (id === 'rename') renameScope(scope);
    else if (id === 'clone') cloneScope(scope);
    else if (id === 'setup') setSetupScope(scope);
    else if (id === 'delete') remove(scope);
  }

  // ── W6: Manage Clients editors ──

  const selectedClient = clients.find((c) => c.id === selectedClientId) ?? null;

  /** Client toolset toggles derived from catalog × client toolset_config (absent = enabled + visible). */
  const clientToggleGroups: ToolToggleGroup[] = useMemo(() => {
    const cfg = clientPerms?.toolsetConfig ?? { groups: {} };
    return catalog.map((group) => ({
      group: group.label,
      tools: group.tools.map((tool) => {
        const override = cfg.groups[group.id]?.tools?.[tool.name] ?? {};
        return {
          name: tool.name,
          enabled: override.disabled !== true,
          hidden: override.hidden === undefined ? tool.hidden : override.hidden,
        };
      }),
    }));
  }, [catalog, clientPerms]);

  function patchClientToggleGroups(next: ToolToggleGroup[]) {
    setClientPerms((current) => {
      if (!current) return current;
      const labelToId = new Map(catalog.map((g) => [g.label, g.id]));
      const groups: McpCustomScopeConfig['groups'] = {};
      for (const tg of next) {
        const groupId = labelToId.get(tg.group) ?? tg.group;
        const catalogGroup = catalog.find((g) => g.id === groupId);
        const tools: Record<string, { disabled?: boolean; hidden?: boolean }> = {};
        for (const entry of tg.tools) {
          const catalogTool = catalogGroup?.tools.find((t) => t.name === entry.name);
          const tool: { disabled?: boolean; hidden?: boolean } = {};
          if (!entry.enabled) tool.disabled = true;
          // Only persist hidden when it diverges from the catalog default
          // (inverted semantics: absent = visible).
          if (catalogTool && entry.hidden !== catalogTool.hidden) tool.hidden = entry.hidden;
          else if (!catalogTool && entry.hidden) tool.hidden = true;
          tools[entry.name] = tool;
        }
        groups[groupId] = { tools };
      }
      return { ...current, toolsetConfig: { groups } };
    });
  }

  const flattenedClientTools = useMemo(
    () =>
      catalog.flatMap((group) =>
        group.tools.map((tool) => ({ groupId: group.id, groupIdLabel: group.label, name: tool.name })),
      ),
    [catalog],
  );

  const currentTempWindow: TempWindow =
    (tempTool && clientPerms?.tempWindows[tempTool]) || emptyTempWindow();

  function setTempWindow(next: TempWindow) {
    if (!tempTool) return;
    setClientPerms((current) =>
      current
        ? { ...current, tempWindows: { ...current.tempWindows, [tempTool]: next } }
        : current,
    );
  }

  const groupNameSuggestions = useMemo(() => {
    const names = new Set(aclGroups.map((g) => g.name));
    for (const g of clientPerms?.acl.groups ?? []) names.add(g.name);
    return [...names];
  }, [aclGroups, clientPerms]);

  function assignPermissionGroup(name: string) {
    const trimmed = name.trim();
    if (!trimmed || !clientPerms) return;
    if (clientPerms.permissionGroups.includes(trimmed)) return;
    setClientPerms({
      ...clientPerms,
      permissionGroups: [...clientPerms.permissionGroups, trimmed],
    });
    setNewGroupName('');
  }

  function unassignPermissionGroup(name: string) {
    setClientPerms((current) =>
      current
        ? { ...current, permissionGroups: current.permissionGroups.filter((g) => g !== name) }
        : current,
    );
  }

  async function saveClient() {
    if (!form.originalSlug || !clientPerms) return;
    setClientSaving(true);
    try {
      const res = await saveClientPermissions(form.originalSlug, clientPerms);
      if (res.stub) {
        toast.success('Saved locally (stub — ACL backend endpoints not merged yet)');
      } else {
        toast.success('Client permissions saved');
      }
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Save failed');
    } finally {
      setClientSaving(false);
    }
  }

  // ── Sidebar tab contents ──

  const editScopeTab = (
    <form onSubmit={save} style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
      <div className="sg-field">
        <label htmlFor="mcp-name">Name</label>
        <input
          id="mcp-name"
          value={form.name}
          onChange={(e) => {
            const name = e.target.value;
            setForm((current) => ({
              ...current,
              name,
              slug: current.slug ? current.slug : slugify(name),
            }));
          }}
        />
      </div>
      <div className="sg-field">
        <label htmlFor="mcp-slug">Slug</label>
        <input
          id="mcp-slug"
          value={form.slug}
          disabled={form.originalSlug === DEFAULT_SLUG}
          onChange={(e) => setForm((current) => ({ ...current, slug: slugify(e.target.value) }))}
        />
      </div>
      <div className="sg-field">
        <label htmlFor="mcp-kind">Kind</label>
        <select
          id="mcp-kind"
          value={form.kind}
          disabled={form.originalSlug === DEFAULT_SLUG}
          onChange={(e) => setForm((current) => ({ ...current, kind: e.target.value }))}
        >
          <option value="all_in_one">All-in-one (grouped default package)</option>
          <option value="custom">Custom (a-la-carte extra endpoint)</option>
          <option value="core_variant">Core variant</option>
        </select>
      </div>
      <div className="sg-field">
        <label htmlFor="mcp-description">Description</label>
        <textarea
          id="mcp-description"
          value={form.description}
          onChange={(e) => setForm((current) => ({ ...current, description: e.target.value }))}
          rows={3}
        />
      </div>

      {catalog.map((group) => {
        const isIncluded = included(form.config, group.id);
        const visibleByDefault = form.config.groups[group.id]?.hidden !== true;
        return (
          <section key={group.id} style={{ border: '1px solid var(--border, #e5e5e5)', borderRadius: 8, padding: '0.875rem' }}>
            <div style={{ display: 'flex', alignItems: 'start', justifyContent: 'space-between', gap: '1rem' }}>
              <div>
                <label style={{ display: 'flex', alignItems: 'center', gap: 8, fontWeight: 700 }}>
                  <input
                    type="checkbox"
                    checked={isIncluded}
                    onChange={(e) => setGroupIncluded(group.id, e.target.checked)}
                  />
                  {group.label}
                </label>
                <span className="sg-field__hint">{group.desc}</span>
              </div>
              {isIncluded && (
                <label style={{ display: 'flex', alignItems: 'center', gap: 8, whiteSpace: 'nowrap', fontSize: 13 }}>
                  <input
                    type="checkbox"
                    checked={visibleByDefault}
                    onChange={(e) => setGroupVisible(group.id, e.target.checked)}
                  />
                  Visible by default
                </label>
              )}
            </div>

            {isIncluded && (
              <div style={{ overflowX: 'auto', marginTop: '0.75rem' }}>
                <table className="sg-table">
                  <thead>
                    <tr>
                      <th>Tool</th>
                      <th>Enabled</th>
                      <th>Visible</th>
                    </tr>
                  </thead>
                  <tbody>
                    {group.tools.map((tool) => (
                      <tr key={tool.name}>
                        <td>
                          <div className="font-mono">{tool.name}</div>
                          <span className="sg-field__hint">{tool.description}</span>
                        </td>
                        <td>
                          <input
                            type="checkbox"
                            checked={toolEnabled(form.config, group.id, tool.name)}
                            onChange={(e) => setToolEnabled(group.id, tool.name, e.target.checked)}
                            aria-label={`${tool.name} enabled`}
                          />
                        </td>
                        <td>
                          <input
                            type="checkbox"
                            checked={toolVisible(form.config, group.id, tool)}
                            onChange={(e) => setToolVisible(group.id, tool.name, e.target.checked)}
                            aria-label={`${tool.name} visible`}
                          />
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </section>
        );
      })}

      {form.originalSlug && form.originalSlug !== DEFAULT_SLUG && (
        <div style={{ display: 'flex', gap: 8 }}>
          <button type="button" className="sg-btn sg-btn--outline sg-btn--sm" onClick={duplicate} disabled={saving}>
            Copy endpoint
          </button>
          <button
            type="button"
            className="sg-btn sg-btn--danger sg-btn--sm"
            onClick={() => selectedScope && remove(selectedScope)}
          >
            Delete
          </button>
        </div>
      )}

      <button type="submit" className="sg-btn sg-btn--black" disabled={saving}>
        {saving ? 'Saving...' : 'Save Scope'}
      </button>
    </form>
  );

  const manageClientsTab = (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
      {clientsLoading ? (
        <p className="sg-page-intro">Loading clients...</p>
      ) : clients.length === 0 ? (
        <p className="sg-page-intro">
          No clients (API keys / OAuth clients) are attached to this endpoint yet.
        </p>
      ) : (
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
          {clients.map((client) => (
            <button
              key={client.id}
              type="button"
              className={`sg-btn sg-btn--sm ${selectedClientId === client.id ? 'sg-btn--black' : 'sg-btn--outline'}`}
              onClick={() => setSelectedClientId(client.id)}
            >
              <span className="font-mono" style={{ fontSize: 11 }}>
                {client.kind === 'api_key' ? 'key' : 'oauth'}
              </span>
              {client.label}
              {client.status !== 'active' ? ' (revoked)' : ''}
            </button>
          ))}
        </div>
      )}

      {clientPermsLoading && <p className="sg-page-intro">Loading permissions...</p>}

      {selectedClient && clientPerms && !clientPermsLoading && (
        <>
          <section style={{ border: '1px solid var(--border, #e5e5e5)', borderRadius: 8, padding: '0.875rem' }}>
            <h3 style={{ margin: '0 0 0.5rem', fontSize: 13, fontWeight: 700 }}>Restrict tools</h3>
            <span className="sg-field__hint" style={{ display: 'block', marginBottom: '0.5rem' }}>
              Per-client overrides layer on top of the scope config (absent = enabled + visible).
            </span>
            <ToolTogglesGrid
              groups={clientToggleGroups}
              onChange={patchClientToggleGroups}
            />
          </section>

          <section style={{ border: '1px solid var(--border, #e5e5e5)', borderRadius: 8, padding: '0.875rem' }}>
            <h3 style={{ margin: '0 0 0.5rem', fontSize: 13, fontWeight: 700 }}>Visibility windows</h3>
            <div className="sg-field">
              <label htmlFor="mcp-temp-tool">Tool</label>
              <select
                id="mcp-temp-tool"
                value={tempTool}
                onChange={(e) => setTempTool(e.target.value)}
              >
                <option value="">— pick a tool —</option>
                {flattenedClientTools.map((t) => (
                  <option key={`${t.groupId}:${t.name}`} value={t.name}>
                    {t.name}
                  </option>
                ))}
              </select>
            </div>
            {tempTool ? (
              <>
                <TempWindowEditor value={currentTempWindow} onChange={setTempWindow} />
                {clientPerms.tempWindows[tempTool] && (
                  <button
                    type="button"
                    className="sg-btn sg-btn--outline sg-btn--sm"
                    style={{ marginTop: 8 }}
                    onClick={() => setTempWindow({ hide_until: null, enable_for_hours: null })}
                  >
                    Clear window
                  </button>
                )}
              </>
            ) : (
              <span className="sg-field__hint">Select a tool to set hide-until / enable-for windows.</span>
            )}
          </section>

          <section style={{ border: '1px solid var(--border, #e5e5e5)', borderRadius: 8, padding: '0.875rem' }}>
            <h3 style={{ margin: '0 0 0.5rem', fontSize: 13, fontWeight: 700 }}>ACL permissions</h3>
            <ACLEditor
              value={clientPerms.acl}
              onChange={(next: AclState) => setClientPerms({ ...clientPerms, acl: next })}
            />
          </section>

          <section style={{ border: '1px solid var(--border, #e5e5e5)', borderRadius: 8, padding: '0.875rem' }}>
            <h3 style={{ margin: '0 0 0.5rem', fontSize: 13, fontWeight: 700 }}>Permission groups</h3>
            <div style={{ display: 'flex', gap: 8 }}>
              <input
                list="acl-group-names"
                value={newGroupName}
                placeholder="Group name"
                onChange={(e) => setNewGroupName(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === 'Enter') {
                    e.preventDefault();
                    assignPermissionGroup(newGroupName);
                  }
                }}
                style={{ flex: 1 }}
              />
              <datalist id="acl-group-names">
                {groupNameSuggestions.map((name) => (
                  <option key={name} value={name} />
                ))}
              </datalist>
              <button
                type="button"
                className="sg-btn sg-btn--outline sg-btn--sm"
                onClick={() => assignPermissionGroup(newGroupName)}
              >
                Add
              </button>
            </div>
            {clientPerms.permissionGroups.length > 0 && (
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginTop: 8 }}>
                {clientPerms.permissionGroups.map((name) => (
                  <span
                    key={name}
                    style={{
                      display: 'inline-flex',
                      alignItems: 'center',
                      gap: 6,
                      fontSize: 12,
                      border: '1px solid var(--border)',
                      borderRadius: 999,
                      padding: '2px 10px',
                    }}
                  >
                    {name}
                    <button
                      type="button"
                      aria-label={`Remove from ${name}`}
                      onClick={() => unassignPermissionGroup(name)}
                      style={{ border: 0, background: 'none', cursor: 'pointer', color: 'var(--text-3)' }}
                    >
                      ×
                    </button>
                  </span>
                ))}
              </div>
            )}
          </section>

          <button
            type="button"
            className="sg-btn sg-btn--black"
            onClick={saveClient}
            disabled={clientSaving}
          >
            {clientSaving ? 'Saving...' : 'Save Client Permissions'}
          </button>
        </>
      )}
    </div>
  );

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">MCP endpoints</h1>
        </div>
        <p className="sg-page-intro">
          Users and organizations are always given a <strong>Tobor Locker</strong>
          endpoint cloned from the global template at{' '}
          <span className="font-mono">/custom/tobor/mcp</span>. Edit standard
          templates here; people can copy and edit their own instances from
          MCP client setup. Click a scope to select it, double-click to toggle
          its settings sidebar, right-click for actions.{' '}
          <Link href="/app/admin">Back to Admin</Link>
        </p>

        {loading ? (
          <p className="sg-page-intro">Loading...</p>
        ) : (
          <section className="dash-panel">
            <div className="dash-panel__head">
              <h2 className="dash-panel__title">Scopes</h2>
              <button
                className="sg-btn sg-btn--outline sg-btn--sm"
                onClick={() => {
                  setForm(blankForm());
                  setSidebarOpen(true);
                  setActiveTab('edit');
                }}
              >
                Add endpoint
              </button>
            </div>
            {scopes.length === 0 ? (
              <p className="sg-page-intro">No custom scopes yet.</p>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                {scopes.map((scope) => (
                  <ContextMenu
                    key={scope.id}
                    items={scopeMenuItems(scope)}
                    onSelect={(id: string) => onScopeMenu(scope, id)}
                    menuLabel={`Scope ${scope.name} actions`}
                  >
                    <button
                      className={`sg-btn ${form.originalSlug === scope.slug ? 'sg-btn--black' : 'sg-btn--outline'}`}
                      style={{ justifyContent: 'flex-start', textAlign: 'left', width: '100%' }}
                      onClick={() => setForm(formFromScope(scope))}
                      onDoubleClick={() => toggleSettings(scope)}
                    >
                      <span>
                        <span style={{ display: 'block', fontWeight: 600 }}>
                          {scope.name}
                          {scope.slug === DEFAULT_SLUG ? ' (default)' : ''}
                        </span>
                        <span className="font-mono" style={{ display: 'block', fontSize: 12 }}>{scope.slug}</span>
                      </span>
                    </button>
                  </ContextMenu>
                ))}
              </div>
            )}
          </section>
        )}

        <SlideOverSidebar
          open={sidebarOpen}
          onClose={() => setSidebarOpen(false)}
          title={form.originalSlug ? `Scope: ${form.name}` : 'New Scope'}
          width={520}
          activeTab={activeTab}
          onTabChange={setActiveTab}
          tabs={[
            { id: 'edit', label: 'Edit Scope', content: editScopeTab },
            { id: 'clients', label: 'Manage Clients', content: manageClientsTab },
          ]}
        />

        {setupScope && (
          <McpEndpointSetupPopunder
            open
            onClose={() => setSetupScope(null)}
            scope={setupScope}
            mcpUrl={stubScopeUrl(setupScope)}
          />
        )}
      </main>
    </div>
  );
}
