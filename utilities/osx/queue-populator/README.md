# queue-populator

Multi-channel input tool that routes user inputs (questions, ideas, reminders, study items) to the appropriate queue files in ~/personal-development/queue/.

## Channels

- CLI: `q "remind me to check deploy tomorrow"`
- Voice: wake-word triggered (depends on wake-word-listener snippet)
- SMS / bot / email (future)

## Routing Logic

Classifies input by type and routes to the correct .jsonl file:
- Questions -> knowledge-base/references.jsonl or personal-development/questions.jsonl
- Reminders -> reminders.jsonl
- Ideas -> ideas/{category}.jsonl (auto-classified)
- Study items -> learning-plan/goals.jsonl
- Flashcard requests -> personal-development/study.jsonl

## Entry Format

```jsonl
{"ts": "2026-05-12T10:30:00Z", "type": "reminder", "text": "check deploy", "source": "cli", "processed": false}
```

## Virtual microphones (Claude / Codex / Llama)

queue-populator can route your live mic into virtual microphone devices so other
apps can receive your voice on demand. The `Recording` device is always fed
while queue-populator is listening. `Claude`, `Codex`, and `Llama` are
command-controlled.

Voice commands (active while idle):

- `robot open claude` / `robot open codex` / `robot open llama` — start routing
  your mic into that device.
- `robot close claude` / `robot close codex` / `robot close llama` — mute it.

Assistant routing is exclusive: opening one Claude/Codex/Llama device mutes the
other assistant devices, so only one assistant channel carries audio at a time.
The `Recording` device stays active.

The devices themselves are provided by a small CoreAudio HAL driver. Build and
install it once with:

```bash
cd Driver && ./build-virtual-mics.sh
```

See [`Driver/README.md`](Driver/README.md) for details, requirements, and
uninstall instructions.

## Status

Not started
