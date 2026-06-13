<script lang="ts">
  import { Button } from '$/components/ui/button';
  import { Input } from '$/components/ui/input';
  import { authClient } from '$lib/auth-client';
  import { goto } from '$app/navigation';

  const session = authClient.useSession();

  let handle = $state('');
  let error = $state('');
  let saving = $state(false);

  const handlePattern = /^[a-z0-9][a-z0-9-]{1,28}[a-z0-9]$/;

  async function saveHandle() {
    const normalized = handle.toLowerCase().trim();

    if (!handlePattern.test(normalized)) {
      error =
        'Handle must be 3-30 characters: lowercase letters, numbers, and hyphens. Must start and end with a letter or number.';
      return;
    }

    saving = true;
    error = '';

    try {
      const response = await fetch('/api/auth/profile/handle', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ handle: normalized })
      });

      if (!response.ok) {
        const data = await response.json();
        error = data.message ?? 'Failed to save handle';
        return;
      }

      await goto('/edit');
    } catch {
      error = 'Something went wrong. Please try again.';
    } finally {
      saving = false;
    }
  }
</script>

<div class="rounded-lg border border-border bg-card p-6 shadow-sm">
  <h2 class="mb-4 text-lg font-semibold">Complete your profile</h2>

  <form
    onsubmit={(e) => {
      e.preventDefault();
      saveHandle();
    }}
    class="space-y-4">
    <div class="space-y-2">
      <label for="handle" class="text-sm font-medium">Choose a handle</label>
      <div class="flex items-center gap-1">
        <span class="text-sm text-muted-foreground">@</span>
        <Input
          id="handle"
          type="text"
          placeholder="your-handle"
          bind:value={handle}
          maxlength={30}
          autocomplete="username" />
      </div>
      {#if error}
        <p class="text-sm text-destructive">{error}</p>
      {/if}
      <p class="text-xs text-muted-foreground">
        This is your public username for sharing diagrams.
      </p>
    </div>

    <Button class="w-full" type="submit" disabled={saving || !handle.trim()}>
      {#if saving}
        Saving...
      {:else}
        Save handle
      {/if}
    </Button>
  </form>
</div>

{#if !$session.data}
  <div class="text-center">
    <a href="/auth/login" class="text-sm text-muted-foreground hover:text-foreground">
      Sign in first
    </a>
  </div>
{/if}
