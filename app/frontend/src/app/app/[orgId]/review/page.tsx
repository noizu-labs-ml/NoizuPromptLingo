"use client";

import { use, useEffect, useState, useCallback } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import { api, type ReviewItem, type ReviewStatus } from "@/lib/api";
import { cyAttrs } from "@/utils/cypress";
import {
  PageHeader,
  Button,
  EmptyState,
  LoadingSkeleton,
  StatusPill,
  type StatusState,
  DataTable,
  type DataTableColumn,
  TextInput,
} from "@/components/ui";

const STATUS_OPTS: ReviewStatus[] = ["pending", "claimed", "resolved"];

function reviewStatusToState(s: ReviewStatus): StatusState {
  switch (s) {
    case "pending":
      return "pending";
    case "claimed":
      return "running";
    case "resolved":
      return "pass";
  }
}

export default function ReviewPage({
  params,
}: {
  params: Promise<{ orgId: string }>;
}) {
  const { orgId } = use(params);
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();

  const [items, setItems] = useState<ReviewItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filterStatus, setFilterStatus] = useState<ReviewStatus | "">("");
  const [filterAssignee, setFilterAssignee] = useState("");
  const [selected, setSelected] = useState<Set<string>>(new Set());
  const [actionPending, setActionPending] = useState<string | null>(null);

  const load = useCallback(() => {
    setLoading(true);
    api
      .listReviewQueue(orgId, {
        ...(filterStatus ? { status: filterStatus } : {}),
        ...(filterAssignee ? { assignee: filterAssignee } : {}),
      })
      .then((res) => setItems(res.items ?? []))
      .catch((e) => {
        const msg = e instanceof Error ? e.message : "failed to load";
        if (msg.includes("404")) {
          setItems([]);
        } else {
          setError(msg);
        }
      })
      .finally(() => setLoading(false));
  }, [orgId, filterStatus, filterAssignee]);

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login");
      return;
    }
    if (!user) return;
    load();
  }, [user, authLoading, router, load]);

  async function doAction(
    itemId: string,
    action: "claim" | "approve" | "reject" | "dismiss",
  ) {
    setActionPending(itemId + action);
    try {
      const res = await api.reviewAction(orgId, itemId, action);
      setItems((prev) => prev.map((it) => (it.id === itemId ? res.item : it)));
    } catch (e) {
      setError(e instanceof Error ? e.message : "action failed");
    } finally {
      setActionPending(null);
    }
  }

  async function doBulk(action: "claim" | "approve") {
    const ids = Array.from(selected);
    if (!ids.length) return;
    setActionPending("bulk-" + action);
    try {
      await api.reviewBulk(orgId, ids, action);
      setSelected(new Set());
      load();
    } catch (e) {
      setError(e instanceof Error ? e.message : "bulk action failed");
    } finally {
      setActionPending(null);
    }
  }

  function toggleSelect(id: string) {
    setSelected((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  }

  function toggleAll() {
    if (selected.size === items.length) {
      setSelected(new Set());
    } else {
      setSelected(new Set(items.map((it) => it.id)));
    }
  }

  if (authLoading) {
    return (
      <div data-cy="app-loading" className="sg-app-loading">
        Loading…
      </div>
    );
  }

  const columns: DataTableColumn<ReviewItem>[] = [
    {
      key: "select",
      label: (
        <input
          type="checkbox"
          data-cy="review-select-all"
          checked={items.length > 0 && selected.size === items.length}
          onChange={toggleAll}
          aria-label="Select all rows"
        />
      ),
      width: 32,
      render: (item) => (
        <input
          type="checkbox"
          data-cy="review-row-select"
          checked={selected.has(item.id)}
          onChange={() => toggleSelect(item.id)}
          onClick={(e) => e.stopPropagation()}
          aria-label={`Select row ${item.id}`}
        />
      ),
    },
    {
      key: "run_id",
      label: "Run ID",
      render: (item) => (
        <span
          data-cy="review-run-id"
          className="sg-mono"
          style={{ fontSize: "0.85rem" }}
        >
          {item.run_id.slice(0, 8)}
        </span>
      ),
    },
    {
      key: "status",
      label: "Status",
      render: (item) => (
        <StatusPill
          state={reviewStatusToState(item.status)}
          size="sm"
          label={item.status}
          cy="review-status-pill"
        />
      ),
    },
    {
      key: "assignee",
      label: "Assignee",
      render: (item) => (
        <span
          data-cy="review-assignee"
          style={{ fontSize: "0.85rem", color: "var(--text-secondary)" }}
        >
          {item.assignee_email ?? "—"}
        </span>
      ),
    },
    {
      key: "created",
      label: "Created",
      render: (item) => (
        <span style={{ fontSize: "0.8rem", color: "var(--text-tertiary)" }}>
          {new Date(item.inserted_at).toLocaleDateString()}
        </span>
      ),
    },
    {
      key: "actions",
      label: "Actions",
      render: (item) => (
        <div
          style={{ display: "flex", gap: "0.35rem", justifyContent: "flex-end" }}
          onClick={(e) => e.stopPropagation()}
        >
          {item.status === "pending" && (
            <Button
              variant="ghost"
              size="sm"
              cy="review-action-claim"
              disabled={!!actionPending}
              onClick={() => doAction(item.id, "claim")}
            >
              Claim
            </Button>
          )}
          <Button
            variant="ghost"
            size="sm"
            cy="review-action-approve"
            disabled={!!actionPending}
            onClick={() => doAction(item.id, "approve")}
          >
            Approve
          </Button>
          <Button
            variant="ghost"
            size="sm"
            cy="review-action-reject"
            disabled={!!actionPending}
            onClick={() => doAction(item.id, "reject")}
          >
            Reject
          </Button>
          <Button
            variant="ghost"
            size="sm"
            cy="review-action-dismiss"
            disabled={!!actionPending}
            onClick={() => doAction(item.id, "dismiss")}
          >
            Dismiss
          </Button>
        </div>
      ),
    },
  ];

  return (
    <div data-cy="review-page" {...cyAttrs({ cyScope: "review" })}>
      <PageHeader
        title="Review Queue"
        subtitle="Triage run results: claim, approve, reject, or dismiss."
      />

      {/* Filters */}
      <div
        data-cy="review-filters"
        style={{
          display: "flex",
          gap: "0.5rem",
          flexWrap: "wrap",
          marginBottom: "1rem",
          alignItems: "center",
        }}
      >
        <Button
          variant={filterStatus === "" ? "primary" : "ghost"}
          size="sm"
          cy="review-filter-all"
          onClick={() => setFilterStatus("")}
        >
          All
        </Button>
        {STATUS_OPTS.map((s) => (
          <Button
            key={s}
            variant={filterStatus === s ? "primary" : "ghost"}
            size="sm"
            cy="review-filter-status"
            cyValue={s}
            onClick={() => setFilterStatus(s)}
          >
            {s}
          </Button>
        ))}
        <TextInput
          cy="review-filter-assignee"
          placeholder="Filter assignee…"
          value={filterAssignee}
          onChange={(e) => setFilterAssignee(e.target.value)}
          style={{ marginLeft: "auto", width: 220 }}
        />
      </div>

      {/* Bulk toolbar */}
      {selected.size > 0 && (
        <div
          data-cy="review-bulk-toolbar"
          style={{
            display: "flex",
            gap: "0.5rem",
            alignItems: "center",
            padding: "0.6rem 1rem",
            background: "var(--bg-surface)",
            border: "1px solid var(--border-default)",
            borderRadius: "0.5rem",
            marginBottom: "0.75rem",
          }}
        >
          <span
            data-cy="review-bulk-count"
            style={{ fontSize: "0.875rem", color: "var(--text-secondary)" }}
          >
            {selected.size} selected
          </span>
          <Button
            variant="ghost"
            size="sm"
            cy="review-bulk-claim"
            loading={actionPending === "bulk-claim"}
            onClick={() => doBulk("claim")}
          >
            Claim all
          </Button>
          <Button
            variant="ghost"
            size="sm"
            cy="review-bulk-approve"
            loading={actionPending === "bulk-approve"}
            onClick={() => doBulk("approve")}
          >
            Approve all
          </Button>
        </div>
      )}

      {error && (
        <p className="sg-error" data-cy="review-error">
          {error}
        </p>
      )}

      {loading ? (
        <LoadingSkeleton variant="row" count={6} />
      ) : items.length === 0 ? (
        <EmptyState
          glyph="search"
          headline="No items in queue"
          body="Adjust filters or wait for new review items to arrive."
        />
      ) : (
        <DataTable<ReviewItem>
          cy="review-table"
          columns={columns}
          rows={items}
          rowKey={(r) => r.id}
        />
      )}
    </div>
  );
}
