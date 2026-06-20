"use client";

// Route-level error boundary. Renders inside the root layout (navbar + chrome
// stay visible), so most errors are caught here rather than escalating to the
// global-error boundary.
import Link from "next/link";
import { StyleGuideBtn } from "@noizu/styleguide/components";

export default function Error({
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div className="content">
      <main>
        <h1 className="sg-page-title">Something went wrong</h1>
        <p className="sg-page-intro">
          An unexpected error occurred while loading this page. Try again, or
          return to the home page.
        </p>
        <div className="button-row sg-page-cta">
          <button onClick={() => reset()} className="sg-btn sg-btn--black">
            Try again
          </button>
          <Link href="/">
            <StyleGuideBtn variant="outline" label="Go home" />
          </Link>
        </div>
      </main>
    </div>
  );
}
