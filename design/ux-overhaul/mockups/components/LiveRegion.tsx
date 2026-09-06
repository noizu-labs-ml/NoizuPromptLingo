export function LiveRegion({ message, assertive = false }: { message?: string; assertive?: boolean }) {
  return (
    <div
      aria-live={assertive ? "assertive" : "polite"}
      aria-atomic="true"
      className="sr-only"
      data-testid="live-region"
    >
      {message}
    </div>
  );
}
