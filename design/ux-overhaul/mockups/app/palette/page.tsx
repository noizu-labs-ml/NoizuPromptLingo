import { CommandPalette } from "@/components/CommandPalette";

export default function PalettePage() {
  return (
    <main style={{ padding: "1rem" }}>
      <h1>Command palette (review)</h1>
      <p>Rendered open, for static review. In-app it opens with ⌘K and traps focus.</p>
      <CommandPalette open />
    </main>
  );
}
