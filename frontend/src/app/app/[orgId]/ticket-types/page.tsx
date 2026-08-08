'use client';

import { useState, useEffect, useCallback, useMemo } from 'react';
import { toast } from 'sonner';
import { PlusIcon } from '@heroicons/react/24/outline';
import { api, type TypeDefinition, type FieldDefinition } from '@/lib/api';
import { useOrg, useOrgId } from '@/context/org';

const RANK = { project: 3, org: 2, global: 1 } as const;

interface FieldRow {
  id: string;
  slug: string;
  label: string;
  checked: boolean;
  required: boolean;
}

function TypeModal({
  orgId,
  scope,
  projectId,
  type,
  prefill,
  available,
  onClose,
  onSaved,
}: {
  orgId: string;
  scope: 'org' | 'project';
  projectId?: string;
  type?: TypeDefinition | null;
  prefill?: TypeDefinition | null;
  available: FieldDefinition[];
  onClose: () => void;
  onSaved: () => void;
}) {
  const isEdit = !!type;
  const base = type ?? prefill ?? null;
  const [slug, setSlug] = useState(base?.slug ?? '');
  const [name, setName] = useState(base?.name ?? '');
  const [description, setDescription] = useState(base?.description ?? '');
  const [icon, setIcon] = useState(base?.icon ?? '');
  const [workflowText, setWorkflowText] = useState(base?.status_workflow ? JSON.stringify(base.status_workflow, null, 2) : '');
  const assigned = new Map((base?.fields ?? []).map((f) => [f.id, f.required]));
  const [rows, setRows] = useState<FieldRow[]>(
    available.map((f) => ({ id: f.id, slug: f.slug, label: f.label, checked: assigned.has(f.id), required: assigned.get(f.id) ?? false })),
  );
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  function toggle(id: string, patch: Partial<FieldRow>) {
    setRows((rs) => rs.map((r) => (r.id === id ? { ...r, ...patch } : r)));
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim() || (!isEdit && !slug.trim())) return;

    let status_workflow: Record<string, unknown> | null = null;
    if (workflowText.trim()) {
      try {
        status_workflow = JSON.parse(workflowText);
      } catch {
        setError('Status workflow must be valid JSON');
        return;
      }
    }

    const fields = rows.filter((r) => r.checked).map((r) => ({ id: r.id, required: r.required }));

    setSaving(true);
    setError(null);
    try {
      const payload = { name: name.trim(), description: description.trim() || null, icon: icon.trim() || null, status_workflow, fields };
      if (isEdit && type) {
        await api.updateTypeDefinition(orgId, type.id, payload);
      } else {
        await api.createTypeDefinition(orgId, { ...payload, slug: slug.trim(), scope, project_id: scope === 'project' ? projectId : null });
      }
      toast.success(isEdit ? 'Type updated' : 'Type saved');
      onSaved();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Request failed');
    } finally {
      setSaving(false);
    }
  }

  const title = isEdit ? 'Edit Ticket Type' : prefill ? `Override “${prefill.slug}” at ${scope} scope` : `New Ticket Type (${scope})`;

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-card" onClick={(e) => e.stopPropagation()}>
        <h2 className="modal-title">{title}</h2>
        <form onSubmit={handleSubmit}>
          <div className="sg-field">
            <label htmlFor="td-slug">Slug</label>
            <input id="td-slug" value={slug} onChange={(e) => setSlug(e.target.value)} placeholder="bug" disabled={isEdit || !!prefill} />
          </div>
          <div className="sg-field">
            <label htmlFor="td-name">Name</label>
            <input id="td-name" value={name} onChange={(e) => setName(e.target.value)} placeholder="Bug" autoFocus />
          </div>
          <div className="sg-field">
            <label htmlFor="td-icon">Icon</label>
            <input id="td-icon" value={icon} onChange={(e) => setIcon(e.target.value)} placeholder="🐛 (optional)" />
          </div>
          <div className="sg-field">
            <label htmlFor="td-desc">Description</label>
            <textarea id="td-desc" value={description} onChange={(e) => setDescription(e.target.value)} placeholder="Optional" />
          </div>

          <div className="sg-field">
            <label>Fields</label>
            {available.length === 0 ? (
              <span className="sg-field__hint">No fields available — create some on the Ticket Fields page.</span>
            ) : (
              <div className="td-fields">
                {rows.map((r) => (
                  <div key={r.id} className="td-fields__row">
                    <label className="td-fields__check">
                      <input type="checkbox" checked={r.checked} onChange={(e) => toggle(r.id, { checked: e.target.checked })} />
                      <span>
                        {r.label} <span className="font-mono sg-field__hint">{r.slug}</span>
                      </span>
                    </label>
                    {r.checked && (
                      <label className="td-fields__req">
                        <input type="checkbox" checked={r.required} onChange={(e) => toggle(r.id, { required: e.target.checked })} />
                        required
                      </label>
                    )}
                  </div>
                ))}
              </div>
            )}
          </div>

          <div className="sg-field">
            <label htmlFor="td-workflow">Status workflow (JSON)</label>
            <textarea
              id="td-workflow"
              value={workflowText}
              onChange={(e) => setWorkflowText(e.target.value)}
              rows={5}
              className="font-mono"
              placeholder={'{ "statuses": ["open","done"], "transitions": { "open": ["done"] } }'}
            />
          </div>

          {error && <div className="sg-error">{error}</div>}
          <div className="modal-actions">
            <button type="button" className="sg-btn sg-btn--outline" onClick={onClose}>
              Cancel
            </button>
            <button type="submit" className="sg-btn sg-btn--black" disabled={saving || !name.trim() || (!isEdit && !slug.trim())}>
              {saving ? 'Saving…' : isEdit ? 'Save' : 'Create'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

interface SlugGroup {
  slug: string;
  effective: TypeDefinition | null;
  ownRow: TypeDefinition | null;
}

type ModalState =
  | { kind: 'create' }
  | { kind: 'edit'; type: TypeDefinition }
  | { kind: 'override'; type: TypeDefinition }
  | null;

export default function TicketTypesPage() {
  const { orgId, loading: orgLoading } = useOrgId();
  const { currentProject, switchProject } = useOrg();
  const [types, setTypes] = useState<TypeDefinition[]>([]);
  const [fields, setFields] = useState<FieldDefinition[]>([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState<ModalState>(null);

  const scope: 'org' | 'project' = currentProject ? 'project' : 'org';
  const projectId = currentProject?.id;

  const fetchData = useCallback(async () => {
    if (!orgId) return;
    try {
      const opts = projectId ? { projectId } : undefined;
      const [typeData, fieldData] = await Promise.all([api.listTypeDefinitions(orgId, opts), api.listFieldDefinitions(orgId, opts)]);
      setTypes(typeData.type_definitions ?? []);
      setFields(fieldData.field_definitions ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load ticket types');
    } finally {
      setLoading(false);
    }
  }, [orgId, projectId]);

  useEffect(() => {
    if (orgId) fetchData();
    else if (!orgLoading) setLoading(false);
  }, [fetchData, orgId, orgLoading]);

  // Effective fields available for assignment (resolved, non-disabled).
  const availableFields = useMemo<FieldDefinition[]>(() => {
    const bySlug = new Map<string, FieldDefinition[]>();
    for (const f of fields) {
      const arr = bySlug.get(f.slug) ?? [];
      arr.push(f);
      bySlug.set(f.slug, arr);
    }
    return [...bySlug.values()]
      .map((rows) => [...rows].sort((a, b) => RANK[b.scope] - RANK[a.scope])[0])
      .filter((f) => f && !f.disabled)
      .sort((a, b) => a.slug.localeCompare(b.slug));
  }, [fields]);

  const groups = useMemo<SlugGroup[]>(() => {
    const bySlug = new Map<string, TypeDefinition[]>();
    for (const t of types) {
      const arr = bySlug.get(t.slug) ?? [];
      arr.push(t);
      bySlug.set(t.slug, arr);
    }
    const isOwn = (t: TypeDefinition) =>
      scope === 'project' ? t.scope === 'project' && t.project_id === projectId : t.scope === 'org';

    return [...bySlug.entries()]
      .map(([slug, rows]) => {
        const sorted = [...rows].sort((a, b) => RANK[b.scope] - RANK[a.scope]);
        const top = sorted[0];
        return { slug, effective: top && !top.disabled ? top : null, ownRow: rows.find(isOwn) ?? null };
      })
      .sort((a, b) => a.slug.localeCompare(b.slug));
  }, [types, scope, projectId]);

  async function openEdit(t: TypeDefinition, kind: 'edit' | 'override') {
    if (!orgId) return;
    try {
      const { type_definition } = await api.getTypeDefinition(orgId, t.id);
      setModal(kind === 'edit' ? { kind: 'edit', type: type_definition } : { kind: 'override', type: type_definition });
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load type');
    }
  }

  async function disableHere(g: SlugGroup) {
    if (!orgId || !g.effective) return;
    try {
      await api.createTypeDefinition(orgId, {
        slug: g.slug,
        name: g.effective.name,
        disabled: true,
        scope,
        project_id: scope === 'project' ? projectId : null,
      });
      toast.success(`Disabled “${g.slug}” at ${scope} scope`);
      fetchData();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to disable');
    }
  }

  async function toggleOwnDisabled(row: TypeDefinition) {
    if (!orgId) return;
    try {
      await api.updateTypeDefinition(orgId, row.id, { disabled: !row.disabled });
      fetchData();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to update');
    }
  }

  async function removeOwn(row: TypeDefinition) {
    if (!orgId) return;
    if (!confirm(`Remove the ${row.scope}-scoped “${row.slug}”?`)) return;
    try {
      await api.deleteTypeDefinition(orgId, row.id);
      toast.success('Removed');
      fetchData();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to remove');
    }
  }

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">Ticket Types</h1>
          <span className="scope-chip">
            Scope: <strong>{currentProject ? `Project · ${currentProject.name}` : 'Organization'}</strong>
            {currentProject && (
              <button type="button" className="scope-chip__clear" onClick={() => switchProject(null)} title="Manage at org scope">
                ×
              </button>
            )}
          </span>
        </div>
        <p className="sg-page-intro">
          Ticket types resolved for this {scope} scope (global → org{currentProject ? ' → project' : ''}). Override or disable inherited
          types, and add new ones at the {scope} scope.
        </p>

        {loading ? (
          <p className="sg-page-intro">Loading…</p>
        ) : groups.length === 0 ? (
          <div className="projects-empty">
            <p className="projects-empty__text">No ticket types visible. Create one at the {scope} scope.</p>
            <button className="sg-btn sg-btn--black" onClick={() => setModal({ kind: 'create' })}>
              New Ticket Type
            </button>
          </div>
        ) : (
          <div className="projects-grid">
            {groups.map((g) => {
              const eff = g.effective;
              const disabledHere = g.ownRow?.disabled;
              const ownAtScope = g.ownRow && (scope === 'project' ? g.ownRow.scope === 'project' : g.ownRow.scope === 'org');
              return (
                <div key={g.slug} className="project-card">
                  <div className="project-card__header">
                    <div className="project-card__org">{eff ? `${eff.scope}${eff.icon ? ` · ${eff.icon}` : ''}` : 'disabled here'}</div>
                    <div className="project-card__name">{eff?.name ?? g.slug}</div>
                  </div>
                  <div className="project-card__body">
                    <dl className="project-card__fields">
                      <div className="project-card__field">
                        <dt>Slug:</dt>
                        <dd className="font-mono">{g.slug}</dd>
                      </div>
                      {eff?.description && (
                        <div className="project-card__field">
                          <dt>About:</dt>
                          <dd>{eff.description}</dd>
                        </div>
                      )}
                    </dl>
                    <div className="project-card__actions">
                      {ownAtScope ? (
                        <>
                          {!disabledHere && (
                            <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => openEdit(g.ownRow!, 'edit')}>
                              Edit
                            </button>
                          )}
                          <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => toggleOwnDisabled(g.ownRow!)}>
                            {disabledHere ? 'Enable' : 'Disable'}
                          </button>
                          <button className="sg-btn sg-btn--danger sg-btn--sm" onClick={() => removeOwn(g.ownRow!)}>
                            Remove
                          </button>
                        </>
                      ) : (
                        <>
                          <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => eff && openEdit(eff, 'override')} disabled={!eff}>
                            Override
                          </button>
                          <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => disableHere(g)} disabled={!eff}>
                            Disable here
                          </button>
                        </>
                      )}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </main>

      {modal && orgId && (
        <TypeModal
          orgId={orgId}
          scope={scope}
          projectId={projectId}
          type={modal.kind === 'edit' ? modal.type : null}
          prefill={modal.kind === 'override' ? modal.type : null}
          available={availableFields}
          onClose={() => setModal(null)}
          onSaved={() => {
            setModal(null);
            fetchData();
          }}
        />
      )}

      {!loading && groups.length > 0 && (
        <button className="fab" onClick={() => setModal({ kind: 'create' })} aria-label="New ticket type" title="New ticket type">
          <PlusIcon />
        </button>
      )}
    </div>
  );
}
