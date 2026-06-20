'use client';

import { useState, useEffect, useCallback } from 'react';
import { toast } from 'sonner';
import { PlusIcon } from '@heroicons/react/24/outline';
import { api, type Project } from '@/lib/api';
import { useOrg, useOrgId } from '@/context/org';

function toSlug(name: string) {
  return name
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '-')
    .replace(/[^a-z0-9-]/g, '')
    .replace(/^-+|-+$/g, '');
}

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

function ProjectModal({
  orgId,
  project,
  onClose,
  onSaved,
}: {
  orgId: string;
  project?: Project | null;
  onClose: () => void;
  onSaved: () => void;
}) {
  const isEdit = !!project;
  const [name, setName] = useState(project?.name ?? '');
  const [slug, setSlug] = useState(project?.slug ?? '');
  const [description, setDescription] = useState(project?.description ?? '');
  const [slugTouched, setSlugTouched] = useState(isEdit);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  function handleNameChange(v: string) {
    setName(v);
    if (!slugTouched) setSlug(toSlug(v));
  }

  function handleSlugChange(v: string) {
    setSlugTouched(true);
    setSlug(v);
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim()) return;
    setSaving(true);
    setError(null);
    try {
      const payload = { name: name.trim(), slug: slug.trim(), description: description.trim() };
      if (isEdit && project) {
        await api.updateProject(orgId, project.id, payload);
      } else {
        await api.createProject(orgId, payload);
      }
      toast.success(isEdit ? 'Project updated' : 'Project created');
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
        <h2 className="modal-title">{isEdit ? 'Edit Project' : 'Create Project'}</h2>
        <form onSubmit={handleSubmit}>
          <div className="sg-field">
            <label htmlFor="project-name">Name</label>
            <input
              id="project-name"
              value={name}
              onChange={(e) => handleNameChange(e.target.value)}
              placeholder="My Project"
              autoFocus
            />
          </div>
          <div className="sg-field">
            <label htmlFor="project-slug">Slug</label>
            <input
              id="project-slug"
              value={slug}
              onChange={(e) => handleSlugChange(e.target.value)}
              placeholder="my-project"
            />
            <span className="sg-field__hint">Lowercase letters, numbers, and hyphens.</span>
          </div>
          <div className="sg-field">
            <label htmlFor="project-description">Description</label>
            <textarea
              id="project-description"
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
            <button type="submit" className="sg-btn sg-btn--black" disabled={saving || !name.trim()}>
              {saving ? 'Saving…' : isEdit ? 'Save' : 'Create'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

function ArchiveConfirm({
  project,
  onClose,
  onConfirm,
}: {
  project: Project;
  onClose: () => void;
  onConfirm: () => Promise<void>;
}) {
  const [loading, setLoading] = useState(false);

  async function handleArchive() {
    setLoading(true);
    await onConfirm();
    setLoading(false);
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-card modal-card--sm" onClick={(e) => e.stopPropagation()}>
        <h2 className="modal-title">Archive Project</h2>
        <p className="modal-body">
          Archive <strong>{project.name}</strong>? It will no longer appear in active listings.
        </p>
        <div className="modal-actions">
          <button type="button" className="sg-btn sg-btn--outline" onClick={onClose}>
            Cancel
          </button>
          <button type="button" className="sg-btn sg-btn--danger" onClick={handleArchive} disabled={loading}>
            {loading ? 'Archiving…' : 'Archive'}
          </button>
        </div>
      </div>
    </div>
  );
}

type ModalState = { type: 'create' } | { type: 'edit'; project: Project } | null;

export default function ProjectsPage() {
  const { orgId, loading: orgLoading } = useOrgId();
  const { organizations, currentProject, switchProject, switchOrg, refreshProjects } = useOrg();
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState<ModalState>(null);
  const [archiveTarget, setArchiveTarget] = useState<Project | null>(null);

  const fetchProjects = useCallback(async () => {
    if (!orgId) return;
    try {
      const data = await api.listProjects(orgId);
      setProjects(data.projects ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load projects');
    } finally {
      setLoading(false);
    }
  }, [orgId]);

  useEffect(() => {
    if (orgId) {
      fetchProjects();
    } else if (!orgLoading) {
      setLoading(false);
    }
  }, [fetchProjects, orgId, orgLoading]);

  // The brand-mark switcher links here as `…/projects#<slug>`. Once projects
  // load, adopt that project as the active scope and scroll it into view.
  useEffect(() => {
    if (loading || !orgId || projects.length === 0) return;
    const slug = typeof window !== 'undefined' ? window.location.hash.slice(1) : '';
    if (!slug) return;
    const target = projects.find((p) => p.slug === slug);
    if (target) {
      switchOrg(orgId);
      switchProject(target, orgId);
      document.getElementById(`project-${target.id}`)?.scrollIntoView({ block: 'center' });
    }
  }, [loading, orgId, projects, switchOrg, switchProject]);

  function selectProject(p: Project) {
    if (!orgId) return;
    switchOrg(orgId);
    if (currentProject?.id === p.id) switchProject(null, orgId);
    else switchProject(p, orgId);
  }

  async function handleSaved() {
    setModal(null);
    await fetchProjects();
    await refreshProjects();
  }

  async function handleArchive(project: Project) {
    if (!orgId) return;
    try {
      await api.archiveProject(orgId, project.id);
      toast.success('Project archived');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to archive project');
    }
    setArchiveTarget(null);
    // Drop the scope if the archived project was the active one.
    if (currentProject?.id === project.id) switchProject(null, orgId);
    await fetchProjects();
    await refreshProjects();
  }

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">Projects</h1>
        </div>

        {loading ? (
          <p className="sg-page-intro">Loading…</p>
        ) : projects.length === 0 ? (
          <div className="projects-empty">
            <p className="projects-empty__text">No projects yet. Create one to get started.</p>
            <button className="sg-btn sg-btn--black" onClick={() => setModal({ type: 'create' })}>
              Create Project
            </button>
          </div>
        ) : (
          <div className="projects-grid">
            {projects.map((p) => {
              const orgName = organizations.find((o) => o.id === p.organization_id)?.name;
              const isActive = currentProject?.id === p.id;
              return (
              <div key={p.id} id={`project-${p.id}`} className={`project-card${isActive ? ' project-card--active' : ''}`}>
                <div className="project-card__header">
                  <div className="project-card__name">
                    {p.name}
                    {isActive && <span className="project-card__current">active</span>}
                  </div>
                  <div className="project-card__slug">{p.slug}</div>
                </div>
                <div className="project-card__body">
                <dl className="project-card__fields">
                  <div className="project-card__field">
                    <dt>Slug:</dt>
                    <dd className="project-card__slug">{p.slug}</dd>
                  </div>
                  <div className="project-card__field">
                    <dt>Title:</dt>
                    <dd>{p.name}</dd>
                  </div>
                  <div className="project-card__field">
                    <dt>Description:</dt>
                    <dd>{p.description || '—'}</dd>
                  </div>
                  {orgName && (
                    <div className="project-card__field">
                      <dt>Org:</dt>
                      <dd className="project-card__org">{orgName}</dd>
                    </div>
                  )}
                </dl>
                <div className="project-card__meta">
                  <span className={`project-card__status project-card__status--${p.status ?? 'active'}`}>
                    {p.status ?? 'active'}
                  </span>
                  <span className="project-card__time">{timeAgo(p.created_at ?? p.inserted_at)}</span>
                </div>
                <div className="project-card__actions">
                  <button
                    className={`sg-btn sg-btn--sm ${isActive ? 'sg-btn--black' : 'sg-btn--outline'}`}
                    onClick={() => selectProject(p)}
                  >
                    {isActive ? 'Active' : 'Select'}
                  </button>
                  <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => setModal({ type: 'edit', project: p })}>
                    Edit
                  </button>
                  {p.status !== 'archived' && (
                    <button className="sg-btn sg-btn--danger sg-btn--sm" onClick={() => setArchiveTarget(p)}>
                      Archive
                    </button>
                  )}
                </div>
                </div>
              </div>
              );
            })}
          </div>
        )}
      </main>

      {modal?.type === 'create' && orgId && (
        <ProjectModal orgId={orgId} onClose={() => setModal(null)} onSaved={handleSaved} />
      )}
      {modal?.type === 'edit' && orgId && (
        <ProjectModal orgId={orgId} project={modal.project} onClose={() => setModal(null)} onSaved={handleSaved} />
      )}
      {archiveTarget && (
        <ArchiveConfirm
          project={archiveTarget}
          onClose={() => setArchiveTarget(null)}
          onConfirm={() => handleArchive(archiveTarget)}
        />
      )}

      {!loading && projects.length > 0 && (
        <button className="fab" onClick={() => setModal({ type: 'create' })} aria-label="New project" title="New project">
          <PlusIcon />
        </button>
      )}
    </div>
  );
}
