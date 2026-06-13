import type { StyleGuideConfig } from "../types";

export function generateGlobalsCSS(config: StyleGuideConfig): string {
  return config.globals;
}
