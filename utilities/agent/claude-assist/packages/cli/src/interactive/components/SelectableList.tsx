import React from "react";
import { Box, Text } from "ink";

interface SelectableListProps<T> {
  items: T[];
  cursor: number;
  visibleRange: [number, number];
  renderItem: (item: T, index: number, isCursor: boolean) => React.ReactNode;
  emptyMessage?: string;
}

export function SelectableList<T>({
  items,
  cursor,
  visibleRange,
  renderItem,
  emptyMessage = "No items",
}: SelectableListProps<T>) {
  if (items.length === 0) {
    return <Text dimColor>{emptyMessage}</Text>;
  }

  const [start, end] = visibleRange;
  const visible = items.slice(start, end);

  return (
    <Box flexDirection="column">
      {start > 0 && <Text dimColor>  ▲ {start} more above</Text>}
      {visible.map((item, vi) => {
        const realIndex = start + vi;
        return (
          <Box key={realIndex}>
            {renderItem(item, realIndex, realIndex === cursor)}
          </Box>
        );
      })}
      {end < items.length && <Text dimColor>  ▼ {items.length - end} more below</Text>}
    </Box>
  );
}
