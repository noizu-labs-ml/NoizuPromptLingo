'use client';

import { useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { toast } from 'sonner';
import {
  api,
  type McpPrompt,
  type McpPromptArgument,
  type McpResource,
  type McpResourceTemplate,
} from '@/lib/api';

type Tab = 'prompts' | 'resources' | 'templates';

type PromptForm = {
  originalSlug?: string;
  slug: string;
  name: string;
  description: string;
  arguments: McpPromptArgument[];
  template: string;
  changeNote: string;
};

type ResourceForm = {
  originalId?: string;
  uri: string;
  name: string;
  description: string;
  mimeType: string;
  content: string;
};

type TemplateForm = {
  originalId?: string;
  uriTemplate: string;
  name: string;
  description: string;
  mimeType: string;
};

function slugify(value: string) {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 63);
}

function parseArguments(value: string): McpPromptArgument[] {
  return value
    .split(',')
    .map((entry) => entry.trim())
    .filter(Boolean)
    .map((entry) => {
      const required = entry.endsWith('*');
      const name = required ? entry.slice(0, -1) : entry;
      return { name, required };
    });
}

function formatArguments(args: McpPromptArgument[]) {
  return args.map((a) => `${a.name}${a.required ? '*' : ''}`).join(', ');
}

export default function AdminMcpEntitiesPage() {
  const [tab, setTab] = useState<Tab>('prompts');
  const [prompts, setPrompts] = useState<McpPrompt[]>([]);
  const [resources, setResources] = useState<McpResource[]>([]);
  const [templates, setTemplates] = useState<McpResourceTemplate[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  const [promptForm, setPromptForm] = useState<PromptForm>({
    slug: '',
    name: '',
    description: '',
    arguments: [],
    template: '',
    changeNote: '',
  });
  const [resourceForm, setResourceForm] = useState<ResourceForm>({
    uri: '',
    name: '',
    description: '',
    mimeType: 'text/plain',
    content: '',
  });
  const [templateForm, setTemplateForm] = useState<TemplateForm>({
    uriTemplate: '',
    name: '',
    description: '',
    mimeType: 'text/plain',
  });

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const [p, r, t] = await Promise.all([
        api.listMcpPrompts(),
        api.listMcpResources(),
        api.listMcpResourceTemplates(),
      ]);
      setPrompts(p.prompts ?? []);
      setResources(r.resources ?? []);
      setTemplates(t.templates ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load MCP entities');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  function selectPrompt(prompt: McpPrompt) {
    setPromptForm({
      originalSlug: prompt.slug,
      slug: prompt.slug,
      name: prompt.name,
      description: prompt.description ?? '',
      arguments: prompt.arguments ?? [],
      template: '',
      changeNote: '',
    });
  }

  async function savePrompt(e: React.FormEvent) {
    e.preventDefault();
    if (!promptForm.name.trim() || !promptForm.slug.trim()) {
      toast.error('Name and slug are required');
      return;
    }
    setSaving(true);
    try {
      if (promptForm.originalSlug) {
        const res = await api.updateMcpPrompt(promptForm.originalSlug, {
          name: promptForm.name.trim(),
          description: promptForm.description.trim(),
          arguments: promptForm.arguments,
        });
        setPrompts((prev) =>
          prev.map((p) => (p.id === res.prompt.id ? res.prompt : p)),
        );
      } else {
        const res = await api.createMcpPrompt({
          slug: promptForm.slug.trim(),
          name: promptForm.name.trim(),
          description: promptForm.description.trim(),
          arguments: promptForm.arguments,
        });
        setPrompts((prev) => [res.prompt, ...prev]);
      }
      toast.success('Prompt saved');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Save failed');
    } finally {
      setSaving(false);
    }
  }

  async function publishPromptVersion(e: React.FormEvent) {
    e.preventDefault();
    const slug = promptForm.originalSlug;
    if (!slug) {
      toast.error('Save the prompt before publishing versions');
      return;
    }
    if (!promptForm.template.trim()) {
      toast.error('Template body is required');
      return;
    }
    setSaving(true);
    try {
      const res = await api.publishMcpPromptVersion(
        slug,
        promptForm.template,
        promptForm.changeNote.trim() || undefined,
      );
      setPrompts((prev) => prev.map((p) => (p.id === res.prompt.id ? res.prompt : p)));
      setPromptForm((f) => ({ ...f, template: '', changeNote: '' }));
      toast.success(`Version ${res.prompt.active_version} published`);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Publish failed');
    } finally {
      setSaving(false);
    }
  }

  async function deletePrompt(slug: string) {
    if (!confirm(`Delete prompt ${slug} (all versions)?`)) return;
    try {
      await api.deleteMcpPrompt(slug);
      setPrompts((prev) => prev.filter((p) => p.slug !== slug));
      if (promptForm.originalSlug === slug) {
        setPromptForm({ slug: '', name: '', description: '', arguments: [], template: '', changeNote: '' });
      }
      toast.success('Prompt deleted');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Delete failed');
    }
  }

  async function saveResource(e: React.FormEvent) {
    e.preventDefault();
    if (!resourceForm.uri.trim() || !resourceForm.name.trim() || !resourceForm.content.trim()) {
      toast.error('URI, name and content are required');
      return;
    }
    setSaving(true);
    try {
      if (resourceForm.originalId) {
        const res = await api.updateMcpResource(resourceForm.originalId, {
          uri: resourceForm.uri.trim(),
          name: resourceForm.name.trim(),
          description: resourceForm.description.trim(),
          mime_type: resourceForm.mimeType.trim() || 'text/plain',
          content: resourceForm.content,
        });
        setResources((prev) => prev.map((r) => (r.id === res.resource.id ? res.resource : r)));
      } else {
        const res = await api.createMcpResource({
          uri: resourceForm.uri.trim(),
          name: resourceForm.name.trim(),
          description: resourceForm.description.trim(),
          mime_type: resourceForm.mimeType.trim() || 'text/plain',
          content: resourceForm.content,
        });
        setResources((prev) => [res.resource, ...prev]);
      }
      toast.success('Resource saved');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Save failed');
    } finally {
      setSaving(false);
    }
  }

  async function deleteResource(id: string) {
    if (!confirm('Delete this resource?')) return;
    try {
      await api.deleteMcpResource(id);
      setResources((prev) => prev.filter((r) => r.id !== id));
      toast.success('Resource deleted');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Delete failed');
    }
  }

  async function saveTemplate(e: React.FormEvent) {
    e.preventDefault();
    if (!templateForm.uriTemplate.trim() || !templateForm.name.trim()) {
      toast.error('URI template and name are required');
      return;
    }
    setSaving(true);
    try {
      if (templateForm.originalId) {
        const res = await api.updateMcpResourceTemplate(templateForm.originalId, {
          uri_template: templateForm.uriTemplate.trim(),
          name: templateForm.name.trim(),
          description: templateForm.description.trim(),
          mime_type: templateForm.mimeType.trim() || 'text/plain',
        });
        setTemplates((prev) => prev.map((t) => (t.id === res.template.id ? res.template : t)));
      } else {
        const res = await api.createMcpResourceTemplate({
          uri_template: templateForm.uriTemplate.trim(),
          name: templateForm.name.trim(),
          description: templateForm.description.trim(),
          mime_type: templateForm.mimeType.trim() || 'text/plain',
        });
        setTemplates((prev) => [res.template, ...prev]);
      }
      toast.success('Template saved');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Save failed');
    } finally {
      setSaving(false);
    }
  }

  async function deleteTemplate(id: string) {
    if (!confirm('Delete this template?')) return;
    try {
      await api.deleteMcpResourceTemplate(id);
      setTemplates((prev) => prev.filter((t) => t.id !== id));
      toast.success('Template deleted');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Delete failed');
    }
  }

  const tabs: { id: Tab; label: string }[] = [
    { id: 'prompts', label: `Prompts (${prompts.length})` },
    { id: 'resources', label: `Resources (${resources.length})` },
    { id: 'templates', label: `Templates (${templates.length})` },
  ];

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">MCP entities</h1>
        </div>
        <p className="sg-page-intro">
          Manage the MCP <strong>prompts</strong> (versioned templates) and{' '}
          <strong>resources</strong> / <strong>resource templates</strong> served by
          custom endpoints that include the <span className="font-mono">prompts</span> /
          <span className="font-mono">resources</span> groups.{' '}
          <Link href="/app/admin">Back to Admin</Link>
        </p>

        <div style={{ display: 'flex', gap: 8, marginBottom: '1rem' }}>
          {tabs.map((t) => (
            <button
              key={t.id}
              className={`sg-btn sg-btn--sm ${tab === t.id ? 'sg-btn--black' : 'sg-btn--outline'}`}
              onClick={() => setTab(t.id)}
            >
              {t.label}
            </button>
          ))}
        </div>

        {loading ? (
          <p className="sg-page-intro">Loading...</p>
        ) : tab === 'prompts' ? (
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(min(100%, 320px), 1fr))', gap: '1rem', alignItems: 'start' }}>
            <section className="dash-panel">
              <div className="dash-panel__head">
                <h2 className="dash-panel__title">Prompts</h2>
                <button
                  className="sg-btn sg-btn--outline sg-btn--sm"
                  onClick={() => setPromptForm({ slug: '', name: '', description: '', arguments: [], template: '', changeNote: '' })}
                >
                  New prompt
                </button>
              </div>
              {prompts.length === 0 ? (
                <p className="sg-page-intro">No prompts yet.</p>
              ) : (
                <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                  {prompts.map((p) => (
                    <div key={p.id} style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
                      <button
                        className={`sg-btn ${promptForm.originalSlug === p.slug ? 'sg-btn--black' : 'sg-btn--outline'}`}
                        style={{ justifyContent: 'flex-start', textAlign: 'left', flex: 1 }}
                        onClick={() => selectPrompt(p)}
                      >
                        <span>
                          <span style={{ display: 'block', fontWeight: 600 }}>{p.name}</span>
                          <span className="font-mono" style={{ display: 'block', fontSize: 12 }}>
                            {p.slug} · v{p.active_version}
                          </span>
                        </span>
                      </button>
                      <button className="sg-btn sg-btn--danger sg-btn--sm" onClick={() => deletePrompt(p.slug)}>
                        Delete
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </section>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
              <form className="dash-panel" onSubmit={savePrompt}>
                <div className="dash-panel__head">
                  <h2 className="dash-panel__title">{promptForm.originalSlug ? 'Edit Prompt' : 'New Prompt'}</h2>
                </div>
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '1rem' }}>
                  <div className="sg-field">
                    <label htmlFor="mp-name">Name</label>
                    <input
                      id="mp-name"
                      value={promptForm.name}
                      onChange={(e) =>
                        setPromptForm((c) => ({
                          ...c,
                          name: e.target.value,
                          slug: c.originalSlug ? c.slug : slugify(e.target.value),
                        }))
                      }
                    />
                  </div>
                  <div className="sg-field">
                    <label htmlFor="mp-slug">Slug</label>
                    <input
                      id="mp-slug"
                      value={promptForm.slug}
                      disabled={!!promptForm.originalSlug}
                      onChange={(e) => setPromptForm((c) => ({ ...c, slug: slugify(e.target.value) }))}
                    />
                  </div>
                </div>
                <div className="sg-field">
                  <label htmlFor="mp-desc">Description</label>
                  <textarea
                    id="mp-desc"
                    rows={2}
                    value={promptForm.description}
                    onChange={(e) => setPromptForm((c) => ({ ...c, description: e.target.value }))}
                  />
                </div>
                <div className="sg-field">
                  <label htmlFor="mp-args">Arguments (comma-separated; * = required)</label>
                  <input
                    id="mp-args"
                    value={formatArguments(promptForm.arguments)}
                    onChange={(e) => setPromptForm((c) => ({ ...c, arguments: parseArguments(e.target.value) }))}
                    placeholder="version*, summary"
                  />
                </div>
                <div className="modal-actions">
                  <button type="submit" className="sg-btn sg-btn--black" disabled={saving}>
                    {saving ? 'Saving...' : 'Save Prompt'}
                  </button>
                </div>
              </form>

              {promptForm.originalSlug && (
                <form className="dash-panel" onSubmit={publishPromptVersion}>
                  <div className="dash-panel__head">
                    <h2 className="dash-panel__title">Publish Version</h2>
                    <span className="sg-field__hint">active: v{prompts.find((p) => p.slug === promptForm.originalSlug)?.active_version}</span>
                  </div>
                  <div className="sg-field">
                    <label htmlFor="mp-template">Template body (use {'{{arg}}'} placeholders)</label>
                    <textarea
                      id="mp-template"
                      rows={6}
                      value={promptForm.template}
                      onChange={(e) => setPromptForm((c) => ({ ...c, template: e.target.value }))}
                    />
                  </div>
                  <div className="sg-field">
                    <label htmlFor="mp-note">Change note</label>
                    <input
                      id="mp-note"
                      value={promptForm.changeNote}
                      onChange={(e) => setPromptForm((c) => ({ ...c, changeNote: e.target.value }))}
                    />
                  </div>
                  <div className="modal-actions">
                    <button type="submit" className="sg-btn sg-btn--black" disabled={saving}>
                      Publish Version
                    </button>
                  </div>
                </form>
              )}
            </div>
          </div>
        ) : tab === 'resources' ? (
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(min(100%, 320px), 1fr))', gap: '1rem', alignItems: 'start' }}>
            <section className="dash-panel">
              <div className="dash-panel__head">
                <h2 className="dash-panel__title">Resources</h2>
              </div>
              {resources.length === 0 ? (
                <p className="sg-page-intro">No resources yet.</p>
              ) : (
                <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                  {resources.map((r) => (
                    <div key={r.id} style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
                      <button
                        className={`sg-btn ${resourceForm.originalId === r.id ? 'sg-btn--black' : 'sg-btn--outline'}`}
                        style={{ justifyContent: 'flex-start', textAlign: 'left', flex: 1 }}
                        onClick={() =>
                          setResourceForm({
                            originalId: r.id,
                            uri: r.uri,
                            name: r.name,
                            description: r.description ?? '',
                            mimeType: r.mime_type ?? 'text/plain',
                            content: r.content ?? '',
                          })
                        }
                      >
                        <span>
                          <span style={{ display: 'block', fontWeight: 600 }}>{r.name}</span>
                          <span className="font-mono" style={{ display: 'block', fontSize: 12 }}>{r.uri}</span>
                        </span>
                      </button>
                      <button className="sg-btn sg-btn--danger sg-btn--sm" onClick={() => deleteResource(r.id)}>
                        Delete
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </section>

            <form className="dash-panel" onSubmit={saveResource}>
              <div className="dash-panel__head">
                <h2 className="dash-panel__title">{resourceForm.originalId ? 'Edit Resource' : 'New Resource'}</h2>
                {resourceForm.originalId && (
                  <button
                    type="button"
                    className="sg-btn sg-btn--outline sg-btn--sm"
                    onClick={() => setResourceForm({ uri: '', name: '', description: '', mimeType: 'text/plain', content: '' })}
                  >
                    New
                  </button>
                )}
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '1rem' }}>
                <div className="sg-field">
                  <label htmlFor="mr-uri">URI</label>
                  <input id="mr-uri" value={resourceForm.uri} onChange={(e) => setResourceForm((c) => ({ ...c, uri: e.target.value }))} />
                </div>
                <div className="sg-field">
                  <label htmlFor="mr-name">Name</label>
                  <input id="mr-name" value={resourceForm.name} onChange={(e) => setResourceForm((c) => ({ ...c, name: e.target.value }))} />
                </div>
                <div className="sg-field">
                  <label htmlFor="mr-mime">MIME type</label>
                  <input id="mr-mime" value={resourceForm.mimeType} onChange={(e) => setResourceForm((c) => ({ ...c, mimeType: e.target.value }))} />
                </div>
              </div>
              <div className="sg-field">
                <label htmlFor="mr-desc">Description</label>
                <textarea id="mr-desc" rows={2} value={resourceForm.description} onChange={(e) => setResourceForm((c) => ({ ...c, description: e.target.value }))} />
              </div>
              <div className="sg-field">
                <label htmlFor="mr-content">Content (served via resources/read)</label>
                <textarea id="mr-content" rows={6} value={resourceForm.content} onChange={(e) => setResourceForm((c) => ({ ...c, content: e.target.value }))} />
              </div>
              <div className="modal-actions">
                <button type="submit" className="sg-btn sg-btn--black" disabled={saving}>
                  {saving ? 'Saving...' : 'Save Resource'}
                </button>
              </div>
            </form>
          </div>
        ) : (
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(min(100%, 320px), 1fr))', gap: '1rem', alignItems: 'start' }}>
            <section className="dash-panel">
              <div className="dash-panel__head">
                <h2 className="dash-panel__title">Resource Templates</h2>
              </div>
              {templates.length === 0 ? (
                <p className="sg-page-intro">No templates yet.</p>
              ) : (
                <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                  {templates.map((t) => (
                    <div key={t.id} style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
                      <button
                        className={`sg-btn ${templateForm.originalId === t.id ? 'sg-btn--black' : 'sg-btn--outline'}`}
                        style={{ justifyContent: 'flex-start', textAlign: 'left', flex: 1 }}
                        onClick={() =>
                          setTemplateForm({
                            originalId: t.id,
                            uriTemplate: t.uri_template,
                            name: t.name,
                            description: t.description ?? '',
                            mimeType: t.mime_type ?? 'text/plain',
                          })
                        }
                      >
                        <span>
                          <span style={{ display: 'block', fontWeight: 600 }}>{t.name}</span>
                          <span className="font-mono" style={{ display: 'block', fontSize: 12 }}>{t.uri_template}</span>
                        </span>
                      </button>
                      <button className="sg-btn sg-btn--danger sg-btn--sm" onClick={() => deleteTemplate(t.id)}>
                        Delete
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </section>

            <form className="dash-panel" onSubmit={saveTemplate}>
              <div className="dash-panel__head">
                <h2 className="dash-panel__title">{templateForm.originalId ? 'Edit Template' : 'New Template'}</h2>
                {templateForm.originalId && (
                  <button
                    type="button"
                    className="sg-btn sg-btn--outline sg-btn--sm"
                    onClick={() => setTemplateForm({ uriTemplate: '', name: '', description: '', mimeType: 'text/plain' })}
                  >
                    New
                  </button>
                )}
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '1rem' }}>
                <div className="sg-field">
                  <label htmlFor="mt-uri">URI template (must contain {'{param}'})</label>
                  <input id="mt-uri" value={templateForm.uriTemplate} onChange={(e) => setTemplateForm((c) => ({ ...c, uriTemplate: e.target.value }))} />
                </div>
                <div className="sg-field">
                  <label htmlFor="mt-name">Name</label>
                  <input id="mt-name" value={templateForm.name} onChange={(e) => setTemplateForm((c) => ({ ...c, name: e.target.value }))} />
                </div>
                <div className="sg-field">
                  <label htmlFor="mt-mime">MIME type</label>
                  <input id="mt-mime" value={templateForm.mimeType} onChange={(e) => setTemplateForm((c) => ({ ...c, mimeType: e.target.value }))} />
                </div>
              </div>
              <div className="sg-field">
                <label htmlFor="mt-desc">Description</label>
                <textarea id="mt-desc" rows={2} value={templateForm.description} onChange={(e) => setTemplateForm((c) => ({ ...c, description: e.target.value }))} />
              </div>
              <div className="modal-actions">
                <button type="submit" className="sg-btn sg-btn--black" disabled={saving}>
                  {saving ? 'Saving...' : 'Save Template'}
                </button>
              </div>
            </form>
          </div>
        )}
      </main>
    </div>
  );
}
