import { orgs } from "@/lib/fixtures";

export default function RootIndex() {
  return (
    <main style={{ padding: "1rem" }}>
      <h1>NPL UX Overhaul — Wireframe Index</h1>
      <p>Pick an org to enter the app shell, or jump to a standalone route below.</p>
      <h2>Orgs</h2>
      <ul>
        {orgs.map((o) => (
          <li key={o.slug}>
            <a href={`/${o.slug}`}>{o.name}</a> <span className="chip">{o.role}</span>
          </li>
        ))}
      </ul>
      <h2>Standalone routes</h2>
      <ul>
        <li>
          <a href="/admin/authz">/admin/authz</a>
        </li>
        <li>
          <a href="/search?q=reconciliation">/search?q=reconciliation</a>
        </li>
        <li>
          <a href="/palette">/palette</a>
        </li>
        <li>
          <a href="/suspended">/suspended</a>
        </li>
        <li>
          <a href="/invite/tok_abc123">/invite/[token]</a>
        </li>
      </ul>
      <p>See the mockups README for the full route index and per-screen migration notes.</p>
    </main>
  );
}
