import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";
import { tickets, fmtDate } from "@/lib/fixtures";

export default async function TicketDetailPage({
  params,
  searchParams,
}: {
  params: Promise<{ org: string; id: string }>;
  searchParams: Promise<SearchParams>;
}) {
  const { org, id } = await params;
  const sp = await searchParams;
  const state = resolveState(sp);
  const tab = (Array.isArray(sp.tab) ? sp.tab[0] : sp.tab) ?? "fields";
  const ticket = tickets.find((t) => t.id === id) ?? tickets[0];

  const tabs = [
    { id: "fields", label: "Fields" },
    { id: "links", label: "Links" },
    { id: "activity", label: "Activity" },
    { id: "prd", label: "PRD" },
  ];

  return (
    <div>
      <p className="state">STATE: {state}</p>
      <ScreenStates state={state} emptyTitle="No data for this tab" emptyDescription="Nothing recorded yet." emptyActionLabel="Refresh">
        <PageHeader title={`#${ticket.id} ${ticket.title.trim() ? ticket.title : "(untitled)"}`} overflowItems={["Close ticket", "Convert to bug", "Copy link"]} />
        <nav aria-label="Ticket detail tabs">
          <ul className="row" style={{ listStyle: "none", padding: 0 }}>
            {tabs.map((t) => (
              <li key={t.id}>
                <a href={`/${org}/work/tickets/${id}?tab=${t.id}`} aria-current={t.id === tab ? "page" : undefined}>
                  {t.label}
                </a>
              </li>
            ))}
          </ul>
        </nav>
        {tab === "fields" && (
          <dl>
            <dt>Type</dt>
            <dd className="chip">{ticket.type}</dd>
            <dt>Status</dt>
            <dd className="chip">{ticket.status}</dd>
            <dt>Assignee</dt>
            <dd>{ticket.assignee ?? "(unassigned)"}</dd>
            <dt>Updated</dt>
            <dd>{fmtDate(ticket.updatedAt)}</dd>
            {Object.entries(ticket.customFields).map(([k, v]) => (
              <div key={k}>
                <dt>f.{k}</dt>
                <dd>{v ?? "—"}</dd>
              </div>
            ))}
          </dl>
        )}
        {tab === "links" && <p>No linked tickets or PRs yet.</p>}
        {tab === "activity" && <p>No activity recorded for this ticket in this fixture.</p>}
        {tab === "prd" && <p>No PRD attached.</p>}
      </ScreenStates>
    </div>
  );
}
