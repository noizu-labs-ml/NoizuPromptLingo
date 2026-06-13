import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import { basename, dirname, join } from "node:path";
import {
  extractTextContent,
  isAssistantMessage,
  isCustomTitle,
  isUserMessage,
  parseJsonlFile,
  type AssistantMessage,
  type BaseRecord,
  type CustomTitleRecord,
  type UserMessage,
} from "@claude-assist/shared";
import type {
  AgentHarness,
  IndexSource,
  RawTranscriptEvent,
  UniversalContentBlock,
  UniversalMessage,
  UniversalRole,
} from "@claude-assist/shared";
import { StorageService, type StoredMessage } from "./storage.ts";
import type { EmbeddingService } from "./embeddings.ts";

export interface IndexProgress {
  phase: "idle" | "scanning" | "indexing" | "embedding";
  current: number;
  total: number;
  currentFile?: string;
}

interface ParsedMessage {
  role: string;
  content: string;
  timestamp: string;
}

interface ParsedConversation {
  id?: string;
  projectPath?: string;
  startedAt: string;
  updatedAt: string;
  title?: string;
  messages: ParsedMessage[];
  universalMessages: UniversalMessage[];
  rawEvents: RawTranscriptEvent[];
  providerMetadata?: Record<string, unknown>;
}

interface CodexRecord {
  timestamp?: string;
  type?: string;
  payload?: {
    id?: string;
    cwd?: string;
    type?: string;
    role?: string;
    content?: unknown;
  };
}

export class IndexerService {
  private storage: StorageService;
  private embeddings: EmbeddingService | null;
  private indexSources: IndexSource[];
  private watcher: unknown = null;
  private debounceTimer: ReturnType<typeof setTimeout> | null = null;
  private fileModTimes = new Map<string, number>();
  private _progress: IndexProgress = { phase: "idle", current: 0, total: 0 };

  constructor(storage: StorageService, indexSources: Array<string | IndexSource> = [], embeddings?: EmbeddingService) {
    this.storage = storage;
    this.embeddings = embeddings ?? null;
    this.indexSources = normalizeIndexSources(indexSources);
  }

  get progress(): IndexProgress {
    return { ...this._progress };
  }

  async indexAll(): Promise<{ indexed: number; errors: number; skipped: number }> {
    this.storage.setIndexStatus("indexing");
    this._progress = { phase: "scanning", current: 0, total: 0 };

    const allFiles: Array<{ source: IndexSource; filePath: string }> = [];
    for (const source of this.indexSources) {
      allFiles.push(...findJsonlFiles(source.path).map((filePath) => ({ source, filePath })));
    }

    this._progress = { phase: "indexing", current: 0, total: allFiles.length };
    let indexed = 0;
    let errors = 0;
    let skipped = 0;

    for (let i = 0; i < allFiles.length; i++) {
      const { source, filePath } = allFiles[i];
      this._progress = { phase: "indexing", current: i + 1, total: allFiles.length, currentFile: basename(filePath) };
      try {
        const mtime = statSync(filePath).mtimeMs;
        const prevMtime = this.fileModTimes.get(filePath);
        if (prevMtime && prevMtime >= mtime) {
          skipped++;
          continue;
        }
        await this.indexFile(filePath, source);
        this.fileModTimes.set(filePath, mtime);
        indexed++;
      } catch (e) {
        errors++;
        console.error(`Failed to index ${filePath}:`, e instanceof Error ? e.message : e);
      }
    }

    this._progress = { phase: "idle", current: 0, total: 0 };
    this.storage.setIndexStatus("idle");
    return { indexed, errors, skipped };
  }

  async indexFile(filePath: string, source?: IndexSource): Promise<void> {
    const resolvedSource = source ?? this.sourceForFile(filePath) ?? { harness: "claude", path: dirname(filePath), format: "jsonl" };
    const parsed = parseHarnessFile(resolvedSource.harness, filePath);

    await this.indexParsedFile(parsed, filePath, resolvedSource.harness);
  }

