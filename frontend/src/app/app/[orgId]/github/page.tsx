'use client';

import { useState, useEffect, useCallback } from 'react';
import Link from 'next/link';
import { toast } from 'sonner';
import { api, type GithubRepoSummary, type GithubPullRequest, type GithubIssue } from '@/lib/api';
import { useOrgId } from '@/context/org';

interface RepoSummary extends GithubRepoSummary {
  openPulls: number;
  openIssues: number;
}

function normalizeList<T>(res: { items: T[] } | T[] | undefined | null): T[] {
  if (!res) return [];
  return Array.isArray(res) ? res : res.items ?? [];
}

export default function GithubReposPage() {
  const { orgId, slug, loading: orgLoading } = useOrgId();
  const [repos, setRepos] = useState<RepoSummary[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchData = useCallback(async () => {
    if (!orgId) return;
    try {
      const data = await api.listGithubRepos(orgId);
      const baseRepos = data.repos ?? [];

      const enriched = await Promise.all(
        baseRepos.map(async (repo) => {
          const [pulls, issues] = await Promise.allSettled([
            api.listGithubPulls(orgId, repo.id, { state: "open", per_page: 1 }),
            api.listGithubIssues(orgId, repo.id, { state: "open", per_page: 1 }),
          ]);
          return {
            ...repo,
            openPulls: pulls.status === "fulfilled" ? normalizeList<GithubPullRequest>(pulls.value).length : 0,
            openIssues: issues.status === "fulfilled" ? normalizeList<GithubIssue>(issues.value).length : 0,
          };
        }),
      );
      setRepos(enriched);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load repositories');
    } finally {
      setLoading(false);
    }
  }, [orgId]);

  useEffect(() => {
    if (orgId) {
      fetchData();
    } else if (!orgLoading) {
      setLoading(false);
    }
  }, [fetchData, orgId, orgLoading]);

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">GitHub Repositories</h1>
        </div>
        <p className="sg-page-intro">
          Repositories mapped to this organization. Access is governed per-repo ACL and group grants.
        </p>

        {loading ? (
          <p className="sg-page-intro">Loading…</p>
        ) : repos.length === 0 ? (
          <div className="projects-empty">
            <p className="projects-empty__text">
              No repositories available. An admin must map repos and tokens first.
            </p>
          </div>
        ) : (
          <div className="projects-grid">
            {repos.map((repo) => (
              <Link
                key={repo.id}
                href={`/app/${slug}/github/${repo.id}`}
                className="project-card"
              >
                <div className="project-card__header">
                  <div className="project-card__name">{repo.repo_full_name}</div>
                </div>
                <div className="project-card__body">
                  <dl className="project-card__fields">
                    <div className="project-card__field">
                      <dt>ACL:</dt>
                      <dd>{repo.default_acl}</dd>
                    </div>
                    <div className="project-card__field">
                      <dt>Open PRs:</dt>
                      <dd>{repo.openPulls}</dd>
                    </div>
                    <div className="project-card__field">
                      <dt>Open Issues:</dt>
                      <dd>{repo.openIssues}</dd>
                    </div>
                  </dl>
                  <div className="project-card__meta">
                    <span className="project-card__status">{repo.token_preview ? 'token mapped' : 'no token'}</span>
                  </div>
                </div>
              </Link>
            ))}
          </div>
        )}
      </main>
    </div>
  );
}