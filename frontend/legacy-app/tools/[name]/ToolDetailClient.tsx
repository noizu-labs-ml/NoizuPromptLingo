"use client";

import { useState } from "react";
import { useParams } from "next/navigation";
import useSWR from "swr";
import { WrenchScrewdriverIcon } from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import type { ToolParam, ToolInvokeResult } from "@/lib/api/types";

import { Card } from "@/components/primitives/Card";
import { Badge } from "@/components/primitives/Badge";
import { CodeBlock } from "@/components/primitives/CodeBlock";
import { EmptyState } from "@/components/primitives/EmptyState";
import { DataTable } from "@/components/primitives/DataTable";
import { Button } from "@/components/primitives/Button";
import { Input } from "@/components/primitives/Input";
import { Textarea } from "@/components/primitives/Textarea";
import { FormField } from "@/components/primitives/FormField";
import { DetailHeader } from "@/components/composites/DetailHeader";

// ── Param input ───────────────────────────────────────────────────────────

function ParamInput({
  param,
  value,
  onChange,
}: {
  param: ToolParam;
  value: string;
  onChange: (v: string) => void;
}) {
  if (param.type === "bool") {
    return (
      <div className="flex items-center gap-2">
        <input
          type="checkbox"
          id={`param-${param.name}`}
          checked={value === "true"}
          onChange={(e) => onChange(e.target.checked ? "true" : "false")}
          className="focus-ring h-4 w-4 rounded border-border text-accent"
        />
        <label htmlFor={`param-${param.name}`} className="text-sm text-muted">
          {value === "true" ? "true" : "false"}
        </label>
      </div>
    );
  }

  if (param.type === "int" || param.type === "float") {
    return (
      <Input
        type="number"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={`Enter ${param.type}…`}
        step={param.type === "float" ? "any" : "1"}
      />
    );
  }

  if (param.type === "list") {
    return (
      <Textarea
        value={value}
        onChange={(e) => onChange(e.target.value)}
        rows={3}
        placeholder="One item per line…"
      />
    );
  }

  if (param.type === "dict") {
    return (
      <Textarea
        value={value}
        onChange={(e) => onChange(e.target.value)}
        rows={4}
        mono
        placeholder='{"key": "value"}'
      />
    );
  }

  return (
    <Input
      type="text"
      value={value}
      onChange={(e) => onChange(e.target.value)}
      placeholder="Enter value…"
    />
  );
}

function parseParamValue(param: ToolParam, raw: string): unknown {
  if (raw === "") return undefined;

  switch (param.type) {
    case "bool":
      return raw === "true";
    case "int":
      return parseInt(raw, 10);
    case "float":
      return parseFloat(raw);
    case "list":
      return raw
        .split("\n")
        .map((s) => s.trim())
        .filter(Boolean);
    case "dict": {
      try {
        return JSON.parse(raw);
      } catch {
        return raw;
      }
    }
    default:
      return raw;
  }
}

// ── Try It panel ──────────────────────────────────────────────────────────

function TryItPanel({
  toolName,
  params,
}: {
  toolName: string;
  params: ToolParam[];
}) {
  const [values, setValues] = useState<Record<string, string>>(() => {
    const init: Record<string, string> = {};
    params.forEach((p) => {
      init[p.name] = p.type === "bool" ? "false" : "";
    });
    return init;
  });

  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<ToolInvokeResult | null>(null);
  const [error, setError] = useState<string | null>(null);

  const handleInvoke = async () => {
    setLoading(true);
    setResult(null);
    setError(null);

    try {
      const args: Record<string, unknown> = {};
      params.forEach((p) => {
        const raw = values[p.name] ?? "";
        if (raw !== "" || p.required) {
          const parsed = parseParamValue(p, raw);
          if (parsed !== undefined) {
            args[p.name] = parsed;
          }
        }
      });

      const res = await api.tools.invoke(toolName, args);
      setResult(res);
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
    } finally {
      setLoading(false);
    }
  };

  const setValue = (name: string, v: string) =>
    setValues((prev) => ({ ...prev, [name]: v }));

  return (
    <div className="flex flex-col gap-4">
      {params.length === 0 ? (
        <p className="text-sm text-muted">This tool takes no parameters.</p>
      ) : (
        <div className="flex flex-col gap-4">
          {params.map((param) => {
            const fieldId = `param-${param.name}`;
            const label = (
              <span className="flex items-center gap-2 normal-case tracking-normal">
                <span className="font-mono text-sm text-foreground">{param.name}</span>
                <span className="text-xs text-subtle font-mono">({param.type})</span>
                {param.required && (
                  <Badge variant="warning" size="sm">
                    required
                  </Badge>
                )}
              </span>
            );
            return (
              <FormField
                key={param.name}
                label={label}
                htmlFor={fieldId}
                helper={param.description || undefined}
              >
                <ParamInput
                  param={param}
                  value={values[param.name] ?? ""}
                  onChange={(v) => setValue(param.name, v)}
                />
              </FormField>
            );
          })}
        </div>
      )}

      <div>
        <Button
          type="button"
          onClick={handleInvoke}
          disabled={loading}
          loading={loading}
        >
          {loading ? "Invoking…" : "Invoke"}
        </Button>
      </div>

      {error && (
        <div
          role="alert"
          className="rounded-md bg-danger/10 border border-danger/30 px-4 py-3"
        >
          <p className="text-sm text-danger font-medium">Error</p>
          <p className="text-sm text-danger mt-1">{error}</p>
        </div>
      )}

      {result && (
        <div className="flex flex-col gap-2">
          <div className="flex items-center gap-2">
            <p className="text-sm font-medium text-foreground">Result</p>
            <Badge
              variant={
                result.status === "ok"
                  ? "success"
                  : result.status === "error"
                  ? "danger"
                  : "warning"
              }
              size="sm"
            >
              {result.status}
            </Badge>
            {result.duration_ms != null && (
              <span className="text-xs text-muted">{result.duration_ms}ms</span>
            )}
          </div>
          {result.message && (
            <p className="text-sm text-muted">{result.message}</p>
          )}
          <CodeBlock
            code={JSON.stringify(result.result ?? result, null, 2)}
            language="json"
            maxHeight="400px"
          />
        </div>
      )}
    </div>
  );
}

