import React, { useState, useEffect, useCallback, useRef } from "react";
import { Box, Text, useInput } from "ink";
import { Spinner, TextInput, Select } from "@inkjs/ui";
import { useRouter } from "../context/RouterContext.js";
import { useApiQuery, apiFetch } from "../hooks/useApi.js";
import { useScroll } from "../hooks/useScroll.js";
import { useTerminalSize } from "../hooks/useTerminalSize.js";
import { SelectableList } from "../components/SelectableList.js";
import { ConfirmDialog } from "../components/ConfirmDialog.js";
import { InputModal } from "../components/InputModal.js";

interface DraftMessage {
  originalIndex?: number;
  role: "user" | "assistant" | "system";
  content: string;
  injected?: boolean;
  collapsed?: boolean;
  template?: string;
}

interface DraftEdit {
  id: string;
  sourceId: string;
  description: string;
  messages: DraftMessage[];
}

interface ThreadRecord {
  type: string;
  message: { role: string; content: string | any[] };
}

type UIMode =
  | "list"
  | "editing"
  | "inserting"
  | "insert-template"
  | "role-select"
  | "confirm-delete"
  | "confirm-revert"
  | "confirm-bulk-delete"
  | "finalize"
  | "simplifying";

const ROLE_OPTIONS = [
  { label: "user", value: "user" },
  { label: "assistant", value: "assistant" },
  { label: "system", value: "system" },
];

const TEMPLATE_OPTIONS = [
  { label: "User Message", value: "user-text" },
  { label: "Assistant Response", value: "assistant-text" },
  { label: "System Context", value: "system-context" },
  { label: "Skill Invocation", value: "skill-invoke" },
  { label: "System Reminder", value: "system-reminder" },
  { label: "Tool Call", value: "tool-use" },
  { label: "Tool Output", value: "tool-result" },
  { label: "Thinking Block", value: "thinking" },
];

const TEMPLATE_ROLES: Record<string, "user" | "assistant" | "system"> = {
  "user-text": "user",
  "assistant-text": "assistant",
  "system-context": "system",
  "skill-invoke": "user",
  "system-reminder": "user",
  "tool-use": "assistant",
  "tool-result": "user",
  "thinking": "assistant",
};

function extractText(content: string | any[]): string {
  if (typeof content === "string") return content;
  const parts: string[] = [];
  for (const block of content) {
    if (block.type === "text" && block.text) parts.push(block.text);
    else if (block.type === "thinking" && block.thinking) parts.push(`<thinking>\n${block.thinking}\n</thinking>`);
    else if (block.type === "tool_use") {
      const input = block.name === "Bash" ? `$ ${block.input?.command ?? ""}` : JSON.stringify(block.input ?? {}, null, 2);
      parts.push(`[Tool: ${block.name}]\n${input}`);
    } else if (block.type === "tool_result") {
      const text = typeof block.content === "string" ? block.content : "";
      if (block.is_error) parts.push(`[Error]\n${text}`);
      else if (text) parts.push(text);
    }
  }
  return parts.join("\n\n");
}

