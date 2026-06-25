'use client';

import { useState, useEffect, useCallback, useMemo } from 'react';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import { api, type Session, type Project } from '@/lib/api';
import { useOrg, useOrgId } from '@/context/org';
import { DataTable } from '@/components/console/DataTable';
import { sessionsDescriptor } from '@/lib/console/descriptors/sessions';

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
  // orgId (UUID) for api; orgSlug for route building (ConsoleContext, diego seq506).
  const { orgId, slug: orgSlug, loading: orgLoading } = useOrgId();
  const { currentProject, switchProject } = useOrg();
  const router = useRouter();
  const [projects, setProjects] = useState<Project[]>([]);
  const [modal, setModal] = useState<ModalState>(null);
  // Bumped on create/edit/archive to refetch <DataTable> in place (G1 refreshKey).
  const [reloadKey, setReloadKey] = useState(0);

  const scopeProjectId = currentProject?.id;

  // Projects power the dynamic projectId facet options + the create/edit modal.
  const fetchProjects = useCallback(async () => {
    if (!orgId) return;
    try {
      const { projects } = await api.listProjects(orgId);
      setProjects(projects ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load projects');
    }
  }, [orgId]);

  useEffect(() => {
    if (orgId) fetchProjects();
  }, [fetchProjects, orgId]);

  const facetOptions = useMemo(
    () => ({ projectId: projects.map((p) => ({ value: p.id, label: p.name })) }),
    [projects],
  );
  const ctx = useMemo(() => ({ orgId: orgId ?? '', orgSlug: orgSlug ?? '' }), [orgId, orgSlug]);
  const scope = useMemo(
    () => (scopeProjectId ? { projectId: scopeProjectId } : undefined),
    [scopeProjectId],
  );

  function handleSaved() {
    setModal(null);
    setReloadKey((k) => k + 1);
  }

  async function handleArchive(session: Session) {
    if (!orgId) return;
    try {
      await api.archiveSession(orgId, session.id);
      toast.success('Session archived');
      setReloadKey((k) => k + 1);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to archive session');
    }
  }

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
          <button className="sg-btn sg-btn--black" onClick={() => setModal({ type: 'create' })}>
            New Session
          </button>
        </div>
        <p className="sg-page-intro">
          {currentProject
            ? `Sessions in ${currentProject.name}.`
            : 'Work sessions grouping rooms, artifacts, and tickets.'}
        </p>

        {orgLoading || !orgId ? (
          <p className="sg-page-intro">Loading…</p>
        ) : (
          <DataTable
            descriptor={sessionsDescriptor}
            ctx={ctx}
            scope={scope}
            facetOptions={facetOptions}
            refreshKey={reloadKey}
            onOpenRow={(s) => router.push(`/app/${orgSlug}/sessions/${s.id}`)}
            onEditRow={(s) => setModal({ type: 'edit', session: s })}
            onAction={(key, s) => {
              if (key === 'archive') void handleArchive(s);
            }}
          />
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
