<script lang="ts">
  import { Button } from '$/components/ui/button';
  import { Input } from '$/components/ui/input';
  import { authClient } from '$lib/auth-client';

  let email = $state('');
  let sent = $state(false);
  let loading = $state(false);
  let errorMsg = $state('');

  async function sendMagicLink() {
    errorMsg = '';
    if (!email.trim()) {
      errorMsg = 'Please enter your email address.';
      return;
    }
    loading = true;
    try {
      const result = await authClient.signIn.magicLink({ email, callbackURL: '/edit' });
      if (result.error) {
        errorMsg = result.error.message || 'Failed to send magic link.';
      } else {
        sent = true;
      }
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
        We sent a sign-in link to <strong>{email}</strong>. Click it to log in — no password needed.
      </p>
      <p class="text-xs text-muted-foreground">The link expires in 10 minutes.</p>
      <div class="flex justify-center gap-2">
        <Button
          variant="outline"
          size="sm"
          onclick={() => {
            sent = false;
          }}>
          Try again
        </Button>
        <Button variant="outline" size="sm" onclick={() => (window.location.href = '/auth/login')}>
          Back to sign in
        </Button>
      </div>
    </div>
  {:else}
    <div class="space-y-4">
      <div>
        <h2 class="text-lg font-semibold">Sign in with magic link</h2>
        <p class="mt-1 text-sm text-muted-foreground">
          Enter your email and we'll send you a one-click sign-in link. No password required.
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

      <Button class="w-full" size="lg" disabled={loading} onclick={sendMagicLink}>
        {#if loading}
          Sending...
        {:else}
          Send magic link
        {/if}
      </Button>

      <div class="text-center">
        <a href="/auth/login" class="text-sm text-muted-foreground hover:text-foreground">
          Sign in with password instead
        </a>
      </div>
    </div>
  {/if}
</div>
