'use client';

import { useState, useEffect, useMemo } from 'react';
import { toast } from 'sonner';
import {
  api,
  type GithubToken,
  type GithubRepo,
  type GithubRepoGrant,
  type RepoAcl,
  type RepoGrantLevel,
} from '@/lib/api';
import { useOrg } from '@/context/org';

const ACL_OPTIONS: { value: RepoAcl; label: string }[] = [
  { value: 'private', label: 'Private (group-only)' },
  { value: 'org_read', label: 'Org — read' },
  { value: 'org_write', label: 'Org — write' },
];

interface Group {
  id: string;
  name: string;
  display_name?: string | null;
}

export default function AdminGithubPage() {
  const { organizations, currentOrg } = useOrg();
  const [orgId, setOrgId] = useState<string>(currentOrg?.id ?? organizations[0]?.id ?? '');

  const [tokens, setTokens] = useState<GithubToken[]>([]);
  const [repos, setRepos] = useState<GithubRepo[]>([]);
  const [groups, setGroups] = useState<Group[]>([]);
  const [loading, setLoading] = useState(true);

  // New token form
  const [tokenLabel, setTokenLabel] = useState('');
  const [tokenValue, setTokenValue] = useState('');
  const [savingToken, setSavingToken] = useState(false);

  // New repo form
  const [repoName, setRepoName] = useState('');
  const [repoTokenId, setRepoTokenId] = useState<string>('');
  const [repoAcl, setRepoAcl] = useState<RepoAcl>('private');
  const [savingRepo, setSavingRepo] = useState(false);

  // Keep the selected org in sync with the org context.
  useEffect(() => {
    if (!orgId) setOrgId(currentOrg?.id ?? organizations[0]?.id ?? '');
  }, [currentOrg?.id, organizations, orgId]);

  useEffect(() => {
    if (!orgId) {
      setLoading(false);
      return;
    }
    setLoading(true);
    Promise.all([api.adminListGithubTokens(orgId), api.adminListGithubRepos(orgId), api.listGroups()])
      .then(([t, r, g]) => {
        setTokens(t.tokens);
        setRepos(r.repos);
        setGroups(g.groups ?? []);
      })
      .catch(() => toast.error('Failed to load GitHub config'))
      .finally(() => setLoading(false));
  }, [orgId]);

  async function addToken(e: React.FormEvent) {
    e.preventDefault();
    if (!orgId || !tokenLabel.trim() || !tokenValue.trim()) return;
    setSavingToken(true);
    try {
      const { token } = await api.adminCreateGithubToken(orgId, tokenLabel.trim(), tokenValue.trim());
      setTokens((prev) => [...prev, token].sort((a, b) => a.label.localeCompare(b.label)));
      setTokenLabel('');
      setTokenValue('');
      toast.success('Token added');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to add token');
    } finally {
      setSavingToken(false);
    }
  }

  async function removeToken(id: string) {
    if (!orgId || !confirm('Delete this token? Repos mapped to it will be unlinked.')) return;
    try {
      await api.adminDeleteGithubToken(orgId, id);
      setTokens((prev) => prev.filter((t) => t.id !== id));
      setRepos((prev) => prev.map((r) => (r.token_id === id ? { ...r, token_id: null, token_label: null } : r)));
      toast.success('Token deleted');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to delete token');
    }
  }

  async function addRepo(e: React.FormEvent) {
    e.preventDefault();
    if (!orgId || !repoName.trim()) return;
    setSavingRepo(true);
    try {
      const { repo } = await api.adminCreateGithubRepo(orgId, repoName.trim(), repoTokenId || null, repoAcl);
      setRepos((prev) => [...prev, repo].sort((a, b) => a.repo_full_name.localeCompare(b.repo_full_name)));
      setRepoName('');
      setRepoTokenId('');
      setRepoAcl('private');
      toast.success('Repo added');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to add repo');
    } finally {
      setSavingRepo(false);
    }
  }

  // Optimistically patch a repo field; revert on error.
  async function patchRepo(repoId: string, patch: Partial<GithubRepo>) {
    if (!orgId) return;
    const prev = repos.find((r) => r.id === repoId);
    if (!prev) return;
    setRepos((rs) => rs.map((r) => (r.id === repoId ? { ...r, ...patch } : r)));
    try {
      await api.adminUpdateGithubRepo(orgId, repoId, patch as { token_id?: string | null; default_acl?: RepoAcl });
    } catch (err) {
      setRepos((rs) => rs.map((r) => (r.id === repoId ? { ...r, ...prev } : r)));
      toast.error(err instanceof Error ? err.message : 'Failed to update repo');
    }
  }

  async function removeRepo(id: string) {
    if (!orgId || !confirm('Remove this repo?')) return;
    try {
      await api.adminDeleteGithubRepo(orgId, id);
      setRepos((prev) => prev.filter((r) => r.id !== id));
      toast.success('Repo removed');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to remove repo');
    }
  }

  const canEdit = useMemo(() => Boolean(orgId), [orgId]);

  if (loading && orgId) {
    return (
      <div className="content">
        <main>
          <p className="sg-page-intro">Loading…</p>
        </main>
      </div>
    );
  }

  return (
    <div className="content">
      <main>
        <h1 className="sg-page-title">GitHub Integration</h1>
        <p className="sg-page-intro">
          Manage raw GitHub tokens and the repos mapped to them. No GitHub API connection yet — paste tokens and repo names as text.
        </p>

        <div className="sg-field">
          <label htmlFor="gh-org">Organization</label>
          <select id="gh-org" value={orgId} onChange={(e) => setOrgId(e.target.value)}>
            {organizations.map((o) => (
              <option key={o.id} value={o.id}>
                {o.name} ({o.slug})
              </option>
            ))}
          </select>
        </div>

        {!canEdit ? (
          <p className="sg-page-intro">Select an organization to manage its GitHub config.</p>
        ) : (
          <div className="dash-grid" style={{ marginTop: 'var(--space-4)' }}>
            {/* Tokens */}
            <section className="dash-panel">
              <div className="dash-panel__head">
                <h2 className="dash-panel__title">Tokens</h2>
                <span className="dash-badge">{tokens.length}</span>
              </div>

              <form className="gh-add-form" onSubmit={addToken}>
                <input
                  className="gh-add-form__input"
                  value={tokenLabel}
                  onChange={(e) => setTokenLabel(e.target.value)}
                  placeholder="Label (e.g. ci-bot)"
                  aria-label="Token label"
                />
                <input
                  className="gh-add-form__input"
                  value={tokenValue}
                  onChange={(e) => setTokenValue(e.target.value)}
                  placeholder="ghp_… (raw token)"
                  aria-label="Token value"
                  autoComplete="off"
                />
                <button className="sg-btn sg-btn--black sg-btn--sm" type="submit" disabled={savingToken || !tokenLabel.trim() || !tokenValue.trim()}>
                  {savingToken ? 'Adding…' : 'Add token'}
                </button>
              </form>

              {tokens.length === 0 ? (
                <p className="sg-page-intro">No tokens yet.</p>
              ) : (
                <ul className="admin-table-wrap">
                  {tokens.map((t) => (
                    <li key={t.id} className="gh-row">
                      <div className="gh-row__main">
                        <div className="gh-row__title">{t.label}</div>
                        <div className="gh-row__sub font-mono">{t.token_preview}</div>
                      </div>
                      <button className="sg-btn sg-btn--danger sg-btn--sm" onClick={() => removeToken(t.id)}>
                        Delete
                      </button>
                    </li>
                  ))}
                </ul>
              )}
            </section>

            {/* Repos */}
            <section className="dash-panel">
              <div className="dash-panel__head">
                <h2 className="dash-panel__title">Repos</h2>
                <span className="dash-badge">{repos.length}</span>
              </div>

              <form className="gh-add-form" onSubmit={addRepo}>
                <input
                  className="gh-add-form__input"
                  value={repoName}
                  onChange={(e) => setRepoName(e.target.value)}
                  placeholder="owner/repo"
                  aria-label="Repo full name"
                />
                <select
                  className="gh-add-form__input"
                  value={repoTokenId}
                  onChange={(e) => setRepoTokenId(e.target.value)}
                  aria-label="Token"
                >
                  <option value="">— no token —</option>
                  {tokens.map((t) => (
                    <option key={t.id} value={t.id}>
                      {t.label}
                    </option>
                  ))}
                </select>
                <select
                  className="gh-add-form__input"
                  value={repoAcl}
                  onChange={(e) => setRepoAcl(e.target.value as RepoAcl)}
                  aria-label="Default ACL"
                >
                  {ACL_OPTIONS.map((o) => (
                    <option key={o.value} value={o.value}>
                      {o.label}
                    </option>
                  ))}
                </select>
                <button className="sg-btn sg-btn--black sg-btn--sm" type="submit" disabled={savingRepo || !repoName.trim()}>
                  {savingRepo ? 'Adding…' : 'Add repo'}
                </button>
              </form>

              {repos.length === 0 ? (
                <p className="sg-page-intro">No repos yet.</p>
              ) : (
                <ul className="admin-table-wrap">
                  {repos.map((r) => (
                    <RepoRow
                      key={r.id}
                      orgId={orgId}
                      repo={r}
                      tokens={tokens}
                      groups={groups}
                      onPatch={patchRepo}
                      onRemove={removeRepo}
                    />
                  ))}
                </ul>
              )}
            </section>
          </div>
        )}
      </main>
    </div>
  );
}

