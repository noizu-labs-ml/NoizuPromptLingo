# Voice and Tone

Editorial voice guide for technical documentation. Voice is consistent across all docs (who we are). Tone adapts to context (how we sound in this situation).

## Universal Voice

All documentation shares these voice characteristics regardless of context:

| Characteristic | Means | Doesn't Mean |
|---------------|-------|-------------|
| **Clear** | Understood on first read | Oversimplified or dumbed-down |
| **Direct** | Gets to the point fast | Rude or abrupt |
| **Honest** | States limitations openly | Negative or pessimistic |
| **Helpful** | Anticipates reader needs | Patronizing or hand-holding |
| **Precise** | Technically accurate | Pedantic or over-qualified |

## Tone by Context

| Context | Tone | Register | Example |
|---------|------|----------|---------|
| **Tutorial** | Encouraging, patient | Conversational guide | "Let's set up your development environment. This takes about 10 minutes." |
| **Reference** | Neutral, authoritative | Technical manual | "The `--force` flag bypasses confirmation prompts. Default: `false`." |
| **Onboarding** | Welcoming, supportive | Friendly expert | "Welcome! By the end of this guide, you'll have a running instance." |
| **Runbook** | Calm, procedural | Operations manual | "Check pod status. If no pods are running, proceed to step 3." |
| **Changelog** | Informative, concise | Release announcement | "Added: Custom theme support via `config.yaml`." |
| **Architecture** | Analytical, thorough | Technical peer review | "The service uses event sourcing to ensure consistency across..." |
| **Error message** | Empathetic, actionable | Support agent | "Connection failed. Check that the database is running on port 5432." |

## Grammar Rules

### Always

- **Active voice:** "Run the command" not "The command should be run"
- **Second person:** "You can configure..." not "Users can configure..."
- **Present tense:** "The API returns..." not "The API will return..."
- **Imperative for steps:** "Install the package" not "You should install the package"
- **Positive framing:** "Use X for Y" not "Don't use Z for Y" (unless the warning is the point)

### Never

- **"Simply" / "just" / "easily"** — These dismiss difficulty. If it were simple, they wouldn't need docs.
- **"Obviously" / "of course" / "clearly"** — Makes the reader feel stupid when it's not obvious to them.
- **"Please"** — In technical docs, politeness is clarity, not pleasantries. "Run X" is fine.
- **"We" (ambiguous)** — "We recommend" (who?), "we'll configure" (the team? you and me?). Use "you" for the reader's actions.
- **Exclamation marks** — Almost never appropriate in technical docs. One per document maximum.

## Sentence Patterns

### Instructions

```
✓ "Run `npm install` to install dependencies."
✗ "You should run `npm install` which will install all the dependencies that are needed."

✓ "Set `PORT` to `3000` in `.env`."
✗ "The PORT environment variable should be set to the value 3000 in the .env file."
```

### Explanations

```
✓ "The cache expires after 5 minutes. To change this, set `CACHE_TTL` in seconds."
✗ "It should be noted that the caching mechanism has a default time-to-live of 300 seconds (5 minutes), which can be modified by setting the CACHE_TTL environment variable to the desired value in seconds."
```

### Warnings

```
✓ "**Warning:** This deletes all data. Back up first."
✗ "Please note that running this command will irreversibly delete all data in the database, so you might want to consider making a backup beforehand."
```

### Conditional Instructions

```
✓ "If you're on macOS, use `brew install`. On Linux, use `apt install`."
✗ "Depending on your operating system, you may need to use different package managers. If you are using macOS, you should use Homebrew..."
```

## Word Choice Guide

| Instead of | Write | Why |
|-----------|-------|-----|
| utilize | use | Shorter, clearer |
| leverage | use | Not a verb meaning "exploit" |
| functionality | feature | Plainer |
| in order to | to | Unnecessary words |
| a number of | several / many | More precise |
| at this point in time | now | Five words → one |
| make sure that | verify / confirm | More precise action |
| be aware that | note: | Shorter |
| terminate | stop / end | Plainer |
| execute | run | Standard CLI vocabulary |
| initiate | start | Plainer |
| perform | run / do | Plainer |
| prior to | before | Plainer |
| subsequent | next / after | Plainer |

## Formatting Conventions

| Element | Format | Example |
|---------|--------|---------|
| Commands, flags, values | `inline code` | Run `npm test` |
| File paths | `inline code` | Edit `src/config.ts` |
| UI elements | **bold** | Click **Settings** |
| Key concepts (first use) | **bold** | A **webhook** is... |
| Emphasis | *italic* (sparingly) | This is *not* reversible |
| Environment variables | `UPPER_SNAKE` in code | Set `DATABASE_URL` |
| Keyboard shortcuts | `code` with `+` | Press `Ctrl+C` |

## Anti-Patterns with Examples

### The Hedge

```
✗ "This should probably work in most cases, but you might need to..."
✓ "This works for standard setups. If you use a custom config, also set `X`."
```

### The Apology

```
✗ "Unfortunately, this feature is not yet supported. We apologize for..."
✓ "Custom themes are not yet supported. Track progress in issue #123."
```

### The Wall

```
✗ "The configuration system supports multiple formats including YAML, JSON,
   and TOML. YAML is recommended for most users because it supports comments
   and is more readable, though JSON is also widely used and may be preferred
   by users who are already familiar with it. TOML is supported primarily for
   compatibility with existing configs..."

✓ "Supported config formats: YAML (recommended), JSON, TOML."
```

### The Assumptive

```
✗ "Open your terminal and navigate to the project directory."
✓ "Open a terminal and run: `cd /path/to/project`"
```
