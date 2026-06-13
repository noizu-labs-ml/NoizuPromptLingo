<script lang="ts">
  import { Button } from '$/components/ui/button';
  import { goto } from '$app/navigation';
  import type { PageData } from './$types';

  let { data }: { data: PageData } = $props();

  const diagramTitle = data.diagram.title || 'Untitled Diagram';

  function statusBadgeClass(status: string): string {
    switch (status) {
      case 'open':
        return 'bg-green-500/15 text-green-700 dark:text-green-400';
      case 'merged':
        return 'bg-purple-500/15 text-purple-700 dark:text-purple-400';
      case 'closed':
        return 'bg-red-500/15 text-red-700 dark:text-red-400';
      default:
        return 'bg-muted text-muted-foreground';
    }
  }

  function formatDate(iso: string): string {
    return new Date(iso).toLocaleDateString(undefined, {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  }
</script>

<svelte:head>
  <title>Pull Requests — {diagramTitle} — Mermaid Live Editor</title>
</svelte:head>

<div class="mx-auto max-w-3xl px-4 py-8">
  <div class="mb-6 flex items-center justify-between">
    <div>
      <h1 class="text-lg font-semibold">Pull Requests</h1>
      <p class="text-sm text-muted-foreground">
        <button class="hover:underline" onclick={() => goto(`/d/${data.diagram.id}`)}>
          {diagramTitle}
        </button>
      </p>
    </div>
    <Button variant="outline" size="sm" onclick={() => goto(`/d/${data.diagram.id}`)}>
      Back to diagram
    </Button>
  </div>

  {#if data.pullRequests.length === 0}
    <div class="rounded-md border border-border p-8 text-center text-muted-foreground">
      No pull requests yet.
    </div>
  {:else}
    <div class="divide-y divide-border rounded-md border border-border">
      {#each data.pullRequests as pr (pr.id)}
        <button
          class="flex w-full items-center gap-3 px-4 py-3 text-left transition-colors hover:bg-accent/5"
          onclick={() => goto(`/d/${data.diagram.id}/prs/${pr.id}`)}>
          <span
            class={[
              'inline-block rounded-full px-2 py-0.5 text-xs font-medium',
              statusBadgeClass(pr.status)
            ]}>
            {pr.status}
          </span>
          <div class="min-w-0 flex-1">
            <p class="truncate text-sm font-medium">{pr.title}</p>
            <p class="text-xs text-muted-foreground">
              by {pr.authorHandle ? `@${pr.authorHandle}` : pr.authorName || 'Unknown'}
              · {formatDate(pr.createdAt)}
            </p>
          </div>
        </button>
      {/each}
    </div>
  {/if}
</div>
