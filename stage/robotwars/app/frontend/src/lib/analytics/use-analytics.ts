"use client";

import { useCallback, useEffect, useRef } from "react";
import { usePathname, useSearchParams } from "next/navigation";
import { analytics } from "./index";
import { hasConsent, onConsentChange } from "@/lib/consent";

export function usePageView() {
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const lastTrackedUrl = useRef<string | null>(null);
  const url = searchParams.toString() ? `${pathname}?${searchParams.toString()}` : pathname;

  const trackCurrentPage = useCallback(() => {
    if (!hasConsent("analytics")) return;
    if (lastTrackedUrl.current === url) return;

    analytics.trackPageView(url);
    lastTrackedUrl.current = url;
  }, [url]);

  useEffect(() => {
    trackCurrentPage();
  }, [trackCurrentPage]);

  useEffect(() => {
    return onConsentChange((state) => {
      if (state?.categories.analytics) {
        lastTrackedUrl.current = null;
        trackCurrentPage();
      } else {
        lastTrackedUrl.current = null;
        analytics.revokeConsent();
      }
    });
  }, [trackCurrentPage]);

  useEffect(() => {
    if (!hasConsent("analytics")) {
      lastTrackedUrl.current = null;
    }
  }, [url]);
}

export { analytics } from "./index";
