/** Shared API response types — contract between backend and frontend agents */

// ─── Fork + PR ─────────────────────────────────────────────────────────────

export interface ForkResponse {
  fork: {
    id: string;
    title: string | null;
    code: string;
    config: string | null;
    visibility: string;
    createdAt: string;
  };
  forkRecord: {
    id: string;
    sourceDiagramId: string | null;
    forkedDiagramId: string;
    forkedBy: string;
  };
}

export interface PullRequest {
  id: string;
  sourceDiagramId: string | null;
  targetDiagramId: string;
  createdBy: string;
  authorName: string | null;
  authorHandle: string | null;
  title: string;
  description: string | null;
  status: 'open' | 'merged' | 'closed';
  sourceCode: string;
  targetCode: string;
  mergedAt: string | null;
  closedAt: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface PullRequestSummary {
  id: string;
  title: string;
  status: 'open' | 'merged' | 'closed';
  authorName: string | null;
  authorHandle: string | null;
  createdAt: string;
}

export interface PRListResponse {
  pullRequests: PullRequestSummary[];
}

export interface PRCreateBody {
  title: string;
  description?: string;
}

export interface PRUpdateBody {
  status: 'merged' | 'closed';
}

// ─── Version Control ───────────────────────────────────────────────────────

export interface Commit {
  id: string;
  diagramId: string;
  branchId: string;
  parentCommitId: string | null;
  committedBy: string;
  authorName: string | null;
  message: string | null;
  codePreview: string;
  createdAt: string;
}

export interface CommitDetail extends Commit {
  code: string;
  config: string | null;
}

export interface CommitListResponse {
  commits: Commit[];
  hasMore: boolean;
}

export interface CommitCreateBody {
  message?: string;
  code: string;
  config?: string;
  branchId?: string;
}

export interface Branch {
  id: string;
  diagramId: string;
  name: string;
  headCommitId: string | null;
  createdBy: string | null;
  createdAt: string;
}

export interface BranchListResponse {
  branches: Branch[];
}

export interface BranchCreateBody {
  name: string;
  fromCommitId?: string;
}

export interface RevertBody {
  commitId: string;
}

// ─── Inter-Diagram Links ───────────────────────────────────────────────────

export interface ResolveResponse {
  resolved: Record<string, string>;
}
