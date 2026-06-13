<script lang="ts">
  import {
    computeDiff,
    computeDiffStats,
    type DiffLine,
    type DiffStats
  } from '$/util/diagram-diff';

  let {
    oldText = '',
    newText = '',
    oldLabel = 'Original',
    newLabel = 'Modified'
  }: {
    oldText?: string;
    newText?: string;
    oldLabel?: string;
    newLabel?: string;
  } = $props();

  let lines: DiffLine[] = $derived(computeDiff(oldText, newText));
  let stats: DiffStats = $derived(computeDiffStats(lines));
</script>

<div
  class="diagram-diff w-full overflow-auto rounded-md border border-border bg-background font-mono text-sm">
  <!-- Stats header -->
  <div
    class="flex items-center gap-4 border-b border-border px-4 py-2 text-xs text-muted-foreground">
    <span class="font-semibold text-foreground">Diff</span>
    <span>{oldLabel} → {newLabel}</span>
    <span class="ml-auto flex items-center gap-3">
      {#if stats.added > 0}
        <span class="text-green-600 dark:text-green-400">+{stats.added}</span>
      {/if}
      {#if stats.removed > 0}
        <span class="text-red-600 dark:text-red-400">-{stats.removed}</span>
      {/if}
      <span>{stats.unchanged} unchanged</span>
    </span>
  </div>

  <!-- Diff lines -->
  <div class="diff-body">
    {#each lines as line, i (i)}
      <div
        class={[
          'diff-line flex',
          line.type === 'added' && 'bg-green-500/10',
          line.type === 'removed' && 'bg-red-500/10'
        ]}>
        <!-- Old line number gutter -->
        <span
          class="inline-block w-12 shrink-0 px-2 py-0.5 text-right text-xs text-muted-foreground/60 select-none">
          {line.oldLineNumber ?? ''}
        </span>
        <!-- New line number gutter -->
        <span
          class="inline-block w-12 shrink-0 border-r border-border/50 px-2 py-0.5 text-right text-xs text-muted-foreground/60 select-none">
          {line.newLineNumber ?? ''}
        </span>
        <!-- Indicator -->
        <span
          class={[
            'inline-block w-6 shrink-0 py-0.5 text-center text-xs font-bold select-none',
            line.type === 'added' && 'text-green-600 dark:text-green-400',
            line.type === 'removed' && 'text-red-600 dark:text-red-400'
          ]}>
          {#if line.type === 'added'}+{:else if line.type === 'removed'}-{:else}&nbsp;{/if}
        </span>
        <!-- Content -->
        <span class="flex-1 py-0.5 pr-4 whitespace-pre">{line.content}</span>
      </div>
    {/each}

    {#if lines.length === 0}
      <div class="px-4 py-6 text-center text-muted-foreground">No differences</div>
    {/if}
  </div>
</div>
