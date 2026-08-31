import { createHash, randomUUID } from "node:crypto";
import { renameSync, mkdirSync, existsSync, readdirSync, writeFileSync, readFileSync } from "node:fs";
import { join, basename, dirname } from "node:path";
import type { StorageService } from "./storage.ts";
import type { AgentHarness, EditedMessage } from "@llm-toolkit/shared";

interface JsonlEntry {
  raw: Record<string, unknown>;
  messageIndex?: number;
}

export class OperationsService {
  constructor(private storage: StorageService) {}

  async archive(conversationId: string): Promise<void> {
    const conv = await this.storage.getConversation(conversationId);
    if (!conv) throw new Error("Conversation not found");
    await this.storage.upsertConversation({
      ...convToUpsert(conv),
      status: "archived",
    });
  }

  async tag(conversationId: string, tags: string[]): Promise<void> {
    const conv = await this.storage.getConversation(conversationId);
    if (!conv) throw new Error("Conversation not found");
    await this.storage.upsertConversation({
      ...convToUpsert(conv),
      tags,
    });
  }

  async clone(conversationId: string): Promise<string> {
    const conv = await this.storage.getConversation(conversationId);
    if (!conv) throw new Error("Conversation not found");
    const newId = createHash("sha256").update(`${conv.id}:clone:${Date.now()}`).digest("hex").slice(0, 16);
    await this.storage.upsertConversation({
      ...convToUpsert(conv),
      id: newId,
      title: `${conv.title} (copy)`,
    });
    const messages = await this.storage.getMessages(conversationId);
    const clonedMessages = messages.map((m) => ({ ...m, conversationId: newId }));
    await this.storage.insertMessages(newId, clonedMessages);
    return newId;
  }

  async saveEdit(
    conversationId: string,
    editMessages: EditedMessage[],
    mode: "new" | "overwrite",
    description?: string,
  ): Promise<{ id: string; sourcePath: string }> {
    const conv = await this.storage.getConversation(conversationId);
    if (!conv) throw new Error("Conversation not found");

    const sessionId = mode === "new" ? randomUUID() : basename(conv.sourcePath, ".jsonl");
    const dir = dirname(conv.sourcePath);
    const filePath = mode === "new" ? join(dir, `${sessionId}.jsonl`) : conv.sourcePath;

    const now = new Date().toISOString();
    const originalEntries = loadJsonlEntries(conv.sourcePath);
    const messageEntries = originalEntries.filter((entry) => entry.messageIndex !== undefined);
    const buckets = bucketNonMessageEntries(originalEntries);
    const emittedBuckets = new Set<number>();
    const output: Record<string, unknown>[] = [];

    const emitBucket = (bucket: number) => {
      if (emittedBuckets.has(bucket)) return;
      emittedBuckets.add(bucket);
      for (const entry of buckets.get(bucket) ?? []) {
        const copied = structuredClone(entry);
        if (mode === "new") updateRecordSession(copied, sessionId);
        output.push(copied);
      }
    };

    if (originalEntries.length === 0) {
      output.push({
        type: "permission-mode",
        permissionMode: "default",
        sessionId,
      });
      emittedBuckets.add(0);
    } else {
      emitBucket(0);
    }

    let highestOriginalIndex = 0;
    for (const msg of editMessages) {
      const originalIndex = typeof msg.originalIndex === "number" ? msg.originalIndex : undefined;
      if (originalIndex !== undefined) {
        for (let bucket = highestOriginalIndex + 1; bucket <= originalIndex; bucket++) emitBucket(bucket);
        highestOriginalIndex = Math.max(highestOriginalIndex, originalIndex);
      }

      const sourceRecord = originalIndex !== undefined ? messageEntries[originalIndex]?.raw : undefined;
      const record = buildEditedRecord(msg, sourceRecord, sessionId, now);
      if (mode === "new") updateRecordSession(record, sessionId);
      output.push(record);
    }

    for (let bucket = highestOriginalIndex + 1; bucket <= messageEntries.length; bucket++) emitBucket(bucket);

    if (description) {
      output.push({ type: "custom-title", customTitle: description, sessionId });
    }

    const lines = output.map((entry) => JSON.stringify(entry));
    writeFileSync(filePath, lines.join("\n") + "\n", "utf-8");

    const newId = mode === "new"
      ? createHash("sha256").update(`${filePath}:${now}`).digest("hex").slice(0, 16)
      : conversationId;

    await this.storage.upsertConversation({
      id: newId,
      harness: conv.harness,
      projectPath: conv.projectPath,
      startedAt: now,
      updatedAt: now,
      messageCount: editMessages.length,
      title: description ?? conv.title,
      tags: conv.tags,
      status: "active",
      sourcePath: filePath,
    });

    const storedMessages = editMessages.map((m) => ({
      conversationId: newId,
      role: m.role,
      content: m.content,
      timestamp: now,
    }));
    await this.storage.insertMessages(newId, storedMessages);

    return { id: newId, sourcePath: filePath };
  }

