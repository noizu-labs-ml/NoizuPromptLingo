export type NativeHostWindow = Window & {
  __LLM_TOOLKIT_NATIVE_CHROME__?: boolean;
  __LLM_TOOLKIT_NAVIGATE__?: (path: string) => void;
};

export function getHostWindow(): NativeHostWindow | null {
  if (typeof window === "undefined") return null;
  return window as NativeHostWindow;
}

export function isNativeMacHost(): boolean {
  return Boolean(getHostWindow()?.__LLM_TOOLKIT_NATIVE_CHROME__);
}
