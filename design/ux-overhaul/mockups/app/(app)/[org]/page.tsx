import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";
import { Skeleton } from "@/components/Skeleton";
import { kpis, firstRunSteps, fmtNumber } from "@/lib/fixtures";

export default async function OrgHome({
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
      <ScreenStates
        state={state}
        loadingSkeleton={<Skeleton lines={8} />}
        emptyTitle="Welcome — let's get this org set up"
        emptyDescription="Complete the first-run checklist to unlock the dashboard."
        emptyActionLabel="Start checklist"
      >
        <PageHeader title={`${org} — Dashboard`} primaryActionLabel="New session" overflowItems={["Export snapshot", "Customize bento"]} />
        <section className="bento" aria-label="Key stats">
          {kpis.map((k) => (
            <div key={k.label}>
              <p className="chip">{k.label}</p>
              <p style={{ fontSize: "1.5rem" }}>{typeof k.value === "number" ? fmtNumber(k.value) : k.value}</p>
            </div>
          ))}
        </section>
        <section aria-label="First-run checklist" style={{ marginTop: "1rem" }}>
          <h2>First-run checklist</h2>
          <ul>
            {firstRunSteps.map((s) => (
              <li key={s.id}>
                <label>
                  <input type="checkbox" defaultChecked={s.done} readOnly /> {s.label}
                </label>
              </li>
            ))}
          </ul>
        </section>
      </ScreenStates>
      <footer className="meta">
        Try <code>?state=empty</code> to see the first-run checklist variant, or{" "}
        <code>?state=loading|error|denied|suspended</code>.
      </footer>
    </div>
  );
}
