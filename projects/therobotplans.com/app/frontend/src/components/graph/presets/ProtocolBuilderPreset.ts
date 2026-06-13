import type { ProjectGraphConfig, FilterPreset } from "../ProjectGraph.types";

/**
 * ProtocolBuilderPreset — Screen 60: Agent Collaboration Protocol
 * LTR layout for sequential handoff chains. Editable: drag-to-link + delete.
 */

export const ProtocolBuilderPreset: ProjectGraphConfig = {
  layout: "ltr",
  filters: {
    nodeTypes: ["fork", "merge", "subtask", "role"],
    // Focus on handoff and fork-branch / branch-merge edges
  },
  highlightCriticalPath: false,
  highlightBlockedPaths: false,
  showMinimap: true,
  editable: true,
};

export const ProtocolBuilderFilterPresets: FilterPreset[] = [
  { id: "all", label: "Full protocol", filters: {} },
  { id: "forks", label: "Decision points", filters: { nodeTypes: ["fork", "merge"] } },
];
