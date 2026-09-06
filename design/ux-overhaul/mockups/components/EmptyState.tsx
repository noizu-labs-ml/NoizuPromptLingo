export function EmptyState({
  title,
  description,
  primaryActionLabel,
  variant = "first-run",
}: {
  title: string;
  description: string;
  primaryActionLabel: string;
  variant?: "first-run" | "filtered" | "error";
}) {
  return (
    <div>
      <p className="chip">empty: {variant}</p>
      <h2>{title}</h2>
      <p>{description}</p>
      <button type="button">{primaryActionLabel}</button>
    </div>
  );
}
