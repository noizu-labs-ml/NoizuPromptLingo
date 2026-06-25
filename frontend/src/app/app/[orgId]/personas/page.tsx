'use client';

import { useState, useEffect, useCallback } from 'react';
import { toast } from 'sonner';
import { PlusIcon } from '@heroicons/react/24/outline';
import {
  api,
  type Persona,
  type PersonaJournalEntry,
  type PersonaKnowledgeEntry,
  type Project,
} from '@/lib/api';
import { useOrg, useOrgId } from '@/context/org';
import { DataTable } from '@/components/console/DataTable';
import { personasDescriptor } from '@/lib/console/descriptors/personas';

const JOURNAL_CATEGORIES = ['work_log', 'reflection', 'decision', 'note'];

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

function PersonaModal({
  orgId,
  projects,
  defaultProjectId,
  persona,
  onClose,
  onSaved,
}: {
  orgId: string;
  projects: Project[];
  defaultProjectId?: string;
  persona?: Persona | null;
  onClose: () => void;
  onSaved: () => void;
}) {
  const isEdit = !!persona;
  const [slug, setSlug] = useState(persona?.slug ?? '');
  const [name, setName] = useState(persona?.name ?? '');
  const [role, setRole] = useState(persona?.role ?? '');
  const [bio, setBio] = useState(persona?.bio ?? '');
  const [avatar, setAvatar] = useState(persona?.avatar ?? '');
  const [tags, setTags] = useState((persona?.tags ?? []).join(', '));
  const [projectId, setProjectId] = useState(persona?.project_id ?? defaultProjectId ?? '');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim() || (!isEdit && !slug.trim())) return;
    setSaving(true);
    setError(null);
    try {
      const payload = {
        name: name.trim(),
        role: role.trim() || null,
        bio: bio.trim() || null,
        avatar: avatar.trim() || null,
        tags: tags.split(',').map((t) => t.trim()).filter(Boolean),
        project_id: projectId || null,
      };
      if (isEdit && persona) {
        await api.updatePersona(orgId, persona.id, payload);
      } else {
        await api.createPersona(orgId, { ...payload, slug: slug.trim() });
      }
      toast.success(isEdit ? 'Persona updated' : 'Persona created');
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
        <h2 className="modal-title">{isEdit ? 'Edit Persona' : 'New Persona'}</h2>
        <form onSubmit={handleSubmit}>
          <div className="sg-field">
            <label htmlFor="p-slug">Slug</label>
            <input id="p-slug" value={slug} onChange={(e) => setSlug(e.target.value)} placeholder="ada-the-architect" disabled={isEdit} />
          </div>
          <div className="sg-field">
            <label htmlFor="p-name">Name</label>
            <input id="p-name" value={name} onChange={(e) => setName(e.target.value)} placeholder="Ada" autoFocus />
          </div>
          <div className="sg-field">
            <label htmlFor="p-role">Role</label>
            <input id="p-role" value={role} onChange={(e) => setRole(e.target.value)} placeholder="Lead Architect" />
          </div>
          <div className="sg-field">
            <label htmlFor="p-bio">Bio</label>
            <textarea id="p-bio" value={bio} onChange={(e) => setBio(e.target.value)} rows={5} />
          </div>
          <div className="sg-field">
            <label htmlFor="p-avatar">Avatar URL</label>
            <input id="p-avatar" value={avatar} onChange={(e) => setAvatar(e.target.value)} placeholder="https://…" />
          </div>
          <div className="sg-field">
            <label htmlFor="p-tags">Tags</label>
            <input id="p-tags" value={tags} onChange={(e) => setTags(e.target.value)} placeholder="comma, separated" />
          </div>
          <div className="sg-field">
            <label htmlFor="p-project">Project</label>
            <select id="p-project" value={projectId} onChange={(e) => setProjectId(e.target.value)}>
              <option value="">No project</option>
              {projects.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.name}
                </option>
              ))}
            </select>
            <span className="sg-field__hint">Optional — scope this persona to a project.</span>
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