export function EditPage() {
  const { current, goBack } = useRouter();
  const id = current.params.id;
  const { rows } = useTerminalSize();

  const { data: threadData, loading: threadLoading } = useApiQuery<{ data: ThreadRecord[] }>(`/conversations/${id}/thread`);
  const { data: draftData, loading: draftLoading } = useApiQuery<{ data: DraftEdit | null }>(`/conversations/${id}/draft`);

  const [messages, setMessages] = useState<DraftMessage[]>([]);
  const [originalRecords, setOriginalRecords] = useState<ThreadRecord[]>([]);
  const [uiMode, setUiMode] = useState<UIMode>("list");
  const [editContent, setEditContent] = useState("");
  const [selected, setSelected] = useState<Set<number>>(new Set());
  const [dirty, setDirty] = useState(false);
  const [actionMsg, setActionMsg] = useState("");
  const [draftId, setDraftId] = useState<string | null>(null);
  const draftIdRef = useRef<string | null>(null);
  const saveTimeout = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => { draftIdRef.current = draftId; }, [draftId]);

  useEffect(() => {
    const records = threadData?.data ?? [];
    setOriginalRecords(records);

    if (draftData?.data?.messages) {
      setMessages(draftData.data.messages);
      setDraftId(draftData.data.id);
      draftIdRef.current = draftData.data.id;
      setDirty(true);
    } else if (records.length > 0) {
      setMessages(records
        .filter((r) => r.type === "user" || r.type === "assistant")
        .map((r, i) => ({
          originalIndex: i,
          role: r.message.role as any,
          content: extractText(r.message.content),
        }))
      );
    }
  }, [threadData, draftData]);

  const persistDraft = useCallback(async (msgs: DraftMessage[]) => {
    if (!id) return;
    try {
      if (!draftIdRef.current) {
        const res = await apiFetch<{ data: DraftEdit }>(`/conversations/${id}/draft`, {
          method: "POST",
          body: JSON.stringify({ messages: msgs }),
        });
        setDraftId(res.data.id);
        draftIdRef.current = res.data.id;
      } else {
        await apiFetch(`/conversations/${id}/draft`, {
          method: "PATCH",
          body: JSON.stringify({ messages: msgs }),
        });
      }
    } catch {}
  }, [id]);

  const debouncedSave = useCallback((msgs: DraftMessage[]) => {
    if (saveTimeout.current) clearTimeout(saveTimeout.current);
    saveTimeout.current = setTimeout(() => persistDraft(msgs), 800);
  }, [persistDraft]);

  const updateMessages = useCallback((next: DraftMessage[]) => {
    setMessages(next);
    setDirty(true);
    debouncedSave(next);
  }, [debouncedSave]);

  const contentHeight = Math.max(5, rows - 10);
  const scroll = useScroll({
    totalItems: messages.length,
    viewportHeight: contentHeight,
    isActive: uiMode === "list",
  });

  const showAction = (msg: string) => {
    setActionMsg(msg);
    setTimeout(() => setActionMsg(""), 2000);
  };

  const toggleSelect = (idx: number) => {
    setSelected((prev) => {
      const next = new Set(prev);
      if (next.has(idx)) next.delete(idx); else next.add(idx);
      return next;
    });
  };

  const handleBulkCompress = () => {
    if (selected.size === 0) return;
    const compressed: DraftMessage = {
      role: "system",
      content: `[Compressed ${selected.size} messages]`,
      collapsed: true,
    };
    const newMsgs: DraftMessage[] = [];
    let inserted = false;
    messages.forEach((msg, i) => {
      if (!selected.has(i)) newMsgs.push(msg);
      else if (!inserted) { newMsgs.push(compressed); inserted = true; }
    });
    updateMessages(newMsgs);
    setSelected(new Set());
  };

  const handleBulkSimplify = async () => {
    if (selected.size === 0) return;
    setUiMode("simplifying");
    try {
      const indices = [...selected];
      const updated = [...messages];
      for (const idx of indices) {
        const msg = updated[idx];
        if (!msg || !msg.content.trim()) continue;
        try {
          const res = await apiFetch<{ data: { content: string } }>("/llm/complete", {
            method: "POST",
            body: JSON.stringify({
              messages: [
                { role: "system", content: "You are an editor. Simplify and distill the following message to its essential content. Remove verbose tool output, redundant explanations, and boilerplate. Preserve key information, decisions, code snippets, and outcomes. Return only the simplified text, no commentary." },
                { role: "user", content: msg.content },
              ],
              maxTokens: 2048,
            }),
          });
          updated[idx] = { ...msg, content: res.data.content };
        } catch {}
      }
      updateMessages(updated);
      setSelected(new Set());
      showAction(`Simplified ${indices.length} messages`);
    } catch {
      showAction("Simplify failed — is LLM configured?");
    }
    setUiMode("list");
  };

  useInput((input, key) => {
    if (uiMode !== "list") {
      if (key.escape && uiMode !== "simplifying") setUiMode("list");
      return;
    }

    if (key.escape) goBack();
    else if (input === " ") toggleSelect(scroll.cursor);
    else if (input === "e") {
      const msg = messages[scroll.cursor];
      if (msg) {
        setEditContent(msg.content);
        setUiMode("editing");
      }
    }
    else if (input === "i") setUiMode("insert-template");
    else if (input === "d") setUiMode("confirm-delete");
    else if (input === "r") setUiMode("role-select");
    else if (input === "s") { persistDraft(messages); showAction("Draft saved"); }
    else if (input === "f") setUiMode("finalize");
    else if (input === "u") setUiMode("confirm-revert");
    else if (input === "A") {
      if (selected.size === messages.length) setSelected(new Set());
      else setSelected(new Set(messages.map((_, i) => i)));
    }
    else if (input === "X") {
      if (selected.size > 0) setUiMode("confirm-bulk-delete");
    }
    else if (input === "K") handleBulkCompress();
    else if (input === "L") handleBulkSimplify();
  }, { isActive: true });

  if (threadLoading || draftLoading) {
    return <Spinner label="Loading..." />;
  }

  return (
    <Box flexDirection="column">
      <Text bold color="cyan">Edit Thread</Text>
      <Text dimColor>
        e:edit i:insert d:delete r:role Space:select A:all s:save f:finalize u:revert
      </Text>
      <Text dimColor>
        X:bulk-delete K:compress L:simplify(LLM)
        {dirty && <Text color="yellow"> [draft auto-saved]</Text>}
        {selected.size > 0 && <Text color="cyan"> [{selected.size} selected]</Text>}
      </Text>
      {actionMsg && <Text color="green">{actionMsg}</Text>}

      {uiMode === "simplifying" && (
        <Box marginY={1}><Spinner label="Simplifying messages with LLM..." /></Box>
      )}

      {uiMode === "editing" && (
        <Box flexDirection="column" marginY={1} borderStyle="single" borderColor="cyan" paddingX={1}>
          <Text bold>Edit message content:</Text>
          <TextInput
            defaultValue={editContent}
            onSubmit={(val) => {
              const updated = [...messages];
              updated[scroll.cursor] = { ...updated[scroll.cursor]!, content: val };
              updateMessages(updated);
              setUiMode("list");
            }}
          />
          <Text dimColor>Enter:save Esc:cancel</Text>
        </Box>
      )}

      {uiMode === "insert-template" && (
        <Box marginY={1} flexDirection="column">
          <Text>Select message type to insert:</Text>
          <Select
            options={TEMPLATE_OPTIONS}
            onChange={(templateId) => {
              setUiMode("inserting");
              setEditContent("");
              const role = TEMPLATE_ROLES[templateId] ?? "user";
              // Store the template type temporarily
              setMessages((prev) => {
                // Will be replaced when content is submitted
                return prev;
              });
              setUiMode("inserting");
            }}
          />
        </Box>
      )}

      {uiMode === "inserting" && (
        <InputModal
          label="Message content:"
          onSubmit={(content) => {
            const newMsg: DraftMessage = { role: "user", content, injected: true };
            const updated = [...messages];
            updated.splice(scroll.cursor + 1, 0, newMsg);
            updateMessages(updated);
            setUiMode("list");
          }}
          onCancel={() => setUiMode("list")}
        />
      )}

      {uiMode === "role-select" && (
        <Box marginY={1}>
          <Text>Role: </Text>
          <Select
            options={ROLE_OPTIONS}
            defaultValue={messages[scroll.cursor]?.role}
            onChange={(v) => {
              const updated = [...messages];
              updated[scroll.cursor] = { ...updated[scroll.cursor]!, role: v as any };
              updateMessages(updated);
              setUiMode("list");
            }}
          />
        </Box>
      )}

      {uiMode === "confirm-delete" && (
        <ConfirmDialog
          message="Delete this message?"
          onConfirm={() => {
            updateMessages(messages.filter((_, i) => i !== scroll.cursor));
            setSelected((prev) => { const n = new Set(prev); n.delete(scroll.cursor); return n; });
            setUiMode("list");
          }}
          onCancel={() => setUiMode("list")}
        />
      )}

      {uiMode === "confirm-bulk-delete" && (
        <ConfirmDialog
          message={`Delete ${selected.size} selected messages?`}
          onConfirm={() => {
            updateMessages(messages.filter((_, i) => !selected.has(i)));
            setSelected(new Set());
            setUiMode("list");
          }}
          onCancel={() => setUiMode("list")}
        />
      )}

      {uiMode === "confirm-revert" && (
        <ConfirmDialog
          message="Revert all edits to original?"
          onConfirm={async () => {
            await apiFetch(`/conversations/${id}/draft`, { method: "DELETE" });
            const initial: DraftMessage[] = originalRecords
              .filter((r) => r.type === "user" || r.type === "assistant")
              .map((r, i) => ({
                originalIndex: i,
                role: r.message.role as any,
                content: extractText(r.message.content),
              }));
            setMessages(initial);
            setDraftId(null);
            draftIdRef.current = null;
            setDirty(false);
            setSelected(new Set());
            showAction("Reverted");
            setUiMode("list");
          }}
          onCancel={() => setUiMode("list")}
        />
      )}

      {uiMode === "finalize" && (
        <InputModal
          label="Version description:"
          onSubmit={async (desc) => {
            if (saveTimeout.current) {
              clearTimeout(saveTimeout.current);
              await persistDraft(messages);
            }
            await apiFetch(`/conversations/${id}/draft/finalize`, {
              method: "POST",
              body: JSON.stringify({ description: desc }),
            });
            showAction("Finalized");
            goBack();
          }}
          onCancel={() => setUiMode("list")}
        />
      )}

      {/* Message list */}
      {uiMode === "list" && (
        <Box flexDirection="column" marginTop={1}>
          <SelectableList
            items={messages}
            cursor={scroll.cursor}
            visibleRange={scroll.visibleRange}
            renderItem={(msg, index, isCursor) => {
              const isSelected = selected.has(index);
              const msgType = detectMessageType(msg.content);
              return (
                <Box>
                  <Text
                    color={isCursor ? "cyan" : undefined}
                    inverse={isCursor}
                  >
                    {isSelected ? "✓ " : "  "}
                    {isCursor ? "▸ " : "  "}
                    <Text color={msg.role === "user" ? "cyan" : msg.role === "system" ? "yellow" : "magenta"} bold>
                      [{msg.role}]
                    </Text>
                    {msg.injected && <Text color="green"> +</Text>}
                    {msg.collapsed && <Text color="yellow"> ⊟</Text>}
                    {msgType && <Text dimColor> ({msgType})</Text>}
                    {" "}{msg.content.slice(0, 70)}{msg.content.length > 70 ? "..." : ""}
                  </Text>
                </Box>
              );
            }}
          />
          <Text dimColor>{messages.length} messages</Text>
        </Box>
      )}
    </Box>
  );
}

function detectMessageType(content: string): string | null {
  if (content.includes("<command-name>")) return "skill";
  if (content.includes("<system-reminder>")) return "sys-remind";
  if (content.startsWith("Base directory for this skill:")) return "skill-def";
  if (content.startsWith("[Tool:")) return "tool";
  if (content.startsWith("<thinking>")) return "thinking";
  return null;
}
