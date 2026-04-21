"use client";

import Link from "next/link";
import { useState } from "react";
import useSWR from "swr";
import clsx from "clsx";
import {
  DocumentIcon,
  PlusIcon,
  XMarkIcon,
} from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import type { Artifact, ArtifactKind } from "@/lib/api/types";
import { Card } from "@/components/primitives/Card";
import { PageHeader } from "@/components/primitives/PageHeader";
import { EmptyState } from "@/components/primitives/EmptyState";
import { Badge } from "@/components/primitives/Badge";
import type { BadgeProps } from "@/components/primitives/Badge";

import { relativeTime } from "@/lib/utils/format";
import { kindVariant } from "@/lib/utils/badges";

const KINDS: ArtifactKind[] = ["markdown", "json", "yaml", "code", "text", "other"];

function kindBadgeVariant(kind: string): BadgeProps["variant"] {
  return kindVariant(kind);
}

function NewArtifactForm({ onCreated }: { onCreated: () => void }) {
  const [open, setOpen] = useState(false);
  const [title, setTitle] = useState("");
  const [kind, setKind] = useState<ArtifactKind>("markdown");
  const [description, setDescription] = useState("");
  const [content, setContent] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit() {
    if (!title.trim() || !content.trim()) return;
    setSubmitting(true);
    setError(null);
    try {
      await api.artifacts.create({
        title: title.trim(),
        content,
        kind,
        description: description.trim() || undefined,
      });
      setTitle("");
      setDescription("");
      setContent("");
      setKind("markdown");
      setOpen(false);
      onCreated();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to create artifact.");
    } finally {
      setSubmitting(false);
    }
  }

  if (!open) {
    return (
      <button
        onClick={() => setOpen(true)}
        className="inline-flex items-center gap-1.5 rounded-md bg-accent px-3 py-1.5 text-sm font-medium text-white hover:bg-accent/90 transition-colors"
      >
        <PlusIcon className="h-4 w-4" /> New artifact
      </button>
    );
  }

  return (
    <Card className="flex flex-col gap-3">
      <div className="flex items-center justify-between">
        <h3 className="text-sm font-semibold text-foreground">New artifact</h3>
        <button
          onClick={() => setOpen(false)}
          className="text-muted hover:text-foreground"
          aria-label="Close"
        >
          <XMarkIcon className="h-4 w-4" />
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
        <div className="flex flex-col gap-1">
          <label className="text-xs font-medium text-muted uppercase tracking-wide">Title</label>
          <input
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="e.g. Draft PRD"
            className="rounded-md border border-border bg-surface-sunken px-3 py-1.5 text-sm text-foreground placeholder:text-subtle focus:outline-none focus:ring-2 focus:ring-accent/40"
          />
        </div>
        <div className="flex flex-col gap-1">
          <label className="text-xs font-medium text-muted uppercase tracking-wide">Kind</label>
          <select
            value={kind}
            onChange={(e) => setKind(e.target.value as ArtifactKind)}
            className="rounded-md border border-border bg-surface-sunken px-3 py-1.5 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-accent/40"
          >
            {KINDS.map((k) => <option key={k} value={k}>{k}</option>)}
          </select>
        </div>
        <div className="md:col-span-2 flex flex-col gap-1">
          <label className="text-xs font-medium text-muted uppercase tracking-wide">Description</label>
          <input
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            className="rounded-md border border-border bg-surface-sunken px-3 py-1.5 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-accent/40"
          />
        </div>
        <div className="md:col-span-2 flex flex-col gap-1">
          <label className="text-xs font-medium text-muted uppercase tracking-wide">Content (revision 1)</label>
          <textarea
            rows={8}
            value={content}
            onChange={(e) => setContent(e.target.value)}
            placeholder="Artifact body..."
            className="font-mono text-xs rounded-md border border-border bg-surface-sunken px-3 py-2 text-foreground focus:outline-none focus:ring-2 focus:ring-accent/40 resize-y"
          />
        </div>
      </div>

      {error && <p className="text-xs text-danger">{error}</p>}

      <div className="flex items-center justify-end gap-2">
        <button
          onClick={() => setOpen(false)}
          className="text-xs rounded-md border border-border px-3 py-1.5 text-muted hover:text-foreground hover:bg-surface-raised transition-colors"
        >
          Cancel
        </button>
        <button
          onClick={handleSubmit}
          disabled={submitting || !title.trim() || !content.trim()}
          className={clsx(
            "text-xs rounded-md px-3 py-1.5 font-medium transition-colors",
            submitting || !title.trim() || !content.trim()
              ? "bg-surface-raised text-subtle cursor-not-allowed"
              : "bg-accent text-white hover:bg-accent/90"
          )}
        >
          {submitting ? "Creating…" : "Create"}
        </button>
      </div>
    </Card>
  );
}

