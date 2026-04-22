"use client";

import { useState } from "react";
import useSWR from "swr";
import Link from "next/link";
import { api } from "@/lib/api/client";
import type { ChatRoom } from "@/lib/api/types";
import { Card } from "@/components/primitives/Card";
import { PageHeader } from "@/components/primitives/PageHeader";
import { Button } from "@/components/primitives/Button";
import { Input } from "@/components/primitives/Input";
import { useToast } from "@/components/primitives/ToastContainer";
import { relativeTime } from "@/lib/utils/format";
import { cyAttrs } from "@/lib/utils/cyAttrs";

// ── Room card ─────────────────────────────────────────────────────────────

function RoomCard({ room }: { room: ChatRoom }) {
  return (
    <Link
      href={`/chat/${room.id}`}
      className="block rounded-lg focus-ring"
      {...cyAttrs({ cy: "room-card", cyId: room.id })}
    >
      <Card hoverable className="flex flex-col gap-2 h-full">
        <div className="flex items-start justify-between gap-2">
          <span
            className="font-mono text-sm font-semibold text-foreground"
            {...cyAttrs({ cy: "room-name" })}
          >
            {room.name}
          </span>
          <span
            className="text-xs text-muted shrink-0"
            {...cyAttrs({ cy: "room-activity" })}
          >
            {room.last_activity ? relativeTime(room.last_activity) : "—"}
          </span>
        </div>
        <p
          className="text-sm text-muted flex-1"
          {...cyAttrs({ cy: "room-description" })}
        >
          {room.description}
        </p>
        <div className="flex items-center gap-1 text-xs text-subtle">
          <span {...cyAttrs({ cy: "message-count", cyValue: room.message_count })}>
            {room.message_count} messages
          </span>
        </div>
      </Card>
    </Link>
  );
}

// ── New room form ─────────────────────────────────────────────────────────

function NewRoomForm({ onCreated }: { onCreated: () => void }) {
  const [open, setOpen] = useState(false);
  const [name, setName] = useState("");
  const [loading, setLoading] = useState(false);
  const { toast } = useToast();

  if (!open) {
    return (
      <Button
        variant="primary"
        size="sm"
        onClick={() => setOpen(true)}
        {...cyAttrs({ cy: "new-room-btn" })}
      >
        New Room
      </Button>
    );
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) return;
    setLoading(true);
    try {
      await api.chat.createRoom({ name: name.trim() });
      toast("Room created", "success");
      setName("");
      setOpen(false);
      onCreated();
    } catch {
      toast("Failed to create room", "error");
    } finally {
      setLoading(false);
    }
  };

  return (
    <form
      onSubmit={handleSubmit}
      className="flex items-center gap-2"
      {...cyAttrs({ cy: "new-room-form" })}
    >
      <Input
        placeholder="Room name..."
        value={name}
        onChange={(e) => setName(e.target.value)}
        disabled={loading}
        {...cyAttrs({ cy: "room-name-input" })}
      />
      <Button
        type="submit"
        variant="primary"
        size="sm"
        loading={loading}
        disabled={!name.trim()}
        {...cyAttrs({ cy: "create-room-btn" })}
      >
        Create
      </Button>
      <Button
        type="button"
        variant="ghost"
        size="sm"
        onClick={() => setOpen(false)}
        {...cyAttrs({ cy: "cancel-room-btn" })}
      >
        Cancel
      </Button>
    </form>
  );
}

// ── Page ──────────────────────────────────────────────────────────────────

export default function ChatPage() {
  const { data: rooms, isLoading, mutate } = useSWR("chat.listRooms", () =>
    api.chat.listRooms()
  );

  return (
    <div
      className="flex flex-col gap-6"
      {...cyAttrs({ cy: "chat-page", cyScope: "chat" })}
    >
      <div className="flex items-start justify-between gap-4">
        <PageHeader
          title="Chat"
          description="Collaborative chat rooms for agent coordination."
        />
        <div className="shrink-0 pt-1">
          <NewRoomForm onCreated={() => mutate()} />
        </div>
      </div>

      {/* Room grid */}
      {isLoading ? (
        <div
          className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4"
          {...cyAttrs({ cy: "rooms-loading" })}
        >
          {Array.from({ length: 5 }).map((_, i) => (
            <div
              key={i}
              className="h-32 rounded-lg bg-surface-1 border border-border animate-pulse"
            />
          ))}
        </div>
      ) : (
        <div
          className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4"
          {...cyAttrs({ cy: "rooms-grid", cyValue: (rooms ?? []).length })}
        >
          {(rooms ?? []).map((room) => (
            <RoomCard key={room.id} room={room} />
          ))}
        </div>
      )}
    </div>
  );
}
