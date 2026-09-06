import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";

export default async function AdminAuthzPage({ searchParams }: { searchParams: Promise<SearchParams> }) {
  const sp = await searchParams;
  const state = resolveState(sp);

  return (
    <div>
      <p className="state">STATE: {state}</p>
      <ScreenStates state={state} emptyTitle="No denials recorded" emptyDescription="No PBAC denials in the selected window." emptyActionLabel="Widen window">
        <PageHeader title="AuthZ / PBAC" />
        <section aria-label="Denial explainer">
          <h2>Recent denial</h2>
          <dl>
            <dt>Actor</dt>
            <dd>member u3</dd>
            <dt>Action</dt>
            <dd>db.write</dd>
            <dt>Resource</dt>
            <dd>svc-billing.ledger_entries</dd>
            <dt>Policy</dt>
            <dd>role:member lacks db.write; requires role:admin or approved write-approval</dd>
            <dt>Decision</dt>
            <dd className="chip">deny (deny-wins narrow rule)</dd>
          </dl>
          <p>This explainer renders the evaluated policy chain, not just the final verdict, so admins can see which rule fired.</p>
        </section>
      </ScreenStates>
    </div>
  );
}
