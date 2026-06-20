'use client';

import { useState, useEffect, useCallback } from 'react';
import { toast } from 'sonner';
import { api, type Session, type Project } from '@/lib/api';
import { useOrg, useOrgId } from '@/context/org';

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

function SessionModal({
  orgId,
  projects,
  session,
  defaultProjectId,
  onClose,
  onSaved,
}: {
  orgId: string;
  projects: Project[];
  session?: Session | null;
  defaultProjectId?: string;
  onClose: () => void;
  onSaved: () => void;
}) {
  const isEdit = !!session;
  const [title, setTitle] = useState(session?.title ?? '');
  const [description, setDescription] = useState(session?.description ?? '');
  // Project association is optional — empty string means "no project". New
  // sessions default to the active project scope when one is selected.
  const [projectId, setProjectId] = useState(session?.project_id ?? defaultProjectId ?? '');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!title.trim()) return;
    setSaving(true);
    setError(null);
    try {
      const payload = {
        title: title.trim(),
        description: description.trim(),
        project_id: projectId || null,
      };
      if (isEdit && session) {
        await api.updateSession(orgId, session.id, payload);
      } else {
        await api.createSession(orgId, payload);
      }
      toast.success(isEdit ? 'Session updated' : 'Session created');
      onSaved();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Request failed');
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-card" onClick={(e) => e.stopPropagation()}>
        <h2 className="modal-title">{isEdit ? 'Edit Session' : 'Create Session'}</h2>
        <form onSubmit={handleSubmit}>
          <div className="sg-field">
            <label htmlFor="session-title">Title</label>
            <input
              id="session-title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="My Session"
              autoFocus
            />
          </div>
          <div className="sg-field">
            <label htmlFor="session-project">Project</label>
            <select
              id="session-project"
              value={projectId}
              onChange={(e) => setProjectId(e.target.value)}
            >
              <option value="">No project</option>
              {projects.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.name}
                </option>
              ))}
            </select>
            <span className="sg-field__hint">Optional — associate this session with a project.</span>
          </div>
          <div className="sg-field">
            <label htmlFor="session-description">Description</label>
            <textarea
              id="session-description"
              value={description ?? ''}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Optional description"
            />
          </div>
          {error && <div className="sg-error">{error}</div>}
          <div className="modal-actions">
            <button type="button" className="sg-btn sg-btn--outline" onClick={onClose}>
              Cancel
            </button>
            <button type="submit" className="sg-btn sg-btn--black" disabled={saving || !title.trim()}>
              {saving ? 'Saving…' : isEdit ? 'Save' : 'Create'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

type ModalState = { type: 'create' } | { type: 'edit'; session: Session } | null;

export default function SessionsPage() {
  const { orgId, loading: orgLoading } = useOrgId();
  const { currentProject, switchProject } = useOrg();
  const [sessions, setSessions] = useState<Session[]>([]);
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState<ModalState>(null);

  const scopeProjectId = currentProject?.id;

  const fetchData = useCallback(async () => {
    if (!orgId) return;
    try {
      const [sessionData, projectData] = await Promise.all([
        api.listSessions(orgId, scopeProjectId ? { projectId: scopeProjectId } : undefined),
        api.listProjects(orgId),
      ]);
      setSessions(sessionData.sessions ?? []);
      setProjects(projectData.projects ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load sessions');
    } finally {
      setLoading(false);
    }
  }, [orgId, scopeProjectId]);

  useEffect(() => {
    if (orgId) {
      fetchData();
    } else if (!orgLoading) {
      setLoading(false);
    }
  }, [fetchData, orgId, orgLoading]);

  async function handleSaved() {
    setModal(null);
    await fetchData();
  }

  async function handleArchive(session: Session) {
    if (!orgId) return;
    try {
      await api.archiveSession(orgId, session.id);
      toast.success('Session archived');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to archive session');
    }
    await fetchData();
  }

  const projectName = (id?: string | null) =>
    id ? projects.find((p) => p.id === id)?.name ?? '—' : '—';

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">Sessions</h1>
          {currentProject && (
            <span className="scope-chip">
              Project: <strong>{currentProject.name}</strong>
              <button
                type="button"
                className="scope-chip__clear"
                onClick={() => switchProject(null)}
                aria-label="Clear project scope"
                title="Show all projects"
              >
                ×
              </button>
            </span>
          )}
        </div>
        <p className="sg-page-intro">
          {currentProject
            ? `Sessions in ${currentProject.name}.`
            : 'Work sessions grouping rooms, artifacts, and tickets.'}
        </p>

        {loading ? (
          <p className="sg-page-intro">Loading…</p>
        ) : sessions.length === 0 ? (
          <div className="projects-empty">
            <p className="projects-empty__text">No sessions yet. Create one to get started.</p>
            <button className="sg-btn sg-btn--black" onClick={() => setModal({ type: 'create' })}>
              Create Session
            </button>
          </div>
        ) : (
          <div className="projects-grid">
            {sessions.map((s) => (
              <div key={s.id} className="project-card">
                <div className="project-card__header">
                  <div className="project-card__org">{projectName(s.project_id)}</div>
                  <div className="project-card__name">{s.title}</div>
                </div>
                <div className="project-card__body">
                <dl className="project-card__fields">
                  <div className="project-card__field">
                    <dt>Description:</dt>
                    <dd>{s.description || '—'}</dd>
                  </div>
                </dl>
                <div className="project-card__meta">
                  <span className={`project-card__status project-card__status--${s.status ?? 'active'}`}>
                    {s.status ?? 'active'}
                  </span>
                  <span className="project-card__time">{timeAgo(s.inserted_at)}</span>
                </div>
                <div className="project-card__actions">
                  <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => setModal({ type: 'edit', session: s })}>
                    Edit
                  </button>
                  {s.status !== 'archived' && (
                    <button className="sg-btn sg-btn--danger sg-btn--sm" onClick={() => handleArchive(s)}>
                      Archive
                    </button>
                  )}
                </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>

      {modal?.type === 'create' && orgId && (
        <SessionModal orgId={orgId} projects={projects} defaultProjectId={scopeProjectId} onClose={() => setModal(null)} onSaved={handleSaved} />
      )}
      {modal?.type === 'edit' && orgId && (
        <SessionModal orgId={orgId} projects={projects} session={modal.session} onClose={() => setModal(null)} onSaved={handleSaved} />
      )}
    </div>
  );
}
