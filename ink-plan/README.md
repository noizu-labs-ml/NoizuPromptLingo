# tabbing-plan

Full-screen terminal UI for converting voice memos into structured project management tickets (user stories, bugs, tasks). Built with Ink (React for CLI). Part of the **tabbing-on** suite.

Records audio via microphone, transcribes via Whisper (through LiteLLM), then uses an LLM to classify and structure the transcript into a YAML-frontmatter + markdown ticket file.

## Prerequisites

- Node.js >= 20
- SoX (audio recording): `brew install sox` (macOS) or `apt install sox` (Linux)
- LiteLLM endpoint with Whisper support (default: inference.noizu.com)

## Install

```bash
# Via tabbing-on (includes tabbing-plan automatically)
cd utilities/tabbing-on
make install

# Or standalone
cd utilities/tabbing-on/ink-plan
make install
```

Installs `tabbing-plan` and `task-memo` (alias) to `~/.local/bin/`.

## Usage

```bash
# cd into a project and just run it — infers project from cwd
cd projects/codefre.sh
tabbing-plan

# Or use the alias
task-memo

# Override inference with flags
tabbing-plan --type bug
tabbing-plan --project derobot.is
```

## Flow

1. Press `r` to start recording
2. Speak your memo, press `space` to stop
3. Audio is transcribed via Whisper API
4. Review/edit the transcript (`e` opens $EDITOR)
5. LLM generates a structured ticket with YAML frontmatter
6. Adjust type/priority with arrow keys, press `enter` to save
7. File saved to `project-management/{user-stories|bugs|tasks}/`
8. Tabbing-on task entry created automatically

## Configuration

| Flag | Env Var | Default |
|------|---------|---------|
| `--api-url` | `LITELLM_API_URL` | `http://inference.noizu.com/v1` |
| `--api-key` | `LITELLM_API_KEY` | (required) |
| `--model` | `M2T_MODEL` | `gpt-4` |
| `--whisper-model` | `M2T_WHISPER_MODEL` | `whisper-1` |
| `-p, --project` | — | (inferred from cwd) |
| `-t, --type` | — | (inferred from speech) |
| `--output-dir` | — | `./project-management/` |
| `--no-tabbing` | — | `false` |

## Output Format

```yaml
---
id: US-042
title: Add OAuth support for backend API
issue_type: user-story
slug: add-oauth-support-backend-api
status: draft
priority: P1
category: auth
labels:
  - backend
  - security
created_at: "2026-05-26"
---

# Add OAuth support for backend API

## Story
As a **third-party developer**, I want to **authenticate via OAuth** so that **I can integrate with the API securely**.

## Acceptance Criteria
- [ ] OAuth 2.0 flow implemented
- [ ] Token refresh supported
- [ ] Documentation updated
```

## Stack

- **UI:** Ink 5 + React 18 + @inkjs/ui
- **Audio:** node-record-lpcm16 (SoX backend)
- **LLM:** OpenAI SDK -> LiteLLM proxy
- **Output:** yaml + fs
