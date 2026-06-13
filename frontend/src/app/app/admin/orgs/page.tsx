"use client";

import { useState, useEffect } from "react";
import { api } from "@/lib/api";

interface AdminOrg {
  id: string;
  slug: string;
  name: string;
  created_at: string;
}

export default function AdminOrgsPage() {
  const [orgs, setOrgs] = useState<AdminOrg[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.adminListOrganizations(page).then((res) => {
      setOrgs(res.organizations);
      setTotal(res.total);
      setLoading(false);
    }).catch(() => setLoading(false));
  }, [page]);

  if (loading) return <p style={{ padding: 40 }}>Loading...</p>;

  return (
    <div style={{ maxWidth: 800, margin: "40px auto", padding: "0 24px" }}>
      <h1 style={{ fontSize: 24, marginBottom: 8 }}>Organizations ({total})</h1>
      <table style={{ width: "100%", borderCollapse: "collapse" }}>
        <thead>
          <tr style={{ borderBottom: "2px solid #eee", textAlign: "left" }}>
            <th style={{ padding: 8 }}>Name</th>
            <th style={{ padding: 8 }}>Slug</th>
            <th style={{ padding: 8 }}>Created</th>
          </tr>
        </thead>
        <tbody>
          {orgs.map((o) => (
            <tr key={o.id} style={{ borderBottom: "1px solid #eee" }}>
              <td style={{ padding: 8 }}>{o.name}</td>
              <td style={{ padding: 8 }}>{o.slug}</td>
              <td style={{ padding: 8 }}>{new Date(o.created_at).toLocaleDateString()}</td>
            </tr>
          ))}
        </tbody>
      </table>
      <div style={{ display: "flex", gap: 8, marginTop: 16 }}>
        <button disabled={page <= 1} onClick={() => setPage(page - 1)} style={{ padding: "4px 12px" }}>Prev</button>
        <span style={{ padding: "4px 8px" }}>Page {page}</span>
        <button disabled={orgs.length < 50} onClick={() => setPage(page + 1)} style={{ padding: "4px 12px" }}>Next</button>
      </div>
    </div>
  );
}
