<script lang="ts">
  import { Button } from '$/components/ui/button';
  import * as Dialog from '$/components/ui/dialog';
  import { Input } from '$/components/ui/input';
  import { Separator } from '$/components/ui/separator';
  import { toast } from 'svelte-sonner';
  import ShareIcon from '~icons/material-symbols/share';
  import DeleteIcon from '~icons/material-symbols/delete-outline-rounded';
  import PersonIcon from '~icons/material-symbols/person-outline-rounded';
  import OrgIcon from '~icons/material-symbols/corporate-fare-rounded';

  // ─── Types ──────────────────────────────────────────────────────────────────

  interface Share {
    id: string;
    permission: string;
    createdAt: string;
    sharedWithUserId: string | null;
    sharedWithOrgId: string | null;
  }

  interface Props {
    diagramId: string;
    isOwner: boolean;
  }

  let { diagramId, isOwner }: Props = $props();

  // ─── State ──────────────────────────────────────────────────────────────────

  let open = $state(false);
  let shares: Share[] = $state([]);
  let loading = $state(false);
  let targetUserId = $state('');
  let targetOrgId = $state('');
  let permission: 'view' | 'edit' = $state('view');
  let shareMode: 'user' | 'org' = $state('user');

  // ─── API ────────────────────────────────────────────────────────────────────

  async function fetchShares() {
    loading = true;
    try {
      const res = await fetch(`/api/diagrams/${diagramId}/shares`);
      if (res.ok) {
        const data = await res.json();
        shares = data.shares;
      }
    } finally {
      loading = false;
    }
  }

  async function addShare() {
    const body: Record<string, string> = { permission };
    if (shareMode === 'user') {
      if (!targetUserId.trim()) return;
      body.userId = targetUserId.trim();
    } else {
      if (!targetOrgId.trim()) return;
      body.orgId = targetOrgId.trim();
    }

    const res = await fetch(`/api/diagrams/${diagramId}/shares`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body)
    });

    if (res.ok) {
      const share = await res.json();
      shares = [...shares, share];
      targetUserId = '';
      targetOrgId = '';
      toast.success('Access granted');
    } else {
      const data = await res.json().catch(() => ({}));
      toast.error(data.message ?? 'Failed to share');
    }
  }

  async function revokeShare(shareId: string) {
    const res = await fetch(`/api/diagrams/${diagramId}/shares/${shareId}`, {
      method: 'DELETE'
    });
    if (res.ok) {
      shares = shares.filter((s) => s.id !== shareId);
      toast.success('Access revoked');
    } else {
      toast.error('Failed to revoke access');
    }
  }

  function handleOpen() {
    open = true;
    fetchShares();
  }
</script>

{#if isOwner}
  <Dialog.Root bind:open>
    <Button size="sm" variant="outline" onclick={handleOpen}>
      <ShareIcon class="mr-1 size-4" />
      Share
    </Button>

    <Dialog.Content class="max-w-md">
      <Dialog.Header>
        <Dialog.Title class="flex items-center gap-2 text-lg">
          <ShareIcon class="size-5" />
          Share Diagram
        </Dialog.Title>
        <Dialog.Description>
          Grant view or edit access to specific users or organizations.
        </Dialog.Description>
      </Dialog.Header>

      <!-- Add share form -->
      <form
        class="flex flex-col gap-3"
        onsubmit={(e) => {
          e.preventDefault();
          addShare();
        }}>
        <!-- Share mode toggle -->
        <div class="flex gap-2">
          <button
            type="button"
            class="flex-1 rounded-md border px-3 py-1.5 text-sm transition-colors {shareMode ===
            'user'
              ? 'border-accent bg-accent/10 text-accent'
              : 'border-border text-muted-foreground hover:border-accent/50'}"
            onclick={() => (shareMode = 'user')}>
            <PersonIcon class="mr-1 inline size-4" /> User
          </button>
          <button
            type="button"
            class="flex-1 rounded-md border px-3 py-1.5 text-sm transition-colors {shareMode ===
            'org'
              ? 'border-accent bg-accent/10 text-accent'
              : 'border-border text-muted-foreground hover:border-accent/50'}"
            onclick={() => (shareMode = 'org')}>
            <OrgIcon class="mr-1 inline size-4" /> Organization
          </button>
        </div>

        <div class="flex gap-2">
          {#if shareMode === 'user'}
            <Input
              type="text"
              bind:value={targetUserId}
              placeholder="User ID"
              class="flex-1 text-sm" />
          {:else}
            <Input
              type="text"
              bind:value={targetOrgId}
              placeholder="Organization ID"
              class="flex-1 text-sm" />
          {/if}

          <select
            bind:value={permission}
            class="h-9 rounded-md border border-border bg-background px-2 text-sm">
            <option value="view">View</option>
            <option value="edit">Edit</option>
          </select>

          <Button type="submit" size="sm">Grant</Button>
        </div>
      </form>

      <Separator />

      <!-- Existing shares -->
      <div class="flex flex-col gap-1">
        <span class="text-xs font-semibold tracking-wider text-muted-foreground uppercase">
          Current access ({shares.length})
        </span>

        {#if loading}
          <div class="py-4 text-center text-sm text-muted-foreground">Loading...</div>
        {:else if shares.length === 0}
          <div class="py-4 text-center text-sm text-muted-foreground">
            No shares yet. Only you can access this diagram.
          </div>
        {:else}
          {#each shares as share (share.id)}
            <div class="flex items-center gap-2 rounded-md px-2 py-1.5 hover:bg-muted">
              {#if share.sharedWithUserId}
                <PersonIcon class="size-4 text-muted-foreground" />
                <span class="flex-1 truncate font-mono text-sm">{share.sharedWithUserId}</span>
              {:else if share.sharedWithOrgId}
                <OrgIcon class="size-4 text-muted-foreground" />
                <span class="flex-1 truncate font-mono text-sm">{share.sharedWithOrgId}</span>
              {/if}
              <span class="rounded bg-muted px-1.5 py-0.5 text-xs text-muted-foreground">
                {share.permission}
              </span>
              <button
                class="rounded p-1 text-muted-foreground hover:text-destructive"
                title="Revoke"
                onclick={() => revokeShare(share.id)}>
                <DeleteIcon class="size-3.5" />
              </button>
            </div>
          {/each}
        {/if}
      </div>
    </Dialog.Content>
  </Dialog.Root>
{/if}