function DetailsModal({ orgId, persona, onClose }: { orgId: string; persona: Persona; onClose: () => void }) {
  const [journal, setJournal] = useState<PersonaJournalEntry[]>([]);
  const [knowledge, setKnowledge] = useState<PersonaKnowledgeEntry[]>([]);
  const [loading, setLoading] = useState(true);

  // Journal add form
  const [jCategory, setJCategory] = useState('note');
  const [jTitle, setJTitle] = useState('');
  const [jBody, setJBody] = useState('');
  const [jSaving, setJSaving] = useState(false);

  // Knowledge add/edit form
  const [kEditing, setKEditing] = useState<PersonaKnowledgeEntry | null>(null);
  const [kSlug, setKSlug] = useState('');
  const [kTitle, setKTitle] = useState('');
  const [kBody, setKBody] = useState('');
  const [kTags, setKTags] = useState('');
  const [kSaving, setKSaving] = useState(false);

  const load = useCallback(async () => {
    try {
      const { journal, knowledge_base } = await api.getPersona(orgId, persona.id);
      setJournal(journal ?? []);
      setKnowledge(knowledge_base ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load persona');
    } finally {
      setLoading(false);
    }
  }, [orgId, persona.id]);

  useEffect(() => {
    load();
  }, [load]);

  function resetKnowledgeForm() {
    setKEditing(null);
    setKSlug('');
    setKTitle('');
    setKBody('');
    setKTags('');
  }

  async function addJournal(e: React.FormEvent) {
    e.preventDefault();
    if (!jBody.trim()) return;
    setJSaving(true);
    try {
      await api.addPersonaJournal(orgId, persona.id, {
        category: jCategory,
        title: jTitle.trim() || undefined,
        body: jBody.trim(),
      });
      setJTitle('');
      setJBody('');
      toast.success('Journal entry added');
      await load();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to add entry');
    } finally {
      setJSaving(false);
    }
  }

  async function deleteJournal(entry: PersonaJournalEntry) {
    if (!confirm('Delete this journal entry?')) return;
    try {
      await api.deletePersonaJournal(orgId, persona.id, entry.id);
      toast.success('Entry deleted');
      await load();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to delete');
    }
  }

  function editKnowledge(entry: PersonaKnowledgeEntry) {
    setKEditing(entry);
    setKSlug(entry.slug);
    setKTitle(entry.title);
    setKBody(entry.body);
    setKTags((entry.tags ?? []).join(', '));
  }

  async function saveKnowledge(e: React.FormEvent) {
    e.preventDefault();
    if (!kTitle.trim() || !kBody.trim() || (!kEditing && !kSlug.trim())) return;
    setKSaving(true);
    try {
      const tagList = kTags.split(',').map((t) => t.trim()).filter(Boolean);
      if (kEditing) {
        await api.updatePersonaKnowledge(orgId, persona.id, kEditing.id, {
          title: kTitle.trim(),
          body: kBody.trim(),
          tags: tagList,
        });
      } else {
        await api.addPersonaKnowledge(orgId, persona.id, {
          slug: kSlug.trim(),
          title: kTitle.trim(),
          body: kBody.trim(),
          tags: tagList,
        });
      }
      toast.success(kEditing ? 'Article updated' : 'Article added');
      resetKnowledgeForm();
      await load();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to save article');
    } finally {
      setKSaving(false);
    }
  }

  async function deleteKnowledge(entry: PersonaKnowledgeEntry) {
    if (!confirm(`Delete article "${entry.title}"?`)) return;
    try {
      await api.deletePersonaKnowledge(orgId, persona.id, entry.id);
      toast.success('Article deleted');
      if (kEditing?.id === entry.id) resetKnowledgeForm();
      await load();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to delete');
    }
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-card modal-card--lg" onClick={(e) => e.stopPropagation()}>
        <h2 className="modal-title">{persona.name}{persona.role ? ` — ${persona.role}` : ''}</h2>
        {loading ? (
          <p className="sg-page-intro">Loading…</p>
        ) : (
          <>
            <h3 className="sg-page-title" style={{ fontSize: '1.1rem' }}>Journal</h3>
            {journal.length === 0 ? (
              <p className="sg-page-intro">No journal entries yet.</p>
            ) : (
              <ul className="asset-outputs">
                {journal.map((j) => (
                  <li key={j.id} className="asset-outputs__row">
                    <div className="asset-outputs__main">
                      <span className="project-card__status">{j.category}</span>
                      {j.title && <strong>{j.title}</strong>}
                      <span className="project-card__time">{timeAgo(j.inserted_at)}</span>
                    </div>
                    <div className="asset-outputs__actions">
                      <button className="sg-btn sg-btn--danger sg-btn--sm" onClick={() => deleteJournal(j)}>
                        Delete
                      </button>
                    </div>
                    <pre className="asset-outputs__content">{j.body}</pre>
                  </li>
                ))}
              </ul>
            )}
            <form onSubmit={addJournal}>
              <div className="sg-field">
                <label htmlFor="j-category">Category</label>
                <select id="j-category" value={jCategory} onChange={(e) => setJCategory(e.target.value)}>
                  {JOURNAL_CATEGORIES.map((c) => (
                    <option key={c} value={c}>
                      {c}
                    </option>
                  ))}
                </select>
              </div>
              <div className="sg-field">
                <label htmlFor="j-title">Title</label>
                <input id="j-title" value={jTitle} onChange={(e) => setJTitle(e.target.value)} placeholder="Optional" />
              </div>
              <div className="sg-field">
                <label htmlFor="j-body">Entry</label>
                <textarea id="j-body" value={jBody} onChange={(e) => setJBody(e.target.value)} rows={3} />
              </div>
              <div className="modal-actions" style={{ justifyContent: 'flex-start', marginTop: 0 }}>
                <button type="submit" className="sg-btn sg-btn--primary sg-btn--sm" disabled={jSaving || !jBody.trim()}>
                  {jSaving ? 'Adding…' : 'Add entry'}
                </button>
              </div>
            </form>

            <h3 className="sg-page-title" style={{ fontSize: '1.1rem', marginTop: '1.5rem' }}>Knowledge Base</h3>
            {knowledge.length === 0 ? (
              <p className="sg-page-intro">No articles yet.</p>
            ) : (
              <ul className="asset-outputs">
                {knowledge.map((k) => (
                  <li key={k.id} className="asset-outputs__row">
                    <div className="asset-outputs__main">
                      <strong>{k.title}</strong>
                      <span className="font-mono sg-field__hint">{k.slug}</span>
                    </div>
                    <div className="asset-outputs__actions">
                      <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => editKnowledge(k)}>
                        Edit
                      </button>
                      <button className="sg-btn sg-btn--danger sg-btn--sm" onClick={() => deleteKnowledge(k)}>
                        Delete
                      </button>
                    </div>
                    <pre className="asset-outputs__content">{k.body}</pre>
                  </li>
                ))}
              </ul>
            )}
            <form onSubmit={saveKnowledge}>
              <div className="sg-field">
                <label htmlFor="k-slug">Slug</label>
                <input id="k-slug" value={kSlug} onChange={(e) => setKSlug(e.target.value)} placeholder="api-conventions" disabled={!!kEditing} />
              </div>
              <div className="sg-field">
                <label htmlFor="k-title">Title</label>
                <input id="k-title" value={kTitle} onChange={(e) => setKTitle(e.target.value)} placeholder="API Conventions" />
              </div>
              <div className="sg-field">
                <label htmlFor="k-body">Body</label>
                <textarea id="k-body" value={kBody} onChange={(e) => setKBody(e.target.value)} rows={5} />
              </div>
              <div className="sg-field">
                <label htmlFor="k-tags">Tags</label>
                <input id="k-tags" value={kTags} onChange={(e) => setKTags(e.target.value)} placeholder="comma, separated" />
              </div>
              <div className="modal-actions" style={{ justifyContent: 'flex-start', marginTop: 0 }}>
                <button type="submit" className="sg-btn sg-btn--primary sg-btn--sm" disabled={kSaving || !kTitle.trim() || !kBody.trim() || (!kEditing && !kSlug.trim())}>
                  {kSaving ? 'Saving…' : kEditing ? 'Save article' : 'Add article'}
                </button>
                {kEditing && (
                  <button type="button" className="sg-btn sg-btn--outline sg-btn--sm" onClick={resetKnowledgeForm}>
                    Cancel edit
                  </button>
                )}
              </div>
            </form>
          </>
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
  | { kind: 'edit'; persona: Persona }
  | { kind: 'details'; persona: Persona }
  | null;

export default function PersonasPage() {
  const { orgId, slug, loading: orgLoading } = useOrgId();
  const { currentProject, switchProject, projects } = useOrg();
  const [modal, setModal] = useState<ModalState>(null);
  // DataTable owns its fetch; bump to refetch in place after a mutation.
  const [reloadKey, setReloadKey] = useState(0);
  const reload = () => setReloadKey((k) => k + 1);

  // Personas are scoped to the active project (or org + global when none).
  const scope = currentProject ? { projectId: currentProject.id } : undefined;

  async function handleDelete(persona: Persona) {
    if (!orgId) return;
    if (!confirm(`Delete persona "${persona.name}"?`)) return;
    try {
      await api.deletePersona(orgId, persona.id);
      toast.success('Persona deleted');
      reload();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to delete');
    }
  }

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">Personas</h1>
          {currentProject && (
            <span className="scope-chip">
              Project: <strong>{currentProject.name}</strong>
              <button type="button" className="scope-chip__clear" onClick={() => switchProject(null)} title="Show all projects">
                ×
              </button>
            </span>
          )}
        </div>
        <p className="sg-page-intro">Personas — character profiles with a journal and knowledge base.</p>

        {!orgId ? (
          <p className="sg-page-intro">{orgLoading ? 'Loading…' : 'Select an organization to view its personas.'}</p>
        ) : (
          // A persona's rich detail (bio + journal + knowledge base) opens as the
          // existing DetailsModal on row-open — not a generic ConsoleDetailPage.
          <DataTable
            descriptor={personasDescriptor}
            ctx={{ orgId, orgSlug: slug }}
            scope={scope}
            refreshKey={reloadKey}
            onOpenRow={(p) => setModal({ kind: 'details', persona: p })}
            onEditRow={(p) => setModal({ kind: 'edit', persona: p })}
            onDeleteRow={handleDelete}
          />
        )}
      </main>

      {modal?.kind === 'details' && orgId && (
        <DetailsModal orgId={orgId} persona={modal.persona} onClose={() => setModal(null)} />
      )}
      {(modal?.kind === 'create' || modal?.kind === 'edit') && orgId && (
        <PersonaModal
          orgId={orgId}
          projects={projects}
          defaultProjectId={currentProject?.id}
          persona={modal.kind === 'edit' ? modal.persona : null}
          onClose={() => setModal(null)}
          onSaved={() => {
            setModal(null);
            reload();
          }}
        />
      )}

      {orgId && (
        <button className="fab" onClick={() => setModal({ kind: 'create' })} aria-label="New persona" title="New persona">
          <PlusIcon />
        </button>
      )}
    </div>
  );
}
