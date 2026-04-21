"use client";

import Link from "next/link";
import { useParams } from "next/navigation";
import { useState } from "react";
import useSWR from "swr";
import clsx from "clsx";
import {
  ArrowLeftIcon,
  QueueListIcon,
} from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import type { Task, TaskStatus } from "@/lib/api/types";
import { Card } from "@/components/primitives/Card";
import { Badge } from "@/components/primitives/Badge";
import type { BadgeProps } from "@/components/primitives/Badge";
import { EmptyState } from "@/components/primitives/EmptyState";
import { PageHeader } from "@/components/primitives/PageHeader";

const STATUSES: TaskStatus[] = ["pending", "in_progress", "blocked", "review", "done"];

function statusVariant(s: TaskStatus): BadgeProps["variant"] {
  switch (s) {
    case "done":        return "success";
    case "in_progress": return "warning";
    case "review":      return "info";
    case "blocked":     return "danger";
    case "pending":
    default:            return "default";
  }
}

function priorityLabel(p: number): string {
  if (p >= 3) return "urgent";
  if (p === 2) return "high";
  if (p === 1) return "normal";
  return "low";
}

function priorityVariant(p: number): BadgeProps["variant"] {
  if (p >= 3) return "danger";
  if (p === 2) return "warning";
  return "default";
}

