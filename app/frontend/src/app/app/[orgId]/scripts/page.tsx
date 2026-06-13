"use client";

import { use, useEffect, useState } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import { api, type Script } from "@/lib/api";
import { cyAttrs } from "@/utils/cypress";
import {
  PageHeader,
  Button,
  Card,
  EmptyState,
  LoadingSkeleton,
  Modal,
  FormField,
  TextInput,
  TextArea,
} from "@/components/ui";

export default function ScriptsPage({
  params,
}: {
  params: Promise<{ orgId: string }>;
}) {
  const { orgId } = use(params);
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();

  const [scripts, setScripts] = useState<Script[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [creating, setCreating] = useState(false);
  const [newName, setNewName] = useState("");
  const [importing, setImporting] = useState(false);
  const [importYaml, setImportYaml] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [publishing, setPublishing] = useState<string | null>(null);

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login");
      return;
    }
    if (!user) return;

    api
      .listScripts(orgId)
      .then((res) => setScripts(res.scripts))
      .catch((err) => setError(err instanceof Error ? err.message : "failed to load"))
      .finally(() => setLoading(false));
  }, [user, authLoading, router, orgId]);

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault();
    if (!newName.trim()) return;
    setSubmitting(true);
    try {
      const res = await api.createScript(orgId, newName.trim());
      setScripts((prev) => [res.script, ...prev]);
      setNewName("");
      setCreating(false);
    } catch (err) {
      setError(err instanceof Error ? err.message : "failed to create");
    } finally {
      setSubmitting(false);
    }
  }

  async function handleImport(e: React.FormEvent) {
    e.preventDefault();
    if (!importYaml.trim()) return;
    setSubmitting(true);
    try {
      const res = await api.importScriptYaml(orgId, importYaml.trim());
      setScripts((prev) => [res.script, ...prev]);
      setImportYaml("");
      setImporting(false);
    } catch (err) {
      setError(err instanceof Error ? err.message : "failed to import");
    } finally {
      setSubmitting(false);
    }
  }

  async function handlePublish(scriptId: string) {
    setPublishing(scriptId);
    try {
      await api.publishScript(orgId, scriptId);
      const res = await api.listScripts(orgId);
      setScripts(res.scripts);
    } catch (err) {
      setError(err instanceof Error ? err.message : "failed to publish");
    } finally {
      setPublishing(null);
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
    <div data-cy="scripts-page" {...cyAttrs({ cyScope: "scripts" })}>
      <PageHeader
        title="Scripts"
        subtitle="Conversation graphs with nodes, edges, expectations."
        actions={
          <>
            <Button variant="ghost" cy="scripts-import" onClick={() => setImporting(true)}>
              Import YAML
            </Button>
            <Button variant="primary" cy="scripts-create" onClick={() => setCreating(true)}>
              + New Script
            </Button>
          </>
        }
      />

      {error && (
        <p className="sg-error" data-cy="scripts-error">
          {error}
        </p>
      )}

      {loading ? (
        <LoadingSkeleton variant="card" count={4} />
      ) : scripts.length === 0 ? (
        <EmptyState
          glyph="scripts"
          headline="No scripts yet"
          body="Create your first evaluation script to start testing agent behavior."
          primaryAction={
            <Button variant="primary" cy="scripts-empty-create" onClick={() => setCreating(true)}>
              + Create Script
            </Button>
          }
          secondaryAction={
            <Button variant="ghost" cy="scripts-empty-import" onClick={() => setImporting(true)}>
              Import YAML
            </Button>
          }
        />
      ) : (
        <div
          data-cy="scripts-list"
          {...cyAttrs({ cyId: "scripts" })}
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))",
            gap: "1rem",
          }}
        >
          {scripts.map((script) => (
            <Card
              key={script.id}
              interactive
              cy="script-row"
              cyId={script.slug}
              onClick={() => router.push(`/app/${orgId}/scripts/${script.id}`)}
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
                <strong data-cy="script-name" style={{ fontSize: "1.05rem" }}>
                  {script.name}
                </strong>
                {script.current_version_id && (
                  <span
                    className="sg-pill sg-pill--sm eval-pass"
                    data-cy="script-version-badge"
                  >
                    published
                  </span>
                )}
              </div>
              <div
                data-cy="script-slug"
                {...cyAttrs({ cyValue: script.slug })}
                style={{
                  fontSize: "0.8rem",
                  color: "var(--text-tertiary)",
                  fontFamily: "var(--font-mono, monospace)",
                  marginBottom: "0.5rem",
                }}
              >
                {script.slug}
              </div>
              {script.description && (
                <p
                  data-cy="script-description"
                  style={{
                    margin: 0,
                    fontSize: "0.875rem",
                    color: "var(--text-secondary)",
                    lineHeight: 1.5,
                  }}
                >
                  {script.description}
                </p>
              )}
              <div style={{ marginTop: "0.75rem", display: "flex", justifyContent: "flex-end" }}>
                <Button
                  variant="ghost"
                  size="sm"
                  cy="script-publish"
                  cyId={script.slug}
                  loading={publishing === script.id}
                  onClick={(e) => {
                    e.stopPropagation();
                    handlePublish(script.id);
                  }}
                >
                  Publish
                </Button>
              </div>
            </Card>
          ))}
        </div>
      )}

      {/* Create modal */}
      <Modal
        open={creating}
        onClose={() => setCreating(false)}
        title="New Script"
        cy="scripts-create-modal"
        footer={
          <div style={{ display: "flex", gap: "0.5rem", justifyContent: "flex-end", width: "100%" }}>
            <Button variant="ghost" cy="scripts-create-cancel" onClick={() => setCreating(false)}>
              Cancel
            </Button>
            <Button
              variant="primary"
              cy="scripts-create-submit"
              loading={submitting}
              disabled={!newName.trim()}
              onClick={(e) => handleCreate(e as unknown as React.FormEvent)}
            >
              Create
            </Button>
          </div>
        }
      >
        <form data-cy="scripts-create-form" onSubmit={handleCreate}>
          <FormField label="Name" name="name" required>
            {(p) => (
              <TextInput
                {...p}
                cy="scripts-name-input"
                type="text"
                value={newName}
                onChange={(e) => setNewName(e.target.value)}
                placeholder="My script"
                autoFocus
              />
            )}
          </FormField>
        </form>
      </Modal>

      {/* Import YAML modal */}
      <Modal
        open={importing}
        onClose={() => setImporting(false)}
        title="Import Script from YAML"
        cy="scripts-import-modal"
        footer={
          <div style={{ display: "flex", gap: "0.5rem", justifyContent: "flex-end", width: "100%" }}>
            <Button variant="ghost" cy="scripts-import-cancel" onClick={() => setImporting(false)}>
              Cancel
            </Button>
            <Button
              variant="primary"
              cy="scripts-import-submit"
              loading={submitting}
              disabled={!importYaml.trim()}
              onClick={(e) => handleImport(e as unknown as React.FormEvent)}
            >
              Import
            </Button>
          </div>
        }
      >
        <form data-cy="scripts-import-form" onSubmit={handleImport}>
          <FormField label="YAML" name="yaml" required>
            {(p) => (
              <TextArea
                {...p}
                cy="scripts-import-yaml"
                value={importYaml}
                onChange={(e) => setImportYaml(e.target.value)}
                placeholder={"script:\n  name: My Script\n  nodes: []"}
                rows={10}
                className="sg-input sg-input--code"
                autoFocus
              />
            )}
          </FormField>
        </form>
      </Modal>
    </div>
  );
}
