import { loadCachedCSS } from "@styleguide-engine/lib/css-cache";

export function StyleInjector() {
  const css = loadCachedCSS();
  return <style dangerouslySetInnerHTML={{ __html: css }} />;
}
