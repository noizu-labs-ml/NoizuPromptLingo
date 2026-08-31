# 07: Continue Session

| Field | Value |
|-------|-------|
| ID | SCR-07 |
| Surface | web |
| Type | primary |
| Category | Core |
| Route / Entry | `/thread/:id/continue` |
| Primary Personas | P-001, P-007, P-008 |
| User Stories | US-035, US-093 |

## Description
Session hand-off screen. Converts a stored conversation into a normalized "universal" transcript and produces harness-specific continuation output: a one-click resume command for the same harness, or a transfer prompt formatted for a different target harness (Claude Code, and stubbed targets — Gemini/OpenCode/Aider).

## Entry Points
- ActionBar "Continue" from Thread Viewer (SCR-04)
- Direct deep link `/thread/:id/continue`

## Key Components
- HarnessSelector — target harness picker (Claude, + stubbed Gemini/OpenCode/Aider)
- ViewModeToggle — Continuation / Universal / Raw view of the transcript
- ResumeCommandBlock — copyable one-click resume command for same-harness continuation
- TransferPromptBlock — copyable formatted prompt for cross-harness transfer
- CopyButton — per-block copy-to-clipboard with a transient "Copied" confirmation

## States
- **Loading:** spinner while `fetchUniversalConversation` resolves
- **Empty:** n/a
- **Error:** "Failed to load universal transcript" inline message if the fetch throws
- **Stubbed target:** non-Claude harness targets are visibly marked as stubbed/experimental (US-093) — output is generated but flagged as unverified

## Interactions
- Switching target harness regenerates the resume/transfer output live (`buildContinuationPayload`, `buildTransferPrompt`)
- View mode toggle swaps between the friendly continuation view, the normalized universal JSON, and raw source
- Copy buttons set a short-lived "copied" state per block

## Navigation
- **From:** SCR-04 Thread Viewer
- **To:** SCR-04 (back), external harness (paste target)
