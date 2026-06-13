"use client";

import type { SemanticClass } from "@styleguide-engine/lib/types";
import { useSemanticSelection } from "./SemanticSelectionContext";
import { SemanticClassSelect } from "./SemanticClassSelect";
import { PreviewCode } from "./pkg/preview-code";
import { Subsection } from "./pkg/subsection";

interface Props {
  semanticClasses: SemanticClass[];
}

interface ButtonRow {
  title: string;
  buttons: { label: string; classes: string }[];
}

function rowToHtml(buttons: { label: string; classes: string }[]): string {
  return buttons
    .map((b) => `<button class="${b.classes}">${b.label}</button>`)
    .join("\n");
}

export function ButtonShowcase({ semanticClasses }: Props) {
  const { selected: selectedClass, setSelected: setSelectedClass } = useSemanticSelection();

  const sc =
    semanticClasses.find((c) => c.name === selectedClass) || semanticClasses[0];

  if (!sc) return null;

  const rows: ButtonRow[] = [
    {
      title: "Sizes",
      buttons: [
        { label: "Small", classes: `btn btn-sm ${sc.class}` },
        { label: "Default", classes: `btn ${sc.class}` },
        { label: "Large", classes: `btn btn-lg ${sc.class}` },
        { label: "XL", classes: `btn btn-xl ${sc.class}` },
      ],
    },
    {
      title: "Styles",
      buttons: [
        { label: "Filled", classes: `btn ${sc.class}` },
        { label: "Outline", classes: `btn btn-outline ${sc.class}` },
        { label: "Accent", classes: `btn accent-${sc.class}` },
        { label: "Outline Accent", classes: `btn btn-outline accent-${sc.class}` },
      ],
    },
    {
      title: "Modifiers",
      buttons: [
        { label: "Rounded", classes: `btn ${sc.class} rounded` },
        { label: "Shadow", classes: `btn ${sc.class} drop-shadow` },
        { label: "Rounded + Shadow", classes: `btn ${sc.class} rounded drop-shadow` },
      ],
    },
    {
      title: "Outline + Modifiers",
      buttons: [
        { label: "Outline Rounded", classes: `btn btn-outline ${sc.class} rounded` },
        { label: "Outline Shadow", classes: `btn btn-outline ${sc.class} drop-shadow` },
      ],
    },
    {
      title: "Accent + Modifiers",
      buttons: [
        { label: "Accent Rounded", classes: `btn accent-${sc.class} rounded` },
        { label: "Accent Shadow", classes: `btn accent-${sc.class} drop-shadow` },
        { label: "Accent Rounded + Shadow", classes: `btn accent-${sc.class} rounded drop-shadow` },
      ],
    },
    {
      title: "Text Styling",
      buttons: [
        { label: "Text Style", classes: `btn text-${sc.class}` },
        { label: "Outline + Text", classes: `btn btn-outline text-${sc.class}` },
        { label: "Filled + Text", classes: `btn ${sc.class} text-${sc.class}` },
      ],
    },
  ];

  return (
    <div>
      <div style={{ marginBottom: "var(--space-3)" }}>
        <SemanticClassSelect semanticClasses={semanticClasses} />
      </div>

      {rows.map((row) => {
        const slug = `btn-${row.title.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "")}`;
        return (
          <Subsection key={row.title} id={slug} title={row.title}>
            <PreviewCode html={rowToHtml(row.buttons)}>
              <div className="flex flex-wrap gap-[var(--space-2)] items-end">
                {row.buttons.map((spec) => (
                  <div
                    key={spec.classes}
                    className="flex flex-col items-center gap-[var(--space-half)]"
                  >
                    <button className={spec.classes}>{spec.label}</button>
                    <code className="text-xs font-mono text-[var(--text-muted)] leading-[1.3] text-center">
                      .{spec.classes.split(" ").join(".")}
                    </code>
                  </div>
                ))}
              </div>
            </PreviewCode>
          </Subsection>
        );
      })}
    </div>
  );
}
