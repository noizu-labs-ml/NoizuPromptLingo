'use client';

import { useState, useEffect, useCallback } from 'react';
import Link from 'next/link';
import { toast } from 'sonner';
import {
  api,
  type MediaProviderRegistryEntry,
  type MediaProviderConfig,
} from '@/lib/api';
import { useOrg } from '@/context/org';

function ConfigModal({
  orgId,
  entry,
  existing,
  onClose,
  onSaved,
}: {
  orgId: string;
  entry: MediaProviderRegistryEntry;
  existing?: MediaProviderConfig | null;
  onClose: () => void;
  onSaved: () => void;
}) {
  const [enabled, setEnabled] = useState(existing?.enabled ?? true);
  const [apiKey, setApiKey] = useState('');
  const [endpoint, setEndpoint] = useState(existing?.endpoint ?? '');
  const [defaultModel, setDefaultModel] = useState(existing?.default_model ?? '');
  const [settings, setSettings] = useState(
    existing?.settings ? JSON.stringify(existing.settings, null, 2) : '',
  );
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const editing = !!existing;

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    setError(null);

    let parsedSettings: Record<string, unknown> | undefined;
    if (settings.trim()) {
      try {
        parsedSettings = JSON.parse(settings);
      } catch {
        setError('Settings must be valid JSON.');
        setSaving(false);
        return;
      }
    }

    try {
      const payload = {
        provider: entry.slug,
        modality: entry.modality,
        enabled,
        api_key: apiKey.trim() || undefined,
        endpoint: endpoint.trim() || null,
        default_model: defaultModel.trim() || null,
        settings: parsedSettings,
      };
      if (editing) {
        await api.adminUpdateMediaProvider(orgId, existing!.id, payload);
        toast.success('Provider config updated');
      } else {
        await api.adminCreateMediaProvider(orgId, payload);
        toast.success('Provider configured');
      }
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
        <h2 className="modal-title">{entry.label}</h2>
        <p className="sg-field__hint" style={{ marginTop: '-0.25rem', marginBottom: '0.75rem' }}>
          Modality: {entry.modality} · reads <code>{entry.env_var}</code> when no key is set below
          ({entry.env_key_set ? 'server key present' : 'server key NOT set'}).
        </p>
        <form onSubmit={handleSubmit}>
          <div className="sg-field sg-field--inline">
            <input id="mp-enabled" type="checkbox" checked={enabled} onChange={(e) => setEnabled(e.target.checked)} />
            <label htmlFor="mp-enabled">Enabled for this org</label>
          </div>
          <div className="sg-field">
            <label htmlFor="mp-key">API key</label>
            <input
              id="mp-key"
              type="password"
              value={apiKey}
              onChange={(e) => setApiKey(e.target.value)}
              placeholder={existing?.api_key_set ? 'Stored — leave blank to keep current' : 'Leave blank to use the server env key'}
              autoComplete="off"
            />
            <span className="sg-field__hint">Stored per org; never shown again after saving.</span>
          </div>
          <div className="sg-field">
            <label htmlFor="mp-model">Default model</label>
            <input id="mp-model" value={defaultModel ?? ''} onChange={(e) => setDefaultModel(e.target.value)} placeholder="e.g. gpt-image-1 (optional)" />
          </div>
          <div className="sg-field">
            <label htmlFor="mp-endpoint">Endpoint URL</label>
            <input id="mp-endpoint" value={endpoint ?? ''} onChange={(e) => setEndpoint(e.target.value)} placeholder="Optional (best-effort; most providers use config base URL)" />
          </div>
          <div className="sg-field">
            <label htmlFor="mp-settings">Settings (JSON)</label>
            <textarea
              id="mp-settings"
              value={settings}
              onChange={(e) => setSettings(e.target.value)}
              rows={4}
              placeholder='{ "size": "1024x1024", "quality": "high" }'
              style={{ fontFamily: 'monospace', fontSize: '0.8125rem' }}
            />
            <span className="sg-field__hint">Provider-interpreted knobs merged into each request.</span>
          </div>
          {error && <div className="sg-error">{error}</div>}
          <div className="modal-actions">
            <button type="button" className="sg-btn sg-btn--outline" onClick={onClose}>Cancel</button>
            <button type="submit" className="sg-btn sg-btn--black" disabled={saving}>
              {saving ? 'Saving…' : editing ? 'Save' : 'Configure'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default function AdminMediaProvidersPage() {
  const { organizations, currentOrg } = useOrg();
  const [orgId, setOrgId] = useState<string>(currentOrg?.id ?? organizations[0]?.id ?? '');
  const [registry, setRegistry] = useState<MediaProviderRegistryEntry[]>([]);
  const [configs, setConfigs] = useState<MediaProviderConfig[]>([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState<{ entry: MediaProviderRegistryEntry; existing: MediaProviderConfig | null } | null>(null);

  useEffect(() => {
    if (!orgId) setOrgId(currentOrg?.id ?? organizations[0]?.id ?? '');
  }, [currentOrg?.id, organizations, orgId]);

  const fetchData = useCallback(async () => {
    if (!orgId) {
      setLoading(false);
      return;
    }
    setLoading(true);
    try {
      const data = await api.adminListMediaProviders(orgId);
      setRegistry(data.registry ?? []);
      setConfigs(data.configs ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load media providers');
    } finally {
      setLoading(false);
    }
  }, [orgId]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  function configFor(slug: string) {
    return configs.find((c) => c.provider === slug) ?? null;
  }

  async function reset(cfg: MediaProviderConfig) {
    if (!confirm('Remove this org override and fall back to server defaults?')) return;
    try {
      await api.adminDeleteMediaProvider(orgId, cfg.id);
      toast.success('Reset to defaults');
      setConfigs((prev) => prev.filter((c) => c.id !== cfg.id));
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Request failed');
    }
  }

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">Media Providers</h1>
        </div>
        <p className="sg-page-intro">
          Per-org overrides (API key, model, settings, on/off) for the registered media
          generation providers used by asset generation. Without an override, generation uses the
          server&apos;s environment keys.{' '}
          <Link href="/app/admin">← Back to Admin</Link>
        </p>

        <div className="sg-field" style={{ maxWidth: 360 }}>
          <label htmlFor="mp-org">Organization</label>
          <select id="mp-org" value={orgId} onChange={(e) => setOrgId(e.target.value)}>
            {organizations.map((o) => (
              <option key={o.id} value={o.id}>{o.name}</option>
            ))}
          </select>
        </div>

        {loading ? (
          <p className="sg-page-intro">Loading…</p>
        ) : registry.length === 0 ? (
          <p className="sg-page-intro">No media providers registered.</p>
        ) : (
          <table className="sg-table">
            <thead>
              <tr>
                <th>Provider</th>
                <th>Modality</th>
                <th>Server key</th>
                <th>Org override</th>
                <th>Model</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {registry.map((p) => {
                const cfg = configFor(p.slug);
                return (
                  <tr key={p.slug}>
                    <td>{p.label}</td>
                    <td>{p.modality}</td>
                    <td>{p.env_key_set ? '✓ set' : '— not set'}</td>
                    <td>
                      {cfg
                        ? `${cfg.enabled ? 'on' : 'off'}${cfg.api_key_set ? ' · key' : ''}`
                        : '—'}
                    </td>
                    <td className="font-mono">{cfg?.default_model || 'default'}</td>
                    <td>
                      <button className="sg-btn sg-btn--outline" onClick={() => setModal({ entry: p, existing: cfg })}>
                        {cfg ? 'Edit' : 'Configure'}
                      </button>
                      {cfg && (
                        <>
                          {' '}
                          <button className="sg-btn sg-btn--outline" onClick={() => reset(cfg)}>Reset</button>
                        </>
                      )}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </main>

      {modal && orgId && (
        <ConfigModal
          orgId={orgId}
          entry={modal.entry}
          existing={modal.existing}
          onClose={() => setModal(null)}
          onSaved={() => { setModal(null); fetchData(); }}
        />
      )}
    </div>
  );
}
