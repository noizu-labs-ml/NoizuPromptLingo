"use client";

import Link from "next/link";
import { useState } from "react";
import useSWR from "swr";
import clsx from "clsx";
import {
  QueueListIcon,
  PlusIcon,
  XMarkIcon,
} from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import type { Task, TaskStatus } from "@/lib/api/types";
import { Card } from "@/components/primitives/Card";
import { PageHeader } from "@/components/primitives/PageHeader";
import { EmptyState } from "@/components/primitives/EmptyState";
import { Badge } from "@/components/primitives/Badge";
import type { BadgeProps } from "@/components/primitives/Badge";

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

function TaskRow({ task, onStatusChange }: {
  task: Task;
  onStatusChange: (id: number, status: TaskStatus) => void;
}) {
  return (
    <Card className="flex items-center gap-3 py-3" padded={false}>
      <div className="px-4 flex-1 min-w-0 flex flex-col gap-0.5">
        <div className="flex items-center gap-2 min-w-0">
          <Link
            href={`/tasks/${task.id}`}
            className="text-sm font-medium text-foreground hover:text-accent transition-colors truncate"
          >
            {task.title}
          </Link>
          <span className="font-mono text-[11px] text-subtle shrink-0">#{task.id}</span>
        </div>
        {task.description && (
          <p className="text-xs text-muted truncate">{task.description}</p>
        )}
      </div>

      <div className="flex items-center gap-2 pr-4 shrink-0">
        <Badge variant={priorityVariant(task.priority)} size="sm">
          {priorityLabel(task.priority)}
        </Badge>
        {task.assigned_to && (
          <span className="text-xs text-muted font-mono">@{task.assigned_to}</span>
        )}
        <select
          value={task.status}
          onChange={(e) => onStatusChange(task.id, e.target.value as TaskStatus)}
          className="text-xs rounded border border-border bg-surface px-2 py-1 text-foreground focus:outline-none focus:ring-2 focus:ring-accent/40"
        >
          {STATUSES.map((s) => (
            <option key={s} value={s}>{s}</option>
          ))}
        </select>
      </div>
    </Card>
  );
}

