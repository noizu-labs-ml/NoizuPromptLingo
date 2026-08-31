'use client';

import { Fragment, useCallback, useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { toast } from 'sonner';
import {
  api,
  type McpCustomGroup,
  type McpCustomScope,
  type McpCustomScopeConfig,
  type McpCustomTool,
} from '@/lib/api';
import { ToolOverrideFields } from '@/components/kit/tool-overrides-editor';
import {
  applyOverridePatch,
  canonicalToolName,
  hasOverrides,
  overrideEntry,
  type ToolOverrideEntry,
} from '@/lib/tool-overrides';

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
  const [overridesOpen, setOverridesOpen] = useState<Record<string, boolean>>({});

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

  // W9 — name/description/arg-description overrides. Entries key by canonical
  // underscore tool name (contract §4/§7); toggle fields are preserved.
  function setToolOverrides(groupId: string, toolName: string, entry: ToolOverrideEntry) {
    setForm((current) => ({
      ...current,
      config: applyOverridePatch(current.config, groupId, toolName, entry),
    }));
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
      if (form.originalSlug === scope.slug) setForm(blankForm());
      toast.success('Scope deleted');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Delete failed');
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
          MCP client setup. <Link href="/app/admin">Back to Admin</Link>
        </p>

        {loading ? (
          <p className="sg-page-intro">Loading...</p>
        ) : (
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(min(100%, 320px), 1fr))', gap: '1rem', alignItems: 'start' }}>
            <section className="dash-panel">
              <div className="dash-panel__head">
                <h2 className="dash-panel__title">Scopes</h2>
                <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => setForm(blankForm())}>Add endpoint</button>
              </div>
              {scopes.length === 0 ? (
                <p className="sg-page-intro">No custom scopes yet.</p>
              ) : (
                <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                  {scopes.map((scope) => (
                    <button
                      key={scope.id}
                      className={`sg-btn ${form.originalSlug === scope.slug ? 'sg-btn--black' : 'sg-btn--outline'}`}
                      style={{ justifyContent: 'flex-start', textAlign: 'left' }}
                      onClick={() => setForm(formFromScope(scope))}
                    >
                      <span>
                        <span style={{ display: 'block', fontWeight: 600 }}>
                          {scope.name}
                          {scope.slug === DEFAULT_SLUG ? ' (default)' : ''}
                        </span>
                        <span className="font-mono" style={{ display: 'block', fontSize: 12 }}>{scope.slug}</span>
                      </span>
                    </button>
                  ))}
                </div>
              )}
            </section>

            <form className="dash-panel" onSubmit={save}>
              <div className="dash-panel__head">
                <h2 className="dash-panel__title">{form.originalSlug ? 'Edit Scope' : 'New Scope'}</h2>
                <div style={{ display: 'flex', gap: 8 }}>
                  {selectedScope?.url && (
                    <button type="button" className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => copy(selectedScope.url)}>
                      Copy URL
                    </button>
                  )}
                  {form.originalSlug && (
                    <button type="button" className="sg-btn sg-btn--outline sg-btn--sm" onClick={duplicate} disabled={saving}>
                      Copy endpoint
                    </button>
                  )}
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '1rem' }}>
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

              <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
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
                                <th>Category</th>
                                <th>Enabled</th>
                                <th>Visible</th>
                                <th>Overrides</th>
                              </tr>
                            </thead>
                            <tbody>
                              {group.tools.map((tool) => {
                                const toolKey = canonicalToolName(tool.name);
                                const openKey = `${group.id}/${toolKey}`;
                                const overridesShown = overridesOpen[openKey] ?? false;
                                const overridden = hasOverrides(form.config, group.id, toolKey);
                                return (
                                  <Fragment key={tool.name}>
                                    <tr>
                                      <td>
                                        <div className="font-mono">
                                          {tool.name}
                                          {overridden && (
                                            <span
                                              title="Has name/description overrides"
                                              style={{
                                                marginLeft: 6,
                                                fontSize: 9,
                                                padding: '1px 5px',
                                                borderRadius: 8,
                                                background: 'var(--accent, #333)',
                                                color: '#fff',
                                                verticalAlign: 'middle',
                                              }}
                                            >
                                              edited
                                            </span>
                                          )}
                                        </div>
                                        <span className="sg-field__hint">{tool.description}</span>
                                      </td>
                                      <td>{tool.category}</td>
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
                                      <td>
                                        <button
                                          type="button"
                                          className="sg-btn sg-btn--outline sg-btn--sm"
                                          aria-expanded={overridesShown}
                                          onClick={() =>
                                            setOverridesOpen((cur) => ({ ...cur, [openKey]: !overridesShown }))
                                          }
                                        >
                                          {overridesShown ? 'Hide' : 'Edit'}
                                        </button>
                                      </td>
                                    </tr>
                                    {overridesShown && (
                                      <tr>
                                        <td colSpan={5} style={{ background: 'var(--bg-3, #fafafa)' }}>
                                          <ToolOverrideFields
                                            idPrefix={`scope-${group.id}-${toolKey}`}
                                            tool={tool}
                                            entry={overrideEntry(form.config, group.id, toolKey)}
                                            onChange={(next) => setToolOverrides(group.id, tool.name, next)}
                                          />
                                        </td>
                                      </tr>
                                    )}
                                  </Fragment>
                                );
                              })}
                            </tbody>
                          </table>
                        </div>
                      )}
                    </section>
                  );
                })}
              </div>

              <div className="modal-actions">
                {form.originalSlug && form.originalSlug !== DEFAULT_SLUG && (
                  <button type="button" className="sg-btn sg-btn--danger" onClick={() => selectedScope && remove(selectedScope)}>
                    Delete
                  </button>
                )}
                <button type="submit" className="sg-btn sg-btn--black" disabled={saving}>
                  {saving ? 'Saving...' : 'Save Scope'}
                </button>
              </div>
            </form>
          </div>
        )}
      </main>
    </div>
  );
}
