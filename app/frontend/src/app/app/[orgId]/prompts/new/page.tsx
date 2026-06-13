"use client";

import { use, useEffect, useState } from "react";
import { useAuth } from "@/context/auth";
import { useRouter } from "next/navigation";
import { api } from "@/lib/api";
import { cyAttrs } from "@/utils/cypress";
import {
  Button,
  FormField,
  PageHeader,
  TextArea,
  TextInput,
  toast,
} from "@/components/ui";

export default function NewPromptPage({
  params,
}: {
  params: Promise<{ orgId: string }>;
}) {
  const { orgId } = use(params);
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();

  const [name, setName] = useState("");
  const [slug, setSlug] = useState("");
  const [description, setDescription] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login");
    }
  }, [user, authLoading, router]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim()) return;
    setError(null);
    setSubmitting(true);
    try {
      const res = await api.createPrompt(
        orgId,
        name.trim(),
        description.trim() || undefined,
        slug.trim() || undefined,
      );
      toast.success(`Prompt "${res.prompt.name}" created.`);
      router.push(`/app/${orgId}/prompts/${res.prompt.id}`);
    } catch (err) {
      const msg = err instanceof Error ? err.message : "failed to create";
      setError(msg);
      toast.error(msg);
      setSubmitting(false);
    }
  }

  if (authLoading) {
    return (
      <div data-cy="app-loading" style={{ padding: "3rem 1rem", textAlign: "center" }}>
        Loading…
      </div>
    );
  }

  return (
    <div data-cy="new-prompt-page" {...cyAttrs({ cyScope: "new-prompt" })}>
      <PageHeader
        title="New Prompt"
        subtitle="Create a prompt. You can publish a version with body and template vars afterwards."
        breadcrumbs={[
          { label: "library", href: `/app/${orgId}` },
          { label: "prompts", href: `/app/${orgId}/prompts` },
          { label: "new", current: true },
        ]}
      />

      <form data-cy="new-prompt-form" onSubmit={handleSubmit} className="sg-form">
        <div className="sg-form-section">
          <FormField label="Name" name="name" required>
            {(p) => (
              <TextInput
                {...p}
                data-cy="new-prompt-name"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="My prompt"
                autoFocus
                required
              />
            )}
          </FormField>

          <FormField
            label="Slug"
            name="slug"
            hint="Optional — auto-generated if blank."
          >
            {(p) => (
              <TextInput
                {...p}
                data-cy="new-prompt-slug"
                value={slug}
                onChange={(e) => setSlug(e.target.value)}
                placeholder="my-prompt"
                className="sg-mono"
              />
            )}
          </FormField>

          <FormField
            label="Description"
            name="description"
            hint="Optional."
            error={error ?? undefined}
          >
            {(p) => (
              <TextArea
                {...p}
                data-cy="new-prompt-description"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="What does this prompt do?"
                rows={3}
              />
            )}
          </FormField>
        </div>

        <footer className="sg-form-footer">
          <Button
            variant="ghost"
            type="button"
            cy="new-prompt-cancel"
            onClick={() => router.push(`/app/${orgId}/prompts`)}
          >
            Cancel
          </Button>
          <Button
            variant="primary"
            type="submit"
            cy="new-prompt-submit"
            loading={submitting}
            disabled={!name.trim()}
          >
            Create Prompt
          </Button>
        </footer>
      </form>
    </div>
  );
}
