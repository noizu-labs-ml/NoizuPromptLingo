"use client";

import { use, useEffect, useState } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import { api, type Prompt, type PromptVersion } from "@/lib/api";
import { cyAttrs } from "@/utils/cypress";
import {
  Button,
  Card,
  DataTable,
  EmptyState,
  FormField,
  LoadingSkeleton,
  PageHeader,
  StatusPill,
  TextArea,
  TextInput,
  toast,
  type DataTableColumn,
} from "@/components/ui";

type VersionSummary = Pick<PromptVersion, "id" | "version_number" | "checksum" | "published_at">;

type Tab = "overview" | "sandbox";

type Binding = { key: string; value: string };

export default function PromptDetailPage({
  params,
}: {
  params: Promise<{ orgId: string; promptId: string }>;
}) {
  const { orgId, promptId } = use(params);
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();

  const [prompt, setPrompt] = useState<Prompt | null>(null);
  const [currentVersion, setCurrentVersion] = useState<PromptVersion | null>(null);
  const [versions, setVersions] = useState<VersionSummary[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Edit state
  const [editing, setEditing] = useState(false);
  const [editBody, setEditBody] = useState("");
  const [editTemplateVars, setEditTemplateVars] = useState("{}");
  const [editToolDefs, setEditToolDefs] = useState("{}");
  const [editJsonError, setEditJsonError] = useState<string | null>(null);
  const [publishing, setPublishing] = useState(false);

  // Sandbox state
  const [activeTab, setActiveTab] = useState<Tab>("overview");
  const [bindings, setBindings] = useState<Binding[]>([{ key: "", value: "" }]);
  const [sandboxResult, setSandboxResult] = useState<{
    rendered: string;
    note: string;
    tool_names: string[];
  } | null>(null);
  const [sandboxError, setSandboxError] = useState<string | null>(null);
  const [sandboxLoading, setSandboxLoading] = useState(false);

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login");
      return;
    }
    if (!user) return;

    api
      .getPrompt(orgId, promptId)
      .then((res) => {
        setPrompt(res.prompt);
        setCurrentVersion(res.current_version);
        setVersions(res.versions);
        if (res.current_version) {
          setEditBody(res.current_version.body);
          setEditTemplateVars(JSON.stringify(res.current_version.template_vars ?? {}, null, 2));
          setEditToolDefs(JSON.stringify(res.current_version.tool_defs ?? {}, null, 2));
        }
      })
      .catch((err) => setError(err instanceof Error ? err.message : "failed to load"))
      .finally(() => setLoading(false));
  }, [user, authLoading, router, orgId, promptId]);

  function validateJson(value: string, field: string): Record<string, unknown> | null {
    try {
      return JSON.parse(value);
    } catch {
      setEditJsonError(`${field}: invalid JSON`);
      return null;
    }
  }

  async function handlePublish() {
    setEditJsonError(null);
    const templateVars = validateJson(editTemplateVars, "Template vars");
    if (templateVars === null) return;
    const toolDefs = validateJson(editToolDefs, "Tool defs");
    if (toolDefs === null) return;

    setPublishing(true);
    try {
      const res = await api.publishPromptVersion(orgId, promptId, editBody, templateVars, toolDefs);
      setCurrentVersion(res.version);
      setVersions((prev) => {
        const exists = prev.find((v) => v.id === res.version.id);
        if (exists) return prev;
        return [
          {
            id: res.version.id,
            version_number: res.version.version_number,
            checksum: res.version.checksum,
            published_at: res.version.published_at,
          },
          ...prev,
        ];
      });
      setEditing(false);
      if (res.status === "noop") {
        toast.info("No changes detected — version unchanged.");
      } else {
        toast.success(`Version ${res.version.version_number} published.`);
      }
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "publish failed");
    } finally {
      setPublishing(false);
    }
  }

  function updateBinding(index: number, field: "key" | "value", value: string) {
    setBindings((prev) => {
      const next = [...prev];
      next[index] = { ...next[index], [field]: value };
      return next;
    });
  }

  function addBinding() {
    setBindings((prev) => [...prev, { key: "", value: "" }]);
  }

  function removeBinding(index: number) {
    setBindings((prev) => prev.filter((_, i) => i !== index));
  }

  async function handleSandbox() {
    setSandboxError(null);
    setSandboxResult(null);
    const bindingMap: Record<string, unknown> = {};
    for (const b of bindings) {
      if (b.key.trim()) bindingMap[b.key.trim()] = b.value;
    }
    setSandboxLoading(true);
    try {
      const res = await api.sandboxPrompt(orgId, promptId, bindingMap);
      setSandboxResult({ rendered: res.rendered, note: res.note, tool_names: res.tool_names });
    } catch (err) {
      const msg = err instanceof Error ? err.message : "render failed";
      if (msg.includes("undeclared") || msg.includes("missing")) {
        setSandboxError(`Variable error: ${msg}`);
      } else {
        setSandboxError(msg);
      }
    } finally {
      setSandboxLoading(false);
    }
  }

  if (authLoading || loading) {
    return (
      <div data-cy="app-loading" style={{ padding: "2rem 0" }}>
        <LoadingSkeleton variant="row" count={4} />
      </div>
    );
  }

  if (error || !prompt) {
    return (
      <div data-cy="prompt-detail-error">
        <EmptyState
          glyph="search"
          headline={error ?? "Prompt not found"}
          primaryAction={
            <Button variant="secondary" onClick={() => router.push(`/app/${orgId}/prompts`)}>
              Back to Prompts
            </Button>
          }
        />
      </div>
    );
  }

  const versionColumns: DataTableColumn<VersionSummary>[] = [
    {
      key: "version_number",
      label: "Version",
      width: 80,
      render: (v) => (
        <span data-cy="prompt-version-row" {...cyAttrs({ cyId: v.version_number })}>
          <strong>v{v.version_number}</strong>
          {v.id === prompt.current_version_id && (
            <span
              className="sg-pill sg-pill--sm"
              data-cy="prompt-version-current-badge"
              style={{ marginLeft: "var(--space-1)" }}
            >
              current
            </span>
          )}
        </span>
      ),
    },
    {
      key: "published_at",
      label: "Published",
      render: (v) => (
        <span className="sg-subtle" style={{ fontSize: "var(--text-small)" }}>
          {new Date(v.published_at).toLocaleString()}
        </span>
      ),
    },
  ];

  return (
    <div data-cy="prompt-detail-page" {...cyAttrs({ cyScope: "prompt-detail", cyId: prompt.slug })}>
      <PageHeader
        title={<span data-cy="prompt-detail-name">{prompt.name}</span>}
        subtitle={
          prompt.description ? (
            <span data-cy="prompt-detail-description">{prompt.description}</span>
          ) : undefined
        }
        breadcrumbs={[
          { label: "library", href: `/app/${orgId}` },
          { label: "prompts", href: `/app/${orgId}/prompts` },
          { label: prompt.slug, current: true },
        ]}
        actions={
          editing ? (
            <>
              <Button
                variant="ghost"
                cy="prompt-edit-toggle"
                onClick={() => {
                  setEditing(false);
                  setEditJsonError(null);
                }}
              >
                Cancel
              </Button>
              <Button
                variant="primary"
                cy="prompt-publish-btn"
                loading={publishing}
                onClick={handlePublish}
              >
                Publish version
              </Button>
            </>
          ) : (
            <Button
              variant="primary"
              cy="prompt-edit-toggle"
              onClick={() => {
                setEditing(true);
                setEditJsonError(null);
                if (currentVersion) {
                  setEditBody(currentVersion.body);
                  setEditTemplateVars(
                    JSON.stringify(currentVersion.template_vars ?? {}, null, 2),
                  );
                  setEditToolDefs(JSON.stringify(currentVersion.tool_defs ?? {}, null, 2));
                }
              }}
            >
              Edit body
            </Button>
          )
        }
      />

      {/* Tabs */}
      <div
        data-cy="prompt-detail-tabs"
        style={{
          display: "flex",
          gap: 0,
          borderBottom: "1px solid var(--border-subtle)",
          marginBottom: "var(--space-5)",
        }}
      >
        {(["overview", "sandbox"] as Tab[]).map((tab) => (
          <button
            key={tab}
            className="sg-btn sg-btn--ghost"
            data-cy={`prompt-tab-${tab}`}
            {...cyAttrs({ cyValue: activeTab === tab ? "active" : "inactive" })}
            onClick={() => setActiveTab(tab)}
            style={{
              borderRadius: 0,
              borderBottom: activeTab === tab ? "2px solid var(--accent)" : "2px solid transparent",
              marginBottom: -1,
              fontSize: "var(--text-body)",
              textTransform: "capitalize",
            }}
          >
            {tab}
          </button>
        ))}
      </div>

      <div className="sg-detail-grid">
        {/* Metadata aside */}
        <aside className="sg-detail-aside">
          <Card>
            <h3 className="sg-meta-label">Slug</h3>
            <p
              className="sg-meta-value sg-meta-value--mono"
              data-cy="prompt-detail-slug"
            >
              {prompt.slug}
            </p>
          </Card>

          <Card>
            <h3 className="sg-meta-label">Status</h3>
            <div className="sg-chip-row">
              {prompt.current_version_id ? (
                <StatusPill
                  state="pass"
                  label="published"
                  size="sm"
                  cy="prompt-detail-published-badge"
                />
              ) : (
                <StatusPill state="pending" label="draft" size="sm" />
              )}
            </div>
          </Card>

          {currentVersion && (
            <Card data-cy="prompt-current-version">
              <h3 className="sg-meta-label">Current Version</h3>
              <p className="sg-meta-value" data-cy="prompt-version-number">
                v{currentVersion.version_number}
              </p>
              <p
                className="sg-meta-value sg-meta-value--mono"
                data-cy="prompt-version-checksum"
              >
                {currentVersion.checksum}
              </p>
              <p
                className="sg-meta-value sg-subtle"
                data-cy="prompt-version-published-at"
              >
                {new Date(currentVersion.published_at).toLocaleString()}
              </p>
            </Card>
          )}

          {versions.length > 0 && (
            <Card data-cy="prompt-versions-section">
              <h3 className="sg-meta-label">Version History</h3>
              <DataTable<VersionSummary>
                columns={versionColumns}
                rows={versions}
                rowKey={(v) => v.id}
                compact
                cy="prompt-versions-table"
              />
            </Card>
          )}
        </aside>

        {/* Main column */}
        <main className="sg-detail-main">
          {activeTab === "overview" && (
            <div data-cy="prompt-tab-overview-panel">
              {editJsonError && (
                <p className="sg-field-error" data-cy="prompt-json-error">
                  {editJsonError}
                </p>
              )}

              {editing ? (
                <div
                  data-cy="prompt-editor"
                  className="sg-stack-md"
                >
                  <FormField label="Prompt body" name="body">
                    {(p) => (
                      <TextArea
                        {...p}
                        data-cy="prompt-body-input"
                        value={editBody}
                        onChange={(e) => setEditBody(e.target.value)}
                        rows={16}
                        className="sg-code"
                      />
                    )}
                  </FormField>

                  <FormField label="Template vars (JSON)" name="template_vars">
                    {(p) => (
                      <TextArea
                        {...p}
                        data-cy="prompt-template-vars-input"
                        value={editTemplateVars}
                        onChange={(e) => setEditTemplateVars(e.target.value)}
                        rows={5}
                        className="sg-code"
                      />
                    )}
                  </FormField>

                  <FormField label="Tool defs (JSON)" name="tool_defs">
                    {(p) => (
                      <TextArea
                        {...p}
                        data-cy="prompt-tool-defs-input"
                        value={editToolDefs}
                        onChange={(e) => setEditToolDefs(e.target.value)}
                        rows={5}
                        className="sg-code"
                      />
                    )}
                  </FormField>
                </div>
              ) : (
                <Card
                  data-cy="prompt-body-display"
                  className={`sg-code sg-code--wrap ${currentVersion?.body ? "" : "sg-subtle"}`}
                  style={{ minHeight: "4rem" }}
                >
                  {currentVersion?.body || "No body yet. Click Edit to add content."}
                </Card>
              )}
            </div>
          )}

          {activeTab === "sandbox" && (
            <div data-cy="prompt-tab-sandbox-panel">
              <p
                className="sg-muted"
                style={{ marginTop: 0, fontSize: "var(--text-small)" }}
              >
                Provide variable bindings to render the prompt template.
              </p>

              <Card style={{ marginBottom: "var(--space-4)" }}>
                <div
                  style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                    marginBottom: "var(--space-2)",
                  }}
                >
                  <strong>Bindings</strong>
                  <Button
                    variant="ghost"
                    size="sm"
                    cy="sandbox-add-binding"
                    onClick={addBinding}
                  >
                    + Add binding
                  </Button>
                </div>
                <div
                  data-cy="sandbox-bindings"
                  className="sg-stack-xs"
                >
                  {bindings.map((b, i) => (
                    <div
                      key={i}
                      data-cy="sandbox-binding-row"
                      className="sg-row-xs"
                    >
                      <TextInput
                        cy="sandbox-binding-key"
                        cyId={i}
                        type="text"
                        placeholder="variable"
                        value={b.key}
                        onChange={(e) => updateBinding(i, "key", e.target.value)}
                        className="sg-code"
                        style={{ flex: 1 }}
                      />
                      <span className="sg-subtle" style={{ flexShrink: 0 }}>=</span>
                      <TextInput
                        cy="sandbox-binding-value"
                        cyId={i}
                        type="text"
                        placeholder="value"
                        value={b.value}
                        onChange={(e) => updateBinding(i, "value", e.target.value)}
                        style={{ flex: 2 }}
                      />
                      <Button
                        variant="ghost"
                        size="sm"
                        cy="sandbox-remove-binding"
                        cyId={i}
                        onClick={() => removeBinding(i)}
                        aria-label="Remove binding"
                      >
                        ×
                      </Button>
                    </div>
                  ))}
                </div>
              </Card>

              <Button
                variant="primary"
                cy="sandbox-render-btn"
                loading={sandboxLoading}
                onClick={handleSandbox}
              >
                Render
              </Button>

              {sandboxError && (
                <Card variant="fail" data-cy="sandbox-error" style={{ marginTop: "var(--space-3)" }}>
                  {sandboxError}
                </Card>
              )}

              {sandboxResult && (
                <div data-cy="sandbox-result" style={{ marginTop: "var(--space-4)" }}>
                  {sandboxResult.note && (
                    <p
                      data-cy="sandbox-note"
                      className="sg-subtle"
                      style={{ fontSize: "var(--text-small)", marginTop: 0 }}
                    >
                      {sandboxResult.note}
                    </p>
                  )}
                  {sandboxResult.tool_names.length > 0 && (
                    <div className="sg-chip-row" style={{ marginBottom: "var(--space-3)" }}>
                      {sandboxResult.tool_names.map((t) => (
                        <span
                          key={t}
                          className="sg-pill sg-pill--sm"
                          data-cy="sandbox-tool-name"
                        >
                          {t}
                        </span>
                      ))}
                    </div>
                  )}
                  <Card
                    data-cy="sandbox-rendered"
                    className="sg-code sg-code--wrap sg-code--scroll"
                  >
                    {sandboxResult.rendered}
                  </Card>
                </div>
              )}
            </div>
          )}
        </main>
      </div>
    </div>
  );
}
