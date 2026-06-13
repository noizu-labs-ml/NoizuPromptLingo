import { createHash, randomUUID } from "node:crypto";
import { renameSync, mkdirSync, existsSync, readdirSync, writeFileSync, readFileSync } from "node:fs";
import { join, basename, dirname } from "node:path";
import type { StorageService } from "./storage.ts";
import type { EditedMessage } from "@claude-assist/shared";

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

    const lines: string[] = [];

    lines.push(JSON.stringify({
      type: "permission-mode",
      permissionMode: "default",
      sessionId,
    }));

    const now = new Date().toISOString();
    for (let i = 0; i < editMessages.length; i++) {
      const msg = editMessages[i];
      const uuid = randomUUID();
      const record: Record<string, unknown> = {
        parentUuid: i === 0 ? null : undefined,
        isSidechain: false,
        type: msg.role === "user" ? "user" : "assistant",
        message: {
          role: msg.role,
          content: msg.role === "assistant"
            ? [{ type: "text", text: msg.content }]
            : msg.content,
          ...(msg.role === "assistant" ? { model: "<edited>", stop_reason: "end_turn" } : {}),
        },
        uuid,
        timestamp: now,
        sessionId,
      };
      lines.push(JSON.stringify(record));
    }

    if (description) {
      lines.push(JSON.stringify({ type: "customTitle", customTitle: description }));
    }

    writeFileSync(filePath, lines.join("\n") + "\n", "utf-8");

    const newId = mode === "new"
      ? createHash("sha256").update(`${filePath}:${now}`).digest("hex").slice(0, 16)
      : conversationId;

    await this.storage.upsertConversation({
      id: newId,
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

function convToUpsert(conv: { id: string; projectPath: string; startedAt: Date; updatedAt: Date; messageCount: number; title: string; summary: string | null; tags: string[]; status: string; sourcePath: string }) {
  return {
    id: conv.id,
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
