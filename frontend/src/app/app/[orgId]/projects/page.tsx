'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import { PlusIcon } from '@heroicons/react/24/outline';
import { api, type Project } from '@/lib/api';
import { useOrg, useOrgId } from '@/context/org';
import { DataTable } from '@/components/console/DataTable';
import { projectsDescriptor } from '@/lib/console/descriptors/projects';

// Projects: the first console-pattern convert (epic 8920d294). The list renders
// through the config-driven DataTable (projectsDescriptor); create/edit/archive keep
// their existing modals, wired via the table's row callbacks. Primary-click adopts
// the project as the active scope (its long-standing primary action).

function toSlug(name: string) {
  return name
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '-')
    .replace(/[^a-z0-9-]/g, '')
    .replace(/^-+|-+$/g, '');
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
  const [keyPrefix, setKeyPrefix] = useState(project?.key_prefix ?? '');
  const [slugTouched, setSlugTouched] = useState(isEdit);
  const [prefixTouched, setPrefixTouched] = useState(isEdit);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Suggested ticket-key prefix: uppercase alnum of the name, capped (mirrors the BE
  // auto-derive). A pre-filled SUGGESTION only — the user can edit or clear it.
  const toPrefix = (v: string) => v.toUpperCase().replace(/[^A-Z0-9]/g, '').slice(0, 6);

  function handleNameChange(v: string) {
    setName(v);
    if (!slugTouched) setSlug(toSlug(v));
    if (!prefixTouched) setKeyPrefix(toPrefix(v));
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
      const payload = { name: name.trim(), slug: slug.trim(), description: description.trim(), key_prefix: keyPrefix.trim() || undefined };
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
            <label htmlFor="project-key-prefix">Ticket key prefix</label>
            <input
              id="project-key-prefix"
              value={keyPrefix}
              onChange={(e) => {
                setPrefixTouched(true);
                setKeyPrefix(e.target.value.toUpperCase().replace(/[^A-Z0-9]/g, '').slice(0, 12));
              }}
              placeholder="ABC"
            />
            <span className="sg-field__hint">Uppercase letters and digits — used for ticket keys like ABC-001. Optional.</span>
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

type ModalState = { type: 'create' } | null;

export default function ProjectsPage() {
  const { orgId, slug, loading: orgLoading } = useOrgId();
  const { currentProject, switchProject, switchOrg, refreshProjects } = useOrg();
  const router = useRouter();
  const [modal, setModal] = useState<ModalState>(null);
  const [archiveTarget, setArchiveTarget] = useState<Project | null>(null);
  // DataTable owns its fetch; bump this to force a refetch after a mutation.
  const [reloadKey, setReloadKey] = useState(0);
  const reload = () => setReloadKey((k) => k + 1);

  // Primary-click adopts the project as the active scope (its long-standing action).
  function selectProject(p: Project) {
    if (!orgId) return;
    switchOrg(orgId);
    if (currentProject?.id === p.id) switchProject(null, orgId);
    else switchProject(p, orgId);
  }

  async function handleSaved() {
    setModal(null);
    reload();
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
    reload();
    await refreshProjects();
  }

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">Projects</h1>
        </div>

        {!orgId ? (
          <p className="sg-page-intro">{orgLoading ? 'Loading…' : 'Select an organization to view its projects.'}</p>
        ) : (
          <DataTable
            descriptor={projectsDescriptor}
            ctx={{ orgId, orgSlug: slug }}
            refreshKey={reloadKey}
            rowClassName={(p) => (currentProject?.id === p.id ? 'is-current-scope' : undefined)}
            onOpenRow={selectProject}
            onEditRow={(p) => router.push(`/app/${slug}/projects/${p.id}?edit=1`)}
            onAction={(action, p) => {
              if (action === 'details') router.push(`/app/${slug}/projects/${p.id}`);
              else if (action === 'archive') setArchiveTarget(p);
            }}
          />
        )}
      </main>

      {modal?.type === 'create' && orgId && (
        <ProjectModal orgId={orgId} onClose={() => setModal(null)} onSaved={handleSaved} />
      )}
      {archiveTarget && (
        <ArchiveConfirm
          project={archiveTarget}
          onClose={() => setArchiveTarget(null)}
          onConfirm={() => handleArchive(archiveTarget)}
        />
      )}

      {orgId && (
        <button className="fab" onClick={() => setModal({ type: 'create' })} aria-label="New project" title="New project">
          <PlusIcon />
        </button>
      )}
    </div>
  );
}
