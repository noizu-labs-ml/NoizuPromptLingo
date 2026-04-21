"use client";

const borderColor = {
  success: "border-l-green-500",
  error: "border-l-red-500",
  info: "border-l-blue-500",
};

export function Toast({
  message,
  type = "info",
  onDismiss,
}: {
  message: string;
  type?: "success" | "error" | "info";
  onDismiss: () => void;
}) {
  return (
    <div
      className={`max-w-sm rounded-md shadow-elevated bg-surface-2 border-l-4 ${borderColor[type]} p-3 flex items-start gap-3`}
    >
      <p className="flex-1 text-sm text-foreground">{message}</p>
      <button
        onClick={onDismiss}
        className="shrink-0 text-muted hover:text-foreground transition-colors leading-none"
        aria-label="Dismiss"
      >
        ×
      </button>
    </div>
  );
}
