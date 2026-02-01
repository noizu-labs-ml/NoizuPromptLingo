---
name: annotate
description: Adds footnote annotations to files. NEVER modifies originals. Copies source to {file}.annotated.{ext}.md, adds markers there, and appends definitions to {file}.footnotes.{ext}.md. Every marker REQUIRES a corresponding definition.
---

# Annotate Instructions

## CRITICAL RULES

1. **NEVER modify the original file**
2. **Copy the original to an annotated file first**
3. **Add markers to the annotated copy only**
4. **Append definitions to the footnotes file**
5. **Every marker MUST have a definition — NEVER add one without the other**

## Three-File System

When annotating `src/auth.py`, you create/modify THREE files:

| File | Purpose | Modified? |
|------|---------|-----------|
| `src/auth.py` | Original source | **NEVER** |
| `src/auth.annotated.py.md` | Annotated copy with markers | YES |
| `src/auth.footnotes.py.md` | Footnote definitions | YES |

### File Naming Rules

| Original File | Annotated Copy | Footnotes File |
|---------------|----------------|----------------|
| `foo.py` | `foo.annotated.py.md` | `foo.footnotes.py.md` |
| `foo.ts` | `foo.annotated.ts.md` | `foo.footnotes.ts.md` |
| `foo.yaml` | `foo.annotated.yaml.md` | `foo.footnotes.yaml.md` |
| `foo.md` | `foo.annotated.md` | `foo.footnotes.md` |

**Pattern:**
- Annotated: `{name}.annotated.{ext}.md` (or `{name}.annotated.md` if already `.md`)
- Footnotes: `{name}.footnotes.{ext}.md` (or `{name}.footnotes.md` if already `.md`)

## Required Operations

Annotating a file requires THREE steps:

### Step 1: Copy Original to Annotated File

**Copy `src/auth.py` → `src/auth.annotated.py.md`**

The annotated file is a markdown file containing the source. Wrap code in a fenced code block:

```markdown
# Annotated: auth.py

Source: `src/auth.py`

\`\`\`python
def login(user):
    token = get_token(user)
    return validate(token)
\`\`\`
```

### Step 2: Add Markers to Annotated Copy

**Edit `src/auth.annotated.py.md` to add `[^marker]` references:**

```markdown
# Annotated: auth.py

Source: `src/auth.py`

\`\`\`python
def login(user):  # [^login-flow]
    token = get_token(user)  # [^token-fetch]
    return validate(token)
\`\`\`
```

### Step 3: Append Definitions to Footnotes File

**Create/append to `src/auth.footnotes.py.md`:**

```markdown
# Footnotes: auth.py

Source: `src/auth.py`

---

[^login-flow]: Main authentication entry point.

Validates user credentials and establishes session.

---

[^token-fetch]: Retrieves OAuth token from identity provider.

---
```

## ALL THREE STEPS ARE REQUIRED

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   STEP 1: Copy original  →  {file}.annotated.{ext}.md      │
│                                                             │
│   STEP 2: Add [^markers] to annotated copy                 │
│                                                             │
│   STEP 3: Append [^marker]: definitions to footnotes       │
│                                                             │
│   ─────────────────────────────────────────────────────    │
│                                                             │
│   NEVER modify the original file                           │
│   NEVER add a marker without its definition                │
│   NEVER add a definition without its marker                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Complete Example

You are asked to annotate `src/api/client.ts`.

### Original File (DO NOT MODIFY)

`src/api/client.ts`:
```typescript
export class ApiClient {
    private baseUrl: string;
    
    async fetch<T>(endpoint: string): Promise<T> {
        const response = await fetch(`${this.baseUrl}${endpoint}`);
        if (!response.ok) {
            throw new ApiError(response.status);
        }
        return response.json();
    }
}
```

### Step 1 & 2: Create Annotated Copy with Markers

**Create `src/api/client.annotated.ts.md`:**

```markdown
# Annotated: client.ts

Source: `src/api/client.ts`

\`\`\`typescript
export class ApiClient {
    private baseUrl: string;  // [^base-url]
    
    async fetch<T>(endpoint: string): Promise<T> {  // [^fetch-method]
        const response = await fetch(`${this.baseUrl}${endpoint}`);
        if (!response.ok) {  // [^error-check]
            throw new ApiError(response.status);
        }
        return response.json();
    }
}
\`\`\`
```

### Step 3: Create Footnotes File with Definitions

**Create `src/api/client.footnotes.ts.md`:**

```markdown
# Footnotes: client.ts

Source: `src/api/client.ts`

---

[^base-url]: Configured via `API_BASE_URL` environment variable.

Defaults to `http://localhost:3000` in development.

---

[^fetch-method]: Generic fetch wrapper with automatic JSON parsing.

Type parameter `T` represents the expected response shape.

---

[^error-check]: Throws `ApiError` on non-2xx responses.

TODO: Add retry logic for 5xx errors.

---
```

## Annotated File Structure

The `.annotated.{ext}.md` file is a markdown document:

```markdown
# Annotated: {filename}

Source: `{path/to/original}`

\`\`\`{language}
{original code with [^markers] added in comments}
\`\`\`
```

For markdown files, no code fence needed — just copy content and add markers inline.

## Footnotes File Structure

```markdown
# Footnotes: {filename}

Source: `{path/to/original}`

---

[^marker-id]: Definition content here.

Supports **markdown** formatting.

---

[^another-marker]: Another definition.

---
```

## Checklist Before Completing

- [ ] Original file is UNTOUCHED
- [ ] Annotated copy exists: `{file}.annotated.{ext}.md`
- [ ] Annotated copy contains original content with `[^markers]`
- [ ] Footnotes file exists: `{file}.footnotes.{ext}.md`
- [ ] Every `[^marker]` has a corresponding `[^marker]:` definition
- [ ] Every definition ends with `---`

## Summary

| Action | File |
|--------|------|
| Read only | `{file}.{ext}` (original) |
| Add markers | `{file}.annotated.{ext}.md` |
| Add definitions | `{file}.footnotes.{ext}.md` |

**The original file is NEVER modified. Markers and definitions are ALWAYS added together.**
