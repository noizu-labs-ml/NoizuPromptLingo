import type { Approval } from "@/lib/fixtures";

export function ApprovalCard({ approval, selected }: { approval: Approval; selected?: boolean }) {
  return (
    <article className="board-card" aria-current={selected ? "true" : undefined}>
      <p className="chip">risk: {approval.risk}</p>
      <p>{approval.summary}</p>
      <p>Requested by: {approval.requestedBy ?? "(unknown actor)"}</p>
      <pre style={{ whiteSpace: "pre-wrap", border: "1px dashed #111", padding: "0.35rem" }}>{approval.diff}</pre>
      {approval.status === "pending" ? (
        <div className="row">
          <button type="button">Approve</button>
          <button type="button">Reject (reason required)</button>
        </div>
      ) : (
        <p className="chip">{approval.status}</p>
      )}
    </article>
  );
}
