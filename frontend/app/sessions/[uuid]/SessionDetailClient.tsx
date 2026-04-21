"use client";

import { useState } from "react";
import { useParams } from "next/navigation";
import Link from "next/link";
import useSWR from "swr";
import clsx from "clsx";
import {
  TabGroup,
  TabList,
  Tab,
  TabPanels,
  TabPanel,
  Disclosure,
  DisclosureButton,
  DisclosurePanel,
} from "@headlessui/react";
import { ChevronRightIcon } from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import type { Session, SessionTreeNode } from "@/lib/api/types";

import { Badge } from "@/components/primitives/Badge";
import { Card } from "@/components/primitives/Card";
import { EmptyState } from "@/components/primitives/EmptyState";
import { PageHeader } from "@/components/primitives/PageHeader";
import { truncate } from "@/lib/utils/format";

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
                    ? "border-l-2 border-brand-500 bg-surface-raised text-foreground font-medium"
                    : "text-muted hover:text-foreground hover:bg-surface-raised"
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
              ? "border-l-2 border-brand-500 bg-surface-raised text-foreground font-medium"
              : "text-muted hover:text-foreground hover:bg-surface-raised"
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

  if (sessionLoading) {
    return (
      <div className="flex flex-col gap-6">
        <div className="h-16 bg-surface-raised border border-border rounded-lg animate-pulse" />
        <div className="h-64 bg-surface-raised border border-border rounded-lg animate-pulse" />
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

  const TAB_NAMES = ["Overview", "Hierarchy", "Activity"];

  return (
    <div className="flex flex-col gap-6">
      <PageHeader
        title={session.agent}
        description={session.brief}
        actions={<Badge variant="info">{session.project}</Badge>}
      />

      <TabGroup>
        <TabList className="flex gap-1 border-b border-border pb-0">
          {TAB_NAMES.map((name) => (
            <Tab
              key={name}
              className={({ selected }: { selected: boolean }) =>
                clsx(
                  "px-4 py-2 text-sm font-medium rounded-t-md transition-colors focus:outline-none",
                  selected
                    ? "bg-surface-raised text-foreground border border-border border-b-surface-raised -mb-px"
                    : "text-muted hover:text-foreground"
                )
              }
            >
              {name}
            </Tab>
          ))}
        </TabList>

        <TabPanels className="mt-4">
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
                  <Badge variant="info">{session.project}</Badge>
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
                  <label className="text-xs font-medium text-subtle uppercase tracking-wide">
                    Append note
                  </label>
                  <textarea
                    rows={3}
                    value={newNote}
                    onChange={(e) => setNewNote(e.target.value)}
                    placeholder="Cross-agent worklog note…"
                    disabled={noteSubmitting}
                    className="font-mono text-xs rounded-md border border-border bg-surface-sunken px-3 py-2 text-foreground placeholder:text-subtle focus:outline-none focus:ring-2 focus:ring-accent/40 resize-y"
                  />
                  <div className="flex items-center justify-between gap-2">
                    <div className="text-xs">
                      {noteError && <span className="text-danger">{noteError}</span>}
                      {!noteError && lastAction === "appended" && (
                        <span className="text-success">Note appended.</span>
                      )}
                      {!noteError && lastAction === "noop" && (
                        <span className="text-muted">Note already present — no change.</span>
                      )}
                    </div>
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
                  <p className="text-[10px] text-subtle">
                    Substring-deduped: if the exact text already exists in notes, no update is made.
                  </p>
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
            <EmptyState
              title="Activity coming soon"
              description="Activity instrumentation coming soon. Will show tool calls, artifact updates, and sub-agent events for this session."
            />
          </TabPanel>
        </TabPanels>
      </TabGroup>
    </div>
  );
}
