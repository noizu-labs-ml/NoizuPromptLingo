"use client";
import * as React from "react";
import { useRouter } from "next/navigation";
import { Button, ContextPanel } from "@/components/ui";
import {
  api,
  type EdgeMatchMethod, type Prompt, type Script, type ScriptEdge,
  type ScriptNode, type ScriptNodeKind, type ScriptVersion,
} from "@/lib/api";
import { cyAttrs } from "@/utils/cypress";
import {
  CANVAS_H, CANVAS_W, GraphCanvas, NODE_H, NODE_W, computeActivePathEdges,
} from "./GraphCanvas";
import { DEFAULT_PALETTE_ITEMS, NodePalette } from "./NodePalette";
import { NodeInspector, type InspectorExpectation } from "./NodeInspector";
import { EdgeModal, type EdgeDraft } from "./EdgeModal";
import { ScriptEditorHeader } from "./ScriptEditorHeader";

const MATCH_METHODS: readonly EdgeMatchMethod[] = [
  "always",
  "regex",
  "semantic",
  "intent",
  "json_path",
];

export interface ScriptEditorProps {
  orgId: string;
  script: Script;
  draftVersion: ScriptVersion | null;
  initialNodes: ScriptNode[];
  initialEdges: ScriptEdge[];
  prompts: Prompt[];
}

/**
 * Top-level orchestration component for the script graph editor. Holds all
 * mutable editor state and routes user interactions into the canvas /
 * inspector / modal children. The parent page component is a thin shell that
 * handles auth + initial data-fetching.
 */
