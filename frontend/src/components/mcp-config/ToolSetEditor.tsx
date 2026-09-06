'use client';

/**
 * N4a/N4b — `kind=tool-set` detail page for /app/admin/mcp-config (PRD-N4 §4.2).
 *
 * Create/edit form for a durable MCP tool set: identity, audience shape
 * (org/project/group — fixed at creation per the N2a changeset), settings
 * (allow_api_keys, description_verbosity, instructions), and the group-include
 * + closed-vocabulary overrides editor (`ToolSetOverridesEditor`).
 *
 * Built-in profile slugs render read-only with a Clone action (R1). N4b: the
 * Validate button dry-runs the draft through the backend (`validate/2`,
 * issues grouped by severity), the saved set's `effective` preview renders
 * the D1-correct live-catalog surface, the group selector lists REAL authz
 * groups (ladder roles labeled distinctly), and enum pruning picks from
 * live enum values (`arg-enum` seeds, session-cached).
 */
import { useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';

import { api, type McpCustomGroup } from '@/lib/api';
import {
  cloneToolSet,
  createToolSet,
  deactivateToolSet,
  getArgEnum,
  getToolSet,
  listToolSetGroupOptions,
  updateToolSet,
  validateToolSet,
  type DescriptionVerbosity,
  type ToolSetConfig,
  type ToolSetEffective,
  type ToolSetGroupOption,
  type ToolSetIssue,
  type ToolSetProfileView,
  type ToolSetSettings,
  type ToolSetShape,
  type ToolSetValidateResult,
  type ToolSetView,
} from '@/lib/acl-api';
import { ToolSetOverridesEditor } from '@/components/kit/tool-overrides-editor';
import { useOrg } from '@/context/org';

interface ToolSetFormState {
  slug: string;
  display_name: string;
  description: string;
  shape: ToolSetShape;
  project_id: string;
  group_id: string;
  config: ToolSetConfig;
  settings: ToolSetSettings;
}

function blankForm(): ToolSetFormState {
  return {
    slug: '',
    display_name: '',
    description: '',
    shape: 'org',
    project_id: '',
    group_id: '',
    config: { groups: {} },
    settings: { allow_api_keys: true, description_verbosity: 'full', instructions: '' },
  };
}

export default function ToolSetEditor({ slug }: { slug: string }) {
  const isNew = slug === 'new';
  const router = useRouter();
  const { currentOrg, projects, refreshProjects } = useOrg();
  const orgId = currentOrg?.id ?? null;

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [profile, setProfile] = useState<ToolSetProfileView | null>(null);
  const [view, setView] = useState<ToolSetView | null>(null);
  const [catalog, setCatalog] = useState<McpCustomGroup[]>([]);
  const [groupOptions, setGroupOptions] = useState<ToolSetGroupOption[]>([]);
  const [validation, setValidation] = useState<ToolSetValidateResult | null>(null);
  const [validating, setValidating] = useState(false);
  const [form, setForm] = useState<ToolSetFormState>(blankForm);

  const patch = (p: Partial<ToolSetFormState>) => setForm((cur) => ({ ...cur, ...p }));

  const load = useCallback(async () => {
    if (!orgId) return;
    setLoading(true);
    setValidation(null);
    try {
      if (isNew) {
        setProfile(null);
        setView(null);
        setForm(blankForm());
      } else {
        const res = await getToolSet(orgId, slug);
        if (res.profile) {
          setProfile(res.profile);
          setView(null);
        } else if (res.tool_set) {
          const t = res.tool_set;
          setProfile(null);
          setView(t);
          setForm({
            slug: t.slug,
            display_name: t.display_name ?? '',
            description: t.description ?? '',
            shape: t.shape,
            project_id: t.project_id ?? '',
            group_id: t.group_id ?? '',
            config: t.config ?? { groups: {} },
            settings: {
              allow_api_keys: t.settings?.allow_api_keys ?? true,
              description_verbosity: t.settings?.description_verbosity ?? 'full',
              instructions: t.settings?.instructions ?? '',
            },
          });
        } else {
          toast.error('Tool set not found');
        }
      }
      const [cat, options] = await Promise.all([
        api.adminMcpCustomScopeCatalog(),
        listToolSetGroupOptions(orgId),
      ]);
      setCatalog(cat.groups ?? []);
      setGroupOptions(options);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to load tool set');
    } finally {
      setLoading(false);
    }
  }, [orgId, isNew, slug]);

  useEffect(() => {
    void load();
  }, [load]);

  useEffect(() => {
    if (orgId) void refreshProjects();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [orgId]);

  async function save() {
    if (!orgId) return;
    setSaving(true);
    try {
      if (isNew) {
        const attrs = {
          slug: form.slug || undefined,
          display_name: form.display_name || undefined,
          description: form.description || undefined,
          project_id: form.shape === 'project' ? form.project_id : undefined,
          group_id: form.shape === 'group' ? form.group_id : undefined,
          config: form.config,
          settings: form.settings,
        };
        const created = await createToolSet(orgId, attrs);
        toast.success(`Tool set "${created.slug}" created`);
        router.replace(`/app/admin/mcp-config/tool-set/${encodeURIComponent(created.slug)}`);
      } else {
        const updated = await updateToolSet(orgId, slug, {
          display_name: form.display_name,
          description: form.description,
          config: form.config,
          settings: form.settings,
        });
        setView(updated);
        toast.success('Tool set saved');
      }
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Save failed');
    } finally {
      setSaving(false);
    }
  }

  async function doClone(source: string) {
    if (!orgId) return;
    try {
      const created = await cloneToolSet(orgId, source);
      toast.success(`Cloned to "${created.slug}"`);
      router.push(`/app/admin/mcp-config/tool-set/${encodeURIComponent(created.slug)}`);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Clone failed');
    }
  }

  async function doDeactivate() {
    if (!orgId || !view) return;
    try {
      const updated = await deactivateToolSet(orgId, view.slug);
      setView(updated);
      toast.success(`Tool set "${updated.slug}" deactivated`);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Deactivate failed');
    }
  }

  async function doReactivate() {
    if (!orgId || !view) return;
    try {
      const updated = await updateToolSet(orgId, view.slug, { is_active: true });
      setView(updated);
      toast.success(`Tool set "${updated.slug}" re-activated`);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Re-activate failed');
    }
  }

  // N4b: pure dry-run of the DRAFT config — never persists, so it is safe to
  // run on the create form too. Issues render grouped by severity below.
  async function doValidate() {
    if (!orgId || validating) return;
    setValidating(true);
    try {
      const result = await validateToolSet(orgId, { config: form.config, settings: form.settings });
      setValidation(result);
      if (result.ok) {
        toast.success(
          result.warnings.length > 0
            ? `Valid, with ${result.warnings.length} warning(s)`
            : 'Config validates cleanly',
        );
      }
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Validate failed');
    } finally {
      setValidating(false);
    }
  }

  if (!orgId) {
    return (
      <section className="dash-panel">
        <p className="sg-page-intro">Select an organization to manage tool sets.</p>
      </section>
    );
  }

  // Built-in profile: read-only view + clone (R1 — never editable).
  if (!isNew && profile) {
    return (
      <section className="dash-panel">
        <div className="dash-panel__head">
          <h2 className="dash-panel__title">
            Profile: {profile.display_name}{' '}
            <span className="dash-badge">built-in</span>
          </h2>
          <button type="button" className="sg-btn sg-btn--black sg-btn--sm" onClick={() => doClone(profile.slug)}>
            Clone
          </button>
        </div>
        <p className="sg-page-intro">{profile.description}</p>
        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', margin: '0.75rem 0' }}>
          <span className="dash-badge">{profile.group_count} groups</span>
          <span className="dash-badge">{profile.tool_count} tools</span>
          <span className="dash-badge">read-only</span>
        </div>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
          {profile.groups.map((g) => (
            <span
              key={g}
              className="font-mono"
              style={{ fontSize: 11, border: '1px solid var(--border)', borderRadius: 999, padding: '2px 10px' }}
            >
              {g}
            </span>
          ))}
        </div>
        <div className="modal-actions" style={{ marginTop: '1rem' }}>
          <Link className="sg-btn sg-btn--outline" href="/app/admin/mcp-custom-scopes">
            Back
          </Link>
        </div>
      </section>
    );
  }

  return (
    <section className="dash-panel">
      <div className="dash-panel__head">
        <h2 className="dash-panel__title">{isNew ? 'New tool set' : `Tool set: ${form.slug}`}</h2>
        <div style={{ display: 'flex', gap: 8 }}>
          {!isNew && view && view.is_active && (
            <button type="button" className="sg-btn sg-btn--danger sg-btn--sm" onClick={doDeactivate}>
              Deactivate
            </button>
          )}
          {!isNew && view && !view.is_active && (
            <button type="button" className="sg-btn sg-btn--outline sg-btn--sm" onClick={doReactivate}>
              Re-activate
            </button>
          )}
          {!isNew && (
            <button type="button" className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => doClone(slug)}>
              Clone
            </button>
          )}
          <button
            type="button"
            className="sg-btn sg-btn--outline sg-btn--sm"
            disabled={validating}
            onClick={doValidate}
          >
            {validating ? 'Validating...' : 'Validate'}
          </button>
        </div>
      </div>

      {loading ? (
        <p className="sg-page-intro">Loading…</p>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          {view && !view.is_active && (
            <p className="sg-field__hint">This tool set is deactivated — it is hidden from the serving path.</p>
          )}
          {view && view.effective && (
            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
              <span className="dash-badge">{view.effective.tools.length} tools served</span>
              {view.effective.version && (
                <span className="dash-badge" title="live catalog version">
                  v {view.effective.version}
                </span>
              )}
              {view.member_count !== null && <span className="dash-badge">{view.member_count} members</span>}
            </div>
          )}

          {validation && <ValidationPanel result={validation} />}

          {view && view.effective && view.effective.tools.length > 0 && (
            <EffectivePreview effective={view.effective} />
          )}

          <div style={{ display: 'flex', gap: '1rem', flexWrap: 'wrap' }}>
            <div className="sg-field" style={{ flex: '1 1 220px' }}>
              <label htmlFor="ts-slug">Slug</label>
              <input
                id="ts-slug"
                value={form.slug}
                placeholder="auto from name"
                disabled={!isNew}
                onChange={(e) => patch({ slug: e.target.value })}
                style={{ fontFamily: 'monospace' }}
              />
              {!isNew && <span className="sg-field__hint">Slug is immutable after creation.</span>}
            </div>
            <div className="sg-field" style={{ flex: '1 1 220px' }}>
              <label htmlFor="ts-name">Display name</label>
              <input
                id="ts-name"
                value={form.display_name}
                onChange={(e) => patch({ display_name: e.target.value })}
              />
            </div>
          </div>

          <div className="sg-field">
            <label htmlFor="ts-desc">Description</label>
            <textarea id="ts-desc" rows={2} value={form.description} onChange={(e) => patch({ description: e.target.value })} />
          </div>

          <div className="sg-field">
            <label>Audience shape</label>
            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', alignItems: 'center' }}>
              {(['org', 'project', 'group'] as ToolSetShape[]).map((s) => (
                <label key={s} style={{ display: 'flex', alignItems: 'center', gap: 4, textTransform: 'capitalize' }}>
                  <input
                    type="radio"
                    name="ts-shape"
                    checked={form.shape === s}
                    disabled={!isNew}
                    onChange={() => patch({ shape: s })}
                  />
                  {s}
                </label>
              ))}
            </div>
            {!isNew && <span className="sg-field__hint">Audience shape is fixed at creation (clone to change it).</span>}
            {isNew && form.shape === 'project' && (
              <div style={{ marginTop: 6 }}>
                <label htmlFor="ts-project">Project</label>
                <select id="ts-project" value={form.project_id} onChange={(e) => patch({ project_id: e.target.value })}>
                  <option value="">— select project —</option>
                  {projects.map((p) => (
                    <option key={p.id} value={p.id}>
                      {(p as { name?: string; slug?: string }).name ?? (p as { slug?: string }).slug ?? p.id}
                    </option>
                  ))}
                </select>
              </div>
            )}
            {isNew && form.shape === 'group' && (
              <div style={{ marginTop: 6 }}>
                <label htmlFor="ts-group">Group</label>
                <select id="ts-group" value={form.group_id} onChange={(e) => patch({ group_id: e.target.value })}>
                  <option value="">— select group —</option>
                  {groupOptions
                    .slice()
                    .sort((a, b) => (a.kind === b.kind ? a.name.localeCompare(b.name) : a.kind === 'ladder_role' ? -1 : 1))
                    .map((g) => (
                      <option key={g.id} value={g.id}>
                        {g.kind === 'ladder_role' ? `Role: ${g.name}` : `Group: ${g.display_name || g.name}`}
                        {g.member_count > 0 ? ` (${g.member_count} members)` : ''}
                      </option>
                    ))}
                </select>
                <span className="sg-field__hint">
                  Ladder roles are the built-in org roles; custom groups are real authz groups —
                  members carrying the role/group in this org get access. Member counts exclude
                  expired memberships.
                </span>
              </div>
            )}
          </div>

          <section style={{ border: '1px solid var(--border, #e5e5e5)', borderRadius: 8, padding: '0.875rem' }}>
            <h3 style={{ margin: '0 0 0.5rem', fontSize: 13, fontWeight: 700 }}>Settings</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
              <label style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 12 }}>
                <input
                  type="checkbox"
                  checked={form.settings.allow_api_keys !== false}
                  onChange={(e) => patch({ settings: { ...form.settings, allow_api_keys: e.target.checked } })}
                />
                Allow API-key callers
              </label>
              <div className="sg-field">
                <label htmlFor="ts-verbosity">Description verbosity</label>
                <select
                  id="ts-verbosity"
                  value={form.settings.description_verbosity ?? 'full'}
                  onChange={(e) =>
                    patch({ settings: { ...form.settings, description_verbosity: e.target.value as DescriptionVerbosity } })
                  }
                >
                  <option value="full">full</option>
                  <option value="concise">concise</option>
                  <option value="minimal">minimal</option>
                </select>
              </div>
              <div className="sg-field">
                <label htmlFor="ts-instructions">Instructions</label>
                <textarea
                  id="ts-instructions"
                  rows={3}
                  value={form.settings.instructions ?? ''}
                  placeholder="Extra instructions surfaced to callers of this set"
                  onChange={(e) => patch({ settings: { ...form.settings, instructions: e.target.value } })}
                />
              </div>
            </div>
          </section>

          <section>
            <h3 style={{ margin: '0 0 0.5rem', fontSize: 13, fontWeight: 700 }}>Groups &amp; tool overrides</h3>
            <span className="sg-field__hint">
              Include groups, then override tool names/descriptions, enable/disable tools, and tune arguments
              (enum pruning, hide, rename, default, description).
            </span>
            <ToolSetOverridesEditor
              groups={catalog.map((g) => ({ group: g.id, label: g.label, tools: g.tools }))}
              value={form.config}
              onChange={(next) => patch({ config: next })}
              argEnum={(tool, arg) => getArgEnum(orgId, tool, arg)}
            />
          </section>

          {view && (view.audit?.length ?? 0) > 0 && (
            <section style={{ border: '1px solid var(--border, #e5e5e5)', borderRadius: 8, padding: '0.875rem' }}>
              <h3 style={{ margin: '0 0 0.5rem', fontSize: 13, fontWeight: 700 }}>Audit trail</h3>
              <ul style={{ margin: 0, paddingLeft: '1.1rem', fontSize: 11, color: 'var(--text-2)' }}>
                {[...(view.audit ?? [])].reverse().map((entry, i) => (
                  <li key={`${entry.at}-${i}`}>
                    <span className="font-mono">{entry.at}</span> — {entry.action}
                    {entry.actor ? ` by ${entry.actor}` : ''}
                  </li>
                ))}
              </ul>
            </section>
          )}

          <div className="modal-actions">
            <Link className="sg-btn sg-btn--outline" href="/app/admin/mcp-custom-scopes">
              Cancel
            </Link>
            <button type="button" className="sg-btn sg-btn--black" disabled={saving} onClick={save}>
              {saving ? 'Saving...' : isNew ? 'Create Tool Set' : 'Save Tool Set'}
            </button>
          </div>
        </div>
      )}
    </section>
  );
}

