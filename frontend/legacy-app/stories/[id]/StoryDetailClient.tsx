"use client";

import { useParams } from "next/navigation";
import useSWR from "swr";
import { DocumentTextIcon } from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import type { Story, StoryStatus, StoryPriority } from "@/lib/api/types";
import { Card } from "@/components/primitives/Card";
import { Badge } from "@/components/primitives/Badge";
import type { BadgeProps } from "@/components/primitives/Badge";
import { EmptyState } from "@/components/primitives/EmptyState";
import { DetailHeader } from "@/components/composites/DetailHeader";

function statusBadgeVariant(status: StoryStatus): BadgeProps["variant"] {
  switch (status) {
    case "done":        return "success";
    case "in_progress": return "warning";
    case "ready":       return "info";
    case "archived":    return "default";
    case "draft":
    default:            return "default";
  }
}

function priorityBadgeVariant(priority: StoryPriority): BadgeProps["variant"] {
  switch (priority) {
    case "critical": return "danger";
    case "high":     return "warning";
    case "medium":   return "info";
    case "low":
    default:         return "default";
  }
}

function StoryHeader({ story }: { story: Story }) {
  const backHref = story.project_id ? `/projects/${story.project_id}` : "/projects";
  const backLabel = story.project_id ? "Back to project" : "Back to projects";
  return (
    <DetailHeader
      breadcrumbs={[
        { label: "Projects", href: "/projects" },
        ...(story.project_id
          ? [{ label: "Project", href: `/projects/${story.project_id}` }]
          : []),
        { label: story.title },
      ]}
      backHref={backHref}
      backLabel={backLabel}
      title={story.title}
      description={story.story_text || undefined}
      actions={
        <div className="flex items-center gap-2">
          <Badge variant={priorityBadgeVariant(story.priority)}>{story.priority}</Badge>
          <Badge variant={statusBadgeVariant(story.status)}>{story.status}</Badge>
          <code className="font-mono text-xs text-muted">{story.id}</code>
        </div>
      }
    />
  );
}

export function StoryDetailClient() {
  const params = useParams();
  const id = typeof params.id === "string"
    ? params.id
    : Array.isArray(params.id) ? params.id[0] : "";

  const { data: story, isLoading, error } = useSWR(
    id ? `story.${id}` : null,
    () => api.stories.get(id),
  );

  if (isLoading) {
    return (
      <div className="space-y-6 animate-pulse">
        <div className="h-8 bg-surface-1 rounded w-1/3" />
        <div className="h-4 bg-surface-1 rounded w-2/3" />
        <div className="h-40 bg-surface-1 rounded" />
      </div>
    );
  }

  if (error || !story) {
    return (
      <EmptyState
        icon={<DocumentTextIcon />}
        title="Story not found"
        description={`No story with id "${id}" was found.`}
      />
    );
  }

  return (
    <div className="space-y-6">
      <StoryHeader story={story} />

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <div className="lg:col-span-2 space-y-6">
          <Card>
            <h2 className="text-sm font-semibold uppercase tracking-wide text-subtle mb-2">
              Description
            </h2>
            {story.description ? (
              <p className="text-sm text-foreground whitespace-pre-wrap leading-relaxed">
                {story.description}
              </p>
            ) : (
              <p className="text-sm text-subtle italic">No description provided.</p>
            )}
          </Card>

          <Card>
            <h2 className="text-sm font-semibold uppercase tracking-wide text-subtle mb-2">
              Acceptance Criteria
            </h2>
            {story.acceptance_criteria.length === 0 ? (
              <p className="text-sm text-subtle italic">None defined.</p>
            ) : (
              <ul className="list-disc list-inside space-y-1 text-sm text-foreground marker:text-subtle">
                {story.acceptance_criteria.map((c, i) => (
                  <li key={i} className="leading-relaxed">{c}</li>
                ))}
              </ul>
            )}
          </Card>
        </div>

        <div className="space-y-4">
          <Card>
            <h2 className="text-sm font-semibold uppercase tracking-wide text-subtle mb-3">
              Metadata
            </h2>
            <dl className="space-y-2.5 text-sm">
              <div className="flex items-center justify-between gap-2">
                <dt className="text-xs font-medium text-subtle uppercase tracking-wide">Status</dt>
                <dd><Badge variant={statusBadgeVariant(story.status)}>{story.status}</Badge></dd>
              </div>
              <div className="flex items-center justify-between gap-2">
                <dt className="text-xs font-medium text-subtle uppercase tracking-wide">Priority</dt>
                <dd><Badge variant={priorityBadgeVariant(story.priority)}>{story.priority}</Badge></dd>
              </div>
              <div className="flex items-center justify-between gap-2">
                <dt className="text-xs font-medium text-subtle uppercase tracking-wide">Points</dt>
                <dd className="font-mono text-foreground">{story.story_points}</dd>
              </div>
              <div className="flex items-center justify-between gap-2">
                <dt className="text-xs font-medium text-subtle uppercase tracking-wide">Personas</dt>
                <dd className="text-foreground">{story.persona_ids.length}</dd>
              </div>
              <div className="flex flex-col gap-1">
                <dt className="text-xs font-medium text-subtle uppercase tracking-wide">Created</dt>
                <dd className="text-foreground font-mono text-xs">{story.created_at}</dd>
              </div>
              <div className="flex flex-col gap-1">
                <dt className="text-xs font-medium text-subtle uppercase tracking-wide">Updated</dt>
                <dd className="text-foreground font-mono text-xs">{story.updated_at}</dd>
              </div>
            </dl>
          </Card>

          {story.tags.length > 0 && (
            <Card>
              <h2 className="text-sm font-semibold uppercase tracking-wide text-subtle mb-3">
                Tags
              </h2>
              <div className="flex flex-wrap gap-1.5">
                {story.tags.map((t) => (
                  <Badge key={t} variant="default">{t}</Badge>
                ))}
              </div>
            </Card>
          )}
        </div>
      </div>
    </div>
  );
}
