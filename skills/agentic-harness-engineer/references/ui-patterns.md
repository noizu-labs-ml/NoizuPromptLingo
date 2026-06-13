# UI Patterns for Agentic Systems

Architecture and component patterns for chat interfaces, admin dashboards, streaming responses, reasoning display, and multi-agent visualization.

## Component Architecture

```
AgentUI
├── ChatInterface/          — User-facing conversation view
│   ├── MessageList         — Rendered message history
│   ├── MessageItem         — Individual message (user/assistant/tool)
│   ├── ThinkingIndicator   — In-progress reasoning display
│   ├── ToolCallCard        — Expandable tool invocation detail
│   └── InputBar            — Text input + submit
├── AdminDashboard/         — Operator view
│   ├── SessionTable        — Live sessions with cost/status
│   ├── AgentGraph          — Multi-agent topology visualization
│   ├── CostMeter           — Real-time spend tracking
│   ├── GuardLog            — Security event feed
│   └── ApprovalQueue       — Human-in-the-loop tool approvals
└── shared/
    ├── StreamingText        — SSE/WebSocket rendered text
    ├── TokenCounter         — Input/output token display
    └── StatusBadge         — Agent lifecycle status
```

---

## Web: Streaming Chat Interface (React/Next.js)

### Streaming Text Component

```tsx
"use client";
import { useEffect, useRef, useState } from "react";

interface StreamingTextProps {
  streamUrl: string;
  onComplete?: (text: string) => void;
  onToolCall?: (toolCall: ToolCall) => void;
}

interface StreamEvent {
  type: "text_delta" | "tool_call" | "thinking" | "done" | "error";
  delta?: string;
  toolCall?: ToolCall;
  thinking?: string;
  error?: string;
}

export function StreamingText({ streamUrl, onComplete, onToolCall }: StreamingTextProps) {
  const [text, setText] = useState("");
  const [thinking, setThinking] = useState<string | null>(null);
  const [toolCalls, setToolCalls] = useState<ToolCall[]>([]);
  const [status, setStatus] = useState<"idle" | "streaming" | "done" | "error">("idle");
  const abortRef = useRef<AbortController | null>(null);

  useEffect(() => {
    const controller = new AbortController();
    abortRef.current = controller;
    setStatus("streaming");

    (async () => {
      const res = await fetch(streamUrl, { signal: controller.signal });
      if (!res.body) return;

      const reader = res.body.getReader();
      const decoder = new TextDecoder();
      let buffer = "";

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split("\n");
        buffer = lines.pop() ?? "";

        for (const line of lines) {
          if (!line.startsWith("data: ")) continue;
          const json = line.slice(6).trim();
          if (json === "[DONE]") { setStatus("done"); continue; }

          try {
            const event: StreamEvent = JSON.parse(json);
            switch (event.type) {
              case "text_delta":
                setText((prev) => prev + (event.delta ?? ""));
                break;
              case "thinking":
                setThinking(event.thinking ?? null);
                break;
              case "tool_call":
                if (event.toolCall) {
                  setToolCalls((prev) => [...prev, event.toolCall!]);
                  onToolCall?.(event.toolCall);
                }
                break;
              case "done":
                setStatus("done");
                break;
              case "error":
                setStatus("error");
                break;
            }
          } catch { /* malformed event */ }
        }
      }
    })().catch(() => setStatus("error"));

    return () => controller.abort();
  }, [streamUrl]);

  return (
    <div className="agent-response">
      {thinking && <ThinkingBlock content={thinking} />}
      {toolCalls.map((tc, i) => <ToolCallCard key={i} toolCall={tc} />)}
      <div className="response-text">
        {text}
        {status === "streaming" && <span className="cursor-blink">▋</span>}
      </div>
    </div>
  );
}
```

### Thinking / Reasoning Display

```tsx
interface ThinkingBlockProps {
  content: string;
  defaultOpen?: boolean;
}

export function ThinkingBlock({ content, defaultOpen = false }: ThinkingBlockProps) {
  const [open, setOpen] = useState(defaultOpen);

  return (
    <details open={open} className="thinking-block" onToggle={(e) => setOpen(e.currentTarget.open)}>
      <summary className="thinking-summary">
        <span className="thinking-icon">💭</span>
        <span>Reasoning</span>
        <span className="thinking-length">{content.split(" ").length} words</span>
      </summary>
      <pre className="thinking-content">{content}</pre>
    </details>
  );
}
```

### Tool Call Card

```tsx
interface ToolCallCardProps {
  toolCall: ToolCall;
  result?: unknown;
  pending?: boolean;
}

export function ToolCallCard({ toolCall, result, pending }: ToolCallCardProps) {
  const [expanded, setExpanded] = useState(false);

  return (
    <div className={`tool-card ${pending ? "tool-card--pending" : "tool-card--done"}`}>
      <button className="tool-card-header" onClick={() => setExpanded(!expanded)}>
        <span className="tool-icon">{pending ? "⏳" : "✓"}</span>
        <span className="tool-name">{toolCall.name}</span>
        <span className="tool-expand">{expanded ? "▲" : "▼"}</span>
      </button>
      {expanded && (
        <div className="tool-card-body">
          <div className="tool-section">
            <h4>Input</h4>
            <pre>{JSON.stringify(toolCall.parameters, null, 2)}</pre>
          </div>
          {result !== undefined && (
            <div className="tool-section">
              <h4>Output</h4>
              <pre>{JSON.stringify(result, null, 2)}</pre>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
```

---

## Web: Admin Dashboard

### Session Table

