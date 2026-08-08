'use client';

import { useState, useEffect, useCallback } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { toast } from 'sonner';
import { api, type GithubRepoSummary, type GithubPullRequest, type GithubIssue } from '@/lib/api';
import { useOrgId } from '@/context/org';

type Tab = 'pulls' | 'issues';

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

export default function GithubRepoPage() {
  const params = useParams<{ orgId: string; repoId: string }>();
  const { slug, orgId, loading: orgLoading } = useOrgId();
  const repoId = params?.repoId;

  const [tab, setTab] = useState<Tab>('pulls');
  const [repo, setRepo] = useState<GithubRepoSummary | null>(null);
  const [pulls, setPulls] = useState<GithubPullRequest[]>([]);
  const [issues, setIssues] = useState<GithubIssue[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchData = useCallback(async () => {
    if (!orgId || !repoId) return;
    try {
      const repoData = await api.listGithubRepos(orgId);
      const match = (repoData.repos ?? []).find((r) => r.id === repoId) ?? null;
      setRepo(match);

      const [pullsRes, issuesRes] = await Promise.allSettled([
        api.listGithubPulls(orgId, repoId, { state: 'open' }),
        api.listGithubIssues(orgId, repoId, { state: 'open' }),
      ]);
      setPulls(pullsRes.status === 'fulfilled' ? normalizeList<GithubPullRequest>(pullsRes.value) : []);
      setIssues(issuesRes.status === 'fulfilled' ? normalizeList<GithubIssue>(issuesRes.value) : []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load repository');
    } finally {
      setLoading(false);
    }
  }, [orgId, repoId]);

  useEffect(() => {
    if (orgId && repoId) {
      fetchData();
    } else if (!orgLoading) {
      setLoading(false);
    }
  }, [fetchData, orgId, repoId, orgLoading]);

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">{repo?.repo_full_name ?? 'Repository'}</h1>
        </div>
        <p className="sg-page-intro">
          <Link href={slug ? `/app/${slug}/github` : '/app'} className="sg-link">
            ← Back to repositories
          </Link>
        </p>

        {loading ? (
          <p className="sg-page-intro">Loading…</p>
        ) : !repo ? (
          <div className="projects-empty">
            <p className="projects-empty__text">Repository not found or no access.</p>
          </div>
        ) : (
          <>
            <div className="project-card">
              <div className="project-card__body">
                <dl className="project-card__fields">
                  <div className="project-card__field">
                    <dt>ACL:</dt>
                    <dd>{repo.default_acl}</dd>
                  </div>
                  <div className="project-card__field">
                    <dt>Open PRs:</dt>
                    <dd>{pulls.length}</dd>
                  </div>
                  <div className="project-card__field">
                    <dt>Open Issues:</dt>
                    <dd>{issues.length}</dd>
                  </div>
                </dl>
              </div>
            </div>

            <div className="projects-header" style={{ marginTop: '2rem' }}>
              <button
                className={`sg-btn ${tab === 'pulls' ? 'sg-btn--black' : 'sg-btn--outline'}`}
                onClick={() => setTab('pulls')}
              >
                Pull Requests ({pulls.length})
              </button>
              <button
                className={`sg-btn ${tab === 'issues' ? 'sg-btn--black' : 'sg-btn--outline'}`}
                onClick={() => setTab('issues')}
              >
                Issues ({issues.length})
              </button>
            </div>

            {tab === 'pulls' && (
              <div className="projects-grid">
                {pulls.length === 0 ? (
                  <p className="projects-empty__text">No open pull requests.</p>
                ) : (
                  pulls.map((pr) => (
                    <Link
                      key={pr.id}
                      href={`/app/${slug}/github/${repoId}/pulls/${pr.number}`}
                      className="project-card"
                    >
                      <div className="project-card__header">
                        <div className="project-card__name">
                          #{pr.number} {pr.title}
                        </div>
                      </div>
                      <div className="project-card__body">
                        <dl className="project-card__fields">
                          <div className="project-card__field">
                            <dt>Author:</dt>
                            <dd>{pr.user?.login ?? '—'}</dd>
                          </div>
                          <div className="project-card__field">
                            <dt>Branch:</dt>
                            <dd>{pr.head?.ref ?? '—'} → {pr.base?.ref ?? '—'}</dd>
                          </div>
                        </dl>
                        <div className="project-card__meta">
                          <span className="project-card__status">{pr.state}</span>
                          <span className="project-card__time">{timeAgo(pr.updated_at)}</span>
                        </div>
                      </div>
                    </Link>
                  ))
                )}
              </div>
            )}

            {tab === 'issues' && (
              <div className="projects-grid">
                {issues.length === 0 ? (
                  <p className="projects-empty__text">No open issues.</p>
                ) : (
                  issues.map((issue) => (
                    <Link
                      key={issue.id}
                      href={`/app/${slug}/github/${repoId}/issues/${issue.number}`}
                      className="project-card"
                    >
                      <div className="project-card__header">
                        <div className="project-card__name">
                          #{issue.number} {issue.title}
                        </div>
                      </div>
                      <div className="project-card__body">
                        <dl className="project-card__fields">
                          <div className="project-card__field">
                            <dt>Author:</dt>
                            <dd>{issue.user?.login ?? '—'}</dd>
                          </div>
                          <div className="project-card__field">
                            <dt>Labels:</dt>
                            <dd>{(issue.labels ?? []).map((l) => l.name).join(', ') || '—'}</dd>
                          </div>
                        </dl>
                        <div className="project-card__meta">
                          <span className="project-card__status">{issue.state}</span>
                          <span className="project-card__time">{timeAgo(issue.updated_at)}</span>
                        </div>
                      </div>
                    </Link>
                  ))
                )}
              </div>
            )}
          </>
        )}
      </main>
    </div>
  );
}