// Static fixture data for the UX wireframe mockups. No fetch, no external calls.
// A few values are lifted from the hostile-fixtures dataset (long names, CJK, RTL,
// nulls, huge numbers) so every table/list is stress-tested by default, not just
// on a special "edge case" pass.

export const HOSTILE_LONG_NAME =
  "payments-reconciliation-and-settlement-orchestrator-for-cross-border-merchant-disbursements-with-fx-hedging-eu-west-1-canary-shard-07-legacy-compat-bridge-v2-do-not-rename-owned-by-platform-treasury-o";
export const HOSTILE_CJK = "検索インデックス";
export const HOSTILE_RTL = "بوابة-واجهة-برمجة";
export const HOSTILE_RTL_AUTHOR = "أحمد المصري";
export const HOSTILE_DIACRITIC = "critères-déploiement-numériquẽ";
export const HOSTILE_WHITESPACE = "   ";
export const HOSTILE_HUGE_NUMBER = 918273645102;
export const HOSTILE_NEGATIVE = -42.5;

export type Org = { slug: string; name: string; role: "owner" | "admin" | "member" | "viewer" };

export const orgs: Org[] = [
  { slug: "acme", name: "Acme Robotics", role: "admin" },
  { slug: HOSTILE_CJK, name: "検索インデックス株式会社", role: "member" },
  { slug: "globex", name: "Globex Corp", role: "viewer" },
];

export const currentUser = {
  name: "Keith Brings",
  email: "keith.brings@noizu.com",
  initials: "KB",
};

export const unreadCount = 4;

export const kpis = [
  { label: "Active sessions", value: 12 },
  { label: "Open tickets", value: 37 },
  { label: "Boards", value: 5 },
  { label: "MCP keys active", value: 3 },
  { label: "Pending approvals", value: HOSTILE_HUGE_NUMBER },
  { label: "Cost (30d, USD)", value: HOSTILE_NEGATIVE },
];

export const firstRunSteps = [
  { id: "step-key", label: "Add an MCP key", done: false },
  { id: "step-mcp", label: "Connect an MCP endpoint", done: false },
  { id: "step-session", label: "Start your first session", done: false },
];

export type NotificationItem = {
  id: string;
  actor: string | null;
  verb: string;
  object: string;
  read: boolean;
  createdAt: string;
};

export const notifications: NotificationItem[] = [
  { id: "n1", actor: "Keith Brings", verb: "mentioned you in", object: "ticket #482", read: false, createdAt: "2026-09-06T14:02:00Z" },
  { id: "n2", actor: null, verb: "system: write-approval required for", object: "svc-billing console query", read: false, createdAt: "2026-09-06T12:40:00Z" },
  { id: "n3", actor: HOSTILE_RTL_AUTHOR, verb: "moved", object: "ticket #401 to Review", read: false, createdAt: "2026-09-05T09:12:00Z" },
  { id: "n4", actor: "小林 ひろし", verb: "commented on", object: "wiki page: Deployment runbook", read: true, createdAt: "2026-09-04T22:05:00Z" },
];

export type ActivityEvent = {
  id: string;
  actor: string | null;
  verb: string;
  object: string;
  scope: string;
  timestamp: string;
};

export const activityEvents: ActivityEvent[] = [
  { id: "a1", actor: "Keith Brings", verb: "created", object: "session sess_a1b2", scope: "project:core", timestamp: "2026-09-06T14:32:11Z" },
  { id: "a2", actor: null, verb: "system: deployed", object: HOSTILE_LONG_NAME, scope: "project:core", timestamp: "2026-09-06T14:30:00Z" },
  { id: "a3", actor: "Zoë Châtelet", verb: "opened", object: "ticket #482", scope: "board:launch", timestamp: "2026-09-06T09:10:00Z" },
  { id: "a4", actor: HOSTILE_WHITESPACE, verb: "edited", object: "wiki page: onboarding", scope: "project:core", timestamp: "2026-09-05T07:30:00Z" },
];

export type SessionRow = {
  id: string;
  name: string;
  status: "running" | "succeeded" | "failed" | "pending" | "degraded" | "unknown";
  project: string;
  owner: string | null;
  startedAt: string | null;
  durationMs: number | null;
  toolScope: string;
};

