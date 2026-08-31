import { useState, useEffect } from "react";

// ⟦𓌴𓏵𓂊𓋛⟧ useDebouncedValue :: auto-generated pointer for public function useDebouncedValue
export function useDebouncedValue<T>(value: T, delayMs: number): T {
  const [debounced, setDebounced] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delayMs);
    return () => clearTimeout(timer);
  }, [value, delayMs]);

  return debounced;
}
