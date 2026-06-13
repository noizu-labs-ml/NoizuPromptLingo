"use client";

import { use, useEffect, useState } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import { api } from "@/lib/api";
import { cyAttrs } from "@/utils/cypress";
import {
  Button,
  Card,
  FormField,
  PageHeader,
  TextArea,
  toast,
} from "@/components/ui";

interface ImportError {
  error: string;
  slug?: string;
  version?: string | number;
  hint?: string;
}

export default function ImportScriptPage({
  params,
}: {
  params: Promise<{ orgId: string }>;
}) {
  const { orgId } = use(params);
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();

  const [yaml, setYaml] = useState("");
  const [fileName, setFileName] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<ImportError | null>(null);

  useEffect(() => {
    if (!authLoading && !user) router.push("/login");
  }, [user, authLoading, router]);

  function handleFile(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    setFileName(file.name);
    const reader = new FileReader();
    reader.onload = () => {
      if (typeof reader.result === "string") setYaml(reader.result);
    };
    reader.readAsText(file);
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!yaml.trim() || submitting) return;
    setSubmitting(true);
    setError(null);
    try {
      const res = await api.importScriptYaml(orgId, yaml.trim());
      toast.success(`Imported "${res.script.name}"`);
      router.push(`/app/${orgId}/scripts/${res.script.id}`);
    } catch (err) {
      const raw = err instanceof Error ? err.message : "import failed";
      let parsed: ImportError = { error: raw };
      try {
        parsed = JSON.parse(raw) as ImportError;
      } catch {
        /* keep flat message */
      }
      setError(parsed);
      toast.error(parsed.error);
      setSubmitting(false);
    }
  }

  if (authLoading || !user) {
    return (
      <div data-cy="app-loading" style={{ padding: "3rem 1rem", textAlign: "center" }}>
        Loading…
      </div>
    );
  }

  return (
    <div data-cy="scripts-import-page" {...cyAttrs({ cyScope: "scripts-import" })}>
      <PageHeader
        title="Import Script from YAML"
        subtitle="Paste YAML or upload a file. Referenced prompts and rubrics must already be published in this organization."
        breadcrumbs={[
          { label: "library", href: `/app/${orgId}` },
          { label: "scripts", href: `/app/${orgId}/scripts` },
          { label: "import", current: true },
        ]}
      />

      {error && (
        <Card
          variant="fail"
          cy="scripts-import-error"
          role="alert"
          style={{ marginBottom: "var(--space-4)" }}
        >
          <strong data-cy="scripts-import-error-message">{error.error}</strong>
          {error.slug && (
            <div
              data-cy="scripts-import-error-slug"
              style={{ fontSize: "0.875rem", marginTop: "0.25rem" }}
            >
              Slug: <code>{error.slug}</code>
              {error.version != null && (
                <>
                  {" "}
                  · version: <code>{String(error.version)}</code>
                </>
              )}
            </div>
          )}
          {error.hint && (
            <div
              data-cy="scripts-import-error-hint"
              style={{ fontSize: "0.875rem", marginTop: "0.25rem", opacity: 0.85 }}
            >
              {error.hint}
            </div>
          )}
        </Card>
      )}

      <form data-cy="scripts-import-form" onSubmit={handleSubmit} className="sg-form">
        <div className="sg-form-section">
          <FormField
            label="Upload YAML file"
            name="file"
            hint={fileName ? `Loaded: ${fileName}` : "Optional. Will populate the textarea below."}
          >
            {(p) => (
              <input
                {...p}
                type="file"
                accept=".yaml,.yml,text/yaml,application/x-yaml"
                data-cy="scripts-import-file"
                onChange={handleFile}
              />
            )}
          </FormField>

          <FormField label="Paste YAML" name="yaml" required>
            {(p) => (
              <TextArea
                {...p}
                data-cy="scripts-import-yaml"
                rows={18}
                value={yaml}
                onChange={(e) => setYaml(e.target.value)}
                placeholder={"script:\n  name: My Script\n  nodes: []"}
                className="sg-mono"
                style={{ fontSize: "0.85rem" }}
                required
              />
            )}
          </FormField>
        </div>

        <footer className="sg-form-footer">
          <Button
            variant="ghost"
            type="button"
            cy="scripts-import-cancel"
            onClick={() => router.push(`/app/${orgId}/scripts`)}
          >
            Cancel
          </Button>
          <Button
            variant="primary"
            type="submit"
            cy="scripts-import-submit"
            loading={submitting}
            disabled={!yaml.trim()}
          >
            Import
          </Button>
        </footer>
      </form>
    </div>
  );
}
