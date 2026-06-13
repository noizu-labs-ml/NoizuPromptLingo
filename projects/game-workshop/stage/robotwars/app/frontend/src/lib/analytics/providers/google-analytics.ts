import type { AnalyticsProvider, AnalyticsEvent, AnalyticsUser } from "../types";
import { getRuntimeConfig } from "@/lib/runtime-config";

declare global {
  interface Window {
    gtag: (...args: unknown[]) => void;
    dataLayer: unknown[];
  }
}

function measurementId() {
  return getRuntimeConfig().GA_MEASUREMENT_ID;
}

export const googleAnalytics: AnalyticsProvider = {
  name: "google-analytics",

  init() {
    const id = measurementId();
    if (!id || typeof window === "undefined") return;

    window.dataLayer = window.dataLayer || [];
    window.gtag = function () {
      window.dataLayer.push(arguments);
    };
    window.gtag("js", new Date());
    window.gtag("consent", "update", {
      analytics_storage: "granted",
      ad_storage: "denied",
      ad_user_data: "denied",
      ad_personalization: "denied",
    });
    window.gtag("config", id, { send_page_view: false });

    const script = document.createElement("script");
    script.src = `https://www.googletagmanager.com/gtag/js?id=${id}`;
    script.async = true;
    document.head.appendChild(script);
  },

  trackPageView(url: string) {
    if (!measurementId() || typeof window === "undefined" || !window.gtag) return;
    window.gtag("event", "page_view", { page_path: url });
  },

  trackEvent(event: AnalyticsEvent) {
    if (!measurementId() || typeof window === "undefined" || !window.gtag) return;
    window.gtag("event", event.name, event.properties);
  },

  identify(user: AnalyticsUser) {
    if (!measurementId() || typeof window === "undefined" || !window.gtag) return;
    window.gtag("set", { user_id: user.id });
  },

  reset() {
    if (!measurementId() || typeof window === "undefined" || !window.gtag) return;
    window.gtag("set", { user_id: undefined });
  },

  setConsent(granted: boolean) {
    if (!measurementId() || typeof window === "undefined" || !window.gtag) return;
    window.gtag("consent", "update", {
      analytics_storage: granted ? "granted" : "denied",
      ad_storage: "denied",
      ad_user_data: "denied",
      ad_personalization: "denied",
    });
  },
};
