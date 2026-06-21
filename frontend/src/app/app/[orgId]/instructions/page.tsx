'use client';

import { useState, useEffect, useCallback } from 'react';
import { toast } from 'sonner';
import { PlusIcon } from '@heroicons/react/24/outline';
import {
  api,
  type Instruction,
  type InstructionParam,
  type InstructionVersionMeta,
  type Project,
} from '@/lib/api';
import { useOrg, useOrgId } from '@/context/org';

const BODY_TEMPLATE = `You are a helpful assistant.

Task: {{task}}

Respond concisely.`;

function timeAgo(dt?: string) {
  if (!dt) return '';
  const diff = Date.now() - new Date(dt).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return 'just now';
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  return `${Math.floor(hrs / 24)}d ago`;
}

// Params editor: one `name|description|required` per line. Only name is required.
function paramsToText(params?: InstructionParam[]): string {
  return (params ?? [])
    .map((p) => [p.name, p.description ?? '', p.required ? 'required' : ''].join('|'))
    .join('\n');
}

function parseParams(text: string): InstructionParam[] {
  return text
    .split('\n')
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const [name, description, required] = line.split('|').map((s) => s.trim());
      const param: InstructionParam = { name };
      if (description) param.description = description;
      if (required && /^(required|true|yes)$/i.test(required)) param.required = true;
      return param;
    })
    .filter((p) => p.name);
}

