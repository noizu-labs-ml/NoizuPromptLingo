'use client';

import { useState, useEffect, useCallback, useMemo, useRef } from 'react';
import { useParams } from 'next/navigation';
import Link from 'next/link';
import { toast } from 'sonner';
import { api, type ChatRoom, type ChatMessage, type ChatReactionSummary } from '@/lib/api';
import { useOrgId } from '@/context/org';

// Quick-pick reactions for the message reaction UI (ticket 764f7346).
const REACTION_EMOJIS = ['👍', '❤️', '😄', '🎉', '👀', '🚀'] as const;

function timeAgo(dt?: string) {
  if (!dt) return '';
  const diff = Date.now() - new Date(dt).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return 'just now';
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  return `${Math.floor(hrs / 24)}d ago`;
}

// Apply an optimistic reaction toggle to a message's embedded summaries. BE sends
// reactions: [{emoji, count, me}] per message (marcus seq144); we mirror that shape
// locally for an instant update and reconcile from the server `me`/count on refetch.
function applyOptimisticReaction(
  reactions: ChatReactionSummary[] | undefined,
  emoji: string,
  add: boolean,
): ChatReactionSummary[] {
  const list = (reactions ?? []).map((r) => ({ ...r }));
  const existing = list.find((r) => r.emoji === emoji);
  if (add) {
    if (existing) {
      if (!existing.me) {
        existing.me = true;
        existing.count += 1;
      }
    } else {
      list.push({ emoji, count: 1, me: true });
    }
  } else if (existing) {
    existing.me = false;
    existing.count = Math.max(0, existing.count - 1);
  }
  return list.filter((r) => r.count > 0).sort((a, b) => b.count - a.count);
}

function Composer({
  disabled,
  sending,
  onSend,
}: {
  disabled: boolean;
  sending: boolean;
  onSend: (content: string) => Promise<void>;
}) {
  const [content, setContent] = useState('');
  const [error, setError] = useState(false);
  const taRef = useRef<HTMLTextAreaElement>(null);

  async function submit() {
    const trimmed = content.trim();
    if (!trimmed || sending) return;
    try {
      await onSend(trimmed);
      setContent('');
      setError(false);
      taRef.current?.focus();
    } catch {
      // Parent surfaces the toast; reflect the failure on the field for a11y.
      setError(true);
    }
  }

  function handleKeyDown(e: React.KeyboardEvent<HTMLTextAreaElement>) {
    // Enter sends; Shift+Enter inserts a newline.
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      void submit();
    }
  }

  return (
    <form
      className="chat-composer"
      onSubmit={(e) => {
        e.preventDefault();
        void submit();
      }}
    >
      <label className="sr-only" htmlFor="chat-composer-input">
        Message
      </label>
      <textarea
        id="chat-composer-input"
        ref={taRef}
        className="chat-composer__input"
        value={content}
        aria-invalid={error || undefined}
        onChange={(e) => {
          setContent(e.target.value);
          if (error) setError(false);
        }}
        onKeyDown={handleKeyDown}
        placeholder={disabled ? 'Messaging unavailable…' : 'Write a message… (Enter to send, Shift+Enter for newline)'}
        rows={2}
        disabled={disabled || sending}
      />
      <button
        type="submit"
        className="sg-btn sg-btn--black"
        disabled={disabled || sending || !content.trim()}
      >
        {sending ? 'Sending…' : 'Send'}
      </button>
    </form>
  );
}

