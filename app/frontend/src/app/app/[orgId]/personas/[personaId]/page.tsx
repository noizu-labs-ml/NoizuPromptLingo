"use client";

import { use, useEffect, useState } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import {
  api,
  type Persona,
  type PersonaVersion,
  type PersonaExpectation,
  type Prompt,
  type ExpectationDirection,
  type ExpectationScoringMethod,
} from "@/lib/api";
import { cyAttrs } from "@/utils/cypress";
import {
  Button,
  Card,
  EmptyState,
  FormField,
  LoadingSkeleton,
  PageHeader,
  Select,
  StatusPill,
  TextArea,
  TextInput,
  toast,
} from "@/components/ui";

const TONE_SUGGESTIONS = [
  "broken-english",
  "hostile",
  "confused-novice",
  "adversarial",
  "over-specific",
  "context-switch",
];

const SCORING_METHODS: ExpectationScoringMethod[] = [
  "exact",
  "contains",
  "regex",
  "rubric",
  "llm",
];

interface ScriptNode {
  id: string;
  node_key: string;
  kind: string;
}

export default function PersonaDetailPage({
  params,
}: {
  params: Promise<{ orgId: string; personaId: string }>;
}) {
  const { orgId, personaId } = use(params);
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();

  const [persona, setPersona] = useState<Persona | null>(null);
  const [currentVersion, setCurrentVersion] = useState<PersonaVersion | null>(null);
  const [loading, setLoading] = useState(true);

  // edit form fields
  const [tone, setTone] = useState("");
  const [description, setDescription] = useState("");
  const [systemPromptVersionId, setSystemPromptVersionId] = useState<string>("");
  const [saving, setSaving] = useState(false);
  const [publishing, setPublishing] = useState(false);

  // prompts picker
  const [prompts, setPrompts] = useState<Prompt[]>([]);

  // expectations
  const [expectations, setExpectations] = useState<PersonaExpectation[]>([]);
  const [scriptNodes, setScriptNodes] = useState<ScriptNode[]>([]);
  const [addingExp, setAddingExp] = useState(false);
  const [expLabel, setExpLabel] = useState("");
  const [expWeight, setExpWeight] = useState("1.0");
  const [expDirection, setExpDirection] = useState<ExpectationDirection>("pass");
  const [expScoringMethod, setExpScoringMethod] =
    useState<ExpectationScoringMethod>("contains");
  const [expNodeId, setExpNodeId] = useState<string>("");
  const [expConfig, setExpConfig] = useState("{}");
  const [savingExp, setSavingExp] = useState(false);

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login");
      return;
    }
    if (!user) return;

    Promise.all([
      api.getPersona(orgId, personaId),
      api.listPrompts(orgId),
      api.listScripts(orgId),
    ])
      .then(([personaRes, promptsRes, scriptsRes]) => {
        setPersona(personaRes.persona);
        setCurrentVersion(personaRes.current_version);
        setPrompts(promptsRes.prompts);

        const cv = personaRes.current_version;
        setTone(cv?.tone ?? "");
        setDescription(personaRes.persona.description ?? "");
        setSystemPromptVersionId(cv?.system_prompt_version_id ?? "");

        const scripts = (scriptsRes as { scripts: { id: string; name: string }[] }).scripts;
        return Promise.all(scripts.map((s) => api.getScript(orgId, s.id)));
      })
      .then((scriptDetails) => {
        const allNodes: ScriptNode[] = scriptDetails.flatMap((sd) => {
          const detail = sd as { nodes: ScriptNode[] };
          return detail.nodes ?? [];
        });
        setScriptNodes(allNodes);
      })
      .catch((err) => {
        toast.error(err instanceof Error ? err.message : "failed to load");
      })
      .finally(() => setLoading(false));
  }, [user, authLoading, router, orgId, personaId]);

  useEffect(() => {
    if (!currentVersion?.id) return;
    api
      .listPersonaExpectations(orgId, personaId, currentVersion.id)
      .then((res) => setExpectations(res.expectations))
      .catch(() => {});
  }, [orgId, personaId, currentVersion?.id]);

  async function handleSave(e: React.FormEvent) {
    e.preventDefault();
    if (!persona) return;
    setSaving(true);
    try {
      const res = await api.updatePersona(orgId, personaId, {
        tone: tone || undefined,
        description: description || undefined,
        system_prompt_version_id: systemPromptVersionId || null,
      });
      setPersona(res.persona);
      toast.success("Persona saved");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "save failed");
    } finally {
      setSaving(false);
    }
  }

  async function handlePublish() {
    setPublishing(true);
    try {
      const res = await api.publishPersonaVersion(orgId, personaId);
      setCurrentVersion(res.version);
      toast.success(res.status === "noop" ? "Already up to date" : "Version published");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "publish failed");
    } finally {
      setPublishing(false);
    }
  }

  async function handleAddExpectation(e: React.FormEvent) {
    e.preventDefault();
    if (!currentVersion) {
      toast.error("Publish a version first to attach expectations");
      return;
    }
    let configObj: Record<string, unknown> = {};
    try {
      configObj = JSON.parse(expConfig);
    } catch {
      toast.error("Config must be valid JSON");
      return;
    }
    setSavingExp(true);
    try {
      const res = await api.createPersonaExpectation(
        orgId,
        personaId,
        currentVersion.id,
        {
          label: expLabel,
          weight: parseFloat(expWeight) || 1,
          direction: expDirection,
          scoring_method: expScoringMethod,
          script_node_id: expNodeId || null,
          config: configObj,
        },
      );
      setExpectations((prev) => [...prev, res.expectation]);
      setExpLabel("");
      setExpWeight("1.0");
      setExpDirection("pass");
      setExpScoringMethod("contains");
      setExpNodeId("");
      setExpConfig("{}");
      setAddingExp(false);
      toast.success("Expectation added");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "failed to add expectation");
    } finally {
      setSavingExp(false);
    }
  }

  if (authLoading || loading) {
    return (
      <div data-cy="app-loading" style={{ padding: "2rem 0" }}>
        <LoadingSkeleton variant="row" count={4} />
      </div>
    );
  }

  if (!persona) {
    return (
      <EmptyState
        glyph="search"
        cy="persona-not-found"
        headline="Persona not found"
        primaryAction={
          <Button variant="secondary" onClick={() => router.push(`/app/${orgId}/personas`)}>
            Back to Personas
          </Button>
        }
      />
    );
  }

  return (
    <div
      data-cy="persona-detail-page"
      {...cyAttrs({ cyScope: "persona-detail", cyId: persona.slug })}
    >
      <PageHeader
        title={<span data-cy="persona-detail-name">{persona.name}</span>}
        subtitle={
          persona.description ? <span>{persona.description}</span> : undefined
        }
        breadcrumbs={[
          { label: "library", href: `/app/${orgId}` },
          { label: "personas", href: `/app/${orgId}/personas` },
          { label: persona.slug, current: true },
        ]}
        actions={
          <Button
            variant="primary"
            cy="persona-publish-btn"
            loading={publishing}
            onClick={handlePublish}
          >
            Publish Version
          </Button>
        }
      />

      <div className="sg-detail-grid">
        {/* Metadata aside */}
        <aside className="sg-detail-aside">
          <Card>
            <h3 className="sg-meta-label">Slug</h3>
            <p
              className="sg-meta-value sg-meta-value--mono"
              data-cy="persona-detail-slug"
              {...cyAttrs({ cyValue: persona.slug })}
            >
              {persona.slug}
            </p>
          </Card>

          <Card>
            <h3 className="sg-meta-label">Status</h3>
            <div className="sg-chip-row">
              {currentVersion ? (
                <StatusPill
                  state="pass"
                  label={`v${currentVersion.version_number} published`}
                  size="sm"
                  cy="persona-published-badge"
                />
              ) : (
                <StatusPill state="pending" label="draft" size="sm" />
              )}
            </div>
          </Card>

          {currentVersion && (
            <Card>
              <h3 className="sg-meta-label">Current Version</h3>
              <p className="sg-meta-value">v{currentVersion.version_number}</p>
              <p className="sg-meta-value sg-meta-value--mono">
                {currentVersion.checksum}
              </p>
              {currentVersion.published_at && (
                <p className="sg-meta-value sg-subtle">
                  {new Date(currentVersion.published_at).toLocaleString()}
                </p>
              )}
            </Card>
          )}
        </aside>

        {/* Main column */}
        <main className="sg-detail-main">
          {/* Edit form */}
          <Card data-cy="persona-edit-section" className="sg-form-section">
            <h2 className="sg-form-section__title">Edit Persona</h2>
            <form
              onSubmit={handleSave}
              style={{
                display: "flex",
                flexDirection: "column",
                gap: "var(--space-4)",
              }}
            >
              <FormField label="Tone" name="tone">
                {(p) => (
                  <>
                    <TextInput
                      {...p}
                      cy="persona-tone-input"
                      type="text"
                      value={tone}
                      onChange={(e) => setTone(e.target.value)}
                      placeholder="e.g. broken-english"
                    />
                    <div
                      className="sg-chip-row"
                      style={{ marginTop: "var(--space-2)" }}
                      data-cy="persona-tone-suggestions"
                    >
                      {TONE_SUGGESTIONS.map((t) => (
                        <button
                          key={t}
                          type="button"
                          className={`sg-pill sg-pill--sm${tone === t ? " eval-pass" : ""}`}
                          data-cy="persona-tone-suggestion"
                          {...cyAttrs({ cyValue: t })}
                          onClick={() => setTone(t)}
                          style={{ cursor: "pointer", border: "1px solid var(--border-default)" }}
                        >
                          {t}
                        </button>
                      ))}
                    </div>
                  </>
                )}
              </FormField>

              <FormField label="Description" name="description">
                {(p) => (
                  <TextArea
                    {...p}
                    cy="persona-description-input"
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    rows={3}
                  />
                )}
              </FormField>

              <FormField label="System Prompt (published prompt)" name="system-prompt">
                {(p) => (
                  <Select
                    {...p}
                    cy="persona-prompt-version-select"
                    value={systemPromptVersionId}
                    onChange={(e) => setSystemPromptVersionId(e.target.value)}
                    options={[
                      { value: "", label: "— none —" },
                      ...prompts
                        .filter((pr) => pr.current_version_id)
                        .map((pr) => ({
                          value: pr.current_version_id!,
                          label: pr.name,
                        })),
                    ]}
                  />
                )}
              </FormField>

              <div style={{ display: "flex", justifyContent: "flex-end" }}>
                <Button
                  variant="primary"
                  type="submit"
                  cy="persona-save-btn"
                  loading={saving}
                >
                  Save
                </Button>
              </div>
            </form>
          </Card>

          {/* Expectations */}
          <Card data-cy="persona-expectations-section" className="sg-form-section">
            <header
              style={{
                display: "flex",
                justifyContent: "space-between",
                alignItems: "baseline",
              }}
            >
              <h2 className="sg-form-section__title">Layered Expectations</h2>
              <Button
                variant="ghost"
                size="sm"
                cy="persona-add-expectation-btn"
                onClick={() => setAddingExp((v) => !v)}
              >
                {addingExp ? "Cancel" : "Add Expectation"}
              </Button>
            </header>

            {!currentVersion && (
              <p
                data-cy="persona-expectations-no-version"
                className="sg-meta-value sg-subtle"
              >
                Publish a version first to attach expectations.
              </p>
            )}

            {addingExp && currentVersion && (
              <form
                data-cy="persona-expectation-form"
                onSubmit={handleAddExpectation}
                style={{
                  display: "flex",
                  flexDirection: "column",
                  gap: "var(--space-3)",
                  padding: "var(--space-4)",
                  border: "1px solid var(--border-subtle)",
                  borderRadius: "var(--radius-md)",
                  background: "var(--bg-elevated)",
                }}
              >
                <FormField label="Label" name="exp-label" required>
                  {(p) => (
                    <TextInput
                      {...p}
                      cy="exp-label-input"
                      type="text"
                      value={expLabel}
                      onChange={(e) => setExpLabel(e.target.value)}
                      placeholder="e.g. Should stay in character"
                      required
                    />
                  )}
                </FormField>

                <div className="sg-form-row">
                  <FormField label="Script Node (optional)" name="exp-node">
                    {(p) => (
                      <Select
                        {...p}
                        cy="exp-node-select"
                        value={expNodeId}
                        onChange={(e) => setExpNodeId(e.target.value)}
                        options={[
                          { value: "", label: "— any node —" },
                          ...scriptNodes.map((n) => ({
                            value: n.id,
                            label: `${n.node_key} (${n.kind})`,
                          })),
                        ]}
                      />
                    )}
                  </FormField>
                  <FormField label="Weight" name="exp-weight">
                    {(p) => (
                      <TextInput
                        {...p}
                        cy="exp-weight-input"
                        type="number"
                        step="0.1"
                        min="0"
                        value={expWeight}
                        onChange={(e) => setExpWeight(e.target.value)}
                      />
                    )}
                  </FormField>
                </div>

                <div className="sg-form-row">
                  <FormField label="Direction" name="exp-direction">
                    {(p) => (
                      <Select
                        {...p}
                        cy="exp-direction-select"
                        value={expDirection}
                        onChange={(e) =>
                          setExpDirection(e.target.value as ExpectationDirection)
                        }
                        options={[
                          { value: "pass", label: "pass" },
                          { value: "fail", label: "fail" },
                        ]}
                      />
                    )}
                  </FormField>
                  <FormField label="Scoring Method" name="exp-scoring">
                    {(p) => (
                      <Select
                        {...p}
                        cy="exp-scoring-method-select"
                        value={expScoringMethod}
                        onChange={(e) =>
                          setExpScoringMethod(
                            e.target.value as ExpectationScoringMethod,
                          )
                        }
                        options={SCORING_METHODS.map((m) => ({ value: m, label: m }))}
                      />
                    )}
                  </FormField>
                </div>

                <FormField label="Config (JSON)" name="exp-config">
                  {(p) => (
                    <TextArea
                      {...p}
                      cy="exp-config-input"
                      value={expConfig}
                      onChange={(e) => setExpConfig(e.target.value)}
                      rows={3}
                      className="sg-mono"
                    />
                  )}
                </FormField>

                <div style={{ display: "flex", justifyContent: "flex-end" }}>
                  <Button
                    variant="primary"
                    type="submit"
                    cy="exp-save-btn"
                    loading={savingExp}
                  >
                    Add Expectation
                  </Button>
                </div>
              </form>
            )}

            <ul
              data-cy="persona-expectations-list"
              style={{ listStyle: "none", padding: 0, margin: 0 }}
            >
              {expectations.length === 0 && (
                <li
                  data-cy="persona-expectations-empty"
                  className="sg-meta-value"
                  style={{ color: "var(--text-tertiary)", padding: "var(--space-3) 0" }}
                >
                  No expectations yet.
                </li>
              )}
              {expectations.map((exp) => (
                <li
                  key={exp.id}
                  data-cy="expectation-row"
                  {...cyAttrs({ cyId: exp.id })}
                  style={{
                    padding: "var(--space-3) var(--space-4)",
                    border: "1px solid var(--border-subtle)",
                    borderRadius: "var(--radius-md)",
                    marginBottom: "var(--space-2)",
                    background: "var(--bg-elevated)",
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                  }}
                >
                  <div>
                    <strong data-cy="expectation-label">{exp.label}</strong>
                    <div className="sg-chip-row" style={{ marginTop: "var(--space-1)" }}>
                      <span
                        className="sg-pill sg-pill--sm"
                        data-cy="expectation-scoring-method"
                        {...cyAttrs({ cyValue: exp.scoring_method })}
                      >
                        {exp.scoring_method}
                      </span>
                      <span
                        className="sg-pill sg-pill--sm"
                        data-cy="expectation-direction"
                        {...cyAttrs({ cyValue: exp.direction })}
                      >
                        {exp.direction}
                      </span>
                      <span className="sg-pill sg-pill--sm" data-cy="expectation-weight">
                        w:{exp.weight}
                      </span>
                    </div>
                  </div>
                </li>
              ))}
            </ul>
          </Card>
        </main>
      </div>
    </div>
  );
}