  async watch(): Promise<void> {
    try {
      const chokidar = await import("chokidar");
      const watcher = chokidar.watch(
        this.indexSources.map((source) => join(source.path, "**/*.jsonl")),
        { ignoreInitial: true, awaitWriteFinish: { stabilityThreshold: 1000 } },
      );

      watcher.on("add", (path: string) => this.debouncedIndex(path));
      watcher.on("change", (path: string) => this.debouncedIndex(path));

      this.watcher = watcher;
      console.log("File watcher started");
    } catch (err) {
      console.warn("Failed to start file watcher:", err instanceof Error ? err.message : err);
    }
  }

  async stopWatch(): Promise<void> {
    if (this.watcher && typeof (this.watcher as { close: () => Promise<void> }).close === "function") {
      await (this.watcher as { close: () => Promise<void> }).close();
      this.watcher = null;
    }
  }

  getStatus(): { status: string; lastIndexed: string | null; conversationCount: number } {
    return this.storage.getIndexStatus();
  }

  async scanPreview(): Promise<ScanPreview> {
    const projects: ScanProject[] = [];
    let totalFiles = 0;
    let totalNewFiles = 0;

    for (const source of this.indexSources) {
      const dirEntries = new Map<string, string[]>();

      const jsonlFiles = findJsonlFiles(source.path);
      for (const filePath of jsonlFiles) {
        const dirName = basename(dirname(filePath));
        if (!dirEntries.has(dirName)) dirEntries.set(dirName, []);
        dirEntries.get(dirName)!.push(filePath);
      }

      for (const [dirName, files] of dirEntries) {
        const projectPath = source.harness === "claude"
          ? decodeProjectPath(join(source.path, dirName))
          : dirName;
        let newCount = 0;
        for (const f of files) {
          const mtime = statSync(f).mtimeMs;
          const prev = this.fileModTimes.get(f);
          if (!prev || prev < mtime) newCount++;
        }
        projects.push({
          harness: source.harness,
          projectPath,
          encodedDir: dirName,
          fileCount: files.length,
          newOrChanged: newCount,
        });
        totalFiles += files.length;
        totalNewFiles += newCount;
      }
    }

    projects.sort((a, b) => b.fileCount - a.fileCount);

    const embeddingProvider = this.embeddings?.ready ? "local" : "none";
    const estimatedTokens = totalNewFiles * 2000;
    const estimatedCost = embeddingProvider === "local" ? 0 : estimatedTokens * 0.00001;

    return {
      watchPaths: this.indexSources.map((source) => source.path),
      indexSources: this.indexSources,
      projects,
      totalFiles,
      totalNewFiles,
      embeddingProvider,
      estimatedTokens,
      estimatedCost,
    };
  }

  private async indexParsedFile(parsed: ParsedConversation | null, filePath: string, harness: AgentHarness): Promise<void> {
    if (!parsed || parsed.messages.length === 0) return;

    const conversationId = parsed.id ?? StorageService.generateId(filePath, parsed.startedAt, harness);
    const projectPath = parsed.projectPath ?? decodeProjectPath(dirname(filePath));
    const title = parsed.title ?? generateTitleFromMessages(parsed.messages);

    const existing = await this.storage.getConversation(conversationId);
    await this.storage.upsertConversation({
      id: conversationId,
      harness,
      projectPath,
      startedAt: parsed.startedAt,
      updatedAt: parsed.updatedAt,
      messageCount: parsed.messages.length,
      title,
      tags: existing?.tags,
      status: existing?.status,
      sourcePath: filePath,
    });

    const messages: StoredMessage[] = parsed.messages.map((message) => ({
      conversationId,
      role: message.role,
      content: message.content,
      timestamp: message.timestamp,
    }));

    await this.storage.insertMessages(conversationId, messages);
    await this.storage.insertUniversalMessages(conversationId, parsed.universalMessages);
    await this.storage.insertRawTranscriptEvents(conversationId, parsed.rawEvents);

    if (this.embeddings?.ready && this.storage.vecAvailable) {
      try {
        const summaryText = messages
          .slice(0, 10)
          .map((m) => m.content)
          .join("\n")
          .slice(0, 2000);
        const embedding = await this.embeddings.embed(summaryText);
        await this.storage.upsertVector(conversationId, embedding);
      } catch {
        // Non-fatal: skip embedding for this conversation.
      }
    }
  }

