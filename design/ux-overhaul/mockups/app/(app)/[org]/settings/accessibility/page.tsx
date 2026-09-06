import { resolveState, type SearchParams } from "@/lib/state";
import { ScreenStates } from "@/components/ScreenStates";
import { PageHeader } from "@/components/PageHeader";

export default async function AccessibilityPage({ searchParams }: { searchParams: Promise<SearchParams> }) {
  const sp = await searchParams;
  const state = resolveState(sp);

  return (
    <div>
      <p className="state">STATE: {state}</p>
      <ScreenStates state={state} emptyTitle="Preferences unavailable" emptyDescription="Could not load your preferences." emptyActionLabel="Retry">
        <PageHeader title="Accessibility & theme" />
        <form className="stack">
          <fieldset>
            <legend>Theme</legend>
            <label>
              <input type="radio" name="theme" value="light" /> Light
            </label>
            <label>
              <input type="radio" name="theme" value="dark" defaultChecked /> Dark
            </label>
            <label>
              <input type="radio" name="theme" value="system" /> System
            </label>
          </fieldset>
          <fieldset>
            <legend>High contrast</legend>
            <label>
              <input type="radio" name="contrast" value="on" /> On
            </label>
            <label>
              <input type="radio" name="contrast" value="off" defaultChecked /> Off
            </label>
          </fieldset>
          <fieldset>
            <legend>Reduced motion</legend>
            <label>
              <input type="radio" name="motion" value="reduce" /> Reduce
            </label>
            <label>
              <input type="radio" name="motion" value="no-preference" defaultChecked /> No preference
            </label>
          </fieldset>
          <fieldset>
            <legend>Density</legend>
            <label>
              <input type="radio" name="density" value="compact" /> Compact
            </label>
            <label>
              <input type="radio" name="density" value="comfortable" defaultChecked /> Comfortable
            </label>
          </fieldset>
          <button type="submit">Save preferences</button>
        </form>
      </ScreenStates>
    </div>
  );
}
