import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";
import { mounts } from "@/lib/fixtures";

export default async function FilesMountPickerPage({
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
      <ScreenStates state={state} emptyTitle="No mounts available" emptyDescription="No VFS mounts are configured for this org." emptyActionLabel="Configure a mount">
        <PageHeader title="Files — mount picker" />
        <ul>
          {mounts.map((m) => (
            <li key={m.id}>
              <a href={`/${org}/files/${encodeURIComponent(m.id)}`}>{m.name.trim() ? m.name : "(unnamed mount)"}</a>{" "}
              <span className="chip">{m.authState}</span>
              {m.authState === "expired" && <button type="button">Re-authenticate</button>}
              {m.docsAvailable && <a href={`/${org}/files/${encodeURIComponent(m.id)}?docs=1`}>Docs</a>}
            </li>
          ))}
        </ul>
      </ScreenStates>
    </div>
  );
}
