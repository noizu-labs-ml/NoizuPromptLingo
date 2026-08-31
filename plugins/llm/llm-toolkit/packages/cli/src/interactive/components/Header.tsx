import React from "react";
import { Box, Text, Spacer } from "ink";
import { useInput } from "ink";
import { useIndexStatus } from "../hooks/useApi.js";
import { HARNESS_OPTIONS, useHarness } from "../context/HarnessContext.js";

interface HeaderProps {
  isActive: boolean;
  selectedHarnessIndex: number;
  onSelectedHarnessIndexChange: (idx: number) => void;
}

// ⟦𓈂𓊟𓋬𓁬⟧ Header :: auto-generated pointer for public function Header
export function Header({ isActive, selectedHarnessIndex, onSelectedHarnessIndexChange }: HeaderProps) {
  const { data } = useIndexStatus();
  const { harness, setHarness } = useHarness();
  const status = data?.data;
  const isIndexed = status && status.conversationCount > 0;

  const selectHarness = (idx: number) => {
    const safe = Math.max(0, Math.min(HARNESS_OPTIONS.length - 1, idx));
    onSelectedHarnessIndexChange(safe);
    setHarness(HARNESS_OPTIONS[safe]);
  };

  useInput((input, key) => {
    if (key.leftArrow) {
      selectHarness(selectedHarnessIndex - 1);
    } else if (key.rightArrow) {
      selectHarness(selectedHarnessIndex + 1);
    } else if (/^[1-4]$/.test(input)) {
      selectHarness(Number(input) - 1);
    }
  }, { isActive });

  const progress = status?.progress;
  const progressLabel = progress && progress.phase !== "idle"
    ? `${progress.phase} ${progress.current}/${progress.total}`
    : null;

  return (
    <Box height={1} paddingX={1}>
      <Text bold color="cyan">llm-toolkit</Text>
      <Text dimColor>  </Text>
      {HARNESS_OPTIONS.map((item, index) => (
        <Text
          key={item}
          inverse={isActive && selectedHarnessIndex === index}
          color={harness === item ? "cyan" : undefined}
          bold={harness === item}
          dimColor={harness !== item && !(isActive && selectedHarnessIndex === index)}
        >
          {index > 0 ? " " : ""}{index + 1}:{item}
        </Text>
      ))}
      <Spacer />
      <Text>
        <Text color={isIndexed ? "green" : "yellow"}>●</Text>
        <Text dimColor> {progressLabel ?? (isIndexed ? `${status!.conversationCount} indexed` : "Not indexed")}</Text>
      </Text>
      <Text dimColor>  q:quit</Text>
    </Box>
  );
}
