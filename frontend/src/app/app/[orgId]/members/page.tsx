"use client";

import { useState, useEffect } from "react";
import { api } from "@/lib/api";
import { useAuth } from "@/context/auth";
import { useOrg, useOrgId } from "@/context/org";
import { toast } from "sonner";

interface Member {
  id: string;
  user_id: string;
  email: string;
  user_name: string;
  role: string;
  joined_at: string;
}

const ROLES = ["viewer", "editor", "admin", "owner"];
const ASSIGNABLE_ROLES = ROLES.filter((r) => r !== "owner");

export default function MembersPage() {
  const { orgId, loading: orgLoading } = useOrgId();
  const { user } = useAuth();
  const { organizations } = useOrg();
  const [members, setMembers] = useState<Member[]>([]);
  const [inviteEmail, setInviteEmail] = useState("");
  const [inviteRole, setInviteRole] = useState("viewer");
  const [inviting, setInviting] = useState(false);
  const [loading, setLoading] = useState(true);

  // The caller's role in this org gates all management actions. The backend
  // enforces org_admin on every mutation; this just keeps the UI honest.
  const myRole = organizations.find((o) => o.id === orgId)?.role;
  const isAdmin = myRole === "admin" || myRole === "owner";

  useEffect(() => {
    if (orgId) {
      api.listMembers(orgId)
        .then((res) => { setMembers(res.members); setLoading(false); })
        .catch(() => setLoading(false));
    } else if (!orgLoading) {
      setLoading(false);
    }
  }, [orgId, orgLoading]);

  async function handleInvite(e: React.FormEvent) {
    e.preventDefault();
    if (!inviteEmail || !orgId) return;
    setInviting(true);
    try {
      const res = await api.addMember(orgId, inviteEmail, inviteRole);
      setMembers(res.members);
      setInviteEmail("");
      toast.success("Member added");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to add member");
    } finally {
      setInviting(false);
    }
  }

  async function handleRoleChange(memberId: string, newRole: string) {
    if (!orgId) return;
    try {
      const res = await api.updateMemberRole(orgId, memberId, newRole);
      setMembers(res.members);
      toast.success("Role updated");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to update role");
    }
  }

  async function handleRemove(memberId: string) {
    if (!confirm("Remove this member?") || !orgId) return;
    try {
      await api.removeMember(orgId, memberId);
      setMembers((prev) => prev.filter((m) => m.id !== memberId));
      toast.success("Member removed");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to remove member");
    }
  }

  if (loading) return <div className="content"><main><p className="sg-page-intro">Loading…</p></main></div>;

  return (
    <div className="content">
      <main>
        <h1 className="sg-page-title">Members</h1>
        <p className="sg-page-intro">
          People with access to this organization.
          {isAdmin ? " As an admin you can invite members and change roles." : " Only org admins can change membership."}
        </p>

        {isAdmin && (
          <form onSubmit={handleInvite} className="button-row" style={{ marginBottom: 24, alignItems: "flex-end" }}>
            <div className="sg-field" style={{ flex: 1 }}>
              <label htmlFor="invite-email">Invite by email</label>
              <input
                id="invite-email"
                type="email"
                placeholder="person@example.com"
                value={inviteEmail}
                onChange={(e) => setInviteEmail(e.target.value)}
              />
            </div>
            <div className="sg-field">
              <label htmlFor="invite-role">Role</label>
              <select id="invite-role" value={inviteRole} onChange={(e) => setInviteRole(e.target.value)}>
                {ASSIGNABLE_ROLES.map((r) => <option key={r} value={r}>{r}</option>)}
              </select>
            </div>
            <button type="submit" className="sg-btn sg-btn--black sg-btn--sm" disabled={inviting}>
              {inviting ? "Adding…" : "Add"}
            </button>
          </form>
        )}

        <div className="admin-table-wrap">
          <table className="admin-table">
            <thead>
              <tr>
                <th>User</th>
                <th>Email</th>
                <th>Role</th>
                {isAdmin && <th />}
              </tr>
            </thead>
            <tbody>
              {members.map((m) => {
                const isOwner = m.role === "owner";
                const isSelf = m.user_id === user?.id;
                return (
                  <tr key={m.id}>
                    <td>{m.user_name || "—"}</td>
                    <td>{m.email}</td>
                    <td>
                      {isAdmin && !isOwner ? (
                        <select
                          className="admin-role-select"
                          value={m.role}
                          onChange={(e) => handleRoleChange(m.id, e.target.value)}
                        >
                          {ASSIGNABLE_ROLES.map((r) => <option key={r} value={r}>{r}</option>)}
                        </select>
                      ) : (
                        <span>{m.role}</span>
                      )}
                    </td>
                    {isAdmin && (
                      <td>
                        {!isOwner && !isSelf && (
                          <button
                            className="sg-btn sg-btn--danger sg-btn--sm"
                            onClick={() => handleRemove(m.id)}
                          >
                            Remove
                          </button>
                        )}
                      </td>
                    )}
                  </tr>
                );
              })}
              {members.length === 0 && (
                <tr>
                  <td colSpan={isAdmin ? 4 : 3} style={{ textAlign: "center", padding: 24 }}>
                    No members yet.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </main>
    </div>
  );
}
