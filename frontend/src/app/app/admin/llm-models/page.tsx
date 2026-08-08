'use client';

import { useState, useEffect, useCallback, useMemo } from 'react';
import Link from 'next/link';
import { toast } from 'sonner';
import { PlusIcon, CloudArrowUpIcon, BeakerIcon } from '@heroicons/react/24/outline';
import { api, type LlmModel, type LlmModelInput } from '@/lib/api';
import {
  getProviderNames,
  getProviderConfig,
  getDefaultModel,
  getDefaultBaseUrl,
  getProviderEnvKey,
  getProviderEnvFallbacks,
  getProviderLabel,
  providerNeedsApiKey,
  providerNeedsBaseUrl,
} from '@/lib/llm-config';

function ModelModal({
  existing,
  onClose,
  onSaved,
}: {
  existing?: LlmModel | null;
  onClose: () => void;
  onSaved: () => void;
}) {
  // Form state
  const [provider, setProvider] = useState(existing?.provider ?? 'openai');
  const [model, setModel] = useState(existing?.model ?? '');
  const [label, setLabel] = useState(existing?.label ?? '');
  const [endpoint, setEndpoint] = useState(existing?.endpoint ?? '');
  const [enabled, setEnabled] = useState(existing?.enabled ?? true);
  const [sortOrder, setSortOrder] = useState(String(existing?.sort_order ?? 0));
  const [notes, setNotes] = useState(existing?.notes ?? '');

  // Guided setup state
  const [availableModels, setAvailableModels] = useState<string[]>([]);
  const [fetchingModels, setFetchingModels] = useState(false);
  const [testResult, setTestResult] = useState<string | null>(null);
  const [testingConfig, setTestingConfig] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const editing = !!existing;

  // Provider-specific config
  const providerConfig = useMemo(() => getProviderConfig(provider), [provider]);
  const needsApiKey = useMemo(() => providerNeedsApiKey(provider), [provider]);
  const needsBaseUrl = useMemo(() => providerNeedsBaseUrl(provider), [provider]);
  const envKey = useMemo(() => getProviderEnvKey(provider), [provider]);
  const envFallbacks = useMemo(() => getProviderEnvFallbacks(provider), [provider]);
  const defaultModel = useMemo(() => getDefaultModel(provider), [provider]);
  const defaultBaseUrl = useMemo(() => getDefaultBaseUrl(provider), [provider]);
  const testResultClassName = useMemo(() => {
    if (!testResult) return 'guided-setup__result';
    return [
      'guided-setup__result',
      testResult.startsWith('✓') ? 'guided-setup__result--success' : 'guided-setup__result--error',
    ].join(' ');
  }, [testResult]);

  // Handle provider change with autofill
  function handleProviderChange(newProvider: string) {
    setProvider(newProvider);
    // Autofill default model and base URL
    setModel('');
    setLabel('');
    setEndpoint('');
    setAvailableModels([]);
    setTestResult(null);
  }

  // Handle model change to autogenerate label
  function handleModelChange(newModel: string) {
    setModel(newModel);
    if (!editing && newModel && !label) {
      const providerLabel = getProviderLabel(provider);
      setLabel(`${providerLabel} · ${newModel}`);
    }
  }

  // Fetch models from provider API
  async function fetchModels() {
    setFetchingModels(true);
    setError(null);
    try {
      const response = await api.adminFetchProviderModels(provider);
      const models = response.models || [];
      setAvailableModels(models);
      if (!editing && !model && models.length > 0) {
        handleModelChange(models[0]);
      }
      toast.success(`Loaded ${models.length} models from ${getProviderLabel(provider)}`);
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to fetch models';
      setError(errorMessage);
      toast.error(errorMessage);
    } finally {
      setFetchingModels(false);
    }
  }

  // Test configuration
  async function testConfiguration() {
    setTestingConfig(true);
    setTestResult(null);
    setError(null);

    try {
      // Validate basic requirements first
      if (!model || model.trim() === '') {
        throw new Error('Model name is required for testing');
      }

      if (needsBaseUrl && (!endpoint || endpoint.trim() === '')) {
        throw new Error('Custom endpoint URL is required for this provider');
      }

      const response = await api.adminTestLlmConfiguration(
        provider,
        model,
        endpoint || undefined
      );

      if (response.valid) {
        setTestResult('✓ Configuration is valid');
        toast.success('Configuration test passed');
      } else if (response.error) {
        throw new Error(response.error);
      } else {
        throw new Error('Configuration test failed');
      }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Test failed';
      setTestResult(`✗ ${errorMessage}`);
      setError(errorMessage);
      toast.error(errorMessage);
    } finally {
      setTestingConfig(false);
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!provider.trim() || !model.trim() || !label.trim()) return;

    // Validate if provider needs inputs
    if (!editing) {
      if (needsApiKey && !envKey) {
        setError('Provider requires an API key configuration');
        return;
      }
      if (needsBaseUrl && !endpoint) {
        setError('Provider requires a custom base URL');
        return;
      }
    }

    setSaving(true);
    setError(null);
    try {
      const payload: LlmModelInput = {
        provider: provider.trim(),
        model: model.trim(),
        label: label.trim(),
        endpoint: endpoint.trim() || null,
        enabled,
        sort_order: Number.parseInt(sortOrder, 10) || 0,
        notes: notes.trim() || null,
      };
      if (editing) {
        await api.adminUpdateLlmModel(existing!.id, payload);
        toast.success('Model updated');
      } else {
        await api.adminCreateLlmModel(payload);
        toast.success('Model added');
      }
      onSaved();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Request failed');
    } finally {
      setSaving(false);
    }
  }

  const providerOptions = getProviderNames();

  return (
    <div className="modal-overlay modal-overlay--wide" onClick={onClose}>
      <div className="modal-card modal-card--wide" onClick={(e) => e.stopPropagation()}>
        <h2 className="modal-title">{editing ? 'Edit model' : 'New model'}</h2>

        <div className="guided-setup">
          {/* Provider selection */}
          <div className="sg-field">
            <label htmlFor="m-provider">Provider</label>
            <select
              id="m-provider"
              value={provider}
              onChange={(e) => handleProviderChange(e.target.value)}
              className="sg-input sg-input--select"
            >
              {providerOptions.map((opt) => (
                <option key={opt} value={opt}>
                  {getProviderLabel(opt)}
                </option>
              ))}
            </select>
            {needsApiKey && (
              <span className="sg-field__hint">
                🔑 Configuration required: Set <code>{envKey}</code>
                {envFallbacks.length > 0 && ` (or ${envFallbacks.join(' / ')})`} in Infisical
              </span>
            )}
            {needsBaseUrl && (
              <span className="sg-field__hint">
                🔗 Custom base URL required for this provider
              </span>
            )}
          </div>

          {/* Model input with fetch capability */}
          <div className="sg-field sg-field--with-action">
            <div className="sg-field__main">
              <label htmlFor="m-model">Model</label>
              <input
                id="m-model"
                value={model}
                onChange={(e) => handleModelChange(e.target.value)}
                placeholder={defaultModel}
                list="available-models"
              />
              {availableModels.length > 0 && (
                <datalist id="available-models">
                  {availableModels.map((m) => (
                    <option key={m} value={m} />
                  ))}
                </datalist>
              )}
            </div>
            {!editing && (
              <button
                type="button"
                className="sg-btn sg-btn--outline sg-btn--sm"
                onClick={fetchModels}
                disabled={fetchingModels}
                title="Fetch available models from provider API"
              >
                {fetchingModels ? 'Loading…' : <><CloudArrowUpIcon className="icon-sm" /> Fetch</>}
              </button>
            )}
          </div>

          {/* Label with autofill hint */}
          <div className="sg-field">
            <label htmlFor="m-label">Label</label>
            <input
              id="m-label"
              value={label}
              onChange={(e) => setLabel(e.target.value)}
              placeholder={`${getProviderLabel(provider)} · ${defaultModel}`}
            />
            <span className="sg-field__hint">Shown in the picker. Auto-generated from provider and model.</span>
          </div>

          {/* Base URL with default */}
          {needsBaseUrl && (
            <div className="sg-field">
              <label htmlFor="m-endpoint">Base URL</label>
              <input
                id="m-endpoint"
                value={endpoint}
                onChange={(e) => setEndpoint(e.target.value)}
                placeholder={defaultBaseUrl}
              />
              <span className="sg-field__hint">Required for {getProviderLabel(provider)}</span>
            </div>
          )}

          {!needsBaseUrl && (
            <div className="sg-field">
              <label htmlFor="m-endpoint">Base URL (optional)</label>
              <input
                id="m-endpoint"
                value={endpoint}
                onChange={(e) => setEndpoint(e.target.value)}
                placeholder={`Default: ${defaultBaseUrl}`}
              />
              <span className="sg-field__hint">Leave empty to use provider default</span>
            </div>
          )}

          {/* Quick actions */}
          <div className="guided-setup__actions">
            <button
              type="button"
              className="sg-btn sg-btn--outline sg-btn--sm"
              onClick={testConfiguration}
              disabled={testingConfig || !!error}
            >
              {testingConfig ? 'Testing…' : <><BeakerIcon className="icon-sm" /> Test Configuration</>}
            </button>
            {testResult && (
              <span className={testResultClassName}>{testResult}</span>
            )}
          </div>

          {/* Additional fields */}
          <div className="sg-field">
            <label htmlFor="m-sort">Sort order</label>
            <input id="m-sort" type="number" value={sortOrder} onChange={(e) => setSortOrder(e.target.value)} />
          </div>

          <div className="sg-field">
            <label htmlFor="m-notes">Notes</label>
            <input id="m-notes" value={notes ?? ''} onChange={(e) => setNotes(e.target.value)} placeholder="Optional" />
          </div>

          <div className="sg-field sg-field--inline">
            <input id="m-enabled" type="checkbox" checked={enabled} onChange={(e) => setEnabled(e.target.checked)} />
            <label htmlFor="m-enabled">Enabled (visible in picker)</label>
          </div>

          {error && <div className="sg-error sg-error--block">{error}</div>}
        </div>

        <div className="modal-actions">
          <button type="button" className="sg-btn sg-btn--outline" onClick={onClose}>Cancel</button>
          <button type="submit" className="sg-btn sg-btn--black" disabled={saving || !provider.trim() || !model.trim() || !label.trim()}>
            {saving ? 'Saving…' : editing ? 'Save' : 'Create Model'}
          </button>
        </div>
      </div>
    </div>
  );
}