// ---------------------------------------------------------------------------
// N4b — validate dry-run results (grouped by severity) + the D1-correct
// effective preview ("what will this set serve").
// ---------------------------------------------------------------------------

function ValidationPanel({ result }: { result: ToolSetValidateResult }) {
  if (result.ok) {
    return (
      <section
        aria-label="Validation result"
        style={{ border: '1px solid var(--border)', borderRadius: 8, padding: '0.875rem' }}
      >
        <h3 style={{ margin: '0 0 0.5rem', fontSize: 13, fontWeight: 700 }}>
          Validation: <span style={{ color: 'var(--accent)' }}>valid</span>
        </h3>
        {result.warnings.length === 0 ? (
          <p className="sg-field__hint" style={{ margin: 0 }}>
            No issues.
          </p>
        ) : (
          <ul style={{ margin: 0, paddingLeft: '1.1rem', fontSize: 11, color: 'var(--text-2)' }}>
            {result.warnings.map((w, i) => (
              <li key={i}>{w}</li>
            ))}
          </ul>
        )}
      </section>
    );
  }

  return (
    <section
      aria-label="Validation result"
      style={{ border: '1px solid var(--border)', borderRadius: 8, padding: '0.875rem' }}
    >
      <h3 style={{ margin: '0 0 0.5rem', fontSize: 13, fontWeight: 700, color: 'var(--danger, #b91c1c)' }}>
        Validation: {result.issues.length} issue(s)
      </h3>
      <IssueList issues={result.issues} />
    </section>
  );
}

