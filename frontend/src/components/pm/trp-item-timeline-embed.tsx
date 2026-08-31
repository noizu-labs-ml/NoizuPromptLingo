"use client";

/**
 * Client shell for the embedded <trp-item-timeline> Lit component (W7 v2 —
 * reverse exchange; mirrors npl-queue-board-embed.tsx).
 *
 * The component bundle is NOT bundled by Next — it is fetched at runtime from
 * the same-origin key proxy (/api/trp-board/component-bundle) and loaded via a
 * native module import inside an injected script tag, so neither the bundler
 * nor the browser sees any key material. Data flows through the same proxy:
 * createTrpApiProvider is pointed at TRP_PROXY_BASE and the route handler
 * attaches the shared key server-side (TRP_EMBED_API_KEY stays in server env).
 */

import { useEffect, useRef, useState } from "react";
import { TRP_PROXY_BASE } from "@/lib/pm/trp-board-embed";

const BUNDLE_URL = `${TRP_PROXY_BASE}/component-bundle`;
const READY_EVENT = "trp-item-timeline-embed:ready";
const MODULE_WINDOW_KEY = "__trpItemTimelineEmbedModule";

type LoadState = "loading" | "ready" | "error";

interface TrpEmbedModule {
  createTrpApiProvider: (options: {
    baseUrl: string;
    orgId: string;
    itemId: string;
    token?: string | null;
  }) => (query?: { signal?: AbortSignal }) => Promise<unknown>;
}

type TimelineHost = HTMLElement & {
  dataProvider?: unknown;
  itemId?: string;
  heading?: string;
};

export default function TrpItemTimelineEmbed({
  orgId,
  itemId,
  heading,
}: {
  orgId: string;
  itemId: string;
  heading?: string;
}) {
  const containerRef = useRef<HTMLDivElement | null>(null);
  const [state, setState] = useState<LoadState>("loading");
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  useEffect(() => {
    let disposed = false;

    const onReady = (event: Event) => {
      const mod = (window as unknown as Record<string, TrpEmbedModule | undefined>)[MODULE_WINDOW_KEY];
      if (!mod) {
        // Import rejected — the event carries the failure detail.
        if (!disposed) {
          setState("error");
          setErrorMessage(
            event instanceof CustomEvent && event.detail ? String(event.detail) : "component bundle failed to load"
          );
        }
        return;
      }
      if (disposed || !containerRef.current) return;

      const host = document.createElement("trp-item-timeline") as TimelineHost;
      host.itemId = itemId;
      if (heading) host.heading = heading;
      host.dataProvider = mod.createTrpApiProvider({
        baseUrl: TRP_PROXY_BASE,
        orgId,
        itemId,
        // No token here on purpose: the key proxy attaches it server-side.
        token: null,
      });
      host.addEventListener("item-load-error", (loadEvent) => {
        const detail = (loadEvent as CustomEvent<unknown>).detail;
        setErrorMessage(typeof detail === "string" ? detail : "item data failed to load");
      });
      // item-activate: v2 leaves navigation to the host app (a TRP item route
      // on NPL arrives with W8's key mapping); the event is available on
      // `host` for follow-up wiring.
      containerRef.current.replaceChildren(host);
      setState("ready");
    };

    if ((window as unknown as Record<string, unknown>)[MODULE_WINDOW_KEY]) {
      onReady(new Event(READY_EVENT));
    } else {
      window.addEventListener(READY_EVENT, onReady, { once: true });

      const script = document.createElement("script");
      script.type = "module";
      // Runtime-generated module script ⇒ native import(), untouched by the bundler.
      script.textContent = [
        `import(${JSON.stringify(BUNDLE_URL)})`,
        `  .then((m) => { window[${JSON.stringify(MODULE_WINDOW_KEY)}] = m;`,
        `         window.dispatchEvent(new Event(${JSON.stringify(READY_EVENT)})); })`,
        `  .catch((e) => window.dispatchEvent(new CustomEvent(${JSON.stringify(READY_EVENT)}, { detail: String(e) })));`,
      ].join("\n");
      document.head.appendChild(script);
    }

    return () => {
      disposed = true;
      window.removeEventListener(READY_EVENT, onReady);
    };
  }, [orgId, itemId, heading]);

  return (
    <div>
      {state === "loading" ? <p className="text-[12px] text-mut">loading trp item timeline…</p> : null}
      {state === "error" ? (
        <p className="text-sm text-err">
          trp item timeline failed to load{errorMessage ? `: ${errorMessage}` : ""}
        </p>
      ) : null}
      <div ref={containerRef} />
    </div>
  );
}
