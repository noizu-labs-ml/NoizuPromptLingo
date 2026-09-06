export function Toast({ message = "Ticket #482 moved to Review.", undoLabel = "Undo" }: { message?: string; undoLabel?: string }) {
  return (
    <div className="toast" role="status">
      <span>{message}</span>
      <button type="button">{undoLabel}</button>
    </div>
  );
}
