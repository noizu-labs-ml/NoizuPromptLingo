<script lang="ts">
  import { ModeWatcher } from 'mode-watcher';
  import type { Snippet } from 'svelte';
  import '../../app.css';

  interface Props {
    children: Snippet;
  }

  let { children }: Props = $props();
</script>

<ModeWatcher />

<div class="flex min-h-dvh items-center justify-center bg-background p-4">
  <div class="w-full max-w-md space-y-6">
    <div class="flex flex-col items-center gap-2">
      <a href="/" class="text-2xl font-bold text-accent no-underline">Mermaid Live Editor</a>
      <p class="text-sm text-muted-foreground">Diagrams, saved and shared</p>
    </div>
    {@render children()}
  </div>
</div>
