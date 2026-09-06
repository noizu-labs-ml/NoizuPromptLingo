import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";
import { DataTable, type Column } from "@/components/DataTable";
import { sessions, fmtDate, fmtDuration, type SessionRow } from "@/lib/fixtures";
import { SkeletonTable } from "@/components/Skeleton";

export default async function SessionsPage({
  params,
  searchParams,
}: {
  params: Promise<{ org: string }>;
  searchParams: Promise<SearchParams>;
}) {
  const { org } = await params;
  const sp = await searchParams;
  const state = resolveState(sp);

  const columns: Column<SessionRow>[] = [
    { key: "name", label: "Name", sortable: true, render: (r) => <a href={`/${org}/work/sessions/${r.id}`}>{r.name.trim() ? r.name : "(untitled session)"}</a> },
    { key: "status", label: "Status", sortable: true, render: (r) => <span className="chip">{r.status}</span> },
    { key: "project", label: "Project", render: (r) => r.project },
    { key: "owner", label: "Owner", render: (r) => r.owner?.trim() || "(unassigned)" },
    { key: "startedAt", label: "Started", sortable: true, render: (r) => fmtDate(r.startedAt) },
    { key: "durationMs", label: "Duration", render: (r) => fmtDuration(r.durationMs) },
    { key: "toolScope", label: "Tool scope", render: (r) => r.toolScope },
  ];

  return (
    <div>
      <p className="state">STATE: {state}</p>
      <ScreenStates
        state={state}
        loadingSkeleton={<SkeletonTable cols={7} />}
        emptyTitle="No sessions match these filters"
        emptyDescription="Try clearing filters or start a new session."
        emptyActionLabel="Clear filters"
      >
        <PageHeader title="Sessions" primaryActionLabel="New session" />
        <form className="row">
          <input type="search" name="q" placeholder="Filter sessions…" />
          <select name="status" defaultValue="">
            <option value="">Any status</option>
            <option value="running">Running</option>
            <option value="succeeded">Succeeded</option>
            <option value="failed">Failed</option>
          </select>
          <select name="project" defaultValue="">
            <option value="">Any project</option>
            <option value="core">core</option>
            <option value="billing">billing</option>
          </select>
        </form>
        <DataTable columns={columns} rows={sessions} caption="Sessions" nextCursorHref={`/${org}/work/sessions?cursor=next`} />
      </ScreenStates>
    </div>
  );
}
