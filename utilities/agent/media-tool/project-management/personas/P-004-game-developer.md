---
id: P-004
name: "Aisha Patel"
slug: game-developer
archetype: "Creative Technologist"
segment: secondary
tags: [game-assets, sprites, audio, video, multimedia]
---

# P-004: Aisha Patel

## Demographics

| Attribute | Value |
|-----------|-------|
| Age | 26 |
| Occupation | Indie game developer and creative coder |
| Location | Austin, TX |
| Tech comfort | high |

## Bio

Aisha builds browser games and creative coding projects. She uses `generate-media-prompt` to generate game sprites, background music via Suno, sound effects via ElevenLabs, and promo videos via Veo. She loves that a single tool handles images, audio, and video through the same declarative interface.

## Goals
- Generate game assets (sprites, backgrounds, icons) in batch
- Create background music and sound effects from text descriptions
- Produce promo videos and trailers from generated stills
- Maintain a game's entire asset pipeline as version-controlled `.media.prompt` files

## Frustrations
- Using different tools for images, music, and video breaks creative flow
- AI-generated assets often need manual cleanup in image editors
- No way to chain "generate sprite → generate idle animation → compose into trailer"

## Behaviors
- Maintains a `media/` directory with categorized `.media.prompt` files per game
- Uses dependency chains heavily (character sprite → character animation → trailer)
- Experiments with `--refine` for key game assets
- Generates audio assets with Suno and voice assets with ElevenLabs in the same pipeline

## Job to Be Done
> "When I'm building a game, I want to generate all visual, audio, and video assets from a single declarative pipeline, so I can focus on gameplay instead of asset production."

## Relationship to Product
Multimedia power user. Uses every asset type (image, audio, video) and every provider category. Leverages dependency chains for multi-step creative pipelines. Will benefit from post-processing (crop, resize) and eval (quality scoring) features.

## Scenarios
- **Scenario 1: Character Asset Pack** — Creates a sprite sheet prompt with transparency, generates variants, uses post-processing to crop into individual frames
- **Scenario 2: Soundtrack Generation** — Writes a Suno `.media.prompt` for each game level's theme music, chains them so the final track references the style of earlier ones
- **Scenario 3: Promo Trailer** — Generates hero screenshots, then feeds them as base images to a Veo video prompt for a short trailer
