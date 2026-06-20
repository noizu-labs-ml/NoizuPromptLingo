'use client';

import { useState, useEffect, useCallback } from 'react';
import { toast } from 'sonner';
import { PlusIcon } from '@heroicons/react/24/outline';
import {
  api,
  type AssetEntry,
  type AssetOutput,
  type Project,
  ASSET_TYPES,
  type AssetType,
} from '@/lib/api';
import { useOrg, useOrgId } from '@/context/org';

const QUALITIES = ['low', 'medium', 'high'];

const PROMPT_TEMPLATE = `type: image
title: ""
prompt:
  text: |
    Describe the asset to generate.
  style: ""
constraints:
  size: ""
`;

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

function AssetModal({
  orgId,
  projects,
  defaultProjectId,
  asset,
  onClose,
  onSaved,
}: {
  orgId: string;
  projects: Project[];
  defaultProjectId?: string;
  asset?: AssetEntry | null;
  onClose: () => void;
  onSaved: () => void;
}) {
  const isEdit = !!asset;
  const [slug, setSlug] = useState(asset?.slug ?? '');
  const [title, setTitle] = useState(asset?.title ?? '');
  const [assetType, setAssetType] = useState<AssetType>((asset?.asset_type as AssetType) ?? 'image');
  const [quality, setQuality] = useState(asset?.quality ?? '');
  const [promptYaml, setPromptYaml] = useState(asset?.prompt_yaml ?? PROMPT_TEMPLATE);
  const [tags, setTags] = useState((asset?.tags ?? []).join(', '));
  const [projectId, setProjectId] = useState(asset?.project_id ?? defaultProjectId ?? '');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!title.trim() || (!isEdit && !slug.trim()) || !promptYaml.trim()) return;
    setSaving(true);
    setError(null);
    try {
      const payload = {
        title: title.trim(),
        asset_type: assetType,
        quality: quality || null,
        prompt_yaml: promptYaml,
        tags: tags.split(',').map((t) => t.trim()).filter(Boolean),
        project_id: projectId || null,
      };
      if (isEdit && asset) {
        await api.updateAsset(orgId, asset.id, payload);
      } else {
        await api.createAsset(orgId, { ...payload, slug: slug.trim() });
      }
      toast.success(isEdit ? 'Asset updated' : 'Asset created');
      onSaved();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Request failed');
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-card modal-card--lg" onClick={(e) => e.stopPropagation()}>
        <h2 className="modal-title">{isEdit ? 'Edit Asset Prompt' : 'New Asset Prompt'}</h2>
        <form onSubmit={handleSubmit}>
          <div className="sg-field">
            <label htmlFor="a-slug">Slug</label>
            <input id="a-slug" value={slug} onChange={(e) => setSlug(e.target.value)} placeholder="hero-banner" disabled={isEdit} />
          </div>
          <div className="sg-field">
            <label htmlFor="a-title">Title</label>
            <input id="a-title" value={title} onChange={(e) => setTitle(e.target.value)} placeholder="Hero Banner" autoFocus />
          </div>
          <div className="sg-field">
            <label htmlFor="a-type">Asset type</label>
            <select id="a-type" value={assetType} onChange={(e) => setAssetType(e.target.value as AssetType)} disabled={isEdit}>
              {ASSET_TYPES.map((t) => (
                <option key={t} value={t}>
                  {t}
                </option>
              ))}
            </select>
          </div>
          <div className="sg-field">
            <label htmlFor="a-quality">Quality</label>
            <select id="a-quality" value={quality} onChange={(e) => setQuality(e.target.value)}>
              <option value="">—</option>
              {QUALITIES.map((q) => (
                <option key={q} value={q}>
                  {q}
                </option>
              ))}
            </select>
          </div>
          <div className="sg-field">
            <label htmlFor="a-prompt">Prompt (.media.prompt YAML)</label>
            <textarea id="a-prompt" value={promptYaml} onChange={(e) => setPromptYaml(e.target.value)} rows={12} className="font-mono" />
          </div>
          <div className="sg-field">
            <label htmlFor="a-tags">Tags</label>
            <input id="a-tags" value={tags} onChange={(e) => setTags(e.target.value)} placeholder="comma, separated" />
          </div>
          <div className="sg-field">
            <label htmlFor="a-project">Project</label>
            <select id="a-project" value={projectId} onChange={(e) => setProjectId(e.target.value)}>
              <option value="">No project</option>
              {projects.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.name}
                </option>
              ))}
            </select>
            <span className="sg-field__hint">Optional — scope this asset to a project.</span>
          </div>
          {error && <div className="sg-error">{error}</div>}
          <div className="modal-actions">
            <button type="button" className="sg-btn sg-btn--outline" onClick={onClose}>
              Cancel
            </button>
            <button type="submit" className="sg-btn sg-btn--black" disabled={saving || !title.trim() || (!isEdit && !slug.trim())}>
              {saving ? 'Saving…' : isEdit ? 'Save' : 'Create'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

function OutputsModal({ orgId, asset, onClose }: { orgId: string; asset: AssetEntry; onClose: () => void }) {
  const [outputs, setOutputs] = useState<AssetOutput[]>([]);
  const [loading, setLoading] = useState(true);
  const [generating, setGenerating] = useState(false);
  const [viewing, setViewing] = useState<{ id: string; content: string } | null>(null);

  const load = useCallback(async () => {
    try {
      const { outputs } = await api.listAssetOutputs(orgId, asset.id);
      setOutputs(outputs ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load outputs');
    } finally {
      setLoading(false);
    }
  }, [orgId, asset.id]);

  useEffect(() => {
    load();
  }, [load]);

  async function generate() {
    setGenerating(true);
    try {
      await api.generateAsset(orgId, asset.id);
      toast.success('Generated output');
      await load();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Generation failed');
    } finally {
      setGenerating(false);
    }
  }

  async function viewContent(o: AssetOutput) {
    if (!o.artifact_id) return;
    try {
      const { artifact } = await api.getArtifact(orgId, o.artifact_id);
      setViewing({ id: o.id, content: artifact.content ?? '(no content)' });
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to fetch artifact');
    }
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-card modal-card--lg" onClick={(e) => e.stopPropagation()}>
        <h2 className="modal-title">Outputs — {asset.title}</h2>
        <div className="modal-actions" style={{ justifyContent: 'flex-start', marginTop: 0 }}>
          <button className="sg-btn sg-btn--primary sg-btn--sm" onClick={generate} disabled={generating}>
            {generating ? 'Generating…' : 'Generate'}
          </button>
        </div>
        {loading ? (
          <p className="sg-page-intro">Loading…</p>
        ) : outputs.length === 0 ? (
          <p className="sg-page-intro">No outputs yet. Generate one.</p>
        ) : (
          <ul className="asset-outputs">
            {outputs.map((o) => (
              <li key={o.id} className="asset-outputs__row">
                <div className="asset-outputs__main">
                  <span className="asset-outputs__variant">v{o.variant_number}</span>
                  <span className={`project-card__status${o.status === 'accepted' ? ' project-card__status--active' : ''}`}>{o.status}</span>
                  {o.provider && <span className="sg-field__hint">{o.provider}</span>}
                </div>
                <div className="asset-outputs__actions">
                  {o.artifact_id && (
                    <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => viewContent(o)}>
                      View
                    </button>
                  )}
                  <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => api.acceptAssetOutput(orgId, asset.id, o.id).then(load)}>
                    Accept
                  </button>
                  <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => api.rejectAssetOutput(orgId, asset.id, o.id).then(load)}>
                    Reject
                  </button>
                  <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => api.setActiveAssetOutput(orgId, asset.id, o.id).then(() => toast.success('Set active'))}>
                    Set active
                  </button>
                </div>
                {viewing?.id === o.id && <pre className="asset-outputs__content">{viewing.content}</pre>}
              </li>
            ))}
          </ul>
        )}
        <div className="modal-actions">
          <button type="button" className="sg-btn sg-btn--outline" onClick={onClose}>
            Close
          </button>
        </div>
      </div>
    </div>
  );
}

