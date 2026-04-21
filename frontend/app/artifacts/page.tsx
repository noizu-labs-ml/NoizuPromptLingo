"use client";

import Link from "next/link";
import { useState } from "react";
import useSWR from "swr";
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
import { Button } from "@/components/primitives/Button";
import { Input } from "@/components/primitives/Input";
import { Select } from "@/components/primitives/Select";
import { Textarea } from "@/components/primitives/Textarea";
import { FormField } from "@/components/primitives/FormField";
import { SkeletonGrid } from "@/components/primitives/SkeletonGrid";
import { FilterBar } from "@/components/composites/FilterBar";

import { relativeTime } from "@/lib/utils/format";
import { kindVariant } from "@/lib/utils/badges";

const KINDS: ArtifactKind[] = [
  "markdown", "json", "yaml", "code", "text", "other",
  "image", "video", "audio", "pdf", "binary",
];
const MEDIA_KINDS: ArtifactKind[] = ["image", "video", "audio", "pdf", "binary"];
const MAX_UPLOAD_BYTES = 15 * 1024 * 1024;

function kindBadgeVariant(kind: string): BadgeProps["variant"] {
  return kindVariant(kind);
}

function NewArtifactForm({ onCreated }: { onCreated: () => void }) {
  const [open, setOpen] = useState(false);
  const [title, setTitle] = useState("");
  const [kind, setKind] = useState<ArtifactKind>("markdown");
  const [description, setDescription] = useState("");
  const [content, setContent] = useState("");
  const [file, setFile] = useState<File | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const isMedia = (MEDIA_KINDS as string[]).includes(kind);

  async function handleSubmit() {
    if (!title.trim()) return;
    setSubmitting(true);
    setError(null);
    try {
      if (isMedia) {
        if (!file) {
          setError("Please pick a file.");
          setSubmitting(false);
          return;
        }
        if (file.size > MAX_UPLOAD_BYTES) {
          setError("File exceeds 15 MB cap.");
          setSubmitting(false);
          return;
        }
        await api.artifacts.upload({
          file,
          title: title.trim(),
          kind,
          description: description.trim() || undefined,
        });
      } else {
        if (!content.trim()) {
          setError("Content cannot be empty.");
          setSubmitting(false);
          return;
        }
        await api.artifacts.create({
          title: title.trim(),
          content,
          kind,
          description: description.trim() || undefined,
        });
      }
      setTitle("");
      setDescription("");
      setContent("");
      setFile(null);
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
      <Button
        variant="primary"
        size="sm"
        leadingIcon={<PlusIcon className="h-4 w-4" />}
        onClick={() => setOpen(true)}
      >
        New artifact
      </Button>
    );
  }

  return (
    <Card className="flex flex-col gap-3">
      <div className="flex items-center justify-between">
        <h3 className="text-sm font-semibold text-foreground">New artifact</h3>
        <Button
          variant="icon"
          onClick={() => setOpen(false)}
          aria-label="Close"
        >
          <XMarkIcon className="h-4 w-4" />
        </Button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
        <FormField label="Title">
          <Input
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="e.g. Draft PRD"
          />
        </FormField>
        <FormField label="Kind">
          <Select
            value={kind}
            onChange={(e) => setKind(e.target.value as ArtifactKind)}
          >
            {KINDS.map((k) => <option key={k} value={k}>{k}</option>)}
          </Select>
        </FormField>
        <FormField label="Description" className="md:col-span-2">
          <Input
            value={description}
            onChange={(e) => setDescription(e.target.value)}
          />
        </FormField>
        {isMedia ? (
          <FormField
            label="File (revision 1)"
            helper="Max 15 MB. MIME type is detected from the file."
            className="md:col-span-2"
          >
            <input
              type="file"
              onChange={(e) => setFile(e.target.files?.[0] ?? null)}
              className="focus-ring block w-full text-sm text-foreground file:mr-3 file:rounded file:border-0 file:bg-accent file:px-3 file:py-1.5 file:text-xs file:font-semibold file:text-accent-on hover:file:bg-accent-soft"
            />
            {file && (
              <p className="mt-1 text-xs text-muted font-mono">
                {file.name} · {(file.size / 1024).toFixed(1)} KB · {file.type || "unknown"}
              </p>
            )}
          </FormField>
        ) : (
          <FormField label="Content (revision 1)" className="md:col-span-2">
            <Textarea
              rows={8}
              mono
              value={content}
              onChange={(e) => setContent(e.target.value)}
              placeholder="Artifact body..."
            />
          </FormField>
        )}
      </div>

      {error && (
        <p className="text-xs text-danger" role="alert" aria-live="polite">
          {error}
        </p>
      )}

      <div className="flex items-center justify-end gap-2">
        <Button variant="secondary" size="sm" onClick={() => setOpen(false)}>
          Cancel
        </Button>
        <Button
          variant="primary"
          size="sm"
          loading={submitting}
          disabled={!title.trim() || (isMedia ? !file : !content.trim())}
          onClick={handleSubmit}
        >
          {submitting ? "Creating…" : "Create"}
        </Button>
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

      <FilterBar
        filters={
          <FormField label="Kind">
            <Select
              inputSize="sm"
              value={kindFilter}
              onChange={(e) => setKindFilter(e.target.value as ArtifactKind | "")}
            >
              <option value="">All</option>
              {KINDS.map((k) => <option key={k} value={k}>{k}</option>)}
            </Select>
          </FormField>
        }
        hasActive={Boolean(kindFilter)}
        onClear={() => setKindFilter("")}
        summary={`${data?.count ?? 0} artifact${(data?.count ?? 0) === 1 ? "" : "s"}`}
      />

      {error && (
        <div
          role="alert"
          className="rounded-md border border-danger/30 bg-danger/10 px-4 py-3 text-sm text-danger"
        >
          Failed to load artifacts: {String(error)}
        </div>
      )}

      {isLoading && <SkeletonGrid as="row" count={6} />}

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
            <Link key={a.id} href={`/artifacts/${a.id}`} className="block rounded-lg focus-ring">
              <Card hoverable className="flex items-center gap-3">
                {a.kind === "image" ? (
                  <img
                    src={api.artifacts.rawUrl(a.id, a.latest_revision)}
                    alt=""
                    className="h-10 w-10 rounded object-cover border border-border/50 shrink-0"
                  />
                ) : null}
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
