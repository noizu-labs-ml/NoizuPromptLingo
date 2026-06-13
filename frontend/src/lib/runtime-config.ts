export interface RuntimeConfig {
  GA_MEASUREMENT_ID?: string;
  POSTHOG_KEY?: string;
  POSTHOG_HOST?: string;
  API_URL?: string;
  OTEL_COLLECTOR_URL?: string;
}

export function getRuntimeConfig(): RuntimeConfig {
  if (typeof window !== "undefined" && (window as unknown as { __ENV: RuntimeConfig }).__ENV) {
    return (window as unknown as { __ENV: RuntimeConfig }).__ENV;
  }
  return {
    GA_MEASUREMENT_ID: process.env.NEXT_PUBLIC_GA_MEASUREMENT_ID,
    POSTHOG_KEY: process.env.NEXT_PUBLIC_POSTHOG_KEY,
    POSTHOG_HOST: process.env.NEXT_PUBLIC_POSTHOG_HOST,
    API_URL: process.env.NEXT_PUBLIC_API_URL,
    OTEL_COLLECTOR_URL: process.env.NEXT_PUBLIC_OTEL_COLLECTOR_URL,
  };
}
