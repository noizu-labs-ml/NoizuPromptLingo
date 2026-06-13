<script lang="ts">
  import { Button } from '$/components/ui/button';
  import { Input } from '$/components/ui/input';
  import { Separator } from '$/components/ui/separator';
  import Navbar from '$/components/Navbar.svelte';
  import { authClient } from '$lib/auth-client';
  import { toast } from 'svelte-sonner';
  import type { PageData } from './$types';
  import PersonIcon from '~icons/material-symbols/person-outline-rounded';
  import OrgIcon from '~icons/material-symbols/groups-outline-rounded';
  import ChartIcon from '~icons/material-symbols/bar-chart-rounded';
  import StarIcon from '~icons/material-symbols/star-rounded';
  import PublicIcon from '~icons/material-symbols/public';
  import AddIcon from '~icons/material-symbols/add-rounded';

  let { data }: { data: PageData } = $props();

  // ─── Handle editing ────────────────────────────────────────────────────────

  let editingHandle = $state(false);
  let handle = $state(data.user.handle ?? '');
  let handleError = $state('');
  let handleSaving = $state(false);

  const handlePattern = /^[a-z0-9][a-z0-9-]{1,28}[a-z0-9]$/;

  async function saveHandle() {
    const normalized = handle.toLowerCase().trim();

    if (!handlePattern.test(normalized)) {
      handleError =
        'Handle must be 3-30 characters: lowercase letters, numbers, and hyphens. Must start and end with a letter or number.';
      return;
    }

    handleSaving = true;
    handleError = '';

    try {
      const response = await fetch('/api/auth/profile/handle', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ handle: normalized })
      });

      if (!response.ok) {
        const d = await response.json();
        handleError = d.message ?? 'Failed to save handle';
        return;
      }

      data.user.handle = normalized;
      editingHandle = false;
      toast.success('Handle updated');
    } catch {
      handleError = 'Something went wrong. Please try again.';
    } finally {
      handleSaving = false;
    }
  }

  // ─── Organization creation ────────────────────────────────────────────────

  let showCreateOrg = $state(false);
  let orgName = $state('');
  let orgSlug = $state('');
  let orgCreating = $state(false);
  let orgError = $state('');

  function slugify(name: string): string {
    return name
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-|-$/g, '')
      .slice(0, 48);
  }

  let autoSlug = $state(true);

  function handleOrgNameInput() {
    if (autoSlug) {
      orgSlug = slugify(orgName);
    }
  }

  function handleSlugInput() {
    autoSlug = false;
  }

  async function createOrg() {
    orgError = '';
    const name = orgName.trim();
    const slug = orgSlug.trim();

    if (!name) {
      orgError = 'Organization name is required.';
      return;
    }
    if (!slug || !/^[a-z0-9][a-z0-9-]*[a-z0-9]$/.test(slug)) {
      orgError =
        'Slug must be lowercase letters, numbers, and hyphens. Must start and end with a letter or number.';
      return;
    }

    orgCreating = true;
    try {
      const response = await fetch('/api/orgs', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name, slug })
      });

      if (!response.ok) {
        const d = await response.json();
        orgError = d.message ?? 'Failed to create organization';
        return;
      }

      const org = await response.json();
      data.organizations = [
        ...data.organizations,
        { createdAt: org.createdAt, id: org.id, name: org.name, role: 'owner', slug: org.slug }
      ];

      showCreateOrg = false;
      orgName = '';
      orgSlug = '';
      autoSlug = true;
      toast.success('Organization created');
    } catch {
      orgError = 'Something went wrong. Please try again.';
    } finally {
      orgCreating = false;
    }
  }

  function formatDate(d: unknown): string {
    if (!d) return 'Unknown';
    const date = typeof d === 'string' ? new Date(d) : (d as Date);
    return date.toLocaleDateString(undefined, { year: 'numeric', month: 'long', day: 'numeric' });
  }
</script>

