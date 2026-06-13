"use client";
import { toast as sonnerToast } from "sonner";

/** Opinionated wrapper around `sonner` — copper success, eval-fail red, etc. */

export interface ToastOptions {
  description?: string;
  duration?: number;
  action?: { label: string; onClick: () => void };
}

function emit(
  kind: "success" | "info" | "error" | "warning",
  message: string,
  options?: ToastOptions
) {
  // sonner's global `toast` API — `success/info/error/warning` variants
  // inherit classNames from <Toaster toastOptions.classNames>.
  const opts = {
    description: options?.description,
    duration: options?.duration,
    action: options?.action,
  };
  switch (kind) {
    case "success":
      sonnerToast.success(message, opts);
      return;
    case "info":
      sonnerToast.info(message, opts);
      return;
    case "error":
      sonnerToast.error(message, opts);
      return;
    case "warning":
      sonnerToast.warning(message, opts);
      return;
  }
}

/**
 * Forge toast helpers. Wraps sonner with state-specific wrapping.
 *
 * @example
 * toast.success("Script saved", { description: "8 nodes, 3 personas" });
 * toast.error("Run failed");
 */
export const toast = {
  success: (message: string, options?: ToastOptions) =>
    emit("success", message, options),
  info: (message: string, options?: ToastOptions) =>
    emit("info", message, options),
  error: (message: string, options?: ToastOptions) =>
    emit("error", message, options),
  warning: (message: string, options?: ToastOptions) =>
    emit("warning", message, options),
};
