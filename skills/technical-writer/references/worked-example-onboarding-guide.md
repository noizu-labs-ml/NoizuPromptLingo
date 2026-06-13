# Worked Example: Authoring an Onboarding Guide

Full walkthrough of writing an onboarding guide for a fictional CLI tool called `datactl` — from codebase analysis through polished output.

---

## 1. The Request

**User:** "Write a getting-started guide for datactl. It's a CLI for querying our data warehouse."

**Initial assessment:**

| Dimension | Status |
|-----------|--------|
| Project | datactl (CLI tool) |
| Doc type | Onboarding guide |
| Audience | Not specified — need to ask |
| Scope | Getting started (install → first query) |

**First question to user:** "Who's the primary audience — developers integrating datactl into scripts, or analysts running ad-hoc queries?"

**User response:** "Analysts. They know SQL but aren't necessarily comfortable with CLI tools."

Now we have enough to start.

---

## 2. Discovery Phase

### Codebase Analysis

Read the project to understand what datactl does:

```bash
# Check README for project overview
cat README.md

# Check CLI help for commands and flags
./datactl --help
./datactl query --help
./datactl config --help

# Check for existing docs
find . -name "*.md" | head -20

# Check installation method
cat package.json   # or Cargo.toml, go.mod, etc.
ls install.sh
```

### Findings

- **Install method:** Homebrew or curl script
- **Config:** `~/.datactl/config.yaml` with warehouse URL and auth token
- **Primary command:** `datactl query "SELECT ..." `
- **Auth:** API token from the web dashboard
- **Output formats:** table (default), CSV, JSON
- **Existing docs:** Only a sparse README with install command

### Audience Profile

| Dimension | Value |
|-----------|-------|
| Who | Data analysts |
| Knows | SQL, spreadsheets, basic terminal use |
| Doesn't know | Package managers, YAML, env vars, piping |
| Goal | Run queries without opening the web UI |
| Emotional state | Cautious — "I hope I don't break anything" |
| Entry point | Link from team wiki or Slack message |

---

## 3. Architecture Phase

### Outline

```
1. What is datactl? (2 sentences)
2. Prerequisites (Homebrew or curl)
3. Installation (3 steps)
4. Configuration (get token + create config)
5. Your first query (the payoff moment)
6. Saving results to a file
7. Next steps (3 links)
8. Troubleshooting (top 3 issues)
```

### Key Decisions

- **Start with "what is this?"** — analysts may not know why CLI > web UI
- **Homebrew first** — most analysts on macOS; curl as alternative
- **Config as a guided walkthrough** — don't just say "create config.yaml"; walk through each field
- **First query must succeed** — use a known-safe query (`SELECT 1` or equivalent)
- **Show output** — they need to see "it worked" visually
- **Saving to file** — immediate practical value for their workflow

---

## 4. Draft

```markdown
# Getting Started with datactl

datactl is a command-line tool for running SQL queries against the data
warehouse. It's faster than the web UI for quick lookups and can be
scripted for recurring reports.

## Prerequisites

- **macOS or Linux** (Windows support coming soon)
- **A data warehouse account** with an API token
  ([get your token here](https://warehouse.example.com/settings/tokens))

## Installation

### Option A: Homebrew (macOS)

```bash
brew install datactl
```

### Option B: Shell script (macOS/Linux)

```bash
curl -fsSL https://get.datactl.dev | sh
```

Verify the installation:

```bash
datactl --version
```

You should see something like:

```
datactl v2.4.1
```

## Configuration

datactl needs to know where your warehouse is and how to authenticate.

1. Create the config directory:

   ```bash
   mkdir -p ~/.datactl
   ```

2. Create the config file:

   ```bash
   cat > ~/.datactl/config.yaml << 'EOF'
   warehouse: https://warehouse.example.com
   token: YOUR_TOKEN_HERE
   EOF
   ```

3. Replace `YOUR_TOKEN_HERE` with your actual API token (the one from
   the Prerequisites step).

4. Verify the connection:

   ```bash
   datactl ping
   ```

   You should see:

   ```
   ✓ Connected to warehouse.example.com (v3.2.0)
   ```

## Your First Query

Run a simple query to confirm everything works:

```bash
datactl query "SELECT current_date AS today"
```

Output:

```
┌────────────┐
│ today      │
├────────────┤
│ 2026-05-12 │
└────────────┘
```

Now try a real query against your data:

```bash
datactl query "SELECT COUNT(*) AS total_users FROM users"
```

## Saving Results to a File

To save query results as a CSV:

```bash
datactl query "SELECT * FROM users LIMIT 100" --format csv > users.csv
```

Open `users.csv` in your spreadsheet tool — you'll see your data ready
to analyze.

Other formats: `--format json` for JSON, `--format table` (default) for
terminal display.

## Next Steps

- [Query syntax guide](./query-syntax.md) — Advanced SQL features
  supported by datactl
- [Scripting with datactl](./scripting.md) — Automate recurring reports
- [Configuration reference](./config-reference.md) — All config options

## Troubleshooting

### "Connection refused" when running `datactl ping`

**Cause:** The warehouse URL in your config is wrong, or you're not on
the company VPN.

**Fix:** Check `~/.datactl/config.yaml` — the warehouse URL should be
`https://warehouse.example.com`. If it's correct, connect to the VPN
and try again.

