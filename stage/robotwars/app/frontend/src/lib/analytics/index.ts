import type { AnalyticsProvider, AnalyticsEvent, AnalyticsUser } from "./types";
import { googleAnalytics } from "./providers/google-analytics";
import { posthog } from "./providers/posthog";
import { hasConsent } from "@/lib/consent";

export type { AnalyticsEvent, AnalyticsUser, AnalyticsProvider } from "./types";

const providers: AnalyticsProvider[] = [googleAnalytics, posthog];

let initialized = false;

function ensureInitialized() {
  if (!hasConsent("analytics")) return;
  providers.forEach((p) => p.setConsent?.(true));
  if (initialized) return;
  initialized = true;
  providers.forEach((p) => p.init());
}

export const analytics = {
  init() {
    ensureInitialized();
  },

  trackPageView(url: string) {
    if (!hasConsent("analytics")) return;
    ensureInitialized();
    providers.forEach((p) => p.trackPageView(url));
  },

  trackEvent(event: AnalyticsEvent) {
    if (!hasConsent("analytics")) return;
    ensureInitialized();
    providers.forEach((p) => p.trackEvent(event));
  },

  identify(user: AnalyticsUser) {
    if (!hasConsent("analytics")) return;
    ensureInitialized();
    providers.forEach((p) => p.identify(user));
  },

  reset() {
    providers.forEach((p) => p.reset());
  },

  revokeConsent() {
    providers.forEach((p) => p.setConsent?.(false));
    providers.forEach((p) => p.reset());
  },
};
