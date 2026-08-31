import React from "react";
import { Box, Text } from "ink";
import { useHarness } from "../context/HarnessContext.js";

const profiles = [
  { name: "Stage Work", scope: "Staging charts and application overlays", state: "Draft" },
  { name: "Production Terraform", scope: "Terraform plans and apply surfaces", state: "Locked" },
  { name: "Secrets Management", scope: "Infisical topology and generated credentials", state: "Review" },
];

const folders = [
  { path: "kubernetes/helm", permission: "Read/write", sensitivity: "Medium" },
  { path: "terraform/production", permission: "Read only", sensitivity: "High" },
  { path: ".secrets", permission: "Disabled", sensitivity: "Critical" },
];

// ⟦𓅪𓁡𓁪𓈰⟧ SafetyWatchPage :: auto-generated pointer for public function SafetyWatchPage
export function SafetyWatchPage() {
  const { harness } = useHarness();

  return (
    <Box flexDirection="column">
      <Text bold color="cyan">Safety Watch</Text>
      <Text dimColor>Permission profiles for {harness}</Text>

      <Box flexDirection="column" borderStyle="single" borderColor="gray" paddingX={1} marginY={1}>
        <Text bold>Monitoring stub</Text>
        <Text dimColor wrap="wrap">
          Policy enforcement is not active yet. This screen reserves the workflow for reviewing folder sensitivity,
          agent permissions, and context-specific enable/disable controls.
        </Text>
      </Box>

      <Text bold>Profiles</Text>
      {profiles.map((profile) => (
        <Box key={profile.name} flexDirection="column" marginTop={1}>
          <Text>
            <Text color="cyan">{profile.name}</Text>
            <Text dimColor> [{profile.state}]</Text>
          </Text>
          <Text dimColor>{"  "}{profile.scope}</Text>
        </Box>
      ))}

      <Box flexDirection="column" marginTop={1}>
        <Text bold>Folder Permissions</Text>
        {folders.map((folder) => (
          <Text key={folder.path}>
            <Text color={folder.sensitivity === "Critical" ? "red" : folder.sensitivity === "High" ? "yellow" : undefined}>
              {folder.sensitivity.padEnd(8)}
            </Text>
            {"  "}
            <Text>{folder.path}</Text>
            <Text dimColor> — {folder.permission}</Text>
          </Text>
        ))}
      </Box>

      <Box flexDirection="column" marginTop={1}>
        <Text bold>Audit Queue</Text>
        <Text dimColor>Future entries will summarize permission changes, denied paths, approval windows, and active context profiles.</Text>
      </Box>
    </Box>
  );
}
