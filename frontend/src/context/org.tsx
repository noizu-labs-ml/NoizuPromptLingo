'use client';

import { createContext, useContext, useState, useEffect, useCallback, ReactNode } from 'react';
import { useParams } from 'next/navigation';
import { useAuth } from './auth';
import { api, type Organization, type Project } from '@/lib/api';
import { resolveOrg } from '@/lib/org-resolve';

interface OrgContextType {
  currentOrg: Organization | null;
  organizations: Organization[];
  switchOrg: (orgId: string) => void;
  clearOrg: () => void;
  refresh: (preferId?: string) => Promise<void>;
  loading: boolean;
  // Projects belonging to the current org, plus the active "scope" project.
  projects: Project[];
  projectsLoading: boolean;
  currentProject: Project | null;
  switchProject: (project: Project | null, orgId?: string) => void;
  refreshProjects: () => Promise<void>;
}

// Per-org persisted project selection. Keyed by org id so switching orgs
// restores the project you last had open in that org.
const projectKey = (orgId: string) => `currentProjectId:${orgId}`;

const OrgContext = createContext<OrgContextType>({
  currentOrg: null,
  organizations: [],
  switchOrg: () => {},
  clearOrg: () => {},
  refresh: async () => {},
  loading: true,
  projects: [],
  projectsLoading: false,
  currentProject: null,
  switchProject: () => {},
  refreshProjects: async () => {},
});

export function OrgProvider({ children }: { children: ReactNode }) {
  const { user, organizations: authOrgs } = useAuth();
  const [organizations, setOrganizations] = useState<Organization[]>([]);
  const [currentOrg, setCurrentOrg] = useState<Organization | null>(null);
  const [loading, setLoading] = useState(true);
  const [projects, setProjects] = useState<Project[]>([]);
  const [projectsLoading, setProjectsLoading] = useState(false);
  const [currentProject, setCurrentProject] = useState<Project | null>(null);

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

  // Select an org by id. Guard: a falsy/undefined orgId (e.g. one leaked from a
  // route param) is a NO-OP — it must never unset an already-active org. Only an
  // explicit user action (refresh with no orgs, or removing the last org) clears
  // the active org; a missing value is never treated as "clear".
  const switchOrg = (orgId: string) => {
    if (!orgId) return;
    const org = organizations.find(o => o.id === orgId);
    if (org) {
      setCurrentOrg(org);
      localStorage.setItem('currentOrgId', orgId);
    }
  };

  // Global scope: no org, no project. Also drops the org's saved project so a
  // later re-select starts unscoped.
  const clearOrg = useCallback(() => {
    if (currentOrg?.id) localStorage.removeItem(projectKey(currentOrg.id));
    setCurrentProject(null);
    setCurrentOrg(null);
    localStorage.removeItem('currentOrgId');
  }, [currentOrg?.id]);

  // Re-fetch the org list from the server (after create/edit/delete). When
  // `preferId` is given, select that org if present; otherwise keep the saved
  // selection or fall back to the first available org.
  const refresh = useCallback(async (preferId?: string) => {
    const res = await api.listOrganizations();
    setOrganizations(res.organizations);
    const targetId = preferId || localStorage.getItem('currentOrgId');
    const next = res.organizations.find(o => o.id === targetId) || res.organizations[0] || null;
    setCurrentOrg(next);
    if (next) localStorage.setItem('currentOrgId', next.id);
    else localStorage.removeItem('currentOrgId');
  }, []);

  // Load the current org's projects and restore its persisted project scope.
  // Runs whenever the active org changes. The persisted id is read fresh from
  // localStorage so a selection made just before switching (e.g. from the
  // brand-mark switcher) is honoured once the list resolves.
  const orgId = currentOrg?.id ?? null;
  useEffect(() => {
    if (!orgId) {
      setProjects([]);
      setCurrentProject(null);
      return;
    }
    let cancelled = false;
    setProjectsLoading(true);
    api.listProjects(orgId)
      .then(res => {
        if (cancelled) return;
        const list = res.projects ?? [];
        setProjects(list);
        const savedId = localStorage.getItem(projectKey(orgId));
        setCurrentProject(list.find(p => p.id === savedId) ?? null);
      })
      .catch(() => {
        if (cancelled) return;
        setProjects([]);
        setCurrentProject(null);
      })
      .finally(() => {
        if (!cancelled) setProjectsLoading(false);
      });
    return () => { cancelled = true; };
  }, [orgId]);

  // Select (or clear) the active project. `orgId` may be passed for the case
  // where the org was switched in the same tick and `currentOrg` hasn't settled.
  const switchProject = useCallback((project: Project | null, forOrgId?: string) => {
    const targetOrg = forOrgId || currentOrg?.id;
    if (!targetOrg) return;
    if (project) localStorage.setItem(projectKey(targetOrg), project.id);
    else localStorage.removeItem(projectKey(targetOrg));
    // Only reflect in state if it applies to the org currently in view.
    if (!forOrgId || forOrgId === currentOrg?.id) setCurrentProject(project);
  }, [currentOrg?.id]);

  const refreshProjects = useCallback(async () => {
    if (!orgId) return;
    const res = await api.listProjects(orgId);
    const list = res.projects ?? [];
    setProjects(list);
    setCurrentProject(prev => (prev ? list.find(p => p.id === prev.id) ?? null : null));
  }, [orgId]);

  return (
    <OrgContext.Provider value={{
      currentOrg, organizations, switchOrg, clearOrg, refresh, loading,
      projects, projectsLoading, currentProject, switchProject, refreshProjects,
    }}>
      {children}
    </OrgContext.Provider>
  );
}

export function useOrg() {
  return useContext(OrgContext);
}

/**
 * Resolves the org-scoped route param (a slug) to the org's UUID.
 *
 * Org URLs carry the slug (`/app/<slug>/projects`), but the API is UUID-keyed,
 * so every org-scoped `api.*` call needs the resolved UUID. This hook reads the
 * `orgId` route param and looks the org up by slug in the loaded org list.
 *
 * Returns `orgId: null` while the org list is still loading or the slug is
 * unknown; callers should gate API calls on a non-null `orgId`.
 */
export function useOrgId() {
  const params = useParams<{ orgId: string }>();
  const { organizations, loading } = useOrg();
  const param = params?.orgId;
  // Resolve the route segment by slug OR id (see resolveOrg) so a stray non-slug
  // param can't blank the org and cascade null-org states across the app. `slug`
  // is normalized back to the canonical slug when resolvable, so callers building
  // URLs from it self-heal.
  const org = resolveOrg(organizations, param);
  return { slug: org?.slug ?? param, orgId: org?.id ?? null, loading };
}
