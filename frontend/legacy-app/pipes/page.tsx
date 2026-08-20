"use client";

import { useState } from "react";
import { TabGroup, TabList, Tab, TabPanels, TabPanel } from "@headlessui/react";
import { ArrowPathIcon, ArrowDownTrayIcon, ArrowUpTrayIcon } from "@heroicons/react/24/outline";
import clsx from "clsx";

import { api } from "@/lib/api/client";
import type { PipeInputResult, PipeOutputResult } from "@/lib/api/types";
import { Card } from "@/components/primitives/Card";
import { Badge } from "@/components/primitives/Badge";
import { Button } from "@/components/primitives/Button";
import { Input } from "@/components/primitives/Input";
import { Textarea } from "@/components/primitives/Textarea";
import { FormField } from "@/components/primitives/FormField";
import { CodeBlock } from "@/components/primitives/CodeBlock";
import { PageHeader } from "@/components/primitives/PageHeader";
import { EmptyState } from "@/components/primitives/EmptyState";

// ── Input tab ───────────────────────────────────────────────────────────

function InputTab() {
  const [agent, setAgent] = useState("");
  const [since, setSince] = useState("");
  const [full, setFull] = useState(false);
  const [withSections, setWithSections] = useState("");
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<PipeInputResult | null>(null);
  const [error, setError] = useState<string | null>(null);

  const handleFetch = async () => {
    if (!agent.trim()) return;
    setLoading(true);
    setError(null);
    try {
      const sections = withSections
        .split(/[,\n]+/)
        .map((s) => s.trim())
        .filter(Boolean);
      const res = await api.pipes.input({
        agent: agent.trim(),
        since: since.trim() || undefined,
        full,
        with_sections: sections.length > 0 ? sections : undefined,
      });
      setResult(res);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to fetch pipe");
    } finally {
      setLoading(false);
    }
  };

  const dashboardKeys = result?.dashboard ? Object.keys(result.dashboard) : [];

  return (
    <div className="grid grid-cols-1 gap-6 lg:grid-cols-[340px_1fr]">
      <div className="space-y-4">
        <Card className="space-y-4">
          <h3 className="text-sm font-semibold text-foreground">Pull messages</h3>
          <FormField label="Agent session UUID" htmlFor="pipe-agent">
            <Input
              id="pipe-agent"
              value={agent}
              onChange={(e) => setAgent(e.target.value)}
              placeholder="Short or full UUID"
            />
          </FormField>
          <FormField label="Since (UTC)" htmlFor="pipe-since" helper="ISO-8601, optional">
            <Input
              id="pipe-since"
              value={since}
              onChange={(e) => setSince(e.target.value)}
              placeholder="2026-04-22T00:00:00Z"
            />
          </FormField>
          <FormField label="Sections filter" htmlFor="pipe-with" helper="Comma-separated, optional">
            <Input
              id="pipe-with"
              value={withSections}
              onChange={(e) => setWithSections(e.target.value)}
              placeholder="build-status, metrics"
            />
          </FormField>
          <label className="flex items-center gap-2 text-sm text-foreground cursor-pointer">
            <input
              type="checkbox"
              checked={full}
              onChange={(e) => setFull(e.target.checked)}
              className="focus-ring h-4 w-4 rounded border-border bg-surface-1 accent-[hsl(var(--accent))]"
            />
            Full (ignore &quot;since&quot;)
          </label>
          <Button
            onClick={handleFetch}
            disabled={loading || !agent.trim()}
            loading={loading}
            className="w-full"
          >
            {loading ? "Fetching…" : "Fetch dashboard"}
          </Button>
        </Card>
      </div>

      <div className="min-w-0 space-y-4">
        {error && (
          <div role="alert" className="bg-danger/10 text-danger p-3 rounded-md text-sm">
            {error}
          </div>
        )}
        {result && (
          <Card className="space-y-3">
            <div className="flex items-center gap-3 flex-wrap">
              <Badge variant="accent" size="sm">{result.agent_handle}</Badge>
              <span className="text-xs text-muted font-mono">{result.agent}</span>
              {result.groups.length > 0 && (
                <span className="text-xs text-muted">
                  groups: {result.groups.join(", ")}
                </span>
              )}
              <Badge variant="default" size="sm">{result.entries} entries</Badge>
            </div>
          </Card>
        )}
        {result && dashboardKeys.length === 0 && (
          <EmptyState
            icon={<ArrowDownTrayIcon />}
            title="No messages"
            description="No pipe entries match this agent. Try adjusting the filters or check the agent UUID."
          />
        )}
        {result && dashboardKeys.length > 0 && (
          <div className="space-y-3">
            {dashboardKeys.map((key) => {
              const raw = result.dashboard[key];
              const entries = Array.isArray(raw) ? raw : [raw];
              return (
                <Card key={key} className="space-y-2">
                  <div className="flex items-center justify-between">
                    <h4 className="text-sm font-semibold font-mono text-foreground">{key}</h4>
                    <Badge variant="default" size="sm">
                      {entries.length} {entries.length === 1 ? "entry" : "entries"}
                    </Badge>
                  </div>
                  {entries.map((entry, i) => (
                    <div
                      key={i}
                      className="rounded-md border border-border/50 bg-surface-1 p-3 space-y-2"
                    >
                      <div className="flex items-center gap-2 text-xs text-muted">
                        <span className="font-mono">{entry.sender.agent_handle}</span>
                        <span className="text-subtle">({entry.sender.agent_id})</span>
                        {entry.updated_at && (
                          <span className="ml-auto text-subtle font-mono">
                            {entry.updated_at}
                          </span>
                        )}
                      </div>
                      <CodeBlock
                        code={
                          typeof entry.data === "string"
                            ? entry.data
                            : JSON.stringify(entry.data, null, 2)
                        }
                        language="yaml"
                        maxHeight="200px"
                      />
                    </div>
                  ))}
                </Card>
              );
            })}
          </div>
        )}
        {!result && !error && (
          <div className="rounded-lg border border-border bg-surface-1 px-6 py-16 text-center text-sm text-muted">
            Enter an agent session UUID and click <strong className="text-foreground">Fetch dashboard</strong> to see incoming pipe messages.
          </div>
        )}
      </div>
    </div>
  );
}

