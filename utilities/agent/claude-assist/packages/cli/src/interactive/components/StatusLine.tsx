import React from "react";
import { Box, Text } from "ink";

interface StatusLineProps {
  hints?: string;
  info?: string;
}

export function StatusLine({ hints, info }: StatusLineProps) {
  return (
    <Box height={1} paddingX={1} justifyContent="space-between">
      <Text dimColor>
        {hints ?? "Tab:nav  j/k:scroll  Enter:select  Esc:back  q:quit"}
      </Text>
      {info && <Text dimColor>{info}</Text>}
    </Box>
  );
}
