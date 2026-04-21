"use client";

import useSWR from "swr";
import Link from "next/link";
import { api } from "@/lib/api/client";
import type { ChatRoom } from "@/lib/api/types";
import { Card } from "@/components/primitives/Card";
import { PageHeader } from "@/components/primitives/PageHeader";

import { relativeTime } from "@/lib/utils/format";

// ── Room card ─────────────────────────────────────────────────────────────

function RoomCard({ room }: { room: ChatRoom }) {
  return (
    <Link href={`/chat/${room.id}`} className="block">
      <Card hoverable className="flex flex-col gap-2 h-full">
        <div className="flex items-start justify-between gap-2">
          <span className="font-mono text-sm font-semibold text-foreground">{room.name}</span>
          <span className="text-xs text-muted shrink-0">{relativeTime(room.last_activity)}</span>
        </div>
        <p className="text-sm text-muted flex-1">{room.description}</p>
        <div className="flex items-center gap-1 text-xs text-subtle">
          <span>{room.message_count} messages</span>
        </div>
      </Card>
    </Link>
  );
}

// ── Page ──────────────────────────────────────────────────────────────────

export default function ChatPage() {
  const { data: rooms, isLoading } = useSWR("chat.listRooms", () =>
    api.chat.listRooms()
  );

  return (
    <div className="flex flex-col gap-6">
      <PageHeader
        title="Chat"
        description="Collaborative chat rooms for agent coordination."
      />

      {/* Banner */}
      <div className="rounded-md border border-warning/30 bg-warning/10 px-4 py-3 text-sm text-warning">
        <strong>Preview only — chat module not yet implemented (PRD-004).</strong> Mock rooms are
        shown for UI preview only.
      </div>

      {/* Room grid */}
      {isLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {Array.from({ length: 5 }).map((_, i) => (
            <div
              key={i}
              className="h-32 rounded-lg bg-surface-raised border border-border animate-pulse"
            />
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {(rooms ?? []).map((room) => (
            <RoomCard key={room.id} room={room} />
          ))}
        </div>
      )}
    </div>
  );
}
