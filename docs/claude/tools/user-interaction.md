# User Interaction

## AskUserQuestion

**Purpose**: Ask the user questions to clarify requirements or gather preferences.

**When to use**:
- Ambiguous requirements
- Multiple valid approaches
- Need user preference
- Making implementation choices
- **In plan mode to clarify BEFORE finalizing plan**

**When NOT to use**:
- Asking "Is my plan ready?" (use ExitPlanMode)
- Asking "Should I proceed?" (use ExitPlanMode)

**Parameters**:
- `questions` (required): Array of 1-4 questions
  - `question` (required): The question text
  - `header` (required): Short display label (max 12 characters recommended)
  - `options` (required): 2-4 choice objects
    - `label` (required): Option display text (1-5 words recommended)
    - `description` (required): Detailed explanation of the option
  - `multiSelect` (optional): Boolean; allow multiple selections (default: false)

**Usage**:

Single choice:
```json
{
  "questions": [
    {
      "question": "Which authentication method should we use?",
      "header": "Auth Method",
      "multiSelect": false,
      "options": [
        {
          "label": "JWT (Recommended)",
          "description": "Stateless, scalable, good for microservices"
        },
        {
          "label": "Session Cookies",
          "description": "Server-side state, simpler but less scalable"
        },
        {
          "label": "OAuth2",
          "description": "Third-party auth (Google, GitHub, etc.)"
        }
      ]
    }
  ]
}
```

Multiple questions:
```json
{
  "questions": [
    {
      "question": "Which database should we use?",
      "header": "Database",
      "multiSelect": false,
      "options": [
        {"label": "PostgreSQL", "description": "Full ACID compliance, robust"},
        {"label": "SQLite", "description": "Lightweight, file-based"},
        {"label": "MongoDB", "description": "NoSQL, flexible schema"}
      ]
    },
    {
      "question": "Which features do you want to enable?",
      "header": "Features",
      "multiSelect": true,
      "options": [
        {"label": "Rate limiting", "description": "Prevent abuse"},
        {"label": "Caching", "description": "Improve performance"},
        {"label": "Monitoring", "description": "Track usage"}
      ]
    }
  ]
}
```

**Key points**:
- An "Other" option is automatically available for all questions, allowing users to provide custom free-form input
- When "Other" is selected, you'll receive the user's custom response in the next message
- Mark the recommended option with "(Recommended)" suffix in the label
- Use `multiSelect: true` for questions where multiple answers are valid
- Keep headers concise (12 chars) and labels brief (1-5 words) for better UI display

**Response handling**:
- User selections appear in the next message as structured data
- For single-select: You'll receive the selected option's label
- For multi-select: You'll receive an array of selected labels
- For "Other": You'll receive the user's free-form text input

**Example workflow**:

You ask:
```json
{
  "questions": [{
    "question": "Which test framework should we use?",
    "header": "Framework",
    "multiSelect": false,
    "options": [
      {"label": "pytest (Recommended)", "description": "Full-featured, widely used"},
      {"label": "unittest", "description": "Python standard library"},
      {"label": "nose2", "description": "Extends unittest"}
    ]
  }]
}
```

User responds: `"pytest (Recommended)"`

You proceed: "Using pytest. I'll create tests in the tests/ directory..."

---

## Skill

**Purpose**: Invoke user-defined custom skills/commands.

**When to use**:
- User references a slash command (e.g., "/commit")
- Task matches an available skill
- User explicitly requests a skill

**When NOT to use**:
- Built-in CLI commands (/help, /clear)
- Skill is already running

**Parameters**:
- `skill` (required): Skill name
- `args` (optional): Arguments for the skill

**Usage**:

Basic:
```json
{
  "skill": "commit"
}
```

With arguments:
```json
{
  "skill": "commit",
  "args": "-m 'Fix bug in auth'"
}
```

Fully qualified:
```json
{
  "skill": "ms-office-suite:pdf"
}
```

**Discovering available skills**:
- Skills are listed in system-reminder messages during the conversation
- User may also mention skills by name (e.g., "run the commit skill")
- Look for slash command references like "/commit" or "/review-pr"

**Project-specific skills** (NoizuPromptLingo):
- `track-assumptions` - Structured response format with assumptions table and response plan
- `update-arch-doc` - PROJ-ARCH.md maintenance guide
- `update-layout-doc` - PROJ-LAYOUT.md maintenance guide
- `guest` - Welcome guide for new Claude Code users
- `annotate` - Adds footnote annotations to files without modifying originals

**Critical rules**:
- MUST invoke skill BEFORE responding about the task
- NEVER mention a skill without calling it
- Check if skill is already running first (look for `<command-name>` tag in current turn)
- Do not use this tool for built-in CLI commands (/help, /clear, etc.)