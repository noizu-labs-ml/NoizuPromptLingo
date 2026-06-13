<script lang="ts">
  import DiagramCard from '$/components/DiagramCard.svelte';
  import { Button } from '$/components/ui/button';
  import AddIcon from '~icons/material-symbols/add-rounded';
  import type { DiagramSummary, FolderSummary } from '$/components/DiagramCard.svelte';

  // ─── Props ──────────────────────────────────────────────────────────────────

  interface Props {
    diagrams: DiagramSummary[];
    folders: FolderSummary[];
    viewMode: 'grid' | 'list';
    loading: boolean;
    hasMore: boolean;
    showStarredOnly: boolean;
    activeSearch: string;
    activeFolderName: string | null;
    // Callbacks
    onstar?: (diagram: DiagramSummary) => void;
    ondelete?: (id: string) => void;
    onmove?: (diagramId: string, folderId: string | null) => void;
    onloadmore?: () => void;
  }

  let {
    diagrams,
    folders,
    viewMode,
    loading,
    hasMore,
    showStarredOnly,
    activeSearch,
    activeFolderName,
    onstar,
    ondelete,
    onmove,
    onloadmore
  }: Props = $props();
</script>

<!-- Header -->
<div class="flex items-center gap-2 px-4 pt-4 sm:px-6">
  <h1 class="text-lg font-semibold">
    {#if showStarredOnly}
      Starred Diagrams
    {:else if activeFolderName}
      {activeFolderName}
    {:else if activeSearch}
      Search: "{activeSearch}"
    {:else}
      All Diagrams
    {/if}
  </h1>
  {#if !loading}
    <span class="text-sm text-muted-foreground">
      ({diagrams.length}{hasMore ? '+' : ''})
    </span>
  {/if}
</div>

<!-- Content -->
{#if loading && diagrams.length === 0}
  <div class="flex flex-1 items-center justify-center">
    <div class="text-muted-foreground">Loading...</div>
  </div>
{:else if diagrams.length === 0}
  <div class="flex flex-1 flex-col items-center justify-center gap-4 p-8 text-center">
    <div class="text-4xl">
      {#if showStarredOnly}
        ⭐
      {:else if activeSearch}
        🔍
      {:else}
        📝
      {/if}
    </div>
    <div class="text-muted-foreground">
      {#if showStarredOnly}
        No starred diagrams yet. Star a diagram to find it quickly.
      {:else if activeSearch}
        No diagrams match "{activeSearch}".
      {:else}
        No diagrams yet.
      {/if}
    </div>
    {#if !activeSearch}
      <Button onclick={() => (window.location.href = '/edit')}>
        <AddIcon class="mr-1 size-4" />
        Create your first diagram
      </Button>
    {/if}
  </div>
{:else if viewMode === 'grid'}
  <!-- Grid view -->
  <div class="grid grid-cols-1 gap-4 p-4 sm:grid-cols-2 sm:px-6 lg:grid-cols-3 xl:grid-cols-4">
    {#each diagrams as diagram (diagram.id)}
      <DiagramCard {diagram} mode="grid" {folders} {onstar} {ondelete} {onmove} />
    {/each}
  </div>
{:else}
  <!-- List view -->
  <div class="flex flex-col divide-y divide-border px-4 sm:px-6">
    {#each diagrams as diagram (diagram.id)}
      <DiagramCard {diagram} mode="list" {folders} {onstar} {ondelete} {onmove} />
    {/each}
  </div>
{/if}

<!-- Load more -->
{#if hasMore && !loading}
  <div class="flex justify-center p-6">
    <Button variant="outline" onclick={onloadmore}>Load more</Button>
  </div>
{/if}

{#if loading && diagrams.length > 0}
  <div class="flex justify-center p-4">
    <span class="text-sm text-muted-foreground">Loading...</span>
  </div>
{/if}
