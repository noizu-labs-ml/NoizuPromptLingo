'use client';

import { useState, useEffect, useCallback } from 'react';
import { toast } from 'sonner';
import {
  api,
  type Memory,
  type MemoryAgent,
  type MemoryScopeType,
} from '@/lib/api';
import { useOrg, useOrgId } from '@/context/org';
import { MemoryCard } from '@/components/memory/memory-card';
import { AssociationsView } from '@/components/memory/associations-view';
import { SignedBar } from '@/components/memory/memory-meters';

const SCOPE_LABELS: Record<MemoryScopeType, string> = {
  persona: 'Persona',
  weego: 'Weego',
  team_member: 'Team member',
};

function agentKey(a: MemoryAgent) {
  return `${a.scope_type}:${a.scope_id}`;
}

function agentDisplay(a: MemoryAgent) {
  const base = `${SCOPE_LABELS[a.scope_type] ?? a.scope_type} · ${a.label}`;
  return a.call_sign ? `${base} (${a.call_sign})` : base;
}

export default function MemoryBrowserPage() {
  const { orgId, loading: orgLoading } = useOrgId();
  const { currentOrg } = useOrg();

  const [agents, setAgents] = useState<MemoryAgent[]>([]);
  const [agentsLoading, setAgentsLoading] = useState(true);
  const [selectedKey, setSelectedKey] = useState<string>('');

  // The memory list / results currently on screen, plus how it was produced so
  // we can label and re-run it.
  const [memories, setMemories] = useState<Memory[]>([]);
  const [listLoading, setListLoading] = useState(false);
  const [scored, setScored] = useState(false); // results carry a resonance score

  // Recall controls.
  const [query, setQuery] = useState('');
  const [mood, setMood] = useState({ valence: 0, arousal: 0, dominance: 0 });

  // Association drill-in.
  const [focused, setFocused] = useState<Memory | null>(null);

  const selectedAgent = agents.find((a) => agentKey(a) === selectedKey) ?? null;
  const agentSlug = selectedAgent?.slug ?? null;

  // Load the agent (scope) list for this org.
  useEffect(() => {
    if (!orgId) {
      if (!orgLoading) setAgentsLoading(false);
      return;
    }
    let cancelled = false;
    setAgentsLoading(true);
    api
      .listMemoryAgents(orgId)
      .then((res) => {
        if (cancelled) return;
        const list = res.agents ?? [];
        setAgents(list);
        setSelectedKey((prev) => prev || (list[0] ? agentKey(list[0]) : ''));
      })
      .catch((err) => {
        if (!cancelled) toast.error(err instanceof Error ? err.message : 'Failed to load agents');
      })
      .finally(() => {
        if (!cancelled) setAgentsLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [orgId, orgLoading]);

  const runRecall = useCallback(async () => {
    if (!orgId || !agentSlug || !query.trim()) return;
    setListLoading(true);
    try {
      const res = await api.recallMemories(orgId, agentSlug, query.trim());
      setMemories(res.results ?? []);
      setScored(true);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Recall failed');
    } finally {
      setListLoading(false);
    }
  }, [orgId, agentSlug, query]);

  const runEmotionalRecall = useCallback(async () => {
    if (!orgId || !agentSlug) return;
    setListLoading(true);
    try {
      const res = await api.recallMemoriesByEmotion(orgId, agentSlug, mood);
      setMemories(res.results ?? []);
      setScored(true);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Emotional recall failed');
    } finally {
      setListLoading(false);
    }
  }, [orgId, agentSlug, mood]);

  // The default "list" for an agent — the dedicated list endpoint, no query.
  const loadDefault = useCallback(async () => {
    if (!orgId || !agentSlug) return;
    setListLoading(true);
    try {
      const res = await api.listAgentMemories(orgId, agentSlug);
      setMemories(res.results ?? []);
      setScored(false);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load memories');
    } finally {
      setListLoading(false);
    }
  }, [orgId, agentSlug]);

  // Reset + load defaults whenever the selected agent changes.
  useEffect(() => {
    setQuery('');
    setMemories([]);
    setScored(false);
    if (selectedKey) loadDefault();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedKey]);

  return (
    <div className="content wide">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">Agent Memory</h1>
          {currentOrg && <span className="scope-chip">Org: <strong>{currentOrg.name}</strong></span>}
        </div>
        <p className="sg-page-intro">
          Read-only browser for agent memory — pick a persona, weego, or team member, then list,
          search, or recall by emotional state.
        </p>

        {/* Scope selector */}
        <div className="sg-field" style={{ maxWidth: 480 }}>
          <label htmlFor="m-agent">Agent (scope)</label>
          <select
            id="m-agent"
            value={selectedKey}
            onChange={(e) => setSelectedKey(e.target.value)}
            disabled={agentsLoading || agents.length === 0}
          >
            {agents.length === 0 && <option value="">No agents available</option>}
            {agents.map((a) => (
              <option key={agentKey(a)} value={agentKey(a)}>
                {agentDisplay(a)}
              </option>
            ))}
          </select>
          <span className="sg-field__hint">
            {agentsLoading ? 'Loading agents…' : `${agents.length} agent(s) in this organization.`}
          </span>
        </div>

        {selectedAgent && (
          <div
            style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))',
              gap: 16,
              margin: '16px 0',
            }}
          >
            {/* Text recall */}
            <div className="project-card">
              <div className="project-card__body">
                <div className="sg-field">
                  <label htmlFor="m-query">Recall (semantic search)</label>
                  <input
                    id="m-query"
                    value={query}
                    onChange={(e) => setQuery(e.target.value)}
                    onKeyDown={(e) => e.key === 'Enter' && runRecall()}
                    placeholder="What do you remember about…"
                  />
                </div>
                <div className="modal-actions" style={{ justifyContent: 'flex-start', marginTop: 0 }}>
                  <button
                    className="sg-btn sg-btn--black sg-btn--sm"
                    onClick={runRecall}
                    disabled={listLoading || !query.trim()}
                  >
                    Recall
                  </button>
                  <button
                    className="sg-btn sg-btn--outline sg-btn--sm"
                    onClick={loadDefault}
                    disabled={listLoading}
                  >
                    Show all
                  </button>
                </div>
              </div>
            </div>

            {/* Emotional recall */}
            <div className="project-card">
              <div className="project-card__body">
                <div className="sg-field__hint" style={{ marginBottom: 6 }}>
                  Emotional recall (VAD)
                </div>
                <div style={{ display: 'grid', gap: 8 }}>
                  {(['valence', 'arousal', 'dominance'] as const).map((axis) => (
                    <div key={axis} style={{ display: 'grid', gap: 2 }}>
                      <SignedBar
                        label={axis[0].toUpperCase() + axis.slice(1)}
                        value={mood[axis]}
                      />
                      <input
                        type="range"
                        min={-1}
                        max={1}
                        step={0.05}
                        value={mood[axis]}
                        onChange={(e) =>
                          setMood((m) => ({ ...m, [axis]: parseFloat(e.target.value) }))
                        }
                      />
                    </div>
                  ))}
                </div>
                <div className="modal-actions" style={{ justifyContent: 'flex-start', marginTop: 8 }}>
                  <button
                    className="sg-btn sg-btn--black sg-btn--sm"
                    onClick={runEmotionalRecall}
                    disabled={listLoading}
                  >
                    Recall by emotion
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Results / list */}
        {!selectedAgent ? (
          !agentsLoading && (
            <p className="sg-page-intro">Select an agent to browse its memories.</p>
          )
        ) : listLoading ? (
          <p className="sg-page-intro">Loading memories…</p>
        ) : memories.length === 0 ? (
          <p className="sg-page-intro">No memories for this scope.</p>
        ) : (
          <>
            <p className="sg-field__hint">
              {memories.length} {scored ? 'ranked result(s)' : 'memory/memories'} — click a card to
              view associations.
            </p>
            <div className="projects-grid">
              {memories.map((m) => (
                <MemoryCard
                  key={m.id}
                  memory={m}
                  score={scored ? m.resonance : undefined}
                  selected={focused?.id === m.id}
                  onSelect={setFocused}
                />
              ))}
            </div>
          </>
        )}
      </main>

      {focused && agentSlug && orgId && (
        <AssociationsView
          orgId={orgId}
          agentSlug={agentSlug}
          memory={focused}
          onClose={() => setFocused(null)}
        />
      )}
    </div>
  );
}
