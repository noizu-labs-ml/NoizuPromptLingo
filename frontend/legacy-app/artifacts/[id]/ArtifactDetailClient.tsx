"use client";

import { useParams } from "next/navigation";
import { useState } from "react";
import useSWR from "swr";
import clsx from "clsx";
import {
  ChatBubbleLeftRightIcon,
  DocumentIcon,
  DocumentTextIcon,
  PlusIcon,
} from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import type { ArtifactRevisionSummary } from "@/lib/api/types";
import { isBinaryKind } from "@/lib/api/types";
import { Card } from "@/components/primitives/Card";
import { Badge } from "@/components/primitives/Badge";
import { CodeBlock } from "@/components/primitives/CodeBlock";
import { EmptyState } from "@/components/primitives/EmptyState";
import { Button } from "@/components/primitives/Button";
import { Input } from "@/components/primitives/Input";
import { Textarea } from "@/components/primitives/Textarea";
import { FormField } from "@/components/primitives/FormField";
import { DetailHeader } from "@/components/composites/DetailHeader";
import { TabBar, TabPanel } from "@/components/composites/TabBar";
import { ReviewPanel } from "@/components/composites/ReviewPanel";

import { kindVariant } from "@/lib/utils/badges";

const MAX_UPLOAD_BYTES = 15 * 1024 * 1024;

export default function ArtifactDetailClient() {
  const params = useParams<{ id: string }>();
  const id = Number.parseInt(params?.id ?? "", 10);
  const validId = Number.isFinite(id) && id > 0;

  const [activeRevision, setActiveRevision] = useState<number | undefined>(undefined);
  const [newContent, setNewContent] = useState("");
  const [newNotes, setNewNotes] = useState("");
  const [newFile, setNewFile] = useState<File | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [addOpen, setAddOpen] = useState(false);
  const [addError, setAddError] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState("content");

  const { data: artifact, isLoading, mutate: mutateArtifact } = useSWR(
    validId ? `artifact.${id}.rev.${activeRevision ?? "latest"}` : null,
    () => api.artifacts.get(id, activeRevision),
  );
  const { data: revisionsData, mutate: mutateRevisions } = useSWR(
    validId ? `artifact.${id}.revisions` : null,
    () => api.artifacts.listRevisions(id),
  );

  const isBinary = artifact ? isBinaryKind(artifact.kind) : false;

  async function handleAddRevision() {
    setSubmitting(true);
    setAddError(null);
    try {
      let updated;
      if (isBinary) {
        if (!newFile) {
          setAddError("Please pick a file.");
          setSubmitting(false);
          return;
        }
        if (newFile.size > MAX_UPLOAD_BYTES) {
          setAddError("File exceeds 15 MB cap.");
          setSubmitting(false);
          return;
        }
        updated = await api.artifacts.addRevisionUpload(id, {
          file: newFile,
          notes: newNotes.trim() || undefined,
        });
      } else {
        if (!newContent.trim()) {
          setAddError("Content cannot be empty.");
          setSubmitting(false);
          return;
        }
        updated = await api.artifacts.addRevision(id, {
          content: newContent,
          notes: newNotes.trim() || undefined,
        });
      }
      setNewContent("");
      setNewNotes("");
      setNewFile(null);
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
        <div className="h-8 bg-surface-1 rounded w-1/3" />
        <div className="h-40 bg-surface-1 rounded" />
      </div>
    );
  }

  if (!artifact) {
    return (
      <div className="space-y-4">
        <DetailHeader
          breadcrumbs={[
            { label: "Artifacts", href: "/artifacts" },
            { label: "Not found" },
          ]}
          backHref="/artifacts"
          backLabel="Back to artifacts"
          title="Artifact not found"
        />
        <EmptyState
          icon={<DocumentIcon />}
          title="Artifact not found"
          description={`No artifact with id "${id}" was found.`}
        />
      </div>
    );
  }

  const revisions: ArtifactRevisionSummary[] = revisionsData?.revisions ?? [];
  const rawUrl = api.artifacts.rawUrl(artifact.id, artifact.revision.revision);
  const mime = artifact.revision.mime_type ?? "";

  return (
    <div className="space-y-6">
      <DetailHeader
        breadcrumbs={[
          { label: "Artifacts", href: "/artifacts" },
          { label: artifact.title },
        ]}
        backHref="/artifacts"
        backLabel="Back to artifacts"
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
              <Button
                variant="ghost"
                size="sm"
                onClick={() => setAddOpen((v) => !v)}
                leadingIcon={<PlusIcon className="h-3.5 w-3.5" />}
              >
                Add
              </Button>
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
                        type="button"
                        onClick={() => setActiveRevision(r.revision)}
                        className={clsx(
                          "focus-ring w-full flex items-center justify-between gap-2 rounded px-2 py-1 text-xs transition-colors",
                          current
                            ? "bg-accent/10 text-accent font-medium"
                            : "text-muted hover:bg-surface-1 hover:text-foreground"
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
            <Card className="space-y-3">
              <h3 className="text-sm font-semibold text-foreground">New revision</h3>
              {isBinary ? (
                <FormField label="File" htmlFor="new-revision-file" helper="Max 15 MB.">
                  <input
                    id="new-revision-file"
                    type="file"
                    onChange={(e) => setNewFile(e.target.files?.[0] ?? null)}
                    className="focus-ring block w-full text-xs text-foreground file:mr-3 file:rounded file:border-0 file:bg-accent file:px-3 file:py-1 file:text-xs file:font-semibold file:text-accent-on hover:file:bg-accent-soft"
                  />
                </FormField>
              ) : (
                <FormField label="Content" htmlFor="new-revision-content">
                  <Textarea
                    id="new-revision-content"
                    rows={5}
                    value={newContent}
                    onChange={(e) => setNewContent(e.target.value)}
                    placeholder="New content body..."
                    mono
                  />
                </FormField>
              )}
              <FormField label="Notes" htmlFor="new-revision-notes" helper="Optional change summary.">
                <Input
                  id="new-revision-notes"
                  inputSize="sm"
                  value={newNotes}
                  onChange={(e) => setNewNotes(e.target.value)}
                  placeholder="Notes (optional)"
                />
              </FormField>
              {addError && (
                <p className="text-xs text-danger" role="alert" aria-live="polite">
                  {addError}
                </p>
              )}
              <Button
                size="sm"
                onClick={handleAddRevision}
                disabled={submitting || (isBinary ? !newFile : !newContent.trim())}
                loading={submitting}
                className="w-full"
              >
                {submitting ? "Saving..." : `Save as v${artifact.latest_revision + 1}`}
              </Button>
            </Card>
          )}
        </aside>

        {/* Content and Reviews tabs */}
        <div className="flex-1 min-w-0 space-y-4">
          <TabBar
            tabs={[
              {
                id: "content",
                label: "Content",
                icon: <DocumentTextIcon className="h-3.5 w-3.5" />,
              },
              {
                id: "reviews",
                label: "Reviews",
                icon: <ChatBubbleLeftRightIcon className="h-3.5 w-3.5" />,
              },
            ]}
            value={activeTab}
            onChange={setActiveTab}
          >
            <TabPanel>
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
                  <p className="text-xs text-muted italic mb-2">&ldquo;{artifact.revision.notes}&rdquo;</p>
                )}
                {isBinary ? (
                  <MediaPreview kind={artifact.kind} mime={mime} rawUrl={rawUrl} title={artifact.title} />
                ) : (
                  <CodeBlock
                    code={artifact.revision.content}
                    language={artifact.kind === "markdown" ? "markdown" : artifact.kind}
                    maxHeight="500px"
                  />
                )}
              </Card>
            </TabPanel>
            <TabPanel>
              <ReviewPanel
                artifactId={artifact.id}
                revisionId={artifact.revision.revision}
              />
            </TabPanel>
          </TabBar>
        </div>
      </div>
    </div>
  );
}

