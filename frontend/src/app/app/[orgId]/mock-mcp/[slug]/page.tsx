'use client';

import { Fragment, useState, useEffect, useCallback } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import Editor from '@monaco-editor/react';
import { toast } from 'sonner';
import {
  api,
  type MockMCPDefinition,
  type MockMCPLLM,
  type MockMCPCallLog,
  type MockMCPDbResult,
  type MockMCPRedisEntry,
  type MockMCPInvokeResult,
} from '@/lib/api';
import { useOrgId } from '@/context/org';

type Tab = 'overview' | 'surface' | 'config' | 'state' | 'playground' | 'calls';

function gatewayUrl(slug: string): string {
  let host = '';
  const apiUrl = process.env.NEXT_PUBLIC_API_URL;
  if (apiUrl) {
    try {
      host = new URL(apiUrl).host;
    } catch {
      host = apiUrl.replace(/^https?:\/\//, '');
    }
  } else if (typeof window !== 'undefined') {
    host = window.location.host;
  }
  return `https://mockmcp.${host}/mcp/${slug}/mcp`;
}

function Json({ value }: { value: unknown }) {
  return (
    <pre className="font-mono" style={{ whiteSpace: 'pre-wrap', wordBreak: 'break-word', margin: 0 }}>
      {typeof value === 'string' ? value : JSON.stringify(value, null, 2)}
    </pre>
  );
}

export default function MockMcpDetailPage() {
  const params = useParams();
  const router = useRouter();
  const { orgId } = useOrgId();
  const slug = params?.slug as string;

  const [def, setDef] = useState<MockMCPDefinition | null>(null);
  const [llms, setLlms] = useState<MockMCPLLM[]>([]);
  const [calls, setCalls] = useState<MockMCPCallLog[]>([]);
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState<string | null>(null);
  const [tab, setTab] = useState<Tab>('overview');

  // config
  const [prompt, setPrompt] = useState('');
  const [activeLlmId, setActiveLlmId] = useState('');

  // state browser
  const [dbTables, setDbTables] = useState<string[]>([]);
  const [dbSql, setDbSql] = useState('SELECT 1;');
  const [dbResult, setDbResult] = useState<MockMCPDbResult | null>(null);
  const [redisEntries, setRedisEntries] = useState<MockMCPRedisEntry[]>([]);

  // playground
  const [pgTool, setPgTool] = useState('');
  const [pgArgs, setPgArgs] = useState('{}');
  const [pgResult, setPgResult] = useState<MockMCPInvokeResult | null>(null);

  // call log
  const [expanded, setExpanded] = useState<string | null>(null);

  const load = useCallback(async () => {
    if (!orgId || !slug) return;
    try {
      const [defData, llmData, callData] = await Promise.all([
        api.getMockMcp(orgId, slug),
        api.listMockMcpLlms(orgId),
        api.listMockMcpCalls(orgId, slug).catch(() => ({ calls: [] })),
      ]);
      const d = defData.definition;
      setDef(d);
      setPrompt(d.prompt);
      setActiveLlmId(d.active_llm_id ?? '');
      setLlms(llmData.llms ?? []);
      setCalls(callData.calls ?? []);
      setPgTool((prev) => prev || d.tools_json?.[0]?.name || '');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load mock MCP');
    } finally {
      setLoading(false);
    }
  }, [orgId, slug]);

  useEffect(() => {
    load();
  }, [load]);

  async function run(label: string, fn: () => Promise<unknown>, successMsg?: string) {
    setBusy(label);
    try {
      await fn();
      if (successMsg) toast.success(successMsg);
      await load();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Request failed');
    } finally {
      setBusy(null);
    }
  }

  const loadState = useCallback(async () => {
    if (!orgId || !def) return;
    try {
      const redis = await api.mockMcpRedisState(orgId, def.slug);
      setRedisEntries(redis.entries ?? []);
      if (def.db_provisioned) {
        const tables = await api.mockMcpDbTables(orgId, def.slug);
        setDbTables(tables.tables ?? []);
      }
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load state');
    }
  }, [orgId, def]);

  useEffect(() => {
    if (tab === 'state') loadState();
  }, [tab, loadState]);

  async function runQuery() {
    if (!orgId || !def) return;
    setBusy('sql');
    try {
      setDbResult(await api.mockMcpDbQuery(orgId, def.slug, dbSql));
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Query failed');
    } finally {
      setBusy(null);
    }
  }

  async function invoke() {
    if (!orgId || !def || !pgTool) return;
    let args: Record<string, unknown> = {};
    try {
      args = pgArgs.trim() ? JSON.parse(pgArgs) : {};
    } catch {
      toast.error('Arguments must be valid JSON');
      return;
    }
    setBusy('invoke');
    setPgResult(null);
    try {
      const res = await api.invokeMockMcpTool(orgId, def.slug, pgTool, args);
      setPgResult(res);
      load();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Invoke failed');
    } finally {
      setBusy(null);
    }
  }

  if (loading) return <div className="content"><main><p className="sg-page-intro">Loading…</p></main></div>;
  if (!def || !orgId) return <div className="content"><main><p className="sg-page-intro">Not found.</p></main></div>;

  const url = gatewayUrl(def.slug);
  const claudeCmd = `claude mcp add ${def.slug} --transport http ${url}`;

  const TABS: { id: Tab; label: string }[] = [
    { id: 'overview', label: 'Overview' },
    { id: 'surface', label: `Surface (${def.tool_count ?? 0}/${def.resource_count ?? 0}/${def.prompt_count ?? 0})` },
    { id: 'config', label: 'Configuration' },
    { id: 'state', label: 'State' },
    { id: 'playground', label: 'Playground' },
    { id: 'calls', label: `Call log (${calls.length})` },
  ];

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">{def.title}</h1>
          <span className={`project-card__status project-card__status--${def.status}`}>{def.status}</span>
        </div>
        <p className="sg-page-intro">
          <Link href={`/app/${orgId}/mock-mcp`}>← All mock MCPs</Link> · <span className="font-mono">{def.slug}</span>
        </p>

        {/* Tab bar */}
        <div className="projects-header" style={{ gap: 8, flexWrap: 'wrap' }}>
          {TABS.map((t) => (
            <button
              key={t.id}
              className={`sg-btn ${tab === t.id ? 'sg-btn--black' : 'sg-btn--outline'}`}
              onClick={() => setTab(t.id)}
            >
              {t.label}
            </button>
          ))}
        </div>

        {/* ── Overview ── */}
        {tab === 'overview' && (
          <>
            <section className="sg-section">
              <h2 className="sg-section-heading">Connection</h2>
              {def.status !== 'active' && (
                <p className="sg-field__hint">Activate this mock MCP before connecting clients.</p>
              )}
              <div className="sg-field">
                <label>Endpoint</label>
                <code className="font-mono" style={{ wordBreak: 'break-all' }}>{url}</code>
              </div>
              <div className="sg-field">
                <label>Claude Code</label>
                <code className="font-mono" style={{ wordBreak: 'break-all' }}>{claudeCmd}</code>
              </div>
            </section>

            <section className="sg-section">
              <h2 className="sg-section-heading">Summary</h2>
              <dl className="project-card__fields">
                <div className="project-card__field"><dt>Active LLM:</dt><dd>{def.active_llm ? `${def.active_llm.label} (${def.active_llm.provider}/${def.active_llm.model})` : 'server default'}</dd></div>
                <div className="project-card__field"><dt>Tools / Resources / Prompts:</dt><dd>{def.tool_count ?? 0} / {def.resource_count ?? 0} / {def.prompt_count ?? 0}</dd></div>
                <div className="project-card__field"><dt>Private DB:</dt><dd>{def.db_provisioned ? def.db_name : 'not provisioned'}</dd></div>
              </dl>
            </section>

            <section className="sg-section">
              <h2 className="sg-section-heading">Lifecycle</h2>
              <div className="modal-actions">
                {def.status !== 'active' ? (
                  <button className="sg-btn sg-btn--black" disabled={busy !== null} onClick={() => run('act', () => api.activateMockMcp(orgId, def.slug), 'Activated')}>Activate</button>
                ) : (
                  <button className="sg-btn sg-btn--outline" disabled={busy !== null} onClick={() => run('arch', () => api.updateMockMcp(orgId, def.slug, { status: 'archived' }), 'Archived')}>Archive</button>
                )}
                <button className="sg-btn sg-btn--outline" disabled={busy !== null} onClick={() => run('gen', () => api.generateMockMcpTools(orgId, def.slug), 'Surface regenerated')}>{busy === 'gen' ? 'Generating…' : 'Regenerate surface'}</button>
                <button className="sg-btn sg-btn--outline" disabled={busy !== null || def.db_provisioned} onClick={() => run('db', () => api.provisionMockMcpDb(orgId, def.slug), 'Database provisioned')}>{def.db_provisioned ? `DB: ${def.db_name}` : 'Provision DB'}</button>
                <button className="sg-btn sg-btn--danger" disabled={busy !== null} onClick={() => { if (!confirm('Delete this mock MCP?')) return; run('del', async () => { await api.deleteMockMcp(orgId, def.slug); router.push(`/app/${orgId}/mock-mcp`); }); }}>Delete</button>
              </div>
            </section>
          </>
        )}

        {/* ── Surface ── */}
        {tab === 'surface' && (
          <>
            <section className="sg-section">
              <div className="projects-header">
                <h2 className="sg-section-heading">Tools ({def.tools_json?.length ?? 0})</h2>
                <button className="sg-btn sg-btn--outline" disabled={busy !== null} onClick={() => run('gen', () => api.generateMockMcpTools(orgId, def.slug), 'Surface regenerated')}>{busy === 'gen' ? 'Generating…' : 'Regenerate'}</button>
              </div>
              <p className="sg-field__hint">
                Generated tools are fulfilled by the LLM using each tool’s private handler. The mock’s
                Postgres/Redis are the agent’s private backing store — never exposed as tools.
              </p>
              {(def.tools_json ?? []).length === 0 ? <p className="sg-field__hint">None.</p> : (
                <div className="projects-grid">
                  {def.tools_json!.map((t) => (
                    <div key={t.name} className="project-card">
                      <div className="project-card__header"><div className="project-card__name font-mono">{t.name}</div></div>
                      <div className="project-card__body">
                        <div>{t.description}</div>
                        {t.handler && (
                          <div className="project-card__field" style={{ marginTop: 8 }}>
                            <dt>Handler (private):</dt>
                            <dd style={{ whiteSpace: 'pre-wrap' }}>{t.handler}</dd>
                          </div>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </section>

            <section className="sg-section">
              <h2 className="sg-section-heading">Resources ({def.resources_json?.length ?? 0})</h2>
              {(def.resources_json ?? []).length === 0 ? <p className="sg-field__hint">None.</p> : (
                <div className="projects-grid">
                  {def.resources_json!.map((r) => (
                    <div key={r.uri} className="project-card">
                      <div className="project-card__header"><div className="project-card__name font-mono">{r.name || r.uri}</div></div>
                      <div className="project-card__body">
                        <div className="font-mono">{r.uri}</div>
                        <div>{r.description}</div>
                        <div className="sg-field__hint">{r.mimeType}</div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </section>

            <section className="sg-section">
              <h2 className="sg-section-heading">Prompts ({def.prompts_json?.length ?? 0})</h2>
              {(def.prompts_json ?? []).length === 0 ? <p className="sg-field__hint">None.</p> : (
                <div className="projects-grid">
                  {def.prompts_json!.map((p) => (
                    <div key={p.name} className="project-card">
                      <div className="project-card__header"><div className="project-card__name font-mono">{p.name}</div></div>
                      <div className="project-card__body">
                        <div>{p.description}</div>
                        {p.arguments && p.arguments.length > 0 && (
                          <div className="sg-field__hint">args: {p.arguments.map((a) => a.name).join(', ')}</div>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </section>
          </>
        )}

        {/* ── Configuration ── */}
        {tab === 'config' && (
          <section className="sg-section">
            <h2 className="sg-section-heading">Configuration</h2>
            <div className="sg-field">
              <label htmlFor="d-prompt">Prompt</label>
              <textarea id="d-prompt" rows={8} value={prompt} onChange={(e) => setPrompt(e.target.value)} />
            </div>
            <div className="sg-field">
              <label htmlFor="d-llm">Active LLM</label>
              <select id="d-llm" value={activeLlmId} onChange={(e) => setActiveLlmId(e.target.value)}>
                <option value="">Server default</option>
                {llms.map((l) => <option key={l.id} value={l.id}>{l.label} ({l.provider}/{l.model})</option>)}
              </select>
              <span className="sg-field__hint"><Link href={`/app/${orgId}/mock-mcp/llms`}>Manage LLM connections →</Link></span>
            </div>
            <div className="modal-actions">
              <button className="sg-btn sg-btn--black" disabled={busy !== null} onClick={() => run('save', () => api.updateMockMcp(orgId, def.slug, { prompt, active_llm_id: activeLlmId || null, auto_generate_tools: false }), 'Saved')}>{busy === 'save' ? 'Saving…' : 'Save'}</button>
            </div>
          </section>
        )}

        {/* ── State (private datastore) ── */}
        {tab === 'state' && (
          <>
            {!def.db_provisioned && (
              <section className="sg-section">
                <p className="sg-field__hint">No database provisioned. The agent can still use Redis. Provision a DB to enable SQL state.</p>
                <button className="sg-btn sg-btn--outline" disabled={busy !== null} onClick={() => run('db', () => api.provisionMockMcpDb(orgId, def.slug), 'Database provisioned')}>Provision DB</button>
              </section>
            )}

            {def.db_provisioned && (
              <section className="sg-section">
                <h2 className="sg-section-heading">Database</h2>
                <p className="sg-field__hint">Tables: {dbTables.length ? dbTables.map((t) => <code key={t} className="font-mono" style={{ marginRight: 8 }}>{t}</code>) : '(none yet)'}</p>
                <div className="sg-field">
                  <label>SQL console (read queries)</label>
                  <div style={{ border: '1px solid var(--border, #ccc)' }}>
                    <Editor height={140} defaultLanguage="sql" theme="vs-dark" value={dbSql} onChange={(v) => setDbSql(v ?? '')} options={{ minimap: { enabled: false }, lineNumbers: 'off', fontSize: 13 }} />
                  </div>
                </div>
                <div className="modal-actions">
                  <button className="sg-btn sg-btn--black" disabled={busy !== null} onClick={runQuery}>{busy === 'sql' ? 'Running…' : 'Run query'}</button>
                </div>
                {dbResult && (
                  <div className="admin-table-wrap" style={{ marginTop: 12 }}>
                    <table className="sg-table">
                      <thead><tr>{dbResult.columns.map((c) => <th key={c}>{c}</th>)}</tr></thead>
                      <tbody>
                        {dbResult.rows.map((row, i) => (
                          <tr key={i}>{row.map((cell, j) => <td key={j} className="font-mono">{cell === null ? '∅' : String(cell)}</td>)}</tr>
                        ))}
                      </tbody>
                    </table>
                    {dbResult.rows.length === 0 && <p className="sg-field__hint">0 rows.</p>}
                  </div>
                )}
              </section>
            )}

            <section className="sg-section">
              <div className="projects-header">
                <h2 className="sg-section-heading">Redis ({redisEntries.length})</h2>
                <button className="sg-btn sg-btn--outline" onClick={loadState}>Refresh</button>
              </div>
              {redisEntries.length === 0 ? <p className="sg-field__hint">No keys.</p> : (
                <table className="sg-table">
                  <thead><tr><th>Key</th><th>Value</th></tr></thead>
                  <tbody>{redisEntries.map((e) => <tr key={e.key}><td className="font-mono">{e.key}</td><td className="font-mono" style={{ wordBreak: 'break-all' }}>{e.value}</td></tr>)}</tbody>
                </table>
              )}
            </section>
          </>
        )}

        {/* ── Playground ── */}
        {tab === 'playground' && (
          <section className="sg-section">
            <h2 className="sg-section-heading">Playground</h2>
            <p className="sg-field__hint">Invoke a generated tool directly (no MCP client). The agent may read/write its private datastore — the ops it ran appear as a trace.</p>
            {(def.tools_json ?? []).length === 0 ? <p className="sg-field__hint">No tools yet — regenerate the surface first.</p> : (
              <>
                <div className="sg-field">
                  <label htmlFor="pg-tool">Tool</label>
                  <select id="pg-tool" value={pgTool} onChange={(e) => setPgTool(e.target.value)}>
                    {def.tools_json!.map((t) => <option key={t.name} value={t.name}>{t.name}</option>)}
                  </select>
                </div>
                <div className="sg-field">
                  <label>Arguments (JSON)</label>
                  <div style={{ border: '1px solid var(--border, #ccc)' }}>
                    <Editor height={120} defaultLanguage="json" theme="vs-dark" value={pgArgs} onChange={(v) => setPgArgs(v ?? '{}')} options={{ minimap: { enabled: false }, lineNumbers: 'off', fontSize: 13 }} />
                  </div>
                </div>
                <div className="modal-actions">
                  <button className="sg-btn sg-btn--black" disabled={busy !== null} onClick={invoke}>{busy === 'invoke' ? 'Invoking…' : 'Invoke'}</button>
                </div>
                {pgResult && (
                  <>
                    <div className="sg-field" style={{ marginTop: 12 }}>
                      <label>Result ({pgResult.latency_ms}ms)</label>
                      <Json value={pgResult.content} />
                    </div>
                    {pgResult.trace?.length > 0 && (
                      <div className="sg-field">
                        <label>Internal data-ops trace ({pgResult.trace.length})</label>
                        <Json value={pgResult.trace} />
                      </div>
                    )}
                  </>
                )}
              </>
            )}
          </section>
        )}

        {/* ── Call log ── */}
        {tab === 'calls' && (
          <section className="sg-section">
            <h2 className="sg-section-heading">Call log</h2>
            {calls.length === 0 ? <p className="sg-field__hint">No calls recorded yet.</p> : (
              <table className="sg-table">
                <thead><tr><th>Method</th><th>Tool</th><th>Latency</th><th>Result</th><th></th></tr></thead>
                <tbody>
                  {calls.map((c) => (
                    <Fragment key={c.id}>
                      <tr>
                        <td>{c.method}</td>
                        <td className="font-mono">{c.tool_name || '—'}</td>
                        <td>{c.latency_ms != null ? `${c.latency_ms}ms` : '—'}</td>
                        <td>{c.error ? <span className="sg-error">error</span> : 'ok'}</td>
                        <td><button className="sg-btn sg-btn--outline" onClick={() => setExpanded(expanded === c.id ? null : c.id)}>{expanded === c.id ? 'Hide' : 'Details'}</button></td>
                      </tr>
                      {expanded === c.id && (
                        <tr>
                          <td colSpan={5}>
                            <div className="sg-field"><label>Arguments</label><Json value={c.arguments ?? {}} /></div>
                            {c.error && <div className="sg-field"><label>Error</label><span className="sg-error">{c.error}</span></div>}
                            <div className="sg-field"><label>Response</label><Json value={c.response ?? {}} /></div>
                          </td>
                        </tr>
                      )}
                    </Fragment>
                  ))}
                </tbody>
              </table>
            )}
          </section>
        )}
      </main>
    </div>
  );
}
