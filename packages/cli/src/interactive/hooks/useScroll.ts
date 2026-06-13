import { useState, useCallback, useMemo } from "react";
import { useInput } from "ink";

interface UseScrollOptions {
  totalItems: number;
  viewportHeight: number;
  isActive?: boolean;
}

export function useScroll({ totalItems, viewportHeight, isActive = true }: UseScrollOptions) {
  const [cursor, setCursorRaw] = useState(0);
  const [offset, setOffset] = useState(0);

  const safeCursor = Math.min(cursor, Math.max(0, totalItems - 1));
  const maxOffset = Math.max(0, totalItems - viewportHeight);

  const setCursor = useCallback((idx: number) => {
    const clamped = Math.max(0, Math.min(idx, totalItems - 1));
    setCursorRaw(clamped);
    setOffset((prev) => {
      if (clamped < prev) return clamped;
      if (clamped >= prev + viewportHeight) return clamped - viewportHeight + 1;
      return prev;
    });
  }, [totalItems, viewportHeight]);

  const moveCursorUp = useCallback(() => setCursor(safeCursor - 1), [safeCursor, setCursor]);
  const moveCursorDown = useCallback(() => setCursor(safeCursor + 1), [safeCursor, setCursor]);

  const pageUp = useCallback(() => {
    setCursor(Math.max(0, safeCursor - viewportHeight));
  }, [safeCursor, viewportHeight, setCursor]);

  const pageDown = useCallback(() => {
    setCursor(Math.min(totalItems - 1, safeCursor + viewportHeight));
  }, [safeCursor, totalItems, viewportHeight, setCursor]);

  useInput((input, key) => {
    if (key.upArrow || input === "k") moveCursorUp();
    else if (key.downArrow || input === "j") moveCursorDown();
    else if (key.pageUp) pageUp();
    else if (key.pageDown) pageDown();
  }, { isActive });

  const safeOffset = Math.max(0, Math.min(offset, maxOffset));
  const visibleRange: [number, number] = [
    safeOffset,
    Math.min(safeOffset + viewportHeight, totalItems),
  ];

  return useMemo(() => ({
    cursor: safeCursor,
    offset: safeOffset,
    visibleRange,
    setCursor,
    moveCursorUp,
    moveCursorDown,
    pageUp,
    pageDown,
    totalItems,
    viewportHeight,
  }), [safeCursor, safeOffset, visibleRange[0], visibleRange[1], totalItems, viewportHeight]);
}
