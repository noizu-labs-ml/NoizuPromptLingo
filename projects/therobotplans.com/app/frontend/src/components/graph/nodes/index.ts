/** Graph Node Components */
export { StoryNode } from "./StoryNode";
export { RoleNode } from "./RoleNode";
export { SubtaskNode } from "./SubtaskNode";
export { MilestoneNode } from "./MilestoneNode";
export { ForkNode } from "./ForkNode";
export { MergeNode } from "./MergeNode";

import type { NodeTypes } from "@xyflow/react";
import { StoryNode } from "./StoryNode";
import { RoleNode } from "./RoleNode";
import { SubtaskNode } from "./SubtaskNode";
import { MilestoneNode } from "./MilestoneNode";
import { ForkNode } from "./ForkNode";
import { MergeNode } from "./MergeNode";

/** React Flow nodeTypes registration map */
export const graphNodeTypes: NodeTypes = {
  story: StoryNode as any,
  role: RoleNode as any,
  subtask: SubtaskNode as any,
  milestone: MilestoneNode as any,
  fork: ForkNode as any,
  merge: MergeNode as any,
};
