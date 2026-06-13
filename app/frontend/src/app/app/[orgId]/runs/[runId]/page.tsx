"use client";

import { use, useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/context/auth";
import {
  api,
  type Run,
  type RunScore,
  type RunStep,
  type RunVerdict,
  type ScriptEdge,
  type ScriptNode,
} from "@/lib/api";
import {
  Button,
  ContextPanel,
  EmptyState,
  LoadingSkeleton,
  PageHeader,
  StatusPill,
  toast,
} from "@/components/ui";
import { VerdictBanner } from "@/components/runs/VerdictBanner";
import { ForgeGraphView } from "@/components/runs/ForgeGraphView";
import { RunTranscript } from "@/components/runs/RunTranscript";
import {
  StepDetail,
  deriveVerdictFromRun,
} from "@/components/runs/StepDetail";
import { useReducedMotion } from "@/hooks/useReducedMotion";
import { cyAttrs } from "@/utils/cypress";

/**
 * Run detail page — the hero verdict moment. Plays the Forge sequence once
 * on mount (when run is completed), shows verdict banner + graph + transcript.
 */
export default function RunDetailPage({
  params,
}: {
  params: Promise<{ orgId: string; runId: string }>;
}) {
  const { orgId, runId } = use(params);
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();
  const reducedMotion = useReducedMotion();

  const [run, setRun] = useState<Run | null>(null);
  const [nodes, setNodes] = useState<ScriptNode[]>([]);
  const [edges, setEdges] = useState<ScriptEdge[]>([]);
  const [steps, setSteps] = useState<RunStep[]>([]);
  const [scores, setScores] = useState<RunScore[]>([]);
  const [loading, setLoading] = useState(true);
  const [notFound, setNotFound] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [selectedStepId, setSelectedStepId] = useState<string | null>(null);
  const [cancelling, setCancelling] = useState(false);
  const [retrying, setRetrying] = useState(false);

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login");
      return;
    }
    if (!user) return;

    let cancelled = false;
    (async () => {
      try {
        const runRes = await api.getRun(orgId, runId);
        if (cancelled) return;
        setRun(runRes.run);
        setNodes(runRes.nodes ?? []);
        setEdges(runRes.edges ?? []);

        // Steps + scores are optional (non-404 failures bubble up). Swallow
        // 404s independently so the page still renders the banner.
        const [stepsRes, scoresRes] = await Promise.all([
          api.listRunSteps(orgId, runId).catch(() => ({ steps: [] as RunStep[] })),
          api.listRunScores(orgId, runId).catch(() => ({ scores: [] as RunScore[] })),
        ]);
        if (cancelled) return;
        setSteps(stepsRes.steps);
        setScores(scoresRes.scores);
      } catch (err) {
        if (cancelled) return;
        const msg = err instanceof Error ? err.message : "";
        if (msg.includes("404")) {
          setNotFound(true);
        } else {
          setError(msg || "failed to load run");
        }
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [orgId, runId, user, authLoading, router]);

  // Map node_id → verdict using run_steps (last step wins if multiple).
  const verdictByNode = useMemo(() => {
    const out: Record<string, RunVerdict | null> = {};
    for (const s of steps) {
      if (s.script_node_id) out[s.script_node_id] = s.verdict ?? null;
    }
    return out;
  }, [steps]);

  const scoresByStep = useMemo(() => {
    const out: Record<string, RunScore[]> = {};
    for (const s of scores) {
      if (!s.run_step_id) continue;
      if (!out[s.run_step_id]) out[s.run_step_id] = [];
      out[s.run_step_id].push(s);
    }
    return out;
  }, [scores]);

  const selectedStep = useMemo(
    () => steps.find((s) => s.id === selectedStepId) ?? null,
    [steps, selectedStepId],
  );

  const isTerminal = useMemo(
    () =>
      run
        ? ["pass", "warn", "fail", "cancelled", "error"].includes(run.status)
        : false,
    [run],
  );

  // Used to key the banner's reveal animation — swap keys when revealing so
  // the CSS animation restarts on mount.
  const [bannerRevealing, setBannerRevealing] = useState(false);
  useEffect(() => {
    if (!run || !isTerminal) return;
    setBannerRevealing(true);
    const t = window.setTimeout(() => setBannerRevealing(false), 600);
    return () => window.clearTimeout(t);
  }, [run, isTerminal]);

  // ─── actions ──────────────────────────────────────────────────────────
  async function handleCancel() {
    if (!run) return;
    setCancelling(true);
    try {
      const res = await api.cancelRun(orgId, run.id);
      setRun(res.run);
      toast.success("Run cancelled");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Cancel failed");
    } finally {
      setCancelling(false);
    }
  }

  async function handleRetry() {
    if (!run) return;
    setRetrying(true);
    try {
      const res = await api.retryRun(orgId, run.id);
      toast.success("Retry queued");
      router.push(`/app/${orgId}/runs/${res.run.id}`);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Retry failed");
    } finally {
      setRetrying(false);
    }
  }

  // ─── render ───────────────────────────────────────────────────────────
  if (authLoading || loading) {
    return (
      <div data-cy="app-loading" style={{ padding: "var(--space-8)" }}>
        <LoadingSkeleton variant="text" />
        <div style={{ height: "var(--space-4)" }} />
        <LoadingSkeleton variant="card" />
      </div>
    );
  }

  if (notFound || !run) {
    return (
      <EmptyState
        glyph="runs"
        headline="Run not found"
        body="This run has not completed yet, or does not belong to this organization."
        primaryAction={
          <Button href={`/app/${orgId}/runs`} variant="primary">
            Back to runs
          </Button>
        }
      />
    );
  }

  const verdict = deriveVerdictFromRun(run.status, run.verdict);
  const shortId = run.short_id ?? run.id.slice(0, 8);

  const retryAvailable = isTerminal;
  const cancelAvailable = run.status === "pending" || run.status === "running";

  return (
    <div
      data-cy="run-detail"
      {...cyAttrs({ cyScope: "run", cyId: shortId })}
    >
      <PageHeader
        title={
          <span>
            Run <code className="sg-mono">{shortId}</code>
          </span>
        }
        subtitle={
          run.script_name ? (
            <span>
              {run.script_name}
              {run.script_version_number != null ? (
                <span style={{ color: "var(--text-ghost)" }}>
                  {" "}
                  v{run.script_version_number}
                </span>
              ) : null}
            </span>
          ) : null
        }
        breadcrumbs={[
          { label: "runs", href: `/app/${orgId}/runs` },
          { label: shortId, current: true },
        ]}
        actions={
          <>
            <StatusPill state={run.status} size="sm" cy="run-status-pill" />
            {retryAvailable ? (
              <Button
                variant="ghost"
                onClick={handleRetry}
                loading={retrying}
                cy="run-retry"
              >
                Retry
              </Button>
            ) : null}
            {cancelAvailable ? (
              <Button
                variant="eval"
                evalState="fail"
                onClick={handleCancel}
                loading={cancelling}
                cy="run-cancel"
              >
                Cancel
              </Button>
            ) : null}
          </>
        }
      />

      {error ? (
        <div
          role="alert"
          data-cy="run-detail-error"
          style={{
            padding: "var(--space-2) var(--space-3)",
            border: "1px solid var(--eval-fail)",
            background: "var(--eval-fail-wash)",
            borderRadius: "var(--radius-sm)",
            color: "var(--eval-fail)",
            margin: "0 0 var(--space-4)",
          }}
        >
          {error}
        </div>
      ) : null}

      {/* Verdict banner */}
      <div style={{ marginBottom: "var(--space-5)" }}>
        <VerdictBanner
          verdict={verdict}
          score={run.score ?? null}
          durationMs={run.duration_ms ?? null}
          agentName={run.agent_name}
          personaName={run.persona_name}
          startedAt={run.started_at}
          revealing={bannerRevealing}
        />
      </div>

      {/* Split view: graph left, transcript right */}
      <div className="sg-run-detail__split">
        <section
          className="sg-run-detail__graph"
          aria-label="Script graph with eval results"
          data-cy="run-graph"
        >
          {nodes.length === 0 ? (
            <EmptyState
              glyph="scripts"
              headline="No graph snapshot"
              body="The script graph for this run was not captured."
            />
          ) : (
            <div style={{ width: "100%", height: "100%", minHeight: 420 }}>
              <ForgeGraphView
                nodes={nodes}
                edges={edges}
                verdictByNode={verdictByNode}
                selectedNodeId={
                  selectedStep?.script_node_id ?? null
                }
                onSelectNode={(node) => {
                  const step =
                    steps.find((s) => s.script_node_id === node.id) ?? null;
                  setSelectedStepId(step?.id ?? null);
                }}
                reducedMotion={reducedMotion}
                animate={isTerminal}
              />
            </div>
          )}
        </section>

        <section
          className="sg-run-detail__transcript"
          aria-label="Run transcript"
          data-cy="run-transcript"
        >
          <RunTranscript
            steps={steps}
            selectedStepId={selectedStepId}
            onSelectStep={setSelectedStepId}
          />
        </section>
      </div>

      {/* Step drill-down — renders scores + rationale */}
      <ContextPanel
        open={Boolean(selectedStep)}
        onClose={() => setSelectedStepId(null)}
        title={
          selectedStep
            ? `Turn ${selectedStep.sequence} · ${selectedStep.voice}`
            : ""
        }
        cy="run-step-detail"
      >
        {selectedStep ? (
          <StepDetail
            step={selectedStep}
            scores={scoresByStep[selectedStep.id] ?? []}
          />
        ) : null}
      </ContextPanel>
    </div>
  );
}

