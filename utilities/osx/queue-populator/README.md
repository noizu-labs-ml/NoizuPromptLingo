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

## Status

Not started
