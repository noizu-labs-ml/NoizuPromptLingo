'use client';

import { useParams, useSearchParams } from 'next/navigation';
import { useOrgId } from '@/context/org';
import { ConsoleDetailPage } from '@/components/console/ConsoleDetailPage';
import { projectsDescriptor } from '@/lib/console/descriptors/projects';

// Project detail/edit route (epic 8920d294) — a THIN instantiation of the shared
// ConsoleDetailPage wrapper (descriptor + ctx + id). The projects LIST keeps its
// primary-click = select-active-scope (priya seq523: the earned (B) exception);
// this detail view is reached via the row's 'Details' action. ?edit=1 opens the
// EditForm (name/slug/description -> api.updateProject).
export default function ProjectDetailRoute() {
  const { orgId, slug, loading } = useOrgId();
  const params = useParams();
  const search = useSearchParams();
  const id = params.projectId as string;

  if (loading || !orgId) {
    return (
      <div className="content">
        <main>
          <p className="sg-page-intro">Loading…</p>
        </main>
      </div>
    );
  }

  return (
    <div className="content">
      <main>
        <ConsoleDetailPage
          ctx={{ orgId, orgSlug: slug }}
          id={id}
          descriptor={projectsDescriptor}
          initialMode={search.get('edit') ? 'edit' : 'view'}
        />
      </main>
    </div>
  );
}
