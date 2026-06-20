'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { PlusIcon } from '@heroicons/react/24/outline';
import { useOrg } from '@/context/org';
import { OrgFormModal, OrgDeleteConfirm } from '@/components/org-dialogs';
import type { Organization } from '@/lib/api';

type ModalState = { type: 'create' } | { type: 'edit'; org: Organization } | null;

export default function OrganizationsPage() {
  const { organizations, currentOrg, switchOrg, refresh, loading } = useOrg();
  const router = useRouter();
  const [modal, setModal] = useState<ModalState>(null);
  const [deleteTarget, setDeleteTarget] = useState<Organization | null>(null);

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">Organizations</h1>
        </div>

        {loading ? (
          <p className="sg-page-intro">Loading…</p>
        ) : organizations.length === 0 ? (
          <div className="projects-empty">You don’t belong to any organization yet. Create one to get started.</div>
        ) : (
          <div className="projects-grid">
            {organizations.map((org) => {
              const isOwner = org.role === 'owner';
              const canEdit = org.role === 'owner' || org.role === 'admin';
              return (
                <div key={org.id} className="project-card">
                  <div className="project-card__header">
                    <div className="project-card__name">{org.name}</div>
                    <div className="project-card__slug">{org.slug}</div>
                  </div>
                  <div className="project-card__body">
                  <dl className="project-card__fields">
                    <div className="project-card__field">
                      <dt>Slug:</dt>
                      <dd className="project-card__slug">{org.slug}</dd>
                    </div>
                    {org.owner && (
                      <div className="project-card__field">
                        <dt>Owner:</dt>
                        <dd>{org.owner}</dd>
                      </div>
                    )}
                    {org.role && (
                      <div className="project-card__field">
                        <dt>Role:</dt>
                        <dd>{org.role}</dd>
                      </div>
                    )}
                  </dl>
                  <div className="project-card__meta">
                    {org.role && <span className="project-card__status">{org.role}</span>}
                    {org.id === currentOrg?.id && <span className="project-card__status project-card__status--active">current</span>}
                  </div>
                  <div className="project-card__actions">
                    <button
                      className="sg-btn sg-btn--primary sg-btn--sm"
                      onClick={() => {
                        switchOrg(org.id);
                        router.push(`/app/${org.slug}`);
                      }}
                    >
                      Open
                    </button>
                    {canEdit && (
                      <button className="sg-btn sg-btn--secondary sg-btn--sm" onClick={() => setModal({ type: 'edit', org })}>
                        Edit
                      </button>
                    )}
                    {isOwner && (
                      <button className="sg-btn sg-btn--danger sg-btn--sm" onClick={() => setDeleteTarget(org)}>
                        Delete
                      </button>
                    )}
                  </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </main>

      {modal?.type === 'create' && (
        <OrgFormModal
          onClose={() => setModal(null)}
          onSaved={async (org) => {
            setModal(null);
            await refresh(org.id);
            router.push(`/app/${org.slug}`);
          }}
        />
      )}
      {modal?.type === 'edit' && (
        <OrgFormModal
          org={modal.org}
          onClose={() => setModal(null)}
          onSaved={async (org) => {
            setModal(null);
            await refresh(org.id);
          }}
        />
      )}
      {deleteTarget && (
        <OrgDeleteConfirm
          org={deleteTarget}
          onClose={() => setDeleteTarget(null)}
          onDeleted={async () => {
            setDeleteTarget(null);
            await refresh();
          }}
        />
      )}

      <button className="fab" onClick={() => setModal({ type: 'create' })} aria-label="New organization" title="New organization">
        <PlusIcon />
      </button>
    </div>
  );
}
