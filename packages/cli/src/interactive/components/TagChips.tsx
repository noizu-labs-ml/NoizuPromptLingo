import React from "react";
import { Box, Text } from "ink";

interface TagChipsProps {
  tags: string[];
  compact?: boolean;
}

export function TagChips({ tags, compact = false }: TagChipsProps) {
  if (tags.length === 0) return null;

  return (
    <Box gap={1}>
      {tags.map((tag) => (
        <Text key={tag} color="cyan" dimColor={compact}>
          [{tag}]
        </Text>
      ))}
    </Box>
  );
}
