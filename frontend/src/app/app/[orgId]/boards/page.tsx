'use client';

import { useState, useEffect, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import { PlusIcon } from '@heroicons/react/24/outline';
import { api, type Board, METHODOLOGIES, type Methodology } from '@/lib/api';
import { useOrg, useOrgId } from '@/context/org';

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
  scope,
  projectId,
  onClose,
  onSaved,
}: {
  orgId: string;
  scope: 'org' | 'project';
  projectId?: string;
  onClose: () => void;
  onSaved: () => void;
}) {
  const [name, setName] = useState('');
  const [slug, setSlug] = useState('');
  const [slugTouched, setSlugTouched] = useState(false);
  const [methodology, setMethodology] = useState<Methodology>('kanban');
  const [description, setDescription] = useState('');
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
        scope,
        project_id: scope === 'project' ? projectId : null,
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
        <h2 className="modal-title">New Board ({scope})</h2>
        <form onSubmit={handleSubmit}>
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
  const { orgId, loading: orgLoading } = useOrgId();
  const { currentProject, switchProject } = useOrg();
  const router = useRouter();
  const [boards, setBoards] = useState<Board[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);

  const scope: 'org' | 'project' = currentProject ? 'project' : 'org';
  const projectId = currentProject?.id;

  const fetchData = useCallback(async () => {
    if (!orgId) return;
    try {
      const data = await api.listBoards(orgId, projectId ? { projectId } : undefined);
      setBoards(data.boards ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load boards');
    } finally {
      setLoading(false);
    }
  }, [orgId, projectId]);

  useEffect(() => {
    if (orgId) fetchData();
    else if (!orgLoading) setLoading(false);
  }, [fetchData, orgId, orgLoading]);

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

        {loading ? (
          <p className="sg-page-intro">Loading…</p>
        ) : boards.length === 0 ? (
          <div className="projects-empty">
            <p className="projects-empty__text">No boards yet. Create one to start planning.</p>
            <button className="sg-btn sg-btn--black" onClick={() => setShowModal(true)}>
              New Board
            </button>
          </div>
        ) : (
          <div className="projects-grid">
            {boards.map((b) => (
              <div key={b.id} className="project-card" style={{ cursor: 'pointer' }} onClick={() => router.push(`/app/${orgId}/boards/${b.id}`)}>
                <div className="project-card__header">
                  <div className="project-card__org">
                    {b.scope} · {b.methodology}
                  </div>
                  <div className="project-card__name">{b.name}</div>
                </div>
                <div className="project-card__body">
                  <dl className="project-card__fields">
                    <div className="project-card__field">
                      <dt>Slug:</dt>
                      <dd className="font-mono">{b.slug}</dd>
                    </div>
                    {b.description && (
                      <div className="project-card__field">
                        <dt>About:</dt>
                        <dd>{b.description}</dd>
                      </div>
                    )}
                  </dl>
                  <div className="project-card__meta">
                    <span className="project-card__status">{b.methodology}</span>
                    <span className="project-card__time">Open board →</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>

      {showModal && orgId && (
        <BoardModal
          orgId={orgId}
          scope={scope}
          projectId={projectId}
          onClose={() => setShowModal(false)}
          onSaved={() => {
            setShowModal(false);
            fetchData();
          }}
        />
      )}

      {!loading && boards.length > 0 && (
        <button className="fab" onClick={() => setShowModal(true)} aria-label="New board" title="New board">
          <PlusIcon />
        </button>
      )}
    </div>
  );
}
