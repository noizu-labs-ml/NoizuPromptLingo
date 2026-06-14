"use client";

import { useState, useEffect, useCallback } from "react";
import { useSession } from "next-auth/react";

const MCP_SERVERS = [
  { id: "root",      label: "Root MCP",    host: "tobor.locker",            required: true,  desc: "Core tools, NPL, discovery" },
  { id: "sessions",  label: "Sessions",    host: "sessions.tobor.locker",   required: true,  desc: "Session management" },
  { id: "tickets",   label: "Tickets",     host: "tickets.tobor.locker",    required: false, desc: "Task & ticket tracking" },
  { id: "projects",  label: "Projects",    host: "projects.tobor.locker",   required: false, desc: "Project management" },
  { id: "assets",    label: "Assets",      host: "assets.tobor.locker",     required: false, desc: "Media asset lifecycle" },
  { id: "artifacts", label: "Artifacts",   host: "artifacts.tobor.locker",  required: false, desc: "Versioned content storage" },
  { id: "chat",      label: "Chat",        host: "chat.tobor.locker",       required: false, desc: "Chat rooms & messages" },
  { id: "review",    label: "Review",      host: "review.tobor.locker",     required: false, desc: "Artifact review & overlays" },
  { id: "wiki",      label: "Wiki",        host: "wiki.tobor.locker",       required: false, desc: "Wiki spaces & pages" },
];

function SetupPanel({ token, keyLabel, onClose }) {
  const [enabled, setEnabled] = useState(() => {
    const state = {};
    MCP_SERVERS.forEach(s => { state[s.id] = true; });
    return state;
  });
  const [copiedCmd, setCopiedCmd] = useState(null);

  function toggle(id) {
    const server = MCP_SERVERS.find(s => s.id === id);
    if (server?.required) return;
    setEnabled(prev => ({ ...prev, [id]: !prev[id] }));
  }

  function getCommandLine(server) {
    return `claude mcp add --transport streamable-http tobor-${server.id} https://${server.host}/mcp --header "Authorization: Bearer $AUTH_TOKEN"`;
  }

  function buildScript() {
    const lines = [`AUTH_TOKEN=${token}`, ""];
    MCP_SERVERS.filter(s => enabled[s.id]).forEach(s => {
      lines.push(getCommandLine(s));
    });
    return lines.join("\n");
  }

  function copyScript() {
    navigator.clipboard.writeText(buildScript());
    setCopiedCmd("script");
    setTimeout(() => setCopiedCmd(null), 2000);
  }

  const activeCount = MCP_SERVERS.filter(s => enabled[s.id]).length;

  return (
    <div style={{ background: "var(--bg-2)", borderRadius: "var(--radius-md)", padding: 16, marginTop: 12, border: "1px solid var(--border)" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}>
        <span style={{ fontSize: 13, fontWeight: 600 }}>MCP Setup — {keyLabel}</span>
        <div style={{ display: "flex", gap: 8 }}>
          <button onClick={onClose} style={btnSm}>Close</button>
        </div>
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap: 6, marginBottom: 16 }}>
        {MCP_SERVERS.map(s => (
          <label
            key={s.id}
            style={{
              display: "flex", alignItems: "center", gap: 8,
              padding: "6px 10px", borderRadius: 6,
              background: enabled[s.id] ? "var(--accent-dim)" : "var(--bg-3)",
              border: `1px solid ${enabled[s.id] ? "var(--accent)" : "var(--border)"}`,
              cursor: s.required ? "default" : "pointer",
              fontSize: 12,
            }}
          >
            <input
              type="checkbox"
              checked={enabled[s.id]}
              onChange={() => toggle(s.id)}
              disabled={s.required}
              style={{ accentColor: "var(--accent)" }}
            />
            <div>
              <div style={{ fontWeight: 500, color: enabled[s.id] ? "var(--text-0)" : "var(--text-3)" }}>
                {s.label}
                {s.required && <span style={{ fontSize: 9, color: "var(--text-3)", marginLeft: 4 }}>required</span>}
              </div>
              <div style={{ fontSize: 10, color: "var(--text-3)" }}>{s.desc}</div>
            </div>
          </label>
        ))}
      </div>

      <div style={{ position: "relative" }}>
        <button
          onClick={copyScript}
          style={{
            ...btnSm,
            position: "absolute", top: 8, right: 8, zIndex: 1,
            ...(copiedCmd === "script" ? { background: "var(--green-dim)", color: "var(--green)", borderColor: "var(--green)" } : {})
          }}
        >
          {copiedCmd === "script" ? "Copied!" : `Copy (${activeCount})`}
        </button>
        <pre style={{
          margin: 0, padding: 16, paddingRight: 80,
          background: "var(--bg-3)", borderRadius: "var(--radius-sm)",
          fontFamily: "var(--font-mono)", fontSize: 12, lineHeight: 1.7,
          color: "var(--text-1)", overflowX: "auto", whiteSpace: "pre-wrap",
          wordBreak: "break-all",
        }}>
          {buildScript()}
        </pre>
      </div>
    </div>
  );
}

const btnSm = { padding: "4px 10px", fontSize: 11, borderRadius: 4, border: "1px solid var(--border)", background: "var(--bg-2)", color: "var(--text-1)", cursor: "pointer", fontFamily: "var(--font)" };

export default function SettingsPage() {
  const { data: session } = useSession();
  const [keys, setKeys] = useState([]);
  const [tokens, setTokens] = useState({});
  const [newKey, setNewKey] = useState(null);
  const [label, setLabel] = useState("");
  const [loading, setLoading] = useState(false);
  const [copied, setCopied] = useState(null);
  const [setupKey, setSetupKey] = useState(null);

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
    setSetupKey(prev => prev === keyId ? null : prev);
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
              <button
                onClick={() => setSetupKey(setupKey === k.id ? null : k.id)}
                style={{ ...btnSm, ...(setupKey === k.id ? { background: "var(--accent-dim)", color: "var(--accent)", borderColor: "var(--accent)" } : {}) }}
              >
                Setup
              </button>
              <button onClick={() => revokeKey(k.id)} style={{ ...btnSm, color: "var(--red)", borderColor: "var(--red)" }}>Revoke</button>
            </div>
          </div>

          {tokens[k.id] ? (
            <div style={{ background: "var(--bg-2)", borderRadius: "var(--radius-sm)", padding: 12 }}>
              <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 4 }}>
                <span style={{ fontSize: 11, fontWeight: 600, color: "var(--text-2)" }}>MCP Token</span>
                <button onClick={() => copy(tokens[k.id].token, k.id)} style={btnSm}>
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

          {setupKey === k.id && tokens[k.id] && (
            <SetupPanel
              token={tokens[k.id].token}
              keyLabel={k.label}
              onClose={() => setSetupKey(null)}
            />
          )}
        </div>
      ))}
      {keys.length === 0 && <div style={{ color: "var(--text-3)", fontSize: 14 }}>No API keys yet.</div>}
    </div>
  );
}
