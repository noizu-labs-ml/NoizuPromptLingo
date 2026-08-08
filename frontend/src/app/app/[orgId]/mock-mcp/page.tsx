'use client';

import { useState, useEffect, useCallback } from 'react';
import Link from 'next/link';
import { toast } from 'sonner';
import { PlusIcon } from '@heroicons/react/24/outline';
import {
  api,
  type MockMCPDefinition,
  type MockMCPLLM,
  type Project,
} from '@/lib/api';
import { useOrg, useOrgId } from '@/context/org';

function timeAgo(dt?: string) {
  if (!dt) return '';
  const diff = Date.now() - new Date(dt).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return 'just now';
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  return `${Math.floor(hrs / 24)}d ago`;
}

function slugify(s: string) {
  return s
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

function CreateModal({
  orgId,
  projects,
  llms,
  defaultProjectId,
  onClose,
  onSaved,
}: {
  orgId: string;
  projects: Project[];
  llms: MockMCPLLM[];
  defaultProjectId?: string;
  onClose: () => void;
  onSaved: () => void;
}) {
  const [title, setTitle] = useState('');
  const [slug, setSlug] = useState('');
  const [slugEdited, setSlugEdited] = useState(false);
  const [prompt, setPrompt] = useState('');
  const [activeLlmId, setActiveLlmId] = useState(llms[0]?.id ?? '');
  const [projectId, setProjectId] = useState(defaultProjectId ?? '');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const effectiveSlug = slugEdited ? slug : slugify(title);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!title.trim() || !prompt.trim() || !effectiveSlug) return;
    setSaving(true);
    setError(null);
    try {
      await api.createMockMcp(orgId, {
        slug: effectiveSlug,
        title: title.trim(),
        prompt,
        active_llm_id: activeLlmId || null,
        project_id: projectId || null,
      });
      toast.success('Mock MCP created — generating tools…');
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
        <h2 className="modal-title">New Mock MCP</h2>
        <form onSubmit={handleSubmit}>
          <div className="sg-field">
            <label htmlFor="mock-title">Title</label>
            <input
              id="mock-title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Weather Service"
              autoFocus
            />
          </div>
          <div className="sg-field">
            <label htmlFor="mock-slug">Slug</label>
            <input
              id="mock-slug"
              value={effectiveSlug}
              onChange={(e) => {
                setSlugEdited(true);
                setSlug(slugify(e.target.value));
              }}
              placeholder="weather-service"
            />
            <span className="sg-field__hint">Globally unique. Used in the live endpoint URL.</span>
          </div>
          <div className="sg-field">
            <label htmlFor="mock-prompt">Prompt</label>
            <textarea
              id="mock-prompt"
              value={prompt}
              onChange={(e) => setPrompt(e.target.value)}
              placeholder="Describe what this MCP server should do. The LLM generates tool definitions from this and answers tool calls."
              rows={8}
            />
          </div>
          <div className="sg-field">
            <label htmlFor="mock-llm">Active LLM</label>
            {llms.length === 0 ? (
              <span className="sg-field__hint">
                No LLM connections yet —{' '}
                <Link href={`/app/${orgId}/mock-mcp/llms`}>add one</Link> to use a specific
                provider/key. Leaving this empty uses the server default.
              </span>
            ) : (
              <select id="mock-llm" value={activeLlmId} onChange={(e) => setActiveLlmId(e.target.value)}>
                <option value="">Server default</option>
                {llms.map((l) => (
                  <option key={l.id} value={l.id}>
                    {l.label} ({l.provider}/{l.model})
                  </option>
                ))}
              </select>
            )}
          </div>
          <div className="sg-field">
            <label htmlFor="mock-project">Project</label>
            <select id="mock-project" value={projectId} onChange={(e) => setProjectId(e.target.value)}>
              <option value="">No project</option>
              {projects.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.name}
                </option>
              ))}
            </select>
            <span className="sg-field__hint">Optional — scope this mock to a project.</span>
          </div>
          {error && <div className="sg-error">{error}</div>}
          <div className="modal-actions">
            <button type="button" className="sg-btn sg-btn--outline" onClick={onClose}>
              Cancel
            </button>
            <button
              type="submit"
              className="sg-btn sg-btn--black"
              disabled={saving || !title.trim() || !prompt.trim() || !effectiveSlug}
            >
              {saving ? 'Saving…' : 'Create'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default function MockMcpPage() {
  const { orgId, loading: orgLoading } = useOrgId();
  const { currentProject, switchProject } = useOrg();
  const [defs, setDefs] = useState<MockMCPDefinition[]>([]);
  const [projects, setProjects] = useState<Project[]>([]);
  const [llms, setLlms] = useState<MockMCPLLM[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);

  const scopeProjectId = currentProject?.id;

  const fetchData = useCallback(async () => {
    if (!orgId) return;
    try {
      const [defData, projectData, llmData] = await Promise.all([
        api.listMockMcp(orgId, scopeProjectId ? { projectId: scopeProjectId } : undefined),
        api.listProjects(orgId),
        api.listMockMcpLlms(orgId),
      ]);
      setDefs(defData.definitions ?? []);
      setProjects(projectData.projects ?? []);
      setLlms(llmData.llms ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load mock MCPs');
    } finally {
      setLoading(false);
    }
  }, [orgId, scopeProjectId]);

  useEffect(() => {
    if (orgId) {
      fetchData();
    } else if (!orgLoading) {
      setLoading(false);
    }
  }, [fetchData, orgId, orgLoading]);

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">Mock MCP</h1>
          {currentProject && (
            <span className="scope-chip">
              Project: <strong>{currentProject.name}</strong>
              <button
                type="button"
                className="scope-chip__clear"
                onClick={() => switchProject(null)}
                aria-label="Clear project scope"
                title="Show all projects"
              >
                ×
              </button>
            </span>
          )}
        </div>
        <p className="sg-page-intro">
          LLM-driven pseudo MCP servers. Describe a server in a prompt; the model generates its tools
          and answers tool calls live.{' '}
          {orgId && <Link href={`/app/${orgId}/mock-mcp/llms`}>Manage LLM connections →</Link>}
        </p>

        {loading ? (
          <p className="sg-page-intro">Loading…</p>
        ) : defs.length === 0 ? (
          <div className="projects-empty">
            <p className="projects-empty__text">No mock MCPs yet. Create one to get started.</p>
            <button className="sg-btn sg-btn--black" onClick={() => setShowModal(true)}>
              New Mock MCP
            </button>
          </div>
        ) : (
          <div className="projects-grid">
            {defs.map((d) => (
              <Link key={d.id} href={`/app/${orgId}/mock-mcp/${d.slug}`} className="project-card">
                <div className="project-card__header">
                  <div className="project-card__name">{d.title}</div>
                </div>
                <div className="project-card__body">
                  <dl className="project-card__fields">
                    <div className="project-card__field">
                      <dt>Slug:</dt>
                      <dd className="font-mono">{d.slug}</dd>
                    </div>
                    <div className="project-card__field">
                      <dt>Tools:</dt>
                      <dd>{d.tool_count ?? d.tools_json?.length ?? 0}</dd>
                    </div>
                    <div className="project-card__field">
                      <dt>LLM:</dt>
                      <dd>{d.active_llm ? `${d.active_llm.label}` : 'server default'}</dd>
                    </div>
                  </dl>
                  <div className="project-card__meta">
                    <span className="project-card__status">{d.status}</span>
                    <span className="project-card__time">{timeAgo(d.updated_at)}</span>
                  </div>
                </div>
              </Link>
            ))}
          </div>
        )}
      </main>

      {showModal && orgId && (
        <CreateModal
          orgId={orgId}
          projects={projects}
          llms={llms}
          defaultProjectId={scopeProjectId}
          onClose={() => setShowModal(false)}
          onSaved={() => {
            setShowModal(false);
            fetchData();
          }}
        />
      )}

      {!loading && defs.length > 0 && (
        <button className="fab" onClick={() => setShowModal(true)} aria-label="New mock MCP" title="New mock MCP">
          <PlusIcon />
        </button>
      )}
    </div>
  );
}
