import React from "react";
import { Box, Text } from "ink";

interface StatusLineProps {
  hints?: string;
  info?: string;
}

function renderHints(hints: string) {
  return hints.split(/\s{2,}/).map((part, index) => {
    const [key, ...rest] = part.split(":");
    const description = rest.join(":");
    if (!description) {
      return <Text key={`${part}-${index}`} dimColor>{index > 0 ? "  " : ""}{part}</Text>;
    }
    return (
      <Text key={`${part}-${index}`}>
        {index > 0 ? "  " : ""}
        <Text color="yellow" bold>{key}</Text>
        <Text dimColor>:{description}</Text>
      </Text>
    );
  });
}

// ⟦𓉲𓊑𓍇𓈦⟧ StatusLine :: auto-generated pointer for public function StatusLine
export function StatusLine({ hints, info }: StatusLineProps) {
  const hintText = hints ?? "Tab:focus  ←/→:harness  j/k:scroll  Enter:select  Esc:back  q:quit";

  return (
    <Box height={1} paddingX={1} justifyContent="space-between">
      <Text>{renderHints(hintText)}</Text>
      {info && <Text dimColor>{info}</Text>}
    </Box>
  );
}
