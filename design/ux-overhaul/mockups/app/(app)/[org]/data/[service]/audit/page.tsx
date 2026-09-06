import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";
import { ScopeChip } from "@/components/ScopeChip";
import { DataTable, type Column } from "@/components/DataTable";
import { auditRows, dbServices, fmtDate } from "@/lib/fixtures";

type AuditRow = (typeof auditRows)[number];

export default async function AuditPage({
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

  const columns: Column<AuditRow>[] = [
    { key: "actor", label: "Actor", render: (r) => r.actor?.trim() || "(unknown actor)" },
    { key: "action", label: "Action", sortable: true, render: (r) => <span className="chip">{r.action}</span> },
    { key: "target", label: "Target", render: (r) => r.target },
    { key: "at", label: "At", sortable: true, render: (r) => fmtDate(r.at) },
    { key: "redacted", label: "Args", render: (r) => (r.redacted ? "(redacted)" : "shown") },
  ];

  return (
    <div>
      <p className="state">STATE: {state}</p>
      <ScreenStates state={state} emptyTitle="No audit rows" emptyDescription="Nothing has run against this service yet." emptyActionLabel="Open console">
        <PageHeader title={`${svc.name} — Audit / pool dashboard`}>
          <ScopeChip scope={svc.scope} />
        </PageHeader>
        <section className="bento" style={{ gridTemplateColumns: "repeat(3, 1fr)", marginBottom: "1rem" }}>
          <div>
            <p className="chip">Pool active</p>
            <p>4 / 10</p>
          </div>
          <div>
            <p className="chip">Queries (24h)</p>
            <p>128</p>
          </div>
          <div>
            <p className="chip">Errors (24h)</p>
            <p>2</p>
          </div>
        </section>
        <DataTable columns={columns} rows={auditRows} caption="Audit log" />
      </ScreenStates>
    </div>
  );
}
