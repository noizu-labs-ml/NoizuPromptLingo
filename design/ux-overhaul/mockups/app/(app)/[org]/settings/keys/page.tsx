import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";
import { SecretRow } from "@/components/SecretRow";
import { keys } from "@/lib/fixtures";

export default async function KeysPage({ searchParams }: { searchParams: Promise<SearchParams> }) {
  const sp = await searchParams;
  const state = resolveState(sp);

  return (
    <div>
      <p className="state">STATE: {state}</p>
      <ScreenStates state={state} emptyTitle="No keys yet" emptyDescription="Create an MCP key to connect tools." emptyActionLabel="New key">
        <PageHeader title="Key vault" primaryActionLabel="New key" />
        <table>
          <thead>
            <tr>
              <th>Label</th>
              <th>Scope</th>
              <th>Value</th>
              <th>Last used</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {keys.map((k) => (
              <SecretRow secret={k} key={k.id} />
            ))}
          </tbody>
        </table>
      </ScreenStates>
    </div>
  );
}
