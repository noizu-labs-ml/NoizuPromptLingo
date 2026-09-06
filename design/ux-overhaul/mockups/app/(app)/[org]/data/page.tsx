import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";
import { ScopeChip } from "@/components/ScopeChip";
import { dbServices } from "@/lib/fixtures";

export default async function DataIndexPage({
  params,
  searchParams,
}: {
  params: Promise<{ org: string }>;
  searchParams: Promise<SearchParams>;
}) {
  const { org } = await params;
  const sp = await searchParams;
  const state = resolveState(sp);

  return (
    <div>
      <p className="state">STATE: {state}</p>
      <ScreenStates state={state} emptyTitle="No DB services connected" emptyDescription="Provision a credential to connect a database service." emptyActionLabel="Provision credential">
        <PageHeader title="Data services" primaryActionLabel="Provision credential" />
        <ul>
          {dbServices.map((s) => (
            <li key={s.id}>
              <strong>{s.name.trim() ? s.name : "(unnamed service)"}</strong> <span className="chip">{s.kind}</span>{" "}
              <ScopeChip scope={s.scope} />
              <ul>
                <li>
                  <a href={`/${org}/data/${s.id}/schema`}>Schema</a>
                </li>
                <li>
                  <a href={`/${org}/data/${s.id}/console`}>Console</a>
                </li>
                <li>
                  <a href={`/${org}/data/${s.id}/approvals`}>Approvals</a>
                </li>
                <li>
                  <a href={`/${org}/data/${s.id}/audit`}>Audit</a>
                </li>
                <li>
                  <a href={`/${org}/data/${s.id}/vectors`}>Vectors</a>
                </li>
              </ul>
            </li>
          ))}
        </ul>
      </ScreenStates>
    </div>
  );
}
