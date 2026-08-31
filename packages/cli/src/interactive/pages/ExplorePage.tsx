import React, { useEffect, useMemo, useState } from "react";
import { Box, Text, useInput } from "ink";
import { TextInput, Spinner, Select } from "@inkjs/ui";
import { useRouter } from "../context/RouterContext.js";
import { useHarness } from "../context/HarnessContext.js";
import { useConversations, useSearch, useIndexStatus } from "../hooks/useApi.js";
import { useDebouncedValue } from "../hooks/useDebouncedValue.js";
import { useScroll } from "../hooks/useScroll.js";
import { useTerminalSize } from "../hooks/useTerminalSize.js";
import { SelectableList } from "../components/SelectableList.js";
import { ConversationRow } from "../components/ConversationRow.js";
import { Pagination } from "../components/Pagination.js";

type SortOption = "updated_at" | "started_at" | "message_count" | "title";
type SearchMode = "fts" | "semantic";
type UIMode = "browse" | "search" | "sort" | "include-tags" | "exclude-tags" | "page-size";
type PreviewMode = "both" | "first" | "last" | "none";
type GroupMode = "grouped" | "flat";

interface ConversationItem {
  id: string;
  harness?: string;
  title: string;
  projectPath: string;
  messageCount: number;
  startedAt: string;
  updatedAt: string;
  status: string;
  tags?: string[];
  firstMessage?: string;
  lastMessage?: string;
}

type BrowseDisplayItem =
  | { type: "group"; projectPath: string; count: number }
  | { type: "conversation"; conversation: ConversationItem };

const SORT_OPTIONS = [
  { label: "Last Updated", value: "updated_at" },
  { label: "Date Started", value: "started_at" },
  { label: "Message Count", value: "message_count" },
  { label: "Title", value: "title" },
];

const PREVIEW_CYCLE: PreviewMode[] = ["both", "first", "last", "none"];
const PAGE_SIZE_OPTIONS = [25, 50, 100];

function parseTagInput(raw: string): string[] {
  return raw.split(",").map((tag) => tag.trim().toLowerCase()).filter(Boolean);
}

