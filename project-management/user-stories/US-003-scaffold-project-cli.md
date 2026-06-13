---
id: US-003
title: "Scaffold new project with CLI"
slug: "scaffold-project-cli"
personas: [P-001, P-006]
epic: "Installation & Onboarding"
priority: "must-have"
complexity: "S"
tags: [cli, scaffolding, project-structure, init]
---

# US-003: Scaffold New Project with CLI

## User Story

**As an** indie AI game developer or game studio lead (P-001, P-006),
**I want to** run `noizurpg init my-game` to scaffold a new project directory with sensible defaults,
**So that** I start with a working project structure rather than building the boilerplate from scratch.

## Acceptance Criteria

- [ ] Given the NoizuRPG CLI is installed, when I run `noizurpg init my-game`, then a directory named `my-game/` is created containing at minimum: `config.yaml`, `characters/`, `worlds/`, `quests/`, and a `main.py` entry point.
- [ ] Given a scaffolded project, when I open `main.py`, then it contains runnable example code that initializes the framework, loads the config, and starts a game loop — identical to the quick-start tutorial output.
- [ ] Given a scaffolded project, when I run `python main.py`, then the process starts without import errors and prints a startup message indicating the game is ready.
- [ ] Given I run `noizurpg init my-game` and `my-game/` already exists, then the CLI prints an error message "Directory 'my-game' already exists. Use --force to overwrite." and exits with a non-zero status code.
- [ ] Given I run `noizurpg init my-game --template minimal`, then the scaffolded project contains only `config.yaml` and `main.py` with no example characters or worlds.

## Notes

The scaffold should work as a studio-friendly starting point — Aisha (P-006) needs it to produce a structure that integrates cleanly into a larger monorepo or CI pipeline. The `--template` flag enables both quick personal projects and clean studio baselines. See US-004 for LLM provider configuration within the generated `config.yaml`.
