'use client';

/**
 * Tool-Sets admin section (N4a §4.2) — extracted from the scopes page (WP5 of
 * the MCP UX cleanup) onto its own route, /app/admin/tool-sets.
 *
 * Built-in profiles (read-only, cloneable) beside the org's durable tool sets;
 * New / Edit / Clone / Deactivate / Re-activate flows. Editing happens on the
 * kind=tool-set config page (/app/admin/mcp-config/tool-set/:slug). States:
 * no-org, loading, inline error (with retry), and the org-sets empty state.
 */
import { useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import { ConfirmDialog } from '@/components/kit';
import {
  cloneToolSet,
  deactivateToolSet,
  listToolSets,
  updateToolSet,
  type ToolSetIndex,
} from '@/lib/acl-api';
import { useOrg } from '@/context/org';

function shapeBadge(shape: string) {
  return (
    <span
      style={{
        fontSize: 10,
        textTransform: 'uppercase',
        letterSpacing: 0.5,
        border: '1px solid var(--border)',
        borderRadius: 999,
        padding: '1px 8px',
        color: 'var(--text-2)',
      }}
    >
      {shape}
    </span>
  );
}

/** Row shell shared with the scopes page rows (sg-* visual language). */
function rowStyle(): React.CSSProperties {
  return {
    display: 'flex',
    alignItems: 'center',
    gap: 12,
    padding: '8px 10px',
    borderRadius: 10,
    border: '1px solid var(--border)',
    background: 'var(--bg-3)',
  };
}

export function ToolSetsSection() {
  const router = useRouter();
  const { currentOrg, organizations, switchOrg } = useOrg();
  const orgId = currentOrg?.id ?? null;
  const [index, setIndex] = useState<ToolSetIndex | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  // WP5: deactivation goes through ConfirmDialog (slug pending confirmation).
  const [pendingDeactivate, setPendingDeactivate] = useState<string | null>(null);

  const load = useCallback(async () => {
    if (!orgId) return;
    setLoading(true);
    setError(null);
    try {
      setIndex(await listToolSets(orgId));
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load tool sets');
    } finally {
      setLoading(false);
    }
  }, [orgId]);

  useEffect(() => {
    void load();
  }, [load]);

  async function clone(source: string) {
    if (!orgId) return;
    try {
      const created = await cloneToolSet(orgId, source);
      toast.success(`Cloned to "${created.slug}"`);
      router.push(`/app/admin/mcp-config/tool-set/${encodeURIComponent(created.slug)}`);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Clone failed');
    }
  }

  /** ConfirmDialog onConfirm — rethrows so the dialog stays open for retry. */
  async function deactivate(slug: string) {
    if (!orgId) return;
    try {
      await deactivateToolSet(orgId, slug);
      toast.success(`Tool set "${slug}" deactivated`);
      void load();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Deactivate failed');
      throw e;
    }
  }

  async function reactivate(slug: string) {
    if (!orgId) return;
    try {
      await updateToolSet(orgId, slug, { is_active: true });
      toast.success(`Tool set "${slug}" re-activated`);
      void load();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Re-activate failed');
    }
  }

  const pendingSet = index?.sets.find((s) => s.slug === pendingDeactivate) ?? null;

  return (
    <section className="dash-panel">
      <div className="dash-panel__head">
        <h2 className="dash-panel__title">
          Tool Sets
          {organizations.length > 1 && (
            <select
              aria-label="Organization"
              value={orgId ?? ''}
              onChange={(e) => switchOrg(e.target.value)}
              style={{ marginLeft: 10, fontSize: 12 }}
            >
              {organizations.map((o) => (
                <option key={o.id} value={o.id}>
                  {o.name ?? o.slug}
                </option>
              ))}
            </select>
          )}
        </h2>
        <Link className="sg-btn sg-btn--outline sg-btn--sm" href="/app/admin/mcp-config/tool-set/new">
          New tool set
        </Link>
      </div>
      <p className="sg-page-intro">
        Built-in capability profiles are read-only — clone one to customize. Org tool sets drive the
        serving path once the tool-set gateway lands.
      </p>

      {!orgId ? (
        <p className="sg-page-intro">Select an organization to manage tool sets.</p>
      ) : loading && !index ? (
        <p className="sg-page-intro">Loading…</p>
      ) : error && !index ? (
        <div className="sg-error sg-error--block" role="alert">
          <p style={{ margin: '0 0 0.5rem' }}>{error}</p>
          <button type="button" className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => void load()}>
            Retry
          </button>
        </div>
      ) : (
        <>
          <h3 style={{ margin: '0.75rem 0 0.5rem', fontSize: 12, fontWeight: 700, color: 'var(--text-2)' }}>
            Built-in profiles
          </h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            {(index?.profiles ?? []).map((p) => (
              <div key={p.slug} style={rowStyle()}>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 13, fontWeight: 600 }}>
                    {p.display_name} <span className="font-mono" style={{ fontSize: 11, color: 'var(--text-3)' }}>{p.slug}</span>
                  </div>
                  <div style={{ fontSize: 11, color: 'var(--text-2)' }}>{p.description}</div>
                </div>
                <span className="dash-badge">{p.group_count} groups</span>
                <span className="dash-badge">{p.tool_count} tools</span>
                <button type="button" className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => clone(p.slug)}>
                  Clone
                </button>
              </div>
            ))}
          </div>

          <h3 style={{ margin: '1rem 0 0.5rem', fontSize: 12, fontWeight: 700, color: 'var(--text-2)' }}>
            Org tool sets
          </h3>
          {(index?.sets ?? []).length === 0 ? (
            <p className="sg-page-intro">No tool sets yet — clone a profile or create a new one.</p>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
              {(index?.sets ?? []).map((s) => (
                <div key={s.id} style={{ ...rowStyle(), background: 'transparent', opacity: s.is_active ? 1 : 0.6 }}>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontSize: 13, fontWeight: 600 }}>
                      {s.display_name}
                      <span className="font-mono" style={{ fontSize: 11, color: 'var(--text-3)', marginLeft: 6 }}>{s.slug}</span>
                      {!s.is_active && (
                        <span style={{ fontSize: 10, color: 'var(--text-3)', marginLeft: 6 }}>(deactivated)</span>
                      )}
                    </div>
                    <div style={{ fontSize: 11, color: 'var(--text-2)' }}>
                      {s.source === 'clone' && s.source_profile ? `clone of ${s.source_profile}` : s.source}
                      {s.member_count !== null ? ` · ${s.member_count} members` : ''}
                    </div>
                  </div>
                  {shapeBadge(s.shape)}
                  {s.config_digest && (
                    <span className="font-mono" style={{ fontSize: 10, color: 'var(--text-3)' }} title="config digest">
                      {s.config_digest.slice(0, 8)}
                    </span>
                  )}
                  <Link
                    className="sg-btn sg-btn--outline sg-btn--sm"
                    href={`/app/admin/mcp-config/tool-set/${encodeURIComponent(s.slug)}`}
                  >
                    Edit
                  </Link>
                  <button type="button" className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => clone(s.slug)}>
                    Clone
                  </button>
                  {s.is_active ? (
                    <button type="button" className="sg-btn sg-btn--danger sg-btn--sm" onClick={() => setPendingDeactivate(s.slug)}>
                      Deactivate
                    </button>
                  ) : (
                    <button type="button" className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => reactivate(s.slug)}>
                      Re-activate
                    </button>
                  )}
                </div>
              ))}
            </div>
          )}
        </>
      )}

      <ConfirmDialog
        open={!!pendingDeactivate}
        onClose={() => setPendingDeactivate(null)}
        title={`Deactivate "${pendingSet?.display_name ?? pendingDeactivate}"?`}
        destructive
        confirmLabel="Deactivate"
        onConfirm={() => (pendingDeactivate ? deactivate(pendingDeactivate) : Promise.resolve())}
      >
        Deactivated sets are hidden from the serving path.
      </ConfirmDialog>
    </section>
  );
}

export default ToolSetsSection;
