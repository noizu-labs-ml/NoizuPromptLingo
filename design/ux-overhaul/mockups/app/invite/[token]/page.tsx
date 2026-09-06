import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";

export default async function InviteAcceptPage({
  params,
  searchParams,
}: {
  params: Promise<{ token: string }>;
  searchParams: Promise<SearchParams>;
}) {
  const { token } = await params;
  const sp = await searchParams;
  const state = resolveState(sp);

  return (
    <main style={{ padding: "1rem", maxWidth: "480px" }}>
      <p className="state">STATE: {state}</p>
      <h1>You're invited</h1>
      <p>Token: {token}</p>
      <ScreenStates
        state={state}
        emptyTitle="This invite is no longer valid"
        emptyDescription="It may have expired or already been used."
        emptyActionLabel="Request a new invite"
      >
        <p>Joining Acme Robotics as <span className="chip">member</span>.</p>
        <div className="stack">
          <button type="button">Continue with SSO</button>
          <details>
            <summary>Use a magic link instead</summary>
            <form className="row">
              <input type="email" placeholder="email@example.com" required />
              <button type="submit">Send link</button>
            </form>
          </details>
        </div>
        <p role="alert" className="chip">
          Org seat cap reached — contact an admin before accepting.
        </p>
      </ScreenStates>
    </main>
  );
}
