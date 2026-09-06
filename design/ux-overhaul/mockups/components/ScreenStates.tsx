import type { ReactNode } from "react";
import type { ScreenState } from "@/lib/state";
import { Skeleton } from "@/components/Skeleton";
import { EmptyState } from "@/components/EmptyState";
import { PermissionState } from "@/components/PermissionState";
import { ErrorState } from "@/components/ErrorState";

/**
 * Shared server-component wrapper implementing the `?state=` contract
 * (UX-PLAN.md §5). Every route reads its state via lib/state.ts and passes
 * it here alongside its normal (default) content and an optional
 * screen-specific empty state.
 */
export function ScreenStates({
  state,
  emptyTitle = "Nothing here yet",
  emptyDescription = "No data matches the current view.",
  emptyActionLabel = "Create the first one",
  loadingSkeleton,
  children,
}: {
  state: ScreenState;
  emptyTitle?: string;
  emptyDescription?: string;
  emptyActionLabel?: string;
  loadingSkeleton?: ReactNode;
  children: ReactNode;
}) {
  if (state === "loading") {
    return <>{loadingSkeleton ?? <Skeleton />}</>;
  }
  if (state === "empty") {
    return (
      <EmptyState
        title={emptyTitle}
        description={emptyDescription}
        primaryActionLabel={emptyActionLabel}
        variant="first-run"
      />
    );
  }
  if (state === "error") {
    return <ErrorState />;
  }
  if (state === "denied") {
    return <PermissionState reason="role" />;
  }
  if (state === "suspended") {
    return <PermissionState reason="suspended" />;
  }
  return <>{children}</>;
}