  private debouncedIndex(filePath: string): void {
    if (this.debounceTimer) clearTimeout(this.debounceTimer);
    this.debounceTimer = setTimeout(async () => {
      try {
        await this.indexFile(filePath);
        this.fileModTimes.set(filePath, Date.now());
        console.log(`Re-indexed: ${basename(filePath)}`);
      } catch (e) {
        console.error(`Watch re-index failed for ${filePath}:`, e instanceof Error ? e.message : e);
      }
    }, 2000);
  }

  private sourceForFile(filePath: string): IndexSource | null {
    return this.indexSources.find((source) => filePath.startsWith(source.path)) ?? null;
  }
}

export interface ScanProject {
  harness: AgentHarness;
  projectPath: string;
  encodedDir: string;
  fileCount: number;
  newOrChanged: number;
}

export interface ScanPreview {
  watchPaths: string[];
  indexSources: IndexSource[];
  projects: ScanProject[];
  totalFiles: number;
  totalNewFiles: number;
  embeddingProvider: string;
  estimatedTokens: number;
  estimatedCost: number;
}

function parseHarnessFile(harness: AgentHarness, filePath: string): ParsedConversation | null {
  switch (harness) {
    case "claude":
      return parseClaudeFile(filePath);
    case "codex":
      return parseCodexFile(filePath);
    case "gemini":
    case "opencode":
    case "aider":
    case "other":
      return parsePendingHarnessFile(harness, filePath);
  }
}

function parsePendingHarnessFile(harness: AgentHarness, _filePath: string): ParsedConversation | null {
  // TODO(agent-watch-dog): validate real transcripts before implementing this
  // importer. Gemini, OpenCode, Aider, and user-defined "other" sources should
  // preserve raw provider events and normalize into UniversalMessage records
  // only after sample transcript formats are captured.
  console.warn(`${harness} transcript import is stubbed until real transcript samples are available`);
  return null;
}

function parseClaudeFile(filePath: string): ParsedConversation | null {
  const content = readFileSync(filePath, "utf-8");
  const allRecords: Array<BaseRecord | CustomTitleRecord> = [];
  for (const record of parseJsonlFile(content)) {
    allRecords.push(record);
  }

  if (allRecords.length === 0) return null;

  const contentRecords = allRecords.filter(
    (r): r is UserMessage | AssistantMessage =>
      isUserMessage(r) || isAssistantMessage(r),
  );

  let customTitle: string | null = null;
  for (const record of allRecords) {
    if (isCustomTitle(record) && record.customTitle) {
      customTitle = record.customTitle;
    }
  }

  if (contentRecords.length === 0) return null;

  const firstRecord = contentRecords[0];
  const lastRecord = contentRecords[contentRecords.length - 1];
  const firstTimestamp = firstRecord.timestamp ?? new Date().toISOString();
  const lastTimestamp = lastRecord.timestamp ?? firstTimestamp;
  const universalMessages = contentRecords.map((record, index) => claudeRecordToUniversalMessage(record, filePath, index));

  return {
    startedAt: firstTimestamp,
    updatedAt: lastTimestamp,
    projectPath: decodeProjectPath(dirname(filePath)),
    title: customTitle ?? generateTitle(contentRecords),
    messages: universalMessages.map(universalToSearchMessage),
    universalMessages,
    rawEvents: allRecords.map((record, index) => rawEventFromRecord("claude", record, filePath, index)),
  };
}

