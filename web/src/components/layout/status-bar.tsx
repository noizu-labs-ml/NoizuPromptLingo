interface StatusBarProps {
  entryCount: number;
  connectionCount: number;
  flagCount: number;
  lastSync?: string;
}

export function StatusBar({
  entryCount,
  connectionCount,
  flagCount,
  lastSync = "just now",
}: StatusBarProps) {
  return (
    <footer className="shrink-0 px-6 h-8 flex items-center border-t border-rule-subtle bg-surface">
      <p className="font-mono text-[11px] text-ink-tertiary tracking-[0.02em] flex items-center gap-3">
        <span>{entryCount.toLocaleString()} entries</span>
        <span className="text-rule-heavy">·</span>
        <span>{connectionCount.toLocaleString()} connections</span>
        <span className="text-rule-heavy">·</span>
        {flagCount > 0 ? (
          <span className="text-flag-warn">{flagCount} flags</span>
        ) : (
          <span>{flagCount} flags</span>
        )}
        <span className="text-rule-heavy">·</span>
        <span>Last sync {lastSync}</span>
      </p>
    </footer>
  );
}