export default function ArtifactsPage() {
  const [kindFilter, setKindFilter] = useState<ArtifactKind | "">("");
  const { data, isLoading, error, mutate } = useSWR(
    `artifacts.list.${kindFilter}`,
    () => api.artifacts.list(kindFilter || undefined),
  );

  const artifacts = data?.artifacts ?? [];

  return (
    <div className="space-y-6">
      <PageHeader
        title="Artifacts"
        description="Versioned text artifacts (PRD-002 MVP). Each artifact has a history of revisions."
        actions={<NewArtifactForm onCreated={() => mutate()} />}
      />

      <Card className="flex flex-wrap items-center gap-3">
        <div className="flex items-center gap-2">
          <label className="text-xs font-medium text-muted uppercase tracking-wide">Kind</label>
          <select
            value={kindFilter}
            onChange={(e) => setKindFilter(e.target.value as ArtifactKind | "")}
            className="text-xs rounded border border-border bg-surface-sunken px-2 py-1 text-foreground focus:outline-none focus:ring-2 focus:ring-accent/40"
          >
            <option value="">All</option>
            {KINDS.map((k) => <option key={k} value={k}>{k}</option>)}
          </select>
        </div>
        {kindFilter && (
          <button
            onClick={() => setKindFilter("")}
            className="text-xs text-muted hover:text-foreground transition-colors"
          >
            Clear
          </button>
        )}
        <span className="ml-auto text-xs text-subtle">
          {data?.count ?? 0} artifact{(data?.count ?? 0) === 1 ? "" : "s"}
        </span>
      </Card>

      {error && (
        <div className="rounded-md border border-danger/30 bg-danger/10 px-4 py-3 text-sm text-danger">
          Failed to load artifacts: {String(error)}
        </div>
      )}

      {isLoading && (
        <div className="space-y-2">
          {[1, 2, 3].map((i) => (
            <Card key={i} className="animate-pulse h-14">
              <div className="h-4 bg-surface-sunken rounded w-1/3" />
            </Card>
          ))}
        </div>
      )}

      {!isLoading && artifacts.length === 0 && (
        <EmptyState
          icon={<DocumentIcon />}
          title="No artifacts"
          description={kindFilter ? "No artifacts match the filter." : "Create the first artifact to get started."}
        />
      )}

      {!isLoading && artifacts.length > 0 && (
        <div className="flex flex-col gap-2">
          {artifacts.map((a: Artifact) => (
            <Link key={a.id} href={`/artifacts/${a.id}`} className="block">
              <Card hoverable className="flex items-center gap-3">
                <div className="flex-1 min-w-0 flex flex-col gap-0.5">
                  <div className="flex items-center gap-2 min-w-0">
                    <span className="text-sm font-medium text-foreground truncate">{a.title}</span>
                    <span className="font-mono text-[11px] text-subtle shrink-0">#{a.id}</span>
                  </div>
                  {a.description && (
                    <p className="text-xs text-muted truncate">{a.description}</p>
                  )}
                </div>
                <div className="flex items-center gap-2 shrink-0">
                  <Badge variant={kindBadgeVariant(a.kind)} size="sm">{a.kind}</Badge>
                  <span className="text-xs text-muted">
                    v{a.latest_revision}
                  </span>
                  <span className="text-xs text-subtle font-mono">
                    {a.updated_at ? relativeTime(a.updated_at) : "—"}
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
