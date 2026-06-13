<script lang="ts">
  import { Button } from '$/components/ui/button';
  import { authClient } from '$lib/auth-client';

  let loading = $state(false);

  async function signInWithAuthentik() {
    loading = true;
    await authClient.signIn.social({
      provider: 'authentik',
      callbackURL: '/edit'
    });
  }
</script>

<div class="rounded-lg border border-border bg-card p-6 shadow-sm">
  <div class="space-y-4">
    <Button class="w-full" size="lg" disabled={loading} onclick={signInWithAuthentik}>
      {#if loading}
        Redirecting...
      {:else}
        Sign in
      {/if}
    </Button>

    <p class="text-center text-xs text-muted-foreground">
      Sign in with your email, Google, or GitHub account via our identity provider.
    </p>
  </div>
</div>

<div class="text-center">
  <a href="/edit" class="text-sm text-muted-foreground hover:text-foreground">
    Continue without signing in
  </a>
</div>
