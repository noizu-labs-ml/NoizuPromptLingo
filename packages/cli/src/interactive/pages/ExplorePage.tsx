import React, { useState } from "react";
import { Box, Text, useInput } from "ink";
import { TextInput, Spinner, Select } from "@inkjs/ui";
import { useRouter } from "../context/RouterContext.js";
import { useConversations, useSearch, useIndexStatus } from "../hooks/useApi.js";
import { useDebouncedValue } from "../hooks/useDebouncedValue.js";
import { useScroll } from "../hooks/useScroll.js";
import { useTerminalSize } from "../hooks/useTerminalSize.js";
import { SelectableList } from "../components/SelectableList.js";
import { ConversationRow } from "../components/ConversationRow.js";
import { Pagination } from "../components/Pagination.js";

type SortOption = "updated_at" | "started_at" | "message_count" | "title";
type SearchMode = "fts" | "semantic";
type UIMode = "browse" | "search" | "sort";
type PreviewMode = "both" | "first" | "last" | "none";
type GroupMode = "grouped" | "flat";

const SORT_OPTIONS = [
  { label: "Last Updated", value: "updated_at" },
  { label: "Date Started", value: "started_at" },
  { label: "Message Count", value: "message_count" },
  { label: "Title", value: "title" },
];

const PREVIEW_CYCLE: PreviewMode[] = ["both", "first", "last", "none"];

export function ExplorePage() {
  const { navigate } = useRouter();
  const { rows } = useTerminalSize();

  const [uiMode, setUiMode] = useState<UIMode>("browse");
  const [searchInput, setSearchInput] = useState("");
  const [searchMode, setSearchMode] = useState<SearchMode>("fts");
  const [sort, setSort] = useState<SortOption>("updated_at");
  const [page, setPage] = useState(1);
  const [previewMode, setPreviewMode] = useState<PreviewMode>("both");
  const [groupMode, setGroupMode] = useState<GroupMode>("grouped");
  const pageSize = 25;

  const debouncedQuery = useDebouncedValue(searchInput, 300);
  const isSearching = debouncedQuery.trim().length > 0;
  const offset = (page - 1) * pageSize;

  const { data: convData, loading: convLoading } = useConversations({ sort, limit: pageSize, offset });
  const { data: searchData, loading: searchLoading } = useSearch(debouncedQuery, searchMode);
  const { data: idxData } = useIndexStatus();

  const conversations = convData?.data ?? [];
  const searchResults = searchData?.data ?? [];
  const totalConvos = convData?.meta?.total ?? 0;
  const indexStatus = idxData?.data;

  const totalFiltered = isSearching ? searchResults.length : totalConvos;
  const totalPages = Math.max(1, Math.ceil(totalFiltered / pageSize));
  const safePage = Math.min(page, totalPages);
  const pageItemCount = isSearching ? searchResults.length : conversations.length;

  const contentHeight = Math.max(5, rows - 10);
  const scroll = useScroll({
    totalItems: pageItemCount,
    viewportHeight: contentHeight,
    isActive: uiMode === "browse",
  });

  useInput((input, key) => {
    if (uiMode === "sort") {
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
    } else if (input === "v") {
      setPreviewMode((m) => {
        const idx = PREVIEW_CYCLE.indexOf(m);
        return PREVIEW_CYCLE[(idx + 1) % PREVIEW_CYCLE.length];
      });
    } else if (input === "g" && !isSearching) {
      setGroupMode((m) => m === "grouped" ? "flat" : "grouped");
    } else if (input === "n" && !isSearching) {
      setPage((p) => Math.min(totalPages, p + 1));
    } else if (input === "p" && !isSearching) {
      setPage((p) => Math.max(1, p - 1));
    } else if (key.return) {
      const items: any[] = isSearching ? searchResults : conversations;
      const item = items[scroll.cursor];
      if (item) {
        const id = isSearching ? (item as any).conversation.id : (item as any).id;
        navigate("thread", { id });
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
            {searchInput ? `⌕ "${searchInput}" [${searchMode}]` : "/:search"} | o:sort | v:preview({previewMode}) | g:{groupMode}{isSearching ? "" : " | n/p:page"}
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

      {/* Results */}
      {loading && <Spinner label="Loading..." />}

      {!loading && pageItemCount === 0 && (
        <Text dimColor>
          {isSearching
            ? `No results for "${debouncedQuery}".`
            : "No conversations indexed. Run claude-assist index to get started."}
        </Text>
      )}

      {!loading && isSearching && searchResults.length > 0 && (
        <SelectableList
          items={searchResults}
          cursor={scroll.cursor}
          visibleRange={scroll.visibleRange}
          renderItem={(item, _index, isCursor) => (
            <ConversationRow
              id={item.conversation.id}
              title={item.conversation.title}
              projectPath={item.conversation.projectPath}
              messageCount={item.conversation.messageCount}
              updatedAt={item.conversation.updatedAt}
              snippet={item.snippet}
              isCursor={isCursor}
            />
          )}
        />
      )}

      {!loading && !isSearching && conversations.length > 0 && (
        <SelectableList
          items={conversations}
          cursor={scroll.cursor}
          visibleRange={scroll.visibleRange}
          renderItem={(item, _index, isCursor) => (
            <ConversationRow
              id={item.id}
              title={item.title}
              projectPath={item.projectPath}
              messageCount={item.messageCount}
              updatedAt={item.updatedAt}
              status={item.status}
              firstMessage={item.firstMessage}
              lastMessage={item.lastMessage}
              previewMode={previewMode}
              isCursor={isCursor}
            />
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
