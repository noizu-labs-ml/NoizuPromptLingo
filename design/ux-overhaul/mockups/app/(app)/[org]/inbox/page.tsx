import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";
import { notifications, fmtDate } from "@/lib/fixtures";

export default async function InboxPage({ searchParams }: { searchParams: Promise<SearchParams> }) {
  const sp = await searchParams;
  const state = resolveState(sp);
  const filter = (Array.isArray(sp.filter) ? sp.filter[0] : sp.filter) ?? "all";

  return (
    <div>
      <p className="state">STATE: {state}</p>
      <ScreenStates
        state={state}
        emptyTitle="No notifications"
        emptyDescription="Notifications land here once producers ship (behind feature.inbox)."
        emptyActionLabel="Adjust notification prefs"
      >
        <PageHeader title="Inbox" primaryActionLabel="Mark all read" />
        <form>
          <label>
            Filter
            <select name="filter" defaultValue={filter}>
              <option value="all">All</option>
              <option value="unread">Unread</option>
              <option value="mentions">Mentions</option>
            </select>
          </label>
        </form>
        <ul>
          {notifications.map((n) => (
            <li key={n.id} aria-current={!n.read ? "true" : undefined}>
              <span className="chip">{n.read ? "read" : "unread"}</span> {n.actor ?? "(system)"} {n.verb}{" "}
              {n.object} — {fmtDate(n.createdAt)}
            </li>
          ))}
        </ul>
      </ScreenStates>
    </div>
  );
}
