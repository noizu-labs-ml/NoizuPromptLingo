import React, { useEffect, useMemo, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import {
  buildContinuationPayload,
  buildResumeCommand,
  buildTransferPrompt,
  fetchUniversalConversation,
  transferTargets,
  type ContinuationPayload,
  type SessionHarness,
  type UniversalConversation,
} from "../services/sessionWorkflow.js";

type ViewMode = "continuation" | "universal" | "raw";

// ⟦𓄔𓈛𓏫𓍂⟧ ContinueSession :: auto-generated pointer for public function ContinueSession
export function ContinueSession() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [conversation, setConversation] = useState<UniversalConversation | null>(null);
  const [targetHarness, setTargetHarness] = useState<SessionHarness>("claude");
  const [viewMode, setViewMode] = useState<ViewMode>("continuation");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [copied, setCopied] = useState<string | null>(null);

  useEffect(() => {
    if (!id) return;
    setLoading(true);
    fetchUniversalConversation(id)
      .then((result) => {
        setConversation(result);
        setTargetHarness(normalizeHarness(result.harness));
        setLoading(false);
      })
      .catch((err) => {
        setError(err instanceof Error ? err.message : "Failed to load universal transcript");
        setLoading(false);
      });
  }, [id]);

  const payload = useMemo<ContinuationPayload | null>(() => {
    if (!conversation) return null;
    return buildContinuationPayload(conversation, targetHarness);
  }, [conversation, targetHarness]);

  const transferPrompt = useMemo(() => payload ? buildTransferPrompt(payload) : "", [payload]);
  const selectedTarget = transferTargets.find((target) => target.harness === targetHarness) ?? transferTargets[0];
  const resumeCommand = conversation ? buildResumeCommand(conversation) : null;
  const canNativeResume = Boolean(resumeCommand && conversation?.harness === targetHarness);

  const copy = async (label: string, value: string) => {
    await navigator.clipboard.writeText(value);
    setCopied(label);
    window.setTimeout(() => setCopied(null), 1800);
  };

  if (loading) {
    return (
      <div className="mx-auto max-w-6xl py-12">
        <p className="text-sm text-text-muted">Loading continuation workspace...</p>
      </div>
    );
  }

  if (error || !conversation || !payload) {
    return (
      <div className="mx-auto max-w-4xl py-12">
        <p className="text-sm text-red-400">{error ?? "Conversation not found"}</p>
        <button onClick={() => navigate(-1)} className="mt-3 btn-action">Go back</button>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-6xl space-y-4 pb-16">
      <header className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <div className="mb-1 flex flex-wrap items-center gap-2 text-xs text-text-dim">
            <span className="rounded border border-border-subtle px-1.5 py-0.5 uppercase">{conversation.harness}</span>
            <span>{conversation.messages.length} universal messages</span>
            <span>{conversation.rawEvents?.length ?? 0} raw events</span>
          </div>
          <h1 className="text-xl font-medium leading-snug text-text-bright">{conversation.title}</h1>
          <p className="mt-1 max-w-3xl truncate font-mono text-xs text-text-muted" title={conversation.projectPath}>
            {conversation.projectPath}
          </p>
        </div>
        <div className="flex flex-wrap items-center gap-2">
          <button onClick={() => navigate(`/thread/${conversation.id}`)} className="btn-action">Thread</button>
          <button
            onClick={() => copy("payload", JSON.stringify(payload, null, 2))}
            className="btn-action-primary"
          >
            Copy Payload
          </button>
          <button
            onClick={() => copy("prompt", transferPrompt)}
            className="btn-action"
          >
            Copy Prompt
          </button>
        </div>
      </header>

      {copied && (
        <p className="rounded-md border border-glow/20 bg-glow/10 px-3 py-2 text-xs text-glow">
          Copied {copied}
        </p>
      )}

      <section className="grid gap-4 lg:grid-cols-[260px_minmax(0,1fr)]">
        <aside className="space-y-4">
          <div className="rounded-lg border border-border-subtle bg-surface-raised p-4">
            <h2 className="text-sm font-medium text-text-bright">Transfer Target</h2>
            <div className="mt-3 space-y-1.5">
              {transferTargets.map((target) => {
                const selected = target.harness === targetHarness;
                const todo = target.state === "todo";
                return (
                  <button
                    key={target.harness}
                    type="button"
                    onClick={() => setTargetHarness(target.harness)}
                    className={`w-full rounded-md border px-3 py-2 text-left transition-colors ${
                      selected
                        ? "border-glow bg-glow-bg text-text-bright"
                        : "border-border-subtle bg-surface text-text-muted hover:border-glow/30 hover:text-text-primary"
                    }`}
                    aria-pressed={selected}
                  >
                    <span className="flex items-center justify-between gap-2">
                      <span className="text-sm font-medium">{target.label}</span>
                      <span className={`rounded px-1.5 py-0.5 text-[10px] uppercase ${todo ? "bg-surface-active text-text-dim" : "bg-glow/15 text-glow"}`}>
                        {todo ? "TODO" : "Ready"}
                      </span>
                    </span>
                    <span className="mt-1 block text-xs text-text-dim">{target.note}</span>
                  </button>
                );
              })}
            </div>
          </div>

          <div className="rounded-lg border border-border-subtle bg-surface-raised p-4">
            <h2 className="text-sm font-medium text-text-bright">Continuation</h2>
            <dl className="mt-3 space-y-2 text-xs">
              <InfoRow label="Intent" value={payload.mode === "resume" ? "Resume same harness" : "Transfer harness"} />
              <InfoRow label="Source" value={payload.source.harness} />
              <InfoRow label="Target" value={payload.targetHarness} />
              <InfoRow label="Memory" value={payload.memory.status} />
            </dl>
            {canNativeResume && resumeCommand ? (
              <div className="mt-3 rounded-md border border-border-subtle bg-void p-3">
                <p className="text-xs font-medium text-text-primary">Native resume</p>
                <code className="mt-2 block break-all font-mono text-xs text-glow">{resumeCommand}</code>
                <button onClick={() => copy("resume command", resumeCommand)} className="mt-3 btn-action text-xs">Copy Command</button>
              </div>
            ) : (
              <p className="mt-3 rounded-md border border-border-subtle bg-void px-3 py-2 text-xs text-text-muted">
                Native resume is not available for this target; use the universal payload or prompt.
              </p>
            )}
          </div>
        </aside>

        <main className="min-w-0 rounded-lg border border-border-subtle bg-surface-raised">
          <div className="flex flex-wrap items-center justify-between gap-2 border-b border-border-subtle px-4 py-3">
            <div className="flex rounded-md border border-border-subtle bg-void p-0.5">
              {([
                ["continuation", "Continuation"],
                ["universal", "Universal"],
                ["raw", "Raw"],
              ] as Array<[ViewMode, string]>).map(([mode, label]) => (
                <button
                  key={mode}
                  type="button"
                  onClick={() => setViewMode(mode)}
                  className={`h-7 px-3 text-xs font-medium transition-colors ${
                    viewMode === mode ? "rounded bg-glow text-void" : "text-text-muted hover:text-text-primary"
                  }`}
                >
                  {label}
                </button>
              ))}
            </div>
            <span className="text-xs text-text-dim">
              {selectedTarget.state === "todo" ? "Exporter stub only" : "Exporter-ready payload"}
            </span>
          </div>

          <div className="p-4">
            {viewMode === "continuation" && (
              <Preview title="Continuation Prompt" content={transferPrompt} />
            )}
            {viewMode === "universal" && (
              <Preview title="Universal Payload" content={JSON.stringify(payload, null, 2)} />
            )}
            {viewMode === "raw" && (
              <Preview title="Raw Transcript Events" content={JSON.stringify(conversation.rawEvents ?? [], null, 2)} />
            )}
          </div>
        </main>
      </section>
    </div>
  );
}

function InfoRow({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-center justify-between gap-3">
      <dt className="text-text-dim">{label}</dt>
      <dd className="rounded bg-void px-2 py-0.5 font-mono text-text-primary">{value}</dd>
    </div>
  );
}

function Preview({ title, content }: { title: string; content: string }) {
  return (
    <div>
      <h2 className="mb-3 text-sm font-medium text-text-bright">{title}</h2>
      <pre className="max-h-[640px] overflow-auto rounded-md border border-border-subtle bg-void p-4 font-mono text-xs leading-relaxed text-text-muted whitespace-pre-wrap">
        {content}
      </pre>
    </div>
  );
}

function normalizeHarness(harness: string): SessionHarness {
  if (harness === "claude" || harness === "codex" || harness === "gemini" || harness === "opencode" || harness === "aider") {
    return harness;
  }
  return "other";
}
