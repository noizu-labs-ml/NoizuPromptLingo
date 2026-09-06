import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";
import { activityEvents, fmtDate } from "@/lib/fixtures";

export default async function ActivityPage({ searchParams }: { searchParams: Promise<SearchParams> }) {
  const sp = await searchParams;
  const state = resolveState(sp);
  const scope = (Array.isArray(sp.scope) ? sp.scope[0] : sp.scope) ?? "org";

  return (
    <div>
      <p className="state">STATE: {state}</p>
      <ScreenStates
        state={state}
        emptyTitle="No activity yet"
        emptyDescription="Activity events land here once producers ship (behind feature.inbox)."
        emptyActionLabel="View sessions"
      >
        <PageHeader title="Activity" />
        <p className="chip">scope: {scope}</p>
        <ul aria-label="Activity feed, grouped by day">
          {activityEvents.map((a) => (
            <li key={a.id}>
              {fmtDate(a.timestamp)} — {a.actor?.trim() ? a.actor : "(unknown actor)"} {a.verb} {a.object}{" "}
              <span className="chip">{a.scope}</span>
            </li>
          ))}
        </ul>
      </ScreenStates>
    </div>
  );
}
