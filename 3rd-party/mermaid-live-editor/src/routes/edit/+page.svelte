<script lang="ts">
  import Actions from '$/components/Actions.svelte';
  import Card from '$/components/Card/Card.svelte';
  import DiagramDetails from '$/components/DiagramDetails.svelte';
  import DiagramDocButton from '$/components/DiagramDocumentationButton.svelte';
  import Editor from '$/components/Editor.svelte';
  import EnhancedEditsButton from '$/components/EnhancedEditsButton.svelte';
  import History from '$/components/History/History.svelte';
  import SaveDiagram from '$/components/SaveDiagram.svelte';
  import EditorChooserModal from '$/components/migration/EditorChooserModal.svelte';
  import { env } from '$/util/env';
  import Navbar from '$/components/Navbar.svelte';
  import PanZoomToolbar from '$/components/PanZoomToolbar.svelte';
  import Preset from '$/components/Preset.svelte';
  import Share from '$/components/Share.svelte';
  import SyncRoughToolbar from '$/components/SyncRoughToolbar.svelte';
  import * as Resizable from '$/components/ui/resizable';
  import { Switch } from '$/components/ui/switch';
  import { Toggle } from '$/components/ui/toggle';
  import VersionSecurityToolbar from '$/components/VersionSecurityToolbar.svelte';
  import View from '$/components/View.svelte';
  import type { EditorMode, Tab } from '$/types';
  import { shouldShowEditorChooser } from '$/util/migration/domainMigration';
  import { PanZoomState } from '$/util/panZoom';
  import { stateStore, updateCodeStore } from '$/util/state';
  import { logEvent } from '$/util/stats';
  import { initHandler } from '$/util/util';
  import { onMount } from 'svelte';
  import CodeIcon from '~icons/custom/code';
  import HistoryIcon from '~icons/material-symbols/history';
  import GearIcon from '~icons/material-symbols/settings-outline-rounded';
  import DetailsIcon from '~icons/material-symbols/tune-rounded';

  const panZoomState = new PanZoomState();

  // ─── Active diagram tracking ───────────────────────────────────────────────
  // When a diagram is saved via SaveDiagram, we track its ID/metadata here
  // so the Details tab can display and PATCH the diagram's metadata.

  let activeDiagram: {
    id: string;
    title: string | null;
    description: string | null;
    tags: string[];
    visibility: string;
  } | null = $state(null);

  let activeTab = $state<string>('code');

  const tabSelectHandler = (tab: Tab) => {
    activeTab = tab.id;
    if (tab.id === 'code' || tab.id === 'config') {
      const editorMode: EditorMode = tab.id === 'code' ? 'code' : 'config';
      updateCodeStore({ editorMode });
    }
  };

  const editorTabs: Tab[] = [
    {
      icon: CodeIcon,
      id: 'code',
      title: 'Code'
    },
    {
      icon: GearIcon,
      id: 'config',
      title: 'Config'
    },
    {
      icon: DetailsIcon,
      id: 'details',
      title: 'Details'
    }
  ];

  // Derive the active tab ID for the Card component (map 'details' back to editor mode)
  let cardActiveTab = $derived(activeTab === 'details' ? 'details' : $stateStore.editorMode);

  let width = $state(0);
  let isMobile = $derived(width < 640);
  let isViewMode = $state(true);
  let showEditorChooser = $state(false);

  onMount(async () => {
    showEditorChooser = shouldShowEditorChooser();
    await initHandler();
    window.addEventListener('appinstalled', () => {
      logEvent('pwaInstalled', { isMobile });
    });
  });

  let isHistoryOpen = $state(false);

  let editorPane: Resizable.Pane | undefined;
  $effect(() => {
    if (isMobile) {
      editorPane?.resize(50);
    }
  });

  /**
   * Called after a diagram is saved/updated via SaveDiagram.
   * Populates the active diagram so the Details tab can edit metadata.
   */
  function handleDiagramSaved(diagram: {
    id: string;
    title?: string | null;
    description?: string | null;
    tags?: string[];
    visibility?: string;
  }) {
    activeDiagram = {
      description: diagram.description ?? null,
      id: diagram.id,
      tags: diagram.tags ?? [],
      title: diagram.title ?? null,
      visibility: diagram.visibility ?? 'unlisted'
    };
  }
</script>

<div class="flex h-full flex-col overflow-hidden">
  {#snippet mobileToggle()}
    <div class="flex items-center gap-2">
      Edit <Switch
        id="editorMode"
        class="data-[state=checked]:bg-accent"
        bind:checked={isViewMode}
        onclick={() => {
          logEvent('mobileViewToggle');
        }} /> View
    </div>
  {/snippet}

  <Navbar mobileToggle={isMobile ? mobileToggle : undefined}>
    <Toggle bind:pressed={isHistoryOpen} size="sm">
      <HistoryIcon />
    </Toggle>
    <Share />
    <SaveDiagram onsave={handleDiagramSaved} />
  </Navbar>

  <div class="flex flex-1 flex-col overflow-hidden" bind:clientWidth={width}>
    <div
      class={[
        'size-full',
        isMobile && ['w-[200%] duration-300', isViewMode && '-translate-x-1/2']
      ]}>
      <Resizable.PaneGroup
        direction="horizontal"
        autoSaveId="liveEditor"
        class="gap-4 p-2 pt-0 sm:gap-0 sm:p-6 sm:pt-0">
        <Resizable.Pane bind:this={editorPane} defaultSize={30} minSize={15}>
          <div class="flex h-full flex-col gap-4 sm:gap-6">
            <Card
              onselect={tabSelectHandler}
              isOpen
              tabs={editorTabs}
              activeTabID={cardActiveTab}
              isClosable={false}>
              {#snippet actions()}
                <DiagramDocButton />
              {/snippet}
              {#if activeTab === 'details'}
                {#if activeDiagram}
                  <DiagramDetails diagram={activeDiagram} />
                {:else}
                  <div
                    class="flex h-full items-center justify-center p-6 text-sm text-muted-foreground">
                    Save your diagram first to edit its details.
                  </div>
                {/if}
              {:else}
                <Editor {isMobile} />
              {/if}
            </Card>

            <div class="group flex flex-wrap justify-between gap-4 sm:gap-6">
              <Preset />
              <Actions />
            </div>
          </div>
        </Resizable.Pane>
        <Resizable.Handle class="mr-1 hidden opacity-0 sm:block" />
        <Resizable.Pane minSize={15} class="relative flex h-full flex-1 flex-col overflow-hidden">
          <View {panZoomState} shouldShowGrid={$stateStore.grid} />
          {#if !env.hidePromotions}<div class="absolute top-0 left-5 hidden md:block">
              <EnhancedEditsButton />
            </div>{/if}
          <div class="absolute top-0 right-0"><PanZoomToolbar {panZoomState} /></div>
          <div class="absolute right-0 bottom-0"><VersionSecurityToolbar /></div>
          <div class="absolute bottom-0 left-0 sm:left-5"><SyncRoughToolbar /></div>
        </Resizable.Pane>
        {#if isHistoryOpen}
          <Resizable.Handle class="ml-1 hidden opacity-0 sm:block" />
          <Resizable.Pane minSize={15} defaultSize={30} class="hidden h-full grow flex-col sm:flex">
            <History />
          </Resizable.Pane>
        {/if}
      </Resizable.PaneGroup>
    </div>
  </div>
</div>

{#if !env.hidePromotions}<EditorChooserModal bind:open={showEditorChooser} />{/if}
