'use client';

import { useState, useEffect, useCallback, useMemo } from 'react';
import { toast } from 'sonner';
import { PlusIcon } from '@heroicons/react/24/outline';
import { api, type FieldDefinition, FIELD_TYPES, type FieldType } from '@/lib/api';
import { useOrg, useOrgId } from '@/context/org';

const OPTION_TYPES: FieldType[] = ['select', 'radio', 'multi_select'];
const RANK = { project: 3, org: 2, global: 1 } as const;

function FieldModal({
  orgId,
  scope,
  projectId,
  field,
  prefill,
  onClose,
  onSaved,
}: {
  orgId: string;
  scope: 'org' | 'project';
  projectId?: string;
  field?: FieldDefinition | null; // editing an own-scope row
  prefill?: FieldDefinition | null; // overriding an inherited row
  onClose: () => void;
  onSaved: () => void;
}) {
  const isEdit = !!field;
  const base = field ?? prefill ?? null;
  const [slug, setSlug] = useState(base?.slug ?? '');
  const [label, setLabel] = useState(base?.label ?? '');
  const [fieldType, setFieldType] = useState<FieldType>((base?.field_type as FieldType) ?? 'text');
  const [defaultValue, setDefaultValue] = useState(base?.default_value ?? '');
  const [description, setDescription] = useState(base?.description ?? '');
  const [optionsText, setOptionsText] = useState(
    base?.options ? JSON.stringify(base.options, null, 2) : '{\n  "values": [\n    { "value": "", "label": "" }\n  ]\n}',
  );
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const needsOptions = OPTION_TYPES.includes(fieldType);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!label.trim() || (!isEdit && !slug.trim())) return;

    let options: Record<string, unknown> | null = null;
    if (needsOptions) {
      try {
        options = JSON.parse(optionsText);
      } catch {
        setError('Options must be valid JSON');
        return;
      }
    }

    setSaving(true);
    setError(null);
    try {
      const payload = {
        label: label.trim(),
        default_value: defaultValue.trim() || null,
        description: description.trim() || null,
        options,
      };
      if (isEdit && field) {
        await api.updateFieldDefinition(orgId, field.id, payload);
      } else {
        await api.createFieldDefinition(orgId, {
          ...payload,
          slug: slug.trim(),
          field_type: fieldType,
          scope,
          project_id: scope === 'project' ? projectId : null,
        });
      }
      toast.success(isEdit ? 'Field updated' : 'Field saved');
      onSaved();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Request failed');
    } finally {
      setSaving(false);
    }
  }

  const title = isEdit ? 'Edit Field' : prefill ? `Override “${prefill.slug}” at ${scope} scope` : `New Field (${scope})`;

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-card" onClick={(e) => e.stopPropagation()}>
        <h2 className="modal-title">{title}</h2>
        <form onSubmit={handleSubmit}>
          <div className="sg-field">
            <label htmlFor="fd-slug">Slug</label>
            <input id="fd-slug" value={slug} onChange={(e) => setSlug(e.target.value)} placeholder="story_points" disabled={isEdit || !!prefill} />
          </div>
          <div className="sg-field">
            <label htmlFor="fd-label">Label</label>
            <input id="fd-label" value={label} onChange={(e) => setLabel(e.target.value)} placeholder="Story Points" autoFocus />
          </div>
          <div className="sg-field">
            <label htmlFor="fd-type">Field type</label>
            <select id="fd-type" value={fieldType} onChange={(e) => setFieldType(e.target.value as FieldType)} disabled={isEdit}>
              {FIELD_TYPES.map((t) => (
                <option key={t} value={t}>
                  {t}
                </option>
              ))}
            </select>
          </div>
          {needsOptions && (
            <div className="sg-field">
              <label htmlFor="fd-options">Options (JSON)</label>
              <textarea id="fd-options" value={optionsText} onChange={(e) => setOptionsText(e.target.value)} rows={6} className="font-mono" />
            </div>
          )}
          <div className="sg-field">
            <label htmlFor="fd-default">Default value</label>
            <input id="fd-default" value={defaultValue} onChange={(e) => setDefaultValue(e.target.value)} placeholder="optional" />
          </div>
          <div className="sg-field">
            <label htmlFor="fd-desc">Description</label>
            <textarea id="fd-desc" value={description} onChange={(e) => setDescription(e.target.value)} placeholder="Help text" />
          </div>
          {error && <div className="sg-error">{error}</div>}
          <div className="modal-actions">
            <button type="button" className="sg-btn sg-btn--outline" onClick={onClose}>
              Cancel
            </button>
            <button type="submit" className="sg-btn sg-btn--black" disabled={saving || !label.trim() || (!isEdit && !slug.trim())}>
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
  effective: FieldDefinition | null; // highest-precedence non-disabled
  ownRow: FieldDefinition | null; // row at the current scope, if any
  sourceScope: FieldDefinition['scope'] | 'none';
}