function parseCodexFile(filePath: string): ParsedConversation | null {
  const records = readFileSync(filePath, "utf-8")
    .split("\n")
    .filter((line) => line.trim())
    .map((line) => JSON.parse(line) as CodexRecord);

  if (records.length === 0) return null;

  let sessionId: string | null = null;
  let projectPath: string | null = null;
  let title: string | null = null;
  const universalMessages: UniversalMessage[] = [];

  for (let index = 0; index < records.length; index++) {
    const record = records[index];
    if (record.type === "session_meta") {
      sessionId = stringOrNull(record.payload?.id) ?? sessionId;
      projectPath = stringOrNull(record.payload?.cwd) ?? projectPath;
    }

    if (record.type !== "response_item") continue;
    const payload = record.payload;
    if (payload?.type !== "message") continue;
    if (payload.role !== "user" && payload.role !== "assistant") continue;

    const message = codexRecordToUniversalMessage(record, filePath, index);
    if (message.content.length === 0) continue;
    universalMessages.push(message);
  }

  const messages = universalMessages.map(universalToSearchMessage);
  if (messages.length === 0) return null;
  if (sessionId) title = loadCodexTitle(filePath, sessionId);

  return {
    id: sessionId ? `codex:${sessionId}` : undefined,
    startedAt: messages[0].timestamp,
    updatedAt: messages[messages.length - 1].timestamp,
    projectPath: projectPath ?? dirname(filePath),
    title: title ?? generateTitleFromMessages(messages),
    messages,
    universalMessages,
    rawEvents: records.map((record, index) => rawEventFromRecord("codex", record, filePath, index)),
    providerMetadata: sessionId ? { sessionId } : undefined,
  };
}

function extractCodexContent(content: unknown): string {
  if (typeof content === "string") return content;
  if (!Array.isArray(content)) return "";
  return content
    .map((block) => {
      if (!block || typeof block !== "object") return "";
      const typed = block as Record<string, unknown>;
      if (typeof typed.text === "string") return typed.text;
      return "";
    })
    .filter(Boolean)
    .join("\n");
}

function claudeRecordToUniversalMessage(record: UserMessage | AssistantMessage, sourcePath: string, rawIndex: number): UniversalMessage {
  const role: UniversalRole = record.type === "assistant" ? "assistant" : "user";
  const content = record.type === "assistant"
    ? record.message.content.map((block) => claudeBlockToUniversal(block))
    : claudeUserContentToUniversal(record.message.content);

  return {
    id: record.uuid,
    role,
    timestamp: record.timestamp ?? "",
    content,
    providerMessageId: record.uuid,
    model: record.type === "assistant" ? record.message.model : undefined,
    stopReason: record.type === "assistant" ? record.message.stop_reason : undefined,
    usage: record.type === "assistant" ? record.message.usage : undefined,
    provenance: {
      harness: "claude",
      sourcePath,
      rawIndex,
      parentId: record.parentUuid,
    },
    providerHints: {
      sessionId: record.sessionId,
      isSidechain: record.isSidechain,
    },
  };
}

function claudeUserContentToUniversal(content: string | Array<Record<string, unknown>>): UniversalContentBlock[] {
  if (typeof content === "string") return [{ type: "text", text: content }];
  return content.map((block) => claudeBlockToUniversal(block));
}

