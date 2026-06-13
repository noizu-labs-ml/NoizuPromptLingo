<script lang="ts">
  import { Button } from '$/components/ui/button';
  import View from '$/components/View.svelte';
  import { stateStore, updateCodeStore } from '$/util/state';
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import type { PageData } from './$types';
  import type { ForkResponse } from '$lib/types/api';
  import TagIcon from '~icons/material-symbols/label-outline-rounded';
  import FolderIcon from '~icons/material-symbols/folder-outline-rounded';

  let { data }: { data: PageData } = $props();

  let forking = $state(false);
  let submittingPR = $state(false);

  onMount(() => {
    updateCodeStore({
      code: data.diagram.code,
      mermaid: data.diagram.config || '{}',
      updateDiagram: true
    });
  });

  function openInEditor() {
    goto('/edit');
  }

  function copyLink() {
    navigator.clipboard.writeText(window.location.href);
  }

  /** Fork this diagram into the current user's account */
  async function forkDiagram() {
    forking = true;
    try {
      const response = await fetch(`/api/diagrams/${data.diagram.id}/fork`, { method: 'POST' });
      if (!response.ok) throw new Error('Fork failed');
      const body = (await response.json()) as ForkResponse;
      await goto(`/d/${body.fork.id}`);
    } catch (err) {
      console.error('Fork error:', err);
      alert('Failed to fork diagram. Please try again.');
    } finally {
      forking = false;
    }
  }

  /** Submit a PR from this fork back to the source diagram */
  async function submitPullRequest() {
    if (!data.sourceDiagramId) return;
    submittingPR = true;
    try {
      const title = prompt('Pull request title:', `Update from fork`);
      if (!title) {
        submittingPR = false;
        return;
      }
      const description = prompt('Description (optional):') ?? undefined;
      const response = await fetch(`/api/diagrams/${data.sourceDiagramId}/prs`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title, description })
      });
      if (!response.ok) throw new Error('PR submission failed');
      await goto(`/d/${data.sourceDiagramId}/prs`);
    } catch (err) {
      console.error('PR error:', err);
      alert('Failed to submit pull request. Please try again.');
    } finally {
      submittingPR = false;
    }
  }

  const pageTitle = data.diagram.title || 'Untitled Diagram';
  const authorLabel = data.author?.handle
    ? `@${data.author.handle}`
    : data.author?.name || 'Anonymous';

  /** Show Fork button when user is authenticated but is not the owner */
  const canFork = $derived(Boolean(data.userId && !data.isOwner));

  /** Show Submit PR button when this diagram is a fork with a known source */
  const canSubmitPR = $derived(Boolean(data.isFork && data.sourceDiagramId && data.isOwner));
</script>

<svelte:head>
  <title>{pageTitle} — Mermaid Live Editor</title>
  {#if data.diagram.description}
    <meta name="description" content={data.diagram.description} />
  {/if}
</svelte:head>

<div class="flex h-screen flex-col">
  <header class="flex flex-col border-b border-border bg-background">
    <!-- Top bar -->
    <div class="flex items-center gap-3 px-4 py-2">
      <a href="/edit" class="text-sm font-medium text-muted-foreground hover:text-foreground">
        ← Editor
      </a>
      <div class="min-w-0 flex-1">
        <h1 class="truncate text-sm font-semibold">{pageTitle}</h1>
        <p class="text-xs text-muted-foreground">
          by {authorLabel}
          {#if data.diagram.visibility === 'public'}
            · Public
          {:else if data.diagram.visibility === 'unlisted'}
            · Unlisted
          {:else if data.diagram.visibility === 'private'}
            · Private
          {/if}
        </p>
      </div>
      <div class="flex items-center gap-2">
        {#if canFork}
          <Button variant="outline" size="sm" onclick={forkDiagram} disabled={forking}>
            {forking ? 'Forking...' : 'Fork'}
          </Button>
        {/if}
        {#if canSubmitPR}
          <Button variant="outline" size="sm" onclick={submitPullRequest} disabled={submittingPR}>
            {submittingPR ? 'Submitting...' : 'Submit PR'}
          </Button>
        {/if}
        {#if data.isOwner}
          <Button variant="outline" size="sm" onclick={() => goto(`/d/${data.diagram.id}/prs`)}>
            PRs
          </Button>
        {/if}
        <Button variant="outline" size="sm" onclick={copyLink}>Copy link</Button>
        <Button size="sm" onclick={openInEditor}>
          {#if data.isOwner}
            Edit
          {:else}
            Open in Editor
          {/if}
        </Button>
      </div>
    </div>

    <!-- Metadata bar (description, tags, projects) -->
    {#if data.diagram.description || data.diagram.tags.length > 0 || data.projects.length > 0}
      <div
        class="flex flex-wrap items-center gap-3 border-t border-border/50 px-4 py-1.5 text-xs text-muted-foreground">
        {#if data.diagram.description}
          <span class="max-w-md truncate" title={data.diagram.description}>
            {data.diagram.description}
          </span>
        {/if}

        {#if data.diagram.tags.length > 0}
          <div class="flex items-center gap-1">
            <TagIcon class="size-3.5 shrink-0" />
            {#each data.diagram.tags as tag (tag)}
              <span class="rounded-full bg-accent/10 px-1.5 py-0.5 text-accent">{tag}</span>
            {/each}
          </div>
        {/if}

        {#if data.projects.length > 0}
          <div class="flex items-center gap-1">
            <FolderIcon class="size-3.5 shrink-0" />
            {#each data.projects as project (project.id)}
              <span class="flex items-center gap-1">
                {#if project.color}
                  <span
                    class="inline-block size-2 rounded-full"
                    style="background-color: {project.color}"></span>
                {/if}
                {project.name}
              </span>
            {/each}
          </div>
        {/if}
      </div>
    {/if}
  </header>

  <div class="flex-1 overflow-auto bg-background">
    {#if $stateStore.code}
      <View />
    {:else}
      <div class="flex h-full items-center justify-center text-muted-foreground">
        Loading diagram...
      </div>
    {/if}
  </div>
</div>