function RepoRow({
  orgId,
  repo,
  tokens,
  groups,
  onPatch,
  onRemove,
}: {
  orgId: string;
  repo: GithubRepo;
  tokens: GithubToken[];
  groups: Group[];
  onPatch: (repoId: string, patch: Partial<GithubRepo>) => void;
  onRemove: (id: string) => void;
}) {
  const [expanded, setExpanded] = useState(false);
  const [grants, setGrants] = useState<GithubRepoGrant[]>([]);
  const [grantGroup, setGrantGroup] = useState('');
  const [grantLevel, setGrantLevel] = useState<RepoGrantLevel>('read');
  const [loadingGrants, setLoadingGrants] = useState(false);

  async function loadGrants() {
    setLoadingGrants(true);
    try {
      const { grants: g } = await api.adminListGithubRepoGrants(orgId, repo.id);
      setGrants(g);
    } catch {
      toast.error('Failed to load grants');
    } finally {
      setLoadingGrants(false);
    }
  }

  async function toggleExpand() {
    const next = !expanded;
    setExpanded(next);
    if (next && grants.length === 0) await loadGrants();
  }

  async function addGrant(e: React.FormEvent) {
    e.preventDefault();
    if (!grantGroup) return;
    try {
      const { grants: g } = await api.adminGrantGithubRepoAccess(orgId, repo.id, grantGroup, grantLevel);
      setGrants(g);
      setGrantGroup('');
      setGrantLevel('read');
      toast.success('Group access granted');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to grant access');
    }
  }

  async function revokeGrant(grantId: string) {
    try {
      await api.adminRevokeGithubRepoAccess(orgId, repo.id, grantId);
      setGrants((prev) => prev.filter((g) => g.id !== grantId));
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to revoke access');
    }
  }

  return (
    <li className="gh-row gh-row--stacked">
      <div className="gh-row__main">
        <button className="gh-row__expand" onClick={toggleExpand} aria-label="Toggle ACL">
          {expanded ? '▾' : '▸'}
        </button>
        <div className="gh-row__title font-mono">{repo.repo_full_name}</div>
        <select
          className="admin-role-select"
          value={repo.token_id ?? ''}
          onChange={(e) => onPatch(repo.id, { token_id: e.target.value || null })}
        >
          <option value="">— no token —</option>
          {tokens.map((t) => (
            <option key={t.id} value={t.id}>
              {t.label}
            </option>
          ))}
        </select>
        <select
          className="admin-role-select"
          value={repo.default_acl}
          onChange={(e) => onPatch(repo.id, { default_acl: e.target.value as RepoAcl })}
          aria-label="Default ACL"
        >
          {ACL_OPTIONS.map((o) => (
            <option key={o.value} value={o.value}>
              {o.label}
            </option>
          ))}
        </select>
        <button className="sg-btn sg-btn--danger sg-btn--sm" onClick={() => onRemove(repo.id)}>
          Remove
        </button>
      </div>

      {expanded && (
        <div className="gh-grants">
          <div className="gh-grants__head">Group access grants</div>
          {loadingGrants ? (
            <p className="sg-page-intro">Loading…</p>
          ) : (
            <>
              {grants.length === 0 ? (
                <p className="sg-page-intro">No group grants — only the default ACL applies.</p>
              ) : (
                <ul className="gh-grants__list">
                  {grants.map((g) => (
                    <li key={g.id} className="gh-grant">
                      <span className="gh-grant__group">{g.display_name || g.group_name}</span>
                      <span className={`gh-grant__level gh-grant__level--${g.group_name}`}>{g.group_name === 'viewer' ? 'read' : 'write'}</span>
                      <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => revokeGrant(g.id)}>
                        Revoke
                      </button>
                    </li>
                  ))}
                </ul>
              )}

              <form className="gh-add-form" onSubmit={addGrant}>
                <select className="gh-add-form__input" value={grantGroup} onChange={(e) => setGrantGroup(e.target.value)} aria-label="Group">
                  <option value="">— select group —</option>
                  {groups.map((g) => (
                    <option key={g.id} value={g.id}>
                      {g.display_name || g.name}
                    </option>
                  ))}
                </select>
                <select
                  className="gh-add-form__input"
                  value={grantLevel}
                  onChange={(e) => setGrantLevel(e.target.value as RepoGrantLevel)}
                  aria-label="Level"
                >
                  <option value="read">read</option>
                  <option value="write">write</option>
                </select>
                <button className="sg-btn sg-btn--black sg-btn--sm" type="submit" disabled={!grantGroup}>
                  Grant
                </button>
              </form>
              <p className="sg-page-intro">
                read = read PRs, comment on PRs, read code · write = create/edit PRs, edit code
              </p>
            </>
          )}
        </div>
      )}
    </li>
  );
}