function claudeBlockToUniversal(block: Record<string, unknown>): UniversalContentBlock {
  switch (block.type) {
    case "text":
      return { type: "text", text: stringOrEmpty(block.text), providerType: "text" };
    case "thinking":
      return {
        type: "thinking",
        thinking: stringOrEmpty(block.thinking),
        signature: stringOrUndefined(block.signature),
        providerType: "thinking",
      };
    case "tool_use":
      return {
        type: "tool_use",
        toolCallId: stringOrEmpty(block.id),
        name: stringOrEmpty(block.name),
        input: objectOrEmpty(block.input),
        providerType: "tool_use",
      };
    case "tool_result":
      return {
        type: "tool_result",
        toolCallId: stringOrEmpty(block.tool_use_id),
        content: typeof block.content === "string" ? block.content : JSON.stringify(block.content ?? ""),
        isError: typeof block.is_error === "boolean" ? block.is_error : undefined,
        providerType: "tool_result",
      };
    default:
      return { type: "unknown", raw: block, providerType: typeof block.type === "string" ? block.type : undefined };
  }
}

function codexRecordToUniversalMessage(record: CodexRecord, sourcePath: string, rawIndex: number): UniversalMessage {
  const role = normalizeRole(record.payload?.role);
  return {
    id: `${sourcePath}:${rawIndex}`,
    role,
    timestamp: record.timestamp ?? "",
    content: codexContentToUniversal(record.payload?.content),
    provenance: {
      harness: "codex",
      sourcePath,
      rawIndex,
    },
    providerHints: {
      payloadType: record.payload?.type,
    },
  };
}

function codexContentToUniversal(content: unknown): UniversalContentBlock[] {
  if (typeof content === "string") return [{ type: "text", text: content }];
  if (!Array.isArray(content)) return [];
  return content.map((block) => {
    if (!block || typeof block !== "object") {
      return { type: "unknown", raw: block } satisfies UniversalContentBlock;
    }
    const typed = block as Record<string, unknown>;
    switch (typed.type) {
      case "input_text":
      case "output_text":
      case "text":
        return { type: "text", text: stringOrEmpty(typed.text), providerType: String(typed.type) };
      default:
        return { type: "unknown", raw: typed, providerType: typeof typed.type === "string" ? typed.type : undefined };
    }
  });
}

function universalToSearchMessage(message: UniversalMessage): ParsedMessage {
  return {
    role: message.role,
    content: universalContentToText(message.content),
    timestamp: message.timestamp,
  };
}

function universalContentToText(blocks: UniversalContentBlock[]): string {
  return blocks
    .map((block) => {
      switch (block.type) {
        case "text":
          return block.text;
        case "thinking":
          return block.thinking;
        case "tool_use":
          return JSON.stringify({ tool_use: block.name, input: block.input });
        case "tool_result":
          return typeof block.content === "string" ? block.content : universalContentToText(block.content);
        case "audio":
          return block.transcript ?? "";
        case "document":
          return block.text ?? "";
        default:
          return "";
      }
    })
    .filter(Boolean)
    .join("\n");
}

function rawEventFromRecord(harness: AgentHarness, raw: unknown, sourcePath: string, index: number): RawTranscriptEvent {
  const typed = raw && typeof raw === "object" ? raw as Record<string, unknown> : {};
  const timestamp = typeof typed.timestamp === "string" ? typed.timestamp : new Date(0).toISOString();
  const eventType = typeof typed.type === "string" ? typed.type : "unknown";
  return {
    id: StorageService.generateId(sourcePath, `${timestamp}:${index}:${eventType}`, harness),
    timestamp,
    harness,
    eventType,
    raw,
  };
}

function normalizeRole(role: unknown): UniversalRole {
  if (role === "system" || role === "developer" || role === "user" || role === "assistant" || role === "tool") {
    return role;
  }
  return "user";
}

function loadCodexTitle(filePath: string, sessionId: string): string | null {
  const root = findCodexRoot(filePath);
  if (!root) return null;
  const indexPath = join(root, "session_index.jsonl");
  if (!existsSync(indexPath)) return null;
  try {
    for (const line of readFileSync(indexPath, "utf-8").split("\n")) {
      if (!line.trim()) continue;
      const row = JSON.parse(line) as { id?: string; thread_name?: string };
      if (row.id === sessionId && row.thread_name) return row.thread_name;
    }
  } catch {
    return null;
  }
  return null;
}