export function ScriptEditor({
  orgId,
  script: initialScript,
  draftVersion,
  initialNodes,
  initialEdges,
  prompts,
}: ScriptEditorProps) {
  const router = useRouter();

  const [script, setScript] = React.useState<Script>(initialScript);
  const [draft, setDraft] = React.useState<ScriptVersion | null>(draftVersion);
  const [nodes, setNodes] = React.useState<ScriptNode[]>(() =>
    layoutFallback(initialNodes),
  );
  const [edges, setEdges] = React.useState<ScriptEdge[]>(initialEdges);
  const [error, setError] = React.useState<string | null>(null);
  const [publishIssues, setPublishIssues] = React.useState<string | null>(null);

  const [selectedNodeId, setSelectedNodeId] = React.useState<string | null>(null);
  const [edgeSourceId, setEdgeSourceId] = React.useState<string | null>(null);
  const [expectationsByNode, setExpectationsByNode] = React.useState<
    Record<string, InspectorExpectation[]>
  >({});
  const [edgeDraft, setEdgeDraft] = React.useState<EdgeDraft | null>(null);
  const [edgeSubmitting, setEdgeSubmitting] = React.useState(false);
  const [edgeError, setEdgeError] = React.useState<string | null>(null);

  const selectedNode = React.useMemo(
    () => nodes.find((n) => n.id === selectedNodeId) ?? null,
    [nodes, selectedNodeId],
  );

  const activePathEdgeIds = React.useMemo(
    () => computeActivePathEdges(nodes, edges, selectedNodeId),
    [nodes, edges, selectedNodeId],
  );

  const published = Boolean(script.current_version_id);

  // ─── actions ──────────────────────────────────────────────────────────
  async function addNode(kind: ScriptNodeKind) {
    setError(null);
    const nodeKey = `${kind}_${Date.now().toString(36)}`;
    const y = nodes.reduce(
      (acc, n) => Math.max(acc, (n.position?.y ?? 0) + NODE_H + 40),
      60,
    );
    try {
      const res = await api.addScriptNode(orgId, script.id, nodeKey, kind, {
        position: { x: 60, y },
      });
      setNodes((prev) => [...prev, res.node]);
      setSelectedNodeId(res.node.id);
    } catch (err) {
      setError(err instanceof Error ? err.message : "failed to add node");
    }
  }

  async function handlePublish() {
    setError(null);
    setPublishIssues(null);
    try {
      await api.publishScript(orgId, script.id);
      const reloaded = await api.getScript(orgId, script.id);
      setScript(reloaded.script);
      setDraft(reloaded.draft_version);
      setNodes(layoutFallback(reloaded.nodes));
      setEdges(reloaded.edges);
    } catch (err) {
      setPublishIssues(err instanceof Error ? err.message : "publish failed");
    }
  }

  async function handleFork() {
    setError(null);
    try {
      const res = await api.forkScript(orgId, script.id);
      router.push(`/app/${orgId}/scripts/${res.script.id}`);
    } catch (err) {
      setError(err instanceof Error ? err.message : "fork failed");
    }
  }

  async function handleExport() {
    setError(null);
    try {
      const yaml = await api.exportScriptYaml(orgId, script.id);
      const blob = new Blob([yaml], { type: "application/x-yaml" });
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = `${script.slug ?? script.id}.yaml`;
      a.click();
      URL.revokeObjectURL(url);
    } catch (err) {
      setError(err instanceof Error ? err.message : "export failed");
    }
  }

  async function handleAutoLayout() {
    setError(null);
    try {
      const res = await api.autoLayoutScript(orgId, script.id);
      setNodes(layoutFallback(res.nodes));
    } catch (err) {
      setError(err instanceof Error ? err.message : "auto-layout failed");
    }
  }

  async function handleTriggerRun() {
    if (!published) {
      setError("Publish the script before running.");
      return;
    }
    router.push(`/app/${orgId}/runs`);
  }

  function submitEdgeDraft() {
    const draft = edgeDraft;
    if (!draft) return;
    let config: Record<string, unknown> = {};
    try {
      config = draft.configText.trim() ? JSON.parse(draft.configText) : {};
    } catch {
      setEdgeError("match_config must be valid JSON");
      return;
    }
    setEdgeError(null);
    setEdgeSubmitting(true);
    void (async () => {
      try {
        const res = await api.addScriptEdge(orgId, script.id, {
          from_node_id: draft.from,
          to_node_id: draft.to,
          match_method: draft.method,
          match_config: config,
          label: draft.label || undefined,
        });
        setEdges((prev) => [...prev, res.edge]);
        setEdgeDraft(null);
      } catch (err) {
        setEdgeError(err instanceof Error ? err.message : "failed to add edge");
      } finally {
        setEdgeSubmitting(false);
      }
    })();
  }

  // ─── render ───────────────────────────────────────────────────────────
  return (
    <div
      className="sg-scripts-editor"
      data-cy="script-editor"
      data-density="compact"
      {...cyAttrs({ cyScope: "script", cyId: script.slug })}
    >
      <ScriptEditorHeader
        orgId={orgId}
        script={script}
        draftVersion={draft}
        onAutoLayout={handleAutoLayout}
        onFork={handleFork}
        onExport={handleExport}
        onPublish={handlePublish}
      />

      {error ? <ErrorBanner cy="script-editor-error">{error}</ErrorBanner> : null}
      {publishIssues ? (
        <ErrorBanner cy="script-publish-issues">
          Publish validation failed: {publishIssues}
        </ErrorBanner>
      ) : null}

      <div className="sg-scripts-editor__body">
        <NodePalette
          items={DEFAULT_PALETTE_ITEMS}
          onAdd={(kind) => void addNode(kind)}
          edgeSourceActive={Boolean(edgeSourceId)}
          onCancelEdgeSource={() => setEdgeSourceId(null)}
        />

        <section
          className="sg-scripts-editor__canvas"
          data-cy="script-canvas"
          style={{ width: CANVAS_W, height: CANVAS_H }}
        >
          <Button
            className="sg-scripts-editor__run-fab"
            variant="primary"
            onClick={handleTriggerRun}
            cy="script-run-fab"
            iconLeft={<RunIcon />}
          >
            Run this script
          </Button>
          <GraphCanvas
            nodes={nodes}
            edges={edges}
            selectedNodeId={selectedNodeId}
            edgeSourceId={edgeSourceId}
            activePathEdgeIds={activePathEdgeIds}
            onSelectNode={(n) => setSelectedNodeId(n.id)}
            onDragNode={(nodeId, pos) => {
              setNodes((prev) =>
                prev.map((n) => (n.id === nodeId ? { ...n, position: pos } : n)),
              );
            }}
            onEdgeSourceStart={(n) => setEdgeSourceId(n.id)}
            onEdgeTarget={(target) => {
              if (!edgeSourceId || edgeSourceId === target.id) return;
              setEdgeDraft({
                from: edgeSourceId,
                to: target.id,
                method: "always",
                configText: "{}",
                label: "",
              });
              setEdgeSourceId(null);
              setEdgeError(null);
            }}
          />
        </section>
      </div>

      <ContextPanel
        open={Boolean(selectedNode)}
        onClose={() => setSelectedNodeId(null)}
        title={selectedNode ? `Node · ${selectedNode.node_key}` : ""}
        cy="script-inspector"
      >
        {selectedNode ? (
          <NodeInspector
            key={selectedNode.id}
            node={selectedNode}
            prompts={prompts}
            expectations={expectationsByNode[selectedNode.id] ?? []}
            onAttachPrompt={async (promptVersionId) => {
              try {
                const res = await api.attachPromptToNode(
                  orgId,
                  script.id,
                  selectedNode.id,
                  promptVersionId,
                );
                setNodes((prev) =>
                  prev.map((n) => (n.id === res.node.id ? res.node : n)),
                );
              } catch (err) {
                setError(err instanceof Error ? err.message : "attach failed");
              }
            }}
            onAddExpectation={async (exp) => {
              try {
                const res = await api.addNodeExpectation(
                  orgId,
                  script.id,
                  selectedNode.id,
                  exp,
                );
                setExpectationsByNode((prev) => ({
                  ...prev,
                  [selectedNode.id]: [
                    ...(prev[selectedNode.id] ?? []),
                    {
                      id: res.expectation.id,
                      label: res.expectation.label,
                      weight: res.expectation.weight,
                    },
                  ],
                }));
              } catch (err) {
                setError(
                  err instanceof Error ? err.message : "add expectation failed",
                );
              }
            }}
          />
        ) : null}
      </ContextPanel>

      <EdgeModal
        open={Boolean(edgeDraft)}
        draft={edgeDraft}
        fromLabel={nodes.find((n) => n.id === edgeDraft?.from)?.node_key}
        toLabel={nodes.find((n) => n.id === edgeDraft?.to)?.node_key}
        matchMethods={MATCH_METHODS}
        onChange={setEdgeDraft}
        onCancel={() => {
          setEdgeDraft(null);
          setEdgeError(null);
        }}
        onSubmit={submitEdgeDraft}
        submitting={edgeSubmitting}
        error={edgeError}
      />
    </div>
  );
}

function RunIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 14 14" fill="none" aria-hidden="true">
      <path d="M3 2l9 5-9 5V2z" fill="currentColor" />
    </svg>
  );
}

function ErrorBanner({
  children,
  cy,
}: {
  children: React.ReactNode;
  cy: string;
}) {
  return (
    <div
      className="sg-error"
      data-cy={cy}
      role="alert"
      style={{
        padding: "var(--space-2) var(--space-3)",
        border: "1px solid var(--eval-fail)",
        background: "var(--eval-fail-wash)",
        borderRadius: "var(--radius-sm)",
        margin: "0 0 var(--space-3)",
      }}
    >
      {children}
    </div>
  );
}

/** Assign grid positions to nodes missing one. */
function layoutFallback(input: ScriptNode[]): ScriptNode[] {
  return input.map((n, i) => {
    const existing = n.position ?? {};
    if (typeof existing.x === "number" && typeof existing.y === "number") return n;
    const col = i % 4;
    const row = Math.floor(i / 4);
    return {
      ...n,
      position: { x: 60 + col * (NODE_W + 40), y: 60 + row * (NODE_H + 60) },
    };
  });
}
