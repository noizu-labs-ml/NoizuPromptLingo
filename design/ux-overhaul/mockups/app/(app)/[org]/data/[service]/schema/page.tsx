import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";
import { ScopeChip } from "@/components/ScopeChip";
import { dbSchema, dbServices } from "@/lib/fixtures";

export default async function SchemaPage({
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
  const tables = dbSchema[svc.id] ?? [];

  return (
    <div>
      <p className="state">STATE: {state}</p>
      <ScreenStates state={state} emptyTitle="No tables found" emptyDescription="This service reports no tables in scope." emptyActionLabel="Refresh">
        <PageHeader title={`${svc.name} — Schema`}>
          <ScopeChip scope={svc.scope} />
        </PageHeader>
        <div className="three-pane">
          <div>
            <h2>Tables</h2>
            <ul>
              {tables.map((t) => (
                <li key={t.table}>{t.table}</li>
              ))}
            </ul>
          </div>
          <div>
            <h2>Columns</h2>
            {tables.map((t) => (
              <div key={t.table}>
                <h3>{t.table}</h3>
                <table>
                  <thead>
                    <tr>
                      <th>Column</th>
                      <th>Type</th>
                    </tr>
                  </thead>
                  <tbody>
                    {t.columns.map((c) => (
                      <tr key={c.name}>
                        <td>{c.name}</td>
                        <td>{c.type}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            ))}
          </div>
          <div>
            <h2>Indexes</h2>
            <p>No indexes reported for the selected table.</p>
            <button type="button">Copy identifier</button>
          </div>
        </div>
      </ScreenStates>
    </div>
  );
}
