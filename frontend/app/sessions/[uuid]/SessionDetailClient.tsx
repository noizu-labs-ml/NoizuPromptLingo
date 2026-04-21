"use client";

import { useState } from "react";
import { useParams } from "next/navigation";
import Link from "next/link";
import useSWR from "swr";
import clsx from "clsx";
import {
  Disclosure,
  DisclosureButton,
  DisclosurePanel,
  TabPanel,
} from "@headlessui/react";
import { ChevronRightIcon } from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import type { SessionTreeNode } from "@/lib/api/types";

import { Badge } from "@/components/primitives/Badge";
import { Card } from "@/components/primitives/Card";
import { EmptyState } from "@/components/primitives/EmptyState";
import { Textarea } from "@/components/primitives/Textarea";
import { Button } from "@/components/primitives/Button";
import { FormField } from "@/components/primitives/FormField";
import { DetailHeader } from "@/components/composites/DetailHeader";
import { TabBar } from "@/components/composites/TabBar";
import { truncate, relativeTime } from "@/lib/utils/format";

// ── Activity event type ───────────────────────────────────────────────────

interface ActivityEvent {
  id: string;
  type: "sub_session" | "error" | "note" | "artifact";
  summary: string;
  detail?: string | null;
  created_at: string | null;
}

// ── Metadata row helper ───────────────────────────────────────────────────

function MetaRow({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="flex flex-col gap-0.5 py-2 border-b border-border last:border-0">
      <span className="text-xs font-medium text-subtle uppercase tracking-wider">
        {label}
      </span>
      <div className="text-sm text-foreground">{children}</div>
    </div>
  );
}

// ── Tree node component ───────────────────────────────────────────────────

function TreeNode({
  node,
  currentUuid,
  depth,
}: {
  node: SessionTreeNode;
  currentUuid: string;
  depth: number;
}) {
  const isCurrent = node.uuid === currentUuid;
  const hasChildren = node.children.length > 0;

  return (
    <div className={clsx("flex flex-col", depth > 0 && "ml-4")}>
      {hasChildren ? (
        <Disclosure defaultOpen={depth < 2}>
          {({ open }: { open: boolean }) => (
            <>
              <DisclosureButton
                className={clsx(
                  "flex items-center gap-2 rounded-md px-3 py-2 text-sm text-left transition-colors w-full",
                  isCurrent
                    ? "border-l-2 border-accent bg-surface-1 text-foreground font-medium"
                    : "text-muted hover:text-foreground hover:bg-surface-1"
                )}
              >
                <ChevronRightIcon
                  className={clsx(
                    "h-3.5 w-3.5 text-subtle transition-transform shrink-0",
                    open && "rotate-90"
                  )}
                />
                <span className="font-mono text-xs shrink-0 text-subtle">{node.agent}</span>
                <span className="truncate flex-1">{truncate(node.brief, 50)}</span>
                {isCurrent && (
                  <Badge variant="info" size="sm">current</Badge>
                )}
              </DisclosureButton>
              <DisclosurePanel>
                {node.children.map((child) => (
                  <TreeNode
                    key={child.uuid}
                    node={child}
                    currentUuid={currentUuid}
                    depth={depth + 1}
                  />
                ))}
              </DisclosurePanel>
            </>
          )}
        </Disclosure>
      ) : (
        <div
          className={clsx(
            "flex items-center gap-2 rounded-md px-3 py-2 text-sm transition-colors",
            isCurrent
              ? "border-l-2 border-accent bg-surface-1 text-foreground font-medium"
              : "text-muted hover:text-foreground hover:bg-surface-1"
          )}
        >
          <span className="h-3.5 w-3.5 shrink-0" />
          <span className="font-mono text-xs shrink-0 text-subtle">{node.agent}</span>
          <span className="truncate flex-1">{truncate(node.brief, 50)}</span>
          {isCurrent && (
            <Badge variant="info" size="sm">current</Badge>
          )}
        </div>
      )}
    </div>
  );
}

