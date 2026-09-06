import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";
import { DataTable, type Column } from "@/components/DataTable";
import { members, memberCap, type Member } from "@/lib/fixtures";

export default async function MembersPage({ searchParams }: { searchParams: Promise<SearchParams> }) {
  const sp = await searchParams;
  const state = resolveState(sp);
  const remaining = memberCap.max - memberCap.used;

  const columns: Column<Member>[] = [
    { key: "name", label: "Name", sortable: true, render: (m) => m.name.trim() || "(unnamed member)" },
    { key: "email", label: "Email", render: (m) => m.email },
    { key: "role", label: "Role", sortable: true, render: (m) => <span className="chip">{m.role}</span> },
    { key: "suspended", label: "Status", render: (m) => (m.suspended ? <span className="chip">suspended</span> : "active") },
  ];

  return (
    <div>
      <p className="state">STATE: {state}</p>
      <ScreenStates state={state} emptyTitle="No members yet" emptyDescription="Invite your first member." emptyActionLabel="Invite member">
        <PageHeader title="Members" />
        <DataTable columns={columns} rows={members} caption="Members" />
        <section aria-label="Invite form" style={{ marginTop: "1rem" }}>
          <h2>Invite a member</h2>
          <p>
            {remaining > 0 ? (
              <>
                {remaining} of {memberCap.max} seats remaining.
              </>
            ) : (
              <span role="alert">Seat cap reached ({memberCap.max}/{memberCap.max}). Upgrade to invite more.</span>
            )}
          </p>
          <form className="row">
            <input type="email" placeholder="email@example.com" required />
            <select name="role" defaultValue="member">
              <option value="admin">admin</option>
              <option value="member">member</option>
              <option value="viewer">viewer</option>
            </select>
            <button type="submit" disabled={remaining <= 0}>
              Send invite
            </button>
          </form>
        </section>
      </ScreenStates>
    </div>
  );
}
