<script lang="ts">
  import { Button } from '$/components/ui/button';
  import { Input } from '$/components/ui/input';
  import { authClient } from '$lib/auth-client';
  import { page } from '$app/stores';

  let inviteToken = $state($page.url.searchParams.get('token') ?? '');
  let email = $state('');
  let password = $state('');
  let name = $state('');
  let errorMsg = $state('');
  let loading = $state(false);

  async function handleSignup() {
    errorMsg = '';

    if (!inviteToken.trim()) {
      errorMsg = 'An invite token is required to sign up.';
      return;
    }
    if (!email.trim() || !password.trim()) {
      errorMsg = 'Email and password are required.';
      return;
    }
    if (password.length < 8) {
      errorMsg = 'Password must be at least 8 characters.';
      return;
    }

    loading = true;
    try {
      const res = await fetch('/api/auth/signup', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email,
          password,
          name: name || undefined,
          inviteToken: inviteToken.trim()
        })
      });

      if (!res.ok) {
        const data = await res.json().catch(() => null);
        errorMsg = data?.message || `Signup failed (${res.status})`;
        loading = false;
        return;
      }

      await authClient.signIn.email({ email, password, callbackURL: '/edit' });
    } catch (e: unknown) {
      errorMsg = e instanceof Error ? e.message : 'An unexpected error occurred.';
      loading = false;
    }
  }
</script>

<div class="rounded-lg border border-border bg-card p-6 shadow-sm">
  <div class="space-y-4">
    <div>
      <label for="invite-token" class="mb-1 block text-sm font-medium text-foreground">
        Invite Token
      </label>
      <Input
        id="invite-token"
        type="text"
        placeholder="Enter your invite token"
        bind:value={inviteToken}
        autocomplete="off" />
    </div>

    <div>
      <label for="name" class="mb-1 block text-sm font-medium text-foreground">
        Name <span class="text-muted-foreground">(optional)</span>
      </label>
      <Input id="name" type="text" placeholder="Your name" bind:value={name} autocomplete="name" />
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

    <div>
      <label for="password" class="mb-1 block text-sm font-medium text-foreground">Password</label>
      <Input
        id="password"
        type="password"
        placeholder="At least 8 characters"
        bind:value={password}
        autocomplete="new-password" />
    </div>

    {#if errorMsg}
      <p class="rounded bg-destructive/10 p-2 text-sm text-destructive">{errorMsg}</p>
    {/if}

    <Button class="w-full" size="lg" disabled={loading} onclick={handleSignup}>
      {#if loading}
        Creating account...
      {:else}
        Sign up
      {/if}
    </Button>
  </div>
</div>

<div class="space-y-2 text-center">
  <a href="/auth/login" class="text-sm text-muted-foreground hover:text-foreground">
    Already have an account? Sign in
  </a>
  <span class="mx-2 text-muted-foreground">·</span>
  <a href="/edit" class="text-sm text-muted-foreground hover:text-foreground">
    Continue without signing in
  </a>
</div>
