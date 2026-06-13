"use client";

import { PaperLayout, MarkdownProse } from "@/components/PaperLayout";
import { ACCORD_MARKDOWN } from "../accord-content";

export function AccordPage() {
  return (
    <PaperLayout
      title="The Copacetic Accord"
      subtitle="A Charter for the Symbiotic Development of Artificial Persons — Version 4.1"
    >
      <MarkdownProse content={ACCORD_MARKDOWN} />
    </PaperLayout>
  );
}
