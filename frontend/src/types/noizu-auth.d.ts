// <noizu-auth> — tobor-kit sign-in/sign-up console, CDN-loaded client-side by
// src/components/tobor-auth.tsx (dropdown sign-in trigger + modal signup
// trigger in the site navbar). JSX intrinsic declaration so the custom
// element typechecks; attributes mirror tobor-kit's noizu-auth README.
import type * as React from "react";

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace React {
    // eslint-disable-next-line @typescript-eslint/no-namespace
    namespace JSX {
      interface IntrinsicElements {
        "noizu-auth": React.DetailedHTMLProps<
          React.HTMLAttributes<HTMLElement>,
          HTMLElement
        > & {
          transport?: string;
          "api-base"?: string;
          mode?: string;
          flow?: string;
          layout?: string;
          open?: boolean;
          [key: string]: unknown;
        };
      }
    }
  }
}
