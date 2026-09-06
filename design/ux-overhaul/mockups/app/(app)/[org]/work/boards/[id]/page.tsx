import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";
import { Board } from "@/components/Board";
import { Toast } from "@/components/Toast";
import { boards } from "@/lib/fixtures";

export default async function BoardPage({
  params,
  searchParams,
}: {
  params: Promise<{ org: string; id: string }>;
  searchParams: Promise<SearchParams>;
}) {
  const { org, id } = await params;
  const sp = await searchParams;
  const state = resolveState(sp);
  const board = boards[id] ?? boards.launch;

  return (
    <div>
      <p className="state">STATE: {state}</p>
      <ScreenStates
        state={state}
        emptyTitle="Board has no cards yet"
        emptyDescription="Create the first ticket to populate this board."
        emptyActionLabel="New ticket"
      >
        <PageHeader title={board.name} primaryActionLabel="New ticket" />
        <form className="row">
          <select name="iteration" defaultValue="">
            <option value="">Any iteration</option>
            <option value="current">Current</option>
          </select>
          <select name="stage" defaultValue="">
            <option value="">Any stage</option>
            {board.stages.map((s) => (
              <option key={s.id} value={s.id}>
                {s.name}
              </option>
            ))}
          </select>
        </form>
        <Board stages={board.stages} ticketHrefFor={(tid) => `/${org}/work/tickets/${tid}`} />
        <div style={{ marginTop: "1rem" }}>
          <Toast />
        </div>
      </ScreenStates>
    </div>
  );
}
