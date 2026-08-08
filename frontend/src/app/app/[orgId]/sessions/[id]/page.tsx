'use client';

// Sessions detail+edit route — thin instantiation of ConsoleDetailPage (diego 0f8453f5),
// same proven shape as tickets/[id] (priya seq554). Wrapper does api.getSession ->
// DetailView (sections + Rooms embedded table) -> EditForm (api.updateSession,
// keep-input-on-failure) -> back-with-state. This page supplies ctx, id, the descriptor,
// and the project reference options for the EditForm. ?edit=1 opens straight in edit mode.
import { useCallback, useEffect, useMemo, useState } from 'react';
import { useParams, useSearchParams } from 'next/navigation';
import { api, type Project } from '@/lib/api';
import { useOrgId } from '@/context/org';
import { ConsoleDetailPage } from '@/components/console/ConsoleDetailPage';
import { sessionsDescriptor } from '@/lib/console/descriptors/sessions';

export default function SessionDetailPage() {
  // orgId (UUID) for api.get/update; orgSlug carried for route-building affordances.
  const { orgId, slug: orgSlug, loading } = useOrgId();
  const params = useParams();
  const searchParams = useSearchParams();
  const id = params.id as string;
  const initialMode = searchParams.get('edit') === '1' ? 'edit' : 'view';

  const [projects, setProjects] = useState<Project[]>([]);

  // Projects back the EditForm's project reference picker. Status options are static
  // in the sessions descriptor, so only project_id needs runtime resolution.
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
  const referenceOptions = useMemo(
    () => ({ project_id: projects.map((p) => ({ value: p.id, label: p.name })) }),
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
            descriptor={sessionsDescriptor}
            referenceOptions={referenceOptions}
            initialMode={initialMode}
          />
        )}
      </main>
    </div>
  );
}
