"use client";

import { heading } from "@/lib/ui/typography";
import { Card } from "@/components/primitives/Card";
import { Kbd } from "@/components/primitives/Kbd";

const samples: Array<{ token: string; className: string; sample: string }> = [
  { token: "text-display", className: "text-display font-sans text-foreground", sample: "Compose structured prompts." },
  { token: "text-title", className: "text-title font-sans text-foreground", sample: "Section header" },
  { token: "text-heading", className: "text-heading font-sans text-foreground", sample: "Card title" },
  { token: "text-label", className: "text-label font-sans uppercase text-subtle", sample: "Eyebrow label" },
  { token: "text-body", className: "text-sm leading-relaxed text-foreground", sample: "Body copy — default paragraph text." },
  { token: "text-caption", className: "text-xs text-subtle", sample: "Caption text, timestamps, hints." },
  { token: "text-mono", className: "text-xs font-mono text-muted", sample: "NPL-MCP-ID-0001" },
];

export function Typography() {
  return (
    <div className="flex flex-col gap-6">
      <h2 className={heading.title}>Typography</h2>
      <Card density="spacious">
        <dl className="flex flex-col divide-y divide-border/50">
          {samples.map((s) => (
            <div
              key={s.token}
              className="flex items-center justify-between gap-6 py-4 first:pt-0 last:pb-0"
            >
              <dt className="min-w-0 flex-1">
                <span className={s.className}>{s.sample}</span>
              </dt>
              <dd className="shrink-0">
                <Kbd>{s.token}</Kbd>
              </dd>
            </div>
          ))}
        </dl>
      </Card>
    </div>
  );
}
