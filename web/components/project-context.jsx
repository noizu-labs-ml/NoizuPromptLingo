"use client";
import { createContext, useContext, useState, useEffect, useCallback } from "react";

const ProjectContext = createContext(null);

export function ProjectProvider({ children }) {
  const [projects, setProjects] = useState([]);
  const [current, setCurrent] = useState(null);
  const [loading, setLoading] = useState(true);

  const refresh = useCallback(() => {
    fetch("/api/projects-list")
      .then((r) => r.ok ? r.json() : { projects: [] })
      .then((data) => {
        const list = data.projects || [];
        setProjects(list);
        const saved = localStorage.getItem("tobor_current_project");
        if (saved) {
          const match = list.find((p) => p.slug === saved);
          if (match) setCurrent(match);
        }
        setLoading(false);
      })
      .catch(() => setLoading(false));
  }, []);

  useEffect(() => { refresh(); }, [refresh]);

  function select(project) {
    setCurrent(project);
    if (project) {
      localStorage.setItem("tobor_current_project", project.slug);
    } else {
      localStorage.removeItem("tobor_current_project");
    }
  }

  return (
    <ProjectContext.Provider value={{ projects, current, select, loading, refresh }}>
      {children}
    </ProjectContext.Provider>
  );
}

export function useProject() {
  const ctx = useContext(ProjectContext);
  if (!ctx) throw new Error("useProject must be used within ProjectProvider");
  return ctx;
}
