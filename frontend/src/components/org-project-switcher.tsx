'use client';

import { useState, useRef, useEffect, useMemo, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import { ChevronRightIcon, MagnifyingGlassIcon } from '@heroicons/react/24/outline';
import { useOrg } from '@/context/org';
import { api, type Organization, type Project } from '@/lib/api';

/**
 * The "M." brand mark doubles as an org → project quick-switcher. Clicking it
 * opens a popover with a searchable org list; expanding an org lazy-loads its
 * projects so you can jump straight to a project's page.
 */
export function OrgProjectSwitcher() {
  const router = useRouter();
  const { currentOrg, organizations, switchOrg, currentProject, switchProject } = useOrg();
  const [open, setOpen] = useState(false);
  const [query, setQuery] = useState('');
  const [expanded, setExpanded] = useState<string | null>(null);
  // Per-org project cache: undefined = not loaded, [] = loaded & empty.
  const [projectsByOrg, setProjectsByOrg] = useState<Record<string, Project[]>>({});
  const [loadingOrg, setLoadingOrg] = useState<string | null>(null);

  const rootRef = useRef<HTMLDivElement>(null);
  const searchRef = useRef<HTMLInputElement>(null);

  // Close on outside click or Escape.
  useEffect(() => {
    if (!open) return;
    function onDown(e: MouseEvent) {
      if (rootRef.current && !rootRef.current.contains(e.target as Node)) setOpen(false);
    }
    function onKey(e: KeyboardEvent) {
      if (e.key === 'Escape') setOpen(false);
    }
    document.addEventListener('mousedown', onDown);
    document.addEventListener('keydown', onKey);
    return () => {
      document.removeEventListener('mousedown', onDown);
      document.removeEventListener('keydown', onKey);
    };
  }, [open]);

  const loadProjects = useCallback(
    async (orgId: string) => {
      if (projectsByOrg[orgId]) return;
      setLoadingOrg(orgId);
      try {
        const res = await api.listProjects(orgId);
        setProjectsByOrg((prev) => ({ ...prev, [orgId]: res.projects ?? [] }));
      } catch {
        setProjectsByOrg((prev) => ({ ...prev, [orgId]: [] }));
      } finally {
        setLoadingOrg((cur) => (cur === orgId ? null : cur));
      }
    },
    [projectsByOrg],
  );

  // When opening, default-expand the current org and focus the search box.
  useEffect(() => {
    if (!open) return;
    const initial = currentOrg?.id ?? organizations[0]?.id ?? null;
    setExpanded(initial);
    if (initial) loadProjects(initial);
    const t = setTimeout(() => searchRef.current?.focus(), 0);
    return () => clearTimeout(t);
  }, [open, currentOrg?.id, organizations, loadProjects]);

  const filteredOrgs = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return organizations;
    return organizations.filter(
      (o) => o.name.toLowerCase().includes(q) || o.slug.toLowerCase().includes(q),
    );
  }, [organizations, query]);

  function toggleOrg(org: Organization) {
    setExpanded((cur) => {
      const next = cur === org.id ? null : org.id;
      if (next) loadProjects(org.id);
      return next;
    });
  }

  function openOrg(org: Organization) {
    switchOrg(org.id);
    setOpen(false);
    router.push(`/app/${org.slug}`);
  }

  function openProject(org: Organization, project: Project) {
    switchOrg(org.id);
    switchProject(project, org.id);
    setOpen(false);
    // No per-project route yet — land on the org's projects list, focused on the pick.
    router.push(`/app/${org.slug}/projects#${project.slug}`);
  }

  function clearProject(org: Organization) {
    switchOrg(org.id);
    switchProject(null, org.id);
    setOpen(false);
    router.push(`/app/${org.slug}`);
  }

  return (
    <div className="ops" ref={rootRef}>
      <button
        type="button"
        className="ops__trigger"
        onClick={() => setOpen((v) => !v)}
        aria-label="Switch organization or project"
        aria-haspopup="true"
        aria-expanded={open}
        title="Switch organization or project"
      >
        <svg width="26" height="26" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
          <rect x="1" y="1" width="30" height="30" rx="6" stroke="var(--border-strong)" strokeWidth="2" />
          <path d="M8 22V10L13 18L18 10V22" stroke="var(--red)" strokeWidth="2.5" fill="none" strokeLinejoin="round" strokeLinecap="round" />
          <circle cx="24" cy="21" r="2.5" fill="var(--blue)" />
        </svg>
      </button>

      {open && (
        <div className="ops__panel" role="dialog" aria-label="Organizations and projects">
          <div className="ops__search">
            <MagnifyingGlassIcon className="ops__search-icon" />
            <input
              ref={searchRef}
              type="text"
              className="ops__search-input"
              placeholder="Search organizations…"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
            />
          </div>

          <div className="ops__list">
            {filteredOrgs.length === 0 ? (
              <div className="ops__empty">No organizations match “{query}”.</div>
            ) : (
              filteredOrgs.map((org) => {
                const isExpanded = expanded === org.id;
                const projects = projectsByOrg[org.id];
                const isCurrent = currentOrg?.id === org.id;
                return (
                  <div key={org.id} className="ops__org">
                    <div className={`ops__org-row${isCurrent ? ' is-current' : ''}`}>
                      <button
                        type="button"
                        className="ops__org-toggle"
                        onClick={() => toggleOrg(org)}
                        aria-expanded={isExpanded}
                      >
                        <ChevronRightIcon className={`ops__chevron${isExpanded ? ' is-open' : ''}`} />
                        <span className="ops__org-name">{org.name}</span>
                        {isCurrent && <span className="ops__org-badge">current</span>}
                      </button>
                      <button
                        type="button"
                        className="ops__org-open"
                        onClick={() => openOrg(org)}
                        title={`Open ${org.name}`}
                      >
                        Open
                      </button>
                    </div>

                    {isExpanded && (
                      <div className="ops__projects">
                        <button
                          type="button"
                          className={`ops__proj ops__proj--all${isCurrent && !currentProject ? ' is-current' : ''}`}
                          onClick={() => clearProject(org)}
                        >
                          <span className="ops__proj-name">All projects</span>
                        </button>
                        {loadingOrg === org.id && !projects ? (
                          <div className="ops__proj-msg">Loading projects…</div>
                        ) : projects && projects.length > 0 ? (
                          projects.map((p) => (
                            <button
                              key={p.id}
                              type="button"
                              className={`ops__proj${isCurrent && currentProject?.id === p.id ? ' is-current' : ''}`}
                              onClick={() => openProject(org, p)}
                            >
                              <span className="ops__proj-name">{p.name}</span>
                              <span className="ops__proj-slug">{p.slug}</span>
                            </button>
                          ))
                        ) : (
                          <div className="ops__proj-msg">No projects.</div>
                        )}
                      </div>
                    )}
                  </div>
                );
              })
            )}
          </div>
        </div>
      )}
    </div>
  );
}
