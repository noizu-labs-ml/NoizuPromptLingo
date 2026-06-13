import type { ProjectGraphConfig, FilterPreset } from "../ProjectGraph.types";

/**
 * GoalAlignmentPreset — Screen 50: Goal Alignment Viz
 * OKR → key-result → work tree as top-down hierarchy.
 */

export const GoalAlignmentPreset: ProjectGraphConfig = {
  layout: "top-down",
  filters: {
    // All node types visible — OKR hierarchy spans story + subtask
  },
  highlightCriticalPath: false,
  highlightBlockedPaths: false,
  showMinimap: true,
  editable: false,
};

export const GoalAlignmentFilterPresets: FilterPreset[] = [
  { id: "all", label: "Full tree", filters: {} },
  { id: "stories", label: "Stories only", filters: { nodeTypes: ["story"] } },
  { id: "at-risk", label: "At risk", filters: { status: ["blocked", "in-progress"] } },
];
