---
id: US-095
title: "Discord Bot Deployment Package"
slug: "discord-bot-package"
personas: [P-001, P-004]
epic: "Developer Experience & Community"
priority: "could-have"
complexity: "L"
tags: [discord, integration, deployment, packaging, tabletop]
---

# US-095: Discord Bot Deployment Package

## User Story

**As an** indie game developer (P-001) and tabletop GM (P-004),
**I want to** deploy a NoizuRPG-powered game as a Discord bot using an official integration package,
**So that** my tabletop group or game community can play directly in Discord without me building all the bot scaffolding from scratch.

## Acceptance Criteria

- [ ] Given `pip install noizurpg[discord]`, when the package installs, then `discord.py` is included as a dependency and `from noizurpg.integrations.discord import NoizuRPGBot` is importable
- [ ] Given a `NoizuRPGBot(token=..., config=NoizuRPGConfig(...))`, when it starts, then it registers slash commands for `/start-game`, `/action [text]`, `/status`, and `/quit` and responds to them using the configured framework components
- [ ] Given a running `NoizuRPGBot` in a Discord server, when a user issues `/action explore the forest`, then the bot processes the action through the framework and replies in the same channel with the narrative result, including a formatted embed showing relevant stat changes
- [ ] Given a multi-player scenario, when two users in the same channel interact with the bot within the same game session, then each user's character state is tracked separately and dialogue/quest events reference the correct player
- [ ] Given the Discord bot package documentation, when I read the "Quickstart" guide, then a complete working bot (with a sample quest and one character archetype) can be deployed in under 15 minutes by following the steps

## Notes

This is the highest-demand integration based on the tabletop gaming community overlap with Discord. It provides P-004 a path from Cloud Playground exploration (US-083) to a real deployment without writing any Discord API code. Multi-player support is scoped to same-channel sessions in this story; cross-channel campaigns are out of scope.
