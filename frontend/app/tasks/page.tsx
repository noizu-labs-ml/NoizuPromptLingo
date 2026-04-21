"use client";

import { useState } from "react";
import useSWR from "swr";
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
import { Button } from "@/components/primitives/Button";
import { Input } from "@/components/primitives/Input";
import { Select } from "@/components/primitives/Select";
import { Textarea } from "@/components/primitives/Textarea";
import { FormField } from "@/components/primitives/FormField";
import { SkeletonGrid } from "@/components/primitives/SkeletonGrid";
import { FilterBar } from "@/components/composites/FilterBar";
import { ListRow } from "@/components/composites/ListRow";

const STATUSES: TaskStatus[] = ["pending", "in_progress", "blocked", "review", "done"];

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
    <ListRow
      href={`/tasks/${task.id}`}
      actions={
        <>
          <Badge variant={priorityVariant(task.priority)} size="sm">
            {priorityLabel(task.priority)}
          </Badge>
          {task.assigned_to && (
            <span className="text-xs text-muted font-mono">@{task.assigned_to}</span>
          )}
          <Select
            inputSize="sm"
            value={task.status}
            onClick={(e) => e.stopPropagation()}
            onChange={(e) => onStatusChange(task.id, e.target.value as TaskStatus)}
            className="w-auto"
          >
            {STATUSES.map((s) => (
              <option key={s} value={s}>{s}</option>
            ))}
          </Select>
        </>
      }
    >
      <div className="flex flex-col gap-0.5">
        <div className="flex items-center gap-2 min-w-0">
          <span className="text-sm font-medium text-foreground truncate">
            {task.title}
          </span>
          <span className="font-mono text-[11px] text-subtle shrink-0">#{task.id}</span>
        </div>
        {task.description && (
          <p className="text-xs text-muted truncate">{task.description}</p>
        )}
      </div>
    </ListRow>
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
      <Button
        variant="primary"
        size="sm"
        leadingIcon={<PlusIcon className="h-4 w-4" />}
        onClick={() => setOpen(true)}
      >
        New task
      </Button>
    );
  }

  return (
    <Card className="flex flex-col gap-3">
      <div className="flex items-center justify-between">
        <h3 className="text-sm font-semibold text-foreground">New task</h3>
        <Button
          variant="icon"
          onClick={() => setOpen(false)}
          aria-label="Close"
        >
          <XMarkIcon className="h-4 w-4" />
        </Button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
        <FormField label="Title" className="md:col-span-2">
          <Input
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="Short, imperative title"
          />
        </FormField>
        <FormField label="Description" className="md:col-span-2">
          <Textarea
            rows={2}
            value={description}
            onChange={(e) => setDescription(e.target.value)}
          />
        </FormField>
        <FormField label="Priority">
          <Select
            value={priority}
            onChange={(e) => setPriority(parseInt(e.target.value))}
          >
            <option value={0}>0 — low</option>
            <option value={1}>1 — normal</option>
            <option value={2}>2 — high</option>
            <option value={3}>3 — urgent</option>
          </Select>
        </FormField>
        <FormField label="Assignee">
          <Input
            value={assignedTo}
            onChange={(e) => setAssignedTo(e.target.value)}
            placeholder="optional"
          />
        </FormField>
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
          disabled={!title.trim()}
          onClick={handleSubmit}
        >
          {submitting ? "Creating…" : "Create"}
        </Button>
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
  const hasActive = Boolean(statusFilter) || Boolean(assigneeFilter);

  return (
    <div className="space-y-6">
      <PageHeader
        title="Tasks"
        description="Flat work-item queue. Filter by status/assignee; flip status inline."
        actions={<NewTaskForm onCreated={() => mutate()} />}
      />

      <FilterBar
        filters={
          <>
            <label className="flex items-center gap-2">
              <span className="text-label text-subtle uppercase">Status</span>
              <Select
                inputSize="sm"
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value as TaskStatus | "")}
                className="w-32"
              >
                <option value="">All</option>
                {STATUSES.map((s) => <option key={s} value={s}>{s}</option>)}
              </Select>
            </label>
            <label className="flex items-center gap-2">
              <span className="text-label text-subtle uppercase">Assignee</span>
              <Input
                type="search"
                inputSize="sm"
                value={assigneeFilter}
                onChange={(e) => setAssigneeFilter(e.target.value)}
                placeholder="exact match…"
                className="w-40"
              />
            </label>
          </>
        }
        hasActive={hasActive}
        onClear={() => { setStatusFilter(""); setAssigneeFilter(""); }}
        summary={`${totalCount} task${totalCount === 1 ? "" : "s"}`}
      />

      {error && (
        <div
          role="alert"
          className="rounded-md border border-danger/30 bg-danger/10 px-4 py-3 text-sm text-danger"
        >
          Failed to load tasks: {String(error)}
        </div>
      )}

      {isLoading && <SkeletonGrid as="row" count={4} />}

      {!isLoading && tasks.length === 0 && (
        <EmptyState
          icon={<QueueListIcon />}
          title="No tasks"
          description={
            hasActive
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
