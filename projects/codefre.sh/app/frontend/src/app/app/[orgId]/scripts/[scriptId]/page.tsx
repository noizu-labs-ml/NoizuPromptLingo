"use client";

import { use, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/context/auth";
import {
  api,
  type Prompt,
  type Script,
  type ScriptEdge,
  type ScriptNode,
  type ScriptVersion,
} from "@/lib/api";
import { LoadingSkeleton, EmptyState, Button } from "@/components/ui";
import { ScriptEditor } from "@/components/scripts/ScriptEditor";

/**
 * Scripts editor page shell. Handles auth + initial data fetch; delegates
 * all graph-editing state and UI to `<ScriptEditor>`.
 */
export default function ScriptEditorPage({
  params,
}: {
  params: Promise<{ orgId: string; scriptId: string }>;
}) {
  const { orgId, scriptId } = use(params);
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();

  const [script, setScript] = useState<Script | null>(null);
  const [draft, setDraft] = useState<ScriptVersion | null>(null);
  const [nodes, setNodes] = useState<ScriptNode[]>([]);
  const [edges, setEdges] = useState<ScriptEdge[]>([]);
  const [prompts, setPrompts] = useState<Prompt[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login");
      return;
    }
    if (!user) return;

    let cancelled = false;
    (async () => {
      try {
        const [sRes, pRes] = await Promise.all([
          api.getScript(orgId, scriptId),
          api.listPrompts(orgId),
        ]);
        if (cancelled) return;
        setScript(sRes.script);
        setDraft(sRes.draft_version);
        setNodes(sRes.nodes);
        setEdges(sRes.edges);
        setPrompts(pRes.prompts);
      } catch (err) {
        if (!cancelled)
          setLoadError(
            err instanceof Error ? err.message : "failed to load script",
          );
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [orgId, scriptId, user, authLoading, router]);

  if (authLoading || loading) {
    return (
      <div data-cy="app-loading" style={{ padding: "var(--space-8)" }}>
        <LoadingSkeleton variant="text" />
        <div style={{ height: "var(--space-4)" }} />
        <LoadingSkeleton variant="graph-node" />
      </div>
    );
  }

  if (loadError || !script) {
    return (
      <EmptyState
        glyph="scripts"
        headline="Script not found"
        body={loadError ?? "This script could not be loaded."}
        primaryAction={
          <Button href={`/app/${orgId}/scripts`} variant="primary">
            Back to scripts
          </Button>
        }
      />
    );
  }

  return (
    <ScriptEditor
      orgId={orgId}
      script={script}
      draftVersion={draft}
      initialNodes={nodes}
      initialEdges={edges}
      prompts={prompts}
    />
  );
}
