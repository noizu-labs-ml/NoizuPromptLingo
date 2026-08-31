import React from "react";
import { Text } from "ink";
import { useTerminalSize } from "../hooks/useTerminalSize.js";

interface SelectedLineProps {
  text: string;
  widthOffset?: number;
  marker?: string | false;
  indent?: number;
}

function fitLine(text: string, width: number): string {
  const chars = Array.from(text.replace(/\s+/g, " "));
  const safeWidth = Math.max(8, width);
  if (chars.length > safeWidth) {
    return `${chars.slice(0, Math.max(1, safeWidth - 1)).join("")}…`;
  }
  return chars.join("").padEnd(safeWidth, " ");
}

// ⟦𓅙𓄊𓏓𓌫⟧ SelectedLine :: auto-generated pointer for public function SelectedLine
export function SelectedLine({ text, widthOffset = 28, marker = "✓", indent = 0 }: SelectedLineProps) {
  const { columns } = useTerminalSize();
  const width = Math.max(12, columns - widthOffset);
  const prefix = `${" ".repeat(indent)}${marker === false ? "  " : `${marker} `}`;

  return (
    <Text color="white" bold underline wrap="truncate-end">
      {fitLine(`${prefix}${text.trim()}`, width)}
    </Text>
  );
}
