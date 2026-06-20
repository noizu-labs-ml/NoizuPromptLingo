'use client';

import { useState } from 'react';
import { toast } from 'sonner';
import type { McpServerConfig } from '@/lib/api';

interface McpSetupPanelProps {
  token: string; // The MCP JWT token
  keyLabel: string; // Label of the API key
  servers: McpServerConfig[]; // Servers + URLs from backend config endpoint
  onClose: () => void;
}

/**
 * Generates `claude mcp add` commands for the given MCP servers.
 *
 * Commands are generated in the format:
 *   AUTH_TOKEN=...
 *   claude mcp add --transport streamable-http tobor-{id} {url} --header "Authorization: Bearer $AUTH_TOKEN"
 *
 * Server URLs come from the backend config endpoint (host-derived), so this
 * component never hardcodes a host.
 */
export default function McpSetupPanel({ token, keyLabel, servers, onClose }: McpSetupPanelProps) {
  const [enabled, setEnabled] = useState<Record<string, boolean>>(() => {
    const state: Record<string, boolean> = {};
    servers.forEach((s) => { state[s.id] = true; });
    return state;
  });
  const [copiedCmd, setCopiedCmd] = useState<string | null>(null);

  function toggle(id: string) {
    const server = servers.find((s) => s.id === id);
    if (server?.required) return;
    setEnabled((prev) => ({ ...prev, [id]: !prev[id] }));
  }

  function getCommandLine(server: McpServerConfig) {
    return `claude mcp add --transport streamable-http tobor-${server.id} ${server.url} --header "Authorization: Bearer $AUTH_TOKEN"`;
  }

  function buildScript() {
    const lines = [`AUTH_TOKEN=${token}`, ""];
    servers.filter((s) => enabled[s.id]).forEach((s) => {
      lines.push(getCommandLine(s));
    });
    return lines.join("\n");
  }

  async function copyScript() {
    try {
      await navigator.clipboard.writeText(buildScript());
      setCopiedCmd("script");
      setTimeout(() => setCopiedCmd(null), 2000);
      toast.success('Copied to clipboard');
    } catch {
      toast.error('Copy failed — select and copy manually');
    }
  }

  const activeCount = servers.filter((s) => enabled[s.id]).length;

  return (
    <div style={{
      background: "var(--bg-2)",
      borderRadius: "var(--radius-md)",
      padding: 16,
      marginTop: 12,
      border: "1px solid var(--border)"
    }}>
      <div style={{
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
        marginBottom: 12
      }}>
        <span style={{ fontSize: 13, fontWeight: 600 }}>MCP Setup — {keyLabel}</span>
        <div style={{ display: "flex", gap: 8 }}>
          <button onClick={onClose} style={btnSm}>Close</button>
        </div>
      </div>

      <div style={{
        display: "grid",
        gridTemplateColumns: "repeat(auto-fill, minmax(250px, 1fr))",
        gap: 6,
        marginBottom: 16
      }}>
        {servers.map((s) => (
          <label
            key={s.id}
            style={{
              display: "flex",
              alignItems: "center",
              gap: 8,
              padding: "6px 10px",
              borderRadius: 6,
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
              <div style={{
                fontWeight: 500,
                color: enabled[s.id] ? "var(--text-0)" : "var(--text-3)"
              }}>
                {s.label}
                {s.required && (
                  <span style={{ fontSize: 9, color: "var(--text-3)", marginLeft: 4 }}>
                    required
                  </span>
                )}
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
            position: "absolute",
            top: 8,
            right: 8,
            zIndex: 1,
            ...(copiedCmd === "script"
              ? { background: "var(--green-dim)", color: "var(--green)", borderColor: "var(--green)" }
              : {})
          }}
        >
          {copiedCmd === "script" ? "Copied!" : `Copy (${activeCount})`}
        </button>
        <pre style={{
          margin: 0,
          padding: 16,
          paddingRight: 80,
          background: "var(--bg-3)",
          borderRadius: "var(--radius-sm)",
          fontFamily: "monospace",
          fontSize: 12,
          lineHeight: 1.7,
          color: "var(--text-1)",
          overflowX: "auto",
          whiteSpace: "pre-wrap",
          wordBreak: "break-all",
        }}>
          {buildScript()}
        </pre>
      </div>
    </div>
  );
}

const btnSm = {
  padding: "4px 10px",
  fontSize: 11,
  borderRadius: 4,
  border: "1px solid var(--border)",
  background: "var(--bg-2)",
  color: "var(--text-1)",
  cursor: "pointer",
  fontFamily: "var(--font)"
};
