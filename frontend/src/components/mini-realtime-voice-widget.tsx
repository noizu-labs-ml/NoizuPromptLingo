"use client";

import { useMemo, useState } from "react";
import { api, type VoiceApprovalScriptResponse } from "@/lib/api";

type Status = "idle" | "mic-ready" | "unsupported" | "denied" | "preparing" | "ready" | "error";

interface MiniRealtimeVoiceWidgetProps {
  orgId: string;
  projectId?: string | null;
  className?: string;
}

const TICKET_TYPES = [
  { value: "task", label: "Task" },
  { value: "bug", label: "Bug" },
  { value: "story", label: "Story" },
  { value: "epic", label: "Epic" },
];

const STATUS_LABEL: Record<Status, string> = {
  idle: "standby",
  "mic-ready": "mic ready",
  unsupported: "mic unavailable",
  denied: "mic denied",
  preparing: "preparing",
  ready: "approval ready",
  error: "error",
};

export function MiniRealtimeVoiceWidget({ orgId, projectId, className }: MiniRealtimeVoiceWidgetProps) {
  const [status, setStatus] = useState<Status>("idle");
  const [transcript, setTranscript] = useState("");
  const [ticketType, setTicketType] = useState("task");
  const [result, setResult] = useState<VoiceApprovalScriptResponse | null>(null);
  const [error, setError] = useState<string | null>(null);

  const title = useMemo(() => {
    const trimmed = transcript.trim().replace(/\s+/g, " ");
    return trimmed ? trimmed.slice(0, 140) : "";
  }, [transcript]);

  async function primeMicrophone() {
    setError(null);
    if (!navigator.mediaDevices?.getUserMedia) {
      setStatus("unsupported");
      return;
    }

    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      stream.getTracks().forEach((track) => track.stop());
      setStatus("mic-ready");
    } catch {
      setStatus("denied");
    }
  }

  async function prepareApproval() {
    if (!transcript.trim() || status === "preparing") return;
    setStatus("preparing");
    setError(null);

    try {
      const response = await api.prepareVoiceApprovalScript(orgId, {
        transcript,
        title,
        ticket_type: ticketType,
        description: transcript,
        project_id: projectId || undefined,
      });
      setResult(response);
      setStatus("ready");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Could not prepare approval script.");
      setStatus("error");
    }
  }

  return (
    <section className={`dash-panel ${className || ""}`}>
      <div className="dash-panel__head">
        <div>
          <h2 className="dash-panel__title">Realtime voice</h2>
          <span className="dash-panel__hint">approval preview</span>
        </div>
        <span className="dash-badge">{STATUS_LABEL[status]}</span>
      </div>
      <div className="sg-field">
        <label htmlFor="voice-capture">Capture</label>
        <textarea
          id="voice-capture"
          rows={4}
          value={transcript}
          onChange={(event) => {
            setTranscript(event.target.value);
            setResult(null);
            if (status === "ready" || status === "error") setStatus("idle");
          }}
          placeholder="Create a task for the prompt pipeline review."
        />
      </div>
      <div className="sg-field">
        <label htmlFor="voice-ticket-type">Type</label>
        <select id="voice-ticket-type" value={ticketType} onChange={(event) => setTicketType(event.target.value)}>
          {TICKET_TYPES.map((type) => (
            <option key={type.value} value={type.value}>{type.label}</option>
          ))}
        </select>
      </div>
      <div className="project-card__actions">
        <button type="button" className="sg-btn sg-btn--outline" onClick={primeMicrophone}>
          mic
        </button>
        <button type="button" className="sg-btn sg-btn--black" onClick={prepareApproval} disabled={!transcript.trim() || status === "preparing"}>
          approval
        </button>
      </div>
      <div className="project-card__meta" style={{ marginTop: "var(--space-3, 0.75rem)" }}>
        <span className="project-card__status">agent calls off</span>
        <span className="project-card__time">{result ? "script ready" : "script pending"}</span>
      </div>
      {error ? <div className="sg-error" style={{ marginTop: "var(--space-3, 0.75rem)" }}>{error}</div> : null}
      {result ? (
        <details style={{ marginTop: "var(--space-3, 0.75rem)" }}>
          <summary className="dash-panel__action">approval script</summary>
          <pre style={{ maxHeight: 260, overflow: "auto", whiteSpace: "pre-wrap", marginTop: 8, fontSize: "0.75rem", lineHeight: 1.45 }}>
            {result.approval_script}
          </pre>
        </details>
      ) : null}
    </section>
  );
}
