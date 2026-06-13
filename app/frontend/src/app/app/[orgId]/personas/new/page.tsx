"use client";

import { use, useState } from "react";
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

export default function NewPersonaPage({
  params,
}: {
  params: Promise<{ orgId: string }>;
}) {
  const { orgId } = use(params);
  const router = useRouter();

  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim()) return;
    setSubmitting(true);
    try {
      const res = await api.createPersona(orgId, name.trim(), description.trim() || undefined);
      toast.success("Persona created");
      router.push(`/app/${orgId}/personas/${res.persona.id}`);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "failed to create persona");
      setSubmitting(false);
    }
  }

  return (
    <div data-cy="new-persona-page" {...cyAttrs({ cyScope: "new-persona" })}>
      <PageHeader
        title="New Persona"
        subtitle="Personas shape agent style and tone at runtime — attach a system prompt later."
        breadcrumbs={[
          { label: "library", href: `/app/${orgId}` },
          { label: "personas", href: `/app/${orgId}/personas` },
          { label: "new", current: true },
        ]}
      />

      <form data-cy="new-persona-form" onSubmit={handleSubmit} className="sg-form">
        <div className="sg-form-section">
          <FormField label="Name" name="name" required>
            {(p) => (
              <TextInput
                {...p}
                data-cy="new-persona-name-input"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="My persona"
                autoFocus
                required
              />
            )}
          </FormField>

          <FormField label="Description" name="description" hint="Optional.">
            {(p) => (
              <TextArea
                {...p}
                data-cy="new-persona-description-input"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="Optional description"
                rows={3}
              />
            )}
          </FormField>
        </div>

        <footer className="sg-form-footer">
          <Button
            variant="ghost"
            type="button"
            cy="new-persona-cancel-btn"
            onClick={() => router.push(`/app/${orgId}/personas`)}
          >
            Cancel
          </Button>
          <Button
            variant="primary"
            type="submit"
            cy="new-persona-submit-btn"
            loading={submitting}
            disabled={!name.trim()}
          >
            Create Persona
          </Button>
        </footer>
      </form>
    </div>
  );
}
