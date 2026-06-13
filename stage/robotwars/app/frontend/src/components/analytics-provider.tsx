"use client";

import { Suspense } from "react";
import { usePageView } from "@/lib/analytics/use-analytics";

function AnalyticsPageView() {
  usePageView();
  return null;
}

export function AnalyticsProvider({ children }: { children: React.ReactNode }) {
  return (
    <>
      <Suspense fallback={null}>
        <AnalyticsPageView />
      </Suspense>
      {children}
    </>
  );
}
