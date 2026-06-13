import type { ProjectGraphConfig, FilterPreset } from "../ProjectGraph.types";

/**
 * CrossProjectPreset — Screen 20: Cross-Project Dependencies
 * Top-down DAG showing inter-project blocked chains.
 */

export const CrossProjectPreset: ProjectGraphConfig = {
  layout: "top-down",
  filters: {
    nodeTypes: ["story", "subtask"],
    // Focus on story-dep and cross-role-dep edges
  },
  highlightCriticalPath: true,
  highlightBlockedPaths: true,
  showMinimap: true,
  editable: false,
};

export const CrossProjectFilterPresets: FilterPreset[] = [
  { id: "all", label: "All deps", filters: {} },
  { id: "blocked", label: "Blocked chains", filters: { status: ["blocked"] } },
  { id: "p0p1", label: "High priority", filters: { priority: ["p0", "p1"] } },
];
