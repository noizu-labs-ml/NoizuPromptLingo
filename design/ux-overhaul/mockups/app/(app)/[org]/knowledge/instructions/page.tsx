import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";
import { DataTable, type Column } from "@/components/DataTable";
import { instructions, fmtDate } from "@/lib/fixtures";

type Instr = (typeof instructions)[number];

export default async function InstructionsPage({ searchParams }: { searchParams: Promise<SearchParams> }) {
  const sp = await searchParams;
  const state = resolveState(sp);

  const columns: Column<Instr>[] = [
    { key: "name", label: "Name", sortable: true, render: (i) => i.name },
    { key: "version", label: "Version", render: (i) => <span className="chip">{i.version}</span> },
    { key: "updatedAt", label: "Updated", sortable: true, render: (i) => fmtDate(i.updatedAt) },
  ];

  return (
    <div>
      <p className="state">STATE: {state}</p>
      <ScreenStates
        state={state}
        emptyTitle="No instructions yet"
        emptyDescription="Instructions are versioned, embedded prompt library entries."
        emptyActionLabel="New instruction"
      >
        <PageHeader title="Instructions" primaryActionLabel="New instruction" />
        <DataTable columns={columns} rows={instructions} caption="Instructions" />
      </ScreenStates>
    </div>
  );
}
