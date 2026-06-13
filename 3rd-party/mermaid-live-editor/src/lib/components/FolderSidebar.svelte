<script lang="ts">
  import { Button } from '$/components/ui/button';
  import { Input } from '$/components/ui/input';
  import { Separator } from '$/components/ui/separator';
  import StarIcon from '~icons/material-symbols/star-rounded';
  import FolderIcon from '~icons/material-symbols/folder-outline-rounded';
  import FolderOpenIcon from '~icons/material-symbols/folder-open-rounded';
  import AddIcon from '~icons/material-symbols/add-rounded';
  import EditIcon from '~icons/material-symbols/edit-outline-rounded';
  import DeleteIcon from '~icons/material-symbols/delete-outline-rounded';
  import { toast } from 'svelte-sonner';

  // ─── Types ──────────────────────────────────────────────────────────────────

  export interface Folder {
    id: string;
    userId: string;
    name: string;
    parentId: string | null;
    createdAt: string;
    updatedAt: string;
  }

  interface Props {
    folders: Folder[];
    activeFolderId: string | null;
    showStarredOnly: boolean;
    onselectall?: () => void;
    onselectstarred?: () => void;
    onselectfolder?: (id: string) => void;
    onfoldercreated?: (folder: Folder) => void;
    onfolderrenamed?: (id: string, name: string) => void;
    onfolderdeleted?: (id: string) => void;
  }

  let {
    folders,
    activeFolderId,
    showStarredOnly,
    onselectall,
    onselectstarred,
    onselectfolder,
    onfoldercreated,
    onfolderrenamed,
    onfolderdeleted
  }: Props = $props();

  // ─── Local state ────────────────────────────────────────────────────────────

  let creatingFolder = $state(false);
  let newFolderName = $state('');
  let renamingFolderId: string | null = $state(null);
  let renameFolderValue = $state('');

  // ─── Derived ────────────────────────────────────────────────────────────────

  let rootFolders = $derived(folders.filter((f) => !f.parentId));
  let activeFolderChildren = $derived(
    activeFolderId ? folders.filter((f) => f.parentId === activeFolderId) : []
  );

  // ─── Folder CRUD ────────────────────────────────────────────────────────────

  async function createFolder() {
    if (!newFolderName.trim()) return;
    const res = await fetch('/api/folders', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name: newFolderName.trim(),
        parentId: activeFolderId
      })
    });
    if (res.ok) {
      const folder = await res.json();
      onfoldercreated?.(folder);
      newFolderName = '';
      creatingFolder = false;
    } else {
      toast.error('Failed to create folder');
    }
  }

  async function renameFolder(id: string) {
    if (!renameFolderValue.trim()) return;
    const res = await fetch(`/api/folders/${id}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: renameFolderValue.trim() })
    });
    if (res.ok) {
      onfolderrenamed?.(id, renameFolderValue.trim());
      renamingFolderId = null;
    } else {
      toast.error('Failed to rename folder');
    }
  }

  async function deleteFolder(id: string) {
    const res = await fetch(`/api/folders/${id}`, { method: 'DELETE' });
    if (res.ok) {
      onfolderdeleted?.(id);
      toast.success('Folder deleted — diagrams moved to root');
    } else {
      toast.error('Failed to delete folder');
    }
  }
</script>

<aside class="hidden w-64 flex-shrink-0 overflow-y-auto border-r border-border p-4 md:block">
  <nav class="flex flex-col gap-1">
    <!-- All Diagrams -->
    <button
      class="flex items-center gap-2 rounded-md px-3 py-2 text-sm transition-colors {!activeFolderId &&
      !showStarredOnly
        ? 'bg-accent/10 font-medium text-accent'
        : 'text-foreground hover:bg-muted'}"
      onclick={onselectall}>
      <FolderIcon class="size-4" />
      All Diagrams
    </button>

    <!-- Starred -->
    <button
      class="flex items-center gap-2 rounded-md px-3 py-2 text-sm transition-colors {showStarredOnly
        ? 'bg-accent/10 font-medium text-accent'
        : 'text-foreground hover:bg-muted'}"
      onclick={onselectstarred}>
      <StarIcon class="size-4 text-yellow-500" />
      Starred
    </button>

    <Separator class="my-2" />

    <!-- Folders header -->
    <div class="flex items-center justify-between px-3">
      <span class="text-xs font-semibold tracking-wider text-muted-foreground uppercase">
        Folders
      </span>
      <button
        class="rounded p-0.5 text-muted-foreground hover:text-foreground"
        title="New folder"
        onclick={() => (creatingFolder = true)}>
        <AddIcon class="size-4" />
      </button>
    </div>

    {#if creatingFolder}
      <form
        class="flex items-center gap-1 px-3"
        onsubmit={(e) => {
          e.preventDefault();
          createFolder();
        }}>
        <Input
          type="text"
          bind:value={newFolderName}
          placeholder="Folder name"
          class="h-7 text-sm"
          autofocus />
        <Button type="submit" size="sm" class="h-7 px-2 text-xs">Add</Button>
      </form>
    {/if}

    {#each rootFolders as folder (folder.id)}
      <div class="group flex items-center">
        {#if renamingFolderId === folder.id}
          <form
            class="flex flex-1 items-center gap-1 px-3"
            onsubmit={(e) => {
              e.preventDefault();
              renameFolder(folder.id);
            }}>
            <Input type="text" bind:value={renameFolderValue} class="h-7 text-sm" autofocus />
            <Button type="submit" size="sm" class="h-7 px-2 text-xs">OK</Button>
          </form>
        {:else}
          <button
            class="flex flex-1 items-center gap-2 rounded-md px-3 py-2 text-sm transition-colors {activeFolderId ===
            folder.id
              ? 'bg-accent/10 font-medium text-accent'
              : 'text-foreground hover:bg-muted'}"
            onclick={() => onselectfolder?.(folder.id)}>
            {#if activeFolderId === folder.id}
              <FolderOpenIcon class="size-4" />
            {:else}
              <FolderIcon class="size-4" />
            {/if}
            <span class="truncate">{folder.name}</span>
          </button>
          <div class="hidden items-center gap-0.5 group-hover:flex">
            <button
              class="rounded p-0.5 text-muted-foreground hover:text-foreground"
              title="Rename"
              onclick={() => {
                renamingFolderId = folder.id;
                renameFolderValue = folder.name;
              }}>
              <EditIcon class="size-3.5" />
            </button>
            <button
              class="rounded p-0.5 text-muted-foreground hover:text-destructive"
              title="Delete folder"
              onclick={() => deleteFolder(folder.id)}>
              <DeleteIcon class="size-3.5" />
            </button>
          </div>
        {/if}
      </div>
    {/each}

    <!-- Nested children when a folder is active -->
    {#if activeFolderId && activeFolderChildren.length > 0}
      <div class="ml-4 flex flex-col gap-1 border-l border-border pl-2">
        {#each activeFolderChildren as child (child.id)}
          <button
            class="flex items-center gap-2 rounded-md px-3 py-1.5 text-sm text-foreground transition-colors hover:bg-muted"
            onclick={() => onselectfolder?.(child.id)}>
            <FolderIcon class="size-3.5" />
            <span class="truncate">{child.name}</span>
          </button>
        {/each}
      </div>
    {/if}
  </nav>
</aside>
