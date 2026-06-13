<script lang="ts">
  import { Button } from '$/components/ui/button';
  import * as Dialog from '$/components/ui/dialog';
  import { Input } from '$/components/ui/input';
  import { authClient } from '$lib/auth-client';
  import { stateStore } from '$/util/state';
  import { toast } from 'svelte-sonner';
  import SaveIcon from '~icons/material-symbols/save-outline-rounded';

  interface Props {
    onsave?: (diagram: {
      id: string;
      title?: string | null;
      description?: string | null;
      tags?: string[];
      visibility?: string;
    }) => void;
  }

  let { onsave }: Props = $props();

  const session = authClient.useSession();

  type Visibility = 'private' | 'unlisted' | 'public';

  let open = $state(false);
  let title = $state('');
  let description = $state('');
  let tagInput = $state('');
  let visibility: Visibility = $state('unlisted');
  let saving = $state(false);
  let savedId: string | null = $state(null);
  let shortLink = $state('');

  let activeDiagramId: string | null = $state(null);

  let parsedTags = $derived(
    tagInput
      .split(',')
      .map((t) => t.trim().toLowerCase())
      .filter((t) => t.length > 0)
      .slice(0, 20)
  );

  // Project selection
  let projects: { id: string; name: string }[] = $state([]);
  let selectedProjectId: string | null = $state(null);
  let projectLinkType: 'linked' | 'clone' = $state('linked');

  function removeTag(tag: string) {
    const tags = parsedTags.filter((t) => t !== tag);
    tagInput = tags.join(', ');
  }

  function extractTitle(code: string): string {
    const firstLine = code.trim().split('\n')[0] ?? '';
    const cleaned = firstLine
      .replace(/^---.*---$/s, '')
      .replace(
        /^(graph|flowchart|sequenceDiagram|classDiagram|stateDiagram|erDiagram|gantt|pie|journey|gitGraph|mindmap|timeline|sankey|block|xychart|packet|architecture|kanban|quadrantChart)\b/i,
        ''
      )
      .trim();
    return cleaned.slice(0, 100) || 'Untitled Diagram';
  }

  function captureThumbnail(): string | null {
    try {
      const svgEl = document.querySelector('#mermaid-diagram svg, #view svg, .mermaid svg');
      if (!svgEl) return null;
      const clone = svgEl.cloneNode(true) as SVGElement;
      if (!clone.getAttribute('viewBox')) {
        const bbox = (svgEl as SVGSVGElement).getBBox?.();
        if (bbox) {
          clone.setAttribute('viewBox', `${bbox.x} ${bbox.y} ${bbox.width} ${bbox.height}`);
        }
      }
      clone.setAttribute('width', '400');
      clone.setAttribute('height', '300');
      return new XMLSerializer().serializeToString(clone);
    } catch {
      return null;
    }
  }

  async function fetchProjects() {
    try {
      const res = await fetch('/api/projects');
      if (res.ok) {
        const data = await res.json();
        projects = data.projects ?? [];
      }
    } catch {
      // Projects are optional
    }
  }

  async function save() {
    saving = true;

    try {
      const state = $stateStore;
      const thumbnail = captureThumbnail();
      const body: Record<string, unknown> = {
        code: state.code,
        config: state.mermaid,
        description: description.trim() || undefined,
        tags: parsedTags.length > 0 ? parsedTags : undefined,
        thumbnail,
        title: title.trim() || extractTitle(state.code),
        visibility
      };

      let response: Response;

      if (activeDiagramId) {
        response = await fetch(`/api/diagrams/${activeDiagramId}`, {
          method: 'PATCH',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(body)
        });
      } else {
        response = await fetch('/api/diagrams', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(body)
        });
      }

      if (!response.ok) {
        const data = await response.json().catch(() => ({}));
        toast.error(data.message ?? 'Failed to save diagram');
        return;
      }

      const diagram = await response.json();
      savedId = diagram.id;
      activeDiagramId = diagram.id;
      shortLink = `${window.location.origin}/d/${diagram.id}`;

      // Add to project if selected
      if (selectedProjectId && diagram.id) {
        try {
          await fetch(`/api/projects/${selectedProjectId}/diagrams`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ diagramId: diagram.id, linkType: projectLinkType })
          });
        } catch {
          // Non-critical — diagram is saved regardless
        }
      }

      toast.success(activeDiagramId ? 'Diagram updated' : 'Diagram saved');

      onsave?.({
        description: diagram.description,
        id: diagram.id,
        tags: Array.isArray(diagram.tags) ? diagram.tags : [],
        title: diagram.title,
        visibility: diagram.visibility
      });
    } catch {
      toast.error('Something went wrong. Please try again.');
    } finally {
      saving = false;
    }
  }

  function copyLink() {
    if (shortLink) {
      navigator.clipboard.writeText(shortLink);
      toast.success('Link copied to clipboard');
    }
  }

  function handleOpen() {
    if (!$session.data?.user) {
      window.location.href = '/auth/login?redirect=/edit';
      return;
    }
    title = title || extractTitle($stateStore.code);
    fetchProjects();
    open = true;
  }
</script>

