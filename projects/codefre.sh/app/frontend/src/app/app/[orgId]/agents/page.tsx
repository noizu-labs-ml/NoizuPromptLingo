"use client";

import { use, useEffect, useState } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import { api, type Agent, type AgentAdapter, type AgentHealthResult } from "@/lib/api";
import { cyAttrs } from "@/utils/cypress";
import {
  PageHeader,
  Button,
  Card,
  EmptyState,
  LoadingSkeleton,
  StatusPill,
  type StatusState,
  Modal,
  FormField,
  TextInput,
  Select,
} from "@/components/ui";

const ADAPTERS: AgentAdapter[] = ["openai", "anthropic", "langchain", "http", "bedrock", "vertex"];

type AgentHealth = "healthy" | "unhealthy" | "stale" | "unchecked";

function healthToState(h: AgentHealth): StatusState {
  switch (h) {
    case "healthy":
      return "pass";
    case "unhealthy":
      return "fail";
    case "stale":
      return "warn";
    default:
      return "pending";
  }
}

export default function AgentsPage({
  params,
}: {
  params: Promise<{ orgId: string }>;
}) {
  const { orgId } = use(params);
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();

  const [agents, setAgents] = useState<Agent[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [creating, setCreating] = useState(false);
  const [newName, setNewName] = useState("");
  const [newAdapter, setNewAdapter] = useState<AgentAdapter>("openai");
  const [submitting, setSubmitting] = useState(false);

  const [publishing, setPublishing] = useState<string | null>(null);
  const [healthChecking, setHealthChecking] = useState<string | null>(null);
  const [healthResults, setHealthResults] = useState<Record<string, AgentHealthResult>>({});

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login");
      return;
    }
    if (!user) return;

    api
      .listAgents(orgId)
      .then((res) => setAgents(res.agents))
      .catch((err) => setError(err instanceof Error ? err.message : "failed to load"))
      .finally(() => setLoading(false));
  }, [user, authLoading, router, orgId]);

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault();
    if (!newName.trim()) return;
    setSubmitting(true);
    try {
      const res = await api.createAgent(orgId, newName.trim(), newAdapter, {});
      setAgents((prev) => [res.agent, ...prev]);
      setNewName("");
      setNewAdapter("openai");
      setCreating(false);
    } catch (err) {
      setError(err instanceof Error ? err.message : "failed to create");
    } finally {
      setSubmitting(false);
    }
  }

  async function handlePublish(agentId: string) {
    setPublishing(agentId);
    try {
      await api.publishAgentVersion(orgId, agentId);
      const res = await api.listAgents(orgId);
      setAgents(res.agents);
    } catch (err) {
      setError(err instanceof Error ? err.message : "failed to publish");
    } finally {
      setPublishing(null);
    }
  }

  async function handleHealthCheck(agentId: string) {
    setHealthChecking(agentId);
    try {
      const result = await api.checkAgentHealth(orgId, agentId);
      setHealthResults((prev) => ({ ...prev, [agentId]: result }));
    } catch (err) {
      setError(err instanceof Error ? err.message : "health check failed");
    } finally {
      setHealthChecking(null);
    }
  }

  if (authLoading) {
    return (
      <div data-cy="app-loading" className="sg-app-loading">
        Loading…
      </div>
    );
  }

  return (
    <div data-cy="agents-page" {...cyAttrs({ cyScope: "agents" })}>
      <PageHeader
        title="Agents"
        subtitle="Adapter configs for OpenAI, Anthropic, LangChain, HTTP, Bedrock, Vertex."
        actions={
          <Button variant="primary" cy="agents-create" onClick={() => setCreating(true)}>
            + New Agent
          </Button>
        }
      />

      {error && (
        <p className="sg-error" data-cy="agents-error">
          {error}
        </p>
      )}

      {loading ? (
        <LoadingSkeleton variant="card" count={4} />
      ) : agents.length === 0 ? (
        <EmptyState
          glyph="agents"
          headline="No agents yet"
          body="Create your first agent to connect an LLM provider to your scripts."
          primaryAction={
            <Button variant="primary" cy="agents-empty-create" onClick={() => setCreating(true)}>
              + Create Agent
            </Button>
          }
        />
      ) : (
        <div
          data-cy="agents-list"
          {...cyAttrs({ cyId: "agents" })}
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fill, minmax(300px, 1fr))",
            gap: "1rem",
          }}
        >
          {agents.map((agent) => {
            const health = healthResults[agent.id];
            const agentHealth = (health?.status ?? agent.health_status ?? "unchecked") as AgentHealth;
            return (
              <Card
                key={agent.id}
                interactive
                cy="agent-row"
                cyId={agent.slug}
                onClick={() => router.push(`/app/${orgId}/agents/${agent.id}`)}
              >
                <div
                  style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "baseline",
                    gap: "0.5rem",
                    marginBottom: "0.5rem",
                  }}
                >
                  <strong data-cy="agent-name" style={{ fontSize: "1.05rem" }}>
                    {agent.name}
                  </strong>
                  <StatusPill
                    state={healthToState(agentHealth)}
                    size="sm"
                    label={agentHealth}
                    cy="agent-health-badge"
                    cyId={agent.slug}
                  />
                </div>

                <div
                  data-cy="agent-adapter"
                  {...cyAttrs({ cyValue: agent.adapter })}
                  style={{
                    display: "inline-block",
                    padding: "0.15rem 0.5rem",
                    background: "var(--bg-surface)",
                    border: "1px solid var(--border-default)",
                    borderRadius: "0.25rem",
                    fontSize: "0.75rem",
                    fontFamily: "var(--font-mono, monospace)",
                    marginBottom: "0.5rem",
                  }}
                >
                  {agent.adapter}
                </div>

                {agent.description && (
                  <p
                    data-cy="agent-description"
                    style={{
                      margin: "0 0 0.75rem",
                      fontSize: "0.875rem",
                      color: "var(--text-secondary)",
                      lineHeight: 1.5,
                    }}
                  >
                    {agent.description}
                  </p>
                )}

                <div
                  style={{
                    display: "flex",
                    gap: "0.5rem",
                    alignItems: "center",
                    flexWrap: "wrap",
                    justifyContent: "flex-end",
                  }}
                >
                  {agent.current_version_id && (
                    <span
                      className="sg-pill sg-pill--sm eval-pass"
                      data-cy="agent-version-badge"
                    >
                      published
                    </span>
                  )}
                  <Button
                    variant="ghost"
                    size="sm"
                    cy="agent-health-check"
                    cyId={agent.slug}
                    loading={healthChecking === agent.id}
                    onClick={(e) => {
                      e.stopPropagation();
                      handleHealthCheck(agent.id);
                    }}
                  >
                    Health check
                  </Button>
                  <Button
                    variant="ghost"
                    size="sm"
                    cy="agent-publish"
                    cyId={agent.slug}
                    loading={publishing === agent.id}
                    onClick={(e) => {
                      e.stopPropagation();
                      handlePublish(agent.id);
                    }}
                  >
                    Publish
                  </Button>
                </div>
              </Card>
            );
          })}
        </div>
      )}

      <Modal
        open={creating}
        onClose={() => setCreating(false)}
        title="New Agent"
        cy="agents-create-modal"
        footer={
          <div style={{ display: "flex", gap: "0.5rem", justifyContent: "flex-end", width: "100%" }}>
            <Button variant="ghost" cy="agents-create-cancel" onClick={() => setCreating(false)}>
              Cancel
            </Button>
            <Button
              variant="primary"
              cy="agents-create-submit"
              loading={submitting}
              disabled={!newName.trim()}
              onClick={(e) => handleCreate(e as unknown as React.FormEvent)}
            >
              Create
            </Button>
          </div>
        }
      >
        <form data-cy="agents-create-form" onSubmit={handleCreate}>
          <FormField label="Name" name="name" required>
            {(p) => (
              <TextInput
                {...p}
                cy="agents-name-input"
                type="text"
                value={newName}
                onChange={(e) => setNewName(e.target.value)}
                placeholder="My agent"
                autoFocus
              />
            )}
          </FormField>
          <FormField label="Adapter" name="adapter" required>
            {(p) => (
              <Select
                {...p}
                cy="agents-adapter-select"
                value={newAdapter}
                onChange={(e) => setNewAdapter(e.target.value as AgentAdapter)}
                options={ADAPTERS.map((a) => ({ value: a, label: a }))}
              />
            )}
          </FormField>
        </form>
      </Modal>
    </div>
  );
}
