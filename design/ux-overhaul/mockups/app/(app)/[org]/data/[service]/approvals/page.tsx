import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";
import { ScopeChip } from "@/components/ScopeChip";
import { ApprovalCard } from "@/components/ApprovalCard";
import { approvals, dbServices } from "@/lib/fixtures";

export default async function ApprovalsPage({
  params,
  searchParams,
}: {
  params: Promise<{ org: string; service: string }>;
  searchParams: Promise<SearchParams>;
}) {
  const { service } = await params;
  const sp = await searchParams;
  const state = resolveState(sp);
  const svc = dbServices.find((s) => s.id === service) ?? dbServices[0];
  const selectedId = Array.isArray(sp.id) ? sp.id[0] : sp.id;
  const selected = approvals.find((a) => a.id === selectedId) ?? approvals[0];

  return (
    <div>
      <p className="state">STATE: {state}</p>
      <ScreenStates state={state} emptyTitle="No pending approvals" emptyDescription="Nothing is waiting for review." emptyActionLabel="View audit log">
        <PageHeader title={`${svc.name} — Write-approval queue`}>
          <ScopeChip scope={svc.scope} />
        </PageHeader>
        <div className="three-pane">
          <div>
            <h2>Queue</h2>
            <ul>
              {approvals.map((a) => (
                <li key={a.id} aria-current={a.id === selected.id ? "true" : undefined}>
                  <a href={`?id=${a.id}`}>{a.id}</a> <span className="chip">{a.risk}</span>
                </li>
              ))}
            </ul>
          </div>
          <div>
            <h2>Detail</h2>
            <ApprovalCard approval={selected} selected />
          </div>
          <div>
            <h2>Context</h2>
            <p>Diff preview and requester history shown here.</p>
          </div>
        </div>
      </ScreenStates>
    </div>
  );
}
