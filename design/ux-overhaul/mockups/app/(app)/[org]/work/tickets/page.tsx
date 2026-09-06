import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";
import { DataTable, type Column } from "@/components/DataTable";
import { SkeletonTable } from "@/components/Skeleton";
import { tickets, fmtDate, type Ticket } from "@/lib/fixtures";

export default async function TicketsPage({
  params,
  searchParams,
}: {
  params: Promise<{ org: string }>;
  searchParams: Promise<SearchParams>;
}) {
  const { org } = await params;
  const sp = await searchParams;
  const state = resolveState(sp);

  const columns: Column<Ticket>[] = [
    { key: "id", label: "#", render: (t) => <a href={`/${org}/work/tickets/${t.id}`}>{t.id}</a> },
    { key: "title", label: "Title", sortable: true, render: (t) => (t.title.trim() ? t.title : "(untitled)") },
    { key: "type", label: "Type", render: (t) => <span className="chip">{t.type}</span> },
    { key: "status", label: "Status", sortable: true, render: (t) => <span className="chip">{t.status}</span> },
    { key: "assignee", label: "Assignee", render: (t) => t.assignee ?? "(unassigned)" },
    { key: "severity", label: "f.severity", render: (t) => t.customFields.severity ?? "—" },
    { key: "points", label: "f.points", render: (t) => t.customFields.points ?? "—" },
    { key: "updatedAt", label: "Updated", sortable: true, render: (t) => fmtDate(t.updatedAt) },
  ];

  return (
    <div>
      <p className="state">STATE: {state}</p>
      <ScreenStates
        state={state}
        loadingSkeleton={<SkeletonTable cols={8} />}
        emptyTitle="No tickets match these filters"
        emptyDescription="Clear filters or create a ticket."
        emptyActionLabel="Clear filters"
      >
        <PageHeader title="Tickets" primaryActionLabel="New ticket" />
        <form className="row">
          <input type="search" name="q" placeholder="Filter tickets…" />
          <label>
            f.severity
            <select name="f.severity" defaultValue="">
              <option value="">Any</option>
              <option value="P1">P1</option>
              <option value="P2">P2</option>
              <option value="P3">P3</option>
            </select>
          </label>
        </form>
        <DataTable columns={columns} rows={tickets} caption="Tickets" nextCursorHref={`/${org}/work/tickets?cursor=next`} />
      </ScreenStates>
    </div>
  );
}
