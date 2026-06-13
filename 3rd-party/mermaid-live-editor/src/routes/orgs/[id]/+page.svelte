<script lang="ts">
  import Navbar from '$/components/Navbar.svelte';
  import { Button } from '$/components/ui/button';
  import { Input } from '$/components/ui/input';
  import { Separator } from '$/components/ui/separator';
  import { toast } from 'svelte-sonner';
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import OrgIcon from '~icons/material-symbols/corporate-fare-rounded';
  import PersonIcon from '~icons/material-symbols/person-outline-rounded';
  import DeleteIcon from '~icons/material-symbols/delete-outline-rounded';
  import AddIcon from '~icons/material-symbols/add-rounded';

  // ─── Types ──────────────────────────────────────────────────────────────────

  interface OrgMember {
    userId: string;
    role: string;
    joinedAt: string;
    name: string | null;
    email: string;
    handle: string | null;
    image: string | null;
  }

  interface OrgDetail {
    id: string;
    name: string;
    slug: string;
    myRole: string;
    members: OrgMember[];
    createdAt: string;
    updatedAt: string;
  }

  // ─── State ──────────────────────────────────────────────────────────────────

  let org: OrgDetail | null = $state(null);
  let loading = $state(true);
  let editingName = $state(false);
  let nameValue = $state('');
  let addingMember = $state(false);
  let newMemberId = $state('');
  let newMemberRole: 'admin' | 'member' = $state('member');
  let confirmDelete = $state(false);

  let isOwner = $derived(org?.myRole === 'owner');
  let isAdmin = $derived(org?.myRole === 'admin' || isOwner);
  let orgId = $derived($page.params.id);

  // ─── API ────────────────────────────────────────────────────────────────────

  async function fetchOrg() {
    loading = true;
    try {
      const res = await fetch(`/api/orgs/${orgId}`);
      if (res.ok) {
        org = await res.json();
        nameValue = org?.name ?? '';
      } else {
        toast.error('Organization not found');
        window.location.href = '/diagrams';
      }
    } finally {
      loading = false;
    }
  }

  async function updateName() {
    if (!nameValue.trim() || !org) return;
    const res = await fetch(`/api/orgs/${orgId}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: nameValue.trim() })
    });
    if (res.ok) {
      const updated = await res.json();
      org = { ...org, name: updated.name };
      editingName = false;
      toast.success('Name updated');
    } else {
      toast.error('Failed to update name');
    }
  }

  async function addMember() {
    if (!newMemberId.trim()) return;
    const res = await fetch(`/api/orgs/${orgId}/members`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ userId: newMemberId.trim(), role: newMemberRole })
    });
    if (res.ok) {
      const member = await res.json();
      if (org) {
        org = { ...org, members: [...org.members, member] };
      }
      newMemberId = '';
      addingMember = false;
      toast.success('Member added');
    } else {
      const data = await res.json().catch(() => ({}));
      toast.error(data.message ?? 'Failed to add member');
    }
  }

  async function removeMember(userId: string) {
    const res = await fetch(`/api/orgs/${orgId}/members/${userId}`, { method: 'DELETE' });
    if (res.ok) {
      if (org) {
        org = { ...org, members: org.members.filter((m) => m.userId !== userId) };
      }
      toast.success('Member removed');
    } else {
      const data = await res.json().catch(() => ({}));
      toast.error(data.message ?? 'Failed to remove member');
    }
  }

  async function changeRole(userId: string, role: string) {
    const res = await fetch(`/api/orgs/${orgId}/members/${userId}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ role })
    });
    if (res.ok) {
      if (org) {
        org = {
          ...org,
          members: org.members.map((m) => (m.userId === userId ? { ...m, role } : m))
        };
      }
      toast.success('Role updated');
    } else {
      const data = await res.json().catch(() => ({}));
      toast.error(data.message ?? 'Failed to change role');
    }
  }

  async function deleteOrg() {
    const res = await fetch(`/api/orgs/${orgId}`, { method: 'DELETE' });
    if (res.ok) {
      toast.success('Organization deleted');
      window.location.href = '/diagrams';
    } else {
      toast.error('Failed to delete organization');
    }
  }

  onMount(fetchOrg);
</script>

