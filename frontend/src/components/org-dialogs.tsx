'use client';

import { useState } from 'react';
import { toast } from 'sonner';
import { api, type Organization } from '@/lib/api';

function toSlug(name: string) {
  return name
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '-')
    .replace(/[^a-z0-9-]/g, '')
    .replace(/^-+|-+$/g, '');
}

export function OrgFormModal({
  org,
  onClose,
  onSaved,
}: {
  org?: Organization | null;
  onClose: () => void;
  onSaved: (org: Organization) => void;
}) {
  const isEdit = !!org;
  const [name, setName] = useState(org?.name ?? '');
  const [slug, setSlug] = useState(org?.slug ?? '');
  const [slugTouched, setSlugTouched] = useState(isEdit);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  function handleNameChange(v: string) {
    setName(v);
    if (!slugTouched) setSlug(toSlug(v));
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim() || !slug.trim()) return;
    setSaving(true);
    setError(null);
    try {
      const res = isEdit && org
        ? await api.updateOrganization(org.id, { name: name.trim(), slug: slug.trim() })
        : await api.createOrganization(slug.trim(), name.trim());
      toast.success(isEdit ? 'Organization updated' : 'Organization created');
      onSaved(res.organization);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Request failed');
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-card" onClick={(e) => e.stopPropagation()}>
        <h2 className="modal-title">{isEdit ? 'Organization Settings' : 'New Organization'}</h2>
        <form onSubmit={handleSubmit}>
          <div className="sg-field">
            <label htmlFor="org-name">Name</label>
            <input id="org-name" value={name} onChange={(e) => handleNameChange(e.target.value)} placeholder="Acme Inc" autoFocus />
          </div>
          <div className="sg-field">
            <label htmlFor="org-slug">Slug</label>
            <input
              id="org-slug"
              value={slug}
              onChange={(e) => {
                setSlugTouched(true);
                setSlug(e.target.value);
              }}
              placeholder="acme"
            />
            <span className="sg-field__hint">Lowercase letters, numbers, and hyphens. Used in URLs.</span>
          </div>
          {error && <div className="sg-error">{error}</div>}
          <div className="modal-actions">
            <button type="button" className="sg-btn sg-btn--outline" onClick={onClose}>
              Cancel
            </button>
            <button type="submit" className="sg-btn sg-btn--black" disabled={saving || !name.trim() || !slug.trim()}>
              {saving ? 'Saving…' : isEdit ? 'Save' : 'Create'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export function OrgDeleteConfirm({
  org,
  onClose,
  onDeleted,
}: {
  org: Organization;
  onClose: () => void;
  onDeleted: () => void;
}) {
  const [confirmText, setConfirmText] = useState('');
  const [loading, setLoading] = useState(false);
  const matches = confirmText.trim() === org.slug;

  async function handleDelete() {
    if (!matches) return;
    setLoading(true);
    try {
      await api.deleteOrganization(org.id);
      toast.success('Organization deleted');
      onDeleted();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to delete organization');
      setLoading(false);
    }
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-card modal-card--sm" onClick={(e) => e.stopPropagation()}>
        <h2 className="modal-title">Delete Organization</h2>
        <p className="modal-body">
          This permanently deletes <strong>{org.name}</strong> and all of its projects. This cannot be undone.
        </p>
        <div className="sg-field">
          <label htmlFor="org-delete-confirm">
            Type <code>{org.slug}</code> to confirm
          </label>
          <input id="org-delete-confirm" value={confirmText} onChange={(e) => setConfirmText(e.target.value)} autoFocus />
        </div>
        <div className="modal-actions">
          <button type="button" className="sg-btn sg-btn--outline" onClick={onClose}>
            Cancel
          </button>
          <button type="button" className="sg-btn sg-btn--danger" onClick={handleDelete} disabled={!matches || loading}>
            {loading ? 'Deleting…' : 'Delete'}
          </button>
        </div>
      </div>
    </div>
  );
}
