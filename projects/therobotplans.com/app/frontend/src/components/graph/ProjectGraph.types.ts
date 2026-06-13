/**
 * ProjectGraph — Type definitions
 *
 * Merges Marcus's architecture doc (project-graph-architecture.md) with
 * Priya's visual spec (project-graph-view.md Sections 1-17).
 *
 * Node types: story, role, subtask, milestone, fork, merge
 * Edge types: assignment, breakdown, story-dep, cross-role-dep, fork-branch, branch-merge
 */

// ── Node Status ────────────────────────────────────────────────

export type NodeStatus = "pending" | "in-progress" | "in-review" | "blocked" | "done";

// ── Assignee ───────────────────────────────────────────────────

export interface Assignee {
  id: string;
  name: string;
  avatar?: string;
  isAgent: boolean;
}

// ── Epic ────────────────────────────────────────────────────────

export interface Epic {
  id: string;
  name: string;
  colorSlot: number; // 1-9, maps to extended palette
}

// ── Node Types ─────────────────────────────────────────────────

export type GraphNodeType = "story" | "role" | "subtask" | "milestone" | "fork" | "merge";

export interface StoryData {
  title: string;
  description?: string;
  storyId: string; // e.g., "US-014"
  priority: "p0" | "p1" | "p2" | "p3";
  epicId?: string;
  status: NodeStatus;
  progress: number; // 0-100
  acceptanceCriteria?: { text: string; done: boolean }[];
  roleAvatars?: { name: string; isAgent: boolean }[];
}

export interface RoleData {
  roleName: string;
  assignee?: Assignee;
  isAgent: boolean;
  subtaskProgress: { done: number; total: number };
}

export interface SubtaskData {
  title: string;
  taskId: string; // e.g., "T-041"
  description?: string;
  status: NodeStatus;
  assignedVia: string; // role node ID
  parentStoryId?: string; // story node ID for navigation
  isAgentWork?: boolean;
}

export interface MilestoneData {
  title: string;
  dueDate?: string;
  progress: number; // 0-100
  status: "not-reached" | "approaching" | "satisfied" | "overdue";
}

export interface Branch {
  id: string;
  label: string;
  approach?: string;
  confidence: number; // 0-100
  confidenceHistory?: { time: string; value: number }[];
  subtaskIds: string[];
  status: "exploring" | "won" | "pruned";
}

export interface ForkData {
  question: string;
  agentId: string;
  branches: Branch[];
  status: "evaluating" | "decided" | "stale";
  decidedAt?: string;
  winnerId?: string;
}

export interface MergeData {
  forkId: string;
  winnerId?: string;
  rationale?: string;
  decidedBy?: string;
  decidedAt?: string;
  status: "pending" | "decided";
}

export type NodeDataMap = {
  story: StoryData;
  role: RoleData;
  subtask: SubtaskData;
  milestone: MilestoneData;
  fork: ForkData;
  merge: MergeData;
};

export interface GraphNode<T extends GraphNodeType = GraphNodeType> {
  id: string;
  type: T;
  data: NodeDataMap[T];
  position?: { x: number; y: number };
  pinned?: boolean;
  expanded?: boolean; // story: show/hide subtask subgraph
}

// ── Edge Types ─────────────────────────────────────────────────

export type GraphEdgeType =
  | "assignment"      // Story → Role
  | "breakdown"       // Role → Subtask
  | "story-dep"       // Story → Story (blocking)
  | "cross-role-dep"  // Subtask → Subtask (across roles)
  | "fork-branch"     // Fork → Branch entry
  | "branch-merge";   // Branch exit → Merge

export interface GraphEdge<T extends GraphEdgeType = GraphEdgeType> {
  id: string;
  source: string;
  target: string;
  type: T;
  data?: EdgeData;
  animated?: boolean;
  health?: "active" | "blocked" | "resolved";
}

export interface EdgeData {
  label?: string;
  branchId?: string;   // fork-branch / branch-merge
  isWinner?: boolean;   // branch-merge: was this the winning branch?
}

// ── Layout ─────────────────────────────────────────────────────

export type LayoutMode = "ltr" | "radial" | "top-down" | "force";

// ── Graph Configuration ────────────────────────────────────────

export interface ProjectGraphConfig {
  layout: LayoutMode;
  filters?: GraphFilters;
  highlightCriticalPath?: boolean;
  highlightBlockedPaths?: boolean;
  showMinimap?: boolean;
  editable?: boolean;
}

export interface GraphFilters {
  status?: NodeStatus[];
  priority?: ("p0" | "p1" | "p2" | "p3")[];
  assigneeId?: string;
  epicId?: string;
  nodeTypes?: GraphNodeType[];
}

// ── Filter Preset ──────────────────────────────────────────────

export interface FilterPreset {
  id: string;
  label: string;
  filters: GraphFilters;
  layout?: LayoutMode;
}

// ── Full Graph Data ────────────────────────────────────────────

export interface ProjectGraphData {
  nodes: GraphNode[];
  edges: GraphEdge[];
  milestones?: MilestoneData[];
  epics?: Epic[];
}

// ── Component Props ────────────────────────────────────────────

export interface ProjectGraphProps {
  data: ProjectGraphData;
  config?: ProjectGraphConfig;
  onNodeSelect?: (node: GraphNode | null) => void;
  onNodeNavigate?: (nodeId: string, nodeType: GraphNodeType) => void;
  onEdgeCreate?: (source: string, target: string, type: GraphEdgeType) => void;
  onEdgeDelete?: (edgeId: string) => void;
  detailPanelSide?: "right" | "bottom" | "none";
  loading?: boolean;
  className?: string;
}

// ── Epic Color Map ─────────────────────────────────────────────

export const EPIC_COLORS: string[] = [
  "var(--blue)",
  "var(--violet)",
  "var(--cyan)",
  "var(--teal, var(--cyan))",
  "var(--indigo, var(--blue))",
  "var(--rose)",
  "var(--orange, var(--warning))",
  "var(--sky, var(--info))",
];

export function epicColor(slot: number): string {
  return EPIC_COLORS[(slot - 1) % EPIC_COLORS.length];
}

// ── Priority Config ────────────────────────────────────────────

export const PRIORITY_CONFIG: Record<string, { color: string; label: string }> = {
  p0: { color: "var(--error)", label: "P0" },
  p1: { color: "var(--warning)", label: "P1" },
  p2: { color: "var(--blue)", label: "P2" },
  p3: { color: "var(--gray-400)", label: "P3" },
};

// ── Status Config ──────────────────────────────────────────────

export const STATUS_CONFIG: Record<NodeStatus, { color: string; label: string; dotColor: string }> = {
  pending: { color: "var(--gray-400)", label: "Pending", dotColor: "var(--gray-400)" },
  "in-progress": { color: "var(--blue)", label: "In Progress", dotColor: "var(--blue)" },
  "in-review": { color: "var(--info)", label: "In Review", dotColor: "var(--info)" },
  blocked: { color: "var(--error)", label: "Blocked", dotColor: "var(--error)" },
  done: { color: "var(--success)", label: "Done", dotColor: "var(--success)" },
};
