'use client';

import { useState, useEffect, useCallback, useMemo } from 'react';
import { toast } from 'sonner';
import {
  PlusIcon,
  TrashIcon,
  ChevronRightIcon,
  PencilSquareIcon,
  DocumentPlusIcon,
  Cog6ToothIcon,
} from '@heroicons/react/24/outline';
import { api, type WikiSpace, type WikiPage, type WikiPageSummary } from '@/lib/api';
import { useOrg, useOrgId } from '@/context/org';
import { Markdown } from '@/components/markdown';
import { MarkdownEditor } from '@/components/markdown-editor';

const REACTION_EMOJI = ['👍', '🎉', '❤️', '🚀', '👀', '✅'];

function toSlug(name: string) {
  return name.toLowerCase().trim().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '').replace(/^-+|-+$/g, '');
}

// ── Page-tree types ───────────────────────────────────────────────────────
interface TreeNode {
  page: WikiPageSummary;
  children: TreeNode[];
}

function buildTree(pages: WikiPageSummary[]): TreeNode[] {
  const byId = new Map<string, TreeNode>();
  pages.forEach((p) => byId.set(p.id, { page: p, children: [] }));
  const roots: TreeNode[] = [];
  pages.forEach((p) => {
    const node = byId.get(p.id)!;
    const parent = p.parent_id ? byId.get(p.parent_id) : undefined;
    if (parent) parent.children.push(node);
    else roots.push(node);
  });
  return roots;
}