function IssueList({ issues }: { issues: ToolSetIssue[] }) {
  return (
    <ul style={{ margin: 0, paddingLeft: '1.1rem', fontSize: 11 }}>
      {issues.map((issue, i) => (
        <li key={`${issue.code}-${issue.tool ?? ''}-${issue.field ?? ''}-${i}`}>
          <span className="font-mono">{issue.code}</span>
          {issue.tool ? (
            <>
              {' '}
              on <span className="font-mono">{issue.tool}</span>
            </>
          ) : null}
          {issue.field ? (
            <>
              .
              <span className="font-mono">{issue.field}</span>
            </>
          ) : null}
          {': '}
          {issue.message}
        </li>
      ))}
    </ul>
  );
}

function EffectivePreview({ effective }: { effective: ToolSetEffective }) {
  return (
    <section style={{ border: '1px solid var(--border)', borderRadius: 8, padding: '0.875rem' }}>
      <h3 style={{ margin: '0 0 0.5rem', fontSize: 13, fontWeight: 700 }}>Effective surface (live catalog)</h3>
      {effective.issues && effective.issues.length > 0 && (
        <div style={{ marginBottom: 8 }}>
          <IssueList issues={effective.issues} />
        </div>
      )}
      <div style={{ overflowX: 'auto' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 11 }}>
          <thead>
            <tr style={{ textAlign: 'left', color: 'var(--text-2)', borderBottom: '1px solid var(--border)' }}>
              <th style={{ padding: '4px 8px' }}>Serves as</th>
              <th style={{ padding: '4px 8px' }}>Base tool</th>
              <th style={{ padding: '4px 8px' }}>State</th>
              <th style={{ padding: '4px 8px' }}>Pruned args</th>
              <th style={{ padding: '4px 8px' }}>Provenance</th>
            </tr>
          </thead>
          <tbody>
            {effective.tools.map((tool) => (
              <tr key={tool.name} style={{ borderBottom: '1px solid var(--border)' }}>
                <td className="font-mono" style={{ padding: '4px 8px' }}>
                  {tool.name}
                  {tool.renamed && (
                    <span className="dash-badge" style={{ marginLeft: 6 }}>
                      renamed
                    </span>
                  )}
                </td>
                <td className="font-mono" style={{ padding: '4px 8px', color: 'var(--text-2)' }}>
                  {tool.base_name}
                </td>
                <td style={{ padding: '4px 8px' }}>
                  {tool.visible ? (
                    <span className="dash-badge">visible</span>
                  ) : (
                    <span className="dash-badge" style={{ opacity: 0.6 }}>
                      hidden
                    </span>
                  )}
                  {tool.callable ? (
                    <span className="dash-badge" style={{ marginLeft: 4 }}>
                      callable
                    </span>
                  ) : (
                    <span className="dash-badge" style={{ marginLeft: 4, opacity: 0.6 }}>
                      not callable
                    </span>
                  )}
                  {tool.reason ? (
                    <span title={String(tool.reason)} style={{ marginLeft: 4, color: 'var(--text-3)' }}>
                      ({String(tool.reason)})
                    </span>
                  ) : null}
                </td>
                <td style={{ padding: '4px 8px' }}>
                  {Object.keys(tool.pruned_args).length === 0
                    ? '—'
                    : Object.entries(tool.pruned_args).map(([arg, removed]) => (
                        <div key={arg}>
                          <span className="font-mono">{arg}</span>: −
                          {removed.map((v) => String(v)).join(', ')}
                        </div>
                      ))}
                </td>
                <td style={{ padding: '4px 8px', color: 'var(--text-3)' }}>
                  {tool.provenance.length === 0
                    ? '—'
                    : tool.provenance.map((row, i) => (
                        <div key={i} title={`${row.layer} @ weight ${row.weight}`}>
                          <span className="font-mono">{row.op}</span>
                          {row.field ? (
                            <>
                              .
                              <span className="font-mono">{row.field}</span>
                            </>
                          ) : null}
                          {' ← '}
                          {row.layer}
                        </div>
                      ))}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <p className="sg-field__hint" style={{ margin: '0.5rem 0 0' }}>
        Composed through the same serving pipeline a caller hits — visibility, renames, prunes and
        provenance are exactly what tools/list serves.
      </p>
    </section>
  );
}
