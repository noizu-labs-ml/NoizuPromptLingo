import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";
import { sessions, sessionEvents, fmtDate, fmtDuration } from "@/lib/fixtures";

export default async function SessionDetailPage({
  params,
  searchParams,
}: {
  params: Promise<{ org: string; id: string }>;
  searchParams: Promise<SearchParams>;
}) {
  const { org, id } = await params;
  const sp = await searchParams;
  const state = resolveState(sp);
  const tab = (Array.isArray(sp.tab) ? sp.tab[0] : sp.tab) ?? "overview";
  const session = sessions.find((s) => s.id === id) ?? sessions[0];

  const tabs = [
    { id: "overview", label: "Overview" },
    { id: "events", label: "Events" },
    { id: "tools", label: "Tools" },
    { id: "artifacts", label: "Artifacts" },
  ];

  return (
    <div>
      <p className="state">STATE: {state}</p>
      <ScreenStates state={state} emptyTitle="No data for this tab" emptyDescription="Nothing recorded yet." emptyActionLabel="Refresh">
        <PageHeader title={session.name.trim() ? session.name : "(untitled session)"} overflowItems={["Cancel session", "Duplicate", "Copy id"]} />
        <nav aria-label="Session detail tabs">
          <ul className="row" style={{ listStyle: "none", padding: 0 }}>
            {tabs.map((t) => (
              <li key={t.id}>
                <a href={`/${org}/work/sessions/${id}?tab=${t.id}`} aria-current={t.id === tab ? "page" : undefined}>
                  {t.label}
                </a>
              </li>
            ))}
          </ul>
        </nav>
        {tab === "overview" && (
          <dl>
            <dt>Status</dt>
            <dd className="chip">{session.status}</dd>
            <dt>Project</dt>
            <dd>{session.project}</dd>
            <dt>Owner</dt>
            <dd>{session.owner?.trim() || "(unassigned)"}</dd>
            <dt>Started</dt>
            <dd>{fmtDate(session.startedAt)}</dd>
            <dt>Duration</dt>
            <dd>{fmtDuration(session.durationMs)}</dd>
            <dt>Tool scope</dt>
            <dd>{session.toolScope}</dd>
          </dl>
        )}
        {tab === "events" && (
          <ul>
            {sessionEvents.map((e) => (
              <li key={e.id}>
                {fmtDate(e.at)} — <span className="chip">{e.type}</span> {e.label}
              </li>
            ))}
          </ul>
        )}
        {tab === "tools" && <p>Tool scope: {session.toolScope}. No calls recorded in this fixture.</p>}
        {tab === "artifacts" && <p>No artifacts produced by this session yet.</p>}
      </ScreenStates>
    </div>
  );
}
