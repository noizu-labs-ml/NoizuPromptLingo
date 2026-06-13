<script lang="ts" module>
  // Named export: navbar trigger button for the edit page
  export { default as DiagramHistoryButton } from './DiagramHistoryButton.svelte';
</script>

<script lang="ts">
  import { Button } from '$/components/ui/button';
  import * as Dialog from '$/components/ui/dialog';
  import { Input } from '$/components/ui/input';
  import { Separator } from '$/components/ui/separator';
  import { toast } from 'svelte-sonner';
  import HistoryIcon from '~icons/material-symbols/history-rounded';
  import BranchIcon from '~icons/material-symbols/fork-right-rounded';
  import VisibilityIcon from '~icons/material-symbols/visibility-outline-rounded';
  import RestoreIcon from '~icons/material-symbols/restore-rounded';
  import AddIcon from '~icons/material-symbols/add-rounded';
  import CloseIcon from '~icons/material-symbols/close-rounded';

  import type {
    Branch,
    BranchListResponse,
    Commit,
    CommitDetail,
    CommitListResponse
  } from '$/types/api';

  // ─── Props ───────────────────────────────────────────────────────────────────

  interface Props {
    diagramId: string;
    isOwner: boolean;
  }

  let { diagramId, isOwner }: Props = $props();

  // ─── State ───────────────────────────────────────────────────────────────────

  let open = $state(false);
  let branches: Branch[] = $state([]);
  let commits: Commit[] = $state([]);
  let hasMore = $state(false);
  let activeBranchId: string | null = $state(null);
  let loading = $state(false);
  let loadingCommits = $state(false);

  // New branch form
  let showNewBranch = $state(false);
  let newBranchName = $state('');
  let creatingBranch = $state(false);

  // Commit detail viewer
  let viewingCommit: CommitDetail | null = $state(null);
  let loadingDetail = $state(false);

  // Revert
  let reverting: string | null = $state(null);

  let activeBranch = $derived(branches.find((b) => b.id === activeBranchId) ?? null);

  // ─── Relative time helper ────────────────────────────────────────────────────

  function relativeTime(iso: string): string {
    const diff = Date.now() - new Date(iso).getTime();
    const seconds = Math.floor(diff / 1000);
    if (seconds < 60) return 'just now';
    const minutes = Math.floor(seconds / 60);
    if (minutes < 60) return `${minutes}m ago`;
    const hours = Math.floor(minutes / 60);
    if (hours < 24) return `${hours}h ago`;
    const days = Math.floor(hours / 24);
    if (days < 30) return `${days}d ago`;
    const months = Math.floor(days / 30);
    return `${months}mo ago`;
  }

  // ─── API ─────────────────────────────────────────────────────────────────────

  async function fetchBranches() {
    loading = true;
    try {
      const res = await fetch(`/api/diagrams/${diagramId}/branches`);
      if (res.ok) {
        const data: BranchListResponse = await res.json();
        branches = data.branches;
        // Default to "main" branch or first available
        if (!activeBranchId && branches.length > 0) {
          const main = branches.find((b) => b.name === 'main');
          activeBranchId = main?.id ?? branches[0].id;
        }
      }
    } finally {
      loading = false;
    }
  }

  async function fetchCommits(branchName: string) {
    loadingCommits = true;
    commits = [];
    try {
      const res = await fetch(
        `/api/diagrams/${diagramId}/commits?branch=${encodeURIComponent(branchName)}`
      );
      if (res.ok) {
        const data: CommitListResponse = await res.json();
        commits = data.commits;
        hasMore = data.hasMore;
      }
    } finally {
      loadingCommits = false;
    }
  }

  async function viewCommit(commitId: string) {
    loadingDetail = true;
    viewingCommit = null;
    try {
      const res = await fetch(`/api/diagrams/${diagramId}/commits/${commitId}`);
      if (res.ok) {
        viewingCommit = await res.json();
      } else {
        toast.error('Failed to load commit details');
      }
    } finally {
      loadingDetail = false;
    }
  }

  async function revertToCommit(commitId: string) {
    reverting = commitId;
    try {
      const res = await fetch(`/api/diagrams/${diagramId}/revert`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ commitId })
      });
      if (res.ok) {
        toast.success('Reverted successfully');
        // Refresh commits to show the new revert commit
        if (activeBranch) {
          await fetchCommits(activeBranch.name);
        }
      } else {
        const data = await res.json().catch(() => ({}));
        toast.error(data.message ?? 'Failed to revert');
      }
    } finally {
      reverting = null;
    }
  }

  async function createBranch() {
    const name = newBranchName.trim();
    if (!name) return;

    creatingBranch = true;
    try {
      const res = await fetch(`/api/diagrams/${diagramId}/branches`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name })
      });
      if (res.ok) {
        const branch: Branch = await res.json();
        branches = [...branches, branch];
        activeBranchId = branch.id;
        newBranchName = '';
        showNewBranch = false;
        toast.success(`Branch "${name}" created`);
        await fetchCommits(name);
      } else {
        const data = await res.json().catch(() => ({}));
        toast.error(data.message ?? 'Failed to create branch');
      }
    } finally {
      creatingBranch = false;
    }
  }

  async function switchBranch(branchId: string) {
    const branch = branches.find((b) => b.id === branchId);
    if (!branch || branch.id === activeBranchId) return;

    activeBranchId = branchId;
    viewingCommit = null;

    // Notify the server of the branch switch
    await fetch(`/api/diagrams/${diagramId}/branches/${branchId}`, {
      method: 'PATCH'
    }).catch(() => {
      /* non-critical */
    });

    await fetchCommits(branch.name);
  }

  // ─── Lifecycle ───────────────────────────────────────────────────────────────

  function handleOpen() {
    open = true;
    viewingCommit = null;
    fetchBranches().then(() => {
      if (activeBranch) {
        fetchCommits(activeBranch.name);
      }
    });
  }
