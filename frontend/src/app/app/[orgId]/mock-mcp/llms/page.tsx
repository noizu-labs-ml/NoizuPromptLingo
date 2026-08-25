'use client';

import { useState, useEffect, useCallback } from 'react';
import Link from 'next/link';
import { toast } from 'sonner';
import { PlusIcon } from '@heroicons/react/24/outline';
import { api, type MockMCPLLM, type MockMCPModel } from '@/lib/api';
import { useOrgId } from '@/context/org';

function LlmModal({
  orgId,
  models,
  existing,
  onClose,
  onSaved,
}: {
  orgId: string;
  models: MockMCPModel[];
  existing?: MockMCPLLM | null;
  onClose: () => void;
  onSaved: () => void;
}) {
  const [label, setLabel] = useState(existing?.label ?? '');
  const [provider, setProvider] = useState(existing?.provider ?? 'openai');
  const [model, setModel] = useState(existing?.model ?? '');
  const [endpoint, setEndpoint] = useState(existing?.endpoint ?? '');
  const [apiKey, setApiKey] = useState('');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const editing = !!existing;

  function applyQuickPick(id: string) {
    const m = models.find((x) => x.id === id);
    if (m) {
      setProvider(m.provider);
      setModel(m.model);
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!label.trim() || !provider.trim() || !model.trim()) return;
    setSaving(true);
    setError(null);
    try {
      const payload = {
        label: label.trim(),
        provider: provider.trim(),
        model: model.trim(),
        endpoint: endpoint.trim() || undefined,
        api_key: apiKey.trim() || undefined,
      };
      if (editing) {
        await api.updateMockMcpLlm(orgId, existing!.id, payload);
        toast.success('LLM connection updated');
      } else {
        await api.createMockMcpLlm(orgId, payload);
        toast.success('LLM connection created');
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
        <h2 className="modal-title">{editing ? 'Edit LLM connection' : 'New LLM connection'}</h2>
        <form onSubmit={handleSubmit}>
          <div className="sg-field">
            <label htmlFor="llm-label">Label</label>
            <input
              id="llm-label"
              value={label}
              onChange={(e) => setLabel(e.target.value)}
              placeholder="OpenAI prod, Local LM Studio…"
              autoFocus
            />
          </div>
          <div className="sg-field">
            <label htmlFor="llm-quickpick">Quick pick</label>
            <select id="llm-quickpick" defaultValue="" onChange={(e) => applyQuickPick(e.target.value)}>
              <option value="">Choose a known provider/model…</option>
              {models.map((m) => (
                <option key={m.id} value={m.id}>
                  {m.label}
                </option>
              ))}
            </select>
            <span className="sg-field__hint">Fills provider + model below. You can override them.</span>
          </div>
          <div className="sg-field">
            <label htmlFor="llm-provider">Provider</label>
            <input
              id="llm-provider"
              value={provider}
              onChange={(e) => setProvider(e.target.value)}
              placeholder="openai, anthropic, or any OpenAI-compatible"
            />
            <span className="sg-field__hint">
              Auth style follows the provider (Bearer; anthropic uses x-api-key).
            </span>
          </div>
          <div className="sg-field">
            <label htmlFor="llm-model">Model</label>
            <input
              id="llm-model"
              value={model}
              onChange={(e) => setModel(e.target.value)}
              placeholder="gpt-4o-mini, claude-sonnet-4-6, llama-3.1-70b…"
            />
          </div>
          <div className="sg-field">
            <label htmlFor="llm-endpoint">Endpoint URL</label>
            <input
              id="llm-endpoint"
              value={endpoint}
              onChange={(e) => setEndpoint(e.target.value)}
              placeholder="https://host/v1/chat/completions (LM Studio, OpenRouter, vLLM…)"
            />
            <span className="sg-field__hint">Optional. Leave blank to use the provider default.</span>
          </div>
          <div className="sg-field">
            <label htmlFor="llm-key">API key</label>
            <input
              id="llm-key"
              type="password"
              value={apiKey}
              onChange={(e) => setApiKey(e.target.value)}
              placeholder={
                editing && existing?.api_key_set
                  ? 'Stored — leave blank to keep current'
                  : 'Leave blank to use the server-configured key'
              }
              autoComplete="off"
            />
            <span className="sg-field__hint">Stored per connection; never shown again after saving.</span>
          </div>
          {error && <div className="sg-error">{error}</div>}
          <div className="modal-actions">
            <button type="button" className="sg-btn sg-btn--outline" onClick={onClose}>
              Cancel
            </button>
            <button
              type="submit"
              className="sg-btn sg-btn--black"
              disabled={saving || !label.trim() || !provider.trim() || !model.trim()}
            >
              {saving ? 'Saving…' : editing ? 'Save' : 'Create'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default function MockMcpLlmsPage() {
  const { orgId, loading: orgLoading } = useOrgId();
  const [llms, setLlms] = useState<MockMCPLLM[]>([]);
  const [models, setModels] = useState<MockMCPModel[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [editing, setEditing] = useState<MockMCPLLM | null>(null);

  const fetchData = useCallback(async () => {
    if (!orgId) return;
    try {
      const [llmData, modelData] = await Promise.all([
        api.listMockMcpLlms(orgId),
        api.listMockMcpModels(orgId),
      ]);
      setLlms(llmData.llms ?? []);
      setModels(modelData.models ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load LLM connections');
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

  async function remove(llm: MockMCPLLM) {
    if (!orgId) return;
    if (!confirm(`Delete LLM connection "${llm.label}"?`)) return;
    try {
      await api.deleteMockMcpLlm(orgId, llm.id);
      toast.success('Deleted');
      fetchData();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Request failed');
    }
  }

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">LLM Connections</h1>
        </div>
        <p className="sg-page-intro">
          Reusable provider/model/endpoint/key connections for this organization. Each mock MCP
          picks one as its active LLM.{' '}
          {orgId && <Link href={`/app/${orgId}/mock-mcp`}>← Back to Mock MCP</Link>}
        </p>

        {loading ? (
          <p className="sg-page-intro">Loading…</p>
        ) : llms.length === 0 ? (
          <div className="projects-empty">
            <p className="projects-empty__text">No LLM connections yet.</p>
            <button
              className="sg-btn sg-btn--black"
              onClick={() => {
                setEditing(null);
                setModalOpen(true);
              }}
            >
              New LLM connection
            </button>
          </div>
        ) : (
          <div className="admin-table-wrap">
            <table className="sg-table">
            <thead>
              <tr>
                <th>Label</th>
                <th>Provider</th>
                <th>Model</th>
                <th>Endpoint</th>
                <th>Key</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {llms.map((l) => (
                <tr key={l.id}>
                  <td>{l.label}</td>
                  <td>{l.provider}</td>
                  <td className="font-mono">{l.model}</td>
                  <td className="font-mono" style={{ wordBreak: 'break-all' }}>{l.endpoint || 'default'}</td>
                  <td>{l.api_key_set ? '••• set' : '—'}</td>
                  <td>
                    <button
                      className="sg-btn sg-btn--outline"
                      onClick={() => {
                        setEditing(l);
                        setModalOpen(true);
                      }}
                    >
                      Edit
                    </button>{' '}
                    <button className="sg-btn sg-btn--outline" onClick={() => remove(l)}>
                      Delete
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
            </table>
          </div>
        )}
      </main>

      {modalOpen && orgId && (
        <LlmModal
          orgId={orgId}
          models={models}
          existing={editing}
          onClose={() => setModalOpen(false)}
          onSaved={() => {
            setModalOpen(false);
            fetchData();
          }}
        />
      )}

      {!loading && llms.length > 0 && (
        <button
          className="fab"
          onClick={() => {
            setEditing(null);
            setModalOpen(true);
          }}
          aria-label="New LLM connection"
          title="New LLM connection"
        >
          <PlusIcon />
        </button>
      )}
    </div>
  );
}
