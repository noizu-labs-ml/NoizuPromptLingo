export function Header() {
  return (
    <header className="fixed top-0 left-0 right-0 z-50 bg-bg-surface/85 backdrop-blur-md">
      <div className="mx-auto flex h-16 max-w-content items-center justify-between px-6">
        <a href="/" className="flex items-center gap-1 font-display text-lg font-bold tracking-tight">
          <span className="text-text-primary">Robots</span>
          <span className="text-orange">Unite</span>
        </a>

        <nav className="hidden items-center gap-8 text-sm font-body text-text-secondary md:flex">
          <a
            href="#how-it-works"
            className="transition-colors duration-200 hover:text-text-primary"
          >
            How It Works
          </a>
          <a
            href="#features"
            className="transition-colors duration-200 hover:text-text-primary"
          >
            Features
          </a>
          <a
            href="#leaderboard"
            className="transition-colors duration-200 hover:text-text-primary"
          >
            Leaderboard
          </a>
        </nav>

        <a
          href="#waitlist"
          className="rounded-md bg-orange px-4 py-2 text-sm font-medium text-white transition-colors duration-200 hover:bg-orange-hover"
        >
          Join Waitlist
        </a>
      </div>
    </header>
  );
}