<svelte:head>
  <title>Profile — Mermaid Live Editor</title>
</svelte:head>

<div class="flex min-h-screen flex-col bg-background">
  <Navbar>
    <Button variant="ghost" size="sm" onclick={() => (window.location.href = '/diagrams')}>
      My Diagrams
    </Button>
  </Navbar>

  <main class="mx-auto w-full max-w-2xl space-y-6 px-4 py-6">
    <!-- Account info -->
    <section class="rounded-lg border border-border bg-card p-5">
      <div class="mb-4 flex items-center gap-3">
        <div class="flex size-12 items-center justify-center rounded-full bg-accent/10 text-accent">
          {#if data.user.image}
            <img
              src={data.user.image}
              alt={data.user.name ?? 'Profile'}
              class="size-12 rounded-full object-cover" />
          {:else}
            <PersonIcon class="size-6" />
          {/if}
        </div>
        <div>
          <h1 class="text-lg font-semibold">{data.user.name ?? 'User'}</h1>
          {#if data.user.handle}
            <p class="text-sm text-muted-foreground">@{data.user.handle}</p>
          {/if}
        </div>
      </div>

      <div class="space-y-3 text-sm">
        <div class="flex items-center justify-between">
          <span class="text-muted-foreground">Email</span>
          <span>{data.user.email}</span>
        </div>

        <Separator />

        <div class="flex items-center justify-between">
          <span class="text-muted-foreground">Handle</span>
          {#if editingHandle}
            <form
              class="flex items-center gap-2"
              onsubmit={(e) => {
                e.preventDefault();
                saveHandle();
              }}>
              <div class="flex items-center gap-1">
                <span class="text-muted-foreground">@</span>
                <Input
                  type="text"
                  bind:value={handle}
                  maxlength={30}
                  class="h-7 w-40 text-sm"
                  autocomplete="username" />
              </div>
              <Button size="sm" type="submit" disabled={handleSaving} class="h-7 px-2 text-xs">
                Save
              </Button>
              <Button
                variant="ghost"
                size="sm"
                class="h-7 px-2 text-xs"
                onclick={() => {
                  editingHandle = false;
                  handle = data.user.handle ?? '';
                  handleError = '';
                }}>
                Cancel
              </Button>
            </form>
          {:else}
            <div class="flex items-center gap-2">
              <span>{data.user.handle ? `@${data.user.handle}` : 'Not set'}</span>
              <Button
                variant="ghost"
                size="sm"
                class="h-7 px-2 text-xs"
                onclick={() => (editingHandle = true)}>
                Edit
              </Button>
            </div>
          {/if}
        </div>
        {#if handleError}
          <p class="text-xs text-destructive">{handleError}</p>
        {/if}

        <Separator />

        <div class="flex items-center justify-between">
          <span class="text-muted-foreground">Member since</span>
          <span>{formatDate(data.user.createdAt)}</span>
        </div>
      </div>
    </section>

    <!-- Diagram stats -->
    <section class="rounded-lg border border-border bg-card p-5">
      <h2 class="mb-3 flex items-center gap-2 font-semibold">
        <ChartIcon class="size-5 text-muted-foreground" />
        Diagrams
      </h2>
      <div class="grid grid-cols-3 gap-4 text-center">
        <div class="rounded-md bg-muted/50 p-3">
          <div class="text-2xl font-bold">{data.stats.totalDiagrams}</div>
          <div class="text-xs text-muted-foreground">Total</div>
        </div>
        <div class="rounded-md bg-muted/50 p-3">
          <div class="flex items-center justify-center gap-1 text-2xl font-bold">
            <PublicIcon class="size-5 text-muted-foreground" />
            {data.stats.publicDiagrams}
          </div>
          <div class="text-xs text-muted-foreground">Public</div>
        </div>
        <div class="rounded-md bg-muted/50 p-3">
          <div class="flex items-center justify-center gap-1 text-2xl font-bold">
            <StarIcon class="size-5 text-yellow-500" />
            {data.stats.starredDiagrams}
          </div>
          <div class="text-xs text-muted-foreground">Starred</div>
        </div>
      </div>
      <div class="mt-3">
        <Button
          variant="outline"
          size="sm"
          class="w-full"
          onclick={() => (window.location.href = '/diagrams')}>
          View all diagrams
        </Button>
      </div>
    </section>

    <!-- Organizations -->
    <section class="rounded-lg border border-border bg-card p-5">
      <div class="mb-3 flex items-center justify-between">
        <h2 class="flex items-center gap-2 font-semibold">
          <OrgIcon class="size-5 text-muted-foreground" />
          Organizations
        </h2>
        <Button
          variant="outline"
          size="sm"
          class="h-7 gap-1 px-2 text-xs"
          onclick={() => (showCreateOrg = !showCreateOrg)}>
          <AddIcon class="size-3.5" />
          New
        </Button>
      </div>

      {#if showCreateOrg}
        <div class="mb-4 rounded-md border border-border bg-muted/30 p-4">
          <h3 class="mb-3 text-sm font-medium">Create organization</h3>
          <div class="space-y-3">
            <div>
              <label for="org-name" class="mb-1 block text-xs font-medium text-muted-foreground">
                Name
              </label>
              <Input
                id="org-name"
                type="text"
                placeholder="My Team"
                bind:value={orgName}
                oninput={handleOrgNameInput}
                maxlength={100}
                class="h-8 text-sm" />
            </div>
            <div>
              <label for="org-slug" class="mb-1 block text-xs font-medium text-muted-foreground">
                Slug
              </label>
              <Input
                id="org-slug"
                type="text"
                placeholder="my-team"
                bind:value={orgSlug}
                oninput={handleSlugInput}
                maxlength={48}
                class="h-8 font-mono text-sm" />
            </div>
            {#if orgError}
              <p class="text-xs text-destructive">{orgError}</p>
            {/if}
            <div class="flex gap-2">
              <Button size="sm" class="h-7 text-xs" disabled={orgCreating} onclick={createOrg}>
                {#if orgCreating}Creating...{:else}Create{/if}
              </Button>
              <Button
                variant="ghost"
                size="sm"
                class="h-7 text-xs"
                onclick={() => {
                  showCreateOrg = false;
                  orgName = '';
                  orgSlug = '';
                  orgError = '';
                  autoSlug = true;
                }}>
                Cancel
              </Button>
            </div>
          </div>
        </div>
      {/if}

      {#if data.organizations.length === 0 && !showCreateOrg}
        <p class="text-sm text-muted-foreground">You are not a member of any organization yet.</p>
      {:else}
        <div class="space-y-2">
          {#each data.organizations as org (org.id)}
            <a
              href="/orgs/{org.id}"
              class="flex items-center justify-between rounded-md border border-border px-3 py-2 text-sm no-underline transition-colors hover:bg-muted/50">
              <div>
                <span class="font-medium">{org.name}</span>
                <span class="ml-2 text-xs text-muted-foreground">@{org.slug}</span>
              </div>
              <span class="rounded-full bg-accent/10 px-2 py-0.5 text-xs text-accent capitalize">
                {org.role}
              </span>
            </a>
          {/each}
        </div>
      {/if}
    </section>

    <!-- Security -->
    <section class="rounded-lg border border-border bg-card p-5">
      <h2 class="mb-3 font-semibold">Security</h2>
      <div class="flex flex-col gap-2">
        <Button
          variant="outline"
          size="sm"
          onclick={() => (window.location.href = '/auth/forgot-password')}>
          Change password
        </Button>
      </div>
    </section>

    <!-- Sign out -->
    <div class="text-center">
      <Button
        variant="ghost"
        size="sm"
        class="text-muted-foreground"
        onclick={async () => {
          await authClient.signOut();
          window.location.href = '/edit';
        }}>
        Sign out
      </Button>
    </div>
  </main>
</div>
