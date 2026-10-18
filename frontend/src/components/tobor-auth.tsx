"use client";

import { useEffect, useRef, useState } from "react";
import { api } from "@/lib/api";

// tobor-kit sign-in/sign-up console (shadow-DOM layout="console"), loaded
// once from the CDN — same island pattern as the root layout's annotate
// widget, but mounted per-trigger here so it lives next to the buttons.
// SSO buttons only: Authentik owns email/password, so no local credential
// pipes are ever enabled — the console renders exactly the social redirect
// providers the backend advertises via GET /api/v1/auth/config.
const AUTH_CDN_URL =
  "https://cdn.derobot.is/tobor-kit/latest/components/auth/noizu-auth.js";

// Component pipe ids in canonical order. The "authentik" pipe resolves
// against a provider published as "authentik" or "oidc"; our backend
// publishes the Authentik IdP under the id "oidc".
const SOCIAL_PIPES = ["google", "authentik", "github"] as const;
const PIPE_TO_PROVIDER: Record<(typeof SOCIAL_PIPES)[number], string> = {
  google: "google",
  authentik: "oidc",
  github: "github",
};

let cdnLoad: Promise<void> | null = null;

function loadToborAuth(): Promise<void> {
  if (typeof window === "undefined") return Promise.resolve();
  if (customElements.get("noizu-auth")) return Promise.resolve();

  if (!cdnLoad) {
    cdnLoad = new Promise<void>((resolve, reject) => {
      const script = document.createElement("script");
      script.type = "module";
      script.src = AUTH_CDN_URL;
      script.async = true;
      // Fires after module evaluation, so customElements.define has run.
      script.addEventListener("load", () => resolve());
      script.addEventListener("error", () => {
        cdnLoad = null;
        reject(new Error("Failed to load tobor-kit auth component"));
      });
      document.head.appendChild(script);
    });
  }

  return cdnLoad;
}

type AuthPipes = string[];

export function ToborAuthTriggers() {
  const [ready, setReady] = useState(false);
  const [pipes, setPipes] = useState<AuthPipes | null>(null);
  const signInRef = useRef<HTMLElement | null>(null);
  const signUpRef = useRef<HTMLElement | null>(null);

  useEffect(() => {
    let cancelled = false;

    loadToborAuth().then(
      () => {
        if (!cancelled) setReady(true);
      },
      () => {
        // CDN unreachable: permanent fallback to the plain /login anchors.
        if (!cancelled) setReady(false);
      },
    );

    api
      .authConfig()
      .then((config) => {
        if (cancelled) return;
        const enabled = new Set((config.providers ?? []).map((p) => p.id));
        const social = SOCIAL_PIPES.filter((pipe) =>
          enabled.has(PIPE_TO_PROVIDER[pipe]),
        );
        setPipes(social);
      })
      .catch(() => {
        // Config unavailable → no enabled pipes → keep the plain anchors
        // (never render buttons for disabled providers).
        if (!cancelled) setPipes([]);
      });

    return () => {
      cancelled = true;
    };
  }, []);

  // `.pipes` is an object property (not an attribute) — set it after the
  // element has upgraded (ready) so Lit's accessor is on the prototype.
  useEffect(() => {
    if (!ready || !pipes) return;
    for (const el of [signInRef.current, signUpRef.current]) {
      if (el) (el as HTMLElement & { pipes?: AuthPipes }).pipes = pipes;
    }
  }, [ready, pipes]);

  const useKit = ready && pipes !== null && pipes.length > 0;

  if (!useKit) {
    return (
      <>
        <a href="/login" className="sg-btn sg-btn--outline sg-btn--sm" data-cy="nav-sign-in">
          Sign In
        </a>
        <a href="/login" className="sg-btn sg-btn--primary sg-btn--sm" data-cy="nav-sign-up">
          Sign up
        </a>
      </>
    );
  }

  return (
    <>
      <noizu-auth
        ref={signInRef}
        transport="rest"
        api-base="/api/v1"
        mode="dropdown"
        layout="console"
        data-cy="nav-sign-in"
      >
        <button type="button" slot="trigger" className="sg-btn sg-btn--outline sg-btn--sm">
          Sign in
        </button>
      </noizu-auth>
      <noizu-auth
        ref={signUpRef}
        transport="rest"
        api-base="/api/v1"
        mode="modal"
        flow="signup"
        layout="console"
        data-cy="nav-sign-up"
      >
        <button type="button" slot="trigger" className="sg-btn sg-btn--primary sg-btn--sm">
          Sign up
        </button>
      </noizu-auth>
    </>
  );
}
