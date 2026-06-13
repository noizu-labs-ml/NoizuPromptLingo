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

export default function NewScriptPage({
  params,
}: {
  params: Promise<{ orgId: string }>;
}) {
  const { orgId } = use(params);
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();

  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!authLoading && !user) router.push("/login");
  }, [user, authLoading, router]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim() || submitting) return;
    setSubmitting(true);
    setError(null);
    try {
      const res = await api.createScript(
        orgId,
        name.trim(),
        description.trim() || undefined,
      );
      toast.success("Script created");
      router.push(`/app/${orgId}/scripts/${res.script.id}`);
    } catch (err) {
      const msg = err instanceof Error ? err.message : "failed to create script";
      setError(msg);
      toast.error(msg);
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
    <div data-cy="scripts-new-page" {...cyAttrs({ cyScope: "scripts-new" })}>
      <PageHeader
        title="New Script"
        subtitle="Create an empty script. You can then add nodes, edges, and expectations."
        breadcrumbs={[
          { label: "library", href: `/app/${orgId}` },
          { label: "scripts", href: `/app/${orgId}/scripts` },
          { label: "new", current: true },
        ]}
      />

      <form data-cy="scripts-new-form" onSubmit={handleSubmit} className="sg-form">
        <div className="sg-form-section">
          <FormField label="Name" name="name" required error={error ?? undefined}>
            {(p) => (
              <TextInput
                {...p}
                data-cy="scripts-new-name"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="Checkout flow happy path"
                autoFocus
                required
              />
            )}
          </FormField>

          <FormField
            label="Description"
            name="description"
            hint="Optional."
          >
            {(p) => (
              <TextArea
                {...p}
                data-cy="scripts-new-description"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="What does this script test?"
                rows={4}
              />
            )}
          </FormField>
        </div>

        <footer className="sg-form-footer">
          <Button
            variant="ghost"
            type="button"
            cy="scripts-new-cancel"
            onClick={() => router.push(`/app/${orgId}/scripts`)}
          >
            Cancel
          </Button>
          <Button
            variant="primary"
            type="submit"
            cy="scripts-new-submit"
            loading={submitting}
            disabled={!name.trim()}
          >
            Create script
          </Button>
        </footer>
      </form>
    </div>
  );
}
