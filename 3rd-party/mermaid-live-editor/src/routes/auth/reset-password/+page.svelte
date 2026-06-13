<script lang="ts">
  import { Button } from '$/components/ui/button';
  import { Input } from '$/components/ui/input';
  import { authClient } from '$lib/auth-client';
  import { page } from '$app/stores';

  let password = $state('');
  let confirmPassword = $state('');
  let loading = $state(false);
  let errorMsg = $state('');
  let success = $state(false);

  let token = $derived(new URL($page.url).searchParams.get('token') ?? '');

  async function resetPassword() {
    errorMsg = '';

    if (!token) {
      errorMsg = 'Invalid or expired reset link. Please request a new one.';
      return;
    }

    if (password.length < 8) {
      errorMsg = 'Password must be at least 8 characters.';
      return;
    }

    if (password !== confirmPassword) {
      errorMsg = 'Passwords do not match.';
      return;
    }

    loading = true;
    try {
      const result = await authClient.resetPassword({ newPassword: password, token });
      if (result.error) {
        errorMsg = result.error.message || 'Failed to reset password.';
      } else {
        success = true;
      }
    } catch {
      errorMsg = 'Something went wrong. Please try again.';
    } finally {
      loading = false;
    }
  }
</script>

<div class="rounded-lg border border-border bg-card p-6 shadow-sm">
  {#if success}
    <div class="space-y-3 text-center">
      <h2 class="text-lg font-semibold">Password reset</h2>
      <p class="text-sm text-muted-foreground">
        Your password has been updated. You can now sign in.
      </p>
      <Button size="lg" class="w-full" onclick={() => (window.location.href = '/auth/login')}>
        Sign in
      </Button>
    </div>
  {:else}
    <div class="space-y-4">
      <div>
        <h2 class="text-lg font-semibold">Set a new password</h2>
        <p class="mt-1 text-sm text-muted-foreground">
          Choose a strong password with at least 8 characters.
        </p>
      </div>

      <div>
        <label for="password" class="mb-1 block text-sm font-medium text-foreground">
          New password
        </label>
        <Input
          id="password"
          type="password"
          placeholder="At least 8 characters"
          bind:value={password}
          autocomplete="new-password" />
      </div>

      <div>
        <label for="confirm-password" class="mb-1 block text-sm font-medium text-foreground">
          Confirm password
        </label>
        <Input
          id="confirm-password"
          type="password"
          placeholder="Repeat your password"
          bind:value={confirmPassword}
          autocomplete="new-password" />
      </div>

      {#if errorMsg}
        <p class="rounded bg-destructive/10 p-2 text-sm text-destructive">{errorMsg}</p>
      {/if}

      <Button class="w-full" size="lg" disabled={loading} onclick={resetPassword}>
        {#if loading}
          Resetting...
        {:else}
          Reset password
        {/if}
      </Button>
    </div>
  {/if}
</div>
