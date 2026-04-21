"use client";

import Link from "next/link";
import { useParams } from "next/navigation";
import { useState } from "react";
import useSWR from "swr";
import clsx from "clsx";
import {
  ArrowLeftIcon,
  DocumentIcon,
  PlusIcon,
} from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import type { ArtifactRevisionSummary } from "@/lib/api/types";
import { Card } from "@/components/primitives/Card";
import { Badge } from "@/components/primitives/Badge";
import { CodeBlock } from "@/components/primitives/CodeBlock";
import { PageHeader } from "@/components/primitives/PageHeader";
import { EmptyState } from "@/components/primitives/EmptyState";

import { kindVariant } from "@/lib/utils/badges";

export default function ArtifactDetailClient() {
  const params = useParams<{ id: string }>();
  const id = Number.parseInt(params?.id ?? "", 10);
  const validId = Number.isFinite(id) && id > 0;

  const [activeRevision, setActiveRevision] = useState<number | undefined>(undefined);
  const [newContent, setNewContent] = useState("");
  const [newNotes, setNewNotes] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [addOpen, setAddOpen] = useState(false);
  const [addError, setAddError] = useState<string | null>(null);

  const { data: artifact, isLoading, mutate: mutateArtifact } = useSWR(
    validId ? `artifact.${id}.rev.${activeRevision ?? "latest"}` : null,
    () => api.artifacts.get(id, activeRevision),
  );
  const { data: revisionsData, mutate: mutateRevisions } = useSWR(
    validId ? `artifact.${id}.revisions` : null,
    () => api.artifacts.listRevisions(id),
  );

  async function handleAddRevision() {
    if (!newContent.trim()) return;
    setSubmitting(true);
    setAddError(null);
    try {
      const updated = await api.artifacts.addRevision(id, {
        content: newContent,
        notes: newNotes.trim() || undefined,
      });
      setNewContent("");
      setNewNotes("");
      setAddOpen(false);
      setActiveRevision(updated.revision.revision);
      await Promise.all([mutateArtifact(), mutateRevisions()]);
    } catch (err) {
      setAddError(err instanceof Error ? err.message : "Failed to add revision.");
    } finally {
      setSubmitting(false);
    }
  }

  if (!validId) {
    return (
      <EmptyState
        icon={<DocumentIcon />}
        title="Invalid artifact id"
        description={`"${params?.id}" is not a valid artifact id.`}
      />
    );
  }

  if (isLoading) {
    return (
      <div className="space-y-6 animate-pulse">
        <div className="h-8 bg-surface-sunken rounded w-1/3" />
        <div className="h-40 bg-surface-sunken rounded" />
      </div>
    );
  }

  if (!artifact) {
    return (
      <div className="space-y-4">
        <Link
          href="/artifacts"
          className="inline-flex items-center gap-1.5 text-xs text-muted hover:text-foreground transition-colors"
        >
          <ArrowLeftIcon className="h-3.5 w-3.5" /> Back to artifacts
        </Link>
        <EmptyState
          icon={<DocumentIcon />}
          title="Artifact not found"
          description={`No artifact with id "${id}" was found.`}
        />
      </div>
    );
  }

  const revisions: ArtifactRevisionSummary[] = revisionsData?.revisions ?? [];

  return (
    <div className="space-y-6">
      <Link
        href="/artifacts"
        className="inline-flex items-center gap-1.5 text-xs text-muted hover:text-foreground transition-colors"
      >
        <ArrowLeftIcon className="h-3.5 w-3.5" /> Back to artifacts
      </Link>

      <PageHeader
        title={artifact.title}
        description={artifact.description || undefined}
        actions={
          <div className="flex items-center gap-2">
            <Badge variant={kindVariant(artifact.kind)}>{artifact.kind}</Badge>
            <span className="font-mono text-xs text-muted">#{artifact.id}</span>
            <span className="text-xs text-muted">v{artifact.latest_revision} latest</span>
          </div>
        }
      />

      <div className="flex flex-col lg:flex-row gap-6 items-start">
        {/* Revision sidebar */}
        <aside className="w-full lg:w-60 shrink-0 space-y-3">
          <Card>
            <div className="flex items-center justify-between mb-3">
              <h3 className="text-sm font-semibold text-foreground">Revisions</h3>
              <button
                onClick={() => setAddOpen((v) => !v)}
                className="text-xs text-accent hover:text-accent/80 transition-colors inline-flex items-center gap-0.5"
              >
                <PlusIcon className="h-3.5 w-3.5" /> Add
              </button>
            </div>
            {revisions.length === 0 ? (
              <p className="text-xs text-muted">No revisions loaded.</p>
            ) : (
              <ul className="flex flex-col gap-0.5">
                {[...revisions].reverse().map((r) => {
                  const current =
                    (activeRevision ?? artifact.latest_revision) === r.revision;
                  return (
                    <li key={r.id}>
                      <button
                        onClick={() => setActiveRevision(r.revision)}
                        className={clsx(
                          "w-full flex items-center justify-between gap-2 rounded px-2 py-1 text-xs transition-colors",
                          current
                            ? "bg-accent/10 text-accent font-medium"
                            : "text-muted hover:bg-surface-raised hover:text-foreground"
                        )}
                      >
                        <span className="font-mono">v{r.revision}</span>
                        {r.notes && (
                          <span className="text-subtle truncate max-w-[100px]" title={r.notes}>
                            {r.notes}
                          </span>
                        )}
                        {current && <span className="text-[10px] shrink-0">viewing</span>}
                      </button>
                    </li>
                  );
                })}
              </ul>
            )}
          </Card>

          {addOpen && (
            <Card className="space-y-2">
              <h3 className="text-sm font-semibold text-foreground">New revision</h3>
              <textarea
                rows={5}
                value={newContent}
                onChange={(e) => setNewContent(e.target.value)}
                placeholder="New content body…"
                className="font-mono text-xs rounded-md border border-border bg-surface-sunken px-3 py-2 text-foreground focus:outline-none focus:ring-2 focus:ring-accent/40 resize-y w-full"
              />
              <input
                value={newNotes}
                onChange={(e) => setNewNotes(e.target.value)}
                placeholder="Notes (optional)"
                className="rounded-md border border-border bg-surface-sunken px-2 py-1 text-xs text-foreground focus:outline-none focus:ring-2 focus:ring-accent/40 w-full"
              />
              {addError && <p className="text-xs text-danger">{addError}</p>}
              <button
                onClick={handleAddRevision}
                disabled={submitting || !newContent.trim()}
                className={clsx(
                  "w-full text-xs rounded-md px-3 py-1.5 font-medium transition-colors",
                  submitting || !newContent.trim()
                    ? "bg-surface-raised text-subtle cursor-not-allowed"
                    : "bg-accent text-white hover:bg-accent/90"
                )}
              >
                {submitting ? "Saving…" : `Save as v${artifact.latest_revision + 1}`}
              </button>
            </Card>
          )}
        </aside>

        {/* Content */}
        <div className="flex-1 min-w-0 space-y-4">
          <Card>
            <div className="flex items-center justify-between mb-2">
              <h3 className="text-sm font-semibold text-foreground">
                Content <span className="font-mono text-xs text-muted ml-1">v{artifact.revision.revision}</span>
              </h3>
              {artifact.revision.created_at && (
                <span className="text-xs text-subtle font-mono">
                  {artifact.revision.created_at}
                </span>
              )}
            </div>
            {artifact.revision.notes && (
              <p className="text-xs text-muted italic mb-2">“{artifact.revision.notes}”</p>
            )}
            <CodeBlock
              code={artifact.revision.content}
              language={artifact.kind === "markdown" ? "markdown" : artifact.kind}
              maxHeight="500px"
            />
          </Card>
        </div>
      </div>
    </div>
  );
}
