# PRD Refactoring Agent Prompt

## Purpose

Migrate flat PRD markdown files to the new directory-based structure with separated concerns (user stories, functional requirements, acceptance tests).

## New PRD Structure Standard

Each PRD is now organized as a directory:

```
project-management/PRDs/PRD-NNN-{name}/
├── README.md                          # Main PRD (overview only, no inlined content)
├── user-stories/
│   ├── index.yaml                     # Metadata index for all stories
│   ├── US-XXX-{slug}.md               # Individual user story
│   └── ...
├── functional-requirements/
│   ├── index.yaml                     # Metadata index for all FRs
│   ├── FR-001-{name}.md               # Individual FR
│   └── ...
├── acceptance-tests/
│   ├── index.yaml                     # Metadata index for all tests
│   ├── AT-001-{name}.md               # Individual test
│   └── ...
└── {feature-name}.impl.log            # Implementation log (created later)
```

## Your Task

Refactor ONE PRD file from flat .md format to the directory-based structure.

### Input Parameters (from task description)

- **SOURCE_PRD**: Path to the flat PRD file to refactor (e.g., `project-management/PRDs/PRD-002-artifact-management.md`)
- **NEW_NUMBER**: Target PRD number if renumbering (e.g., `002` stays the same, or `016` for renamed)
- **FEATURE_NAME**: Kebab-case feature name (e.g., `artifact-management`)

## Step-by-Step Process

### Step 1: Read and Parse the Source PRD

1. Read the entire PRD file
2. Identify sections:
   - **Overview**: Extract overview paragraph
   - **Goals/Non-Goals**: Extract from any "Goals" section
   - **User Stories**: Find all stories (look for patterns like "### US-" or "| ID | US-")
   - **Functional Requirements**: Find all FRs (look for "### FR-" patterns)
   - **Acceptance Tests/Criteria**: Find all tests (look for "### AT-" or test code blocks)
   - **NFRs, Error Handling, Dependencies**: Extract other standard sections
   - **Success Criteria**: Extract completion criteria

### Step 2: Create Directory Structure

```bash
mkdir -p project-management/PRDs/PRD-{NEW_NUMBER}-{FEATURE_NAME}/
mkdir -p project-management/PRDs/PRD-{NEW_NUMBER}-{FEATURE_NAME}/user-stories/
mkdir -p project-management/PRDs/PRD-{NEW_NUMBER}-{FEATURE_NAME}/functional-requirements/
mkdir -p project-management/PRDs/PRD-{NEW_NUMBER}-{FEATURE_NAME}/acceptance-tests/
```

### Step 3: Extract and Create User Stories

For each user story found:

1. **Create file**: `user-stories/US-{ID}-{slug}.md`
2. **Content template**:
   ```markdown
   # US-{ID}: {Title}

   **Priority**: high | medium | low
   **Story Points**: N
   **Related Personas**: persona-1, persona-2

   ## Description

   As a {persona}, I want {action} so that {benefit}.

   ## Acceptance Criteria

   - [ ] AC-1: Specific criterion
   - [ ] AC-2: Another criterion

   ## Related Requirements

   - FR-001
   - FR-002
   ```

3. **Create or update** `user-stories/index.yaml`:
   ```yaml
   user_stories:
     - id: US-001
       title: "Story Title"
       description: "One-sentence description"
       persona: persona-id
       priority: high | medium | low
       status: draft | active | completed
       file: US-001-slug.md
       related_prd: PRD-NNN
   ```

### Step 4: Extract and Create Functional Requirements

For each FR found:

1. **Create file**: `functional-requirements/FR-{ID:03d}-{slug}.md`
2. **Content template**:
   ```markdown
   # FR-{ID}: {Requirement Name}

   **Status**: Draft | Active | Completed

   ## Description

   Clear statement of what the system must do.

   ## Interface

   ```python
   def function_name(param1: Type, param2: Type) -> ReturnType:
       """Docstring with purpose and behavior."""
   ```

   ## Behavior

   - **Given** precondition or initial state
   - **When** action is taken
   - **Then** expected result occurs

   ## Edge Cases

   - **Edge case 1**: Description and handling
   - **Edge case 2**: Description and handling

   ## Related User Stories

   - US-001
   - US-002

   ## Test Coverage

   Expected test count: 8-12 tests
   Target coverage: 100% for this FR
   ```

3. **Create or update** `functional-requirements/index.yaml`:
   ```yaml
   functional_requirements:
     - id: FR-001
       name: "Requirement Name"
       description: "Brief description"
       status: draft | active | completed
       related_stories:
         - US-001
         - US-002
       expected_tests: 8
       coverage_target: 100
       file: FR-001-requirement-name.md
   ```

### Step 5: Extract and Create Acceptance Tests

For each acceptance test/criterion found:

1. **Create file**: `acceptance-tests/AT-{ID:03d}-{slug}.md`
2. **Content template**:
   ```markdown
   # AT-{ID}: {Test Name}

   **Category**: Unit | Integration | End-to-End
   **Related FR**: FR-001, FR-002
   **Status**: Not Started | In Progress | Passing | Failing

   ## Description

   Clear statement of what this test validates.

   ## Test Implementation

   ```python
   def test_something_specific():
       """Test docstring explaining the scenario."""
       # Setup
       # Action
       # Assert
   ```

   ## Acceptance Criteria

   - [ ] Condition 1 is true
   - [ ] Condition 2 is true

   ## Coverage

   Covers:
   - Normal path scenarios
   - Edge cases
   - Error conditions
   ```

