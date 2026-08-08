'use client';

import { useParams } from 'next/navigation';
import { useOrgId } from '@/context/org';
import { ConsoleDetailPage } from '@/components/console/ConsoleDetailPage';
import { reviewsDescriptor } from '@/lib/console/descriptors/reviews';

// Review detail route (epic 8920d294) — a THIN ConsoleDetailPage instantiation.
// READ-ONLY: reviews have no update endpoint yet (soren f73f4cd2), so the descriptor
// omits api.update and the wrapper shows no Edit. Lights up when updateReview ships.
export default function ReviewDetailRoute() {
  const { orgId, slug, loading } = useOrgId();
  const params = useParams();
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
        <ConsoleDetailPage ctx={{ orgId, orgSlug: slug }} id={id} descriptor={reviewsDescriptor} />
      </main>
    </div>
  );
}