function InstructionModal({
  orgId,
  projects,
  defaultProjectId,
  instruction,
  onClose,
  onSaved,
}: {
  orgId: string;
  projects: Project[];
  defaultProjectId?: string;
  instruction?: Instruction | null;
  onClose: () => void;
  onSaved: () => void;
}) {
  const isEdit = !!instruction;
  const [slug, setSlug] = useState(instruction?.slug ?? '');
  const [title, setTitle] = useState(instruction?.title ?? '');
  const [description, setDescription] = useState(instruction?.description ?? '');
  const [tags, setTags] = useState((instruction?.tags ?? []).join(', '));
  const [body, setBody] = useState('');
  const [paramsText, setParamsText] = useState(paramsToText(instruction?.parameters));
  const [changeNote, setChangeNote] = useState('');
  const [projectId, setProjectId] = useState(instruction?.project_id ?? defaultProjectId ?? '');
  const [loadingBody, setLoadingBody] = useState(isEdit);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Track original body so we only send `body` (creating a new version) when changed.
  const [originalBody, setOriginalBody] = useState('');

  const loadBody = useCallback(async () => {
    if (!instruction) return;
    try {
      const data = await api.getInstruction(orgId, instruction.id);
      setBody(data.body ?? '');
      setOriginalBody(data.body ?? '');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load instruction body');
    } finally {
      setLoadingBody(false);
    }
  }, [orgId, instruction]);

  useEffect(() => {
    if (isEdit) loadBody();
    else setBody(BODY_TEMPLATE);
  }, [isEdit, loadBody]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!title.trim() || (!isEdit && !slug.trim()) || (!isEdit && !body.trim())) return;
    setSaving(true);
    setError(null);
    try {
      const base = {
        title: title.trim(),
        description: description.trim() || null,
        tags: tags.split(',').map((t) => t.trim()).filter(Boolean),
        parameters: parseParams(paramsText),
        project_id: projectId || null,
      };
      if (isEdit && instruction) {
        const bodyChanged = body !== originalBody;
        await api.updateInstruction(orgId, instruction.id, {
          ...base,
          ...(bodyChanged ? { body, change_note: changeNote.trim() || undefined } : {}),
        });
      } else {
        await api.createInstruction(orgId, { ...base, slug: slug.trim(), body });
      }
      toast.success(isEdit ? 'Instruction updated' : 'Instruction created');
      onSaved();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Request failed');
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-card modal-card--lg" onClick={(e) => e.stopPropagation()}>
        <h2 className="modal-title">{isEdit ? 'Edit Instruction' : 'New Instruction'}</h2>
        <form onSubmit={handleSubmit}>
          <div className="sg-field">
            <label htmlFor="i-slug">Slug</label>
            <input id="i-slug" value={slug} onChange={(e) => setSlug(e.target.value)} placeholder="code-review-prompt" disabled={isEdit} />
          </div>
          <div className="sg-field">
            <label htmlFor="i-title">Title</label>
            <input id="i-title" value={title} onChange={(e) => setTitle(e.target.value)} placeholder="Code Review Prompt" autoFocus />
          </div>
          <div className="sg-field">
            <label htmlFor="i-description">Description</label>
            <textarea id="i-description" value={description} onChange={(e) => setDescription(e.target.value)} rows={2} />
          </div>
          <div className="sg-field">
            <label htmlFor="i-body">Body (prompt with {'{{param}}'} placeholders)</label>
            <textarea
              id="i-body"
              value={body}
              onChange={(e) => setBody(e.target.value)}
              rows={12}
              className="font-mono"
              disabled={loadingBody}
            />
            {loadingBody && <span className="sg-field__hint">Loading current version…</span>}
          </div>
          <div className="sg-field">
            <label htmlFor="i-params">Parameters</label>
            <textarea
              id="i-params"
              value={paramsText}
              onChange={(e) => setParamsText(e.target.value)}
              rows={4}
              className="font-mono"
              placeholder="name|description|required"
            />
            <span className="sg-field__hint">One per line: name|description|required (only name is required).</span>
          </div>
          {isEdit && (
            <div className="sg-field">
              <label htmlFor="i-change-note">Change note</label>
              <input id="i-change-note" value={changeNote} onChange={(e) => setChangeNote(e.target.value)} placeholder="Only used if the body changed" />
              <span className="sg-field__hint">Editing the body creates a new active version.</span>
            </div>
          )}
          <div className="sg-field">
            <label htmlFor="i-tags">Tags</label>
            <input id="i-tags" value={tags} onChange={(e) => setTags(e.target.value)} placeholder="comma, separated" />
          </div>
          <div className="sg-field">
            <label htmlFor="i-project">Project</label>
            <select id="i-project" value={projectId} onChange={(e) => setProjectId(e.target.value)}>
              <option value="">No project</option>
              {projects.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.name}
                </option>
              ))}
            </select>
            <span className="sg-field__hint">Optional — scope this instruction to a project.</span>
          </div>
          {error && <div className="sg-error">{error}</div>}
          <div className="modal-actions">
            <button type="button" className="sg-btn sg-btn--outline" onClick={onClose}>
              Cancel
            </button>
            <button
              type="submit"
              className="sg-btn sg-btn--black"
              disabled={saving || loadingBody || !title.trim() || (!isEdit && (!slug.trim() || !body.trim()))}
            >
              {saving ? 'Saving…' : isEdit ? 'Save' : 'Create'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

function RenderModal({ orgId, instruction, onClose }: { orgId: string; instruction: Instruction; onClose: () => void }) {
  const [params, setParams] = useState<Record<string, string>>({});
  const [versions, setVersions] = useState<InstructionVersionMeta[]>([]);
  const [rendered, setRendered] = useState<string | null>(null);
  const [rendering, setRendering] = useState(false);
  const [loading, setLoading] = useState(true);

  const declared = instruction.parameters ?? [];

  const load = useCallback(async () => {
    try {
      const { versions } = await api.listInstructionVersions(orgId, instruction.id);
      setVersions(versions ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load versions');
    } finally {
      setLoading(false);
    }
  }, [orgId, instruction.id]);

  useEffect(() => {
    load();
  }, [load]);

  async function render() {
    setRendering(true);
    try {
      const { rendered } = await api.renderInstruction(orgId, instruction.id, params);
      setRendered(rendered.body);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Render failed');
    } finally {
      setRendering(false);
    }
  }

  async function makeActive(version: number) {
    try {
      await api.setInstructionActiveVersion(orgId, instruction.id, version);
      toast.success(`Version ${version} is now active`);
      await load();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to set active version');
    }
  }

  async function copyRendered() {
    if (!rendered) return;
    try {
      await navigator.clipboard.writeText(rendered);
      toast.success('Copied to clipboard');
    } catch {
      toast.error('Copy failed');
    }
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-card modal-card--lg" onClick={(e) => e.stopPropagation()}>
        <h2 className="modal-title">Render — {instruction.title}</h2>
        <h3 className="sg-page-title" style={{ fontSize: '1.1rem' }}>Parameters</h3>
        {declared.length === 0 ? (
          <p className="sg-page-intro">This instruction declares no parameters.</p>
        ) : (
          declared.map((p) => (
            <div key={p.name} className="sg-field">
              <label htmlFor={`r-${p.name}`}>
                {p.name}
                {p.required ? ' *' : ''}
              </label>
              <input
                id={`r-${p.name}`}
                value={params[p.name] ?? p.default ?? ''}
                onChange={(e) => setParams((prev) => ({ ...prev, [p.name]: e.target.value }))}
                placeholder={p.description ?? ''}
              />
              {p.description && <span className="sg-field__hint">{p.description}</span>}
            </div>
          ))
        )}
        <div className="modal-actions" style={{ justifyContent: 'flex-start', marginTop: 0 }}>
          <button className="sg-btn sg-btn--primary sg-btn--sm" onClick={render} disabled={rendering}>
            {rendering ? 'Rendering…' : 'Render'}
          </button>
        </div>

        {rendered !== null && (
          <>
            <div className="asset-outputs__main" style={{ marginTop: '1rem' }}>
              <strong>Rendered output</strong>
              <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={copyRendered}>
                Copy
              </button>
            </div>
            <pre className="asset-outputs__content">{rendered}</pre>
          </>
        )}

        <h3 className="sg-page-title" style={{ fontSize: '1.1rem', marginTop: '1.5rem' }}>Versions</h3>
        {loading ? (
          <p className="sg-page-intro">Loading…</p>
        ) : versions.length === 0 ? (
          <p className="sg-page-intro">No versions.</p>
        ) : (
          <ul className="asset-outputs">
            {versions.map((v) => (
              <li key={v.version} className="asset-outputs__row">
                <div className="asset-outputs__main">
                  <span className="asset-outputs__variant">v{v.version}</span>
                  <span className={`project-card__status${v.active ? ' project-card__status--active' : ''}`}>
                    {v.active ? 'active' : 'inactive'}
                  </span>
                  {v.change_note && <span className="sg-field__hint">{v.change_note}</span>}
                  <span className="project-card__time">{timeAgo(v.inserted_at)}</span>
                </div>
                <div className="asset-outputs__actions">
                  {!v.active && (
                    <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => makeActive(v.version)}>
                      Make active
                    </button>
                  )}
                </div>
              </li>
            ))}
          </ul>
        )}

        <div className="modal-actions">
          <button type="button" className="sg-btn sg-btn--outline" onClick={onClose}>
            Close
          </button>
        </div>
      </div>
    </div>
  );
}

type ModalState =
  | { kind: 'create' }
  | { kind: 'edit'; instruction: Instruction }
  | { kind: 'render'; instruction: Instruction }
  | null;

export default function InstructionsPage() {
  const { orgId, loading: orgLoading } = useOrgId();
  const { currentProject, switchProject } = useOrg();
  const [instructions, setInstructions] = useState<Instruction[]>([]);
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState<ModalState>(null);

  const scopeProjectId = currentProject?.id;

  const fetchData = useCallback(async () => {
    if (!orgId) return;
    try {
      const [instructionData, projectData] = await Promise.all([
        api.listInstructions(orgId, scopeProjectId ? { projectId: scopeProjectId } : undefined),
        api.listProjects(orgId),
      ]);
      setInstructions(instructionData.instructions ?? []);
      setProjects(projectData.projects ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load instructions');
    } finally {
      setLoading(false);
    }
  }, [orgId, scopeProjectId]);

  useEffect(() => {
    if (orgId) fetchData();
    else if (!orgLoading) setLoading(false);
  }, [fetchData, orgId, orgLoading]);

  async function handleDelete(instruction: Instruction) {
    if (!orgId) return;
    if (!confirm(`Delete instruction "${instruction.title}"?`)) return;
    try {
      await api.deleteInstruction(orgId, instruction.id);
      toast.success('Instruction deleted');
      fetchData();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to delete');
    }
  }

  const projectName = (id?: string | null) => (id ? projects.find((p) => p.id === id)?.name ?? '—' : null);

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">Instructions</h1>
          {currentProject && (
            <span className="scope-chip">
              Project: <strong>{currentProject.name}</strong>
              <button type="button" className="scope-chip__clear" onClick={() => switchProject(null)} title="Show all projects">
                ×
              </button>
            </span>
          )}
        </div>
        <p className="sg-page-intro">Instructions — versioned, parameterized prompt templates.</p>

        {loading ? (
          <p className="sg-page-intro">Loading…</p>
        ) : instructions.length === 0 ? (
          <div className="projects-empty">
            <p className="projects-empty__text">No instructions yet. Create one to get started.</p>
            <button className="sg-btn sg-btn--black" onClick={() => setModal({ kind: 'create' })}>
              New Instruction
            </button>
          </div>
        ) : (
          <div className="projects-grid">
            {instructions.map((i) => (
              <div key={i.id} className="project-card">
                <div className="project-card__header">
                  {projectName(i.project_id) && <div className="project-card__org">{projectName(i.project_id)}</div>}
                  <div className="project-card__name">{i.title}</div>
                </div>
                <div className="project-card__body">
                  <dl className="project-card__fields">
                    <div className="project-card__field">
                      <dt>Slug:</dt>
                      <dd className="font-mono">{i.slug}</dd>
                    </div>
                    {i.description && (
                      <div className="project-card__field">
                        <dt>Desc:</dt>
                        <dd>{i.description}</dd>
                      </div>
                    )}
                    <div className="project-card__field">
                      <dt>Version:</dt>
                      <dd>v{i.active_version ?? 1}</dd>
                    </div>
                    <div className="project-card__field">
                      <dt>Params:</dt>
                      <dd>{(i.parameters ?? []).length}</dd>
                    </div>
                  </dl>
                  <div className="project-card__meta">
                    <span className="project-card__status">{i.status}</span>
                    <span className="project-card__time">{timeAgo(i.inserted_at)}</span>
                  </div>
                  <div className="project-card__actions">
                    <button className="sg-btn sg-btn--primary sg-btn--sm" onClick={() => setModal({ kind: 'render', instruction: i })}>
                      Render
                    </button>
                    <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => setModal({ kind: 'edit', instruction: i })}>
                      Edit
                    </button>
                    <button className="sg-btn sg-btn--danger sg-btn--sm" onClick={() => handleDelete(i)}>
                      Delete
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>

      {modal?.kind === 'render' && orgId && (
        <RenderModal orgId={orgId} instruction={modal.instruction} onClose={() => setModal(null)} />
      )}
      {(modal?.kind === 'create' || modal?.kind === 'edit') && orgId && (
        <InstructionModal
          orgId={orgId}
          projects={projects}
          defaultProjectId={scopeProjectId}
          instruction={modal.kind === 'edit' ? modal.instruction : null}
          onClose={() => setModal(null)}
          onSaved={() => {
            setModal(null);
            fetchData();
          }}
        />
      )}

      {!loading && instructions.length > 0 && (
        <button className="fab" onClick={() => setModal({ kind: 'create' })} aria-label="New instruction" title="New instruction">
          <PlusIcon />
        </button>
      )}
    </div>
  );
}
