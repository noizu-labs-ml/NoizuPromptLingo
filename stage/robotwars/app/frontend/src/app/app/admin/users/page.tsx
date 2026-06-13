"use client";

import { useState, useEffect } from "react";
import { api } from "@/lib/api";

interface AdminUser {
  id: string;
  email: string;
  user_name: string;
  status: string;
  verified: boolean;
  admin: boolean;
  created_at: string;
}

export default function AdminUsersPage() {
  const [users, setUsers] = useState<AdminUser[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.adminListUsers(page).then((res) => {
      setUsers(res.users);
      setTotal(res.total);
      setLoading(false);
    }).catch(() => setLoading(false));
  }, [page]);

  if (loading) return <p style={{ padding: 40 }}>Loading...</p>;

  return (
    <div style={{ maxWidth: 800, margin: "40px auto", padding: "0 24px" }}>
      <h1 style={{ fontSize: 24, marginBottom: 8 }}>Users ({total})</h1>
      <table style={{ width: "100%", borderCollapse: "collapse" }}>
        <thead>
          <tr style={{ borderBottom: "2px solid #eee", textAlign: "left" }}>
            <th style={{ padding: 8 }}>Email</th>
            <th style={{ padding: 8 }}>Username</th>
            <th style={{ padding: 8 }}>Status</th>
            <th style={{ padding: 8 }}>Verified</th>
            <th style={{ padding: 8 }}>Admin</th>
          </tr>
        </thead>
        <tbody>
          {users.map((u) => (
            <tr key={u.id} style={{ borderBottom: "1px solid #eee" }}>
              <td style={{ padding: 8 }}>{u.email}</td>
              <td style={{ padding: 8 }}>{u.user_name}</td>
              <td style={{ padding: 8 }}>{u.status}</td>
              <td style={{ padding: 8 }}>{u.verified ? "Yes" : "No"}</td>
              <td style={{ padding: 8 }}>{u.admin ? "Yes" : "No"}</td>
            </tr>
          ))}
        </tbody>
      </table>
      <div style={{ display: "flex", gap: 8, marginTop: 16 }}>
        <button disabled={page <= 1} onClick={() => setPage(page - 1)} style={{ padding: "4px 12px" }}>Prev</button>
        <span style={{ padding: "4px 8px" }}>Page {page}</span>
        <button disabled={users.length < 50} onClick={() => setPage(page + 1)} style={{ padding: "4px 12px" }}>Next</button>
      </div>
    </div>
  );
}
