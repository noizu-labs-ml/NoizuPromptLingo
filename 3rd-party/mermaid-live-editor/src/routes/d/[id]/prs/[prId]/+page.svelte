<script lang="ts">
  import { Button } from '$/components/ui/button';
  import DiagramDiff from '$/components/DiagramDiff.svelte';
  import { goto } from '$app/navigation';
  import type { PageData } from './$types';
  import type { PRUpdateBody } from '$lib/types/api';

  let { data }: { data: PageData } = $props();

  let updating = $state(false);

  const pr = data.pullRequest;
  const authorLabel = pr.authorHandle ? `@${pr.authorHandle}` : pr.authorName || 'Unknown';

  function formatDate(iso: string): string {
    return new Date(iso).toLocaleDateString(undefined, {
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      month: 'short',
      year: 'numeric'
    });
  }

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

  async function updatePR(newStatus: 'merged' | 'closed') {
    updating = true;
    try {
      const body: PRUpdateBody = { status: newStatus };
      const response = await fetch(`/api/diagrams/${data.diagram.id}/prs/${pr.id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body)
      });
      if (!response.ok) throw new Error(`Failed to ${newStatus} PR`);
      // Reload page to reflect new status
      window.location.reload();
    } catch (err) {
      console.error(`PR ${newStatus} error:`, err);
      alert(`Failed to ${newStatus} pull request. Please try again.`);
    } finally {
      updating = false;
    }
  }
</script>

<svelte:head>
  <title>{pr.title} — Pull Request — Mermaid Live Editor</title>
</svelte:head>

<div class="mx-auto max-w-4xl px-4 py-8">
  <!-- Navigation breadcrumb -->
  <div class="mb-4 flex items-center gap-2 text-sm text-muted-foreground">
    <button class="hover:underline" onclick={() => goto(`/d/${data.diagram.id}`)}>
      {data.diagram.title || 'Untitled Diagram'}
    </button>
    <span>/</span>
    <button class="hover:underline" onclick={() => goto(`/d/${data.diagram.id}/prs`)}>
      Pull Requests
    </button>
    <span>/</span>
    <span class="text-foreground">{pr.title}</span>
  </div>

  <!-- PR header -->
  <div class="mb-6 rounded-md border border-border p-4">
    <div class="flex items-start justify-between gap-4">
      <div>
        <h1 class="text-lg font-semibold">{pr.title}</h1>
        <div class="mt-1 flex items-center gap-2 text-sm text-muted-foreground">
          <span
            class={[
              'inline-block rounded-full px-2 py-0.5 text-xs font-medium',
              statusBadgeClass(pr.status)
            ]}>
            {pr.status}
          </span>
          <span>by {authorLabel}</span>
          <span>· opened {formatDate(pr.createdAt)}</span>
          {#if pr.closedAt}
            <span>· closed {formatDate(pr.closedAt)}</span>
          {/if}
        </div>
        {#if pr.description}
          <p class="mt-3 text-sm text-muted-foreground">{pr.description}</p>
        {/if}
      </div>

      <!-- Actions (only when PR is open) -->
      {#if pr.status === 'open'}
        <div class="flex shrink-0 items-center gap-2">
          <Button
            variant="outline"
            size="sm"
            onclick={() => updatePR('closed')}
            disabled={updating}>
            {updating ? 'Updating...' : 'Close'}
          </Button>
          <Button size="sm" onclick={() => updatePR('merged')} disabled={updating}>
            {updating ? 'Updating...' : 'Merge'}
          </Button>
        </div>
      {/if}
    </div>
  </div>

  <!-- Diff view -->
  <DiagramDiff
    oldText={data.targetCode}
    newText={data.sourceCode}
    oldLabel="Current"
    newLabel="Proposed" />
</div>
