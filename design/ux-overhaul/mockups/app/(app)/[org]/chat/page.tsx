import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";
import { chatRooms } from "@/lib/fixtures";

export default async function ChatIndexPage({
  params,
  searchParams,
}: {
  params: Promise<{ org: string }>;
  searchParams: Promise<SearchParams>;
}) {
  const { org } = await params;
  const sp = await searchParams;
  const state = resolveState(sp);

  return (
    <div>
      <p className="state">STATE: {state}</p>
      <ScreenStates state={state} emptyTitle="No rooms yet" emptyDescription="Create a room to start chatting." emptyActionLabel="New room">
        <PageHeader title="Chat" primaryActionLabel="New room" />
        <ul>
          {chatRooms.map((r) => (
            <li key={r.id}>
              <a href={`/${org}/chat/${encodeURIComponent(r.id)}`}>{r.name.trim() ? r.name : "(unnamed room)"}</a>{" "}
              {r.unread > 0 && <span className="chip">{r.unread} unread</span>} {r.muted && <span className="chip">muted</span>}
            </li>
          ))}
        </ul>
      </ScreenStates>
    </div>
  );
}
