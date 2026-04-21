"use client";

import Link from "next/link";
import { useParams } from "next/navigation";
import useSWR from "swr";
import { api } from "@/lib/api/client";
import { Card } from "@/components/primitives/Card";
import { EmptyState } from "@/components/primitives/EmptyState";
import { PageHeader } from "@/components/primitives/PageHeader";
import { relativeTime } from "@/lib/utils/format";

// ── Static mock messages ──────────────────────────────────────────────────

const MOCK_MESSAGES = [
  {
    id: "msg-1",
    author: "npl-tdd-coder",
    timestamp: "2026-04-21T09:14:00Z",
    body: "Pushed initial test suite for the NPLLoad refactor. Coverage is at 87%.",
  },
  {
    id: "msg-2",
    author: "npl-prd-editor",
    timestamp: "2026-04-21T09:22:00Z",
    body: "PRD-007 updated with revised acceptance criteria for the web interface section.",
  },
  {
    id: "msg-3",
    author: "npl-tdd-debugger",
    timestamp: "2026-04-21T10:05:00Z",
    body: "Root cause found: the FastMCP 3.x upgrade changed the tool dispatch signature. Fix incoming.",
  },
  {
    id: "msg-4",
    author: "npl-winnower",
    timestamp: "2026-04-21T10:47:00Z",
    body: "Response quality scores for the last 20 tool invocations are within acceptable bounds.",
  },
  {
    id: "msg-5",
    author: "npl-tasker-sonnet",
    timestamp: "2026-04-21T11:30:00Z",
    body: "Assigned to npl-core task queue. Estimated completion: 2 pipeline cycles.",
  },
];

// ── Component ─────────────────────────────────────────────────────────────

export default function ChatRoomClient() {
  const params = useParams<{ id: string }>();
  const { data: room, isLoading } = useSWR(
    params?.id ? `chat.room.${params.id}` : null,
    () => api.chat.getRoom(params!.id)
  );

  return (
    <div className="flex flex-col gap-6 max-w-3xl">
      {/* Banner */}
      <div className="rounded-md border border-warning/30 bg-warning/10 px-4 py-3 text-sm text-warning">
        <strong>Preview only — chat module not yet implemented (PRD-004).</strong> Mock rooms are
        shown for UI preview only.
      </div>

      {isLoading ? (
        <div className="h-24 rounded-lg bg-surface-raised border border-border animate-pulse" />
      ) : room ? (
        <PageHeader title={room.name} description={room.description} />
      ) : (
        <EmptyState
          title="Room not found"
          description="This chat room doesn't exist or has been archived."
          action={
            <Link
              href="/chat"
              className="inline-flex items-center gap-1 rounded-md bg-brand-500 px-4 py-2 text-sm text-white hover:bg-brand-600"
            >
              Back to chat rooms
            </Link>
          }
        />
      )}

      {/* Message feed */}
      <Card className="flex flex-col gap-0 p-0 overflow-hidden">
        <div className="px-4 py-3 border-b border-border bg-surface">
          <h2 className="text-sm font-semibold text-foreground">Messages (mock)</h2>
        </div>
        <div className="flex flex-col divide-y divide-border">
          {MOCK_MESSAGES.map((msg) => (
            <div key={msg.id} className="px-4 py-4 flex flex-col gap-1">
              <div className="flex items-center gap-2">
                <span className="font-mono text-xs font-semibold text-foreground">
                  {msg.author}
                </span>
                <span className="text-xs text-subtle">{relativeTime(msg.timestamp)}</span>
              </div>
              <p className="text-sm text-muted">{msg.body}</p>
            </div>
          ))}
        </div>
      </Card>

      {/* Disabled input */}
      <Card className="flex flex-col gap-3">
        <textarea
          disabled
          placeholder="Chat unavailable in preview"
          className="w-full rounded-md border border-border bg-surface px-3 py-2 text-sm text-muted placeholder:text-subtle resize-none h-20 cursor-not-allowed opacity-60"
        />
        <div className="flex justify-end">
          <button
            type="button"
            disabled
            className="px-4 py-2 rounded-md bg-brand-500 text-white text-sm font-medium opacity-40 cursor-not-allowed"
          >
            Send
          </button>
        </div>
      </Card>
    </div>
  );
}
