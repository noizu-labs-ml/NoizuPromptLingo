'use client';

import { useParams, useSearchParams } from 'next/navigation';
import { useOrgId } from '@/context/org';
import { ConsoleDetailPage } from '@/components/console/ConsoleDetailPage';
import { artifactsDescriptor } from '@/lib/console/descriptors/artifacts';

// Artifact detail/edit route (ticket c0f97e6b) — a THIN instantiation of the shared
// ConsoleDetailPage wrapper (descriptor + ctx + id). ?edit=1 opens straight into the
// append-revision editor.
export default function ArtifactDetailRoute() {
  const { orgId, slug, loading } = useOrgId();
  const params = useParams();
  const search = useSearchParams();
  const id = params.id as string;

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
          descriptor={artifactsDescriptor}
          initialMode={search.get('edit') ? 'edit' : 'view'}
        />
      </main>
    </div>
  );
}
