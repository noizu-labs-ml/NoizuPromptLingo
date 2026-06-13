<script lang="ts">
  import { Input } from '$/components/ui/input';
  import { Separator } from '$/components/ui/separator';
  import { toast } from 'svelte-sonner';
  import StarIcon from '~icons/material-symbols/star-rounded';
  import StarOutlineIcon from '~icons/material-symbols/star-outline-rounded';
  import FolderIcon from '~icons/material-symbols/folder-outline-rounded';
  import EditIcon from '~icons/material-symbols/edit-outline-rounded';
  import DeleteIcon from '~icons/material-symbols/delete-outline-rounded';
  import MoreIcon from '~icons/material-symbols/more-vert';
  import DetailsIcon from '~icons/material-symbols/tune-rounded';
  import LockIcon from '~icons/material-symbols/lock-outline';
  import LinkIcon from '~icons/material-symbols/link-rounded';
  import PublicIcon from '~icons/material-symbols/public';

  // ─── Types ──────────────────────────────────────────────────────────────────

  export interface DiagramSummary {
    id: string;
    userId: string | null;
    title: string | null;
    description?: string | null;
    tags?: string[];
    visibility: string;
    starred: boolean;
    folderId: string | null;
    createdAt: string;
    updatedAt: string;
  }

  export interface FolderSummary {
    id: string;
    name: string;
  }

  interface Props {
    diagram: DiagramSummary;
    mode: 'grid' | 'list';
    folders?: FolderSummary[];
    onstar?: (diagram: DiagramSummary) => void;
    ondelete?: (id: string) => void;
    onmove?: (diagramId: string, folderId: string | null) => void;
    onupdate?: (diagram: DiagramSummary) => void;
  }

  let { diagram, mode, folders = [], onstar, ondelete, onmove, onupdate }: Props = $props();

  // ─── Local state ────────────────────────────────────────────────────────────

  let menuOpen = $state(false);
  let editMode = $state(false);
  let editDesc = $state(diagram.description ?? '');
  let editTags = $state((diagram.tags ?? []).join(', '));
  let editVisibility = $state(diagram.visibility);
  let editSaving = $state(false);

  function openEditMode() {
    editDesc = diagram.description ?? '';
    editTags = (diagram.tags ?? []).join(', ');
    editVisibility = diagram.visibility;
    editMode = true;
    menuOpen = false;
  }

  function cancelEdit() {
    editMode = false;
  }

  async function saveEdit() {
    editSaving = true;
    try {
      const tags = editTags
        .split(',')
        .map((t) => t.trim().toLowerCase())
        .filter((t) => t.length > 0)
        .slice(0, 20);

      const body: Record<string, unknown> = {
        description: editDesc.trim() || null,
        tags,
        visibility: editVisibility
      };

      const res = await fetch(`/api/diagrams/${diagram.id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body)
      });

      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        toast.error(data.message ?? 'Failed to update');
        return;
      }

      const updated = await res.json();
      diagram.description = updated.description ?? null;
      diagram.tags = Array.isArray(updated.tags) ? updated.tags : [];
      diagram.visibility = updated.visibility;
      diagram.updatedAt = updated.updatedAt;
      editMode = false;
      toast.success('Updated');
      onupdate?.(diagram);
    } catch {
      toast.error('Something went wrong');
    } finally {
      editSaving = false;
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  function formatDate(iso: string): string {
    const d = new Date(iso);
    const now = new Date();
    const diffMs = now.getTime() - d.getTime();
    const diffMin = Math.floor(diffMs / 60000);
    if (diffMin < 1) return 'Just now';
    if (diffMin < 60) return `${diffMin}m ago`;
    const diffHr = Math.floor(diffMin / 60);
    if (diffHr < 24) return `${diffHr}h ago`;
    const diffDay = Math.floor(diffHr / 24);
    if (diffDay < 30) return `${diffDay}d ago`;
    return d.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' });
  }

  function visibilityLabel(v: string): string {
    if (v === 'private') return 'Private';
    if (v === 'unlisted') return 'Unlisted';
    return 'Public';
  }

  const title = $derived(diagram.title || 'Untitled');
  const folderName = $derived(
    diagram.folderId ? (folders.find((f) => f.id === diagram.folderId)?.name ?? null) : null
  );
</script>

{#if mode === 'grid'}
  <!-- ─── Grid card ──────────────────────────────────────────────────────── -->
  <div
    class="group relative flex flex-col rounded-lg border border-border bg-card transition-colors hover:border-accent/50">
    <!-- Thumbnail area -->
    <a
      href="/d/{diagram.id}"
      class="block h-32 overflow-hidden rounded-t-lg bg-muted/30 no-underline">
      <!-- Placeholder — thumbnail rendering can be added later -->
      <div class="flex h-full items-center justify-center text-3xl text-muted-foreground/30">
        📊
      </div>
    </a>

    <!-- Card body -->
    <a href="/d/{diagram.id}" class="flex flex-1 flex-col gap-2 p-3 no-underline">
      <h3 class="line-clamp-2 text-sm font-medium text-foreground">{title}</h3>
      <div class="mt-auto flex items-center gap-2 text-xs text-muted-foreground">
        {#if diagram.visibility === 'private'}
          <LockIcon class="size-3" />
        {:else if diagram.visibility === 'unlisted'}
          <LinkIcon class="size-3" />
        {:else}
          <PublicIcon class="size-3" />
        {/if}
        <span>{visibilityLabel(diagram.visibility)}</span>
        <span class="ml-auto">{formatDate(diagram.updatedAt)}</span>
      </div>
    </a>

    <!-- Actions bar -->
    <div class="flex items-center border-t border-border px-2 py-1">
      <button
        class="rounded p-1.5 transition-colors hover:bg-muted"
        title={diagram.starred ? 'Unstar' : 'Star'}
        onclick={() => onstar?.(diagram)}>
        {#if diagram.starred}
          <StarIcon class="size-4 text-yellow-500" />
        {:else}
          <StarOutlineIcon class="size-4 text-muted-foreground" />
        {/if}
      </button>

      <a href="/d/{diagram.id}" class="rounded p-1.5 transition-colors hover:bg-muted" title="Open">
        <EditIcon class="size-4 text-muted-foreground" />
      </a>

      <div class="relative ml-auto">
        <button
          class="rounded p-1.5 transition-colors hover:bg-muted"
          title="More actions"
          onclick={() => (menuOpen = !menuOpen)}>
          <MoreIcon class="size-4 text-muted-foreground" />
        </button>
        {#if menuOpen}
          <!-- svelte-ignore a11y_no_static_element_interactions -->
          <div
            class="absolute right-0 bottom-full z-20 mb-1 w-44 rounded-md border border-border bg-popover p-1 shadow-md"
            onmouseleave={() => (menuOpen = false)}>
            <button
              class="flex w-full items-center gap-2 rounded px-2 py-1.5 text-sm hover:bg-muted"
              onclick={openEditMode}>
              <DetailsIcon class="size-3.5" /> Edit details
            </button>
            {#if folders.length > 0}
              <Separator class="my-1" />
              <div class="px-2 py-1 text-xs font-medium text-muted-foreground">Move to folder</div>
              {#if diagram.folderId}
                <button
                  class="flex w-full items-center gap-2 rounded px-2 py-1.5 text-sm hover:bg-muted"
                  onclick={() => {
                    onmove?.(diagram.id, null);
                    menuOpen = false;
                  }}>
                  <FolderIcon class="size-3.5" /> Root
                </button>
              {/if}
              {#each folders.filter((f) => f.id !== diagram.folderId) as folder (folder.id)}
                <button
                  class="flex w-full items-center gap-2 rounded px-2 py-1.5 text-sm hover:bg-muted"
                  onclick={() => {
                    onmove?.(diagram.id, folder.id);
                    menuOpen = false;
                  }}>
                  <FolderIcon class="size-3.5" />
                  <span class="truncate">{folder.name}</span>
                </button>
              {/each}
            {/if}
            <Separator class="my-1" />
            <button
              class="flex w-full items-center gap-2 rounded px-2 py-1.5 text-sm text-destructive hover:bg-destructive/10"
              onclick={() => {
                ondelete?.(diagram.id);
                menuOpen = false;
              }}>
              <DeleteIcon class="size-3.5" /> Delete
            </button>
          </div>
        {/if}
      </div>
    </div>

    <!-- Inline edit overlay -->
    {#if editMode}
      <!-- svelte-ignore a11y_no_static_element_interactions -->
      <div
        class="absolute inset-0 z-30 flex flex-col gap-2 rounded-lg border border-accent bg-card p-3"
        onclick={(e) => e.stopPropagation()}>
        <div class="text-xs font-medium text-muted-foreground">Edit details</div>

        <textarea
          class="flex min-h-[48px] w-full rounded-md border border-input bg-background px-2 py-1 text-xs ring-offset-background placeholder:text-muted-foreground focus-visible:ring-1 focus-visible:ring-ring focus-visible:outline-none"
          placeholder="Description..."
          bind:value={editDesc}
          maxlength={2000}></textarea>

        <Input
          type="text"
          placeholder="Tags (comma-separated)"
          bind:value={editTags}
          maxlength={500}
          class="h-7 text-xs" />

        <div class="flex gap-1">
          {#each [{ v: 'private', icon: LockIcon }, { v: 'unlisted', icon: LinkIcon }, { v: 'public', icon: PublicIcon }] as opt (opt.v)}
            <button
              type="button"
              class="flex flex-1 items-center justify-center gap-1 rounded border px-1 py-1 text-xs transition-colors {editVisibility ===
              opt.v
                ? 'border-accent bg-accent/10 text-accent'
                : 'border-border text-muted-foreground hover:border-accent/50'}"
              onclick={() => (editVisibility = opt.v)}>
              <opt.icon class="size-3" />
              <span class="capitalize">{opt.v}</span>
            </button>
          {/each}
        </div>

        <div class="mt-auto flex gap-2">
          <button
            class="flex-1 rounded bg-muted px-2 py-1 text-xs hover:bg-muted/80"
            onclick={cancelEdit}
            disabled={editSaving}>
            Cancel
          </button>
          <button
            class="flex-1 rounded bg-accent px-2 py-1 text-xs text-accent-foreground hover:bg-accent/90"
            onclick={saveEdit}
            disabled={editSaving}>
            {editSaving ? 'Saving...' : 'Save'}
          </button>
        </div>
      </div>
    {/if}
  </div>
{:else}
  <!-- ─── List row ───────────────────────────────────────────────────────── -->
  <div class="group flex items-center gap-4 py-3">
    <button
      class="flex-shrink-0 rounded p-1 transition-colors hover:bg-muted"
      title={diagram.starred ? 'Unstar' : 'Star'}
      onclick={() => onstar?.(diagram)}>
      {#if diagram.starred}
        <StarIcon class="size-4 text-yellow-500" />
      {:else}
        <StarOutlineIcon class="size-4 text-muted-foreground" />
      {/if}
    </button>

    <a href="/d/{diagram.id}" class="flex flex-1 flex-col gap-0.5 no-underline">
      <span class="text-sm font-medium text-foreground">{title}</span>
      <span class="flex items-center gap-2 text-xs text-muted-foreground">
        {#if diagram.visibility === 'private'}
          <LockIcon class="size-3" />
        {:else if diagram.visibility === 'unlisted'}
          <LinkIcon class="size-3" />
        {:else}
          <PublicIcon class="size-3" />
        {/if}
        {visibilityLabel(diagram.visibility)}
        {#if folderName}
          <span>· {folderName}</span>
        {/if}
      </span>
    </a>

    <span class="hidden text-xs text-muted-foreground sm:block">
      {formatDate(diagram.updatedAt)}
    </span>

    <div class="flex items-center gap-1">
      <button
        class="rounded p-1.5 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
        title="Edit details"
        onclick={openEditMode}>
        <DetailsIcon class="size-4" />
      </button>
      <a
        href="/d/{diagram.id}"
        class="rounded p-1.5 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
        title="Open">
        <EditIcon class="size-4" />
      </a>
      <button
        class="rounded p-1.5 text-muted-foreground transition-colors hover:bg-muted hover:text-destructive"
        title="Delete"
        onclick={() => ondelete?.(diagram.id)}>
        <DeleteIcon class="size-4" />
      </button>
    </div>

    <!-- List row inline edit -->
    {#if editMode}
      <div class="col-span-full flex flex-wrap items-end gap-2 border-t border-border pt-2">
        <textarea
          class="flex min-h-[36px] flex-1 rounded-md border border-input bg-background px-2 py-1 text-xs ring-offset-background placeholder:text-muted-foreground focus-visible:ring-1 focus-visible:ring-ring focus-visible:outline-none"
          placeholder="Description..."
          bind:value={editDesc}
          maxlength={2000}></textarea>
        <Input
          type="text"
          placeholder="Tags"
          bind:value={editTags}
          maxlength={500}
          class="h-7 w-40 text-xs" />
        <select
          class="h-7 rounded-md border border-input bg-background px-2 text-xs"
          bind:value={editVisibility}>
          <option value="private">Private</option>
          <option value="unlisted">Unlisted</option>
          <option value="public">Public</option>
        </select>
        <button
          class="h-7 rounded bg-accent px-3 text-xs text-accent-foreground hover:bg-accent/90"
          onclick={saveEdit}
          disabled={editSaving}>
          {editSaving ? '...' : 'Save'}
        </button>
        <button
          class="h-7 rounded bg-muted px-3 text-xs hover:bg-muted/80"
          onclick={cancelEdit}
          disabled={editSaving}>
          Cancel
        </button>
      </div>
    {/if}
  </div>
{/if}
