"use client";

import { use, useEffect, useState } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import { api, type Persona } from "@/lib/api";
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

type PersonaStarter = {
  slug: string;
  name: string;
  tone: string;
  description: string;
  sample_preamble: string;
};

export default function PersonasPage({
  params,
}: {
  params: Promise<{ orgId: string }>;
}) {
  const { orgId } = use(params);
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();

  const [personas, setPersonas] = useState<Persona[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Create modal
  const [creating, setCreating] = useState(false);
  const [newName, setNewName] = useState("");
  const [submitting, setSubmitting] = useState(false);

  // Starter modal
  const [showStarterModal, setShowStarterModal] = useState(false);
  const [starters, setStarters] = useState<PersonaStarter[]>([]);
  const [startersLoading, setStartersLoading] = useState(false);
  const [importingSlug, setImportingSlug] = useState<string | null>(null);

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login");
      return;
    }
    if (!user) return;

    api
      .listPersonas(orgId)
      .then((res) => setPersonas(res.personas))
      .catch((err) => setError(err instanceof Error ? err.message : "failed to load"))
      .finally(() => setLoading(false));
  }, [user, authLoading, router, orgId]);

  async function openStarterModal() {
    setShowStarterModal(true);
    setStartersLoading(true);
    try {
      const res = await api.listPersonaStarters();
      setStarters(res.starters);
    } catch (err) {
      setError(err instanceof Error ? err.message : "failed to load starters");
    } finally {
      setStartersLoading(false);
    }
  }

  async function handleImportStarter(slug: string) {
    setImportingSlug(slug);
    try {
      const res = await api.importPersonaStarter(orgId, slug);
      setPersonas((prev) => [res.persona, ...prev]);
      setShowStarterModal(false);
    } catch (err) {
      setError(err instanceof Error ? err.message : "failed to import");
    } finally {
      setImportingSlug(null);
    }
  }

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault();
    if (!newName.trim()) return;
    setSubmitting(true);
    try {
      const res = await api.createPersona(orgId, newName.trim());
      setPersonas((prev) => [res.persona, ...prev]);
      setNewName("");
      setCreating(false);
    } catch (err) {
      setError(err instanceof Error ? err.message : "failed to create");
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

  return (
    <div data-cy="personas-page" {...cyAttrs({ cyScope: "personas" })}>
      <PageHeader
        title="Personas"
        subtitle="User-voice personas with tone tags. Import from the starter library or craft your own."
        actions={
          <>
            <Button
              variant="ghost"
              cy="personas-import-starter"
              onClick={openStarterModal}
            >
              Import from starter library
            </Button>
            <Button variant="primary" cy="personas-create" onClick={() => setCreating(true)}>
              + New Persona
            </Button>
          </>
        }
      />

      {error && (
        <p className="sg-error" data-cy="personas-error">
          {error}
        </p>
      )}

      {loading ? (
        <LoadingSkeleton variant="card" count={4} />
      ) : personas.length === 0 ? (
        <EmptyState
          glyph="personas"
          headline="No personas yet"
          body="Import a starter persona or create your own to simulate user voices in scripts."
          primaryAction={
            <Button variant="primary" cy="personas-empty-create" onClick={() => setCreating(true)}>
              + Create Persona
            </Button>
          }
          secondaryAction={
            <Button variant="ghost" cy="personas-empty-starter" onClick={openStarterModal}>
              Import starter
            </Button>
          }
        />
      ) : (
        <div
          data-cy="personas-list"
          {...cyAttrs({ cyId: "personas" })}
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))",
            gap: "1rem",
          }}
        >
          {personas.map((persona) => (
            <Card
              key={persona.id}
              interactive
              cy="persona-row"
              cyId={persona.slug}
              onClick={() => router.push(`/app/${orgId}/personas/${persona.id}`)}
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
                <strong data-cy="persona-name" style={{ fontSize: "1.05rem" }}>
                  {persona.name}
                </strong>
                {persona.current_version_id && (
                  <span
                    className="sg-pill sg-pill--sm eval-pass"
                    data-cy="persona-version-badge"
                  >
                    published
                  </span>
                )}
              </div>
              <div
                data-cy="persona-slug"
                {...cyAttrs({ cyValue: persona.slug })}
                style={{
                  fontSize: "0.8rem",
                  color: "var(--text-tertiary)",
                  fontFamily: "var(--font-mono, monospace)",
                  marginBottom: "0.5rem",
                }}
              >
                {persona.slug}
              </div>
              {persona.description && (
                <p
                  data-cy="persona-description"
                  style={{
                    margin: 0,
                    fontSize: "0.875rem",
                    color: "var(--text-secondary)",
                    lineHeight: 1.5,
                  }}
                >
                  {persona.description}
                </p>
              )}
            </Card>
          ))}
        </div>
      )}

      {/* Create modal */}
      <Modal
        open={creating}
        onClose={() => setCreating(false)}
        title="New Persona"
        cy="personas-create-modal"
        footer={
          <div style={{ display: "flex", gap: "0.5rem", justifyContent: "flex-end", width: "100%" }}>
            <Button variant="ghost" cy="personas-create-cancel" onClick={() => setCreating(false)}>
              Cancel
            </Button>
            <Button
              variant="primary"
              cy="personas-create-submit"
              loading={submitting}
              disabled={!newName.trim()}
              onClick={(e) => handleCreate(e as unknown as React.FormEvent)}
            >
              Create
            </Button>
          </div>
        }
      >
        <form data-cy="personas-create-form" onSubmit={handleCreate}>
          <FormField label="Name" name="name" required>
            {(p) => (
              <TextInput
                {...p}
                cy="personas-name-input"
                type="text"
                value={newName}
                onChange={(e) => setNewName(e.target.value)}
                placeholder="My persona"
                autoFocus
              />
            )}
          </FormField>
        </form>
      </Modal>

      {/* Starter library modal — preserved */}
      <Modal
        open={showStarterModal}
        onClose={() => setShowStarterModal(false)}
        title="Starter Library"
        cy="starter-library-modal"
      >
        {startersLoading ? (
          <p data-cy="starters-loading" className="sg-subtle">
            Loading starters…
          </p>
        ) : starters.length === 0 ? (
          <p data-cy="starters-empty" className="sg-subtle">
            No starters available.
          </p>
        ) : (
          <ul style={{ listStyle: "none", padding: 0, margin: 0, maxHeight: "60vh", overflowY: "auto" }}>
            {starters.map((starter) => (
              <li
                key={starter.slug}
                data-cy="starter-row"
                {...cyAttrs({ cyId: starter.slug })}
                style={{
                  padding: "0.75rem 1rem",
                  border: "1px solid var(--border-default)",
                  borderRadius: "0.5rem",
                  marginBottom: "0.5rem",
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                  gap: "0.75rem",
                }}
              >
                <div style={{ flex: 1, minWidth: 0 }}>
                  <strong data-cy="starter-name">{starter.name}</strong>
                  <span
                    className="sg-pill sg-pill--sm"
                    data-cy="starter-tone"
                    {...cyAttrs({ cyValue: starter.tone })}
                    style={{ marginLeft: "0.5rem" }}
                  >
                    {starter.tone}
                  </span>
                  {starter.description && (
                    <p
                      data-cy="starter-description"
                      style={{
                        margin: "0.25rem 0 0",
                        fontSize: "0.85rem",
                        color: "var(--text-secondary)",
                      }}
                    >
                      {starter.description}
                    </p>
                  )}
                </div>
                <Button
                  variant="primary"
                  size="sm"
                  cy="starter-import"
                  cyId={starter.slug}
                  loading={importingSlug === starter.slug}
                  onClick={() => handleImportStarter(starter.slug)}
                >
                  Import
                </Button>
              </li>
            ))}
          </ul>
        )}
      </Modal>
    </div>
  );
}
