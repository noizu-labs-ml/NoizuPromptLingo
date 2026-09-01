'use client';

import { createContext, useContext, useEffect, useState, useCallback, ReactNode } from 'react';
import { useAuth } from './auth';
import { useOrg } from './org';

/**
 * Viewer-level starred projects. Purely a UI preference (per viewer, per org)
 * — persisted in localStorage keyed by user + org; not an MCP/API feature.
 */
interface StarredContextType {
  starred: string[];
  isStarred: (projectId: string) => boolean;
  toggle: (projectId: string) => void;
}

const storageKey = (userId: string, orgId: string) => `starredProjects:${userId}:${orgId}`;

const StarredContext = createContext<StarredContextType>({
  starred: [],
  isStarred: () => false,
  toggle: () => {},
});

export function StarredProjectsProvider({ children }: { children: ReactNode }) {
  const { user } = useAuth();
  const { currentOrg } = useOrg();
  const [starred, setStarred] = useState<string[]>([]);

  const userId = user?.id ?? null;
  const orgId = currentOrg?.id ?? null;

  // Reload the starred set whenever the viewer or active org changes.
  useEffect(() => {
    if (!userId || !orgId) {
      setStarred([]);
      return;
    }
    try {
      const raw = localStorage.getItem(storageKey(userId, orgId));
      setStarred(raw ? (JSON.parse(raw) as string[]) : []);
    } catch {
      setStarred([]);
    }
  }, [userId, orgId]);

  const toggle = useCallback(
    (projectId: string) => {
      if (!userId || !orgId) return;
      setStarred((prev) => {
        const next = prev.includes(projectId)
          ? prev.filter((id) => id !== projectId)
          : [...prev, projectId];
        try {
          localStorage.setItem(storageKey(userId, orgId), JSON.stringify(next));
        } catch {
          // Storage unavailable (private mode etc.) — star still applies for the session.
        }
        return next;
      });
    },
    [userId, orgId],
  );

  const isStarred = useCallback((projectId: string) => starred.includes(projectId), [starred]);

  return (
    <StarredContext.Provider value={{ starred, isStarred, toggle }}>
      {children}
    </StarredContext.Provider>
  );
}

export function useStarredProjects() {
  return useContext(StarredContext);
}
