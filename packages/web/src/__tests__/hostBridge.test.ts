import { describe, test, expect, afterEach } from "vitest";
import { isNativeMacHost } from "../hostBridge.ts";

describe("hostBridge", () => {
  afterEach(() => {
    delete (window as Window & { __LLM_TOOLKIT_NATIVE_CHROME__?: boolean }).__LLM_TOOLKIT_NATIVE_CHROME__;
  });

  test("is false in a normal browser", () => {
    expect(isNativeMacHost()).toBe(false);
  });

  test("is true when the Mac host injected the flag", () => {
    (window as Window & { __LLM_TOOLKIT_NATIVE_CHROME__?: boolean }).__LLM_TOOLKIT_NATIVE_CHROME__ = true;
    expect(isNativeMacHost()).toBe(true);
  });
});
