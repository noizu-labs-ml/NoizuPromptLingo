<script lang="ts">
  import { Button } from '$/components/ui/button';
  import { Input } from '$/components/ui/input';
  import { authClient } from '$lib/auth-client';

  let email = $state('');
  let password = $state('');
  let errorMsg = $state('');
  let loading = $state(false);
  let oauthLoading = $state(false);

  async function signInWithEmail() {
    errorMsg = '';
    if (!email.trim() || !password.trim()) {
      errorMsg = 'Email and password are required.';
      return;
    }
    loading = true;
    try {
      const result = await authClient.signIn.email({
        email,
        password,
        callbackURL: '/edit'
      });
      if (result.error) {
        errorMsg = result.error.message || 'Invalid email or password.';
        loading = false;
      }
    } catch (e: unknown) {
      errorMsg = e instanceof Error ? e.message : 'Sign in failed.';
      loading = false;
    }
  }

  async function signInWithAuthentik() {
    oauthLoading = true;
    await authClient.signIn.social({
      provider: 'authentik',
      callbackURL: '/edit'
    });
  }
</script>

<div class="rounded-lg border border-border bg-card p-6 shadow-sm">
  <div class="space-y-4">
    <div>
      <label for="email" class="mb-1 block text-sm font-medium text-foreground">Email</label>
      <Input
        id="email"
        type="email"
        placeholder="you@example.com"
        bind:value={email}
        autocomplete="email" />
    </div>

    <div>
      <div class="mb-1 flex items-center justify-between">
        <label for="password" class="text-sm font-medium text-foreground">Password</label>
        <a href="/auth/forgot-password" class="text-xs text-muted-foreground hover:text-accent">
          Forgot password?
        </a>
      </div>
      <Input
        id="password"
        type="password"
        placeholder="Your password"
        bind:value={password}
        autocomplete="current-password" />
    </div>

    {#if errorMsg}
      <p class="rounded bg-destructive/10 p-2 text-sm text-destructive">{errorMsg}</p>
    {/if}

    <Button class="w-full" size="lg" disabled={loading} onclick={signInWithEmail}>
      {#if loading}
        Signing in...
      {:else}
        Sign in
      {/if}
    </Button>

    <div class="relative">
      <div class="absolute inset-0 flex items-center">
        <span class="w-full border-t border-border"></span>
      </div>
      <div class="relative flex justify-center text-xs uppercase">
        <span class="bg-card px-2 text-muted-foreground">or</span>
      </div>
    </div>

    <div class="flex flex-col gap-2">
      <Button
        class="w-full"
        variant="outline"
        size="lg"
        onclick={() => (window.location.href = '/auth/magic-link')}>
        Sign in with magic link
      </Button>

      <Button
        class="w-full"
        variant="outline"
        size="lg"
        disabled={oauthLoading}
        onclick={signInWithAuthentik}>
        {#if oauthLoading}
          Redirecting...
        {:else}
          Sign in with SSO
        {/if}
      </Button>
    </div>
  </div>
</div>

<div class="space-y-2 text-center">
  <a href="/auth/signup" class="text-sm text-muted-foreground hover:text-foreground">
    Have an invite? Sign up
  </a>
  <span class="mx-2 text-muted-foreground">&middot;</span>
  <a href="/edit" class="text-sm text-muted-foreground hover:text-foreground">
    Continue without signing in
  </a>
</div>