// ── Main client component ─────────────────────────────────────────────────

export default function SessionDetailClient() {
  const params = useParams();
  const uuid = typeof params?.uuid === "string" ? params.uuid : Array.isArray(params?.uuid) ? params.uuid[0] : "";

  const { data: session, isLoading: sessionLoading, mutate: mutateSession } = useSWR(
    uuid ? `sessions.get.${uuid}` : null,
    () => api.sessions.get(uuid)
  );

  const [newNote, setNewNote] = useState("");
  const [noteSubmitting, setNoteSubmitting] = useState(false);
  const [noteError, setNoteError] = useState<string | null>(null);
  const [lastAction, setLastAction] = useState<"appended" | "noop" | null>(null);

  async function handleAppendNote() {
    const trimmed = newNote.trim();
    if (!trimmed) return;
    setNoteSubmitting(true);
    setNoteError(null);
    setLastAction(null);
    try {
      const beforeNotes = session?.notes ?? "";
      const updated = await api.sessions.appendNote(uuid, trimmed);
      setLastAction(updated.notes === beforeNotes ? "noop" : "appended");
      setNewNote("");
      await mutateSession(updated, { revalidate: false });
    } catch (err) {
      setNoteError(err instanceof Error ? err.message : "Failed to append note.");
    } finally {
      setNoteSubmitting(false);
    }
  }

  // Determine root uuid: walk up via parent chain
  // Since mock data is synchronous we rely on the session's parent field
  // to find root — if no parent, the session is root itself.
  const rootUuid = session
    ? session.parent === null || session.parent === undefined
      ? session.uuid
      : session.parent
    : null;

  const { data: tree } = useSWR(
    rootUuid ? `sessions.tree.${rootUuid}` : null,
    () => api.sessions.tree(rootUuid!)
  );

  const { data: activity } = useSWR(
    uuid ? `sessions.${uuid}.activity` : null,
    () => fetch(`/api/sessions/${encodeURIComponent(uuid)}/activity?limit=50`)
      .then(r => r.ok ? r.json() : { items: [], count: 0 })
      .then((d: { items: ActivityEvent[] }) => d.items),
  );

  if (sessionLoading) {
    return (
      <div className="flex flex-col gap-6">
        <div className="h-16 bg-surface-1 border border-border rounded-lg animate-pulse" />
        <div className="h-64 bg-surface-1 border border-border rounded-lg animate-pulse" />
      </div>
    );
  }

  if (!session) {
    return (
      <EmptyState
        title="Session not found"
        description={`No session found with UUID: ${uuid}`}
        action={
          <Link href="/sessions" className="text-sm text-accent hover:underline">
            Back to Sessions
          </Link>
        }
      />
    );
  }

  return (
    <div className="flex flex-col gap-6">
      <DetailHeader
        breadcrumbs={[
          { label: "Sessions", href: "/sessions" },
          { label: session.agent },
        ]}
        backHref="/sessions"
        backLabel="Back to sessions"
        title={session.agent}
        description={session.brief}
        actions={<Badge variant="accent">{session.project}</Badge>}
      />

      <TabBar
        tabs={[
          { id: "overview", label: "Overview" },
          { id: "hierarchy", label: "Hierarchy" },
          { id: "activity", label: "Activity" },
        ]}
        defaultIndex={0}
      >
        {/* ── Overview Tab ─────────────────────────────────────────── */}
        <TabPanel>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Metadata card */}
            <Card>
              <h3 className="text-sm font-semibold text-foreground mb-3">Metadata</h3>
              <MetaRow label="UUID">
                <span className="font-mono text-xs break-all">{session.uuid}</span>
              </MetaRow>
              <MetaRow label="Agent">
                <span className="font-mono">{session.agent}</span>
              </MetaRow>
              <MetaRow label="Task">
                <span className="text-muted">{session.task}</span>
              </MetaRow>
              <MetaRow label="Project">
                <Badge variant="accent">{session.project}</Badge>
              </MetaRow>
              <MetaRow label="Created">
                <span className="text-muted">{new Date(session.created_at).toLocaleString()}</span>
              </MetaRow>
              <MetaRow label="Updated">
                <span className="text-muted">{new Date(session.updated_at).toLocaleString()}</span>
              </MetaRow>
              {session.parent && (
                <MetaRow label="Parent">
                  <Link
                    href={`/sessions/${session.parent}`}
                    className="font-mono text-xs text-accent hover:underline"
                  >
                    {session.parent}
                  </Link>
                </MetaRow>
              )}
            </Card>

            {/* Notes card */}
            <Card>
              <h3 className="text-sm font-semibold text-foreground mb-3">Notes</h3>
              {session.notes ? (
                <p className="text-sm text-foreground whitespace-pre-wrap">{session.notes}</p>
              ) : (
                <p className="text-sm text-muted">No notes.</p>
              )}

              <div className="mt-4 pt-3 border-t border-border flex flex-col gap-2">
                <FormField
                  label="Append note"
                  htmlFor="session-append-note"
                  helper="Substring-deduped: if the exact text already exists in notes, no update is made."
                >
                  <Textarea
                    id="session-append-note"
                    rows={3}
                    value={newNote}
                    onChange={(e) => setNewNote(e.target.value)}
                    placeholder="Cross-agent worklog note…"
                    disabled={noteSubmitting}
                    mono
                  />
                </FormField>
                <div className="flex items-center justify-between gap-2">
                  <div
                    className="text-xs"
                    role={noteError ? "alert" : "status"}
                    aria-live="polite"
                  >
                    {noteError && <span className="text-danger">{noteError}</span>}
                    {!noteError && lastAction === "appended" && (
                      <span className="text-success">Note appended.</span>
                    )}
                    {!noteError && lastAction === "noop" && (
                      <span className="text-muted">Note already present — no change.</span>
                    )}
                  </div>
                  <Button
                    size="sm"
                    onClick={handleAppendNote}
                    disabled={noteSubmitting || !newNote.trim()}
                    loading={noteSubmitting}
                  >
                    {noteSubmitting ? "Appending…" : "Append"}
                  </Button>
                </div>
              </div>
            </Card>
          </div>
        </TabPanel>

        {/* ── Hierarchy Tab ─────────────────────────────────────────── */}
        <TabPanel>
          <Card>
            <h3 className="text-sm font-semibold text-foreground mb-3">Session Tree</h3>
            {tree ? (
              <div className="flex flex-col gap-0.5">
                <TreeNode node={tree} currentUuid={session.uuid} depth={0} />
              </div>
            ) : (
              <p className="text-sm text-muted">Loading tree…</p>
            )}
          </Card>
        </TabPanel>

        {/* ── Activity Tab ─────────────────────────────────────────── */}
        <TabPanel>
          {!activity || activity.length === 0 ? (
            <EmptyState
              title="No activity yet"
              description="Sub-agent spawns, errors, and tool calls will appear here."
            />
          ) : (
            <div className="space-y-2">
              {activity.map((event) => (
                <div key={event.id} className="flex items-start gap-3 rounded-md border border-border p-3 text-sm">
                  <span className={clsx(
                    "mt-0.5 h-2 w-2 shrink-0 rounded-full",
                    event.type === "error" ? "bg-danger" : event.type === "sub_session" ? "bg-accent" : "bg-success"
                  )} />
                  <div className="flex-1 min-w-0">
                    <p className="text-foreground truncate">{event.summary}</p>
                    {event.created_at && (
                      <p className="text-xs text-muted mt-0.5">{relativeTime(event.created_at)}</p>
                    )}
                  </div>
                  {event.type === "sub_session" && event.detail && (
                    <Link href={`/sessions/${event.detail}`} className="text-xs text-accent hover:underline shrink-0">
                      View
                    </Link>
                  )}
                </div>
              ))}
            </div>
          )}
        </TabPanel>
      </TabBar>
    </div>
  );
}