function findCodexRoot(filePath: string): string | null {
  let current = dirname(filePath);
  while (current && current !== dirname(current)) {
    if (basename(current) === ".codex") return current;
    current = dirname(current);
  }
  return null;
}

function normalizeIndexSources(sources: Array<string | IndexSource>): IndexSource[] {
  return sources.map((source) =>
    typeof source === "string"
      ? { harness: "claude", path: source, format: "jsonl" }
      : { format: "jsonl", ...source },
  );
}

function findJsonlFiles(dir: string): string[] {
  const results: string[] = [];
  try {
    const entries = readdirSync(dir, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = join(dir, entry.name);
      if (entry.isDirectory()) {
        results.push(...findJsonlFiles(fullPath));
      } else if (entry.name.endsWith(".jsonl")) {
        results.push(fullPath);
      }
    }
  } catch {
    // Skip directories we can't read.
  }
  return results;
}

/**
 * Decode a Claude Code encoded directory name back to a real filesystem path.
 *
 * Claude Code encodes /Users/foo/noizu-infra as -Users-foo-noizu-infra,
 * which is ambiguous: -noizu-infra could mean /noizu/infra or /noizu-infra.
 *
 * Resolution: greedy left-to-right, preferring hyphenated directory names
 * (literal hyphens) over nested directories at each step. Falls back to
 * treating hyphens as path separators when neither exists.
 */
function decodeProjectPath(dirPath: string): string {
  const dirName = basename(dirPath);
  if (!dirName.startsWith("-")) return dirName;

  const segments = dirName.slice(1).split("-");
  if (segments.length === 0) return "/";

  return resolveEncodedSegments(segments);
}

function resolveEncodedSegments(segments: string[]): string {
  let resolved = "/";
  let i = 0;

  while (i < segments.length) {
    let matched = false;
    for (let end = segments.length; end > i + 1; end--) {
      const candidate = segments.slice(i, end).join("-");
      const candidatePath = join(resolved, candidate);
      if (existsSync(candidatePath)) {
        resolved = candidatePath;
        i = end;
        matched = true;
        break;
      }
    }

    if (!matched) {
      resolved = join(resolved, segments[i]);
      i++;
    }
  }

  return resolved;
}

export { decodeProjectPath, resolveEncodedSegments };

function generateTitle(records: (UserMessage | AssistantMessage)[]): string {
  const firstUser = records.find((r): r is UserMessage => r.type === "user");
  if (!firstUser) return "Untitled conversation";

  return truncateTitle(extractTitleText(extractTextContent(firstUser)));
}

function generateTitleFromMessages(messages: ParsedMessage[]): string {
  const firstUser = messages.find((message) => message.role === "user");
  if (!firstUser) return "Untitled conversation";

  return truncateTitle(extractTitleText(firstUser.content));
}

function extractTitleText(text: string): string {
  const commandNameMatch = text.match(/<command-name>([^<]+)<\/command-name>/);
  if (commandNameMatch) {
    const commandName = commandNameMatch[1].trim();
    const argsMatch = text.match(/<command-args>([^<]*)<\/command-args>/);
    const args = argsMatch ? argsMatch[1].trim() : "";
    return args ? `${commandName} ${args}` : commandName;
  }

  return text.split("\n")[0].trim() || "Untitled conversation";
}

function truncateTitle(title: string): string {
  if (title.length <= 80) return title;
  return title.slice(0, 77) + "...";
}

function stringOrNull(value: unknown): string | null {
  return typeof value === "string" ? value : null;
}

function stringOrUndefined(value: unknown): string | undefined {
  return typeof value === "string" ? value : undefined;
}

function stringOrEmpty(value: unknown): string {
  return typeof value === "string" ? value : "";
}

function objectOrEmpty(value: unknown): Record<string, unknown> {
  if (!value || typeof value !== "object" || Array.isArray(value)) return {};
  return value as Record<string, unknown>;
}
