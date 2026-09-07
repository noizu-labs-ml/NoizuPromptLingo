'use client';

import { useEffect, useMemo, useState } from 'react';
import { toast } from 'sonner';
import {
  api,
  type McpCustomGroup,
  type McpCustomScope,
} from '@/lib/api';
import McpIncludeEditor from '@/components/mcp-include-editor';
import EndpointWizard from '@/components/mcp-config/endpoint-wizard';
import McpEndpointList from '@/components/mcp-endpoint-list';
import { ConfirmDialog, CopyField } from '@/components/kit';
import type { WizardSource } from '@/components/mcp-config/endpoint-wizard-state';

interface McpEndpointManagerProps {
  templates: McpCustomScope[];
  endpoints: McpCustomScope[];
  selected: McpCustomScope | null;
  catalog: McpCustomGroup[];
  onSelect: (scope: McpCustomScope) => void;
  onChange: (next: { templates: McpCustomScope[]; endpoints: McpCustomScope[]; selected: McpCustomScope }) => void;
}

interface WizardSession {
  source: (WizardSource & { name: string; description: string }) | null;
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
  const [confirmDelete, setConfirmDelete] = useState(false);
  const [name, setName] = useState(selected?.name ?? '');
  // PRD-020 FR-4/FR-6: wizard entry points — null = closed; source = clone mode.
  const [wizard, setWizard] = useState<WizardSession | null>(null);

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

  // PRD-020 FR-4: Clone affordance (templates + own endpoints + org endpoints
  // where editable) opens the shared wizard prefilled from the source — name =
  // "Copy of <source.name>"; submit sends source_slug (templates) or source_id
  // (own) and the config carries over verbatim via MCPCustomScopes.copy/2.
  function openClone() {
    if (!current) return;
    const isTemplate = current.owner_kind === 'template' || (!current.user_id && !current.organization_id);
    setWizard({
      source: {
        id: isTemplate ? undefined : current.id,
        slug: current.slug,
        kind: isTemplate ? 'template' : 'own',
        name: `Copy of ${current.name}`,
        description: current.description ?? '',
      },
    });
  }

  function openWizard() {
    setWizard({ source: null });
  }

  async function wizardCreated(endpoint: McpCustomScope) {
    toast.success('Endpoint created');
    try {
      const res = await api.listMcpEndpoints();
      onChange({
        templates: res.templates ?? [],
        endpoints: res.endpoints ?? [],
        selected: endpoint,
      });
    } catch {
      // Refresh failed; still surface the new row locally.
      onChange({
        templates,
        endpoints: [endpoint, ...endpoints.filter((s) => s.id !== endpoint.id)],
        selected: endpoint,
      });
    }
    onSelect(endpoint);
    setName(endpoint.name);
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

      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 12 }}>
        <button type="button" className="sg-btn sg-btn--black sg-btn--sm" onClick={openWizard}>
          New endpoint (wizard)
        </button>
      </div>

      {/* Alacarte: visual picker (display thumb / emoji / color) replaces the
          native select; groupings + selection semantics unchanged. */}
      <McpEndpointList
        templates={templates}
        endpoints={endpoints}
        selectedId={current?.id ?? null}
        onSelect={(next) => {
          onSelect(next);
          setName(next.name);
        }}
      />

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

          <div style={{ marginBottom: 12 }}>
            <CopyField label="MCP URL" value={url} />
          </div>

          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 16 }}>
            <button type="button" className="sg-btn sg-btn--black sg-btn--sm" onClick={copyEndpoint} disabled={busy}>
              Save a copy
            </button>
            {/* FR-4: Clone affordance on templates and own/org-editable rows.
                Templates were previously a read-only dead end ("copy it to edit"). */}
            <button
              type="button"
              className="sg-btn sg-btn--outline sg-btn--sm"
              onClick={openClone}
              disabled={busy || (!!current && current.owner_kind === 'organization' && !editable)}
            >
              Clone to edit
            </button>
            {!current.is_default || current.owner_kind !== 'user' ? (
              <button type="button" className="sg-btn sg-btn--outline sg-btn--sm" onClick={useEndpoint} disabled={busy}>
                Use as my default
              </button>
            ) : null}
            {editable && !current.is_default ? (
              <button
                type="button"
                className="sg-btn sg-btn--danger sg-btn--sm"
                aria-label={`Delete copy ${current.name}`}
                onClick={() => setConfirmDelete(true)}
                disabled={busy}
              >
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

      <ConfirmDialog
        open={confirmDelete}
        onClose={() => setConfirmDelete(false)}
        title={`Delete ${current?.name ?? 'endpoint'}?`}
        destructive
        confirmLabel="Delete"
        onConfirm={remove}
      >
        Clients using this URL will stop seeing these tools.
      </ConfirmDialog>

      <EndpointWizard
        open={wizard !== null}
        catalog={catalog}
        cloneSource={wizard?.source ?? null}
        onClose={() => setWizard(null)}
        onCreated={wizardCreated}
      />
    </section>
  );
}
