export function PermissionState({ reason = "role" }: { reason?: "role" | "suspended" | "scope" }) {
  const copy: Record<string, string> = {
    role: "Your role does not include access to this page.",
    suspended: "This account is suspended.",
    scope: "This action requires a scope your session does not have.",
  };
  return (
    <div role="alert">
      <p className="chip">permission denied</p>
      <h2>Access restricted</h2>
      <p>{copy[reason]}</p>
      <p>Contact an org admin if you believe this is unexpected.</p>
    </div>
  );
}
