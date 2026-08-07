'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import { api, type Organization } from '@/lib/api';
import { useOrg, useOrgId } from '@/context/org';
import { OrgDeleteConfirm } from '@/components/org-dialogs';

export default function OrgSettingsPage() {
  const { orgId, slug: slugParam, loading: orgLoading } = useOrgId();
  const router = useRouter();
  const { organizations, refresh, switchOrg } = useOrg();

  const [org, setOrg] = useState<Organization | null>(null);
  const [name, setName] = useState('');
  const [slug, setSlug] = useState('');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [showDelete, setShowDelete] = useState(false);

  // Role comes from the membership list (list_user_organizations); match by slug.
  const role = organizations.find((o) => o.slug === slugParam)?.role;
  const isOwner = role === 'owner';

  useEffect(() => {
    if (!orgId) {
      if (!orgLoading) setLoading(false);
      return;
    }
    api
      .getOrganization(orgId)
      .then((res) => {
        setOrg(res.organization);
        setName(res.organization.name);
        setSlug(res.organization.slug);
      })
      .catch((err) => setError(err instanceof Error ? err.message : 'Failed to load organization'))
      .finally(() => setLoading(false));
  }, [orgId, orgLoading]);

  async function handleSave(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim() || !slug.trim() || !orgId) return;
    setSaving(true);
    setError(null);
    try {
      const res = await api.updateOrganization(orgId, { name: name.trim(), slug: slug.trim() });
      setOrg(res.organization);
      await refresh(orgId);
      switchOrg(orgId);
      toast.success('Organization updated');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to update organization');
    } finally {
      setSaving(false);
    }
  }

  if (loading) {
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
      <main style={{ maxWidth: 560 }}>
        <h1 className="sg-page-title">Organization Settings</h1>

        <section className="dash-panel" style={{ marginBottom: 'var(--space-4)' }}>
          <div className="dash-panel__head">
            <h2 className="dash-panel__title">MCP clients</h2>
          </div>
          <p className="sg-page-intro" style={{ marginBottom: 12 }}>
            Connect Claude.ai, ChatGPT, and CLI agents to Tobor Locker via OAuth (no static OAuth
            secret to copy). Legacy API keys live on the same page for older CLIs.
          </p>
          <Link className="sg-btn sg-btn--black sg-btn--sm" href="/app/mcp-keys">
            Open MCP client setup
          </Link>
        </section>

        <form onSubmit={handleSave}>
          <div className="sg-field">
            <label htmlFor="org-name">Name</label>
            <input id="org-name" value={name} onChange={(e) => setName(e.target.value)} />
          </div>
          <div className="sg-field">
            <label htmlFor="org-slug">Slug</label>
            <input id="org-slug" value={slug} onChange={(e) => setSlug(e.target.value)} />
            <span className="sg-field__hint">Lowercase letters, numbers, and hyphens. Used in URLs.</span>
          </div>
          {error && <div className="sg-error">{error}</div>}
          <button type="submit" className="sg-btn sg-btn--black" disabled={saving || !name.trim() || !slug.trim()}>
            {saving ? 'Saving…' : 'Save changes'}
          </button>
        </form>

        {isOwner && org && (
          <div className="danger-zone">
            <h2 className="danger-zone__title">Danger zone</h2>
            <div className="danger-zone__row">
              <div>
                <div className="danger-zone__label">Delete this organization</div>
                <div className="danger-zone__hint">Permanently removes the organization and all of its projects.</div>
              </div>
              <button className="sg-btn sg-btn--danger" onClick={() => setShowDelete(true)}>
                Delete
              </button>
            </div>
          </div>
        )}
      </main>

      {showDelete && org && (
        <OrgDeleteConfirm
          org={org}
          onClose={() => setShowDelete(false)}
          onDeleted={async () => {
            setShowDelete(false);
            await refresh();
            router.push('/app');
          }}
        />
      )}
    </div>
  );
}
