<script lang="ts">
  import Navbar from '$/components/Navbar.svelte';
  import FolderSidebar from '$/components/FolderSidebar.svelte';
  import DiagramFilters from '$/components/DiagramFilters.svelte';
  import DiagramGrid from '$/components/DiagramGrid.svelte';
  import { Button } from '$/components/ui/button';
  import { toast } from 'svelte-sonner';
  import AddIcon from '~icons/material-symbols/add-rounded';
  import { onMount } from 'svelte';
  import { SvelteURLSearchParams } from 'svelte/reactivity';
  import type { DiagramSummary } from '$/components/DiagramCard.svelte';
  import type { Folder } from '$/components/FolderSidebar.svelte';
  import type {
    ViewMode,
    SortField,
    SortDir,
    VisibilityFilter
  } from '$/components/DiagramFilters.svelte';

  // ─── State ──────────────────────────────────────────────────────────────────

  let diagrams: DiagramSummary[] = $state([]);
  let allFolders: Folder[] = $state([]);
  let viewMode: ViewMode = $state('grid');
  let searchQuery = $state('');
  let activeSearch = $state('');
  let sortField: SortField = $state('updatedAt');
  let sortDir: SortDir = $state('desc');
  let visibilityFilter: VisibilityFilter = $state('all');
  let showStarredOnly = $state(false);
  let activeFolderId: string | null = $state(null);
  let loading = $state(true);
  let page = $state(1);
  let hasMore = $state(false);

  // ─── Derived ────────────────────────────────────────────────────────────────

  let activeFolderName = $derived(
    activeFolderId ? (allFolders.find((f) => f.id === activeFolderId)?.name ?? 'Folder') : null
  );

  /** Folder summaries for DiagramCard move-to menu */
  let folderSummaries = $derived(allFolders.map((f) => ({ id: f.id, name: f.name })));

  /** First 6 root folders for mobile bar */
  let mobileFolders = $derived(
    allFolders
      .filter((f) => !f.parentId)
      .slice(0, 6)
      .map((f) => ({ id: f.id, name: f.name }))
  );

  /** Client-side sort + visibility filter on fetched diagrams */
  let sortedDiagrams = $derived.by(() => {
    let filtered = diagrams;

    // Visibility filter
    if (visibilityFilter !== 'all') {
      filtered = filtered.filter((d) => d.visibility === visibilityFilter);
    }

    const sorted = [...filtered];
    sorted.sort((a, b) => {
      let cmp = 0;
      if (sortField === 'title') {
        cmp = (a.title ?? '').localeCompare(b.title ?? '');
      } else if (sortField === 'starred') {
        // Starred first, then by updatedAt
        if (a.starred !== b.starred) return a.starred ? -1 : 1;
        cmp = new Date(a.updatedAt).getTime() - new Date(b.updatedAt).getTime();
        return -cmp; // newest first within group
      } else {
        cmp = new Date(a[sortField]).getTime() - new Date(b[sortField]).getTime();
      }
      return sortDir === 'desc' ? -cmp : cmp;
    });
    return sorted;
  });

  // ─── API calls ──────────────────────────────────────────────────────────────

  async function fetchDiagrams(append = false) {
    loading = true;
    try {
      const params = new SvelteURLSearchParams();
      params.set('page', String(page));
      params.set('limit', '40');
      if (activeFolderId) params.set('folder', activeFolderId);
      if (showStarredOnly) params.set('starred', 'true');
      if (activeSearch) params.set('q', activeSearch);

      const res = await fetch(`/api/diagrams?${params}`);
      if (!res.ok) {
        toast.error('Failed to load diagrams');
        return;
      }
      const data = await res.json();
      if (append) {
        diagrams = [...diagrams, ...data.diagrams];
      } else {
        diagrams = data.diagrams;
      }
      hasMore = data.diagrams.length === 40;
    } finally {
      loading = false;
    }
  }

  async function fetchFolders() {
    const res = await fetch('/api/folders');
    if (res.ok) {
      const data = await res.json();
      allFolders = data.folders;
    }
  }

  // ─── Diagram actions ───────────────────────────────────────────────────────

  function handleStar(diagram: DiagramSummary) {
    const newStarred = !diagram.starred;
    // Optimistic update
    diagrams = diagrams.map((d) => (d.id === diagram.id ? { ...d, starred: newStarred } : d));

    fetch(`/api/diagrams/${diagram.id}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ starred: newStarred })
    }).then((res) => {
      if (!res.ok) {
        diagrams = diagrams.map((d) => (d.id === diagram.id ? { ...d, starred: !newStarred } : d));
        toast.error('Failed to update star');
      }
    });
  }

  async function handleDelete(id: string) {
    const res = await fetch(`/api/diagrams/${id}`, { method: 'DELETE' });
    if (res.ok) {
      diagrams = diagrams.filter((d) => d.id !== id);
      toast.success('Diagram deleted');
    } else {
      toast.error('Failed to delete diagram');
    }
  }

  async function handleMove(diagramId: string, folderId: string | null) {
    const res = await fetch(`/api/diagrams/${diagramId}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ folderId })
    });
    if (res.ok) {
      if (activeFolderId !== folderId && activeFolderId !== null) {
        diagrams = diagrams.filter((d) => d.id !== diagramId);
      } else {
        diagrams = diagrams.map((d) => (d.id === diagramId ? { ...d, folderId } : d));
      }
      toast.success('Diagram moved');
    } else {
      toast.error('Failed to move diagram');
    }
  }

  // ─── Navigation ─────────────────────────────────────────────────────────────

  function selectFolder(id: string) {
    activeFolderId = id;
    showStarredOnly = false;
    page = 1;
    fetchDiagrams();
  }

  function selectStarred() {
    showStarredOnly = true;
    activeFolderId = null;
    page = 1;
    fetchDiagrams();
  }

  function selectAll() {
    showStarredOnly = false;
    activeFolderId = null;
    page = 1;
    fetchDiagrams();
  }

  function doSearch(query: string) {
    activeSearch = query.trim();
    page = 1;
    fetchDiagrams();
  }

  function clearSearch() {
    searchQuery = '';
    activeSearch = '';
    page = 1;
    fetchDiagrams();
  }

  function loadMore() {
    page += 1;
    fetchDiagrams(true);
  }

  // ─── Folder callbacks ──────────────────────────────────────────────────────

  function handleFolderCreated(folder: Folder) {
    allFolders = [...allFolders, folder];
  }

  function handleFolderRenamed(id: string, name: string) {
    allFolders = allFolders.map((f) => (f.id === id ? { ...f, name } : f));
  }

  function handleFolderDeleted(id: string) {
    allFolders = allFolders.filter((f) => f.id !== id);
    if (activeFolderId === id) {
      activeFolderId = null;
      page = 1;
      fetchDiagrams();
    }
  }

  // ─── Lifecycle ──────────────────────────────────────────────────────────────

  onMount(() => {
    fetchDiagrams();
    fetchFolders();
  });
