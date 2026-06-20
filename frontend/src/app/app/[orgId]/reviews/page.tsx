'use client';

import { useState, useEffect, useCallback } from 'react';
import { toast } from 'sonner';
import { PlusIcon } from '@heroicons/react/24/outline';
import { api, type Review, type Artifact, type Project } from '@/lib/api';
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

function statusClass(status?: string) {
  if (status === 'completed') return 'project-card__status--active';
  if (status === 'in_progress') return 'project-card__status--archived';
  return '';
}

function ReviewModal({
  orgId,
  artifacts,
  defaultProjectId,
  onClose,
  onSaved,
}: {
  orgId: string;
  artifacts: Artifact[];
  defaultProjectId?: string;
  onClose: () => void;
  onSaved: () => void;
}) {
  const [artifactId, setArtifactId] = useState('');
  const [persona, setPersona] = useState('');
  const [title, setTitle] = useState('');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!artifactId || !persona.trim()) return;
    setSaving(true);
    setError(null);
    try {
      // A review targets a specific revision; resolve the artifact's latest.
      const { artifact } = await api.getArtifact(orgId, artifactId);
      if (!artifact.revision_id) throw new Error('Selected artifact has no revision to review');
      await api.createReview(orgId, {
        artifact_id: artifactId,
        revision_id: artifact.revision_id,
        reviewer_persona: persona.trim(),
        title: title.trim() || undefined,
        project_id: artifact.project_id ?? defaultProjectId ?? null,
      });
      toast.success('Review started');
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
        <h2 className="modal-title">Start Review</h2>
        <form onSubmit={handleSubmit}>
          <div className="sg-field">
            <label htmlFor="review-artifact">Artifact</label>
            <select id="review-artifact" value={artifactId} onChange={(e) => setArtifactId(e.target.value)}>
              <option value="">Select an artifact…</option>
              {artifacts.map((a) => (
                <option key={a.id} value={a.id}>
                  {a.title} ({a.kind})
                </option>
              ))}
            </select>
            <span className="sg-field__hint">The latest revision of this artifact will be reviewed.</span>
          </div>
          <div className="sg-field">
            <label htmlFor="review-persona">Reviewer persona</label>
            <input
              id="review-persona"
              value={persona}
              onChange={(e) => setPersona(e.target.value)}
              placeholder="senior-engineer"
              autoFocus
            />
          </div>
          <div className="sg-field">
            <label htmlFor="review-title">Title</label>
            <input
              id="review-title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Optional review title"
            />
          </div>
          {error && <div className="sg-error">{error}</div>}
          <div className="modal-actions">
            <button type="button" className="sg-btn sg-btn--outline" onClick={onClose}>
              Cancel
            </button>
            <button type="submit" className="sg-btn sg-btn--black" disabled={saving || !artifactId || !persona.trim()}>
              {saving ? 'Saving…' : 'Start'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default function ReviewsPage() {
  const { orgId, loading: orgLoading } = useOrgId();
  const { currentProject, switchProject } = useOrg();
  const [reviews, setReviews] = useState<Review[]>([]);
  const [artifacts, setArtifacts] = useState<Artifact[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);

  const scopeProjectId = currentProject?.id;

  const fetchData = useCallback(async () => {
    if (!orgId) return;
    try {
      const [reviewData, artifactData] = await Promise.all([
        api.listReviews(orgId, scopeProjectId ? { projectId: scopeProjectId } : undefined),
        api.listArtifacts(orgId, scopeProjectId ? { projectId: scopeProjectId } : undefined),
      ]);
      setReviews(reviewData.reviews ?? []);
      setArtifacts(artifactData.artifacts ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load reviews');
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

  const artifactTitle = (id?: string) => artifacts.find((a) => a.id === id)?.title ?? '—';

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">Reviews</h1>
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
            ? `Reviews in ${currentProject.name}.`
            : 'Code reviews, comments, and compiled feedback for this organization.'}
        </p>

        {loading ? (
          <p className="sg-page-intro">Loading…</p>
        ) : reviews.length === 0 ? (
          <div className="projects-empty">
            <p className="projects-empty__text">
              {artifacts.length === 0
                ? 'No artifacts to review yet. Create an artifact first.'
                : 'No reviews yet. Start one to get going.'}
            </p>
            {artifacts.length > 0 && (
              <button className="sg-btn sg-btn--black" onClick={() => setShowModal(true)}>
                Start Review
              </button>
            )}
          </div>
        ) : (
          <div className="projects-grid">
            {reviews.map((r) => (
              <div key={r.id} className="project-card">
                <div className="project-card__header">
                  <div className="project-card__org">{artifactTitle(r.artifact_id)}</div>
                  <div className="project-card__name">{r.title || `Review by ${r.reviewer_persona}`}</div>
                </div>
                <div className="project-card__body">
                  <dl className="project-card__fields">
                    <div className="project-card__field">
                      <dt>Reviewer:</dt>
                      <dd>{r.reviewer_persona}</dd>
                    </div>
                    {r.verdict && (
                      <div className="project-card__field">
                        <dt>Verdict:</dt>
                        <dd>{r.verdict}</dd>
                      </div>
                    )}
                  </dl>
                  <div className="project-card__meta">
                    <span className={`project-card__status ${statusClass(r.status)}`}>{r.status}</span>
                    <span className="project-card__time">{timeAgo(r.inserted_at)}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>

      {showModal && orgId && (
        <ReviewModal
          orgId={orgId}
          artifacts={artifacts}
          defaultProjectId={scopeProjectId}
          onClose={() => setShowModal(false)}
          onSaved={() => {
            setShowModal(false);
            fetchData();
          }}
        />
      )}

      {!loading && reviews.length > 0 && (
        <button className="fab" onClick={() => setShowModal(true)} aria-label="New review" title="New review">
          <PlusIcon />
        </button>
      )}
    </div>
  );
}