type ModalState =
  | { kind: 'create' }
  | { kind: 'edit'; field: FieldDefinition }
  | { kind: 'override'; field: FieldDefinition }
  | null;

export default function TicketFieldsPage() {
  const { orgId, loading: orgLoading } = useOrgId();
  const { currentProject, switchProject } = useOrg();
  const [fields, setFields] = useState<FieldDefinition[]>([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState<ModalState>(null);

  const scope: 'org' | 'project' = currentProject ? 'project' : 'org';
  const projectId = currentProject?.id;

  const fetchData = useCallback(async () => {
    if (!orgId) return;
    try {
      const data = await api.listFieldDefinitions(orgId, projectId ? { projectId } : undefined);
      setFields(data.field_definitions ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load fields');
    } finally {
      setLoading(false);
    }
  }, [orgId, projectId]);

  useEffect(() => {
    if (orgId) fetchData();
    else if (!orgLoading) setLoading(false);
  }, [fetchData, orgId, orgLoading]);

  // Collapse rows by slug into the effective view + current-scope override.
  const groups = useMemo<SlugGroup[]>(() => {
    const bySlug = new Map<string, FieldDefinition[]>();
    for (const f of fields) {
      const arr = bySlug.get(f.slug) ?? [];
      arr.push(f);
      bySlug.set(f.slug, arr);
    }
    const isOwn = (f: FieldDefinition) =>
      scope === 'project' ? f.scope === 'project' && f.project_id === projectId : f.scope === 'org';

    return [...bySlug.entries()]
      .map(([slug, rows]) => {
        const sorted = [...rows].sort((a, b) => RANK[b.scope] - RANK[a.scope]);
        const top = sorted[0];
        const effective = top && !top.disabled ? top : null;
        const ownRow = rows.find(isOwn) ?? null;
        return { slug, effective, ownRow, sourceScope: effective ? effective.scope : ('none' as const) };
      })
      .sort((a, b) => a.slug.localeCompare(b.slug));
  }, [fields, scope, projectId]);

  async function disableHere(g: SlugGroup) {
    if (!orgId || !g.effective) return;
    try {
      await api.createFieldDefinition(orgId, {
        slug: g.slug,
        label: g.effective.label,
        field_type: g.effective.field_type,
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

  async function toggleOwnDisabled(row: FieldDefinition) {
    if (!orgId) return;
    try {
      await api.updateFieldDefinition(orgId, row.id, { disabled: !row.disabled });
      fetchData();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to update');
    }
  }

  async function removeOwn(row: FieldDefinition) {
    if (!orgId) return;
    if (!confirm(`Remove the ${row.scope}-scoped “${row.slug}”?`)) return;
    try {
      await api.deleteFieldDefinition(orgId, row.id);
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
          <h1 className="sg-page-title">Ticket Fields</h1>
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
          Field definitions resolved for this {scope} scope (global → org{currentProject ? ' → project' : ''}). Override or disable
          inherited fields, and add new ones at the {scope} scope.
        </p>

        {loading ? (
          <p className="sg-page-intro">Loading…</p>
        ) : groups.length === 0 ? (
          <div className="projects-empty">
            <p className="projects-empty__text">No fields visible. Create one at the {scope} scope.</p>
            <button className="sg-btn sg-btn--black" onClick={() => setModal({ kind: 'create' })}>
              New Field
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
                    <div className="project-card__org">
                      {eff ? `${eff.scope} · ${eff.field_type}` : 'disabled here'}
                    </div>
                    <div className="project-card__name">{eff?.label ?? g.slug}</div>
                  </div>
                  <div className="project-card__body">
                    <dl className="project-card__fields">
                      <div className="project-card__field">
                        <dt>Slug:</dt>
                        <dd className="font-mono">{g.slug}</dd>
                      </div>
                      {eff?.description && (
                        <div className="project-card__field">
                          <dt>Help:</dt>
                          <dd>{eff.description}</dd>
                        </div>
                      )}
                    </dl>
                    <div className="project-card__actions">
                      {ownAtScope ? (
                        <>
                          {!disabledHere && (
                            <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => setModal({ kind: 'edit', field: g.ownRow! })}>
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
                          <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => setModal({ kind: 'override', field: eff! })} disabled={!eff}>
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
        <FieldModal
          orgId={orgId}
          scope={scope}
          projectId={projectId}
          field={modal.kind === 'edit' ? modal.field : null}
          prefill={modal.kind === 'override' ? modal.field : null}
          onClose={() => setModal(null)}
          onSaved={() => {
            setModal(null);
            fetchData();
          }}
        />
      )}

      {!loading && groups.length > 0 && (
        <button className="fab" onClick={() => setModal({ kind: 'create' })} aria-label="New field" title="New field">
          <PlusIcon />
        </button>
      )}
    </div>
  );
}