// ── Space create/edit modal ───────────────────────────────────────────────
function SpaceModal({
  orgId,
  space,
  defaultProjectId,
  onClose,
  onSaved,
}: {
  orgId: string;
  space?: WikiSpace | null;
  defaultProjectId?: string;
  onClose: () => void;
  onSaved: (space: WikiSpace) => void;
}) {
  const isEdit = !!space;
  const [name, setName] = useState(space?.name ?? '');
  const [slug, setSlug] = useState(space?.slug ?? '');
  const [description, setDescription] = useState(space?.description ?? '');
  const [slugTouched, setSlugTouched] = useState(isEdit);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim()) return;
    setSaving(true);
    setError(null);
    try {
      const payload = {
        name: name.trim(),
        slug: slug.trim() || toSlug(name),
        description: description.trim(),
        ...(isEdit ? {} : { project_id: defaultProjectId ?? null }),
      };
      const res = isEdit && space
        ? await api.updateWikiSpace(orgId, space.id, payload)
        : await api.createWikiSpace(orgId, payload);
      toast.success(isEdit ? 'Space updated' : 'Space created');
      onSaved(res.space);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Request failed');
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-card" onClick={(e) => e.stopPropagation()}>
        <h2 className="modal-title">{isEdit ? 'Edit Space' : 'Create Space'}</h2>
        <form onSubmit={handleSubmit}>
          <div className="sg-field">
            <label htmlFor="space-name">Name</label>
            <input
              id="space-name"
              value={name}
              onChange={(e) => { setName(e.target.value); if (!slugTouched) setSlug(toSlug(e.target.value)); }}
              placeholder="Engineering"
              autoFocus
            />
          </div>
          <div className="sg-field">
            <label htmlFor="space-slug">Slug</label>
            <input id="space-slug" value={slug} onChange={(e) => { setSlugTouched(true); setSlug(e.target.value); }} placeholder="engineering" />
          </div>
          <div className="sg-field">
            <label htmlFor="space-description">Description</label>
            <textarea id="space-description" value={description ?? ''} onChange={(e) => setDescription(e.target.value)} placeholder="Optional description" />
          </div>
          {error && <div className="sg-error">{error}</div>}
          <div className="modal-actions">
            <button type="button" className="sg-btn sg-btn--outline" onClick={onClose}>Cancel</button>
            <button type="submit" className="sg-btn sg-btn--black" disabled={saving || !name.trim()}>
              {saving ? 'Saving…' : isEdit ? 'Save' : 'Create'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

// ── Sidebar tree node ─────────────────────────────────────────────────────
function TreeItem({
  node,
  depth,
  activeId,
  onOpen,
  onAddChild,
  onDelete,
}: {
  node: TreeNode;
  depth: number;
  activeId: string | null;
  onOpen: (id: string) => void;
  onAddChild: (parentId: string) => void;
  onDelete: (page: WikiPageSummary) => void;
}) {
  const [open, setOpen] = useState(true);
  const hasChildren = node.children.length > 0;

  return (
    <li className="wtree__li">
      <div
        className={`wtree__row${activeId === node.page.id ? ' is-active' : ''}`}
        style={{ paddingLeft: `${depth * 14 + 6}px` }}
      >
        <button
          type="button"
          className={`wtree__caret${hasChildren ? '' : ' is-empty'}`}
          onClick={() => setOpen((v) => !v)}
          aria-label={open ? 'Collapse' : 'Expand'}
        >
          {hasChildren && <ChevronRightIcon className={open ? 'is-open' : ''} />}
        </button>
        <button type="button" className="wtree__name" onClick={() => onOpen(node.page.id)} title={node.page.title}>
          {node.page.title}
        </button>
        <span className="wtree__actions">
          <button className="wiki-icon-btn" onClick={() => onAddChild(node.page.id)} title="Add subpage" aria-label="Add subpage">
            <PlusIcon />
          </button>
          <button className="wiki-icon-btn" onClick={() => onDelete(node.page)} title="Delete page" aria-label="Delete page">
            <TrashIcon />
          </button>
        </span>
      </div>
      {hasChildren && open && (
        <ul className="wtree__children">
          {node.children.map((c) => (
            <TreeItem key={c.page.id} node={c} depth={depth + 1} activeId={activeId} onOpen={onOpen} onAddChild={onAddChild} onDelete={onDelete} />
          ))}
        </ul>
      )}
    </li>
  );
}

// ── Page view / inline editor (+ comments, reactions, attachments) ────────
function PageView({
  orgId,
  pageId,
  pages,
  onChanged,
  onDeleted,
}: {
  orgId: string;
  pageId: string;
  pages: WikiPageSummary[];
  onChanged: () => void;
  onDeleted: () => void;
}) {
  const [page, setPage] = useState<WikiPage | null>(null);
  const [loading, setLoading] = useState(true);
  const [editing, setEditing] = useState(false);
  const [draftTitle, setDraftTitle] = useState('');
  const [draftContent, setDraftContent] = useState('');
  const [saving, setSaving] = useState(false);
  const [commentBody, setCommentBody] = useState('');
  const [attName, setAttName] = useState('');
  const [attUrl, setAttUrl] = useState('');

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const res = await api.getWikiPage(orgId, pageId);
      setPage(res.page);
      setDraftTitle(res.page.title);
      setDraftContent(res.page.content ?? '');
      // A freshly-created "Untitled" page opens straight into edit mode.
      setEditing(res.page.title === 'Untitled' && !res.page.content);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load page');
    } finally {
      setLoading(false);
    }
  }, [orgId, pageId]);

  useEffect(() => { load(); }, [load]);

  // Breadcrumb from parent chain.
  const breadcrumb = useMemo(() => {
    if (!page) return [];
    const byId = new Map(pages.map((p) => [p.id, p]));
    const chain: WikiPageSummary[] = [];
    let cur: WikiPageSummary | undefined = byId.get(page.id);
    const seen = new Set<string>();
    while (cur && !seen.has(cur.id)) {
      seen.add(cur.id);
      chain.unshift(cur);
      cur = cur.parent_id ? byId.get(cur.parent_id) : undefined;
    }
    return chain;
  }, [page, pages]);

  async function save() {
    if (!page || !draftTitle.trim()) return;
    setSaving(true);
    try {
      const res = await api.updateWikiPage(orgId, page.id, { title: draftTitle.trim(), content: draftContent });
      setPage(res.page);
      setEditing(false);
      toast.success('Saved');
      onChanged();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to save');
    } finally {
      setSaving(false);
    }
  }

  async function handleDelete() {
    if (!page || !confirm(`Delete page “${page.title}”?`)) return;
    try {
      await api.deleteWikiPage(orgId, page.id);
      toast.success('Page deleted');
      onDeleted();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to delete page');
    }
  }

  async function addComment(e: React.FormEvent) {
    e.preventDefault();
    if (!commentBody.trim()) return;
    try {
      await api.createWikiComment(orgId, pageId, { body: commentBody.trim() });
      setCommentBody('');
      await load();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to add comment');
    }
  }

  async function deleteComment(id: string) {
    try { await api.deleteWikiComment(orgId, id); await load(); }
    catch (err) { toast.error(err instanceof Error ? err.message : 'Failed to delete comment'); }
  }

  async function toggleReaction(emoji: string) {
    const has = page?.reactions?.some((r) => r.emoji === emoji);
    try {
      if (has) await api.removeWikiPageReaction(orgId, pageId, emoji);
      else await api.addWikiPageReaction(orgId, pageId, emoji);
      await load();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to react');
    }
  }

  async function addAttachment(e: React.FormEvent) {
    e.preventDefault();
    if (!attName.trim()) return;
    try {
      await api.createWikiAttachment(orgId, pageId, { filename: attName.trim(), url: attUrl.trim() || undefined });
      setAttName(''); setAttUrl(''); await load();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to add attachment');
    }
  }

  async function deleteAttachment(id: string) {
    try { await api.deleteWikiAttachment(orgId, id); await load(); }
    catch (err) { toast.error(err instanceof Error ? err.message : 'Failed to delete attachment'); }
  }

  if (loading) return <div className="wiki-doc"><p className="sg-page-intro">Loading…</p></div>;
  if (!page) return <div className="wiki-doc"><p className="sg-page-intro">Page not found.</p></div>;

  const reactionCounts = (page.reactions ?? []).reduce<Record<string, number>>((acc, r) => {
    acc[r.emoji] = (acc[r.emoji] ?? 0) + 1; return acc;
  }, {});

  return (
    <div className="wiki-doc">
      <div className="wiki-doc__bar">
        <nav className="wiki-crumbs" aria-label="Breadcrumb">
          {breadcrumb.map((b, i) => (
            <span key={b.id} className="wiki-crumb">
              {i > 0 && <span className="wiki-crumb__sep">/</span>}
              <span className={b.id === page.id ? 'wiki-crumb__current' : ''}>{b.title}</span>
            </span>
          ))}
        </nav>
        <div className="wiki-doc__actions">
          {editing ? (
            <>
              <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => { setEditing(false); setDraftTitle(page.title); setDraftContent(page.content ?? ''); }} disabled={saving}>
                Cancel
              </button>
              <button className="sg-btn sg-btn--black sg-btn--sm" onClick={save} disabled={saving || !draftTitle.trim()}>
                {saving ? 'Saving…' : 'Save'}
              </button>
            </>
          ) : (
            <>
              <button className="sg-btn sg-btn--outline sg-btn--sm" onClick={() => setEditing(true)}>
                <PencilSquareIcon /> Edit
              </button>
              <button className="sg-btn sg-btn--danger sg-btn--sm" onClick={handleDelete}>
                <TrashIcon /> Delete
              </button>
            </>
          )}
        </div>
      </div>

      {editing ? (
        <div className="wiki-doc__edit">
          <input
            className="wiki-doc__title-input"
            value={draftTitle}
            onChange={(e) => setDraftTitle(e.target.value)}
            placeholder="Page title"
          />
          <MarkdownEditor value={draftContent} onChange={setDraftContent} />
        </div>
      ) : (
        <article className="wiki-doc__body">
          <h1 className="wiki-doc__title">{page.title}</h1>
          <Markdown content={page.content} />
        </article>
      )}

      {!editing && (
        <>
          <div className="wiki-reactions">
            {REACTION_EMOJI.map((emoji) => {
              const count = reactionCounts[emoji] ?? 0;
              const active = page.reactions?.some((r) => r.emoji === emoji);
              return (
                <button key={emoji} className={`wiki-reaction${active ? ' is-active' : ''}`} onClick={() => toggleReaction(emoji)} title={active ? 'Remove reaction' : 'Add reaction'}>
                  <span>{emoji}</span>
                  {count > 0 && <span className="wiki-reaction__count">{count}</span>}
                </button>
              );
            })}
          </div>

          <section className="wiki-section">
            <h3 className="wiki-section__title">Attachments</h3>
            <ul className="wiki-list">
              {(page.attachments ?? []).length === 0 && <li className="wiki-list__empty">No attachments.</li>}
              {(page.attachments ?? []).map((a) => (
                <li key={a.id} className="wiki-list__item">
                  {a.url ? <a href={a.url} target="_blank" rel="noreferrer" className="wiki-link">{a.filename}</a> : <span>{a.filename}</span>}
                  <button className="wiki-icon-btn" onClick={() => deleteAttachment(a.id)} aria-label="Delete attachment"><TrashIcon /></button>
                </li>
              ))}
            </ul>
            <form className="wiki-inline-form" onSubmit={addAttachment}>
              <input value={attName} onChange={(e) => setAttName(e.target.value)} placeholder="filename.pdf" />
              <input value={attUrl} onChange={(e) => setAttUrl(e.target.value)} placeholder="https:// (optional)" />
              <button type="submit" className="sg-btn sg-btn--outline sg-btn--sm" disabled={!attName.trim()}>Add</button>
            </form>
          </section>

          <section className="wiki-section">
            <h3 className="wiki-section__title">Comments</h3>
            <ul className="wiki-comments">
              {(page.comments ?? []).length === 0 && <li className="wiki-list__empty">No comments yet.</li>}
              {(page.comments ?? []).map((c) => (
                <li key={c.id} className="wiki-comment">
                  <div className="wiki-comment__meta">
                    <span className="wiki-comment__author">{c.author || 'unknown'}</span>
                    <button className="wiki-icon-btn" onClick={() => deleteComment(c.id)} aria-label="Delete comment"><TrashIcon /></button>
                  </div>
                  <div className="wiki-comment__body">{c.body}</div>
                </li>
              ))}
            </ul>
            <form className="wiki-inline-form" onSubmit={addComment}>
              <input value={commentBody} onChange={(e) => setCommentBody(e.target.value)} placeholder="Add a comment…" />
              <button type="submit" className="sg-btn sg-btn--black sg-btn--sm" disabled={!commentBody.trim()}>Comment</button>
            </form>
          </section>
        </>
      )}
    </div>
  );
}

