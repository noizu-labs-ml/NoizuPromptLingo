import type { AnalyticsProvider, AnalyticsEvent, AnalyticsUser } from "../types";
import { getRuntimeConfig } from "@/lib/runtime-config";

declare global {
  interface Window {
    posthog: {
      init: (key: string, config: Record<string, unknown>) => void;
      capture: (event: string, properties?: Record<string, unknown>) => void;
      identify: (id: string, properties?: Record<string, unknown>) => void;
      reset: () => void;
      opt_in_capturing?: () => void;
      opt_out_capturing?: () => void;
    };
  }
}

function apiKey() {
  return getRuntimeConfig().POSTHOG_KEY;
}

function apiHost() {
  return getRuntimeConfig().POSTHOG_HOST || "https://us.i.posthog.com";
}

export const posthog: AnalyticsProvider = {
  name: "posthog",

  init() {
    const key = apiKey();
    const host = apiHost();
    if (!key || typeof window === "undefined") return;

    // @ts-expect-error — PostHog inline snippet (vendor code)
    // eslint-disable-next-line
    !function(t,e){var o,n,p,r;e.__SV||(window.posthog=e,e._i=[],e.init=function(i,s,a){function g(t,e){var o=e.split(".");2==o.length&&(t=t[o[0]],e=o[1]),t[e]=function(){t.push([e].concat(Array.prototype.slice.call(arguments,0)))}}(p=t.createElement("script")).type="text/javascript",p.crossOrigin="anonymous",p.async=!0,p.src=s.api_host.replace(".i.posthog.com","-assets.i.posthog.com")+"/static/array.js",(r=t.getElementsByTagName("script")[0]).parentNode.insertBefore(p,r);var u=e;for(void 0!==a?u=e[a]=[]:a="posthog",u.people=u.people||[],u.toString=function(t){var e="posthog";return"posthog"!==a&&(e+="."+a),t||(e+=" (stub)"),e},u.people.toString=function(){return u.toString(1)+".people (stub)"},o="init capture register register_once register_for_session unregister unregister_for_session getFeatureFlag getFeatureFlagPayload isFeatureEnabled reloadFeatureFlags updateEarlyAccessFeatureEnrollment getEarlyAccessFeatures on onFeatureFlags onSessionId getSurveys getActiveMatchingSurveys renderSurvey canRenderSurvey identify setPersonProperties group resetGroups setPersonPropertiesForFlags resetPersonPropertiesForFlags setGroupPropertiesForFlags resetGroupPropertiesForFlags reset get_distinct_id getGroups get_session_id get_session_replay_url alias set_config startSessionRecording stopSessionRecording sessionRecordingStarted captureException loadToolbar get_property getSessionProperty createPersonProfile opt_in_capturing opt_out_capturing has_opted_in_capturing has_opted_out_capturing clear_opt_in_out_capturing debug getPageviewId".split(" "),n=0;n<o.length;n++)g(u,o[n]);e._i.push([i,s,a])},e.__SV=1)}(document,window.posthog||[]);

    window.posthog.init(key, {
      api_host: host,
      person_profiles: "identified_only",
      capture_pageview: false,
      capture_pageleave: true,
    });
  },

  trackPageView(url: string) {
    if (!apiKey() || typeof window === "undefined" || !window.posthog) return;
    window.posthog.capture("$pageview", { $current_url: url });
  },

  trackEvent(event: AnalyticsEvent) {
    if (!apiKey() || typeof window === "undefined" || !window.posthog) return;
    window.posthog.capture(event.name, event.properties);
  },

  identify(user: AnalyticsUser) {
    if (!apiKey() || typeof window === "undefined" || !window.posthog) return;
    const { id, ...properties } = user;
    window.posthog.identify(id, properties);
  },

  reset() {
    if (!apiKey() || typeof window === "undefined" || !window.posthog) return;
    window.posthog.reset();
  },

  setConsent(granted: boolean) {
    if (!apiKey() || typeof window === "undefined" || !window.posthog) return;
    if (granted) {
      window.posthog.opt_in_capturing?.();
    } else {
      window.posthog.opt_out_capturing?.();
    }
  },
};