function NewTaskForm({ onCreated }: { onCreated: () => void }) {
  const [open, setOpen] = useState(false);
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [priority, setPriority] = useState(1);
  const [assignedTo, setAssignedTo] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit() {
    if (!title.trim()) return;
    setSubmitting(true);
    setError(null);
    try {
      await api.tasks.create({
        title: title.trim(),
        description: description.trim() || undefined,
        priority,
        assigned_to: assignedTo.trim() || undefined,
      });
      setTitle("");
      setDescription("");
      setPriority(1);
      setAssignedTo("");
      setOpen(false);
      onCreated();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to create task.");
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
        <PlusIcon className="h-4 w-4" /> New task
      </button>
    );
  }

  return (
    <Card className="flex flex-col gap-3">
      <div className="flex items-center justify-between">
        <h3 className="text-sm font-semibold text-foreground">New task</h3>
        <button
          onClick={() => setOpen(false)}
          className="text-muted hover:text-foreground"
          aria-label="Close"
        >
          <XMarkIcon className="h-4 w-4" />
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
        <div className="md:col-span-2 flex flex-col gap-1">
          <label className="text-xs font-medium text-muted uppercase tracking-wide">Title</label>
          <input
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="Short, imperative title"
            className="rounded-md border border-border bg-surface-sunken px-3 py-1.5 text-sm text-foreground placeholder:text-subtle focus:outline-none focus:ring-2 focus:ring-accent/40"
          />
        </div>
        <div className="md:col-span-2 flex flex-col gap-1">
          <label className="text-xs font-medium text-muted uppercase tracking-wide">Description</label>
          <textarea
            rows={2}
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            className="rounded-md border border-border bg-surface-sunken px-3 py-1.5 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-accent/40 resize-y"
          />
        </div>
        <div className="flex flex-col gap-1">
          <label className="text-xs font-medium text-muted uppercase tracking-wide">Priority</label>
          <select
            value={priority}
            onChange={(e) => setPriority(parseInt(e.target.value))}
            className="rounded-md border border-border bg-surface-sunken px-3 py-1.5 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-accent/40"
          >
            <option value={0}>0 — low</option>
            <option value={1}>1 — normal</option>
            <option value={2}>2 — high</option>
            <option value={3}>3 — urgent</option>
          </select>
        </div>
        <div className="flex flex-col gap-1">
          <label className="text-xs font-medium text-muted uppercase tracking-wide">Assignee</label>
          <input
            value={assignedTo}
            onChange={(e) => setAssignedTo(e.target.value)}
            placeholder="optional"
            className="rounded-md border border-border bg-surface-sunken px-3 py-1.5 text-sm text-foreground placeholder:text-subtle focus:outline-none focus:ring-2 focus:ring-accent/40"
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
          disabled={submitting || !title.trim()}
          className={clsx(
            "text-xs rounded-md px-3 py-1.5 font-medium transition-colors",
            submitting || !title.trim()
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

export default function TasksPage() {
  const [statusFilter, setStatusFilter] = useState<TaskStatus | "">("");
  const [assigneeFilter, setAssigneeFilter] = useState("");
  const { data, isLoading, error, mutate } = useSWR(
    `tasks.list.${statusFilter}.${assigneeFilter}`,
    () => api.tasks.list({
      status: statusFilter || undefined,
      assigned_to: assigneeFilter.trim() || undefined,
    }),
  );

  async function handleStatusChange(id: number, status: TaskStatus) {
    try {
      await api.tasks.updateStatus(id, status);
      await mutate();
    } catch {
      // Silently revert by revalidating
      await mutate();
    }
  }

  const tasks = data?.tasks ?? [];
  const totalCount = data?.count ?? 0;

  return (
    <div className="space-y-6">
      <PageHeader
        title="Tasks"
        description="Flat work-item queue. Filter by status/assignee; flip status inline."
        actions={<NewTaskForm onCreated={() => mutate()} />}
      />

      <Card className="flex flex-wrap items-center gap-3">
        <div className="flex items-center gap-2">
          <label className="text-xs font-medium text-muted uppercase tracking-wide">
            Status
          </label>
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value as TaskStatus | "")}
            className="text-xs rounded border border-border bg-surface-sunken px-2 py-1 text-foreground focus:outline-none focus:ring-2 focus:ring-accent/40"
          >
            <option value="">All</option>
            {STATUSES.map((s) => <option key={s} value={s}>{s}</option>)}
          </select>
        </div>
        <div className="flex items-center gap-2">
          <label className="text-xs font-medium text-muted uppercase tracking-wide">
            Assignee
          </label>
          <input
            type="search"
            value={assigneeFilter}
            onChange={(e) => setAssigneeFilter(e.target.value)}
            placeholder="exact match…"
            className="text-xs rounded border border-border bg-surface-sunken px-2 py-1 text-foreground placeholder:text-subtle focus:outline-none focus:ring-2 focus:ring-accent/40 w-40"
          />
        </div>
        {(statusFilter || assigneeFilter) && (
          <button
            onClick={() => { setStatusFilter(""); setAssigneeFilter(""); }}
            className="text-xs text-muted hover:text-foreground transition-colors"
          >
            Clear
          </button>
        )}
        <span className="ml-auto text-xs text-subtle">
          {totalCount} task{totalCount === 1 ? "" : "s"}
        </span>
      </Card>

      {error && (
        <div className="rounded-md border border-danger/30 bg-danger/10 px-4 py-3 text-sm text-danger">
          Failed to load tasks: {String(error)}
        </div>
      )}

      {isLoading && (
        <div className="space-y-2">
          {[1, 2, 3].map((i) => (
            <Card key={i} className="animate-pulse h-12">
              <div className="h-4 bg-surface-sunken rounded w-2/3" />
            </Card>
          ))}
        </div>
      )}

      {!isLoading && tasks.length === 0 && (
        <EmptyState
          icon={<QueueListIcon />}
          title="No tasks"
          description={
            statusFilter || assigneeFilter
              ? "No tasks match the current filters."
              : "Create the first task to get started."
          }
        />
      )}

      {!isLoading && tasks.length > 0 && (
        <div className="flex flex-col gap-2">
          {tasks.map((t) => (
            <TaskRow key={t.id} task={t} onStatusChange={handleStatusChange} />
          ))}
        </div>
      )}
    </div>
  );
}
