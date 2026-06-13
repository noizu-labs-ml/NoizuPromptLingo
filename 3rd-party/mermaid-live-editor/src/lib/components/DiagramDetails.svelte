<script lang="ts">
  import { Button } from '$/components/ui/button';
  import { Input } from '$/components/ui/input';
  import { toast } from 'svelte-sonner';
  import SaveIcon from '~icons/material-symbols/save-outline-rounded';
  import LockIcon from '~icons/material-symbols/lock-outline';
  import LinkIcon from '~icons/material-symbols/link-rounded';
  import PublicIcon from '~icons/material-symbols/public';

  interface DiagramMeta {
    id: string;
    title: string | null;
    description: string | null;
    tags: string[];
    visibility: string;
  }

  interface Project {
    id: string;
    name: string;
    color: string | null;
  }

  interface Props {
    diagram: DiagramMeta;
    projects?: Project[];
    onupdate?: (updated: DiagramMeta) => void;
  }

  let { diagram, projects = [], onupdate }: Props = $props();

  // ─── Local editable state ──────────────────────────────────────────────────

  let title = $state(diagram.title ?? '');
  let description = $state(diagram.description ?? '');
  let tagInput = $state(diagram.tags.join(', '));
  let visibility = $state(diagram.visibility);
  let selectedProjectId: string | null = $state(null);
  let saving = $state(false);
  let dirty = $state(false);

  let parsedTags = $derived(
    tagInput
      .split(',')
      .map((t) => t.trim().toLowerCase())
      .filter((t) => t.length > 0)
      .slice(0, 20)
  );

  // Track changes
  $effect(() => {
    const titleChanged = (title.trim() || null) !== (diagram.title || null);
    const descChanged = (description.trim() || null) !== (diagram.description || null);
    const tagsChanged = JSON.stringify(parsedTags) !== JSON.stringify(diagram.tags);
    const visChanged = visibility !== diagram.visibility;
    dirty = titleChanged || descChanged || tagsChanged || visChanged;
  });

  function removeTag(tag: string) {
    const tags = parsedTags.filter((t) => t !== tag);
    tagInput = tags.join(', ');
  }

  async function save() {
    saving = true;

    try {
      const body: Record<string, unknown> = {};

      if ((title.trim() || null) !== (diagram.title || null)) {
        body.title = title.trim() || null;
      }
      if ((description.trim() || null) !== (diagram.description || null)) {
        body.description = description.trim() || null;
      }
      if (JSON.stringify(parsedTags) !== JSON.stringify(diagram.tags)) {
        body.tags = parsedTags;
      }
      if (visibility !== diagram.visibility) {
        body.visibility = visibility;
      }

      if (Object.keys(body).length === 0) {
        toast.info('No changes to save');
        return;
      }

      const response = await fetch(`/api/diagrams/${diagram.id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body)
      });

      if (!response.ok) {
        const data = await response.json().catch(() => ({}));
        toast.error(data.message ?? 'Failed to update diagram');
        return;
      }

      const updated = await response.json();

      // Sync local state with response
      diagram.title = updated.title ?? null;
      diagram.description = updated.description ?? null;
      diagram.tags = Array.isArray(updated.tags) ? updated.tags : [];
      diagram.visibility = updated.visibility;

      dirty = false;
      toast.success('Details saved');
      onupdate?.(diagram);
    } catch {
      toast.error('Something went wrong. Please try again.');
    } finally {
      saving = false;
    }
  }
</script>

<div class="flex flex-col gap-4 p-4">
  <!-- Title -->
  <div class="flex flex-col gap-1.5">
    <label for="details-title" class="text-xs font-medium text-muted-foreground">Title</label>
    <Input
      id="details-title"
      type="text"
      placeholder="Untitled Diagram"
      bind:value={title}
      maxlength={200} />
  </div>

  <!-- Description -->
  <div class="flex flex-col gap-1.5">
    <label for="details-desc" class="text-xs font-medium text-muted-foreground">Description</label>
    <textarea
      id="details-desc"
      class="flex min-h-[72px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none"
      placeholder="What this diagram shows..."
      bind:value={description}
      maxlength={2000}></textarea>
  </div>

  <!-- Tags -->
  <div class="flex flex-col gap-1.5">
    <label for="details-tags" class="text-xs font-medium text-muted-foreground">Tags</label>
    <Input
      id="details-tags"
      type="text"
      placeholder="architecture, backend, api (comma-separated)"
      bind:value={tagInput}
      maxlength={500} />
    {#if parsedTags.length > 0}
      <div class="flex flex-wrap gap-1">
        {#each parsedTags as tag (tag)}
          <span
            class="inline-flex items-center rounded-full bg-accent/10 px-2 py-0.5 text-xs text-accent">
            {tag}
            <button
              type="button"
              class="ml-1 text-accent/70 hover:text-accent"
              onclick={() => removeTag(tag)}>x</button>
          </span>
        {/each}
      </div>
    {/if}
  </div>

  <!-- Visibility -->
  <div class="flex flex-col gap-1.5">
    <span class="text-xs font-medium text-muted-foreground">Visibility</span>
    <div class="flex gap-2">
      {#each [{ value: 'private', label: 'Private', sublabel: 'Only you', icon: LockIcon }, { value: 'unlisted', label: 'Unlisted', sublabel: 'Anyone with link', icon: LinkIcon }, { value: 'public', label: 'Public', sublabel: 'Everyone', icon: PublicIcon }] as opt (opt.value)}
        <button
          type="button"
          class="flex flex-1 flex-col items-center gap-0.5 rounded-md border px-2 py-2 text-xs transition-colors {visibility ===
          opt.value
            ? 'border-accent bg-accent/10 text-accent'
            : 'border-border text-muted-foreground hover:border-accent/50'}"
          onclick={() => (visibility = opt.value)}>
          <opt.icon class="size-4" />
          <span class="font-medium">{opt.label}</span>
          <span class="opacity-70">{opt.sublabel}</span>
        </button>
      {/each}
    </div>
  </div>

  <!-- Project selector -->
  {#if projects.length > 0}
    <div class="flex flex-col gap-1.5">
      <label for="details-project" class="text-xs font-medium text-muted-foreground">Project</label>
      <select
        id="details-project"
        class="flex h-9 w-full rounded-md border border-input bg-background px-3 py-1 text-sm shadow-sm transition-colors focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none"
        bind:value={selectedProjectId}>
        <option value={null}>None</option>
        {#each projects as project (project.id)}
          <option value={project.id}>
            {project.name}
          </option>
        {/each}
      </select>
    </div>
  {/if}

  <!-- Save button -->
  <Button class="w-full" onclick={save} disabled={saving || !dirty}>
    <SaveIcon class="mr-1 size-4" />
    {#if saving}
      Saving...
    {:else}
      Save details
    {/if}
  </Button>
</div>
