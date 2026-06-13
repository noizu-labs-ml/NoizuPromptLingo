<script lang="ts">
  import { Button } from '$/components/ui/button';
  import * as Popover from '$/components/ui/popover';
  import { Separator } from '$/components/ui/separator';
  import { toast } from 'svelte-sonner';
  import OrgIcon from '~icons/material-symbols/corporate-fare-rounded';
  import AddIcon from '~icons/material-symbols/add-rounded';
  import CheckIcon from '~icons/material-symbols/check-rounded';
  import GearIcon from '~icons/material-symbols/settings-outline-rounded';
  import { onMount } from 'svelte';

  // ─── Types ──────────────────────────────────────────────────────────────────

  export interface OrgSummary {
    id: string;
    name: string;
    slug: string;
    role: string;
  }

  interface Props {
    /** Currently selected org (null = personal context) */
    activeOrgId?: string | null;
    onselect?: (orgId: string | null) => void;
  }

  let { activeOrgId = null, onselect }: Props = $props();

  // ─── State ──────────────────────────────────────────────────────────────────

  let orgs: OrgSummary[] = $state([]);
  let popoverOpen = $state(false);
  let creating = $state(false);
  let newOrgName = $state('');
  let newOrgSlug = $state('');

  let activeOrgName = $derived(
    activeOrgId ? (orgs.find((o) => o.id === activeOrgId)?.name ?? 'Organization') : null
  );

  // ─── API ────────────────────────────────────────────────────────────────────

  async function fetchOrgs() {
    const res = await fetch('/api/orgs');
    if (res.ok) {
      const data = await res.json();
      orgs = data.organizations;
    }
  }

  async function createOrg() {
    if (!newOrgName.trim() || !newOrgSlug.trim()) return;
    const res = await fetch('/api/orgs', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: newOrgName.trim(), slug: newOrgSlug.trim().toLowerCase() })
    });
    if (res.ok) {
      const org = await res.json();
      orgs = [...orgs, { id: org.id, name: org.name, slug: org.slug, role: org.role }];
      onselect?.(org.id);
      creating = false;
      newOrgName = '';
      newOrgSlug = '';
      popoverOpen = false;
      toast.success(`Created "${org.name}"`);
    } else {
      const data = await res.json().catch(() => ({}));
      toast.error(data.message ?? 'Failed to create organization');
    }
  }

  function selectOrg(id: string | null) {
    onselect?.(id);
    popoverOpen = false;
  }

  /** Auto-generate slug from name */
  function autoSlug(name: string): string {
    return name
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-|-$/g, '')
      .slice(0, 60);
  }

  onMount(fetchOrgs);
</script>

<Popover.Root bind:open={popoverOpen}>
  <Popover.Trigger asChild let:builder>
    <Button builders={[builder]} variant="ghost" size="sm" class="gap-1.5">
      <OrgIcon class="size-4" />
      {#if activeOrgName}
        <span class="max-w-24 truncate text-xs">{activeOrgName}</span>
      {:else}
        <span class="text-xs">Personal</span>
      {/if}
    </Button>
  </Popover.Trigger>

  <Popover.Content align="end" class="w-64 p-0" sideOffset={8}>
    <div class="flex flex-col">
      <!-- Personal context -->
      <button
        class="flex items-center gap-2 px-3 py-2 text-sm hover:bg-muted {!activeOrgId
          ? 'font-medium text-accent'
          : 'text-foreground'}"
        onclick={() => selectOrg(null)}>
        {#if !activeOrgId}
          <CheckIcon class="size-4" />
        {:else}
          <div class="size-4" />
        {/if}
        Personal
      </button>

      {#if orgs.length > 0}
        <Separator />
        <div class="px-3 py-1.5">
          <span class="text-xs font-semibold tracking-wider text-muted-foreground uppercase">
            Organizations
          </span>
        </div>
        {#each orgs as org (org.id)}
          <div class="flex items-center">
            <button
              class="flex flex-1 items-center gap-2 px-3 py-2 text-sm hover:bg-muted {activeOrgId ===
              org.id
                ? 'font-medium text-accent'
                : 'text-foreground'}"
              onclick={() => selectOrg(org.id)}>
              {#if activeOrgId === org.id}
                <CheckIcon class="size-4" />
              {:else}
                <div class="size-4" />
              {/if}
              <span class="truncate">{org.name}</span>
              <span class="ml-auto text-xs text-muted-foreground">{org.role}</span>
            </button>
            {#if org.role === 'owner' || org.role === 'admin'}
              <a
                href="/orgs/{org.id}"
                class="p-1.5 text-muted-foreground hover:text-foreground"
                title="Settings">
                <GearIcon class="size-3.5" />
              </a>
            {/if}
          </div>
        {/each}
      {/if}

      <Separator />

      {#if creating}
        <form
          class="flex flex-col gap-2 p-3"
          onsubmit={(e) => {
            e.preventDefault();
            createOrg();
          }}>
          <input
            type="text"
            bind:value={newOrgName}
            placeholder="Organization name"
            class="h-8 rounded-md border border-border bg-background px-2 text-sm"
            oninput={() => {
              if (!newOrgSlug || newOrgSlug === autoSlug(newOrgName.slice(0, -1))) {
                newOrgSlug = autoSlug(newOrgName);
              }
            }}
            autofocus />
          <input
            type="text"
            bind:value={newOrgSlug}
            placeholder="slug (url-friendly)"
            class="h-8 rounded-md border border-border bg-background px-2 font-mono text-sm" />
          <div class="flex gap-2">
            <Button
              type="button"
              variant="ghost"
              size="sm"
              class="flex-1"
              onclick={() => (creating = false)}>
              Cancel
            </Button>
            <Button type="submit" size="sm" class="flex-1">Create</Button>
          </div>
        </form>
      {:else}
        <button
          class="flex items-center gap-2 px-3 py-2 text-sm text-muted-foreground hover:bg-muted hover:text-foreground"
          onclick={() => (creating = true)}>
          <AddIcon class="size-4" />
          New Organization
        </button>
      {/if}
    </div>
  </Popover.Content>
</Popover.Root>
