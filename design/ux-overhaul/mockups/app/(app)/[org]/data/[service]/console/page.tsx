import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";
import { ScopeChip } from "@/components/ScopeChip";
import { DataTable, type Column } from "@/components/DataTable";
import { dbServices, consoleResultColumns, consoleResultRows } from "@/lib/fixtures";

type ResultRow = { id: string } & Record<string, string | number | null>;

export default async function ConsolePage({
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

  const columns: Column<ResultRow>[] = consoleResultColumns.map((c) => ({
    key: c,
    label: c,
    render: (r) => (r[c] === null ? "—" : String(r[c])),
  }));

  return (
    <div>
      <p className="state">STATE: {state}</p>
      <ScreenStates state={state} emptyTitle="No query run yet" emptyDescription="Run a query to see results here." emptyActionLabel="Focus editor">
        <PageHeader title={`${svc.name} — Console`}>
          <ScopeChip scope={svc.scope} />
        </PageHeader>
        <form className="stack">
          <label>
            SQL
            <textarea rows={6} style={{ width: "100%" }} defaultValue={"SELECT id, amount_usd, status FROM invoices LIMIT 100;"} />
          </label>
          <div className="row">
            <button type="submit">Run</button>
            <button type="button">Explain</button>
            <label>
              Limit <input type="number" defaultValue={100} style={{ width: "5rem" }} />
            </label>
          </div>
        </form>
        <p role="alert" className="chip">
          Write detected in last statement → requires approval before execution.
        </p>
        <DataTable columns={columns} rows={consoleResultRows as ResultRow[]} caption="Query results" />
      </ScreenStates>
    </div>
  );
}
