'use client';

import { useState, useEffect, useCallback } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { toast } from 'sonner';
import { api, type GithubPullRequest, type GithubComment } from '@/lib/api';
import { useOrgId } from '@/context/org';

function normalizeList<T>(res: { items: T[] } | T[] | undefined | null): T[] {
  if (!res) return [];
  return Array.isArray(res) ? res : res.items ?? [];
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

export default function GithubPullPage() {
  const params = useParams<{ orgId: string; repoId: string; pullNumber: string }>();
  const { slug, orgId, loading: orgLoading } = useOrgId();
  const repoId = params?.repoId;
  const pullNumber = params?.pullNumber ? parseInt(params.pullNumber, 10) : NaN;

  const [pull, setPull] = useState<GithubPullRequest | null>(null);
  const [comments, setComments] = useState<GithubComment[]>([]);
  const [loading, setLoading] = useState(true);
  const [commentBody, setCommentBody] = useState('');
  const [posting, setPosting] = useState(false);

  const fetchData = useCallback(async () => {
    if (!orgId || !repoId || Number.isNaN(pullNumber)) return;
    try {
      const [pr, commentsRes] = await Promise.all([
        api.getGithubPull(orgId, repoId, pullNumber),
        api.listGithubPullComments(orgId, repoId, pullNumber).then(normalizeList).catch(() => []),
      ]);
      setPull(pr);
      setComments(commentsRes as GithubComment[]);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load pull request');
    } finally {
      setLoading(false);
    }
  }, [orgId, repoId, pullNumber]);

  useEffect(() => {
    if (orgId && repoId && !Number.isNaN(pullNumber)) {
      fetchData();
    } else if (!orgLoading) {
      setLoading(false);
    }
  }, [fetchData, orgId, repoId, pullNumber, orgLoading]);

  async function postComment(e: React.FormEvent) {
    e.preventDefault();
    if (!orgId || !repoId || Number.isNaN(pullNumber) || !commentBody.trim()) return;
    setPosting(true);
    try {
      const created = await api.createGithubPullComment(orgId, repoId, pullNumber, commentBody.trim());
      setComments((prev) => [...prev, created]);
      setCommentBody('');
      toast.success('Comment added');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to add comment');
    } finally {
      setPosting(false);
    }
  }

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">
            {pull ? `#${pull.number} ${pull.title}` : 'Pull Request'}
          </h1>
        </div>
        <p className="sg-page-intro">
          <Link href={slug ? `/app/${slug}/github/${repoId}` : '/app'} className="sg-link">
            ← Back to repository
          </Link>
        </p>

        {loading ? (
          <p className="sg-page-intro">Loading…</p>
        ) : !pull ? (
          <div className="projects-empty">
            <p className="projects-empty__text">Pull request not found or no access.</p>
          </div>
        ) : (
          <>
            <div className="project-card">
              <div className="project-card__body">
                <dl className="project-card__fields">
                  <div className="project-card__field">
                    <dt>State:</dt>
                    <dd>{pull.state}</dd>
                  </div>
                  <div className="project-card__field">
                    <dt>Author:</dt>
                    <dd>{pull.user?.login ?? '—'}</dd>
                  </div>
                  <div className="project-card__field">
                    <dt>Branch:</dt>
                    <dd>{pull.head?.ref ?? '—'} → {pull.base?.ref ?? '—'}</dd>
                  </div>
                  <div className="project-card__field">
                    <dt>Updated:</dt>
                    <dd>{timeAgo(pull.updated_at)}</dd>
                  </div>
                </dl>
                {pull.body && (
                  <div className="project-card__meta" style={{ marginTop: '0.75rem' }}>
                    <pre style={{ whiteSpace: 'pre-wrap', margin: 0, fontFamily: 'inherit' }}>{pull.body}</pre>
                  </div>
                )}
              </div>
            </div>

            <h2 className="sg-page-title" style={{ fontSize: '1.25rem', marginTop: '2rem' }}>
              Comments ({comments.length})
            </h2>

            <form className="sg-field" onSubmit={postComment} style={{ maxWidth: 'none' }}>
              <label htmlFor="pr-comment">Add a comment</label>
              <textarea
                id="pr-comment"
                value={commentBody}
                onChange={(e) => setCommentBody(e.target.value)}
                placeholder="Leave a comment"
                rows={4}
              />
              <div className="modal-actions">
                <button
                  type="submit"
                  className="sg-btn sg-btn--black"
                  disabled={!commentBody.trim() || posting}
                >
                  {posting ? 'Posting…' : 'Comment'}
                </button>
              </div>
            </form>

            <div className="projects-grid" style={{ marginTop: '1rem' }}>
              {comments.length === 0 ? (
                <p className="projects-empty__text">No comments yet.</p>
              ) : (
                comments.map((c) => (
                  <div key={c.id} className="project-card">
                    <div className="project-card__header">
                      <div className="project-card__name">{c.user?.login ?? '—'}</div>
                    </div>
                    <div className="project-card__body">
                      <div className="project-card__meta">
                        <span className="project-card__time">{timeAgo(c.created_at)}</span>
                      </div>
                      <pre style={{ whiteSpace: 'pre-wrap', margin: '0.5rem 0 0', fontFamily: 'inherit' }}>{c.body}</pre>
                    </div>
                  </div>
                ))
              )}
            </div>
          </>
        )}
      </main>
    </div>
  );
}