```tsx
interface AgentSession {
  sessionId: string;
  userId: string;
  agentId: string;
  status: "active" | "idle" | "error" | "complete";
  startedAt: number;
  turnCount: number;
  totalTokens: number;
  totalCostUsd: number;
}

export function SessionTable({ sessions }: { sessions: AgentSession[] }) {
  return (
    <table className="session-table">
      <thead>
        <tr>
          <th>Session</th>
          <th>User</th>
          <th>Status</th>
          <th>Turns</th>
          <th>Tokens</th>
          <th>Cost (USD)</th>
          <th>Duration</th>
        </tr>
      </thead>
      <tbody>
        {sessions.map((s) => (
          <tr key={s.sessionId} className={`session-row session-row--${s.status}`}>
            <td><code>{s.sessionId.slice(0, 8)}</code></td>
            <td>{s.userId}</td>
            <td><StatusBadge status={s.status} /></td>
            <td>{s.turnCount}</td>
            <td>{s.totalTokens.toLocaleString()}</td>
            <td>${s.totalCostUsd.toFixed(4)}</td>
            <td>{formatDuration(Date.now() - s.startedAt)}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}

function formatDuration(ms: number): string {
  if (ms < 60_000) return `${Math.round(ms / 1000)}s`;
  return `${Math.round(ms / 60_000)}m`;
}
```

### Tool Approval Workflow (Human-in-the-Loop)

```tsx
interface PendingApproval {
  id: string;
  sessionId: string;
  userId: string;
  toolName: string;
  parameters: Record<string, unknown>;
  riskLevel: "low" | "medium" | "high" | "critical";
  expiresAt: number;
}

export function ApprovalQueue({
  approvals,
  onApprove,
  onDeny,
}: {
  approvals: PendingApproval[];
  onApprove: (id: string) => void;
  onDeny: (id: string, reason: string) => void;
}) {
  return (
    <div className="approval-queue">
      <h2>Pending Approvals ({approvals.length})</h2>
      {approvals.map((a) => (
        <div key={a.id} className={`approval-card approval-card--${a.riskLevel}`}>
          <div className="approval-header">
            <span className="approval-tool">{a.toolName}</span>
            <span className="approval-risk">{a.riskLevel.toUpperCase()}</span>
            <span className="approval-expiry">
              Expires in {Math.round((a.expiresAt - Date.now()) / 1000)}s
            </span>
          </div>
          <pre className="approval-params">{JSON.stringify(a.parameters, null, 2)}</pre>
          <div className="approval-actions">
            <button className="btn-approve" onClick={() => onApprove(a.id)}>Approve</button>
            <button className="btn-deny" onClick={() => onDeny(a.id, "Rejected by operator")}>Deny</button>
          </div>
        </div>
      ))}
    </div>
  );
}
```

---

## Multi-Agent Visualization

Use a directed graph to show agent topology, message flow, and current state.

```tsx
// Lightweight adjacency-list graph renderer using SVG
interface AgentNode {
  id: string;
  label: string;
  status: "idle" | "running" | "waiting" | "done" | "error";
  x: number;
  y: number;
}

interface AgentEdge {
  from: string;
  to: string;
  label?: string;
  active?: boolean;
}

export function AgentGraph({ nodes, edges }: { nodes: AgentNode[]; edges: AgentEdge[] }) {
  const nodeMap = new Map(nodes.map((n) => [n.id, n]));

  return (
    <svg className="agent-graph" viewBox="0 0 800 600">
      {edges.map((e, i) => {
        const from = nodeMap.get(e.from)!;
        const to = nodeMap.get(e.to)!;
        return (
          <g key={i} className={`edge ${e.active ? "edge--active" : ""}`}>
            <line x1={from.x} y1={from.y} x2={to.x} y2={to.y} />
            {e.label && <text x={(from.x + to.x) / 2} y={(from.y + to.y) / 2}>{e.label}</text>}
          </g>
        );
      })}
      {nodes.map((n) => (
        <g key={n.id} className={`node node--${n.status}`} transform={`translate(${n.x},${n.y})`}>
          <circle r={30} />
          <text textAnchor="middle" dy="5">{n.label}</text>
        </g>
      ))}
    </svg>
  );
}
```

---

## Terminal UI with Ink (Node.js)

```tsx
// ink-agent-monitor.tsx — live terminal dashboard
import React, { useState, useEffect } from "react";
import { render, Box, Text, useInput } from "ink";

interface AgentStatus {
  id: string;
  status: string;
  tokens: number;
  costUsd: number;
}

function AgentMonitor({ agents }: { agents: AgentStatus[] }) {
  const [selected, setSelected] = useState(0);

  useInput((input, key) => {
    if (key.upArrow) setSelected((s) => Math.max(0, s - 1));
    if (key.downArrow) setSelected((s) => Math.min(agents.length - 1, s + 1));
  });

  return (
    <Box flexDirection="column" borderStyle="round" padding={1}>
      <Box marginBottom={1}>
        <Text bold>Agent Monitor</Text>
      </Box>
      {agents.map((a, i) => (
        <Box key={a.id} backgroundColor={i === selected ? "blue" : undefined}>
          <Text color={a.status === "error" ? "red" : a.status === "running" ? "green" : "white"}>
            {a.status === "running" ? "▶" : a.status === "error" ? "✗" : "○"}{" "}
          </Text>
          <Text>{a.id.slice(0, 12).padEnd(14)}</Text>
          <Text color="yellow">{a.status.padEnd(10)}</Text>
          <Text color="cyan">{a.tokens.toLocaleString().padStart(10)} tok</Text>
          <Text color="magenta">${a.costUsd.toFixed(4).padStart(8)}</Text>
        </Box>
      ))}
      <Box marginTop={1}>
        <Text dimColor>↑↓ navigate  q quit</Text>
      </Box>
    </Box>
  );
}
```
