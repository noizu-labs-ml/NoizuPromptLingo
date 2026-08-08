'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import { PlusIcon } from '@heroicons/react/24/outline';
import { api, type Project, METHODOLOGIES, type Methodology } from '@/lib/api';
import { useOrg, useOrgId } from '@/context/org';
import { DataTable } from '@/components/console/DataTable';
import { boardsDescriptor } from '@/lib/console/descriptors/boards';

function toSlug(s: string) {
  return s.toLowerCase().trim().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '').replace(/^-+|-+$/g, '');
}

const METHODOLOGY_BLURB: Record<string, string> = {
  kanban: 'Continuous flow across columns.',
  scrum: 'Time-boxed sprints with a backlog.',
  waterfall: 'Sequential phases, start to finish.',
  spiral: 'Iterative risk-driven cycles.',
};

function BoardModal({
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
  const [name, setName] = useState('');
  const [slug, setSlug] = useState('');
  const [slugTouched, setSlugTouched] = useState(false);
  const [methodology, setMethodology] = useState<Methodology>('kanban');
  const [description, setDescription] = useState('');
  // Default the board's project to the active project; '' = org-level (no project).
  const [projectId, setProjectId] = useState(defaultProjectId ?? '');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim() || !slug.trim()) return;
    setSaving(true);
    setError(null);
    try {
      await api.createBoard(orgId, {
        name: name.trim(),
        slug: slug.trim(),
        methodology,
        description: description.trim() || undefined,
        scope: projectId ? 'project' : 'org',
        project_id: projectId || null,
      });
      toast.success('Board created');
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
        <h2 className="modal-title">New Board</h2>
        <form onSubmit={handleSubmit}>
          <div className="sg-field">
            <label htmlFor="b-project">Project</label>
            <select id="b-project" value={projectId} onChange={(e) => setProjectId(e.target.value)}>
              <option value="">Org-level (no project)</option>
              {projects.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.name}
                </option>
              ))}
            </select>
            <span className="sg-field__hint">Defaults to your active project. The board shows that project’s tickets as cards.</span>
          </div>
          <div className="sg-field">
            <label htmlFor="b-name">Name</label>
            <input
              id="b-name"
              value={name}
              onChange={(e) => {
                setName(e.target.value);
                if (!slugTouched) setSlug(toSlug(e.target.value));
              }}
              placeholder="Sprint Board"
              autoFocus
            />
          </div>
          <div className="sg-field">
            <label htmlFor="b-slug">Slug</label>
            <input id="b-slug" value={slug} onChange={(e) => { setSlugTouched(true); setSlug(e.target.value); }} placeholder="sprint-board" />
          </div>
          <div className="sg-field">
            <label htmlFor="b-method">Methodology</label>
            <select id="b-method" value={methodology} onChange={(e) => setMethodology(e.target.value as Methodology)}>
              {METHODOLOGIES.map((m) => (
                <option key={m} value={m}>
                  {m}
                </option>
              ))}
            </select>
            <span className="sg-field__hint">{METHODOLOGY_BLURB[methodology]} Default stages are created automatically.</span>
          </div>
          <div className="sg-field">
            <label htmlFor="b-desc">Description</label>
            <textarea id="b-desc" value={description} onChange={(e) => setDescription(e.target.value)} placeholder="Optional" />
          </div>
          {error && <div className="sg-error">{error}</div>}
          <div className="modal-actions">
            <button type="button" className="sg-btn sg-btn--outline" onClick={onClose}>
              Cancel
            </button>
            <button type="submit" className="sg-btn sg-btn--black" disabled={saving || !name.trim() || !slug.trim()}>
              {saving ? 'Saving…' : 'Create'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default function BoardsPage() {
  const { orgId, slug, loading: orgLoading } = useOrgId();
  const { currentProject, switchProject, projects } = useOrg();
  const router = useRouter();
  const [showModal, setShowModal] = useState(false);
  // DataTable owns its fetch; bump to refetch in place after a create.
  const [reloadKey, setReloadKey] = useState(0);

  // Board cards are scoped to the active project (or org + global when none).
  const scope = currentProject ? { projectId: currentProject.id } : undefined;

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">Boards</h1>
          {currentProject && (
            <span className="scope-chip">
              Project: <strong>{currentProject.name}</strong>
              <button type="button" className="scope-chip__clear" onClick={() => switchProject(null)} title="Show org + global">
                ×
              </button>
            </span>
          )}
        </div>
        <p className="sg-page-intro">Kanban, Scrum, Waterfall, and Spiral boards for planning and tracking tickets.</p>

        {!orgId ? (
          <p className="sg-page-intro">{orgLoading ? 'Loading…' : 'Select an organization to view its boards.'}</p>
        ) : (
          <DataTable
            descriptor={boardsDescriptor}
            ctx={{ orgId, orgSlug: slug }}
            scope={scope}
            refreshKey={reloadKey}
            onOpenRow={(b) => router.push(`/app/${slug}/boards/${b.id}`)}
          />
        )}
      </main>

      {showModal && orgId && (
        <BoardModal
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

      {orgId && (
        <button className="fab" onClick={() => setShowModal(true)} aria-label="New board" title="New board">
          <PlusIcon />
        </button>
      )}
    </div>
  );
}
