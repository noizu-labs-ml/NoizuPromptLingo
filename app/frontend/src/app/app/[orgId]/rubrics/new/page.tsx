"use client";

import { use, useState } from "react";
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

export default function NewRubricPage({ params }: { params: Promise<{ orgId: string }> }) {
  const { orgId } = use(params);
  const { user } = useAuth();
  const router = useRouter();
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim()) return;
    setSubmitting(true);
    try {
      const res = await api.createRubric(orgId, name.trim(), description.trim() || undefined);
      toast.success("Rubric created");
      router.push(`/app/${orgId}/rubrics/${res.rubric.id}`);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to create rubric");
      setSubmitting(false);
    }
  }

  if (!user) return null;

  return (
    <div data-cy="rubric-new-page" {...cyAttrs({ cyScope: "rubric-new" })}>
      <PageHeader
        title="New Rubric"
        subtitle="Rubrics combine a scale and weighted criteria to score agent output."
        breadcrumbs={[
          { label: "library", href: `/app/${orgId}` },
          { label: "rubrics", href: `/app/${orgId}/rubrics` },
          { label: "new", current: true },
        ]}
      />

      <form data-cy="rubric-new-form" onSubmit={handleSubmit} className="sg-form">
        <div className="sg-form-section">
          <FormField label="Name" name="name" required>
            {(p) => (
              <TextInput
                {...p}
                data-cy="rubric-new-name"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="e.g. Factual Accuracy"
                autoFocus
                required
              />
            )}
          </FormField>

          <FormField label="Description" name="description" hint="Optional.">
            {(p) => (
              <TextArea
                {...p}
                data-cy="rubric-new-description"
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
            cy="rubric-new-cancel"
            onClick={() => router.push(`/app/${orgId}/rubrics`)}
          >
            Cancel
          </Button>
          <Button
            variant="primary"
            type="submit"
            cy="rubric-new-submit"
            loading={submitting}
            disabled={!name.trim()}
          >
            Create Rubric
          </Button>
        </footer>
      </form>
    </div>
  );
}
