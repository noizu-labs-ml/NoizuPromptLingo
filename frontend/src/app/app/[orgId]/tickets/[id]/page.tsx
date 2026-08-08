'use client';

// Tickets detail+edit route — thin instantiation of the shared ConsoleDetailPage
// wrapper (diego 0f8453f5 / priya seq529 wrapper-proof). The wrapper does
// api.getTicket -> DetailView (sections + Sub-tickets embedded table) -> EditForm
// (api.updateTicket, keep-input-on-failure) -> back-with-state. This page only
// supplies ctx, id, the descriptor, and resolved referenceOptions for the dynamic
// edit fields (project / ticket_type / status). ?edit=1 opens straight in edit mode.
import { useCallback, useEffect, useMemo, useState } from 'react';
import { useParams, useSearchParams } from 'next/navigation';
import { api, type Project } from '@/lib/api';
import { useOrgId } from '@/context/org';
import { ConsoleDetailPage } from '@/components/console/ConsoleDetailPage';
import { ticketsDescriptor } from '@/lib/console/descriptors/tickets';
import { TICKET_TYPE_OPTIONS, TICKET_STATUS_OPTIONS } from '@/lib/console/options';

export default function TicketDetailPage() {
  // orgId (UUID) for api.get/update; orgSlug carried for any route-building affordances.
  const { orgId, slug: orgSlug, loading } = useOrgId();
  const params = useParams();
  const searchParams = useSearchParams();
  const id = params.id as string;
  const initialMode = searchParams.get('edit') === '1' ? 'edit' : 'view';

  const [projects, setProjects] = useState<Project[]>([]);

  // Projects back the EditForm's project reference picker.
  const fetchProjects = useCallback(async () => {
    if (!orgId) return;
    try {
      const { projects } = await api.listProjects(orgId);
      setProjects(projects ?? []);
    } catch {
      // Reference picker degrades to no options; non-fatal for view mode.
    }
  }, [orgId]);

  useEffect(() => {
    if (orgId) fetchProjects();
  }, [fetchProjects, orgId]);

  const ctx = useMemo(() => ({ orgId: orgId ?? '', orgSlug: orgSlug ?? '' }), [orgId, orgSlug]);

  // referenceOptions keys match the descriptor's dynamic edit-field keys.
  const referenceOptions = useMemo(
    () => ({
      project_id: projects.map((p) => ({ value: p.id, label: p.name })),
      ticket_type: TICKET_TYPE_OPTIONS,
      status: TICKET_STATUS_OPTIONS,
    }),
    [projects],
  );

  return (
    <div className="content">
      <main>
        {loading || !orgId ? (
          <p className="sg-page-intro">Loading…</p>
        ) : (
          <ConsoleDetailPage
            ctx={ctx}
            id={id}
            descriptor={ticketsDescriptor}
            referenceOptions={referenceOptions}
            initialMode={initialMode}
          />
        )}
      </main>
    </div>
  );
}
