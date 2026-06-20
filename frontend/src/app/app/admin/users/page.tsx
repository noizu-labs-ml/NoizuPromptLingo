"use client";

import { useState, useEffect } from "react";
import { api } from "@/lib/api";
import { useAuth } from "@/context/auth";
import { toast } from "sonner";

interface AdminUser {
  id: string;
  email: string;
  user_name: string;
  status: string;
  verified: boolean;
  role: string;
  created_at: string;
}

const ALL_ROLES = ["user", "moderator", "admin", "owner", "service", "other"];

export default function AdminUsersPage() {
  const { user: me } = useAuth();
  const [users, setUsers] = useState<AdminUser[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);
  const [savingId, setSavingId] = useState<string | null>(null);

  useEffect(() => {
    api.adminListUsers(page).then((res) => {
      setUsers(res.users);
      setTotal(res.total);
      setLoading(false);
    }).catch(() => setLoading(false));
  }, [page]);

  async function changeRole(id: string, role: string) {
    const prev = users.find((u) => u.id === id)?.role;
    setSavingId(id);
    // Optimistic update
    setUsers((us) => us.map((u) => (u.id === id ? { ...u, role } : u)));
    try {
      await api.adminUpdateUserRole(id, role);
      toast.success(`Role updated to ${role}`);
    } catch (err) {
      // Revert on failure
      setUsers((us) => us.map((u) => (u.id === id ? { ...u, role: prev ?? u.role } : u)));
      toast.error(err instanceof Error ? err.message : "Failed to update role");
    } finally {
      setSavingId(null);
    }
  }

  if (loading) {
    return <div className="content narrow"><main><p className="sg-page-intro">Loading…</p></main></div>;
  }

  return (
    <div className="content">
      <main>
        <h1 className="sg-page-title">Users ({total})</h1>
        <p className="sg-page-intro">Manage account roles. Elevated roles (admin, owner) grant access to this admin area.</p>
        <div className="admin-table-wrap">
          <table className="admin-table">
            <thead>
              <tr>
                <th>Email</th>
                <th>Username</th>
                <th>Status</th>
                <th>Verified</th>
                <th>Role</th>
              </tr>
            </thead>
            <tbody>
              {users.map((u) => {
                const isSelf = me?.id === u.id;
                return (
                  <tr key={u.id}>
                    <td>{u.email}</td>
                    <td>{u.user_name}</td>
                    <td>{u.status}</td>
                    <td>{u.verified ? "Yes" : "No"}</td>
                    <td>
                      <select
                        className="admin-role-select"
                        value={u.role}
                        disabled={isSelf || savingId === u.id}
                        title={isSelf ? "You cannot change your own role" : undefined}
                        onChange={(e) => changeRole(u.id, e.target.value)}
                      >
                        {ALL_ROLES.map((r) => (
                          <option key={r} value={r}>{r}</option>
                        ))}
                      </select>
                      {isSelf && <span className="admin-role-self"> (you)</span>}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
        <div className="button-row" style={{ marginTop: "var(--space-4)" }}>
          <button className="sg-btn sg-btn--outline sg-btn--sm" disabled={page <= 1} onClick={() => setPage(page - 1)}>Prev</button>
          <span className="sg-navbar__user" style={{ alignSelf: "center" }}>Page {page}</span>
          <button className="sg-btn sg-btn--outline sg-btn--sm" disabled={users.length < 50} onClick={() => setPage(page + 1)}>Next</button>
        </div>
      </main>
    </div>
  );
}
