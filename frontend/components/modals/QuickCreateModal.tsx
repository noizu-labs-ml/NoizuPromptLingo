"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { SparklesIcon } from "@heroicons/react/24/outline";
import { Button } from "@/components/primitives/Button";
import { Input } from "@/components/primitives/Input";
import { Textarea } from "@/components/primitives/Textarea";
import { FormField } from "@/components/primitives/FormField";
import { api } from "@/lib/api/client";
import { useToast } from "@/components/primitives/ToastContainer";

type CreateType = "instruction" | "task" | "project" | "document" | "artifact";

interface QuickCreateModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function QuickCreateModal({ isOpen, onClose }: QuickCreateModalProps) {
  const router = useRouter();
  const { toast } = useToast();
  const [step, setStep] = useState<"select" | "form">("select");
  const [selected, setSelected] = useState<CreateType | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [formData, setFormData] = useState({ name: "", description: "" });

  if (!isOpen) return null;

  const handleSelect = (type: CreateType) => {
    setSelected(type);
    setStep("form");
    setError(null);
  };

  const handleReset = () => {
    setStep("select");
    setSelected(null);
    setError(null);
    setFormData({ name: "", description: "" });
  };

  const handleClose = () => {
    onClose();
    handleReset();
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selected || !formData.name.trim()) return;
    setLoading(true);
    setError(null);

    try {
      let redirectPath: string;

      switch (selected) {
        case "task": {
          const task = await api.tasks.create({
            title: formData.name.trim(),
            description: formData.description.trim() || undefined,
          });
          redirectPath = `/tasks/${task.id}`;
          break;
        }
        case "artifact":
        case "document": {
          const artifact = await api.artifacts.create({
            title: formData.name.trim(),
            content: "",
            kind: selected === "document" ? "markdown" : "text",
            description: formData.description.trim() || undefined,
          });
          redirectPath = `/artifacts/${artifact.id}`;
          break;
        }
        case "instruction": {
          const instruction = await api.instructions.create({
            title: formData.name.trim(),
            description: formData.description.trim() || undefined,
          });
          redirectPath = `/instructions/${instruction.uuid}`;
          break;
        }
        case "project": {
          const project = await api.projects.create({
            name: formData.name.trim(),
            description: formData.description.trim() || undefined,
          });
          redirectPath = `/projects/${project.id}`;
          break;
        }
        default:
          throw new Error(`Unknown create type: ${selected}`);
      }

      toast(`${selected.charAt(0).toUpperCase() + selected.slice(1)} created`, "success");
      handleClose();
      router.push(redirectPath);
    } catch (err) {
      const msg = err instanceof Error ? err.message : "Creation failed";
      setError(msg);
      toast(msg, "error");
    } finally {
      setLoading(false);
    }
  };

  const handleBackdropClick = (e: React.MouseEvent<HTMLDivElement>) => {
    if (e.target === e.currentTarget) handleClose();
  };

  const createTypes: Array<{ type: CreateType; label: string; description: string }> = [
    { type: "instruction", label: "Instruction", description: "Prompt template + versions" },
    { type: "task", label: "Task", description: "Project checklist item" },
    { type: "project", label: "Project", description: "Workspace + team" },
    { type: "document", label: "Document", description: "Markdown with NPL" },
    { type: "artifact", label: "Artifact", description: "Versioned output" },
  ];

  const showDescription = ["instruction", "document", "project", "artifact"].includes(selected ?? "");

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm"
      onClick={handleBackdropClick}
    >
      <div className="w-full max-w-md rounded-lg bg-surface-0 shadow-elevated p-6 space-y-6">
        {step === "select" ? (
          <>
            <div className="flex items-center gap-2">
              <SparklesIcon className="h-5 w-5 text-accent" />
              <h2 className="text-lg font-semibold text-foreground">Quick Create</h2>
            </div>
            <p className="text-sm text-muted">What do you want to create?</p>
            <div className="space-y-2">
              {createTypes.map(({ type, label, description }) => (
                <button
                  key={type}
                  onClick={() => handleSelect(type)}
                  className="w-full text-left rounded-md border-2 border-border/50 p-3 transition-all hover:border-accent hover:bg-surface-1 focus-ring"
                >
                  <div className="font-medium text-foreground">{label}</div>
                  <div className="text-xs text-muted">{description}</div>
                </button>
              ))}
            </div>
            <div className="flex justify-end gap-2 pt-4">
              <Button variant="ghost" onClick={handleClose}>Cancel</Button>
            </div>
          </>
        ) : (
          <>
            <div className="flex items-center gap-2">
              <h2 className="text-lg font-semibold text-foreground">
                Create {selected}
              </h2>
            </div>
            <form onSubmit={handleSubmit} className="space-y-4">
              <FormField label="Name" required>
                <Input
                  placeholder={`Enter ${selected} name...`}
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  disabled={loading}
                />
              </FormField>
              {showDescription && (
                <FormField label="Brief description">
                  <Textarea
                    placeholder="What is this for?"
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                    disabled={loading}
                  />
                </FormField>
              )}
              {error && (
                <p className="text-sm text-red-500">{error}</p>
              )}
              <div className="flex justify-end gap-2 pt-4">
                <Button variant="ghost" onClick={handleReset} disabled={loading}>Back</Button>
                <Button
                  variant="primary"
                  type="submit"
                  loading={loading}
                  disabled={!formData.name.trim() || loading}
                >
                  Create
                </Button>
              </div>
            </form>
          </>
        )}
      </div>
    </div>
  );
}
