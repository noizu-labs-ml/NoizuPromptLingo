import { describe, expect, test } from "vitest";
import { parseInvocation } from "../interface-selection.js";

describe("interface selection", () => {
  test("defaults no-arg invocation to web interface", () => {
    expect(parseInvocation([], {}).command).toBe("serve");
  });

  test("uses requested typo env var for TUI default", () => {
    expect(parseInvocation([], { CODE_ASSIST_DEFAUJLT_INTERFACE: "tui" }).command).toBe("interactive");
  });

  test("supports corrected env var for TUI default", () => {
    expect(parseInvocation([], { CODE_ASSIST_DEFAULT_INTERFACE: "terminal" }).command).toBe("interactive");
  });

  test("interface flag overrides env default", () => {
    expect(parseInvocation(["--interface", "tui"], { CODE_ASSIST_DEFAUJLT_INTERFACE: "web" }).command).toBe("interactive");
  });

  test("supports typo flag spelling", () => {
    expect(parseInvocation(["--interace=web"], { CODE_ASSIST_DEFAUJLT_INTERFACE: "tui" }).command).toBe("serve");
  });

  test("keeps explicit commands unchanged", () => {
    const parsed = parseInvocation(["--interface", "tui", "search", "auth"], {});
    expect(parsed.command).toBe("search");
    expect(parsed.args).toEqual(["auth"]);
  });
});
