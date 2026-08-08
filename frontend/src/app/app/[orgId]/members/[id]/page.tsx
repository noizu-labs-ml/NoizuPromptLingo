'use client';

import { useParams, useSearchParams } from 'next/navigation';
import { useOrgId } from '@/context/org';
import { ConsoleDetailPage } from '@/components/console/ConsoleDetailPage';
import { membersDescriptor } from '@/lib/console/descriptors/members';

// Member detail/edit route (ticket 7bddfd70 / 4a9aa9d9) — a thin ConsoleDetailPage
// instantiation (getMember). ?edit=1 opens the role EditForm (api.updateMemberRole).
export default function MemberDetailRoute() {
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
          descriptor={membersDescriptor}
          initialMode={search.get('edit') ? 'edit' : 'view'}
        />
      </main>
    </div>
  );
}
