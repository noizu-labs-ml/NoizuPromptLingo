'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { PlusIcon } from '@heroicons/react/24/outline';
import { useOrg } from '@/context/org';
import { OrgFormModal, OrgDeleteConfirm } from '@/components/org-dialogs';
import type { Organization } from '@/lib/api';
import { DataTable } from '@/components/console/DataTable';
import { organizationsDescriptor } from '@/lib/console/descriptors/organizations';

// Organizations console list (epic 8920d294). A top-level list (NOT org-scoped) —
// api.listOrganizations ignores ctx.orgId. Primary-click opens the org (switchOrg +
// navigate); the RBAC-gated kebab (edit @ admin, delete @ owner) reads each row's
// effective_role (16dc3df2) via the descriptor's canEdit/canDelete. create/edit/delete
// keep the existing OrgFormModal / OrgDeleteConfirm dialogs.

type ModalState = { type: 'create' } | { type: 'edit'; org: Organization } | null;

export default function OrganizationsPage() {
  const { currentOrg, switchOrg, refresh } = useOrg();
  const router = useRouter();
  const [modal, setModal] = useState<ModalState>(null);
  const [deleteTarget, setDeleteTarget] = useState<Organization | null>(null);
  const [reloadKey, setReloadKey] = useState(0);
  const reload = () => setReloadKey((k) => k + 1);

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">Organizations</h1>
        </div>

        <DataTable
          descriptor={organizationsDescriptor}
          ctx={{ orgId: currentOrg?.id ?? '', orgSlug: currentOrg?.slug }}
          refreshKey={reloadKey}
          onOpenRow={(o) => {
            switchOrg(o.id);
            router.push(`/app/${o.slug}`);
          }}
          onEditRow={(o) => setModal({ type: 'edit', org: o })}
          onDeleteRow={(o) => setDeleteTarget(o)}
        />
      </main>

      {modal?.type === 'create' && (
        <OrgFormModal
          onClose={() => setModal(null)}
          onSaved={async (org) => {
            setModal(null);
            reload();
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
            reload();
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
            reload();
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