### "Authentication failed"

**Cause:** Your API token is invalid or expired.

**Fix:** Generate a new token at
https://warehouse.example.com/settings/tokens and update your config
file.

### "Command not found: datactl"

**Cause:** datactl isn't in your PATH.

**Fix (Homebrew):** Run `brew link datactl`.
**Fix (shell script):** Add `export PATH="$HOME/.local/bin:$PATH"` to
your `~/.zshrc` (or `~/.bashrc`), then restart your terminal.
```

---

## 5. Self-Review (Five Passes)

### Pass 1: Structural ✓

- Opening answers "what" and "why" ✓
- Logical flow: what → install → config → use → save → next ✓
- Prerequisites before installation ✓
- Troubleshooting at the end ✓
- No missing sections for the target audience ✓

### Pass 2: Accuracy ✓

- `brew install datactl` — verified against Homebrew tap ✓
- `datactl --version` output format — verified ✓
- `datactl ping` — verified this command exists ✓
- Config file format — verified against source ✓
- `--format csv` flag — verified against `datactl query --help` ✓
- **Fix found:** The `mkdir -p` step is unnecessary if `datactl config init` exists — checked, it doesn't. Step stays.

### Pass 3: Clarity ✓

- No jargon undefined for analyst audience ✓
- "YAML" not explained but shown by example (adequate for copy-paste) ✓
- Each step is one action ✓
- Expected output shown for every command ✓
- **Fix:** Changed "pipe to a file" to "save results to a file" (analyst vocabulary)

### Pass 4: Consistency ✓

- "data warehouse" used consistently (not alternating with "database") ✓
- Code fences all have language tags ✓
- Headers use sentence case consistently ✓
- Command examples use `datactl` not `./datactl` ✓

### Pass 5: Mechanics ✓

- No spelling errors ✓
- Markdown renders correctly ✓
- All links use descriptive text ✓
- No trailing whitespace ✓

---

## 6. Quality Score

| Criterion | Weight | Score | Weighted |
|-----------|--------|-------|----------|
| Accuracy | 25% | 9/10 | 2.25 |
| Completeness | 20% | 8/10 | 1.60 |
| Clarity | 20% | 9/10 | 1.80 |
| Structure | 15% | 9/10 | 1.35 |
| Examples | 10% | 9/10 | 0.90 |
| Freshness | 10% | 10/10 | 1.00 |
| **Total** | **100%** | | **8.90/10** |

Ships at 8.9/10. Above the 7.0 threshold.

---

## 7. Lessons Learned

1. **Audience calibration changed the entire doc** — "analysts who know SQL" means: explain CLI concepts, don't explain SQL, use their vocabulary ("save to file" not "pipe stdout")
2. **The first query IS the doc** — everything before it is setup; everything after is bonus. Get them to that moment fast.
3. **Expected output is non-negotiable** — for cautious users, "did it work?" anxiety is real. Show them exactly what success looks like.
4. **Troubleshooting top 3 is enough for v1** — don't try to document every failure mode upfront. Add entries as real users report issues.
5. **Self-review caught one real issue** — "pipe to a file" → "save results to a file" was a vocabulary mismatch the clarity pass caught.