// ⟦𓊜𓂛𓃽𓃂⟧ ExplorePage :: auto-generated pointer for public function ExplorePage
export function ExplorePage() {
  const { navigate } = useRouter();
  const { harness } = useHarness();
  const { rows } = useTerminalSize();

  const [uiMode, setUiMode] = useState<UIMode>("browse");
  const [searchInput, setSearchInput] = useState("");
  const [searchMode, setSearchMode] = useState<SearchMode>("fts");
  const [sort, setSort] = useState<SortOption>("updated_at");
  const [page, setPage] = useState(1);
  const [previewMode, setPreviewMode] = useState<PreviewMode>("both");
  const [groupMode, setGroupMode] = useState<GroupMode>("flat");
  const [includeTags, setIncludeTags] = useState("");
  const [excludeTags, setExcludeTags] = useState("");
  const [pageSize, setPageSize] = useState(25);

  const debouncedQuery = useDebouncedValue(searchInput, 300);
  const isSearching = debouncedQuery.trim().length > 0;
  const offset = (page - 1) * pageSize;

  useEffect(() => {
    setPage(1);
  }, [harness]);

  const { data: convData, loading: convLoading } = useConversations({ sort, limit: pageSize, offset, harness });
  const { data: searchData, loading: searchLoading } = useSearch(debouncedQuery, searchMode, { harness });
  const { data: idxData } = useIndexStatus();

  const conversations = (convData?.data ?? []) as ConversationItem[];
  const searchResults = searchData?.data ?? [];
  const totalConvos = convData?.meta?.total ?? 0;
  const indexStatus = idxData?.data;

  const includeList = parseTagInput(includeTags);
  const excludeList = parseTagInput(excludeTags);

  const filterByTags = <T,>(items: T[], getTags: (item: T) => string[] | undefined): T[] => {
    if (includeList.length === 0 && excludeList.length === 0) return items;
    return items.filter((item) => {
      const tags = (getTags(item) ?? []).map((tag) => tag.toLowerCase());
      if (includeList.length > 0 && !includeList.every((tag) => tags.includes(tag))) return false;
      if (excludeList.length > 0 && excludeList.some((tag) => tags.includes(tag))) return false;
      return true;
    });
  };

  const filteredConversations = useMemo(
    () => filterByTags(conversations, (item) => item.tags),
    [conversations, includeTags, excludeTags],
  );

  const filteredSearchResults = useMemo(
    () => filterByTags(searchResults, (item) => item.conversation.tags),
    [searchResults, includeTags, excludeTags],
  );

  const totalFiltered = isSearching
    ? filteredSearchResults.length
    : (includeList.length > 0 || excludeList.length > 0) ? filteredConversations.length : totalConvos;
  const totalPages = Math.max(1, Math.ceil(totalFiltered / pageSize));
  const safePage = Math.min(page, totalPages);
  const paginatedSearchResults = isSearching
    ? filteredSearchResults.slice((safePage - 1) * pageSize, safePage * pageSize)
    : [];

  const browseItems = useMemo<BrowseDisplayItem[]>(() => {
    if (groupMode === "flat") {
      return filteredConversations.map((conversation) => ({ type: "conversation", conversation }));
    }

    const groups = new Map<string, ConversationItem[]>();
    for (const conversation of filteredConversations) {
      const key = conversation.projectPath;
      if (!groups.has(key)) groups.set(key, []);
      groups.get(key)!.push(conversation);
    }

    const items: BrowseDisplayItem[] = [];
    for (const [projectPath, groupConversations] of groups) {
      items.push({ type: "group", projectPath, count: groupConversations.length });
      items.push(...groupConversations.map((conversation) => ({ type: "conversation" as const, conversation })));
    }
    return items;
  }, [filteredConversations, groupMode]);

  const pageItemCount = isSearching ? paginatedSearchResults.length : browseItems.length;

  const contentHeight = Math.max(5, rows - 10);
  const scroll = useScroll({
    totalItems: pageItemCount,
    viewportHeight: contentHeight,
    isActive: uiMode === "browse",
  });

  useInput((input, key) => {
    if (uiMode === "sort" || uiMode === "page-size") {
      if (key.escape) setUiMode("browse");
      return;
    }

    if (uiMode === "include-tags" || uiMode === "exclude-tags") {
      if (key.escape) setUiMode("browse");
      return;
    }

    if (uiMode === "search") {
      if (key.escape) {
        setUiMode("browse");
        if (!searchInput) setSearchInput("");
      }
      if (input === "\t") {
        setSearchMode((m) => m === "fts" ? "semantic" : "fts");
      }
      return;
    }

    if (input === "/" || input === "s") {
      setUiMode("search");
    } else if (input === "o") {
      setUiMode("sort");
    } else if (input === "z") {
      setUiMode("page-size");
    } else if (input === "i") {
      setUiMode("include-tags");
    } else if (input === "I") {
      setUiMode("exclude-tags");
    } else if (input === "x") {
      setSearchInput("");
      setIncludeTags("");
      setExcludeTags("");
      setPage(1);
    } else if (input === "v") {
      setPreviewMode((m) => {
        const idx = PREVIEW_CYCLE.indexOf(m);
        return PREVIEW_CYCLE[(idx + 1) % PREVIEW_CYCLE.length];
      });
    } else if (input === "g" && !isSearching) {
      setGroupMode((m) => m === "grouped" ? "flat" : "grouped");
    } else if (input === "n") {
      setPage((p) => Math.min(totalPages, p + 1));
    } else if (input === "p") {
      setPage((p) => Math.max(1, p - 1));
    } else if (key.return) {
      if (isSearching) {
        const item = paginatedSearchResults[scroll.cursor];
        if (item) navigate("thread", { id: item.conversation.id });
      } else {
        const item = browseItems[scroll.cursor];
        if (item?.type === "conversation") {
          navigate("thread", { id: item.conversation.id });
        } else if (item?.type === "group") {
          navigate("project-detail", { path: item.projectPath });
        }
      }
    }
  }, { isActive: true });

  const loading = isSearching ? searchLoading : convLoading;
  const lastIndexed = indexStatus?.lastIndexed
    ? new Date(indexStatus.lastIndexed).toLocaleString()
    : "Never";

  return (
    <Box flexDirection="column">
      {/* Search bar */}
      <Box marginBottom={1}>
        {uiMode === "search" ? (
          <Box>
            <Text color="cyan">⌕ </Text>
            <TextInput
              placeholder="Search conversations..."
              onChange={setSearchInput}
              onSubmit={() => setUiMode("browse")}
            />
            <Text dimColor> [{searchMode}]</Text>
            <Text dimColor> Tab:toggle mode</Text>
          </Box>
        ) : (
          <Text dimColor>
            {searchInput ? `⌕ "${searchInput}" [${searchMode}]` : "/:search"} | o:sort | z:size({pageSize}) | i/I:tags | v:preview({previewMode}) | g:{groupMode} | n/p:page | x:clear
          </Text>
        )}
      </Box>

      {/* Stats row */}
      <Box gap={2} marginBottom={1}>
        <Box borderStyle="single" borderColor="gray" paddingX={1}>
          <Text>
            <Text bold>{totalConvos}</Text>
            <Text dimColor> conversations</Text>
          </Text>
        </Box>
        <Box borderStyle="single" borderColor="gray" paddingX={1}>
          <Text>
            <Text bold>{indexStatus?.conversationCount ?? 0}</Text>
            <Text dimColor> indexed</Text>
          </Text>
        </Box>
        <Box borderStyle="single" borderColor="gray" paddingX={1}>
          <Text>
            <Text bold color="cyan">{harness}</Text>
            <Text dimColor> harness</Text>
          </Text>
        </Box>
        <Box borderStyle="single" borderColor="gray" paddingX={1}>
          <Text dimColor>Last: {lastIndexed}</Text>
        </Box>
      </Box>

      {/* Sort overlay */}
      {uiMode === "sort" && (
        <Box marginBottom={1}>
          <Text color="cyan">Sort by: </Text>
          <Select
            options={SORT_OPTIONS}
            defaultValue={sort}
            onChange={(v) => {
              setSort(v as SortOption);
              setPage(1);
              setUiMode("browse");
            }}
          />
        </Box>
      )}

      {uiMode === "page-size" && (
        <Box marginBottom={1}>
          <Text color="cyan">Page size: </Text>
          <Select
            options={PAGE_SIZE_OPTIONS.map((value) => ({ label: String(value), value: String(value) }))}
            defaultValue={String(pageSize)}
            onChange={(value) => {
              setPageSize(Number(value));
              setPage(1);
              setUiMode("browse");
            }}
          />
        </Box>
      )}

      {uiMode === "include-tags" && (
        <Box marginBottom={1}>
          <Text color="cyan">Include tags: </Text>
          <TextInput
            defaultValue={includeTags}
            placeholder="tags, comma-separated"
            onSubmit={(value) => {
              setIncludeTags(value);
              setPage(1);
              setUiMode("browse");
            }}
          />
        </Box>
      )}

      {uiMode === "exclude-tags" && (
        <Box marginBottom={1}>
          <Text color="cyan">Exclude tags: </Text>
          <TextInput
            defaultValue={excludeTags}
            placeholder="tags, comma-separated"
            onSubmit={(value) => {
              setExcludeTags(value);
              setPage(1);
              setUiMode("browse");
            }}
          />
        </Box>
      )}

      {(includeTags || excludeTags) && (
        <Text dimColor>
          Tags: {includeTags ? `include=${includeTags}` : ""}
          {includeTags && excludeTags ? " | " : ""}
          {excludeTags ? `exclude=${excludeTags}` : ""}
        </Text>
      )}

      {/* Results */}
      {loading && <Spinner label="Loading..." />}

      {!loading && pageItemCount === 0 && (
        <Text dimColor>
          {isSearching
            ? `No results for "${debouncedQuery}".`
            : includeTags || excludeTags
              ? "No conversations match the tag filters."
              : "No conversations indexed. Run llm-toolkit index to get started."}
        </Text>
      )}

      {!loading && isSearching && paginatedSearchResults.length > 0 && (
        <SelectableList
          items={paginatedSearchResults}
          cursor={scroll.cursor}
          visibleRange={scroll.visibleRange}
          renderItem={(item, _index, isCursor) => (
            <ConversationRow
              id={item.conversation.id}
              harness={item.conversation.harness}
              title={item.conversation.title}
              projectPath={item.conversation.projectPath}
              messageCount={item.conversation.messageCount}
              startedAt={(item.conversation as Partial<ConversationItem>).startedAt}
              updatedAt={item.conversation.updatedAt}
              snippet={item.snippet}
              isCursor={isCursor}
            />
          )}
        />
      )}

      {!loading && !isSearching && browseItems.length > 0 && (
        <SelectableList
          items={browseItems}
          cursor={scroll.cursor}
          visibleRange={scroll.visibleRange}
          renderItem={(item, _index, isCursor) => (
            item.type === "group" ? (
              <Box flexDirection="column" borderStyle={isCursor ? "single" : undefined} borderColor={isCursor ? "cyan" : undefined} paddingX={isCursor ? 1 : 0}>
                <Text color={isCursor ? "white" : "cyan"} bold>
                  {isCursor ? "✓ " : "  "}Project {shortProject(item.projectPath)} <Text dimColor={!isCursor}>({item.count})</Text>
                </Text>
              </Box>
            ) : (
              <ConversationRow
                id={item.conversation.id}
                harness={item.conversation.harness}
                title={item.conversation.title}
                projectPath={item.conversation.projectPath}
                messageCount={item.conversation.messageCount}
                startedAt={item.conversation.startedAt}
                updatedAt={item.conversation.updatedAt}
                status={item.conversation.status}
                firstMessage={item.conversation.firstMessage}
                lastMessage={item.conversation.lastMessage}
                previewMode={previewMode}
                isCursor={isCursor}
              />
            )
          )}
        />
      )}

      {/* Pagination */}
      {!isSearching && (
        <Box marginTop={1}>
          <Pagination page={safePage} totalPages={totalPages} totalItems={totalFiltered} />
        </Box>
      )}
    </Box>
  );
}

function shortProject(path: string): string {
  const parts = path.split("/").filter(Boolean);
  return parts.length > 2 ? parts.slice(-2).join("/") : path;
}
