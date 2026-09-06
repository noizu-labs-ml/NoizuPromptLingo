import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";
import { integrations } from "@/lib/fixtures";

export default async function IntegrationsPage({ searchParams }: { searchParams: Promise<SearchParams> }) {
  const sp = await searchParams;
  const state = resolveState(sp);

  return (
    <div>
      <p className="state">STATE: {state}</p>
      <ScreenStates state={state} emptyTitle="No integrations configured" emptyDescription="Connect GitHub, MCP, or webhooks to get started." emptyActionLabel="Connect an integration">
        <PageHeader title="Integrations" />
        <ul>
          {integrations.map((i) => (
            <li key={i.id}>
              {i.name} <span className="chip">{i.status}</span>{" "}
              <button type="button">{i.status === "connected" ? "Manage" : "Configure"}</button>
            </li>
          ))}
        </ul>
      </ScreenStates>
    </div>
  );
}
