"use client";

import { useState, useEffect, useCallback } from "react";
import { useSession, signOut } from "next-auth/react";

export default function Home() {
  const { data: session } = useSession();
  const [keys, setKeys] = useState([]);
  const [tokens, setTokens] = useState({});
  const [newKey, setNewKey] = useState(null);
  const [label, setLabel] = useState("");
  const [loading, setLoading] = useState(false);
  const [copied, setCopied] = useState(null);

  const [mcpKey, setMcpKey] = useState("");
  const [name, setName] = useState("");
  const [greeting, setGreeting] = useState(null);
  const [error, setError] = useState(null);
  const [mcpSessionId, setMcpSessionId] = useState(null);

  const fetchKeys = useCallback(async () => {
    const res = await fetch("/api/keys");
    if (res.ok) {
      const data = await res.json();
      setKeys(data.keys || []);
    }
  }, []);

  const fetchToken = useCallback(async (keyId) => {
    const res = await fetch("/api/mcp-token", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ keyId }),
    });
    if (res.ok) {
      const data = await res.json();
      setTokens((prev) => ({ ...prev, [keyId]: data }));
    }
  }, []);

  useEffect(() => {
    if (session) fetchKeys();
  }, [session, fetchKeys]);

  useEffect(() => {
    keys.forEach((k) => {
      if (!tokens[k.id]) fetchToken(k.id);
    });
  }, [keys, tokens, fetchToken]);

  async function generateKey(e) {
    e.preventDefault();
    setLoading(true);
    setNewKey(null);
    const res = await fetch("/api/keys", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ label: label || "default" }),
    });
    if (res.ok) {
      const data = await res.json();
      setNewKey(data.key);
      setLabel("");
      fetchKeys();
    }
    setLoading(false);
  }

  async function revokeKey(keyId) {
    await fetch("/api/keys", {
      method: "DELETE",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ keyId }),
    });
    setTokens((prev) => {
      const next = { ...prev };
      delete next[keyId];
      return next;
    });
    fetchKeys();
  }

  function copyToClipboard(text, id) {
    navigator.clipboard.writeText(text);
    setCopied(id);
    setTimeout(() => setCopied(null), 2000);
  }

  function mcpHeaders(sid) {
    const h = { "Content-Type": "application/json" };
    if (mcpKey) h["Authorization"] = `Bearer ${mcpKey}`;
    if (sid) h["mcp-session-id"] = sid;
    return h;
  }

  async function initialize() {
    const res = await fetch("/mcp", {
      method: "POST",
      headers: mcpHeaders(null),
      body: JSON.stringify({
        jsonrpc: "2.0",
        id: 1,
        method: "initialize",
        params: {
          protocolVersion: "2025-03-26",
          capabilities: {},
          clientInfo: { name: "hello-world-web", version: "0.1.0" },
        },
      }),
    });
    if (!res.ok) throw new Error(await res.text());
    const sid = res.headers.get("mcp-session-id");
    if (sid) setMcpSessionId(sid);
    await res.json();
    await fetch("/mcp", {
      method: "POST",
      headers: mcpHeaders(sid),
      body: JSON.stringify({ jsonrpc: "2.0", method: "notifications/initialized" }),
    });
    return sid;
  }

  async function handleGreet(e) {
    e.preventDefault();
    setError(null);
    setGreeting(null);
    try {
      let sid = mcpSessionId;
      if (!sid) sid = await initialize();
      const res = await fetch("/mcp", {
        method: "POST",
        headers: mcpHeaders(sid),
        body: JSON.stringify({
          jsonrpc: "2.0",
          id: 2,
          method: "tools/call",
          params: { name: "greet", arguments: { name } },
        }),
      });
      const data = await res.json();
      if (data.result?.content?.[0]?.text) setGreeting(data.result.content[0].text);
      else if (data.error) setError(data.error.message || JSON.stringify(data.error));
    } catch (err) {
      setError(err.message);
    }
  }

  return (
    <main style={{ maxWidth: 750, margin: "3rem auto", fontFamily: "system-ui, sans-serif", padding: "0 1rem" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <h1 style={{ margin: 0 }}>Tobor Locker</h1>
        {session && (
          <div style={{ fontSize: "0.9rem", textAlign: "right" }}>
            <div>{session.user?.name || session.user?.email}</div>
            <button onClick={() => signOut()} style={{ padding: "0.25rem 0.5rem", fontSize: "0.8rem", cursor: "pointer", marginTop: "0.25rem" }}>
              Sign out
            </button>
          </div>
        )}
      </div>
      <p style={{ color: "#666" }}>MCP server with API key + user identity authentication.</p>

      <section style={{ marginTop: "2rem" }}>
        <h2>MCP API Keys</h2>
        <form onSubmit={generateKey} style={{ display: "flex", gap: "0.5rem", marginBottom: "1rem" }}>
          <input
            type="text"
            value={label}
            onChange={(e) => setLabel(e.target.value)}
            placeholder="Key label (optional)"
            style={{ padding: "0.5rem", fontSize: "0.9rem", flex: 1 }}
          />
          <button type="submit" disabled={loading} style={{ padding: "0.5rem 1rem", fontSize: "0.9rem" }}>
            {loading ? "..." : "Generate Key"}
          </button>
        </form>

        {newKey && (
          <div style={{ padding: "1rem", background: "#fffbe6", border: "1px solid #f5c518", borderRadius: 8, marginBottom: "1rem", wordBreak: "break-all" }}>
            <strong>Raw API key (save if needed):</strong>
            <pre style={{ margin: "0.5rem 0 0", fontSize: "0.85rem", fontFamily: "monospace" }}>{newKey}</pre>
          </div>
        )}

        {keys.length > 0 ? (
          <div>
            {keys.map((k) => (
              <div key={k.id} style={{ border: "1px solid #ddd", borderRadius: 8, padding: "1rem", marginBottom: "1rem" }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "0.5rem" }}>
                  <div>
                    <strong>{k.label}</strong>
                    <span style={{ color: "#999", marginLeft: "0.75rem", fontFamily: "monospace", fontSize: "0.85rem" }}>{k.key_prefix}...</span>
                  </div>
                  <div style={{ fontSize: "0.8rem", color: "#999" }}>
                    Created {new Date(k.created_at).toLocaleDateString()}
                    {k.last_used_at && <> · Last used {new Date(k.last_used_at).toLocaleDateString()}</>}
                    <button
                      onClick={() => revokeKey(k.id)}
                      style={{ marginLeft: "0.75rem", fontSize: "0.8rem", color: "#c00", cursor: "pointer", background: "none", border: "none" }}
                    >
                      Revoke
                    </button>
                  </div>
                </div>

                {tokens[k.id] ? (
                  <div style={{ background: "#f8f9fa", borderRadius: 6, padding: "0.75rem" }}>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "0.25rem" }}>
                      <span style={{ fontSize: "0.8rem", fontWeight: 600 }}>MCP Token (for Claude Code)</span>
                      <div style={{ display: "flex", gap: "0.5rem" }}>
                        <button
                          onClick={() => copyToClipboard(tokens[k.id].token, k.id)}
                          style={{ fontSize: "0.75rem", padding: "0.2rem 0.5rem", cursor: "pointer" }}
                        >
                          {copied === k.id ? "Copied!" : "Copy"}
                        </button>
                        <button
                          onClick={() => { setTokens((p) => { const n = {...p}; delete n[k.id]; return n; }); fetchToken(k.id); }}
                          style={{ fontSize: "0.75rem", padding: "0.2rem 0.5rem", cursor: "pointer" }}
                        >
                          Regenerate
                        </button>
                      </div>
                    </div>
                    <pre style={{ margin: 0, fontSize: "0.75rem", fontFamily: "monospace", wordBreak: "break-all", whiteSpace: "pre-wrap", color: "#333" }}>
                      {tokens[k.id].token}
                    </pre>
                    <div style={{ fontSize: "0.7rem", color: "#999", marginTop: "0.25rem" }}>
                      Expires {new Date(tokens[k.id].expires_at).toLocaleDateString()}
                    </div>
                  </div>
                ) : (
                  <div style={{ color: "#999", fontSize: "0.85rem" }}>Loading token...</div>
                )}
              </div>
            ))}
          </div>
        ) : (
          <p style={{ color: "#999" }}>No API keys yet. Generate one above.</p>
        )}
      </section>

      <section style={{ marginTop: "2.5rem", paddingTop: "1.5rem", borderTop: "1px solid #eee" }}>
        <h2>Test MCP</h2>
        <div style={{ marginBottom: "0.75rem" }}>
          <input
            type="text"
            value={mcpKey}
            onChange={(e) => { setMcpKey(e.target.value); setMcpSessionId(null); }}
            placeholder="Paste MCP token to test"
            style={{ padding: "0.5rem", fontSize: "0.9rem", width: "100%", fontFamily: "monospace" }}
          />
        </div>
        <form onSubmit={handleGreet} style={{ display: "flex", gap: "0.5rem" }}>
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Enter your name"
            required
            style={{ padding: "0.5rem", fontSize: "0.9rem", flex: 1 }}
          />
          <button type="submit" disabled={!mcpKey} style={{ padding: "0.5rem 1rem", fontSize: "0.9rem" }}>Greet</button>
        </form>
        {greeting && (
          <div style={{ marginTop: "1rem", padding: "1rem", background: "#f0f9f0", borderRadius: 8 }}>{greeting}</div>
        )}
        {error && (
          <div style={{ marginTop: "1rem", padding: "1rem", background: "#fff0f0", borderRadius: 8, color: "#c00" }}>{error}</div>
        )}
      </section>
    </main>
  );
}
