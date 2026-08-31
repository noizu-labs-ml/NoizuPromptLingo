import Database from "better-sqlite3";
import { homedir } from "node:os";
import { join } from "node:path";

const DEFAULT_PERIOD_MS = 60 * 60 * 1000;
const DEFAULT_LIMIT = 50;
const MAX_LIMIT = 1_000;
const MAX_PREVIEW_LENGTH = 240;

export interface RecentOptions {
  periodMs: number;
  periodLabel: string;
  limit: number;
  json: boolean;
  full: boolean;
  help: boolean;
}

export interface RecentSession {
  id: string;
  title: string;
  directory: string;
  runner: string;
  source: string;
  startedAt: string;
  updatedAt: string;
  messageCount: number;
  firstMessage: string | null;
  lastMessage: string | null;
}

interface RecentRow {
  id: string;
  title: string;
  project_path: string;
  harness: string;
  source_path: string;
  started_at: string;
  updated_at: string;
  message_count: number;
  first_message: string | null;
  last_message: string | null;
}

// ⟦𓈯𓎬𓌷𓃷⟧ runRecentCommand :: auto-generated pointer for public function runRecentCommand
export function runRecentCommand(args: string[]): number {
  try {
    const options = parseRecentArgs(args);
    if (options.help) {
      console.log(recentHelp());
      return 0;
    }

    const dbPath = join(
      process.env.LLM_TOOLKIT_DATA_DIR ?? process.env.CLAUDE_ASSIST_DATA_DIR ?? join(homedir(), ".llm-toolkit"),
      "llm-toolkit.db",
    );
    const since = new Date(Date.now() - options.periodMs);
    const sessions = queryRecentSessions(dbPath, since, options.limit);

    if (options.json) {
      console.log(JSON.stringify({ since: since.toISOString(), sessions }, null, 2));
    } else {
      console.log(formatRecentSessions(sessions, options));
    }
    return 0;
  } catch (error) {
    console.error(`llm-toolkit recent: ${error instanceof Error ? error.message : String(error)}`);
    return 1;
  }
}

// ⟦𓊛𓀽𓎡𓎩⟧ parseRecentArgs :: auto-generated pointer for public function parseRecentArgs
export function parseRecentArgs(args: string[]): RecentOptions {
  let limit = DEFAULT_LIMIT;
  let json = false;
  let full = false;
  let help = false;
  let explicitPeriod: string | undefined;
  const positional: string[] = [];

  for (let index = 0; index < args.length; index++) {
    const arg = args[index];
    if (arg === "-h" || arg === "--help") {
      help = true;
    } else if (arg === "--json") {
      json = true;
    } else if (arg === "--full") {
      full = true;
    } else if (arg === "--limit") {
      limit = parseLimit(args[++index]);
    } else if (arg.startsWith("--limit=")) {
      limit = parseLimit(arg.slice("--limit=".length));
    } else if (arg === "--period" || arg === "--since") {
      explicitPeriod = requireFlagValue(arg, args[++index]);
    } else if (arg.startsWith("--period=") || arg.startsWith("--since=")) {
      explicitPeriod = requireFlagValue(arg.split("=", 1)[0], arg.slice(arg.indexOf("=") + 1));
    } else if (arg.startsWith("-")) {
      throw new Error(`unknown option: ${arg}`);
    } else {
      positional.push(arg);
    }
  }

  if (explicitPeriod && positional.length > 0) {
    throw new Error("pass the period either positionally or with --period/--since, not both");
  }

  const periodInput = explicitPeriod ?? positional.join(" ");
  const period = periodInput ? parsePeriod(periodInput) : {
    milliseconds: DEFAULT_PERIOD_MS,
    label: "1 hour",
  };

  return {
    periodMs: period.milliseconds,
    periodLabel: period.label,
    limit,
    json,
    full,
    help,
  };
}

// ⟦𓂯𓈫𓋡𓋳⟧ parsePeriod :: auto-generated pointer for public function parsePeriod
export function parsePeriod(value: string): { milliseconds: number; label: string } {
  const match = value.trim().toLowerCase().match(
    /^(\d+(?:\.\d+)?)\s*(s|sec|secs|second|seconds|m|min|mins|minute|minutes|h|hr|hrs|hour|hours|d|day|days|w|week|weeks)$/,
  );
  if (!match) {
    throw new Error(`invalid period "${value}"; use forms such as 30m, 2h, 1d, or 1 week`);
  }

  const amount = Number(match[1]);
  if (!Number.isFinite(amount) || amount <= 0) {
    throw new Error("period must be greater than zero");
  }

  const unit = match[2];
  const unitMs = unit.startsWith("s") ? 1_000
    : unit.startsWith("m") ? 60_000
      : unit.startsWith("h") ? 3_600_000
        : unit.startsWith("d") ? 86_400_000
          : 604_800_000;
  const milliseconds = amount * unitMs;
  const canonicalUnit = unitMs === 1_000 ? "second"
    : unitMs === 60_000 ? "minute"
      : unitMs === 3_600_000 ? "hour"
        : unitMs === 86_400_000 ? "day"
          : "week";

  return {
    milliseconds,
    label: `${amount} ${canonicalUnit}${amount === 1 ? "" : "s"}`,
  };
}

