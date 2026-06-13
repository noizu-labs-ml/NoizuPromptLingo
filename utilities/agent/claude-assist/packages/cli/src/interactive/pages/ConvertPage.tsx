import React, { useState } from "react";
import { Box, Text, useInput } from "ink";
import { Spinner, Select, TextInput } from "@inkjs/ui";
import { useRouter } from "../context/RouterContext.js";
import { useApiQuery, apiFetch } from "../hooks/useApi.js";
import { StepIndicator } from "../components/StepIndicator.js";

interface Candidate {
  type: string;
  startIndex: number;
  endIndex: number;
  confidence: number;
  description: string;
}

interface Artifact {
  type: string;
  name: string;
  description: string;
  content: string;
}

const TYPE_OPTIONS = [
  { label: "Agent", value: "agent" },
  { label: "Skill", value: "skill" },
  { label: "Command", value: "command" },
  { label: "Snippet", value: "snippet" },
  { label: "Runbook", value: "runbook" },
];

const STEPS = ["Type", "Range", "Details", "Preview"];

export function ConvertPage() {
  const { current, goBack } = useRouter();
  const id = current.params.id;

  const { data: candData } = useApiQuery<{ data: Candidate[] }>(`/conversations/${id}/candidates`);
  const candidates = candData?.data ?? [];

  const [step, setStep] = useState(0);
  const [selectedType, setSelectedType] = useState("");
  const [rangeStart, setRangeStart] = useState("");
  const [rangeEnd, setRangeEnd] = useState("");
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [artifact, setArtifact] = useState<Artifact | null>(null);
  const [generating, setGenerating] = useState(false);
  const [nameSubmitted, setNameSubmitted] = useState(false);

  useInput((_input, key) => {
    if (key.escape) {
      if (step > 0) setStep(step - 1);
      else goBack();
    }
  }, { isActive: true });

  const handleGenerate = async () => {
    setGenerating(true);
    try {
      const result = await apiFetch<{ data: Artifact }>(`/conversations/${id}/convert`, {
        method: "POST",
        body: JSON.stringify({
          type: selectedType,
          range: [parseInt(rangeStart), parseInt(rangeEnd)],
          name,
          description,
        }),
      });
      setArtifact(result.data);
      setStep(3);
    } catch (err: any) {
      setArtifact(null);
    }
    setGenerating(false);
  };

  return (
    <Box flexDirection="column">
      <Text bold color="cyan">Convert to Artifact</Text>
      <StepIndicator steps={STEPS} currentStep={step} />

      {/* Step 0: Select type */}
      {step === 0 && (
        <Box flexDirection="column" marginTop={1}>
          <Text>Select artifact type:</Text>
          <Select
            options={TYPE_OPTIONS}
            onChange={(v) => {
              setSelectedType(v);
              setStep(1);
            }}
          />
          {candidates.length > 0 && (
            <Box flexDirection="column" marginTop={1}>
              <Text dimColor bold>Suggestions:</Text>
              {candidates.map((c, i) => (
                <Text key={i} dimColor>
                  {" "}{c.type} [{c.startIndex}-{c.endIndex}] {Math.round(c.confidence * 100)}% — {c.description}
                </Text>
              ))}
            </Box>
          )}
        </Box>
      )}

      {/* Step 1: Range */}
      {step === 1 && (
        <Box flexDirection="column" marginTop={1}>
          <Text>Message range for <Text color="cyan">{selectedType}</Text>:</Text>
          <Box gap={2} marginTop={1}>
            <Box>
              <Text>Start: </Text>
              <TextInput placeholder="0" onSubmit={(v) => { setRangeStart(v); }} onChange={setRangeStart} />
            </Box>
          </Box>
          <Box gap={2}>
            <Box>
              <Text>End: </Text>
              <TextInput placeholder="10" onSubmit={(v) => { setRangeEnd(v); setStep(2); }} onChange={setRangeEnd} />
            </Box>
          </Box>
          <Text dimColor>Enter end value to proceed</Text>
        </Box>
      )}

      {/* Step 2: Details */}
      {step === 2 && (
        <Box flexDirection="column" marginTop={1}>
          <Text>Artifact details:</Text>
          <Box marginTop={1}>
            <Text>Name: </Text>
            {!nameSubmitted ? (
              <TextInput placeholder="my-artifact" onSubmit={(v) => { setName(v); setNameSubmitted(true); }} onChange={setName} />
            ) : (
              <Text color="cyan">{name}</Text>
            )}
          </Box>
          {nameSubmitted && (
            <Box>
              <Text>Description: </Text>
              <TextInput placeholder="What this does" onSubmit={(v) => { setDescription(v); handleGenerate(); }} onChange={setDescription} />
            </Box>
          )}
          <Text dimColor>Enter to proceed</Text>
        </Box>
      )}

      {/* Step 3: Preview */}
      {generating && <Spinner label="Generating artifact..." />}

      {step === 3 && artifact && (
        <Box flexDirection="column" marginTop={1}>
          <Text bold color="green">Generated: {artifact.name}</Text>
          <Text dimColor>Type: {artifact.type}</Text>
          <Text dimColor>{artifact.description}</Text>
          <Box marginTop={1} borderStyle="single" borderColor="gray" paddingX={1} flexDirection="column">
            <Text wrap="wrap">{artifact.content.slice(0, 2000)}</Text>
            {artifact.content.length > 2000 && (
              <Text dimColor>[...{artifact.content.length - 2000} more chars]</Text>
            )}
          </Box>
          <Text dimColor>Esc:back</Text>
        </Box>
      )}
    </Box>
  );
}
