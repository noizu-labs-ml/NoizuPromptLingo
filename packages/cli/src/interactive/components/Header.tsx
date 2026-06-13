import React from "react";
import { Box, Text, Spacer } from "ink";
import { useIndexStatus } from "../hooks/useApi.js";

export function Header() {
  const { data } = useIndexStatus();
  const status = data?.data;
  const isIndexed = status && status.conversationCount > 0;

  return (
    <Box height={1} paddingX={1}>
      <Text bold color="cyan">claude-assist</Text>
      <Spacer />
      <Text>
        <Text color={isIndexed ? "green" : "yellow"}>●</Text>
        <Text dimColor> {isIndexed ? `${status!.conversationCount} indexed` : "Not indexed"}</Text>
      </Text>
      <Text dimColor>  q:quit</Text>
    </Box>
  );
}