export default function AdminLlmModelsPage() {
  const [models, setModels] = useState<LlmModel[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [editing, setEditing] = useState<LlmModel | null>(null);

  const fetchData = useCallback(async () => {
    try {
      const data = await api.adminListLlmModels();
      setModels(data.models ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load models');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  async function toggle(m: LlmModel) {
    try {
      await api.adminUpdateLlmModel(m.id, { enabled: !m.enabled });
      setModels((prev) => prev.map((x) => (x.id === m.id ? { ...x, enabled: !x.enabled } : x)));
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Request failed');
    }
  }

  async function remove(m: LlmModel) {
    if (!confirm(`Remove "${m.label}" from the catalog?`)) return;
    try {
      await api.adminDeleteLlmModel(m.id);
      toast.success('Removed');
      setModels((prev) => prev.filter((x) => x.id !== m.id));
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Request failed');
    }
  }

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">LLM Catalog</h1>
        </div>
        <p className="sg-page-intro">
          Provider/model pairs available in the Mock MCP picker and MCP ListModels. Disabled
          entries stay in the catalog but are hidden from the picker.{' '}
          <Link href="/app/admin">← Back to Admin</Link>
        </p>

        {loading ? (
          <p className="sg-page-intro">Loading…</p>
        ) : models.length === 0 ? (
          <div className="projects-empty">
            <p className="projects-empty__text">No models in the catalog.</p>
            <button className="sg-btn sg-btn--black" onClick={() => { setEditing(null); setModalOpen(true); }}>
              New model
            </button>
          </div>
        ) : (
          <table className="sg-table">
            <thead>
              <tr>
                <th>Label</th>
                <th>Provider</th>
                <th>Model</th>
                <th>Endpoint</th>
                <th>Enabled</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {models.map((m) => (
                <tr key={m.id}>
                  <td>{m.label}</td>
                  <td>{m.provider}</td>
                  <td className="font-mono">{m.model}</td>
                  <td className="font-mono" style={{ wordBreak: 'break-all' }}>{m.endpoint || 'default'}</td>
                  <td>
                    <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => toggle(m)}>
                      {m.enabled ? 'On' : 'Off'}
                    </button>
                  </td>
                  <td>
                    <button className="sg-btn sg-btn--outline" onClick={() => { setEditing(m); setModalOpen(true); }}>Edit</button>{' '}
                    <button className="sg-btn sg-btn--outline" onClick={() => remove(m)}>Delete</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </main>

      {modalOpen && (
        <ModelModal
          existing={editing}
          onClose={() => setModalOpen(false)}
          onSaved={() => { setModalOpen(false); fetchData(); }}
        />
      )}

      {!loading && models.length > 0 && (
        <button className="fab" onClick={() => { setEditing(null); setModalOpen(true); }} aria-label="New model" title="New model">
          <PlusIcon />
        </button>
      )}
    </div>
  );
}
