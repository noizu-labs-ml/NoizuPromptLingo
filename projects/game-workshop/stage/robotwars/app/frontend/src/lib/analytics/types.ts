export interface AnalyticsEvent {
  name: string;
  properties?: Record<string, string | number | boolean>;
}

export interface AnalyticsUser {
  id: string;
  email?: string;
  [key: string]: string | number | boolean | undefined;
}

export interface AnalyticsProvider {
  name: string;
  init(): void;
  trackPageView(url: string): void;
  trackEvent(event: AnalyticsEvent): void;
  identify(user: AnalyticsUser): void;
  reset(): void;
  setConsent?(granted: boolean): void;
}