// ── Page (Docmost-style: sidebar tree + document) ─────────────────────────
type SpaceModalState = { type: 'create' } | { type: 'edit'; space: WikiSpace } | null;

export default function WikiPage() {
  const { orgId, loading: orgLoading } = useOrgId();
  const { currentProject, switchProject } = useOrg();
  const [spaces, setSpaces] = useState<WikiSpace[]>([]);
  const [activeSpace, setActiveSpace] = useState<WikiSpace | null>(null);
  const [pages, setPages] = useState<WikiPageSummary[]>([]);
  const [activePageId, setActivePageId] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [spaceModal, setSpaceModal] = useState<SpaceModalState>(null);

  const scopeProjectId = currentProject?.id;
  const tree = useMemo(() => buildTree(pages), [pages]);

  const fetchSpaces = useCallback(async () => {
    if (!orgId) return;
    setLoading(true);
    try {
      const res = await api.listWikiSpaces(orgId, scopeProjectId ? { projectId: scopeProjectId } : undefined);
      setSpaces(res.spaces ?? []);
      setActiveSpace((cur) => res.spaces.find((s) => s.id === cur?.id) ?? res.spaces[0] ?? null);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load spaces');
    } finally {
      setLoading(false);
    }
  }, [orgId, scopeProjectId]);

  useEffect(() => {
    if (orgId) fetchSpaces();
    else if (!orgLoading) setLoading(false);
  }, [fetchSpaces, orgId, orgLoading]);

  const fetchPages = useCallback(async () => {
    if (!orgId || !activeSpace) { setPages([]); setActivePageId(null); return; }
    try {
      const res = await api.listWikiPages(orgId, activeSpace.id);
      setPages(res.pages ?? []);
      setActivePageId((cur) => res.pages.find((p) => p.id === cur)?.id ?? res.pages[0]?.id ?? null);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load pages');
    }
  }, [orgId, activeSpace]);

  useEffect(() => { fetchPages(); }, [fetchPages]);

  async function createPage(parentId?: string) {
    if (!orgId || !activeSpace) return;
    try {
      const res = await api.createWikiPage(orgId, activeSpace.id, {
        title: 'Untitled',
        slug: `page-${Date.now()}`,
        parent_id: parentId ?? null,
      });
      await fetchPages();
      setActivePageId(res.page.id);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to create page');
    }
  }

  async function deletePage(p: WikiPageSummary) {
    if (!orgId || !confirm(`Delete page “${p.title}” and its subpages?`)) return;
    try {
      await api.deleteWikiPage(orgId, p.id);
      toast.success('Page deleted');
      if (activePageId === p.id) setActivePageId(null);
      await fetchPages();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to delete page');
    }
  }

  async function deleteSpace(space: WikiSpace) {
    if (!orgId || !confirm(`Delete space “${space.name}” and all its pages?`)) return;
    try {
      await api.deleteWikiSpace(orgId, space.id);
      toast.success('Space deleted');
      if (activeSpace?.id === space.id) setActiveSpace(null);
      await fetchSpaces();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to delete space');
    }
  }

  if (!orgId && !orgLoading) {
    return <div className="content"><main><p className="sg-page-intro">Select an organization.</p></main></div>;
  }

  return (
    <div className="content content--flush">
      <div className="wiki-shell">
        {/* Sidebar */}
        <aside className="wiki-sidebar">
          <div className="wiki-sidebar__top">
            <select
              className="wiki-space-select"
              value={activeSpace?.id ?? ''}
              onChange={(e) => setActiveSpace(spaces.find((s) => s.id === e.target.value) ?? null)}
              disabled={spaces.length === 0}
            >
              {spaces.length === 0 && <option value="">No spaces</option>}
              {spaces.map((s) => <option key={s.id} value={s.id}>{s.name}</option>)}
            </select>
            <button className="wiki-icon-btn" onClick={() => setSpaceModal({ type: 'create' })} title="New space" aria-label="New space">
              <PlusIcon />
            </button>
            {activeSpace && (
              <button className="wiki-icon-btn" onClick={() => setSpaceModal({ type: 'edit', space: activeSpace })} title="Space settings" aria-label="Space settings">
                <Cog6ToothIcon />
              </button>
            )}
          </div>

          {currentProject && (
            <div className="wiki-sidebar__scope">
              <span className="scope-chip">
                {currentProject.name}
                <button type="button" className="scope-chip__clear" onClick={() => switchProject(null)} aria-label="Clear project scope" title="Show all projects">×</button>
              </span>
            </div>
          )}

          <div className="wiki-sidebar__head">
            <span>Pages</span>
            <button className="wiki-icon-btn" onClick={() => createPage()} disabled={!activeSpace} title="New page" aria-label="New page">
              <DocumentPlusIcon />
            </button>
          </div>

          {loading ? (
            <p className="wiki-col__empty">Loading…</p>
          ) : !activeSpace ? (
            <p className="wiki-col__empty">Create a space to begin.</p>
          ) : tree.length === 0 ? (
            <button className="wiki-empty-cta" onClick={() => createPage()}>+ Create your first page</button>
          ) : (
            <ul className="wtree">
              {tree.map((n) => (
                <TreeItem key={n.page.id} node={n} depth={0} activeId={activePageId} onOpen={setActivePageId} onAddChild={createPage} onDelete={deletePage} />
              ))}
            </ul>
          )}

          {activeSpace && (
            <button className="wiki-sidebar__danger" onClick={() => deleteSpace(activeSpace)}>
              <TrashIcon /> Delete space
            </button>
          )}
        </aside>

        {/* Document area */}
        <div className="wiki-main">
          {activePageId && orgId ? (
            <PageView
              key={activePageId}
              orgId={orgId}
              pageId={activePageId}
              pages={pages}
              onChanged={fetchPages}
              onDeleted={() => { setActivePageId(null); fetchPages(); }}
            />
          ) : (
            <div className="wiki-doc wiki-doc--empty">
              <h1 className="sg-page-title">Wiki</h1>
              <p className="sg-page-intro">
                {activeSpace ? 'Select a page from the sidebar, or create one.' : 'Create a space to start writing.'}
              </p>
            </div>
          )}
        </div>
      </div>

      {spaceModal && orgId && (
        <SpaceModal
          orgId={orgId}
          space={spaceModal.type === 'edit' ? spaceModal.space : null}
          defaultProjectId={scopeProjectId}
          onClose={() => setSpaceModal(null)}
          onSaved={(s) => { setSpaceModal(null); setActiveSpace(s); fetchSpaces(); }}
        />
      )}
    </div>
  );
}
