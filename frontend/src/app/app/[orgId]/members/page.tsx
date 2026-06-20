"use client";

import { useState, useEffect } from "react";
import { api } from "@/lib/api";
import { useAuth } from "@/context/auth";
import { useOrgId } from "@/context/org";
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

export default function MembersPage() {
  const { orgId, loading: orgLoading } = useOrgId();
  const { user } = useAuth();
  const [members, setMembers] = useState<Member[]>([]);
  const [inviteEmail, setInviteEmail] = useState("");
  const [inviteRole, setInviteRole] = useState("viewer");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (orgId) {
      api.listMembers(orgId).then((res) => { setMembers(res.members); setLoading(false); }).catch(() => setLoading(false));
    } else if (!orgLoading) {
      setLoading(false);
    }
  }, [orgId, orgLoading]);

  async function handleInvite(e: React.FormEvent) {
    e.preventDefault();
    if (!inviteEmail || !orgId) return;
    try {
      const res = await api.addMember(orgId, inviteEmail, inviteRole);
      setMembers(res.members);
      setInviteEmail("");
      toast.success("Member added");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to add member");
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

  if (loading) return <p style={{ padding: 40 }}>Loading...</p>;

  return (
    <div style={{ maxWidth: 640, margin: "40px auto", padding: "0 24px" }}>
      <h1 style={{ fontSize: 24, marginBottom: 24 }}>Members</h1>

      <form onSubmit={handleInvite} style={{ display: "flex", gap: 8, marginBottom: 24 }}>
        <input type="email" placeholder="Email address" value={inviteEmail} onChange={(e) => setInviteEmail(e.target.value)} style={{ flex: 1, padding: 8, border: "1px solid #ccc", borderRadius: 4 }} />
        <select value={inviteRole} onChange={(e) => setInviteRole(e.target.value)} style={{ padding: 8, border: "1px solid #ccc", borderRadius: 4 }}>
          {ROLES.filter((r) => r !== "owner").map((r) => <option key={r} value={r}>{r}</option>)}
        </select>
        <button type="submit" style={{ padding: "8px 16px", background: "#000", color: "#fff", border: "none", borderRadius: 4, cursor: "pointer" }}>Add</button>
      </form>

      <table style={{ width: "100%", borderCollapse: "collapse" }}>
        <thead>
          <tr style={{ borderBottom: "2px solid #eee", textAlign: "left" }}>
            <th style={{ padding: 8 }}>Email</th>
            <th style={{ padding: 8 }}>Role</th>
            <th style={{ padding: 8 }}></th>
          </tr>
        </thead>
        <tbody>
          {members.map((m) => (
            <tr key={m.id} style={{ borderBottom: "1px solid #eee" }}>
              <td style={{ padding: 8 }}>{m.email}</td>
              <td style={{ padding: 8 }}>
                {m.role === "owner" ? (
                  <span>owner</span>
                ) : (
                  <select value={m.role} onChange={(e) => handleRoleChange(m.id, e.target.value)} style={{ padding: 4, border: "1px solid #ccc", borderRadius: 4 }}>
                    {ROLES.filter((r) => r !== "owner").map((r) => <option key={r} value={r}>{r}</option>)}
                  </select>
                )}
              </td>
              <td style={{ padding: 8 }}>
                {m.role !== "owner" && m.user_id !== user?.id && (
                  <button onClick={() => handleRemove(m.id)} style={{ color: "#dc2626", background: "none", border: "none", cursor: "pointer" }}>Remove</button>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