export const sessions: SessionRow[] = [
  { id: "sess_a1b2", name: HOSTILE_LONG_NAME, status: "succeeded", project: "core", owner: "Keith Brings", startedAt: "2026-09-05T14:32:11Z", durationMs: 102000, toolScope: "read-write" },
  { id: "sess_c3d4", name: HOSTILE_CJK, status: "failed", project: "core", owner: "小林 ひろし", startedAt: "2026-09-05T14:31:57Z", durationMs: 48000, toolScope: "read-only" },
  { id: "sess_e5f6", name: "billing-ledger", status: "pending", project: "billing", owner: null, startedAt: null, durationMs: null, toolScope: "read-only" },
  { id: "sess_g7h8", name: HOSTILE_RTL, status: "unknown", project: "core", owner: HOSTILE_RTL_AUTHOR, startedAt: "2026-09-05T09:12:00Z", durationMs: 61500, toolScope: "read-write" },
  { id: "sess_i9j0", name: HOSTILE_WHITESPACE, status: "degraded", project: "core", owner: "  ", startedAt: "2026-09-05T07:30:00Z", durationMs: 8000, toolScope: "read-only" },
];

export const sessionEvents = [
  { id: "ev1", type: "tool_call", label: "fs.read(/mnt/vfs/core/README.md)", at: "2026-09-05T14:32:01Z" },
  { id: "ev2", type: "tool_call", label: "db.query(svc-billing, SELECT ...)", at: "2026-09-05T14:32:05Z" },
  { id: "ev3", type: "message", label: "Assistant: reviewing schema before writing migration", at: "2026-09-05T14:32:09Z" },
];

export type Ticket = {
  id: string;
  title: string;
  type: "bug" | "feature" | "chore";
  status: "open" | "in_review" | "blocked" | "done";
  assignee: string | null;
  updatedAt: string;
  customFields: Record<string, string | number | null>;
};

export const tickets: Ticket[] = [
  { id: "482", title: "Fix reconciliation timeout on canary shard", type: "bug", status: "in_review", assignee: "Keith Brings", updatedAt: "2026-09-06T14:02:00Z", customFields: { severity: "P1", points: 5 } },
  { id: "401", title: HOSTILE_CJK, type: "feature", status: "open", assignee: null, updatedAt: "2026-09-05T09:12:00Z", customFields: { severity: "P2", points: null } },
  { id: "377", title: HOSTILE_LONG_NAME, type: "chore", status: "blocked", assignee: HOSTILE_RTL_AUTHOR, updatedAt: "2026-09-04T22:05:00Z", customFields: { severity: "P3", points: HOSTILE_HUGE_NUMBER } },
  { id: "205", title: HOSTILE_WHITESPACE, type: "bug", status: "done", assignee: "Zoë Châtelet", updatedAt: "2026-09-01T00:00:00Z", customFields: { severity: null, points: 1 } },
];

export type BoardCard = { id: string; title: string; assignee: string | null; ticketId: string | null };
export type BoardStage = { id: string; name: string; cards: BoardCard[]; hasMore: boolean };

export const boards: Record<string, { id: string; name: string; stages: BoardStage[] }> = {
  launch: {
    id: "launch",
    name: "Launch board",
    stages: [
      {
        id: "backlog",
        name: "Backlog",
        cards: [
          { id: "c1", title: "Draft landing page copy", assignee: null, ticketId: null },
          { id: "c2", title: HOSTILE_LONG_NAME, assignee: "Keith Brings", ticketId: "482" },
        ],
        hasMore: true,
      },
      {
        id: "in-progress",
        name: "In progress",
        cards: [{ id: "c3", title: HOSTILE_CJK, assignee: "小林 ひろし", ticketId: "401" }],
        hasMore: false,
      },
      {
        id: "review",
        name: "Review",
        cards: [{ id: "c4", title: HOSTILE_WHITESPACE, assignee: HOSTILE_RTL_AUTHOR, ticketId: "377" }],
        hasMore: false,
      },
      { id: "done", name: "Done", cards: [{ id: "c5", title: "Ship v2.4.1", assignee: "Zoë Châtelet", ticketId: "205" }], hasMore: true },
    ],
  },
};

export type ChatRoom = { id: string; name: string; unread: number; muted: boolean };
export type ChatMessage = { id: string; author: string | null; body: string; at: string; threadId: string | null; pinned: boolean };

export const chatRooms: ChatRoom[] = [
  { id: "general", name: "general", unread: 2, muted: false },
  { id: HOSTILE_CJK, name: HOSTILE_CJK, unread: 0, muted: true },
  { id: "incident-482", name: HOSTILE_LONG_NAME, unread: 12, muted: false },
];

export const chatMessages: Record<string, ChatMessage[]> = {
  general: [
    { id: "t1", author: "Keith Brings", body: "Kicking off the reconciliation fix.", at: "2026-09-06T14:00:00Z", threadId: null, pinned: true },
    { id: "m2", author: HOSTILE_RTL_AUTHOR, body: HOSTILE_RTL, at: "2026-09-06T14:05:00Z", threadId: "t1", pinned: false },
    { id: "m3", author: null, body: HOSTILE_WHITESPACE, at: "2026-09-06T14:06:00Z", threadId: null, pinned: false },
  ],
};