type ModalState = { kind: 'create' } | { kind: 'edit'; asset: AssetEntry } | { kind: 'outputs'; asset: AssetEntry } | null;

export default function AssetsPage() {
  const { orgId, loading: orgLoading } = useOrgId();
  const { currentProject, switchProject } = useOrg();
  const [assets, setAssets] = useState<AssetEntry[]>([]);
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState<ModalState>(null);

  const scopeProjectId = currentProject?.id;

  const fetchData = useCallback(async () => {
    if (!orgId) return;
    try {
      const [assetData, projectData] = await Promise.all([
        api.listAssets(orgId, scopeProjectId ? { projectId: scopeProjectId } : undefined),
        api.listProjects(orgId),
      ]);
      setAssets(assetData.assets ?? []);
      setProjects(projectData.projects ?? []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load assets');
    } finally {
      setLoading(false);
    }
  }, [orgId, scopeProjectId]);

  useEffect(() => {
    if (orgId) fetchData();
    else if (!orgLoading) setLoading(false);
  }, [fetchData, orgId, orgLoading]);

  async function handleDelete(asset: AssetEntry) {
    if (!orgId) return;
    if (!confirm(`Delete asset "${asset.title}"?`)) return;
    try {
      await api.deleteAsset(orgId, asset.id);
      toast.success('Asset deleted');
      fetchData();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to delete');
    }
  }

  const projectName = (id?: string | null) => (id ? projects.find((p) => p.id === id)?.name ?? '—' : null);

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">Assets</h1>
          {currentProject && (
            <span className="scope-chip">
              Project: <strong>{currentProject.name}</strong>
              <button type="button" className="scope-chip__clear" onClick={() => switchProject(null)} title="Show all projects">
                ×
              </button>
            </span>
          )}
        </div>
        <p className="sg-page-intro">Media-prompt assets — save prompts, generate items, and fetch the generated output.</p>

        {loading ? (
          <p className="sg-page-intro">Loading…</p>
        ) : assets.length === 0 ? (
          <div className="projects-empty">
            <p className="projects-empty__text">No assets yet. Create a media prompt to get started.</p>
            <button className="sg-btn sg-btn--black" onClick={() => setModal({ kind: 'create' })}>
              New Asset
            </button>
          </div>
        ) : (
          <div className="projects-grid">
            {assets.map((a) => (
              <div key={a.id} className="project-card">
                <div className="project-card__header">
                  {projectName(a.project_id) && <div className="project-card__org">{projectName(a.project_id)}</div>}
                  <div className="project-card__name">{a.title}</div>
                </div>
                <div className="project-card__body">
                  <dl className="project-card__fields">
                    <div className="project-card__field">
                      <dt>Type:</dt>
                      <dd>{a.asset_type}</dd>
                    </div>
                    <div className="project-card__field">
                      <dt>Slug:</dt>
                      <dd className="font-mono">{a.slug}</dd>
                    </div>
                  </dl>
                  <div className="project-card__meta">
                    <span className="project-card__status">{a.status}</span>
                    <span className="project-card__time">{timeAgo(a.inserted_at)}</span>
                  </div>
                  <div className="project-card__actions">
                    <button className="sg-btn sg-btn--primary sg-btn--sm" onClick={() => setModal({ kind: 'outputs', asset: a })}>
                      Outputs
                    </button>
                    <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => setModal({ kind: 'edit', asset: a })}>
                      Edit
                    </button>
                    <button className="sg-btn sg-btn--danger sg-btn--sm" onClick={() => handleDelete(a)}>
                      Delete
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>

      {modal?.kind === 'outputs' && orgId && (
        <OutputsModal orgId={orgId} asset={modal.asset} onClose={() => setModal(null)} />
      )}
      {(modal?.kind === 'create' || modal?.kind === 'edit') && orgId && (
        <AssetModal
          orgId={orgId}
          projects={projects}
          defaultProjectId={scopeProjectId}
          asset={modal.kind === 'edit' ? modal.asset : null}
          onClose={() => setModal(null)}
          onSaved={() => {
            setModal(null);
            fetchData();
          }}
        />
      )}

      {!loading && assets.length > 0 && (
        <button className="fab" onClick={() => setModal({ kind: 'create' })} aria-label="New asset" title="New asset">
          <PlusIcon />
        </button>
      )}
    </div>
  );
}