// Accessible, click-toggled reaction popover (ticket 764f7346; lead's a11y split).
// Replaces the CSS hover/focus-within menu — a dead end on touch and for keyboard
// users — with a real popover that fulfils the role="menu" contract: arrow-key
// roving focus, Home/End, Escape-to-close-and-restore-focus, and outside-click
// dismiss. Visual states/tokens follow lena-graphic's spec; mechanics are this lane.
function ReactionPicker({
  mine,
  isPending,
  onToggle,
}: {
  mine: Set<string>;
  isPending: (emoji: string) => boolean;
  onToggle: (emoji: string) => void;
}) {
  const [open, setOpen] = useState(false);
  const [activeIndex, setActiveIndex] = useState(0);
  const triggerRef = useRef<HTMLButtonElement>(null);
  const menuRef = useRef<HTMLDivElement>(null);
  const optionRefs = useRef<(HTMLButtonElement | null)[]>([]);

  // Dismiss on an outside pointer-down; leave focus wherever the user clicked.
  useEffect(() => {
    if (!open) return;
    function onPointerDown(e: PointerEvent) {
      const t = e.target as Node;
      if (!menuRef.current?.contains(t) && !triggerRef.current?.contains(t)) {
        setOpen(false);
      }
    }
    document.addEventListener('pointerdown', onPointerDown);
    return () => document.removeEventListener('pointerdown', onPointerDown);
  }, [open]);

  // Roving focus: focus the active option whenever it (or the open state) changes.
  useEffect(() => {
    if (open) optionRefs.current[activeIndex]?.focus();
  }, [open, activeIndex]);

  function openMenu() {
    setActiveIndex(0);
    setOpen(true);
  }
  function closeMenu(restoreFocus: boolean) {
    setOpen(false);
    if (restoreFocus) triggerRef.current?.focus();
  }

  function onMenuKeyDown(e: React.KeyboardEvent<HTMLDivElement>) {
    const n = REACTION_EMOJIS.length;
    switch (e.key) {
      case 'ArrowRight':
      case 'ArrowDown':
        e.preventDefault();
        setActiveIndex((i) => (i + 1) % n);
        break;
      case 'ArrowLeft':
      case 'ArrowUp':
        e.preventDefault();
        setActiveIndex((i) => (i - 1 + n) % n);
        break;
      case 'Home':
        e.preventDefault();
        setActiveIndex(0);
        break;
      case 'End':
        e.preventDefault();
        setActiveIndex(n - 1);
        break;
      case 'Escape':
        e.preventDefault();
        closeMenu(true);
        break;
      case 'Tab':
        // Collapse behind the user as focus moves on naturally (no restore).
        setOpen(false);
        break;
      default:
        break;
    }
  }

  return (
    <div className="reaction-picker">
      <button
        ref={triggerRef}
        type="button"
        className="reaction-add"
        aria-label="Add reaction"
        aria-haspopup="true"
        aria-expanded={open}
        title="Add reaction"
        onClick={() => (open ? closeMenu(false) : openMenu())}
        onKeyDown={(e) => {
          // Down/Up opens the menu and lands on the first option (menu-button pattern).
          if (!open && (e.key === 'ArrowDown' || e.key === 'ArrowUp')) {
            e.preventDefault();
            openMenu();
          }
        }}
      >
        ＋
      </button>
      <div
        ref={menuRef}
        className={`reaction-picker__menu${open ? ' is-open' : ''}`}
        role="menu"
        aria-label="Pick a reaction"
        onKeyDown={onMenuKeyDown}
      >
        {REACTION_EMOJIS.map((emoji, i) => {
          const selected = mine.has(emoji);
          return (
            <button
              key={emoji}
              ref={(el) => {
                optionRefs.current[i] = el;
              }}
              type="button"
              role="menuitemcheckbox"
              aria-checked={selected}
              tabIndex={open && i === activeIndex ? 0 : -1}
              disabled={isPending(emoji)}
              className="reaction-picker__option"
              aria-label={`${selected ? 'Remove' : 'Add'} ${emoji} reaction`}
              onClick={() => {
                onToggle(emoji);
                closeMenu(true);
              }}
            >
              <span aria-hidden>{emoji}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}

export default function ChatRoomDetailPage() {
  // orgId = resolved UUID for API calls; orgSlug = canonical slug for building URLs.
  const { orgId, slug: orgSlug, loading: orgLoading } = useOrgId();
  const params = useParams();
  const roomId = params.roomId as string;

  const [room, setRoom] = useState<ChatRoom | null>(null);
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [loading, setLoading] = useState(true);
  const [sending, setSending] = useState(false);
  // True when the messages endpoint isn't live yet (BE not deployed; 052 release gate).
  const [messagesPending, setMessagesPending] = useState(false);
  // In-flight reaction toggles, keyed `${messageId}:${emoji}`. Guards a rapid
  // double-tap on the same emoji from interleaving two requests into a wrong count
  // (yuki-ux flow C / sofia-qa G1). Ref is the synchronous source of truth for the
  // guard; the state mirror drives the disabled UI.
  const reactionInFlight = useRef<Set<string>>(new Set());
  const [pendingReactions, setPendingReactions] = useState<Set<string>>(new Set());
  const isReactionPending = useCallback(
    (messageId: string, emoji: string) => pendingReactions.has(`${messageId}:${emoji}`),
    [pendingReactions],
  );

  // Auto-scroll (yuki-ux §B / priya seq222): keep the newest message in view when
  // the user is already at the bottom (or just sent their own message), but NEVER
  // yank a user who has scrolled up reading history. `pinnedRef` tracks bottom
  // proximity via an IntersectionObserver on a sentinel, so it's agnostic to which
  // element actually scrolls (page vs container). `followNextRef` forces a scroll on
  // the user's own send regardless of pin state.
  const bottomRef = useRef<HTMLDivElement>(null);
  const pinnedRef = useRef(true);
  const followNextRef = useRef(false);

  const fetchRoom = useCallback(async () => {
    if (!orgId || !roomId) return;
    try {
      const { room } = await api.getChatRoom(orgId, roomId);
      setRoom(room);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load room');
    }
  }, [orgId, roomId]);

  const fetchMessages = useCallback(async () => {
    if (!orgId || !roomId) return;
    try {
      // Reactions arrive embedded per message (marcus seq144) — no separate fetch.
      // include_replies: this flat room view shows ALL messages; once 054 threading
      // ships, the default list is top-level-only, so opt into the flat list (aniket seq629)
      // until the Slack top-level+thread view lands (ffa2d2f6).
      const { messages } = await api.listChatMessages(orgId, roomId, { include_replies: true });
      setMessages(messages ?? []);
      setMessagesPending(false);
    } catch {
      // Endpoint not reachable yet — degrade to an empty thread + notice rather
      // than crashing the view while BE deploys.
      setMessages([]);
      setMessagesPending(true);
    }
  }, [orgId, roomId]);

  useEffect(() => {
    if (orgId && roomId) {
      Promise.all([fetchRoom(), fetchMessages()]).finally(() => setLoading(false));
    } else if (!orgLoading) {
      setLoading(false);
    }
  }, [fetchRoom, fetchMessages, orgId, roomId, orgLoading]);

  // Track whether the thread is scrolled to (near) the bottom. The sentinel only
  // exists once the room renders, so re-arm the observer when `loading` settles.
  useEffect(() => {
    const sentinel = bottomRef.current;
    if (!sentinel) return;
    const io = new IntersectionObserver(
      ([entry]) => {
        pinnedRef.current = entry.isIntersecting;
      },
      // Grow the root rect 48px past the bottom so "near the bottom" counts as pinned.
      { rootMargin: '0px 0px 48px 0px' },
    );
    io.observe(sentinel);
    return () => io.disconnect();
  }, [loading]);

  // On a new message (length change — not a reaction edit) or once the room finishes
  // loading (initial landing on the newest), follow to the bottom — but only if the
  // user was pinned there, or it's their own send. Reading-position preserved otherwise.
  useEffect(() => {
    if (pinnedRef.current || followNextRef.current) {
      bottomRef.current?.scrollIntoView({ block: 'end' });
      followNextRef.current = false;
    }
  }, [messages.length, loading]);

  async function handleSend(content: string) {
    if (!orgId) return;
    setSending(true);
    try {
      const { message } = await api.createChatMessage(orgId, roomId, { content });
      followNextRef.current = true; // always follow the user's own message to the bottom
      setMessages((prev) => [...prev, message]);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to send message');
      throw err; // let the composer reflect the failure (aria-invalid)
    } finally {
      setSending(false);
    }
  }

  async function toggleReaction(messageId: string, emoji: string) {
    if (!orgId) return;
    // Coalesce to a single in-flight request per (message, emoji): a second tap
    // while one is pending is a no-op until the first settles.
    const key = `${messageId}:${emoji}`;
    if (reactionInFlight.current.has(key)) return;
    reactionInFlight.current.add(key);
    setPendingReactions((prev) => new Set(prev).add(key));

    const target = messages.find((m) => m.id === messageId);
    const mine = target?.reactions?.find((r) => r.emoji === emoji)?.me ?? false;
    const snapshot = target?.reactions;

    // Optimistic update against the embedded summaries; reconcile on next fetch.
    setMessages((prev) =>
      prev.map((m) =>
        m.id === messageId
          ? { ...m, reactions: applyOptimisticReaction(m.reactions, emoji, !mine) }
          : m,
      ),
    );
    try {
      // POST/DELETE return the regrouped {emoji,count,me} summary (aniket seq171) —
      // reconcile with server truth in the same round-trip, no refetch needed.
      const { reactions } = mine
        ? await api.removeMessageReaction(orgId, roomId, messageId, emoji)
        : await api.addMessageReaction(orgId, roomId, messageId, emoji);
      setMessages((prev) =>
        prev.map((m) => (m.id === messageId ? { ...m, reactions } : m)),
      );
    } catch (err) {
      // Roll back to the pre-toggle snapshot on failure.
      setMessages((prev) =>
        prev.map((m) => (m.id === messageId ? { ...m, reactions: snapshot } : m)),
      );
      toast.error(err instanceof Error ? err.message : 'Reaction failed');
    } finally {
      reactionInFlight.current.delete(key);
      setPendingReactions((prev) => {
        const next = new Set(prev);
        next.delete(key);
        return next;
      });
    }
  }

  const roomTitle = room?.name ?? 'Room';
  // Prefer slug (ticket 0ab32676) when present; fall back to id. This is the full
  // value copied to the clipboard; the chip visually truncates a long UUID fallback
  // via CSS ellipsis (.chat-room-header__slug), so the user still copies it whole.
  const roomHandle = useMemo(() => room?.slug ?? room?.id ?? roomId, [room, roomId]);

  // Slug-as-copyable-handle (yuki seq181 / lena seq79): activate to copy the full
  // handle; falls back to manual select-all (CSS) if the clipboard API is blocked.
  const copyHandle = useCallback(async (handle: string) => {
    try {
      await navigator.clipboard.writeText(handle);
      toast.success('Room handle copied');
    } catch {
      toast.error('Copy unavailable — select the handle to copy it manually');
    }
  }, []);

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <Link href={`/app/${orgSlug}/chat`} className="sg-link">
            ← All rooms
          </Link>
        </div>

        {loading ? (
          <p className="sg-page-intro">Loading…</p>
        ) : !room ? (
          <div className="projects-empty">
            <p className="projects-empty__text">Room not found.</p>
          </div>
        ) : (
          <>
            <div className="chat-room-header">
              <h1 className="sg-page-title">{roomTitle}</h1>
              {roomHandle && (
                <button
                  type="button"
                  className="chat-room-header__slug"
                  title="Copy room handle"
                  aria-label={`Copy room handle ${roomHandle}`}
                  onClick={() => copyHandle(roomHandle)}
                >
                  {roomHandle}
                </button>
              )}
            </div>
            {room.description && <p className="sg-page-intro">{room.description}</p>}

            {messagesPending && (
              <div className="sg-notice" role="status">
                Messaging backend is not reachable yet — this thread will populate once
                the messages API is deployed.
              </div>
            )}

            <ul className="chat-thread" aria-label="Messages">
              {messages.length === 0 ? (
                <li className="chat-thread__empty">
                  {messagesPending ? 'Waiting on the messages API…' : 'No messages yet. Say hello 👋'}
                </li>
              ) : (
                messages.map((m) => {
                  const reactions = m.reactions ?? [];
                  return (
                    <li key={m.id} className="chat-message">
                      <div className="chat-message__meta">
                        <span className="chat-message__author">{m.sender ?? 'Unknown'}</span>
                        <span className="chat-message__time">{timeAgo(m.inserted_at)}</span>
                      </div>
                      <div className="chat-message__body">{m.content}</div>

                      <div className="chat-message__reactions">
                        {reactions.map((r) => (
                          <button
                            key={r.emoji}
                            type="button"
                            className={`reaction-chip${r.me ? ' reaction-chip--mine' : ''}`}
                            onClick={() => toggleReaction(m.id, r.emoji)}
                            disabled={isReactionPending(m.id, r.emoji)}
                            aria-pressed={r.me}
                            aria-label={`${r.emoji} reaction, ${r.count}`}
                          >
                            <span className="reaction-chip__emoji" aria-hidden>{r.emoji}</span>
                            <span className="reaction-chip__count">{r.count}</span>
                          </button>
                        ))}
                        <ReactionPicker
                          mine={new Set(reactions.filter((r) => r.me).map((r) => r.emoji))}
                          isPending={(emoji) => isReactionPending(m.id, emoji)}
                          onToggle={(emoji) => toggleReaction(m.id, emoji)}
                        />
                      </div>
                    </li>
                  );
                })
              )}
            </ul>
            {/* Bottom sentinel for pinned-to-bottom detection + auto-scroll target. */}
            <div ref={bottomRef} aria-hidden />

            <Composer disabled={!orgId} sending={sending} onSend={handleSend} />
          </>
        )}
      </main>
    </div>
  );
}