export const instructions = [
  { id: "instr-1", name: "PR review checklist", version: "v4", updatedAt: "2026-09-05T00:00:00Z" },
  { id: "instr-2", name: HOSTILE_LONG_NAME, version: "v1", updatedAt: "2026-09-04T00:00:00Z" },
  { id: "instr-3", name: HOSTILE_CJK, version: "v0.9", updatedAt: "2026-09-03T00:00:00Z" },
];

export type Mount = { id: string; name: string; authState: "connected" | "expired" | "denied"; docsAvailable: boolean };

export const mounts: Mount[] = [
  { id: "core-vfs", name: "core-vfs", authState: "connected", docsAvailable: true },
  { id: HOSTILE_CJK, name: HOSTILE_CJK, authState: "expired", docsAvailable: false },
  { id: "billing-vfs", name: "billing-vfs", authState: "denied", docsAvailable: true },
  { id: "wiki", name: "wiki", authState: "connected", docsAvailable: true },
];

export type FileNode = { id: string; name: string; type: "dir" | "file"; children?: FileNode[]; live?: boolean };

export const fileTree: FileNode[] = [
  {
    id: "src",
    name: "src",
    type: "dir",
    children: [
      { id: "src/index.ts", name: "index.ts", type: "file", live: true },
      { id: "src/util.ts", name: HOSTILE_LONG_NAME + ".ts", type: "file" },
    ],
  },
  { id: "README.md", name: "README.md", type: "file" },
  { id: HOSTILE_CJK, name: HOSTILE_CJK, type: "dir", children: [] },
];

export const fileContent = `# README\n\nThis mount is read-write for members with the core-vfs group gate.\nLast sync: 2026-09-06T14:32:11Z\n`;

export const wikiFileTree: FileNode[] = [
  {
    id: "docs",
    name: "docs",
    type: "dir",
    children: [{ id: "docs/readme.md", name: "readme.md", type: "file", live: true }],
  },
];

export const wikiFileContent = `# Wiki readme\n\nMounted read-only for all members; edits require the wiki:write group gate.\n`;

export const fileTreesByMount: Record<string, FileNode[]> = {
  "core-vfs": fileTree,
  wiki: wikiFileTree,
};

export const fileContentByMount: Record<string, string> = {
  "core-vfs": fileContent,
  wiki: wikiFileContent,
};

export type DbService = { id: string; name: string; scope: string; kind: string };

export const dbServices: DbService[] = [
  { id: "svc-billing", name: "svc-billing", scope: "tenant:acme", kind: "postgres" },
  { id: "svc-search", name: HOSTILE_CJK, scope: "tenant:acme", kind: "weaviate" },
];

export const dbSchema: Record<string, { table: string; columns: { name: string; type: string }[] }[]> = {
  "svc-billing": [
    { table: "invoices", columns: [{ name: "id", type: "uuid" }, { name: "amount_usd", type: "numeric" }, { name: HOSTILE_LONG_NAME.slice(0, 60), type: "text" }] },
    { table: "ledger_entries", columns: [{ name: "id", type: "uuid" }, { name: "delta", type: "numeric" }] },
  ],
};

export const consoleResultColumns = ["id", "amount_usd", "status"];
export const consoleResultRows: Array<Record<string, string | number | null>> = [
  { id: "inv_001", amount_usd: 412.55, status: "paid" },
  { id: "inv_002", amount_usd: HOSTILE_NEGATIVE, status: "refunded" },
  { id: "inv_003", amount_usd: null, status: "pending" },
];

export type Approval = { id: string; summary: string; requestedBy: string | null; risk: "low" | "medium" | "high"; diff: string; status: "pending" | "approved" | "rejected" };

export const approvals: Approval[] = [
  { id: "appr-1", summary: "UPDATE ledger_entries SET delta = delta + 10 WHERE id = ...", requestedBy: "Keith Brings", risk: "high", diff: "- delta: 0\n+ delta: 10", status: "pending" },
  { id: "appr-2", summary: HOSTILE_LONG_NAME, requestedBy: null, risk: "medium", diff: "- status: pending\n+ status: paid", status: "pending" },
];

export const auditRows = [
  { id: "aud-1", actor: "Keith Brings", action: "SELECT", target: "svc-billing.invoices", at: "2026-09-06T14:00:00Z", redacted: false },
  { id: "aud-2", actor: HOSTILE_RTL_AUTHOR, action: "UPDATE", target: "svc-billing.ledger_entries", at: "2026-09-06T13:40:00Z", redacted: true },
];

export const vectorResults = [
  { id: "vec-1", snippet: "reconciliation timeout retry policy", score: 0.92 },
  { id: "vec-2", snippet: HOSTILE_CJK, score: 0.81 },
  { id: "vec-3", snippet: HOSTILE_WHITESPACE, score: 0.11 },
];

