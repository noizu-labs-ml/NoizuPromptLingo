"use client";

import { use, useEffect, useState } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import { api, type Run, type RunStatus, type Script, type Agent, type Persona } from "@/lib/api";
import { cyAttrs } from "@/utils/cypress";
import {
  PageHeader,
  Button,
  EmptyState,
  LoadingSkeleton,
  StatusPill,
  type StatusState,
  DataTable,
  type DataTableColumn,
  Modal,
  FormField,
  Select,
} from "@/components/ui";

function runStatusToState(s: RunStatus): StatusState {
  switch (s) {
    case "pending":
      return "pending";
    case "running":
      return "running";
    case "pass":
      return "pass";
    case "warn":
      return "warn";
    case "fail":
      return "fail";
    case "cancelled":
      return "cancelled";
    case "error":
      return "error";
    default:
      return "pending";
  }
}

export default function RunsPage({
  params,
}: {
  params: Promise<{ orgId: string }>;
}) {
  const { orgId } = use(params);
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();

  const [runs, setRuns] = useState<Run[]>([]);
  const [loading, setLoading] = useState(true);
  const [runnerMissing, setRunnerMissing] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Trigger modal state
  const [triggering, setTriggering] = useState(false);
  const [scripts, setScripts] = useState<Script[]>([]);
  const [agents, setAgents] = useState<Agent[]>([]);
  const [personas, setPersonas] = useState<Persona[]>([]);
  const [selectedScript, setSelectedScript] = useState("");
  const [selectedAgent, setSelectedAgent] = useState("");
  const [selectedPersona, setSelectedPersona] = useState("");
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login");
      return;
    }
    if (!user) return;

    api
      .listRuns(orgId)
      .then((res) => setRuns(res.runs))
      .catch((err) => {
        const msg = err instanceof Error ? err.message : "";
        if (msg.includes("404") || msg.includes("Request failed: 404")) {
          setRunnerMissing(true);
        } else {
          setError(msg || "failed to load");
        }
      })
      .finally(() => setLoading(false));
  }, [user, authLoading, router, orgId]);

  async function openTriggerModal() {
    setTriggering(true);
    try {
      const [s, a, p] = await Promise.all([
        api.listScripts(orgId),
        api.listAgents(orgId),
        api.listPersonas(orgId),
      ]);
      setScripts(s.scripts);
      setAgents(a.agents);
      setPersonas(p.personas);
      if (s.scripts[0]) setSelectedScript(s.scripts[0].id);
      if (a.agents[0]) setSelectedAgent(a.agents[0].id);
    } catch (err) {
      setError(err instanceof Error ? err.message : "failed to load options");
      setTriggering(false);
    }
  }

  async function handleTrigger(e: React.FormEvent) {
    e.preventDefault();
    if (!selectedScript || !selectedAgent) return;
    setSubmitting(true);
    try {
      const res = await api.triggerRun(
        orgId,
        selectedScript,
        selectedAgent,
        selectedPersona || undefined,
      );
      setRuns((prev) => [res.run, ...prev]);
      setTriggering(false);
      setSelectedScript("");
      setSelectedAgent("");
      setSelectedPersona("");
    } catch (err) {
      setError(err instanceof Error ? err.message : "failed to trigger run");
    } finally {
      setSubmitting(false);
    }
  }

  if (authLoading) {
    return (
      <div data-cy="app-loading" className="sg-app-loading">
        Loading…
      </div>
    );
  }

  if (runnerMissing) {
    return (
      <div data-cy="runs-runner-missing">
        <EmptyState
          glyph="runs"
          headline="Runner coming soon"
          body="The run execution service is not yet deployed for this organization."
        />
      </div>
    );
  }

  const columns: DataTableColumn<Run>[] = [
    {
      key: "short_id",
      label: "Run",
      render: (run) => (
        <span
          data-cy="run-id"
          className="sg-mono"
          style={{ fontSize: "0.9rem" }}
        >
          {run.short_id ?? run.id.slice(0, 8)}
        </span>
      ),
    },
    {
      key: "script_name",
      label: "Script",
      render: (run) =>
        run.script_name ? (
          <span data-cy="run-script-name">
            {run.script_name}
            {run.script_version_number != null && (
              <span className="sg-subtle"> v{run.script_version_number}</span>
            )}
          </span>
        ) : (
          "—"
        ),
    },
    {
      key: "agent_name",
      label: "Agent",
      render: (run) =>
        run.agent_name ? (
          <span data-cy="run-agent-name" style={{ fontSize: "0.875rem", color: "var(--text-secondary)" }}>
            {run.agent_name}
          </span>
        ) : (
          "—"
        ),
    },
    {
      key: "persona_name",
      label: "Persona",
      render: (run) =>
        run.persona_name ? (
          <span
            data-cy="run-persona-name"
            style={{ fontSize: "0.85rem", color: "var(--text-tertiary)" }}
          >
            {run.persona_name}
          </span>
        ) : (
          "—"
        ),
    },
    {
      key: "duration",
      label: "Duration",
      render: (run) =>
        run.duration_ms != null ? (
          <span data-cy="run-duration" style={{ fontSize: "0.85rem", color: "var(--text-tertiary)" }}>
            {run.duration_ms}ms
          </span>
        ) : (
          "—"
        ),
    },
    {
      key: "status",
      label: "Status",
      render: (run) => <StatusPill state={runStatusToState(run.status)} size="sm" cy="run-status-pill" />,
    },
  ];

  return (
    <div data-cy="runs-page" {...cyAttrs({ cyScope: "runs" })}>
      <PageHeader
        title="Runs"
        subtitle="Trigger runs, watch live status, see per-step scores and verdicts."
        actions={
          <Button variant="primary" cy="runs-trigger" onClick={openTriggerModal}>
            + Trigger Run
          </Button>
        }
      />

      {error && (
        <p className="sg-error" data-cy="runs-error">
          {error}
        </p>
      )}

      {loading ? (
        <LoadingSkeleton variant="row" count={6} />
      ) : runs.length === 0 ? (
        <EmptyState
          glyph="runs"
          headline="No runs yet"
          body="Trigger your first run to see live status, scores, and verdicts."
          primaryAction={
            <Button variant="primary" cy="runs-empty-trigger" onClick={openTriggerModal}>
              + Trigger Run
            </Button>
          }
        />
      ) : (
        <DataTable<Run>
          cy="runs-table"
          columns={columns}
          rows={runs}
          rowKey={(r) => r.id}
          onRowClick={(row) => router.push(`/app/${orgId}/runs/${row.id}`)}
        />
      )}

      <Modal
        open={triggering}
        onClose={() => setTriggering(false)}
        title="Trigger a Run"
        cy="runs-trigger-modal"
        footer={
          <div style={{ display: "flex", gap: "0.5rem", justifyContent: "flex-end", width: "100%" }}>
            <Button variant="ghost" cy="runs-trigger-cancel" onClick={() => setTriggering(false)}>
              Cancel
            </Button>
            <Button
              variant="primary"
              cy="runs-trigger-submit"
              loading={submitting}
              disabled={!selectedScript || !selectedAgent}
              onClick={(e) => handleTrigger(e as unknown as React.FormEvent)}
            >
              Start Run
            </Button>
          </div>
        }
      >
        <form onSubmit={handleTrigger}>
          <FormField label="Script" name="script" required>
            {(p) => (
              <Select
                {...p}
                cy="runs-script-select"
                value={selectedScript}
                onChange={(e) => setSelectedScript(e.target.value)}
              >
                {scripts.length === 0 && <option value="">No scripts available</option>}
                {scripts.map((s) => (
                  <option key={s.id} value={s.id}>
                    {s.name}
                  </option>
                ))}
              </Select>
            )}
          </FormField>
          <FormField label="Agent" name="agent" required>
            {(p) => (
              <Select
                {...p}
                cy="runs-agent-select"
                value={selectedAgent}
                onChange={(e) => setSelectedAgent(e.target.value)}
              >
                {agents.length === 0 && <option value="">No agents available</option>}
                {agents.map((a) => (
                  <option key={a.id} value={a.id}>
                    {a.name}
                  </option>
                ))}
              </Select>
            )}
          </FormField>
          <FormField label="Persona (optional)" name="persona">
            {(p) => (
              <Select
                {...p}
                cy="runs-persona-select"
                value={selectedPersona}
                onChange={(e) => setSelectedPersona(e.target.value)}
              >
                <option value="">None</option>
                {personas.map((pr) => (
                  <option key={pr.id} value={pr.id}>
                    {pr.name}
                  </option>
                ))}
              </Select>
            )}
          </FormField>
        </form>
      </Modal>
    </div>
  );
}