  async rehome(conversationId: string, targetProject: string): Promise<void> {
    const conv = await this.storage.getConversation(conversationId);
    if (!conv) throw new Error("Conversation not found");

    const oldPath = conv.sourcePath;
    const fileName = basename(oldPath);
    const projectsRoot = dirname(dirname(oldPath));

    // Find or create the target directory.
    // Claude Code encodes /Users/foo/bar as -Users-foo-bar, but this is
    // ambiguous with paths containing literal hyphens. If a directory already
    // exists for this project, reuse it. Otherwise encode with the standard
    // Claude Code scheme.
    const targetDir = findOrCreateProjectDir(projectsRoot, targetProject);
    const newPath = join(targetDir, fileName);

    if (oldPath !== newPath) {
      mkdirSync(targetDir, { recursive: true });
      renameSync(oldPath, newPath);
    }

    await this.storage.upsertConversation({
      ...convToUpsert(conv),
      projectPath: targetProject,
      sourcePath: newPath,
    });
  }
}

/**
 * Find an existing Claude Code project directory for a given path, or create
 * the standard encoded name.
 *
 * Scans existing directories in the projects root to find one that decodes
 * to the target path. This handles the ambiguity where /Users/foo/noizu-infra
 * is encoded as -Users-foo-noizu-infra (same encoding as /Users/foo/noizu/infra).
 */
