# Onboarding Guides

Patterns and templates for getting-started documentation — installation guides, first-run experiences, and new-user walkthroughs.

## When to Use

Write an onboarding guide when a new user needs to go from "I just found this tool" to "I have it working and did something useful." This is typically the highest-traffic documentation for any project.

## Core Structure

Every onboarding guide follows this skeleton:

```
1. What this is (1-2 sentences)
2. Prerequisites (what you need before starting)
3. Installation (step by step)
4. Configuration (minimal viable config)
5. First success (do something real)
6. Next steps (where to go from here)
7. Troubleshooting (common failures)
```

## Section-by-Section Guidance

### 1. What This Is

One to two sentences maximum. Answer: "What does this tool do, and why would I use it?"

**Good:** "Helm is a package manager for Kubernetes. It lets you define, install, and upgrade complex Kubernetes applications."

**Bad:** "Helm is a CNCF graduated project that provides a robust and comprehensive package management solution for the Kubernetes ecosystem, building on years of community contributions..."

### 2. Prerequisites

Bulleted list. Each item should include:
- What's needed
- How to check if you have it
- Where to get it if you don't

```markdown
## Prerequisites

- **Node.js 18+** — check with `node --version` ([install](https://nodejs.org))
- **Docker** — check with `docker --version` ([install](https://docs.docker.com/get-docker/))
- **A GitHub account** with SSH key configured ([setup guide](https://docs.github.com/en/authentication))
```

### 3. Installation

Numbered steps. Each step should be one action. Show the command AND the expected output.

```markdown
## Installation

1. Clone the repository:
   ```bash
   git clone git@github.com:org/project.git
   cd project
   ```

2. Install dependencies:
   ```bash
   npm install
   ```
   You should see output ending with `added X packages`.

3. Copy the example config:
   ```bash
   cp .env.example .env
   ```
```

**Rules:**
- One command per step (don't chain with `&&` unless they're truly atomic)
- Show expected output for non-obvious commands
- If a step can fail, add a troubleshooting note inline or point to the troubleshooting section

### 4. Configuration

Only the minimum config needed to get started. Link to full config reference for everything else.

```markdown
## Configuration

Edit `.env` with your settings:

```env
DATABASE_URL=postgresql://localhost:5432/myapp
API_KEY=your-api-key-here  # Get this from https://example.com/settings
```

> For all configuration options, see the [Configuration Reference](./config-reference.md).
```

### 5. First Success

The user should do something real within 5 minutes of finishing installation. This is the emotional hook — "it works!"

```markdown
## Your First Query

Run a test query to verify everything is working:

```bash
myctl query "SELECT 1"
```

You should see:
```
┌──────┐
│ ?col │
├──────┤
│    1 │
└──────┘
```

Congratulations — you're connected and ready to go.
```

### 6. Next Steps

Three to five bullets pointing to deeper docs. Ordered by likely interest.

### 7. Troubleshooting

Top 3-5 failure modes with symptoms and fixes. Use the problem → solution → verification pattern:

```markdown
## Troubleshooting

### Connection refused on port 5432

**Symptom:** `Error: connect ECONNREFUSED 127.0.0.1:5432`

**Fix:** Start the PostgreSQL service:
```bash
brew services start postgresql@16
```

**Verify:** Re-run `myctl query "SELECT 1"` — you should see the table output.
```

## Anti-Patterns

| Anti-Pattern | Why It's Bad | Fix |
|-------------|-------------|-----|
| Wall of text before any commands | Reader bounces before starting | Lead with prerequisites + install |
| Assuming environment | "Run `make`" (which make? what OS?) | Specify prerequisites explicitly |
| No expected output | Reader doesn't know if it worked | Show output for every non-obvious step |
| Config dump | Overwhelming for first-time users | Minimum viable config only |
| No troubleshooting | Reader is stuck with no recourse | Top 5 failure modes minimum |
| "For more info see..." with no link | Dead-end reference | Always include the actual link |

## Audience Variants

| Audience | Adjust |
|----------|--------|
| External developer | Full prerequisites, no assumed context, every term defined |
| Internal team member | Can assume repo access, shared infra, internal tooling |
| Non-developer (ops, PM) | GUI-focused path if available, explain CLI concepts |