3. **Create or update** `acceptance-tests/index.yaml`:
   ```yaml
   acceptance_tests:
     - id: AT-001
       name: "Test Name"
       description: "What this test validates"
       category: unit | integration | e2e
       related_fr:
         - FR-001
       status: not_started | in_progress | passing | failing
       file: AT-001-test-name.md
   ```

### Step 6: Create Main README.md

Create `project-management/PRDs/PRD-{NEW_NUMBER}-{FEATURE_NAME}/README.md`:

```markdown
# PRD-{NEW_NUMBER}: {Feature Name}

**Version**: 1.0
**Status**: Draft | Review | Approved | Implemented
**Author**: npl-prd-editor
**Created**: {timestamp}
**Updated**: {timestamp}

## Overview

{Overview paragraph from original PRD}

## Goals

1. Goal statement
2. Goal statement

## Non-Goals

- Non-goal statement

---

## User Stories

Reference stories from `./user-stories/` directory.

| ID | Title | Persona |
|----|-------|---------|
| US-001 | [Title](./user-stories/US-001-slug.md) | persona-id |

Use MCP tools to load full story details:
- **get-story**: Load story by ID
- **edit-story**: Modify story content
- **update-story**: Update story metadata

---

## Functional Requirements

All functional requirements are detailed in `./functional-requirements/` directory.

See `functional-requirements/index.yaml` for complete list.

Key requirements:
- **FR-001**: [Name](./functional-requirements/FR-001-name.md)
- **FR-002**: [Name](./functional-requirements/FR-002-name.md)

---

## Non-Functional Requirements

| ID | Requirement | Metric | Target |
|----|-------------|--------|--------|
| NFR-1 | Test coverage | Line coverage | >= 80% |

---

## Error Handling

| Error Condition | Error Type | User Message |
|-----------------|------------|--------------|
| Invalid input | ValueError | "Please provide valid input" |

---

## Acceptance Tests

All acceptance tests detailed in `./acceptance-tests/` directory.

See `acceptance-tests/index.yaml` for test plan.

---

## Success Criteria

1. All user stories implemented with acceptance criteria passing
2. Test coverage >= 80% for all new code
3. All acceptance tests passing
4. Clear and actionable error messages

---

## Out of Scope

- Item excluded from this work

---

## Dependencies

- External service/library name

---

## Open Questions

- [ ] Question about requirements?
```

### Step 7: Archive Original (Optional)

Move the original flat .md file to archive:
```bash
mv project-management/PRDs/PRD-{OLD_NUMBER}-{FEATURE_NAME}.md \
   project-management/PRDs/archive/PRD-{OLD_NUMBER}-{FEATURE_NAME}.md
```

Or rename if number changed:
```bash
mv project-management/PRDs/archive/PRD-{OLD_NUMBER}-*.md \
   project-management/PRDs/archive/PRD-{NEW_NUMBER}-*.md
```

### Step 8: Validation Checklist

Before considering this PRD complete:

- [ ] All user stories extracted to separate files
- [ ] All FRs extracted to separate files
- [ ] All ATs extracted to separate files
- [ ] user-stories/index.yaml created with all metadata
- [ ] functional-requirements/index.yaml created with all metadata
- [ ] acceptance-tests/index.yaml created with all metadata
- [ ] README.md created with only overview/links
- [ ] No inlined content remains in README.md
- [ ] All relative links work (./ paths)
- [ ] All file names follow kebab-case convention
- [ ] All IDs properly formatted (US-NNN, FR-NNN, AT-NNN)

## Extraction Patterns (for searching)

**User Stories**: Look for:
- `### US-` (heading)
- `| ID | US-` (table rows)
- `| US-` (inline references)
- Story descriptions starting with "As a..."

**Functional Requirements**: Look for:
- `### FR-` (heading)
- `### FR {N}:` (numbered)
- Function interfaces in code blocks
- "Interface" sections

**Acceptance Tests/Criteria**: Look for:
- `### AT-` (heading)
- `### AC-` or "Acceptance Criteria" sections
- Python test code blocks (`def test_`)
- Test class definitions

## Tips

1. **Preserve structure**: Keep original formatting and content as-is when moving to new files
2. **Be consistent**: Use same ID numbering as original (don't renumber)
3. **Link everything**: Update all cross-references between index.yaml files
4. **Document status**: Mark extracted items with appropriate status (draft, active, etc.)
5. **Keep descriptions brief**: In index.yaml, use one-line descriptions for clarity
6. **Test coverage**: Extract from existing PRD text; if missing, use reasonable estimates

## Success

You have successfully completed PRD refactoring when:

✅ Directory structure created with all subdirectories
✅ All extracted files created with proper naming
✅ All index.yaml files created with complete metadata
✅ Main README.md created without inlined content
✅ All validation checklist items checked
✅ All relative links functional

Report back with:
1. PRD directory path created
2. Count of files extracted (US, FR, AT)
3. Any manual decisions made (missing info, ambiguous sections)
4. Validation checklist status
5. Original file archived (if applicable)
