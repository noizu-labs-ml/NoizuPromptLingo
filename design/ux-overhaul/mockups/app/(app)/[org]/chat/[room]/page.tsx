import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";
import { ThreadPanel } from "@/components/ThreadPanel";
import { chatRooms, chatMessages, fmtDate } from "@/lib/fixtures";

export default async function ChatRoomPage({
  params,
  searchParams,
}: {
  params: Promise<{ org: string; room: string }>;
  searchParams: Promise<SearchParams>;
}) {
  const { org, room: roomParam } = await params;
  const sp = await searchParams;
  const state = resolveState(sp);
  const threadId = Array.isArray(sp.thread) ? sp.thread[0] : sp.thread;
  const room = chatRooms.find((r) => r.id === roomParam) ?? chatRooms[0];
  const messages = chatMessages[room.id] ?? chatMessages.general;
  const rootMessage = threadId ? messages.find((m) => m.id === threadId) ?? null : null;
  const replies = threadId ? messages.filter((m) => m.threadId === threadId) : [];

  return (
    <div>
      <p className="state">STATE: {state}</p>
      <ScreenStates state={state} emptyTitle="No messages yet" emptyDescription="Say something to start the conversation." emptyActionLabel="Focus composer">
        <PageHeader title={room.name.trim() ? room.name : "(unnamed room)"} overflowItems={["Room settings", "Leave room"]} />
        <div className="three-pane">
          <div>
            <h2>Rooms</h2>
            <ul>
              {chatRooms.map((r) => (
                <li key={r.id} aria-current={r.id === room.id ? "true" : undefined}>
                  <a href={`/${org}/chat/${encodeURIComponent(r.id)}`}>{r.name.trim() ? r.name : "(unnamed room)"}</a>
                </li>
              ))}
            </ul>
          </div>
          <div>
            <h2>Messages</h2>
            <ul>
              {messages.map((m) => (
                <li key={m.id}>
                  <strong>{m.author ?? "(deleted user)"}</strong> — {fmtDate(m.at)}
                  {m.pinned && <span className="chip">pinned</span>}
                  <p>{m.body || "(empty message)"}</p>
                  <a href={`?thread=${m.id}`}>Open thread</a>
                </li>
              ))}
            </ul>
            <form className="row">
              <input type="text" placeholder="Message…" style={{ flex: 1 }} />
              <button type="submit">Send</button>
            </form>
          </div>
          <ThreadPanel rootMessage={rootMessage} replies={replies} />
        </div>
      </ScreenStates>
    </div>
  );
}
