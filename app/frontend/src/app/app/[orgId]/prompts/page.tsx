"use client";

import * as React from "react";
import { use, useEffect, useState } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { api, type Prompt } from "@/lib/api";
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
} from "@/components/ui";

export default function PromptsPage({
  params,
}: {
  params: Promise<{ orgId: string }>;
}) {
  const { orgId } = use(params);
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();

  const [prompts, setPrompts] = useState<Prompt[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [creating, setCreating] = useState(false);
  const [newName, setNewName] = useState("");
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login");
      return;
    }
    if (!user) return;

    api
      .listPrompts(orgId)
      .then((res) => setPrompts(res.prompts))
      .catch((err) => setError(err instanceof Error ? err.message : "failed to load"))
      .finally(() => setLoading(false));
  }, [user, authLoading, router, orgId]);

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault();
    if (!newName.trim()) return;
    setSubmitting(true);
    try {
      const res = await api.createPrompt(orgId, newName.trim());
      setPrompts((prev) => [res.prompt, ...prev]);
      setNewName("");
      setCreating(false);
    } catch (err) {
      setError(err instanceof Error ? err.message : "failed to create");
    } finally {
      setSubmitting(false);
    }
  }

  async function handleArchive(promptId: string) {
    // Archive not yet in api.ts — placeholder to show intent
    setPrompts((prev) => prev.filter((p) => p.id !== promptId));
  }

  if (authLoading) {
    return (
      <div data-cy="app-loading" className="sg-app-loading">
        Loading…
      </div>
    );
  }

  return (
    <div data-cy="prompts-page" {...cyAttrs({ cyScope: "prompts" })}>
      <PageHeader
        title="Prompts"
        subtitle="Reusable prompt templates with variables and tool definitions."
        actions={
          <>
            <Link
              href={`/app/${orgId}/prompts?template=starter`}
              data-cy="prompts-templates-link"
              className="sg-btn sg-btn--ghost"
            >
              Browse templates
            </Link>
            <Button
              variant="primary"
              cy="prompts-create"
              onClick={() => setCreating(true)}
            >
              + New Prompt
            </Button>
          </>
        }
      />

      {error && (
        <p className="sg-error" data-cy="prompts-error">
          {error}
        </p>
      )}

      {loading ? (
        <LoadingSkeleton variant="card" count={4} />
      ) : prompts.length === 0 ? (
        <EmptyState
          glyph="prompts"
          headline="No prompts yet"
          body="Create your first prompt template to reuse across scripts and agents."
          primaryAction={
            <Button variant="primary" cy="prompts-empty-create" onClick={() => setCreating(true)}>
              + Create Prompt
            </Button>
          }
        />
      ) : (
        <div
          data-cy="prompts-list"
          {...cyAttrs({ cyId: "prompts" })}
          className="sg-resource-grid sg-stagger"
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))",
            gap: "1rem",
          }}
        >
          {prompts.map((prompt, i) => (
            <Card
              key={prompt.id}
              interactive
              cy="prompt-row"
              cyId={prompt.slug}
              onClick={() => router.push(`/app/${orgId}/prompts/${prompt.id}`)}
              style={{ "--i": i } as React.CSSProperties}
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
                <strong data-cy="prompt-name" style={{ fontSize: "1.05rem" }}>
                  {prompt.name}
                </strong>
                {prompt.current_version_id && (
                  <span
                    className="sg-pill sg-pill--sm eval-pass"
                    data-cy="prompt-version-badge"
                  >
                    published
                  </span>
                )}
              </div>
              <div
                data-cy="prompt-slug"
                {...cyAttrs({ cyValue: prompt.slug })}
                style={{
                  fontSize: "0.8rem",
                  color: "var(--text-tertiary)",
                  fontFamily: "var(--font-mono, monospace)",
                  marginBottom: "0.5rem",
                }}
              >
                {prompt.slug}
              </div>
              {prompt.description && (
                <p
                  data-cy="prompt-description"
                  style={{
                    margin: 0,
                    fontSize: "0.875rem",
                    color: "var(--text-secondary)",
                    lineHeight: 1.5,
                  }}
                >
                  {prompt.description}
                </p>
              )}
              <div style={{ marginTop: "0.75rem", display: "flex", justifyContent: "flex-end" }}>
                <Button
                  variant="ghost"
                  size="sm"
                  cy="prompt-archive"
                  cyId={prompt.slug}
                  onClick={(e) => {
                    e.stopPropagation();
                    handleArchive(prompt.id);
                  }}
                >
                  Archive
                </Button>
              </div>
            </Card>
          ))}
        </div>
      )}

      <Modal
        open={creating}
        onClose={() => setCreating(false)}
        title="New Prompt"
        cy="prompts-create-modal"
        footer={
          <div style={{ display: "flex", gap: "0.5rem", justifyContent: "flex-end", width: "100%" }}>
            <Button variant="ghost" cy="prompts-create-cancel" onClick={() => setCreating(false)}>
              Cancel
            </Button>
            <Button
              variant="primary"
              cy="prompts-create-submit"
              loading={submitting}
              disabled={!newName.trim()}
              onClick={(e) => handleCreate(e as unknown as React.FormEvent)}
            >
              Create
            </Button>
          </div>
        }
      >
        <form data-cy="prompts-create-form" onSubmit={handleCreate}>
          <FormField label="Name" name="name" required>
            {(p) => (
              <TextInput
                {...p}
                cy="prompts-name-input"
                type="text"
                value={newName}
                onChange={(e) => setNewName(e.target.value)}
                placeholder="My prompt"
                autoFocus
              />
            )}
          </FormField>
        </form>
      </Modal>
    </div>
  );
}
