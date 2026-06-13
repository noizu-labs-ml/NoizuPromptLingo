"use client";

import { useState, useEffect, useCallback } from "react";
import { useSession } from "next-auth/react";

export default function SettingsPage() {
  const { data: session } = useSession();
  const [keys, setKeys] = useState([]);
  const [tokens, setTokens] = useState({});
  const [newKey, setNewKey] = useState(null);
  const [label, setLabel] = useState("");
  const [loading, setLoading] = useState(false);
  const [copied, setCopied] = useState(null);

  const fetchKeys = useCallback(async () => {
    const res = await fetch("/api/keys");
    if (res.ok) { const data = await res.json(); setKeys(data.keys || []); }
  }, []);

  const fetchToken = useCallback(async (keyId) => {
    const res = await fetch("/api/mcp-token", {
      method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ keyId }),
    });
    if (res.ok) { const data = await res.json(); setTokens(prev => ({ ...prev, [keyId]: data })); }
  }, []);

  useEffect(() => { if (session) fetchKeys(); }, [session, fetchKeys]);
  useEffect(() => { keys.forEach(k => { if (!tokens[k.id]) fetchToken(k.id); }); }, [keys, tokens, fetchToken]);

  async function generateKey(e) {
    e.preventDefault();
    setLoading(true); setNewKey(null);
    const res = await fetch("/api/keys", {
      method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ label: label || "default" }),
    });
    if (res.ok) { const data = await res.json(); setNewKey(data.key); setLabel(""); fetchKeys(); }
    setLoading(false);
  }

  async function revokeKey(keyId) {
    await fetch("/api/keys", {
      method: "DELETE", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ keyId }),
    });
    setTokens(prev => { const n = { ...prev }; delete n[keyId]; return n; });
    fetchKeys();
  }

  function copy(text, id) {
    navigator.clipboard.writeText(text);
    setCopied(id);
    setTimeout(() => setCopied(null), 2000);
  }

  const s = {
    card: { background: "var(--bg-1)", border: "1px solid var(--border)", borderRadius: "var(--radius-lg)", padding: 20, marginBottom: 12 },
    input: { background: "var(--bg-2)", border: "1px solid var(--border)", borderRadius: "var(--radius-sm)", padding: "8px 12px", fontSize: 13, color: "var(--text-0)", fontFamily: "var(--font)", outline: "none", flex: 1 },
    btn: { padding: "8px 14px", borderRadius: "var(--radius-sm)", fontSize: 13, fontWeight: 500, cursor: "pointer", border: "1px solid var(--accent)", background: "var(--accent)", color: "white", fontFamily: "var(--font)" },
    btnSm: { padding: "4px 10px", fontSize: 11, borderRadius: 4, border: "1px solid var(--border)", background: "var(--bg-2)", color: "var(--text-1)", cursor: "pointer", fontFamily: "var(--font)" },
    mono: { fontFamily: "var(--font-mono)", fontSize: 12 },
    warn: { padding: 12, background: "var(--yellow-dim)", border: "1px solid var(--yellow)", borderRadius: "var(--radius-sm)", marginBottom: 12, fontSize: 12, wordBreak: "break-all" },
  };

  return (
    <div>
      <h1 style={{ fontSize: 22, fontWeight: 600, marginBottom: 24, letterSpacing: "-0.02em" }}>Sessions & API Keys</h1>

      <form onSubmit={generateKey} style={{ display: "flex", gap: 8, marginBottom: 16 }}>
        <input type="text" value={label} onChange={e => setLabel(e.target.value)} placeholder="Key label" style={s.input} />
        <button type="submit" disabled={loading} style={s.btn}>{loading ? "..." : "Generate Key"}</button>
      </form>

      {newKey && <div style={s.warn}><strong>Save this key:</strong> <code>{newKey}</code></div>}

      {keys.map(k => (
        <div key={k.id} style={s.card}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 8 }}>
            <div>
              <strong>{k.label}</strong>
              <span style={{ color: "var(--text-3)", marginLeft: 8, ...s.mono }}>{k.key_prefix}...</span>
            </div>
            <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
              <span style={{ fontSize: 11, color: "var(--text-3)" }}>
                Created {new Date(k.created_at).toLocaleDateString()}
              </span>
              <button onClick={() => revokeKey(k.id)} style={{ ...s.btnSm, color: "var(--red)", borderColor: "var(--red)" }}>Revoke</button>
            </div>
          </div>
          {tokens[k.id] ? (
            <div style={{ background: "var(--bg-2)", borderRadius: "var(--radius-sm)", padding: 12 }}>
              <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 4 }}>
                <span style={{ fontSize: 11, fontWeight: 600, color: "var(--text-2)" }}>MCP Token</span>
                <button onClick={() => copy(tokens[k.id].token, k.id)} style={s.btnSm}>
                  {copied === k.id ? "Copied!" : "Copy"}
                </button>
              </div>
              <pre style={{ margin: 0, ...s.mono, color: "var(--text-1)", wordBreak: "break-all", whiteSpace: "pre-wrap" }}>
                {tokens[k.id].token}
              </pre>
              <div style={{ fontSize: 10, color: "var(--text-3)", marginTop: 4 }}>
                Expires {new Date(tokens[k.id].expires_at).toLocaleDateString()}
              </div>
            </div>
          ) : (
            <div style={{ color: "var(--text-3)", fontSize: 12 }}>Loading token...</div>
          )}
        </div>
      ))}
      {keys.length === 0 && <div style={{ color: "var(--text-3)", fontSize: 14 }}>No API keys yet.</div>}
    </div>
  );
}
