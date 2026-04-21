"use client";

import Link from "next/link";
import useSWR from "swr";
import { FolderIcon } from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import { Card } from "@/components/primitives/Card";
import { PageHeader } from "@/components/primitives/PageHeader";
import { EmptyState } from "@/components/primitives/EmptyState";

function formatDate(iso: string): string {
  return new Date(iso).toLocaleDateString("en-US", {
    year: "numeric",
    month: "short",
    day: "numeric",
  });
}

export default function ProjectsPage() {
  const { data: projects, isLoading } = useSWR("projects.list", () =>
    api.projects.list()
  );

  return (
    <div className="space-y-8">
      <PageHeader
        title="Projects"
        description="NPL MCP projects with their personas and user stories."
      />

      {isLoading && (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {[1, 2, 3].map((i) => (
            <Card key={i} className="animate-pulse">
              <div className="h-4 bg-surface-1 rounded w-3/4 mb-2" />
              <div className="h-3 bg-surface-1 rounded w-1/2 mb-4" />
              <div className="h-3 bg-surface-1 rounded w-full mb-1" />
              <div className="h-3 bg-surface-1 rounded w-5/6" />
            </Card>
          ))}
        </div>
      )}

      {!isLoading && (!projects || projects.length === 0) && (
        <EmptyState
          icon={<FolderIcon />}
          title="No projects yet"
          description="Projects will appear here once they are created."
        />
      )}

      {!isLoading && projects && projects.length > 0 && (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {projects.map((project) => (
            <Link key={project.id} href={`/projects/${project.id}`} className="block rounded-lg group focus-ring">
              <Card hoverable className="h-full flex flex-col gap-3">
                <div className="flex flex-col gap-1">
                  <h2 className="text-base font-semibold text-foreground group-hover:text-accent transition-colors">
                    {project.title}
                  </h2>
                  <span className="text-xs font-mono text-muted">{project.name}</span>
                </div>

                <p className="text-sm text-muted line-clamp-2 flex-1">
                  {project.description}
                </p>

                <div className="flex items-center gap-2 flex-wrap pt-1 border-t border-border">
                  <span className="inline-flex items-center rounded-full bg-accent/10 text-accent px-2.5 py-0.5 text-xs font-medium">
                    {project.persona_count} personas
                  </span>
                  <span className="inline-flex items-center rounded-full bg-accent/10 text-accent px-2.5 py-0.5 text-xs font-medium">
                    {project.story_count} stories
                  </span>
                  <span className="ml-auto text-xs text-subtle">
                    {formatDate(project.created_at)}
                  </span>
                </div>
              </Card>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
