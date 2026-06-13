<script lang="ts">
  import { Button } from '$/components/ui/button';
  import { Input } from '$/components/ui/input';
  import { Separator } from '$/components/ui/separator';
  import SearchIcon from '~icons/material-symbols/search-rounded';
  import SortIcon from '~icons/material-symbols/sort-rounded';
  import GridIcon from '~icons/material-symbols/grid-view-rounded';
  import ListIcon from '~icons/material-symbols/view-list-rounded';
  import StarIcon from '~icons/material-symbols/star-rounded';
  import FolderIcon from '~icons/material-symbols/folder-outline-rounded';

  // ─── Types ──────────────────────────────────────────────────────────────────

  export type ViewMode = 'grid' | 'list';
  export type SortField = 'updatedAt' | 'createdAt' | 'title' | 'starred';
  export type SortDir = 'asc' | 'desc';
  export type VisibilityFilter = 'all' | 'private' | 'unlisted' | 'public';

  interface FolderRef {
    id: string;
    name: string;
  }

  interface Props {
    viewMode: ViewMode;
    sortField: SortField;
    sortDir: SortDir;
    searchQuery: string;
    activeSearch: string;
    visibilityFilter: VisibilityFilter;
    // Mobile folder bar
    showStarredOnly: boolean;
    activeFolderId: string | null;
    mobileFolders: FolderRef[];
    // Callbacks
    onviewchange?: (mode: ViewMode) => void;
    onsortfieldchange?: (field: SortField) => void;
    onsortdirchange?: () => void;
    onsearch?: (query: string) => void;
    onclearsearch?: () => void;
    onvisibilitychange?: (filter: VisibilityFilter) => void;
    // Mobile navigation
    onselectall?: () => void;
    onselectstarred?: () => void;
    onselectfolder?: (id: string) => void;
  }

  let {
    viewMode,
    sortField,
    sortDir,
    searchQuery = $bindable(''),
    activeSearch,
    visibilityFilter,
    showStarredOnly,
    activeFolderId,
    mobileFolders,
    onviewchange,
    onsortfieldchange,
    onsortdirchange,
    onsearch,
    onclearsearch,
    onvisibilitychange,
    onselectall,
    onselectstarred,
    onselectfolder
  }: Props = $props();

  // ─── Sort labels ────────────────────────────────────────────────────────────

  const SORT_LABELS: Record<SortField, string> = {
    updatedAt: 'Last modified',
    createdAt: 'Date created',
    title: 'Name',
    starred: 'Starred first'
  };

  const SORT_FIELDS: SortField[] = ['updatedAt', 'createdAt', 'title', 'starred'];

  function cycleSortField() {
    const idx = SORT_FIELDS.indexOf(sortField);
    onsortfieldchange?.(SORT_FIELDS[(idx + 1) % SORT_FIELDS.length]);
  }

  const VISIBILITY_OPTIONS: { value: VisibilityFilter; label: string }[] = [
    { value: 'all', label: 'All' },
    { value: 'private', label: 'Private' },
    { value: 'unlisted', label: 'Unlisted' },
    { value: 'public', label: 'Public' }
  ];
</script>

<!-- Mobile folder nav (visible on small screens where sidebar is hidden) -->
<div class="flex items-center gap-2 overflow-x-auto border-b border-border px-4 py-2 md:hidden">
  <button
    class="flex-shrink-0 rounded-md px-2 py-1 text-xs font-medium {!activeFolderId &&
    !showStarredOnly
      ? 'bg-accent/10 text-accent'
      : 'text-muted-foreground hover:bg-muted'}"
    onclick={onselectall}>
    All
  </button>
  <button
    class="flex flex-shrink-0 items-center gap-1 rounded-md px-2 py-1 text-xs font-medium {showStarredOnly
      ? 'bg-accent/10 text-accent'
      : 'text-muted-foreground hover:bg-muted'}"
    onclick={onselectstarred}>
    <StarIcon class="size-3 text-yellow-500" /> Starred
  </button>
  {#each mobileFolders as folder (folder.id)}
    <button
      class="flex max-w-24 flex-shrink-0 items-center gap-1 truncate rounded-md px-2 py-1 text-xs font-medium {activeFolderId ===
      folder.id
        ? 'bg-accent/10 text-accent'
        : 'text-muted-foreground hover:bg-muted'}"
      onclick={() => onselectfolder?.(folder.id)}>
      <FolderIcon class="size-3 flex-shrink-0" />
      <span class="truncate">{folder.name}</span>
    </button>
  {/each}
</div>

<!-- Toolbar -->
<div class="flex flex-wrap items-center gap-3 border-b border-border px-4 py-3 sm:px-6">
  <!-- Search -->
  <form
    class="flex flex-1 items-center gap-2"
    onsubmit={(e) => {
      e.preventDefault();
      onsearch?.(searchQuery);
    }}>
    <div class="relative max-w-sm flex-1">
      <SearchIcon class="absolute top-1/2 left-2.5 size-4 -translate-y-1/2 text-muted-foreground" />
      <Input
        type="text"
        bind:value={searchQuery}
        placeholder="Search by title..."
        class="h-9 pl-9 text-sm" />
    </div>
    {#if activeSearch}
      <Button variant="ghost" size="sm" onclick={onclearsearch} class="text-xs">Clear</Button>
    {/if}
  </form>

  <!-- Visibility filter -->
  <div class="flex items-center gap-1">
    {#each VISIBILITY_OPTIONS as opt (opt.value)}
      <button
        class="rounded-md px-2 py-1 text-xs font-medium transition-colors {visibilityFilter ===
        opt.value
          ? 'bg-accent/10 text-accent'
          : 'text-muted-foreground hover:bg-muted'}"
        onclick={() => onvisibilitychange?.(opt.value)}>
        {opt.label}
      </button>
    {/each}
  </div>

  <Separator orientation="vertical" class="h-6" />

  <!-- Sort -->
  <div class="flex items-center gap-1">
    <Button variant="ghost" size="sm" onclick={cycleSortField} class="gap-1 text-xs">
      <SortIcon class="size-4" />
      {SORT_LABELS[sortField]}
    </Button>
    <Button variant="ghost" size="sm" onclick={onsortdirchange} class="px-1.5 text-xs">
      {sortDir === 'desc' ? '↓' : '↑'}
    </Button>
  </div>

  <Separator orientation="vertical" class="h-6" />

  <!-- View toggle -->
  <div class="flex items-center gap-1">
    <button
      class="rounded-md p-1.5 transition-colors {viewMode === 'grid'
        ? 'bg-accent/15 text-accent'
        : 'text-muted-foreground hover:bg-muted hover:text-foreground'}"
      aria-label="Grid view"
      onclick={() => onviewchange?.('grid')}>
      <GridIcon class="size-4" />
    </button>
    <button
      class="rounded-md p-1.5 transition-colors {viewMode === 'list'
        ? 'bg-accent/15 text-accent'
        : 'text-muted-foreground hover:bg-muted hover:text-foreground'}"
      aria-label="List view"
      onclick={() => onviewchange?.('list')}>
      <ListIcon class="size-4" />
    </button>
  </div>
</div>
