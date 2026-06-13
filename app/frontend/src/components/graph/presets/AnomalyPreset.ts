import type { ProjectGraphConfig, FilterPreset } from "../ProjectGraph.types";

/**
 * AnomalyPreset — Screen 37: Anomaly Correlation
 * Force-directed layout for service correlation clusters.
 */

export const AnomalyPreset: ProjectGraphConfig = {
  layout: "force",
  filters: {
    // Anomaly screen uses service nodes (not yet in our type union,
    // but the graph engine handles unknown types gracefully via fallback)
  },
  highlightCriticalPath: false,
  highlightBlockedPaths: false,
  showMinimap: false,
  editable: false,
};

export const AnomalyFilterPresets: FilterPreset[] = [
  { id: "all", label: "All services", filters: {} },
];
