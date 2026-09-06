import { paletteActions } from "@/lib/fixtures";

export function CommandPalette({ open = true }: { open?: boolean }) {
  return (
    <dialog open={open} aria-label="Command palette" className="dialog-panel">
      <form method="dialog">
        <label>
          <span className="sr-only">Command</span>
          <input type="text" placeholder="Type a command or search…" autoFocus style={{ width: "100%" }} />
        </label>
        <ul>
          {paletteActions.map((a) => (
            <li key={a.id}>
              <button type="button" style={{ width: "100%", textAlign: "left" }}>
                {a.label} {a.hint && <span className="chip">{a.hint}</span>}
              </button>
            </li>
          ))}
        </ul>
        <button type="submit">Close</button>
      </form>
    </dialog>
  );
}