</script>

<Dialog.Root bind:open>
  <Button size="sm" variant="outline" onclick={handleOpen}>
    <HistoryIcon class="mr-1 size-4" />
    History
  </Button>

  <Dialog.Content class="flex max-h-[80vh] max-w-lg flex-col">
    <Dialog.Header>
      <Dialog.Title class="flex items-center gap-2 text-lg">
        <HistoryIcon class="size-5" />
        Diagram History
      </Dialog.Title>
      <Dialog.Description>Browse commits and manage branches for this diagram.</Dialog.Description>
    </Dialog.Header>

    <!-- Branch selector -->
    <div class="flex items-center gap-2">
      <BranchIcon class="size-4 shrink-0 text-muted-foreground" />
      <select
        class="flex h-8 flex-1 rounded-md border border-input bg-background px-2 text-sm shadow-sm transition-colors focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none"
        value={activeBranchId}
        onchange={(e) => switchBranch((e.target as HTMLSelectElement).value)}
        disabled={loading}>
        {#each branches as branch (branch.id)}
          <option value={branch.id}>
            {branch.name}
            {#if branch.id === activeBranchId}(current){/if}
          </option>
        {/each}
      </select>

      <button
        class="rounded p-1.5 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
        title="New branch"
        onclick={() => (showNewBranch = !showNewBranch)}>
        {#if showNewBranch}
          <CloseIcon class="size-4" />
        {:else}
          <AddIcon class="size-4" />
        {/if}
      </button>
    </div>

    <!-- New branch inline form -->
    {#if showNewBranch}
      <form
        class="flex gap-2"
        onsubmit={(e) => {
          e.preventDefault();
          createBranch();
        }}>
        <Input
          type="text"
          bind:value={newBranchName}
          placeholder="Branch name..."
          class="flex-1 text-sm"
          maxlength={80}
          disabled={creatingBranch} />
        <Button type="submit" size="sm" disabled={creatingBranch || !newBranchName.trim()}>
          {#if creatingBranch}Creating...{:else}Create{/if}
        </Button>
      </form>
    {/if}

    <Separator />

    <!-- Commit detail viewer -->
    {#if viewingCommit || loadingDetail}
      <div class="flex flex-col gap-2">
        <div class="flex items-center justify-between">
          <span class="text-xs font-semibold tracking-wider text-muted-foreground uppercase">
            Commit {viewingCommit?.id.slice(0, 8) ?? '...'}
          </span>
          <button
            class="rounded p-1 text-muted-foreground hover:text-foreground"
            title="Close preview"
            onclick={() => (viewingCommit = null)}>
            <CloseIcon class="size-3.5" />
          </button>
        </div>
        {#if loadingDetail}
          <div class="py-4 text-center text-sm text-muted-foreground">Loading commit...</div>
        {:else if viewingCommit}
          <textarea
            readonly
            class="min-h-[160px] w-full rounded-md border border-input bg-muted/50 px-3 py-2 font-mono text-xs leading-relaxed focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none"
            value={viewingCommit.code}></textarea>
          {#if viewingCommit.config}
            <details class="text-xs text-muted-foreground">
              <summary class="cursor-pointer hover:text-foreground">Config</summary>
              <pre
                class="mt-1 max-h-[80px] overflow-auto rounded bg-muted p-2 text-xs">{viewingCommit.config}</pre>
            </details>
          {/if}
        {/if}
      </div>
      <Separator />
    {/if}

    <!-- Commit list -->
    <div class="flex min-h-0 flex-1 flex-col gap-1 overflow-y-auto">
      <span class="text-xs font-semibold tracking-wider text-muted-foreground uppercase">
        Commits
        {#if activeBranch}
          on {activeBranch.name}
        {/if}
      </span>

      {#if loading || loadingCommits}
        <div class="py-6 text-center text-sm text-muted-foreground">Loading...</div>
      {:else if commits.length === 0}
        <div class="py-6 text-center text-sm text-muted-foreground">
          No commits on this branch yet.
        </div>
      {:else}
        {#each commits as commit (commit.id)}
          <div
            class="group flex items-start gap-2 rounded-md px-2 py-1.5 transition-colors hover:bg-muted">
            <!-- Commit info -->
            <div class="flex min-w-0 flex-1 flex-col gap-0.5">
              <div class="flex items-center gap-2">
                <code class="shrink-0 text-xs text-accent">{commit.id.slice(0, 8)}</code>
                <span class="truncate text-sm">
                  {commit.message ?? 'Auto-save'}
                </span>
              </div>
              <div class="flex items-center gap-2 text-xs text-muted-foreground">
                {#if commit.authorName}
                  <span>{commit.authorName}</span>
                  <span class="opacity-40">-</span>
                {/if}
                <span>{relativeTime(commit.createdAt)}</span>
              </div>
            </div>

            <!-- Actions -->
            <div
              class="flex shrink-0 items-center gap-1 opacity-0 transition-opacity group-hover:opacity-100">
              <button
                class="rounded p-1 text-muted-foreground hover:bg-accent/10 hover:text-accent"
                title="View code"
                onclick={() => viewCommit(commit.id)}>
                <VisibilityIcon class="size-3.5" />
              </button>
              {#if isOwner}
                <button
                  class="rounded p-1 text-muted-foreground hover:bg-accent/10 hover:text-accent"
                  title="Revert to this commit"
                  disabled={reverting === commit.id}
                  onclick={() => revertToCommit(commit.id)}>
                  <RestoreIcon class="size-3.5" />
                </button>
              {/if}
            </div>
          </div>
        {/each}

        {#if hasMore}
          <div class="py-2 text-center text-xs text-muted-foreground">
            Showing latest commits. More history available via API.
          </div>
        {/if}
      {/if}
    </div>
  </Dialog.Content>
</Dialog.Root>
