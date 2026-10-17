// <noizu-page-comments> — tobor-kit annotate island, CDN-loaded once in the
// root layout (src/app/layout.tsx). JSX intrinsic declaration so the custom
// element typechecks.
import type * as React from "react";

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace React {
    // eslint-disable-next-line @typescript-eslint/no-namespace
    namespace JSX {
      interface IntrinsicElements {
        "noizu-page-comments": React.DetailedHTMLProps<
          React.HTMLAttributes<HTMLElement>,
          HTMLElement
        > & { [key: string]: unknown };
      }
    }
  }
}