export const integrations = [
  { id: "github", name: "GitHub", status: "connected" },
  { id: "mock-mcp", name: "Mock MCP", status: "connected" },
  { id: "webhooks", name: "Webhooks", status: "not configured" },
  { id: "tunnels", name: "Dev tunnels", status: "not configured" },
];

export type Member = { id: string; name: string; email: string; role: "owner" | "admin" | "member" | "viewer"; suspended: boolean };

export const members: Member[] = [
  { id: "u1", name: "Keith Brings", email: "keith.brings@noizu.com", role: "owner", suspended: false },
  { id: "u2", name: HOSTILE_RTL_AUTHOR, email: "ahmed@example.com", role: "admin", suspended: false },
  { id: "u3", name: "小林 ひろし", email: "kobayashi@example.com", role: "member", suspended: false },
  { id: "u4", name: HOSTILE_WHITESPACE, email: "ghost@example.com", role: "viewer", suspended: true },
];

export const memberCap = { used: members.length, max: 25 };

export type SecretKey = { id: string; label: string; lastUsed: string | null; revealed: boolean; scope: string };

export const keys: SecretKey[] = [
  { id: "key-1", label: "CI deploy key", lastUsed: "2026-09-06T10:00:00Z", revealed: false, scope: "read-write" },
  { id: "key-2", label: HOSTILE_LONG_NAME, lastUsed: null, revealed: false, scope: "read-only" },
];

export const searchGroups = [
  {
    group: "Tickets",
    results: [
      { id: "482", title: "Fix reconciliation timeout on canary shard", href: "/acme/work/tickets/482" },
    ],
  },
  {
    group: "Wiki",
    results: [{ id: "w1", title: "Deployment runbook", href: "/acme/knowledge/instructions" }],
  },
  {
    group: "Files",
    results: [{ id: "f1", title: "README.md (core-vfs)", href: "/acme/files/core-vfs/README.md" }],
  },
];

export const paletteActions = [
  { id: "go-home", label: "Go to Home", hint: "g h" },
  { id: "go-work", label: "Go to Work", hint: "g w" },
  { id: "go-chat", label: "Go to Chat", hint: "g c" },
  { id: "go-knowledge", label: "Go to Knowledge", hint: "g k" },
  { id: "go-files", label: "Go to Files", hint: "g f" },
  { id: "go-data", label: "Go to Data", hint: "g d" },
  { id: "new-ticket", label: "Create ticket", hint: "" },
  { id: "search", label: "Search everything", hint: "/" },
];

export const breadcrumbLabels: Record<string, string> = {
  work: "Work",
  sessions: "Sessions",
  boards: "Boards",
  tickets: "Tickets",
  chat: "Chat",
  knowledge: "Knowledge",
  instructions: "Instructions",
  files: "Files",
  data: "Data",
  schema: "Schema",
  console: "Console",
  approvals: "Approvals",
  audit: "Audit",
  vectors: "Vectors",
  integrations: "Integrations",
  settings: "Settings",
  members: "Members",
  keys: "Keys",
  accessibility: "Accessibility",
  inbox: "Inbox",
  activity: "Activity",
};

export const railDestinations = [
  { id: "home", label: "Home", href: "" },
  { id: "work", label: "Work", href: "work/sessions" },
  { id: "chat", label: "Chat", href: "chat" },
  { id: "knowledge", label: "Knowledge", href: "knowledge/instructions" },
  { id: "files", label: "Files", href: "files" },
  { id: "data", label: "Data", href: "data" },
  { id: "integrations", label: "Integrations", href: "integrations" },
  { id: "settings", label: "Settings", href: "settings/members" },
];

export const adminRailDestinations = [
  { id: "users", label: "Users", href: "/admin/users" },
  { id: "orgs", label: "Orgs", href: "/admin/orgs" },
  { id: "authz", label: "AuthZ / PBAC", href: "/admin/authz" },
  { id: "llm", label: "LLM providers", href: "/admin/llm" },
  { id: "media", label: "Media providers", href: "/admin/media" },
  { id: "oauth", label: "OAuth clients", href: "/admin/oauth" },
  { id: "mcp", label: "MCP catalog", href: "/admin/mcp" },
  { id: "marketing", label: "Marketing", href: "/admin/marketing" },
];

export function fmtDate(iso: string | null): string {
  if (!iso) return "—";
  return iso.replace("T", " ").replace("Z", " UTC");
}

export function fmtDuration(ms: number | null): string {
  if (ms === null || ms === undefined) return "—";
  if (ms >= 1000) return `${(ms / 1000).toFixed(1)}s`;
  return `${ms}ms`;
}

export function fmtNumber(n: number | null): string {
  if (n === null || n === undefined) return "—";
  return n.toLocaleString("en-US");
}
