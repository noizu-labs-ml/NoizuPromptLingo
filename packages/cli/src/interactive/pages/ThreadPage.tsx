import React, { useState } from "react";
import { Box, Text, useInput } from "ink";
import { Spinner, TextInput } from "@inkjs/ui";
import { useRouter } from "../context/RouterContext.js";
import { useApiQuery, apiFetch } from "../hooks/useApi.js";
import { useScroll } from "../hooks/useScroll.js";
import { useTerminalSize } from "../hooks/useTerminalSize.js";
import { SelectableList } from "../components/SelectableList.js";
import { MessageBlock, type ThreadRecord } from "../components/MessageBlock.js";
import { TagChips } from "../components/TagChips.js";
import { ConfirmDialog } from "../components/ConfirmDialog.js";
import { InputModal } from "../components/InputModal.js";

interface ConversationMeta {
  id: string;
  title: string;
  slug: string | null;
  description: string | null;
  projectPath: string;
  messageCount: number;
  startedAt: string;
  updatedAt: string;
  status: string;
  tags: string[];
  sourcePath: string;
}

type Overlay =
  | null
  | "clone"
  | "archive"
  | "rehome"
  | "tag"
  | "save-prompt"
  | "edit-title"
  | "edit-slug"
  | "edit-desc"
  | "remove-tag";

