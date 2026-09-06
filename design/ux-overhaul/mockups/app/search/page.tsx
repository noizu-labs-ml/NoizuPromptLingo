import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { searchGroups } from "@/lib/fixtures";

export default async function SearchResultsPage({ searchParams }: { searchParams: Promise<SearchParams> }) {
  const sp = await searchParams;
  const state = resolveState(sp);
  const q = (Array.isArray(sp.q) ? sp.q[0] : sp.q) ?? "";

  return (
    <main style={{ padding: "1rem" }}>
      <p className="state">STATE: {state}</p>
      <ScreenStates
        state={state}
        emptyTitle={`No results for "${q}"`}
        emptyDescription="Try a different term, or check spelling and filters."
        emptyActionLabel="Clear search"
      >
        <h1>Search results for &quot;{q}&quot;</h1>
        <form role="search">
          <input type="search" name="q" defaultValue={q} />
          <button type="submit">Search</button>
        </form>
        {searchGroups.map((g) => (
          <section key={g.group}>
            <h2>{g.group}</h2>
            <ul>
              {g.results.map((r) => (
                <li key={r.id}>
                  <a href={r.href}>{r.title}</a>
                </li>
              ))}
            </ul>
          </section>
        ))}
      </ScreenStates>
    </main>
  );
}
