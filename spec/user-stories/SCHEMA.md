# User Stories YAML Schema

**Last Updated:** 2026-03-04
**Purpose:** Defines the structure for the `stories.yaml` index file

---

## YAML Structure

```yaml
stories:
  - id: "US-001"                    # Story identifier
    title: "Global Hotkey Activation"  # Short descriptive title
    user_story: "As a developer, I want to press..."  # Full user story
    scenarios:                       # List of BDD scenarios
      - given: "the application is running"
        when: "The user presses hotkey"
        then: "popup appears"
    notes:                           # Metadata from Notes section
      persona: "both"                # developer, knowledge-worker, or both
      t_shirt_size: "S"              # XS, S, M, L, XL
      complexity: "medium"           # low, medium, high, very-high
      risks: "Conflicts with other apps"  # Any risks identified
      dependencies: ["US-000"]       # Array of dependency IDs
    stage: 0                         # Roadmap stage (0-7)
    impacts: ["ux", "performance"]   # Areas impacted (optional)
    status: "pending"                # pending, in_progress, completed
```

---

## Field Descriptions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | ✅ | Story identifier (US-XXX) |
| `title` | string | ✅ | Short title from first heading |
| `user_story` | string | ✅ | Full "As a... I want... so that..." text |
| `scenarios` | array | ✅ | List of given/when/then scenarios |
| `notes.persona` | string | ✅ | Target persona(s) |
| `notes.t_shirt_size` | string | ✅ | Size estimate (XS/S/M/L/XL) |
| `notes.complexity` | string | ✅ | Complexity (low/medium/high/very-high) |
| `notes.risks` | string | ❌ | Identified risks |
| `notes.dependencies` | array | ❌ | Dependency IDs |
| `stage` | integer | ✅ | Roadmap stage (0-7) |
| `impacts` | array | ❌ | Areas affected |
| `status` | string | ✅ | Current implementation status |

---

## Stage Mapping

| US Range | Stage |
|----------|-------|
| US-001 | 0 |
| US-002-003 | 1 |
| US-004-006 | 2 |
| US-007-010 | 3 |
| US-011-013 | 4 |
| US-014-017 | 5 |
| US-018-022 | 6 |
| US-023-028 | 7 |
| US-029-033 | Performance |
| US-034-042 | Security |
| US-043-046 | Accessibility |
| US-047-049 | Localization |
| US-050-055 | Edge Cases |
| US-056 | Developer |
| US-057-058 | Onboarding |
| US-059-060 | Favorites |
| US-061-065 | Foundation |
| US-066-069 | AI/ML |
| US-070-071 | Analytics/Sync |

---

## yq Query Examples

**Count stories:**
```bash
yq '.stories | length' stories.yaml
```

**List all IDs and titles:**
```bash
yq '.stories[] | .id + ": " + .title' stories.yaml
```

**Filter by stage:**
```bash
yq '.stories[] | select(.stage == 0)' stories.yaml
```

**Filter by t-shirt size:**
```bash
yq '.stories[] | select(.t_shirt_size == "XL") | .id + " " + .title' stories.yaml
```

**Filter by persona:**
```bash
yq '.stories[] | select(.notes.persona == "developer") | .id' stories.yaml
```

**Filter by status:**
```bash
yq '.stories[] | select(.status == "completed")' stories.yaml
```

**Get specific story:**
```bash
yq '.stories[] | select(.id == "US-001")' stories.yaml
```

<!-- nav -->

---

[Table of Contents](../../product-spec.md) | [Next: US-001: Global Hotkey Activation >](US-001.md)

<!-- nav -->
