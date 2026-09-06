import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";
import { ScopeChip } from "@/components/ScopeChip";
import { vectorResults, dbServices } from "@/lib/fixtures";

export default async function VectorsPage({
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

  return (
    <div>
      <p className="state">STATE: {state}</p>
      <ScreenStates state={state} emptyTitle="No results" emptyDescription="No vectors matched this query." emptyActionLabel="Clear query">
        <PageHeader title={`${svc.name} — Vector search`}>
          <ScopeChip scope={svc.scope} />
        </PageHeader>
        <form className="row">
          <input type="search" placeholder="Query the recall index…" style={{ flex: 1 }} />
          <button type="submit">Search</button>
        </form>
        <ul>
          {vectorResults.map((v) => (
            <li key={v.id}>
              {v.snippet.trim() ? v.snippet : "(empty snippet)"} — <span className="chip">score {v.score}</span>
            </li>
          ))}
        </ul>
      </ScreenStates>
    </div>
  );
}
