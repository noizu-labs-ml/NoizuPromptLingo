<script lang="ts">
  import { Button } from '$/components/ui/button';
  import { Input } from '$/components/ui/input';
  import { authClient } from '$lib/auth-client';

  let email = $state('');
  let sent = $state(false);
  let loading = $state(false);
  let errorMsg = $state('');

  async function requestReset() {
    errorMsg = '';
    if (!email.trim()) {
      errorMsg = 'Please enter your email address.';
      return;
    }
    loading = true;
    try {
      await authClient.forgetPassword({ email, redirectTo: '/auth/reset-password' });
      sent = true;
    } catch {
      errorMsg = 'Something went wrong. Please try again.';
    } finally {
      loading = false;
    }
  }
</script>

<div class="rounded-lg border border-border bg-card p-6 shadow-sm">
  {#if sent}
    <div class="space-y-3 text-center">
      <h2 class="text-lg font-semibold">Check your email</h2>
      <p class="text-sm text-muted-foreground">
        If an account exists for <strong>{email}</strong>, we've sent a password reset link.
      </p>
      <Button variant="outline" size="sm" onclick={() => (window.location.href = '/auth/login')}>
        Back to sign in
      </Button>
    </div>
  {:else}
    <div class="space-y-4">
      <div>
        <h2 class="text-lg font-semibold">Forgot your password?</h2>
        <p class="mt-1 text-sm text-muted-foreground">
          Enter your email and we'll send you a reset link.
        </p>
      </div>

      <div>
        <label for="email" class="mb-1 block text-sm font-medium text-foreground">Email</label>
        <Input
          id="email"
          type="email"
          placeholder="you@example.com"
          bind:value={email}
          autocomplete="email" />
      </div>

      {#if errorMsg}
        <p class="rounded bg-destructive/10 p-2 text-sm text-destructive">{errorMsg}</p>
      {/if}

      <Button class="w-full" size="lg" disabled={loading} onclick={requestReset}>
        {#if loading}
          Sending...
        {:else}
          Send reset link
        {/if}
      </Button>

      <div class="text-center">
        <a href="/auth/login" class="text-sm text-muted-foreground hover:text-foreground">
          Back to sign in
        </a>
      </div>
    </div>
  {/if}
</div>
