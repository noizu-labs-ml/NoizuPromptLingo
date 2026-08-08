'use client';

import { useState, useEffect, useMemo } from 'react';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import { PlusIcon } from '@heroicons/react/24/outline';
import { api, type Artifact, type Project, type ArtifactKind } from '@/lib/api';
import { useOrg, useOrgId } from '@/context/org';
import { DataTable } from '@/components/console/DataTable';
import { artifactsDescriptor } from '@/lib/console/descriptors/artifacts';

// Artifacts viewer (ticket c0f97e6b). List renders through the config-driven DataTable
// (artifactsDescriptor); detail/edit live on the /artifacts/:id route via
// ConsoleDetailPage (safe-markdown render + edit=append-revision). Create keeps the
// richer modal here (kind/title/content/mime/project) since append-revision is content-only.

const KINDS: ArtifactKind[] = ['code', 'document', 'image', 'wiki', 'config', 'binary'];

function ArtifactModal({
  orgId,
  projects,
  defaultProjectId,
  onClose,
  onSaved,
}: {
  orgId: string;
  projects: Project[];
  defaultProjectId?: string;
  onClose: () => void;
  onSaved: () => void;
}) {
  const [kind, setKind] = useState<ArtifactKind>('document');
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [mimeType, setMimeType] = useState('');
  const [projectId, setProjectId] = useState(defaultProjectId ?? '');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!title.trim() || !content.trim()) return;
    setSaving(true);
    setError(null);
    try {
      await api.createArtifact(orgId, {
        kind,
        title: title.trim(),
        content,
        mime_type: mimeType.trim() || undefined,
        project_id: projectId || null,
      });
      toast.success('Artifact created');
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
        <h2 className="modal-title">Create Artifact</h2>
        <form onSubmit={handleSubmit}>
          <div className="sg-field">
            <label htmlFor="artifact-kind">Kind</label>
            <select id="artifact-kind" value={kind} onChange={(e) => setKind(e.target.value as ArtifactKind)}>
              {KINDS.map((k) => (
                <option key={k} value={k}>
                  {k}
                </option>
              ))}
            </select>
          </div>
          <div className="sg-field">
            <label htmlFor="artifact-title">Title</label>
            <input
              id="artifact-title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="My Artifact"
              autoFocus
            />
          </div>
          <div className="sg-field">
            <label htmlFor="artifact-content">Content</label>
            <textarea
              id="artifact-content"
              value={content}
              onChange={(e) => setContent(e.target.value)}
              placeholder="Initial content (text, or base64 for binary)"
              rows={8}
            />
          </div>
          <div className="sg-field">
            <label htmlFor="artifact-mime">MIME type</label>
            <input
              id="artifact-mime"
              value={mimeType}
              onChange={(e) => setMimeType(e.target.value)}
              placeholder="text/markdown (optional)"
            />
          </div>
          <div className="sg-field">
            <label htmlFor="artifact-project">Project</label>
            <select id="artifact-project" value={projectId} onChange={(e) => setProjectId(e.target.value)}>
              <option value="">No project</option>
              {projects.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.name}
                </option>
              ))}
            </select>
            <span className="sg-field__hint">Optional — scope this artifact to a project.</span>
          </div>
          {error && <div className="sg-error">{error}</div>}
          <div className="modal-actions">
            <button type="button" className="sg-btn sg-btn--outline" onClick={onClose}>
              Cancel
            </button>
            <button
              type="submit"
              className="sg-btn sg-btn--black"
              disabled={saving || !title.trim() || !content.trim()}
            >
              {saving ? 'Saving…' : 'Create'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default function ArtifactsPage() {
  const router = useRouter();
  const { orgId, slug, loading: orgLoading } = useOrgId();
  const { currentProject } = useOrg();
  const [projects, setProjects] = useState<Project[]>([]);
  const [showModal, setShowModal] = useState(false);
  const [reloadKey, setReloadKey] = useState(0);

  // Projects power the dynamic project facet + the create modal's project picker.
  useEffect(() => {
    if (!orgId) return;
    api.listProjects(orgId).then((r) => setProjects(r.projects ?? [])).catch(() => {});
  }, [orgId]);

  const facetOptions = useMemo(
    () => ({ projectId: projects.map((p) => ({ value: p.id, label: p.name })) }),
    [projects],
  );

  if (orgLoading || !orgId) {
    return (
      <div className="content">
        <main>
          <p className="sg-page-intro">Loading…</p>
        </main>
      </div>
    );
  }

  const ctx = { orgId, orgSlug: slug };
  const detailHref = (a: Artifact) => `/app/${slug}/artifacts/${a.id}`;

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">Artifacts</h1>
        </div>
        <p className="sg-page-intro">
          {currentProject
            ? `Typed, versioned content objects in ${currentProject.name}.`
            : 'Typed, versioned content objects for this organization.'}
        </p>

        <DataTable
          descriptor={artifactsDescriptor}
          ctx={ctx}
          refreshKey={reloadKey}
          scope={currentProject?.id ? { projectId: currentProject.id } : undefined}
          facetOptions={facetOptions}
          onOpenRow={(a) => router.push(detailHref(a))}
          onEditRow={(a) => router.push(`${detailHref(a)}?edit=1`)}
        />

        <button className="fab" onClick={() => setShowModal(true)} aria-label="New artifact" title="New artifact">
          <PlusIcon />
        </button>
      </main>

      {showModal && (
        <ArtifactModal
          orgId={orgId}
          projects={projects}
          defaultProjectId={currentProject?.id}
          onClose={() => setShowModal(false)}
          onSaved={() => {
            setShowModal(false);
            setReloadKey((k) => k + 1);
          }}
        />
      )}
    </div>
  );
}
