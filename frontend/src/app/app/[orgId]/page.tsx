'use client';

import { useParams } from 'next/navigation';
import { useOrg } from '@/context/org';

export default function OrgDashboard() {
  const { orgId } = useParams<{ orgId: string }>();
  const { currentOrg } = useOrg();

  return (
    <div style={{ maxWidth: 800, margin: '2rem auto', padding: '0 1rem' }}>
      <h1>{currentOrg?.name || 'Organization'} Dashboard</h1>
      <p>Organization ID: {orgId}</p>
      <p>This is a placeholder dashboard. Add your app content here.</p>
    </div>
  );
}
