import { useState, useEffect } from "react";

export function useMonacoTheme(): string {
  const [theme, setTheme] = useState("light");

  useEffect(() => {
    function update() {
      setTheme(document.documentElement.classList.contains("dark") ? "vs-dark" : "light");
    }
    update();
    const observer = new MutationObserver(update);
    observer.observe(document.documentElement, { attributes: true, attributeFilter: ["class"] });
    return () => observer.disconnect();
  }, []);

  return theme;
}