export function TaskDetailClient() {
  const params = useParams();
  const idRaw = typeof params.id === "string" ? params.id : Array.isArray(params.id) ? params.id[0] : "";
  const id = Number.parseInt(idRaw, 10);
  const validId = Number.isFinite(id) && id > 0;

  const { data: task, isLoading, error, mutate } = useSWR(
    validId ? `task.${id}` : null,
    () => api.tasks.get(id),
  );

  const [newNote, setNewNote] = useState("");
  const [noteSubmitting, setNoteSubmitting] = useState(false);
  const [noteError, setNoteError] = useState<string | null>(null);
  const [statusSubmitting, setStatusSubmitting] = useState(false);

  async function handleStatusChange(status: TaskStatus) {
    if (!task) return;
    setStatusSubmitting(true);
    try {
      const updated = await api.tasks.updateStatus(task.id, status);
      await mutate(updated, { revalidate: false });
    } finally {
      setStatusSubmitting(false);
    }
  }

  async function handleAppendNote() {
    if (!task || !newNote.trim()) return;
    setNoteSubmitting(true);
    setNoteError(null);
    try {
      const updated = await api.tasks.updateStatus(task.id, task.status, newNote.trim());
      setNewNote("");
      await mutate(updated, { revalidate: false });
    } catch (err) {
      setNoteError(err instanceof Error ? err.message : "Failed to append note.");
    } finally {
      setNoteSubmitting(false);
    }
  }

  if (isLoading) {
    return (
      <div className="space-y-6 animate-pulse">
        <div className="h-8 bg-surface-sunken rounded w-1/3" />
        <div className="h-4 bg-surface-sunken rounded w-2/3" />
        <div className="h-40 bg-surface-sunken rounded" />
      </div>
    );
  }

  if (error || !task) {
    return (
      <div className="space-y-4">
        <Link
          href="/tasks"
          className="inline-flex items-center gap-1.5 text-xs text-muted hover:text-foreground transition-colors"
        >
          <ArrowLeftIcon className="h-3.5 w-3.5" /> Back to tasks
        </Link>
        <EmptyState
          icon={<QueueListIcon />}
          title="Task not found"
          description={`No task with id "${idRaw}" was found.`}
        />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <Link
        href="/tasks"
        className="inline-flex items-center gap-1.5 text-xs text-muted hover:text-foreground transition-colors"
      >
        <ArrowLeftIcon className="h-3.5 w-3.5" /> Back to tasks
      </Link>

      <PageHeader
        title={task.title}
        description={task.description || undefined}
        actions={
          <div className="flex items-center gap-2">
            <Badge variant={priorityVariant(task.priority)}>
              P{task.priority} — {priorityLabel(task.priority)}
            </Badge>
            <Badge variant={statusVariant(task.status)}>{task.status}</Badge>
            <span className="font-mono text-xs text-muted">#{task.id}</span>
          </div>
        }
      />

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <div className="lg:col-span-2 space-y-4">
          <Card>
            <h2 className="text-sm font-semibold uppercase tracking-wide text-subtle mb-2">Notes</h2>
            {task.notes ? (
              <p className="text-sm text-foreground whitespace-pre-wrap leading-relaxed">{task.notes}</p>
            ) : (
              <p className="text-sm text-subtle italic">No notes yet.</p>
            )}
            <div className="mt-4 pt-3 border-t border-border flex flex-col gap-2">
              <label className="text-xs font-medium text-subtle uppercase tracking-wide">
                Append note
              </label>
              <textarea
                rows={3}
                value={newNote}
                onChange={(e) => setNewNote(e.target.value)}
                placeholder="Substring-deduped against existing notes."
                disabled={noteSubmitting}
                className="font-mono text-xs rounded-md border border-border bg-surface-sunken px-3 py-2 text-foreground placeholder:text-subtle focus:outline-none focus:ring-2 focus:ring-accent/40 resize-y"
              />
              <div className="flex items-center justify-between gap-2">
                <span className="text-xs">
                  {noteError && <span className="text-danger">{noteError}</span>}
                </span>
                <button
                  onClick={handleAppendNote}
                  disabled={noteSubmitting || !newNote.trim()}
                  className={clsx(
                    "text-xs rounded-md px-3 py-1.5 font-medium transition-colors",
                    noteSubmitting || !newNote.trim()
                      ? "bg-surface-raised text-subtle cursor-not-allowed"
                      : "bg-accent text-white hover:bg-accent/90"
                  )}
                >
                  {noteSubmitting ? "Appending…" : "Append"}
                </button>
              </div>
            </div>
          </Card>
        </div>

        <div className="space-y-4">
          <Card>
            <h2 className="text-sm font-semibold uppercase tracking-wide text-subtle mb-3">
              Status
            </h2>
            <div className="grid grid-cols-1 gap-1.5">
              {STATUSES.map((s) => (
                <button
                  key={s}
                  onClick={() => handleStatusChange(s)}
                  disabled={statusSubmitting || s === task.status}
                  className={clsx(
                    "flex items-center justify-between gap-2 text-xs rounded-md px-3 py-1.5 transition-colors border",
                    s === task.status
                      ? "border-accent/40 bg-accent/10 text-accent font-medium"
                      : "border-border text-muted hover:text-foreground hover:bg-surface-raised"
                  )}
                >
                  <span className="font-mono">{s}</span>
                  {s === task.status && <span className="text-[10px]">current</span>}
                </button>
              ))}
            </div>
          </Card>

          <Card>
            <h2 className="text-sm font-semibold uppercase tracking-wide text-subtle mb-3">
              Metadata
            </h2>
            <dl className="space-y-2 text-sm">
              <div className="flex items-center justify-between gap-2">
                <dt className="text-xs text-subtle uppercase tracking-wide">ID</dt>
                <dd className="font-mono text-foreground">#{task.id}</dd>
              </div>
              <div className="flex items-center justify-between gap-2">
                <dt className="text-xs text-subtle uppercase tracking-wide">Priority</dt>
                <dd className="font-mono text-foreground">{task.priority}</dd>
              </div>
              <div className="flex items-center justify-between gap-2">
                <dt className="text-xs text-subtle uppercase tracking-wide">Assignee</dt>
                <dd className="text-foreground">{task.assigned_to ?? <span className="text-subtle">—</span>}</dd>
              </div>
              <div className="flex flex-col gap-1">
                <dt className="text-xs text-subtle uppercase tracking-wide">Created</dt>
                <dd className="text-foreground font-mono text-xs">{task.created_at ?? "—"}</dd>
              </div>
              <div className="flex flex-col gap-1">
                <dt className="text-xs text-subtle uppercase tracking-wide">Updated</dt>
                <dd className="text-foreground font-mono text-xs">{task.updated_at ?? "—"}</dd>
              </div>
            </dl>
          </Card>
        </div>
      </div>
    </div>
  );
}