// ── Main client component ─────────────────────────────────────────────────

export function ToolDetailClient() {
  const params = useParams();
  const rawName = params?.name;
  const toolName = Array.isArray(rawName)
    ? decodeURIComponent(rawName[0])
    : typeof rawName === "string"
    ? decodeURIComponent(rawName)
    : null;

  const { data: tool, isLoading } = useSWR(
    toolName ? `tools.get.${toolName}` : null,
    () => api.tools.get(toolName!)
  );

  if (!toolName) {
    return (
      <EmptyState
        icon={<WrenchScrewdriverIcon />}
        title="No tool specified"
        description="Navigate to a tool from the catalog."
      />
    );
  }

  if (isLoading) {
    return (
      <div className="flex flex-col gap-6">
        <div className="h-16 rounded-lg bg-surface-1 border border-border animate-pulse" />
        <div className="h-64 rounded-lg bg-surface-1 border border-border animate-pulse" />
      </div>
    );
  }

  if (!tool) {
    return (
      <EmptyState
        icon={<WrenchScrewdriverIcon />}
        title={`Tool "${toolName}" not found`}
        description="This tool does not exist in the catalog."
      />
    );
  }

  const paramColumns = [
    {
      key: "name",
      header: "Name",
      render: (row: ToolParam) => (
        <span className="font-mono text-sm">{row.name}</span>
      ),
    },
    {
      key: "type",
      header: "Type",
      render: (row: ToolParam) => (
        <span className="font-mono text-xs text-muted">{row.type}</span>
      ),
    },
    {
      key: "required",
      header: "Required",
      render: (row: ToolParam) => (
        <Badge variant={row.required ? "warning" : "default"} size="sm">
          {row.required ? "required" : "optional"}
        </Badge>
      ),
    },
    {
      key: "description",
      header: "Description",
      render: (row: ToolParam) => (
        <span className="text-sm text-muted">{row.description || "—"}</span>
      ),
    },
  ];

  return (
    <div className="flex flex-col gap-8">
      {/* Header */}
      <DetailHeader
        breadcrumbs={[
          { label: "Tools", href: "/tools" },
          { label: tool.name },
        ]}
        backHref="/tools"
        backLabel="Back to tools"
        title={tool.name}
        description={tool.description}
        actions={
          <div className="flex flex-wrap items-center gap-2">
            <Badge variant="success" size="sm">
              registered
            </Badge>
            <Badge variant="accent" size="sm">
              {tool.category}
            </Badge>
            {(tool.tags ?? []).map((tag) => (
              <Badge key={tag} variant="default" size="sm">
                {tag}
              </Badge>
            ))}
          </div>
        }
      />

      {/* Parameters */}
      <section className="flex flex-col gap-3">
        <h2 className="text-base font-semibold text-foreground">Parameters</h2>
        {tool.parameters.length === 0 ? (
          <EmptyState
            title="No parameters"
            description="This tool takes no input parameters."
          />
        ) : (
          <DataTable
            columns={paramColumns}
            rows={tool.parameters}
            rowKey={(row) => row.name}
            emptyMessage="No parameters."
          />
        )}
      </section>

      {/* Metadata */}
      <section className="flex flex-col gap-3">
        <h2 className="text-base font-semibold text-foreground">Metadata</h2>
        <Card>
          <dl className="grid grid-cols-1 sm:grid-cols-2 gap-x-6 gap-y-3 text-sm">
            <div className="flex flex-col gap-0.5">
              <dt className="text-xs text-muted uppercase tracking-wide font-medium">
                Category
              </dt>
              <dd className="text-foreground font-mono text-sm">{tool.category}</dd>
            </div>

            {tool.title && (
              <div className="flex flex-col gap-0.5">
                <dt className="text-xs text-muted uppercase tracking-wide font-medium">
                  Title
                </dt>
                <dd className="text-foreground">{tool.title}</dd>
              </div>
            )}

            {tool.version && (
              <div className="flex flex-col gap-0.5">
                <dt className="text-xs text-muted uppercase tracking-wide font-medium">
                  Version
                </dt>
                <dd className="text-foreground font-mono">{tool.version}</dd>
              </div>
            )}

            <div className="flex flex-col gap-0.5">
              <dt className="text-xs text-muted uppercase tracking-wide font-medium">
                Tier
              </dt>
              <dd>
                <Badge variant="success" size="sm">
                  MCP-registered
                </Badge>
              </dd>
            </div>

            {tool.tags && tool.tags.length > 0 && (
              <div className="flex flex-col gap-0.5 sm:col-span-2">
                <dt className="text-xs text-muted uppercase tracking-wide font-medium">
                  Tags
                </dt>
                <dd className="flex flex-wrap gap-1">
                  {tool.tags.map((tag) => (
                    <Badge key={tag} variant="default" size="sm">
                      {tag}
                    </Badge>
                  ))}
                </dd>
              </div>
            )}
          </dl>
        </Card>
      </section>

      {/* Try It */}
      <section className="flex flex-col gap-3">
        <h2 className="text-base font-semibold text-foreground">Try It</h2>
        <Card>
          <TryItPanel toolName={tool.name} params={tool.parameters} />
        </Card>
      </section>
    </div>
  );
}
