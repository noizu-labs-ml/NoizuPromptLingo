export function ErrorState({ requestId = "req_9f21ac" }: { requestId?: string }) {
  return (
    <div role="alert">
      <p className="chip">error</p>
      <h2>Something went wrong loading this page</h2>
      <p>Request id: {requestId}</p>
      <button type="button">Retry</button>
    </div>
  );
}
