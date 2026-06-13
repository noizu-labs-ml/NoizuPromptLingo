'use client';

import { useAuth } from '@/context/auth';
import { useOrg } from '@/context/org';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';

export default function AppPage() {
  const { user, loading: authLoading } = useAuth();
  const { organizations, loading: orgLoading } = useOrg();
  const router = useRouter();

  useEffect(() => {
    if (!authLoading && !user) {
      router.push('/login');
    }
  }, [user, authLoading, router]);

  if (authLoading || orgLoading) return <div>Loading...</div>;
  if (!user) return null;

  if (organizations.length === 1) {
    router.push(`/app/${organizations[0].id}`);
    return null;
  }

  return (
    <div style={{ maxWidth: 600, margin: '2rem auto', padding: '0 1rem' }}>
      <h1>Your Organizations</h1>
      {organizations.length === 0 ? (
        <p>You are not a member of any organization yet.</p>
      ) : (
        <ul style={{ listStyle: 'none', padding: 0 }}>
          {organizations.map((org) => (
            <li key={org.id} style={{ marginBottom: '1rem' }}>
              <a
                href={`/app/${org.id}`}
                style={{ display: 'block', padding: '1rem', border: '1px solid #ccc', borderRadius: '8px', textDecoration: 'none' }}
              >
                <strong>{org.name}</strong>
                <span style={{ marginLeft: '0.5rem', color: '#666' }}>({org.role})</span>
              </a>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