<div class="flex h-full flex-col overflow-hidden">
  <Navbar hidePromotion>
    <Button variant="ghost" size="sm" onclick={() => (window.location.href = '/diagrams')}>
      ← Back to Diagrams
    </Button>
  </Navbar>

  <div class="mx-auto w-full max-w-2xl overflow-y-auto p-6">
    {#if loading}
      <div class="text-center text-muted-foreground">Loading...</div>
    {:else if org}
      <!-- Header -->
      <div class="mb-6 flex items-center gap-3">
        <OrgIcon class="size-8 text-accent" />
        <div>
          {#if editingName && isAdmin}
            <form
              class="flex items-center gap-2"
              onsubmit={(e) => {
                e.preventDefault();
                updateName();
              }}>
              <Input
                type="text"
                bind:value={nameValue}
                class="h-8 text-lg font-semibold"
                autofocus />
              <Button type="submit" size="sm">Save</Button>
              <Button type="button" variant="ghost" size="sm" onclick={() => (editingName = false)}>
                Cancel
              </Button>
            </form>
          {:else}
            <h1
              class="text-xl font-semibold {isAdmin ? 'cursor-pointer hover:text-accent' : ''}"
              onclick={() => isAdmin && (editingName = true)}
              role={isAdmin ? 'button' : undefined}
              tabindex={isAdmin ? 0 : undefined}>
              {org.name}
            </h1>
          {/if}
          <p class="font-mono text-sm text-muted-foreground">@{org.slug}</p>
        </div>
      </div>

      <Separator class="mb-6" />

      <!-- Members -->
      <div class="mb-6">
        <div class="mb-3 flex items-center justify-between">
          <h2 class="text-base font-semibold">Members ({org.members.length})</h2>
          {#if isAdmin}
            <Button variant="outline" size="sm" onclick={() => (addingMember = true)}>
              <AddIcon class="mr-1 size-4" />
              Add member
            </Button>
          {/if}
        </div>

        {#if addingMember}
          <form
            class="mb-3 flex items-center gap-2 rounded-md border border-border p-3"
            onsubmit={(e) => {
              e.preventDefault();
              addMember();
            }}>
            <Input
              type="text"
              bind:value={newMemberId}
              placeholder="User ID"
              class="flex-1 text-sm"
              autofocus />
            <select
              bind:value={newMemberRole}
              class="h-9 rounded-md border border-border bg-background px-2 text-sm">
              <option value="member">Member</option>
              <option value="admin">Admin</option>
            </select>
            <Button type="submit" size="sm">Add</Button>
            <Button type="button" variant="ghost" size="sm" onclick={() => (addingMember = false)}>
              Cancel
            </Button>
          </form>
        {/if}

        <div class="flex flex-col gap-1">
          {#each org.members as member (member.userId)}
            <div class="flex items-center gap-3 rounded-md px-3 py-2 hover:bg-muted">
              <PersonIcon class="size-5 text-muted-foreground" />
              <div class="flex-1">
                <div class="text-sm font-medium">
                  {member.handle ? `@${member.handle}` : (member.name ?? member.email)}
                </div>
                <div class="text-xs text-muted-foreground">{member.email}</div>
              </div>

              {#if isOwner && member.role !== 'owner'}
                <select
                  value={member.role}
                  onchange={(e) => changeRole(member.userId, (e.target as HTMLSelectElement).value)}
                  class="h-7 rounded border border-border bg-background px-1.5 text-xs">
                  <option value="member">Member</option>
                  <option value="admin">Admin</option>
                </select>
              {:else}
                <span class="rounded bg-muted px-2 py-0.5 text-xs text-muted-foreground capitalize">
                  {member.role}
                </span>
              {/if}

              {#if isAdmin && member.role !== 'owner'}
                <button
                  class="rounded p-1 text-muted-foreground hover:text-destructive"
                  title="Remove member"
                  onclick={() => removeMember(member.userId)}>
                  <DeleteIcon class="size-4" />
                </button>
              {/if}
            </div>
          {/each}
        </div>
      </div>

      <!-- Danger zone (owner only) -->
      {#if isOwner}
        <Separator class="mb-6" />
        <div class="rounded-md border border-destructive/30 p-4">
          <h2 class="mb-2 text-base font-semibold text-destructive">Danger Zone</h2>
          <p class="mb-3 text-sm text-muted-foreground">
            Deleting this organization will remove all members and revoke all diagram shares
            associated with it. This action cannot be undone.
          </p>
          {#if confirmDelete}
            <div class="flex items-center gap-2">
              <span class="text-sm font-medium text-destructive">Are you sure?</span>
              <Button variant="destructive" size="sm" onclick={deleteOrg}>
                Yes, delete "{org.name}"
              </Button>
              <Button variant="ghost" size="sm" onclick={() => (confirmDelete = false)}>
                Cancel
              </Button>
            </div>
          {:else}
            <Button variant="destructive" size="sm" onclick={() => (confirmDelete = true)}>
              Delete Organization
            </Button>
          {/if}
        </div>
      {/if}
    {/if}
  </div>
</div>
