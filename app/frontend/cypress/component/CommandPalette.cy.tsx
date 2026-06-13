// Regression test for the bug that prompted this suite: `useCommandPalette`
// threw "must be used within <CommandPaletteProvider>" because the barrel
// re-export and direct-path import yielded two different React contexts under
// Next 15 / Webpack.
//
// This isolation test verifies the provider exposes a working context to a
// consumer that uses the hook via the canonical import path.

import { useEffect } from "react";
import {
  CommandPaletteProvider,
  useCommandPalette,
} from "@/components/ui/CommandPaletteProvider";

function Consumer() {
  const palette = useCommandPalette();
  useEffect(() => {
    // Expose for the test to assert on.
    (window as unknown as { __palette: typeof palette }).__palette = palette;
  }, [palette]);
  return (
    <button data-cy="consumer-open" onClick={palette.open}>
      Open
    </button>
  );
}

describe("<CommandPaletteProvider>", () => {
  it("useCommandPalette resolves when rendered inside the provider", () => {
    cy.mount(
      <CommandPaletteProvider>
        <Consumer />
      </CommandPaletteProvider>,
    );
    cy.getByCy("consumer-open").should("be.visible");
    cy.window().its("__palette").should("have.property", "open");
    cy.window().its("__palette").should("have.property", "toggle");
  });

  it("clicking open triggers the palette element to mount", () => {
    cy.mount(
      <CommandPaletteProvider>
        <Consumer />
      </CommandPaletteProvider>,
    );
    cy.getByCy("consumer-open").click();
    cy.getByCy("command-palette").should("be.visible");
  });
});
