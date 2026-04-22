"use client";

import { useState, useEffect, useRef } from "react";
import Link from "next/link";
import { useParams } from "next/navigation";
import useSWR from "swr";
import { api } from "@/lib/api/client";
import { Card } from "@/components/primitives/Card";
import { Button } from "@/components/primitives/Button";
import { EmptyState } from "@/components/primitives/EmptyState";
import { PageHeader } from "@/components/primitives/PageHeader";
import { useToast } from "@/components/primitives/ToastContainer";
import { relativeTime } from "@/lib/utils/format";
import { cyAttrs } from "@/lib/utils/cyAttrs";

// ── Author color helper ───────────────────────────────────────────────────

const AUTHOR_COLORS = [
  "text-blue-400",
  "text-emerald-400",
  "text-violet-400",
  "text-amber-400",
  "text-rose-400",
  "text-cyan-400",
  "text-fuchsia-400",
  "text-lime-400",
];

function authorColor(author: string): string {
  let hash = 0;
  for (let i = 0; i < author.length; i++) {
    hash = (hash * 31 + author.charCodeAt(i)) & 0xffff;
  }
  return AUTHOR_COLORS[hash % AUTHOR_COLORS.length];
}

// ── Component ─────────────────────────────────────────────────────────────

export default function ChatRoomClient() {
  const params = useParams<{ id: string }>();
  const id = params?.id ?? "";
  const { toast } = useToast();

  const { data: room, isLoading: roomLoading } = useSWR(
    id ? `chat.room.${id}` : null,
    () => api.chat.getRoom(id)
  );

  const { data: messages, mutate: mutateMessages } = useSWR(
    id ? `chat.messages.${id}` : null,
    () => api.chat.listMessages(Number(id)),
    { refreshInterval: 3000 }
  );

  const [draft, setDraft] = useState("");
  const [sending, setSending] = useState(false);
  const feedRef = useRef<HTMLDivElement>(null);

  // Scroll to bottom when messages update
  useEffect(() => {
    if (feedRef.current) {
      feedRef.current.scrollTop = feedRef.current.scrollHeight;
    }
  }, [messages]);

  const sendMessage = async () => {
    if (!draft.trim() || sending) return;
    setSending(true);
    try {
      await api.chat.sendMessage(Number(id), { content: draft.trim() });
      setDraft("");
      mutateMessages();
    } catch {
      toast("Failed to send message", "error");
    } finally {
      setSending(false);
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  };

  return (
    <div
      className="flex flex-col gap-6 max-w-3xl"
      {...cyAttrs({ cy: "chat-room-page", cyScope: "chat-room", cyId: id })}
    >
      {roomLoading ? (
        <div
          className="h-24 rounded-lg bg-surface-1 border border-border animate-pulse"
          {...cyAttrs({ cy: "room-loading" })}
        />
      ) : room ? (
        <PageHeader title={room.name} description={room.description} />
      ) : (
        <EmptyState
          title="Room not found"
          description="This chat room doesn't exist or has been archived."
          action={
            <Link
              href="/chat"
              className="inline-flex items-center gap-1 rounded-md bg-accent px-4 py-2 text-sm text-accent-on hover:bg-accent-soft"
              {...cyAttrs({ cy: "back-to-rooms-link" })}
            >
              Back to chat rooms
            </Link>
          }
        />
      )}

      {/* Message feed */}
      <Card className="flex flex-col gap-0 p-0 overflow-hidden">
        <div className="px-4 py-3 border-b border-border bg-surface-1">
          <h2
            className="text-sm font-semibold text-foreground"
            {...cyAttrs({ cy: "messages-heading" })}
          >
            Messages
          </h2>
        </div>
        <div
          ref={feedRef}
          className="flex flex-col divide-y divide-border max-h-[480px] overflow-y-auto"
          {...cyAttrs({ cy: "message-feed", cyValue: messages?.length ?? 0 })}
        >
          {!messages || messages.length === 0 ? (
            <div
              className="px-4 py-8 text-center text-sm text-subtle"
              {...cyAttrs({ cy: "empty-messages" })}
            >
              No messages yet. Start the conversation.
            </div>
          ) : (
            messages.map((msg) => (
              <div
                key={msg.id}
                className="px-4 py-4 flex flex-col gap-1"
                {...cyAttrs({ cy: "message-item", cyId: msg.id })}
              >
                <div className="flex items-center gap-2">
                  <span
                    className={`font-mono text-xs font-semibold ${authorColor(msg.author)}`}
                    {...cyAttrs({ cy: "message-author", cyValue: msg.author })}
                  >
                    {msg.author}
                  </span>
                  <span
                    className="text-xs text-subtle"
                    {...cyAttrs({ cy: "message-time" })}
                  >
                    {msg.created_at ? relativeTime(msg.created_at) : "—"}
                  </span>
                </div>
                <p
                  className="text-sm text-muted"
                  {...cyAttrs({ cy: "message-content" })}
                >
                  {msg.content}
                </p>
              </div>
            ))
          )}
        </div>
      </Card>

      {/* Message input */}
      <Card className="flex flex-col gap-3" {...cyAttrs({ cy: "message-composer" })}>
        <textarea
          value={draft}
          onChange={(e) => setDraft(e.target.value)}
          onKeyDown={handleKeyDown}
          placeholder="Type a message… (Enter to send, Shift+Enter for newline)"
          disabled={sending}
          className="w-full rounded-md border border-border bg-surface-1 px-3 py-2 text-sm text-foreground placeholder:text-subtle resize-none h-20 focus:outline-none focus:ring-2 focus:ring-accent"
          {...cyAttrs({ cy: "message-input" })}
        />
        <div className="flex justify-end">
          <Button
            type="button"
            variant="primary"
            size="sm"
            loading={sending}
            disabled={!draft.trim()}
            onClick={sendMessage}
            {...cyAttrs({ cy: "send-btn" })}
          >
            Send
          </Button>
        </div>
      </Card>
    </div>
  );
}