</script>

<div class="flex h-full flex-col overflow-hidden">
  <Navbar hidePromotion>
    <Button variant="outline" size="sm" onclick={() => (window.location.href = '/edit')}>
      <AddIcon class="mr-1 size-4" />
      New Diagram
    </Button>
  </Navbar>

  <div class="flex flex-1 overflow-hidden">
    <FolderSidebar
      folders={allFolders}
      {activeFolderId}
      {showStarredOnly}
      onselectall={selectAll}
      onselectstarred={selectStarred}
      onselectfolder={selectFolder}
      onfoldercreated={handleFolderCreated}
      onfolderrenamed={handleFolderRenamed}
      onfolderdeleted={handleFolderDeleted} />

    <div class="flex flex-1 flex-col overflow-y-auto">
      <DiagramFilters
        {viewMode}
        {sortField}
        {sortDir}
        bind:searchQuery
        {activeSearch}
        {visibilityFilter}
        {showStarredOnly}
        {activeFolderId}
        {mobileFolders}
        onviewchange={(mode) => (viewMode = mode)}
        onsortfieldchange={(field) => (sortField = field)}
        onsortdirchange={() => (sortDir = sortDir === 'desc' ? 'asc' : 'desc')}
        onsearch={doSearch}
        onclearsearch={clearSearch}
        onvisibilitychange={(filter) => (visibilityFilter = filter)}
        onselectall={selectAll}
        onselectstarred={selectStarred}
        onselectfolder={selectFolder} />

      <DiagramGrid
        diagrams={sortedDiagrams}
        folders={folderSummaries}
        {viewMode}
        {loading}
        {hasMore}
        {showStarredOnly}
        {activeSearch}
        {activeFolderName}
        onstar={handleStar}
        ondelete={handleDelete}
        onmove={handleMove}
        onloadmore={loadMore} />
    </div>
  </div>
</div>
