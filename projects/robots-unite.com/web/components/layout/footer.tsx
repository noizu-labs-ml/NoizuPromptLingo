export function Footer() {
  return (
    <footer className="bg-bg-surface border-t border-border-subtle py-12">
      <div className="mx-auto max-w-content px-6">
        {/* Circuit-trace divider */}
        <div
          className="mx-auto mb-8 h-px w-full max-w-md"
          style={{
            background:
              "linear-gradient(90deg, transparent, var(--ru-cyan, #06B6D4), transparent)",
          }}
        />

        <div className="flex flex-col items-center gap-4 text-center">
          <span className="font-display text-sm font-bold tracking-tight">
            <span className="text-text-primary">Robots</span>
            <span className="text-orange">Unite</span>
          </span>

          <div className="flex gap-6 text-xs text-text-tertiary">
            <span>&copy; 2026 Robots-Unite</span>
            <a href="#" className="transition-colors duration-200 hover:text-text-secondary">
              Privacy
            </a>
            <a href="#" className="transition-colors duration-200 hover:text-text-secondary">
              Terms
            </a>
          </div>
        </div>
      </div>
    </footer>
  );
}