// ── Output tab ──────────────────────────────────────────────────────────

const OUTPUT_TEMPLATE = `build-status:
  target:
    agent-handle: npl-tdd-coder
  data:
    status: green
    tests_passed: 42`;

function OutputTab() {
  const [agent, setAgent] = useState("");
  const [body, setBody] = useState(OUTPUT_TEMPLATE);
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<PipeOutputResult | null>(null);
  const [error, setError] = useState<string | null>(null);

  const handleSend = async () => {
    if (!agent.trim() || !body.trim()) return;
    setLoading(true);
    setError(null);
    try {
      const res = await api.pipes.output({ agent: agent.trim(), body });
      setResult(res);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to send");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="grid grid-cols-1 gap-6 lg:grid-cols-[1fr_340px]">
      <Card className="space-y-4">
        <h3 className="text-sm font-semibold text-foreground">Compose message</h3>
        <FormField label="Sender session UUID" htmlFor="pipe-out-agent">
          <Input
            id="pipe-out-agent"
            value={agent}
            onChange={(e) => setAgent(e.target.value)}
            placeholder="Short or full UUID of the sending agent"
          />
        </FormField>
        <FormField
          label="YAML body"
          htmlFor="pipe-out-body"
          helper="Top-level keys are message names. Each has a 'target' and 'data' block."
        >
          <Textarea
            id="pipe-out-body"
            rows={14}
            mono
            value={body}
            onChange={(e) => setBody(e.target.value)}
          />
        </FormField>
        <Button
          onClick={handleSend}
          disabled={loading || !agent.trim() || !body.trim()}
          loading={loading}
          className="w-full"
        >
          {loading ? "Sending…" : "Push to pipe"}
        </Button>
      </Card>

      <div className="space-y-4">
        {error && (
          <div role="alert" className="bg-danger/10 text-danger p-3 rounded-md text-sm">
            {error}
          </div>
        )}
        {result && (
          <Card className="space-y-2">
            <h4 className="text-sm font-semibold text-foreground">Result</h4>
            <div className="flex items-center gap-2">
              <Badge variant={result.status === "ok" ? "success" : "danger"} size="sm">
                {result.status}
              </Badge>
              <span className="text-xs text-muted">
                {result.upserted} section{result.upserted === 1 ? "" : "s"} upserted
              </span>
            </div>
            <p className="text-xs text-muted font-mono">sender: {result.sender}</p>
          </Card>
        )}
        <Card className="space-y-2">
          <h4 className="text-sm font-semibold text-foreground">YAML structure</h4>
          <p className="text-xs text-muted leading-relaxed">
            Each top-level key is a <code className="font-mono text-accent">message-name</code>. Inside, use:
          </p>
          <ul className="text-xs text-muted space-y-1 list-disc pl-4">
            <li><code className="font-mono text-accent">target.agent</code> — direct UUID</li>
            <li><code className="font-mono text-accent">target.agent-handle</code> — agent name</li>
            <li><code className="font-mono text-accent">target.group</code> — group name</li>
            <li><code className="font-mono text-accent">target.group-handle</code> — group UUID</li>
            <li><code className="font-mono text-accent">data</code> — arbitrary payload</li>
          </ul>
        </Card>
      </div>
    </div>
  );
}

// ── Page ────────────────────────────────────────────────────────────────

export default function PipesPage() {
  return (
    <div className="space-y-6">
      <PageHeader
        title="Agent Pipes"
        description="Inter-agent structured messaging. Push data to targets (agents or groups) and pull incoming dashboards."
      />

      <TabGroup>
        <TabList className="flex gap-1 rounded-lg bg-surface-1 border border-border p-1 w-fit">
          {[
            { label: "Input", icon: ArrowDownTrayIcon },
            { label: "Output", icon: ArrowUpTrayIcon },
          ].map(({ label, icon: Icon }) => (
            <Tab
              key={label}
              className={({ selected }: { selected: boolean }) =>
                clsx(
                  "flex items-center gap-1.5 rounded-md px-4 py-1.5 text-sm font-medium transition-colors focus:outline-none",
                  selected
                    ? "bg-accent text-accent-on shadow-sm"
                    : "text-muted hover:text-foreground"
                )
              }
            >
              <Icon className="h-4 w-4" />
              {label}
            </Tab>
          ))}
        </TabList>

        <TabPanels className="mt-6">
          <TabPanel>
            <InputTab />
          </TabPanel>
          <TabPanel>
            <OutputTab />
          </TabPanel>
        </TabPanels>
      </TabGroup>
    </div>
  );
}