function MediaPreview({
  kind,
  mime,
  rawUrl,
  title,
}: {
  kind: string;
  mime: string;
  rawUrl: string;
  title: string;
}) {
  if (kind === "image" || mime.startsWith("image/")) {
    return (
      <div className="rounded-lg border border-border/50 bg-surface-1 p-3 flex items-center justify-center">
        <img
          src={rawUrl}
          alt={title}
          className="max-w-full max-h-[70vh] object-contain rounded"
        />
      </div>
    );
  }
  if (kind === "video" || mime.startsWith("video/")) {
    return (
      <div className="rounded-lg border border-border/50 bg-surface-1 p-3">
        <video
          src={rawUrl}
          controls
          className="w-full max-h-[70vh] rounded"
        />
      </div>
    );
  }
  if (kind === "audio" || mime.startsWith("audio/")) {
    return (
      <div className="rounded-lg border border-border/50 bg-surface-1 p-4">
        <audio src={rawUrl} controls className="w-full" />
        <p className="mt-2 text-xs text-muted font-mono">{mime}</p>
      </div>
    );
  }
  if (kind === "pdf" || mime === "application/pdf") {
    return (
      <div className="rounded-lg border border-border/50 bg-surface-1 overflow-hidden">
        <iframe
          src={rawUrl}
          title={title}
          className="w-full"
          style={{ height: "75vh", border: 0 }}
        />
      </div>
    );
  }
  // binary / unknown -- offer download
  return (
    <div className="rounded-lg border border-border/50 bg-surface-1 p-6 text-center space-y-3">
      <p className="text-sm text-muted">Binary artifact ({mime || "unknown type"}).</p>
      <a
        href={rawUrl}
        download={title}
        className="focus-ring inline-flex items-center gap-2 rounded-md bg-accent px-4 py-2 text-sm font-semibold text-accent-on hover:bg-accent-soft transition-colors"
      >
        Download
      </a>
    </div>
  );
}
