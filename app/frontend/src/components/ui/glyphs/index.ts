import * as React from "react";
import { ScriptGlyph } from "./ScriptGlyph";
import { RunGlyph } from "./RunGlyph";
import { AgentGlyph } from "./AgentGlyph";
import { PersonaGlyph } from "./PersonaGlyph";
import { PromptGlyph } from "./PromptGlyph";
import { RubricGlyph } from "./RubricGlyph";
import { DatasetGlyph } from "./DatasetGlyph";
import { ReviewGlyph } from "./ReviewGlyph";

export {
  ScriptGlyph,
  RunGlyph,
  AgentGlyph,
  PersonaGlyph,
  PromptGlyph,
  RubricGlyph,
  DatasetGlyph,
  ReviewGlyph,
};

export type GlyphName =
  | "script"
  | "scripts"
  | "run"
  | "runs"
  | "agent"
  | "agents"
  | "persona"
  | "personas"
  | "prompt"
  | "prompts"
  | "rubric"
  | "rubrics"
  | "dataset"
  | "datasets"
  | "review";

const REGISTRY: Record<string, React.ComponentType<React.SVGProps<SVGSVGElement>>> = {
  script: ScriptGlyph,
  scripts: ScriptGlyph,
  run: RunGlyph,
  runs: RunGlyph,
  agent: AgentGlyph,
  agents: AgentGlyph,
  persona: PersonaGlyph,
  personas: PersonaGlyph,
  prompt: PromptGlyph,
  prompts: PromptGlyph,
  rubric: RubricGlyph,
  rubrics: RubricGlyph,
  dataset: DatasetGlyph,
  datasets: DatasetGlyph,
  review: ReviewGlyph,
};

/**
 * Resolve a domain glyph name to its React component.
 * Returns null if unknown.
 */
export function getGlyph(name: string): React.ReactElement | null {
  const Comp = REGISTRY[name];
  if (!Comp) return null;
  return React.createElement(Comp);
}
