"use client";

import { use, useEffect, useState } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import { api, type OtelSpan } from "@/lib/api";
import { cyAttrs } from "@/utils/cypress";
import {
  PageHeader,
  Button,
  EmptyState,
  LoadingSkeleton,
  TextInput,
} from "@/components/ui";

function durationLabel(ns: number): string {
  if (ns >= 1_000_000_000) return `${(ns / 1_000_000_000).toFixed(2)}s`;
  if (ns >= 1_000_000) return `${(ns / 1_000_000).toFixed(1)}ms`;
  if (ns >= 1_000) return `${(ns / 1_000).toFixed(0)}µs`;
  return `${ns}ns`;
}

function statusColor(code: string): string {
  if (code === "STATUS_CODE_ERROR") return "var(--eval-fail)";
  if (code === "STATUS_CODE_OK") return "var(--eval-pass)";
  return "var(--text-tertiary)";
}

type SpanNode = OtelSpan & { children: SpanNode[] };

function buildTree(spans: OtelSpan[]): SpanNode[] {
  const byId = new Map<string, SpanNode>();
  spans.forEach((s) => byId.set(s.span_id, { ...s, children: [] }));
  const roots: SpanNode[] = [];
  byId.forEach((node) => {
    if (node.parent_span_id && byId.has(node.parent_span_id)) {
      byId.get(node.parent_span_id)!.children.push(node);
    } else {
      roots.push(node);
    }
  });
  return roots;
}

function SpanRow({ node, depth }: { node: SpanNode; depth: number }) {
  const [open, setOpen] = useState(depth < 2);
  const attrs = node.attributes as Record<string, unknown>;
  const attrPreview = Object.entries(attrs)
    .slice(0, 2)
    .map(([k, v]) => `${k}=${JSON.stringify(v)}`)
    .join(" ");

  return (
    <>
      <tr
        data-cy="otel-span-row"
        {...cyAttrs({ cyId: node.span_id })}
        style={{ borderBottom: "1px solid var(--border-default)" }}
      >
        <td style={{ padding: "0.4rem 0.5rem", paddingLeft: `${0.5 + depth * 1.25}rem` }}>
          {node.children.length > 0 && (
            <button
              type="button"
              data-cy="otel-span-toggle"
              onClick={() => setOpen((v) => !v)}
              style={{
                background: "none",
                border: "none",
                cursor: "pointer",
                fontSize: "0.75rem",
                marginRight: "0.25rem",
                color: "var(--text-tertiary)",
              }}
              aria-label={open ? "Collapse span" : "Expand span"}
            >
              {open ? "▼" : "▶"}
            </button>
          )}
          <span
            data-cy="otel-span-name"
            className="sg-mono"
            style={{ fontSize: "0.85rem" }}
          >
            {node.name}
          </span>
        </td>
        <td style={{ padding: "0.4rem 0.5rem", fontSize: "0.82rem", whiteSpace: "nowrap" }}>
          <span data-cy="otel-span-duration">{durationLabel(node.duration_ns)}</span>
        </td>
        <td style={{ padding: "0.4rem 0.5rem" }}>
          <span
            data-cy="otel-span-status"
            style={{ fontSize: "0.78rem", color: statusColor(node.status_code) }}
          >
            {node.status_code.replace("STATUS_CODE_", "")}
          </span>
        </td>
        <td
          data-cy="otel-span-attrs"
          style={{
            padding: "0.4rem 0.5rem",
            fontSize: "0.75rem",
            color: "var(--text-tertiary)",
            fontFamily: "var(--font-mono, monospace)",
            maxWidth: 300,
            overflow: "hidden",
            textOverflow: "ellipsis",
            whiteSpace: "nowrap",
          }}
        >
          {attrPreview || "—"}
        </td>
      </tr>
      {open &&
        node.children.map((child) => (
          <SpanRow key={child.span_id} node={child} depth={depth + 1} />
        ))}
    </>
  );
}