// ⟦𓄆𓇟𓈁𓌨⟧ queryRecentSessions :: auto-generated pointer for public function queryRecentSessions
export function queryRecentSessions(dbPath: string, since: Date, limit: number): RecentSession[] {
  let db: Database.Database;
  try {
    db = new Database(dbPath, { readonly: true, fileMustExist: true });
  } catch {
    throw new Error(`index not found at ${dbPath}; run \`llm-toolkit\` once to build it`);
  }

  try {
    const rows = db.prepare(`
      SELECT
        c.id,
        c.title,
        c.project_path,
        c.harness,
        c.source_path,
        c.started_at,
        c.updated_at,
        c.message_count,
        (SELECT m.content FROM messages m WHERE m.conversation_id = c.id ORDER BY m.id ASC LIMIT 1) AS first_message,
        (SELECT m.content FROM messages m WHERE m.conversation_id = c.id ORDER BY m.id DESC LIMIT 1) AS last_message
      FROM conversations c
      WHERE c.updated_at >= ?
      ORDER BY c.updated_at DESC
      LIMIT ?
    `).all(since.toISOString(), limit) as RecentRow[];

    return rows.map((row) => ({
      id: row.id,
      title: row.title,
      directory: row.project_path,
      runner: row.harness,
      source: row.source_path,
      startedAt: row.started_at,
      updatedAt: row.updated_at,
      messageCount: row.message_count,
      firstMessage: row.first_message,
      lastMessage: row.last_message,
    }));
  } catch (error) {
    if (error instanceof Error && error.message.includes("no such table")) {
      throw new Error(`index at ${dbPath} is not initialized; run \`llm-toolkit\` once`);
    }
    throw error;
  } finally {
    db.close();
  }
}

// ⟦𓃧𓇎𓊭𓆝⟧ formatRecentSessions :: auto-generated pointer for public function formatRecentSessions
export function formatRecentSessions(sessions: RecentSession[], options: RecentOptions): string {
  const header = `Recent sessions · last ${options.periodLabel} · ${sessions.length} found`;
  if (sessions.length === 0) return `${header}\nNo indexed sessions were updated in this period.`;

  const blocks = sessions.map((session, index) => [
    `${index + 1}. ${session.title || "Untitled session"}`,
    `   id:        ${session.id}`,
    `   updated:   ${formatTimestamp(session.updatedAt)} (${session.messageCount} messages)`,
    `   directory: ${session.directory}`,
    `   runner:    ${session.runner}`,
    `   source:    ${session.source}`,
    `   first:     ${messagePreview(session.firstMessage, options.full)}`,
    `   last:      ${messagePreview(session.lastMessage, options.full)}`,
  ].join("\n"));

  return `${header}\n\n${blocks.join("\n\n")}`;
}

function messagePreview(message: string | null, full: boolean): string {
  if (!message) return "—";
  const oneLine = message.replace(/\s+/g, " ").trim();
  if (full || oneLine.length <= MAX_PREVIEW_LENGTH) return oneLine;
  return `${oneLine.slice(0, MAX_PREVIEW_LENGTH - 1)}…`;
}

function formatTimestamp(value: string): string {
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? value : date.toLocaleString();
}

function parseLimit(value: string | undefined): number {
  if (!value || !/^\d+$/.test(value)) throw new Error("--limit requires a positive integer");
  const limit = Number(value);
  if (limit < 1 || limit > MAX_LIMIT) {
    throw new Error(`--limit must be between 1 and ${MAX_LIMIT}`);
  }
  return limit;
}

function requireFlagValue(flag: string, value: string | undefined): string {
  if (!value) throw new Error(`${flag} requires a period`);
  return value;
}

function recentHelp(): string {
  return `Usage: llm-toolkit recent [period] [options]

List recently updated sessions without starting the API or web UI.

Periods:
  30m, 2h, 1d, 1 week       Default: 1h

Options:
  --period, --since <period>  Alternative to the positional period
  --limit <count>             Maximum sessions (default: ${DEFAULT_LIMIT}, max: ${MAX_LIMIT})
  --full                      Do not truncate first/last message previews
  --json                      Emit machine-readable JSON
  -h, --help                  Show this help

Examples:
  llm-toolkit recent
  llm-toolkit recent 2h
  llm-toolkit recent --since 30m --limit 10
  llm-toolkit recent 1d --json`;
}
