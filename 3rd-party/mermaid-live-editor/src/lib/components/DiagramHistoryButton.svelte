<script lang="ts">
  import { Button } from '$/components/ui/button';
  import HistoryIcon from '~icons/material-symbols/history-rounded';

  interface Props {
    onclick: () => void;
  }

  let { onclick }: Props = $props();
</script>

<!--
  Standalone trigger button for the editor Navbar.
  Import from DiagramHistory.svelte via the named export:
    import { DiagramHistoryButton } from '$/components/DiagramHistory.svelte';
  Wire it to open the DiagramHistory dialog by toggling shared state.
-->
<Button size="sm" variant="ghost" {onclick} title="Diagram history">
  <HistoryIcon class="size-4" />
</Button>
