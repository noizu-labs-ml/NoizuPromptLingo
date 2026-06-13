import type { ProjectGraphConfig, FilterPreset } from "../ProjectGraph.types";

/**
 * GanttDepsPreset — Screen 16: Gantt View
 * Temporal LTR layout, dependency connectors between stories + milestones.
 */

export const GanttDepsPreset: ProjectGraphConfig = {
  layout: "ltr",
  filters: {
    nodeTypes: ["story", "milestone", "subtask"],
    // edge types: story-dep, breakdown
  },
  highlightCriticalPath: true,
  highlightBlockedPaths: true,
  showMinimap: true,
  editable: false,
};

export const GanttFilterPresets: FilterPreset[] = [
  { id: "all", label: "All work", filters: {} },
  { id: "blocked", label: "Blocked", filters: { status: ["blocked"] } },
  { id: "milestones", label: "Milestones", filters: { nodeTypes: ["milestone", "story"] } },
];