export default function OtelPage({
  params,
}: {
  params: Promise<{ orgId: string }>;
}) {
  const { orgId } = use(params);
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();

  const [runId, setRunId] = useState("");
  const [attrQuery, setAttrQuery] = useState("");
  const [spans, setSpans] = useState<OtelSpan[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [searched, setSearched] = useState(false);

  const [isAdmin, setIsAdmin] = useState(false);

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login");
      return;
    }
    if (!user) return;
    api
      .getOrganization(orgId)
      .then((res) => {
        if (res.organization.role === "admin") setIsAdmin(true);
      })
      .catch(() => {});
  }, [user, authLoading, router, orgId]);

  async function handleSearch(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setSearched(true);
    try {
      let parsedAttrs: Record<string, unknown> | undefined;
      if (attrQuery.trim()) {
        try {
          parsedAttrs = JSON.parse(attrQuery);
        } catch {
          setError("Attributes must be valid JSON object");
          setLoading(false);
          return;
        }
      }
      const res = await api.searchOtelSpans(orgId, {
        ...(runId.trim() ? { run_id: runId.trim() } : {}),
        ...(parsedAttrs ? { attributes: parsedAttrs } : {}),
      });
      setSpans(res.spans ?? []);
    } catch (e) {
      const msg = e instanceof Error ? e.message : "search failed";
      if (msg.includes("404")) {
        setSpans([]);
      } else {
        setError(msg);
      }
    } finally {
      setLoading(false);
    }
  }

  const tree = buildTree(spans);

  if (authLoading) {
    return (
      <div data-cy="app-loading" className="sg-app-loading">
        Loading…
      </div>
    );
  }

  return (
    <div data-cy="otel-page" {...cyAttrs({ cyScope: "otel" })}>
      <PageHeader
        title="OTel Traces"
        subtitle="Search distributed traces by run ID or attribute filter."
        actions={
          isAdmin ? (
            <Button
              variant="ghost"
              cy="otel-policies-link"
              href={`/app/${orgId}/otel/policies`}
            >
              Sampling Policies
            </Button>
          ) : undefined
        }
      />

      <form
        data-cy="otel-search-form"
        onSubmit={handleSearch}
        style={{ display: "flex", gap: "0.75rem", flexWrap: "wrap", marginBottom: "1.5rem" }}
      >
        <TextInput
          cy="otel-run-id-input"
          placeholder="Run ID (UUID)"
          value={runId}
          onChange={(e) => setRunId(e.target.value)}
          style={{ flex: 1, minWidth: 200 }}
        />
        <TextInput
          cy="otel-attrs-input"
          placeholder='Attributes JSON e.g. {"service.name":"foo"}'
          value={attrQuery}
          onChange={(e) => setAttrQuery(e.target.value)}
          style={{ flex: 2, minWidth: 260 }}
        />
        <Button
          type="submit"
          variant="primary"
          cy="otel-search-btn"
          loading={loading}
          onClick={(e) => handleSearch(e as unknown as React.FormEvent)}
        >
          Search
        </Button>
      </form>

      {error && (
        <p className="sg-error" data-cy="otel-error">
          {error}
        </p>
      )}

      {!searched && !loading && (
        <EmptyState
          glyph="search"
          headline="Search traces"
          body="Enter a Run ID or attribute filter above to load spans."
        />
      )}

      {loading && <LoadingSkeleton variant="row" count={6} />}

      {searched && !loading && spans.length === 0 && !error && (
        <EmptyState
          glyph="search"
          headline="No spans found"
          body="Try a different run ID or attribute filter."
        />
      )}

      {spans.length > 0 && !loading && (
        <table
          data-cy="otel-spans-table"
          className="sg-table"
          style={{ width: "100%", borderCollapse: "collapse", fontSize: "0.9rem" }}
        >
          <thead>
            <tr style={{ borderBottom: "2px solid var(--border-default)" }}>
              <th style={{ padding: "0.5rem", textAlign: "left" }}>Span name</th>
              <th style={{ padding: "0.5rem", textAlign: "left", whiteSpace: "nowrap" }}>Duration</th>
              <th style={{ padding: "0.5rem", textAlign: "left" }}>Status</th>
              <th style={{ padding: "0.5rem", textAlign: "left" }}>Attributes preview</th>
            </tr>
          </thead>
          <tbody>
            {tree.map((root) => (
              <SpanRow key={root.span_id} node={root} depth={0} />
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}