export function ThreadPage() {
  const { current, navigate, goBack } = useRouter();
  const id = current.params.id;
  const { rows } = useTerminalSize();

  const { data: metaData, refetch: refetchMeta } = useApiQuery<{ data: ConversationMeta }>(`/conversations/${id}`);
  const { data: threadData, loading } = useApiQuery<{ data: ThreadRecord[] }>(`/conversations/${id}/thread`);

  const meta = metaData?.data;
  const records = threadData?.data ?? [];

  const [overlay, setOverlay] = useState<Overlay>(null);
  const [expandThinking, setExpandThinking] = useState(false);
  const [showRaw, setShowRaw] = useState(false);
  const [actionMsg, setActionMsg] = useState("");

  const contentHeight = Math.max(5, rows - 14);
  const scroll = useScroll({
    totalItems: records.length,
    viewportHeight: contentHeight,
    isActive: overlay === null,
  });

  const showAction = (msg: string) => {
    setActionMsg(msg);
    setTimeout(() => setActionMsg(""), 2000);
  };

  useInput((input, key) => {
    if (overlay) return;

    if (key.escape || input === "b") goBack();
    else if (input === "e") navigate("edit", { id });
    else if (input === "c") navigate("convert", { id });
    else if (input === "C") setOverlay("clone");
    else if (input === "a") setOverlay("archive");
    else if (input === "r") setOverlay("rehome");
    else if (input === "t") setOverlay("tag");
    else if (input === "T") setOverlay("remove-tag");
    else if (input === "x") setExpandThinking((v) => !v);
    else if (input === "R") setShowRaw((v) => !v);
    else if (input === "p") setOverlay("save-prompt");
    else if (input === "n") setOverlay("edit-title");
    else if (input === "S") setOverlay("edit-slug");
    else if (input === "D") setOverlay("edit-desc");
  }, { isActive: true });

  const handleSaveMeta = async (field: "title" | "slug" | "description", value: string) => {
    const body: Record<string, string | null> = {};
    if (field === "slug") body.slug = value.trim() || null;
    else if (field === "description") body.description = value.trim() || null;
    else body.title = value.trim();

    try {
      await apiFetch(`/conversations/${id}/meta`, {
        method: "PATCH",
        body: JSON.stringify(body),
      });
      showAction(`${field} updated`);
    } catch {
      showAction(`${field} update failed`);
    }
    setOverlay(null);
    refetchMeta();
  };

  const handleClone = async () => {
    try {
      const res = await apiFetch<{ data: { id: string } }>(`/conversations/${id}/clone`, { method: "POST" });
      showAction(`Cloned as ${res.data.id.slice(0, 8)}`);
    } catch {
      showAction("Clone failed");
    }
    setOverlay(null);
  };

  const handleArchive = async () => {
    try {
      await apiFetch(`/conversations/${id}/archive`, { method: "POST" });
      showAction("Archived");
    } catch {
      showAction("Archive failed");
    }
    setOverlay(null);
    refetchMeta();
  };

  const handleRehome = async (project: string) => {
    try {
      await apiFetch(`/conversations/${id}/rehome`, {
        method: "POST",
        body: JSON.stringify({ project }),
      });
      showAction(`Rehomed to ${project}`);
    } catch {
      showAction("Rehome failed");
    }
    setOverlay(null);
    refetchMeta();
  };

  const handleTag = async (tag: string) => {
    const currentTags = meta?.tags ?? [];
    try {
      await apiFetch(`/conversations/${id}/tag`, {
        method: "POST",
        body: JSON.stringify({ tags: [...new Set([...currentTags, tag.trim()])] }),
      });
      showAction(`Tagged: ${tag}`);
    } catch {
      showAction("Tag failed");
    }
    setOverlay(null);
    refetchMeta();
  };

  const handleRemoveTag = async (tag: string) => {
    const currentTags = meta?.tags ?? [];
    try {
      await apiFetch(`/conversations/${id}/tag`, {
        method: "POST",
        body: JSON.stringify({ tags: currentTags.filter((t) => t !== tag.trim()) }),
      });
      showAction(`Removed tag: ${tag}`);
    } catch {
      showAction("Tag removal failed");
    }
    setOverlay(null);
    refetchMeta();
  };

  const handleSavePrompt = async (title: string) => {
    const record = records[scroll.cursor];
    if (!record) return;
    const content = typeof record.message.content === "string"
      ? record.message.content
      : record.message.content
        .filter((b) => b.type === "text")
        .map((b) => b.text)
        .join("\n");

    try {
      await apiFetch("/prompts", {
        method: "POST",
        body: JSON.stringify({
          title,
          content,
          role: record.message.role,
          sourceConversationId: id,
        }),
      });
      showAction("Saved as prompt");
    } catch {
      showAction("Save failed");
    }
    setOverlay(null);
  };

  if (loading) {
    return <Spinner label={`Loading conversation ${id}...`} />;
  }

  if (!meta) {
    return <Text color="red">Conversation not found: {id}</Text>;
  }

  const sessionId = meta.sourcePath.split("/").pop()?.replace(/\.jsonl$/, "") ?? "";
  const resumeCmd = sessionId ? `claude --resume ${sessionId}` : null;

  return (
    <Box flexDirection="column">
      {/* Header */}
      <Box flexDirection="column" borderStyle="single" borderColor="cyan" paddingX={1} marginBottom={1}>
        <Text bold color="cyan">{meta.title}</Text>
        <Text dimColor>
          <Text color="cyan">{meta.slug ? `@${meta.slug}` : meta.id.slice(0, 8)}</Text>
          {" | "}
          <Text color="cyan">{shortProject(meta.projectPath)}</Text>
          {" | "}{meta.messageCount} msgs
          {" | "}{meta.startedAt?.slice(0, 10)}
          {meta.status !== "active" && <Text color="yellow"> [{meta.status}]</Text>}
        </Text>
        {meta.description && <Text dimColor italic>{meta.description}</Text>}
        {meta.tags.length > 0 && <TagChips tags={meta.tags} />}
      </Box>

      {/* Source metadata */}
      <Box flexDirection="column" marginBottom={1}>
        <Text dimColor>Dir: {meta.projectPath}</Text>
        {resumeCmd && <Text dimColor>Resume: {resumeCmd}</Text>}
      </Box>

      {/* Actions */}
      <Text dimColor>
        b:back e:edit c:convert C:clone r:rehome a:archive t:tag T:untag
      </Text>
      <Text dimColor>
        n:rename S:slug D:desc x:thinking R:raw p:prompt
      </Text>

      {actionMsg && <Text color="green">{actionMsg}</Text>}

      {/* Overlays */}
      {overlay === "clone" && (
        <ConfirmDialog message="Clone this conversation?" onConfirm={handleClone} onCancel={() => setOverlay(null)} />
      )}
      {overlay === "archive" && (
        <ConfirmDialog message="Archive this conversation?" onConfirm={handleArchive} onCancel={() => setOverlay(null)} />
      )}
      {overlay === "rehome" && (
        <InputModal label="New project path:" defaultValue={meta.projectPath} onSubmit={handleRehome} onCancel={() => setOverlay(null)} />
      )}
      {overlay === "tag" && (
        <InputModal label="Add tag:" onSubmit={handleTag} onCancel={() => setOverlay(null)} />
      )}
      {overlay === "remove-tag" && (
        <InputModal
          label={`Remove tag (current: ${meta.tags.join(", ")}):`}
          onSubmit={handleRemoveTag}
          onCancel={() => setOverlay(null)}
        />
      )}
      {overlay === "save-prompt" && (
        <InputModal label="Prompt title:" onSubmit={handleSavePrompt} onCancel={() => setOverlay(null)} />
      )}
      {overlay === "edit-title" && (
        <InputModal
          label="New title:"
          defaultValue={meta.title}
          onSubmit={(v) => handleSaveMeta("title", v)}
          onCancel={() => setOverlay(null)}
        />
      )}
      {overlay === "edit-slug" && (
        <InputModal
          label="Slug (lowercase, alphanumeric, hyphens):"
          defaultValue={meta.slug ?? ""}
          onSubmit={(v) => handleSaveMeta("slug", v)}
          onCancel={() => setOverlay(null)}
        />
      )}
      {overlay === "edit-desc" && (
        <InputModal
          label="Description:"
          defaultValue={meta.description ?? ""}
          onSubmit={(v) => handleSaveMeta("description", v)}
          onCancel={() => setOverlay(null)}
        />
      )}

      {/* Messages */}
      {!overlay && (
        <Box flexDirection="column" marginTop={1}>
          <SelectableList
            items={records}
            cursor={scroll.cursor}
            visibleRange={scroll.visibleRange}
            renderItem={(record, index, isCursor) => (
              <MessageBlock
                record={record}
                index={index}
                isCursor={isCursor}
                expandThinking={expandThinking}
                showRaw={showRaw}
              />
            )}
          />
          <Text dimColor>— {scroll.cursor + 1}/{records.length} messages —</Text>
        </Box>
      )}
    </Box>
  );
}

function shortProject(path: string): string {
  const parts = path.split("/").filter(Boolean);
  return parts.length > 2 ? parts.slice(-2).join("/") : path;
}
