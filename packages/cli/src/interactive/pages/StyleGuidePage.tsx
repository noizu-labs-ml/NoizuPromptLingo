import React from "react";
import { Box, Text } from "ink";

const tokens = [
  ["Void", "#09090B", "deep background"],
  ["Canvas", "#0F0F14", "page background"],
  ["Surface", "#18181F", "cards and panels"],
  ["Surface Raised", "#22222E", "elevated panels"],
  ["Glow", "#06B6D4", "active controls and primary links"],
];

const rules = [
  "Dark-native tool surface: dense, calm, no decorative glow.",
  "Use cyan only for active or interactive elements.",
  "Use monospace for identifiers, paths, code, and transcript metadata.",
  "Keep controls compact and keyboard-first.",
  "Thinking/tool blocks should default collapsed and expand on demand.",
];

// ⟦𓏍𓉅𓉁𓊚⟧ StyleGuidePage :: auto-generated pointer for public function StyleGuidePage
export function StyleGuidePage() {
  return (
    <Box flexDirection="column">
      <Text bold color="cyan">Claude Assist Style Guide</Text>
      <Text dimColor>2026-Q2-1 | Nocturne plus Minimal Tech | Plasma Cyan #06B6D4</Text>

      <Box flexDirection="column" borderStyle="single" borderColor="gray" paddingX={1} marginY={1}>
        <Text bold>Identity</Text>
        <Text dimColor>Professional instrument, terminal kinship, quiet competence, high information density.</Text>
      </Box>

      <Text bold>Core Tokens</Text>
      {tokens.map(([name, hex, use]) => (
        <Text key={name}>
          <Text color="cyan">{name.padEnd(15)}</Text>
          <Text dimColor>{hex} — {use}</Text>
        </Text>
      ))}

      <Box flexDirection="column" marginTop={1}>
        <Text bold>Rules</Text>
        {rules.map((rule) => (
          <Text key={rule} dimColor>  - {rule}</Text>
        ))}
      </Box>

      <Box flexDirection="column" marginTop={1}>
        <Text bold>Thread Rendering</Text>
        <Text dimColor>User messages use cyan emphasis. Assistant messages use neutral surfaces. Markdown is rendered in web and source-like in terminal.</Text>
        <Text dimColor>Tool use, tool results, and thinking blocks remain inspectable without dominating the main transcript.</Text>
      </Box>
    </Box>
  );
}
