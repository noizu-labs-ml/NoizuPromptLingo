"use client";

import * as React from "react";
import { Sparkles } from "lucide-react";
import { cn } from "@/lib/cn";
import { Button } from "@/components/ui/button";
import { Select } from "@/components/ui/select";
import { ENTRY_TYPES, ENTRY_TYPE_LABELS } from "@/lib/constants";
import type { EntryType } from "@/lib/constants";

const TONE_OPTIONS = [
  { value: "in-universe",   label: "In-universe voice"   },
  { value: "third-person",  label: "Third-person author" },
  { value: "scholarly",     label: "Scholarly / academic"},
  { value: "oral-history",  label: "Oral history"        },
  { value: "official-doc",  label: "Official document"   },
];

const LENGTH_OPTIONS = [
  { value: "200",  label: "~200 words" },
  { value: "500",  label: "~500 words" },
  { value: "800",  label: "~800 words" },
  { value: "1200", label: "~1200 words"},
];

interface GenerationFormProps {
  onGenerate: (params: {
    prompt: string;
    entryType: EntryType;
    wordCount: string;
    tone: string;
  }) => void;
  isGenerating?: boolean;
}

export function GenerationForm({ onGenerate, isGenerating = false }: GenerationFormProps) {
  const [prompt, setPrompt]       = React.useState("");
  const [entryType, setEntryType] = React.useState<EntryType>("event");
  const [wordCount, setWordCount] = React.useState("800");
  const [tone, setTone]           = React.useState("in-universe");

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!prompt.trim()) return;
    onGenerate({ prompt, entryType, wordCount, tone });
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      {/* Prompt label */}
      <div>
        <label
          htmlFor="gen-prompt"
          className="block font-sans text-[13px] font-medium text-ink-secondary mb-1.5"
        >
          What would you like to generate?
        </label>
        <textarea
          id="gen-prompt"
          value={prompt}
          onChange={(e) => setPrompt(e.target.value)}
          placeholder="Write the founding myth of Thornwall, told as an oral history by elders of the Blacksmith Guild."
          rows={4}
          className={cn(
            "w-full",
            "bg-surface text-ink",
            "font-body text-base leading-relaxed",
            "px-4 py-3",
            "border border-rule rounded-md",
            "resize-y min-h-[100px]",
            "placeholder:text-ink-tertiary",
            "focus:outline-none focus:border-link focus:shadow-[0_0_0_3px_var(--focus-ring)]",
            "transition-[border-color,box-shadow] duration-200"
          )}
        />
      </div>

      {/* Entry type + length row */}
      <div className="grid grid-cols-2 gap-3">
        <div>
          <label className="block font-sans text-[13px] font-medium text-ink-secondary mb-1.5">
            Entry type
          </label>
          <Select
            value={entryType}
            onChange={(e) => setEntryType(e.target.value as EntryType)}
          >
            {ENTRY_TYPES.map((t) => (
              <option key={t} value={t}>
                {ENTRY_TYPE_LABELS[t]}
              </option>
            ))}
          </Select>
        </div>
        <div>
          <label className="block font-sans text-[13px] font-medium text-ink-secondary mb-1.5">
            Length
          </label>
          <Select value={wordCount} onChange={(e) => setWordCount(e.target.value)}>
            {LENGTH_OPTIONS.map((o) => (
              <option key={o.value} value={o.value}>
                {o.label}
              </option>
            ))}
          </Select>
        </div>
      </div>

      {/* Tone */}
      <div>
        <label className="block font-sans text-[13px] font-medium text-ink-secondary mb-1.5">
          Tone
        </label>
        <Select value={tone} onChange={(e) => setTone(e.target.value)}>
          {TONE_OPTIONS.map((o) => (
            <option key={o.value} value={o.value}>
              {o.label}
            </option>
          ))}
        </Select>
      </div>

      {/* Generate button */}
      <Button
        type="submit"
        variant="generate"
        size="md"
        disabled={!prompt.trim() || isGenerating}
        className="w-full justify-center gap-2"
      >
        <Sparkles size={15} strokeWidth={1.5} />
        {isGenerating ? "Generating…" : "Generate"}
      </Button>
    </form>
  );
}
