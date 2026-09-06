export default function SuspendedPage() {
  return (
    <main style={{ padding: "1rem", maxWidth: "480px" }} role="alert">
      <p className="state">STATE: suspended</p>
      <h1>Account suspended</h1>
      <p>Your access to this org has been suspended by an admin.</p>
      <p>Contact your org owner, or reach support to appeal.</p>
      <a href="mailto:support@example.com">Contact support</a>
    </main>
  );
}
