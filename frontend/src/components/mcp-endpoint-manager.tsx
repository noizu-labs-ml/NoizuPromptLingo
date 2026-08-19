'use client';

import { useEffect, useMemo, useState } from 'react';
import { toast } from 'sonner';
import {
  api,
  type McpCustomGroup,
  type McpCustomScope,
} from '@/lib/api';
import McpIncludeEditor from '@/components/mcp-include-editor';

interface McpEndpointManagerProps {
  templates: McpCustomScope[];
  endpoints: McpCustomScope[];
  selected: McpCustomScope | null;
  catalog: McpCustomGroup[];
  onSelect: (scope: McpCustomScope) => void;
  onChange: (next: { templates: McpCustomScope[]; endpoints: McpCustomScope[]; selected: McpCustomScope }) => void;
}

function ownerLabel(scope: McpCustomScope) {
  if (scope.owner_kind === 'template' || (!scope.user_id && !scope.organization_id)) {
    return 'Standard template';
  }
  if (scope.owner_kind === 'organization' || (scope.organization_id && !scope.user_id)) {
    return scope.is_default ? 'Organization default' : 'Organization copy';
  }
  return scope.is_default ? 'Your default' : 'Your copy';
}

export default function McpEndpointManager({
  templates,
  endpoints,
  selected,
  catalog,
  onSelect,
  onChange,
}: McpEndpointManagerProps) {
  const [busy, setBusy] = useState(false);
  const [copied, setCopied] = useState<string | null>(null);
  const [name, setName] = useState(selected?.name ?? '');

  useEffect(() => {
    setName(selected?.name ?? '');
  }, [selected?.id, selected?.name]);

  const all = useMemo(() => {
    const seen = new Set<string>();
    const rows: McpCustomScope[] = [];
    for (const row of [...endpoints, ...templates]) {
      if (!row?.id || seen.has(row.id)) continue;
      seen.add(row.id);
      rows.push(row);
    }
    return rows;
  }, [endpoints, templates]);

  const current = selected && all.find((s) => s.id === selected.id) ? selected : all[0] ?? null;
  const editable = !!current?.editable;
  const url = current?.url ?? '';

  async function copyText(text: string, id: string) {
    try {
      await navigator.clipboard.writeText(text);
      setCopied(id);
      setTimeout(() => setCopied(null), 2000);
      toast.success('Copied');
    } catch {
      toast.error('Copy failed — select and copy manually');
    }
  }

  function replaceScope(updated: McpCustomScope) {
    const nextTemplates = templates.map((s) => (s.id === updated.id ? { ...s, ...updated } : s));
    const inEndpoints = endpoints.some((s) => s.id === updated.id);
    const nextEndpoints = inEndpoints
      ? endpoints.map((s) => (s.id === updated.id ? { ...s, ...updated } : s))
      : updated.owner_kind === 'template'
        ? endpoints
        : [updated, ...endpoints];
    onChange({
      templates: nextTemplates,
      endpoints: nextEndpoints,
      selected: updated,
    });
    onSelect(updated);
    setName(updated.name);
  }

  async function copyEndpoint() {
    if (!current) return;
    setBusy(true);
    try {
      const res = await api.copyMcpEndpoint(current.id, {
        name: `${current.name} copy`,
      });
      replaceScope(res.endpoint);
      toast.success('Copied to your endpoints');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Copy failed');
    } finally {
      setBusy(false);
    }
  }

  async function useEndpoint() {
    if (!current) return;
    setBusy(true);
    try {
      const res = await api.useMcpEndpoint(current.id);
      const used = res.endpoint;
      const nextEndpoints = [
        used,
        ...endpoints
          .filter((s) => s.id !== used.id)
          .map((s) => (s.user_id && s.is_default ? { ...s, is_default: false } : s)),
      ];
      onChange({ templates, endpoints: nextEndpoints, selected: used });
      onSelect(used);
      toast.success('Now your default MCP endpoint');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Could not set default');
    } finally {
      setBusy(false);
    }
  }

  async function rename() {
    if (!current || !editable) return;
    const next = name.trim();
    if (!next || next === current.name) return;
    setBusy(true);
    try {
      const res = await api.updateMcpEndpoint(current.id, { name: next });
      replaceScope(res.endpoint);
      toast.success('Renamed');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Rename failed');
    } finally {
      setBusy(false);
    }
  }

  async function remove() {
    if (!current || !editable || current.is_default) return;
    if (!confirm(`Delete ${current.name}? Clients using this URL will stop seeing these tools.`)) return;
    setBusy(true);
    try {
      await api.deleteMcpEndpoint(current.id);
      const nextEndpoints = endpoints.filter((s) => s.id !== current.id);
      const next = nextEndpoints.find((s) => s.is_default) ?? nextEndpoints[0] ?? templates[0] ?? null;
      onChange({
        templates,
        endpoints: nextEndpoints,
        selected: next ?? current,
      });
      if (next) onSelect(next);
      toast.success('Endpoint deleted');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Delete failed');
    } finally {
      setBusy(false);
    }
  }

  return (
    <section className="dash-panel" style={{ marginTop: 'var(--space-4)' }}>
      <div className="dash-panel__head">
        <h2 className="dash-panel__title">Custom MCP endpoint</h2>
        <span className="dash-badge">tobor.locker</span>
      </div>
      <p className="sg-page-intro" style={{ marginBottom: 12 }}>
        Every account and organization gets a <strong>Tobor Locker</strong> endpoint
        cloned from the standard template. Choose one, edit what it includes, or
        copy it. Setup commands below use the selected URL.
      </p>

      <div className="sg-field" style={{ marginBottom: 12 }}>
        <label htmlFor="mcp-endpoint-select">Endpoint</label>
        <select
          id="mcp-endpoint-select"
          value={current?.id ?? ''}
          onChange={(e) => {
            const next = all.find((s) => s.id === e.target.value);
            if (!next) return;
            onSelect(next);
            setName(next.name);
          }}
        >
          {endpoints.length > 0 ? (
            <optgroup label="Your endpoints">
              {endpoints.filter((s) => s.owner_kind !== 'organization').map((s) => (
                <option key={s.id} value={s.id}>
                  {s.name}{s.is_default ? ' (default)' : ''} — /custom/{s.slug}/mcp
                </option>
              ))}
            </optgroup>
          ) : null}
          {endpoints.some((s) => s.owner_kind === 'organization') ? (
            <optgroup label="Organization">
              {endpoints.filter((s) => s.owner_kind === 'organization').map((s) => (
                <option key={s.id} value={s.id}>
                  {s.name} — /custom/{s.slug}/mcp
                </option>
              ))}
            </optgroup>
          ) : null}
          {templates.length > 0 ? (
            <optgroup label="Standard templates">
              {templates.map((s) => (
                <option key={s.id} value={s.id}>
                  {s.name}{s.slug === 'tobor' ? ' (standard)' : ''} — /custom/{s.slug}/mcp
                </option>
              ))}
            </optgroup>
          ) : null}
        </select>
      </div>

      {current ? (
        <>
          <div style={{ fontSize: 11, color: 'var(--text-3)', marginBottom: 10 }}>
            {ownerLabel(current)}
            {current.source_template_slug ? ` · from ${current.source_template_slug}` : ''}
          </div>

          {editable ? (
            <div className="gh-add-form" style={{ marginBottom: 12 }}>
              <input
                className="gh-add-form__input"
                value={name}
                onChange={(e) => setName(e.target.value)}
                aria-label="Endpoint name"
              />
              <button
                type="button"
                className="sg-btn sg-btn--outline sg-btn--sm"
                onClick={rename}
                disabled={busy || name.trim() === current.name}
              >
                Rename
              </button>
            </div>
          ) : null}

          <div className="authz-reveal" style={{ marginBottom: 12 }}>
            <div className="authz-reveal__label">MCP URL</div>
            <div className="authz-reveal__row">
              <code className="authz-reveal__key font-mono">{url}</code>
              <button
                type="button"
                className="sg-btn sg-btn--outline sg-btn--sm"
                onClick={() => copyText(url, 'url')}
              >
                {copied === 'url' ? 'Copied!' : 'Copy'}
              </button>
            </div>
          </div>

          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 16 }}>
            <button type="button" className="sg-btn sg-btn--black sg-btn--sm" onClick={copyEndpoint} disabled={busy}>
              Copy endpoint
            </button>
            {!current.is_default || current.owner_kind !== 'user' ? (
              <button type="button" className="sg-btn sg-btn--outline sg-btn--sm" onClick={useEndpoint} disabled={busy}>
                Use as my default
              </button>
            ) : null}
            {editable && !current.is_default ? (
              <button type="button" className="sg-btn sg-btn--danger sg-btn--sm" onClick={remove} disabled={busy}>
                Delete copy
              </button>
            ) : null}
          </div>

          {catalog.length > 0 ? (
            <McpIncludeEditor
              key={current.id}
              catalog={catalog}
              scope={current}
              readOnly={!editable}
              save={(config) => api.updateMcpEndpoint(current.id, { config }).then((r) => r.endpoint)}
              onSaved={replaceScope}
            />
          ) : null}
        </>
      ) : (
        <p className="sg-page-intro">Loading standard Tobor Locker endpoint…</p>
      )}
    </section>
  );
}