<Dialog.Root bind:open>
  <Button size="sm" onclick={handleOpen}>
    <SaveIcon class="mr-1 size-4" />
    {#if activeDiagramId}
      Update
    {:else}
      Save
    {/if}
  </Button>

  <Dialog.Content class="max-h-[85vh] overflow-y-auto">
    <Dialog.Header>
      <Dialog.Title class="flex items-center gap-2 text-xl">
        <SaveIcon class="size-5" />
        {#if savedId}
          Diagram Saved
        {:else if activeDiagramId}
          Update Diagram
        {:else}
          Save Diagram
        {/if}
      </Dialog.Title>
      <Dialog.Description>
        {#if savedId}
          Share your diagram with this link.
        {:else}
          Save to your account and get a short share link.
        {/if}
      </Dialog.Description>
    </Dialog.Header>

    {#if savedId}
      <div class="flex flex-col gap-4">
        <div class="flex items-center gap-2">
          <Input value={shortLink} readonly class="font-mono text-sm" />
          <Button size="sm" onclick={copyLink}>Copy</Button>
        </div>
        <div class="flex gap-2">
          <Button
            variant="outline"
            size="sm"
            class="flex-1"
            onclick={() => {
              savedId = null;
            }}>
            Edit details
          </Button>
          <Button
            size="sm"
            class="flex-1"
            onclick={() => {
              open = false;
              savedId = null;
            }}>
            Done
          </Button>
        </div>
      </div>
    {:else}
      <form
        class="flex flex-col gap-4"
        onsubmit={(e) => {
          e.preventDefault();
          save();
        }}>
        <div class="flex flex-col gap-2">
          <label for="diagram-title" class="text-sm font-medium">Title</label>
          <Input
            id="diagram-title"
            type="text"
            placeholder="My Diagram"
            bind:value={title}
            maxlength={200} />
        </div>

        <div class="flex flex-col gap-2">
          <label for="diagram-desc" class="text-sm font-medium">
            Description <span class="text-muted-foreground">(optional)</span>
          </label>
          <textarea
            id="diagram-desc"
            class="flex min-h-[60px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none"
            placeholder="What this diagram shows..."
            bind:value={description}
            maxlength={2000}></textarea>
        </div>

        <div class="flex flex-col gap-2">
          <label for="diagram-tags" class="text-sm font-medium">
            Tags <span class="text-muted-foreground">(optional)</span>
          </label>
          <Input
            id="diagram-tags"
            type="text"
            placeholder="architecture, backend, api (comma-separated)"
            bind:value={tagInput}
            maxlength={500} />
          {#if parsedTags.length > 0}
            <div class="flex flex-wrap gap-1">
              {#each parsedTags as tag (tag)}
                <span
                  class="inline-flex items-center rounded-full bg-accent/10 px-2 py-0.5 text-xs text-accent">
                  {tag}
                  <button
                    type="button"
                    class="ml-1 text-accent/70 hover:text-accent"
                    onclick={() => removeTag(tag)}>×</button>
                </span>
              {/each}
            </div>
          {/if}
        </div>

        {#if projects.length > 0}
          <div class="flex flex-col gap-2">
            <label for="diagram-project" class="text-sm font-medium">
              Project <span class="text-muted-foreground">(optional)</span>
            </label>
            <select
              id="diagram-project"
              class="flex h-9 w-full rounded-md border border-input bg-background px-3 py-1 text-sm shadow-sm transition-colors focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none"
              bind:value={selectedProjectId}>
              <option value={null}>None</option>
              {#each projects as project (project.id)}
                <option value={project.id}>
                  {project.name}
                </option>
              {/each}
            </select>
            {#if selectedProjectId}
              <div class="flex gap-2 text-xs">
                <label class="flex items-center gap-1">
                  <input
                    type="radio"
                    bind:group={projectLinkType}
                    value="linked"
                    class="accent-accent" />
                  Link (same diagram)
                </label>
                <label class="flex items-center gap-1">
                  <input
                    type="radio"
                    bind:group={projectLinkType}
                    value="clone"
                    class="accent-accent" />
                  Clone (independent copy)
                </label>
              </div>
            {/if}
          </div>
        {/if}

        <div class="flex flex-col gap-2">
          <label class="text-sm font-medium">Visibility</label>
          <div class="flex gap-2">
            {#each ['private', 'unlisted', 'public'] as v (v)}
              <button
                type="button"
                class="flex-1 rounded-md border px-3 py-2 text-sm transition-colors {visibility ===
                v
                  ? 'border-accent bg-accent/10 text-accent'
                  : 'border-border text-muted-foreground hover:border-accent/50'}"
                onclick={() => (visibility = v as Visibility)}>
                <div class="font-medium capitalize">{v}</div>
                <div class="text-xs opacity-70">
                  {#if v === 'private'}
                    Only you
                  {:else if v === 'unlisted'}
                    Anyone with link
                  {:else}
                    Everyone
                  {/if}
                </div>
              </button>
            {/each}
          </div>
        </div>

        <Button type="submit" disabled={saving} class="w-full">
          {#if saving}
            Saving...
          {:else if activeDiagramId}
            Update diagram
          {:else}
            Save & get link
          {/if}
        </Button>
      </form>
    {/if}
  </Dialog.Content>
</Dialog.Root>
