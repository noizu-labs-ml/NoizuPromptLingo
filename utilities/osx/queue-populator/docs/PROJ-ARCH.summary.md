# Project Architecture — Summary

Multi-channel input router that classifies free-text input and appends structured JSONL entries to queue files under `~/personal-development/queue/`.

- **Channels**: CLI (`q` command), voice (planned), SMS/bot/email (planned)
- **Components**: CLI entry point → input classifier → type router → JSONL writer
- **Persistence**: Append-only JSONL files on local filesystem, no database
- **Classifier**: Strategy TBD (LLM, rule-based, or hybrid)
- **Status**: Not started — design only
