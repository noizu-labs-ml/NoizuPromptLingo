'use client';

import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { useAuth } from './auth';
import { api, type Organization } from '@/lib/api';

interface OrgContextType {
  currentOrg: Organization | null;
  organizations: Organization[];
  switchOrg: (orgId: string) => void;
  loading: boolean;
}

const OrgContext = createContext<OrgContextType>({
  currentOrg: null,
  organizations: [],
  switchOrg: () => {},
  loading: true,
});

export function OrgProvider({ children }: { children: ReactNode }) {
  const { user, organizations: authOrgs } = useAuth();
  const [organizations, setOrganizations] = useState<Organization[]>([]);
  const [currentOrg, setCurrentOrg] = useState<Organization | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user) {
      setOrganizations([]);
      setCurrentOrg(null);
      setLoading(false);
      return;
    }

    if (authOrgs && authOrgs.length > 0) {
      setOrganizations(authOrgs);
      const savedOrgId = localStorage.getItem('currentOrgId');
      const saved = authOrgs.find(o => o.id === savedOrgId);
      setCurrentOrg(saved || authOrgs[0]);
      setLoading(false);
    } else {
      api.listOrganizations().then(res => {
        setOrganizations(res.organizations);
        const savedOrgId = localStorage.getItem('currentOrgId');
        const saved = res.organizations.find((o: Organization) => o.id === savedOrgId);
        setCurrentOrg(saved || res.organizations[0] || null);
        setLoading(false);
      }).catch(() => setLoading(false));
    }
  }, [user, authOrgs]);

  const switchOrg = (orgId: string) => {
    const org = organizations.find(o => o.id === orgId);
    if (org) {
      setCurrentOrg(org);
      localStorage.setItem('currentOrgId', orgId);
    }
  };

  return (
    <OrgContext.Provider value={{ currentOrg, organizations, switchOrg, loading }}>
      {children}
    </OrgContext.Provider>
  );
}

export function useOrg() {
  return useContext(OrgContext);
}