function findOrCreateProjectDir(projectsRoot: string, targetProject: string): string {
  // Check if any existing directory decodes to the target project
  try {
    const entries = readdirSync(projectsRoot, { withFileTypes: true });
    for (const entry of entries) {
      if (!entry.isDirectory() || !entry.name.startsWith("-")) continue;
      // A directory matches if, when we resolve its encoded name against the
      // filesystem, it points to the target project path
      const decoded = greedyDecode(entry.name);
      if (decoded === targetProject) {
        return join(projectsRoot, entry.name);
      }
    }
  } catch {
    // projects root doesn't exist yet — fall through to create
  }

  // No existing directory found — encode with standard scheme
  const encoded = targetProject.replace(/\//g, "-");
  return join(projectsRoot, encoded);
}

/**
 * Greedy decode: resolve an encoded directory name against the filesystem,
 * preferring literal hyphens in directory names over nested directories.
 */
function greedyDecode(dirName: string): string {
  if (!dirName.startsWith("-")) return dirName;

  const segments = dirName.slice(1).split("-");
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

function convToUpsert(conv: { id: string; harness?: AgentHarness; projectPath: string; startedAt: Date; updatedAt: Date; messageCount: number; title: string; summary: string | null; tags: string[]; status: string; sourcePath: string }) {
  return {
    id: conv.id,
    harness: conv.harness,
    projectPath: conv.projectPath,
    startedAt: conv.startedAt.toISOString(),
    updatedAt: conv.updatedAt.toISOString(),
    messageCount: conv.messageCount,
    title: conv.title,
    summary: conv.summary,
    tags: conv.tags,
    status: conv.status,
    sourcePath: conv.sourcePath,
  };
}

function loadJsonlEntries(filePath: string): JsonlEntry[] {
  try {
    let messageIndex = 0;
    return readFileSync(filePath, "utf-8")
      .split("\n")
      .filter((line) => line.trim())
      .map((line) => {
        const raw = JSON.parse(line) as Record<string, unknown>;
        if (raw.type === "user" || raw.type === "assistant") {
          return { raw, messageIndex: messageIndex++ };
        }
        return { raw };
      });
  } catch {
    return [];
  }
}

function bucketNonMessageEntries(entries: JsonlEntry[]): Map<number, Array<Record<string, unknown>>> {
  const buckets = new Map<number, Array<Record<string, unknown>>>();
  let seenMessages = 0;
  for (const entry of entries) {
    if (entry.messageIndex !== undefined) {
      seenMessages++;
      continue;
    }
    const bucket = seenMessages;
    const items = buckets.get(bucket) ?? [];
    items.push(entry.raw);
    buckets.set(bucket, items);
  }
  return buckets;
}

function buildEditedRecord(
  msg: EditedMessage,
  sourceRecord: Record<string, unknown> | undefined,
  sessionId: string,
  now: string,
): Record<string, unknown> {
  if (msg.rawEdited && isRecord(msg.rawRecord)) {
    return structuredClone(msg.rawRecord);
  }

  const record = sourceRecord ? structuredClone(sourceRecord) : createSyntheticRecord(msg, sessionId, now);
  patchRecordMessage(record, msg);
  return record;
}

function createSyntheticRecord(msg: EditedMessage, sessionId: string, now: string): Record<string, unknown> {
  const type = msg.role === "assistant" ? "assistant" : "user";
  return {
    parentUuid: null,
    isSidechain: false,
    type,
    message: {
      role: msg.role === "system" ? "user" : msg.role,
      content: type === "assistant" ? [{ type: "text", text: msg.content }] : msg.content,
      ...(type === "assistant" ? { model: "<edited>", stop_reason: "end_turn" } : {}),
    },
    uuid: randomUUID(),
    timestamp: now,
    sessionId,
  };
}

function patchRecordMessage(record: Record<string, unknown>, msg: EditedMessage): void {
  const type = msg.role === "assistant" ? "assistant" : "user";
  record.type = type;

  const message = isRecord(record.message) ? structuredClone(record.message) : {};
  message.role = msg.role === "system" ? "user" : msg.role;
  message.content = patchContent(message.content, msg.content, type);
  if (type === "assistant") {
    if (typeof message.model !== "string") message.model = "<edited>";
    if (!("stop_reason" in message)) message.stop_reason = "end_turn";
  }
  record.message = message;
}

function patchContent(existing: unknown, text: string, type: "user" | "assistant"): unknown {
  if (typeof existing === "string") return text;
  if (Array.isArray(existing)) {
    const blocks = structuredClone(existing) as unknown[];
    const textIndex = blocks.findIndex((block) => isRecord(block) && block.type === "text");
    const providerTextKey = type === "assistant" ? "text" : "text";
    if (textIndex >= 0 && isRecord(blocks[textIndex])) {
      blocks[textIndex] = { ...blocks[textIndex], [providerTextKey]: text };
      return blocks;
    }
    return [{ type: "text", text }, ...blocks];
  }
  return type === "assistant" ? [{ type: "text", text }] : text;
}

function updateRecordSession(record: Record<string, unknown>, sessionId: string): void {
  if ("sessionId" in record) record.sessionId = sessionId;
  if (isRecord(record.payload) && "id" in record.payload && record.type === "session_meta") {
    record.payload = { ...record.payload, id: sessionId };
  }
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return Boolean(value) && typeof value === "object" && !Array.isArray(value);
}
