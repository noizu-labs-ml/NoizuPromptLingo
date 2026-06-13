# Domain Model

## Entity Types

### Universe

Top-level container for a creative world. Each universe is independently scoped — entries, connections, flags, and generations are all universe-local.

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | URL-safe slug (e.g., `ashward-chronicles`) |
| `name` | string | Display name |
| `genre` | string | Genre label (e.g., "Dark Fantasy") |
| `description` | string | Short summary |
| `entryCount` | number | Denormalized count of entries |
| `flagCount` | number | Denormalized count of unresolved flags |
| `connectionCount` | number | Denormalized count of connections |
| `updatedAt` | string (ISO 8601) | Last modification timestamp |

### Entry

A knowledge article within a universe. The fundamental unit of the knowledge graph.

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique identifier |
| `type` | EntryType | One of: `character`, `location`, `event`, `faction`, `object`, `concept`, `rule` |
| `status` | EntryStatus | `canon` (human-approved) or `generated` (AI-produced, pending review) |
| `title` | string | Entry heading |
| `excerpt` | string | Short summary for cards/lists |
| `body` | string | Full content |
| `tags` | string[] | Freeform tags |
| `era` | string? | Optional temporal grouping |
| `region` | string? | Optional spatial grouping |
| `wordCount` | number | Body word count |
| `version` | number | Revision counter |
| `createdAt` | string (ISO 8601) | Creation timestamp |
| `updatedAt` | string (ISO 8601) | Last edit timestamp |
| `connectionIds` | string[] | IDs of related connections |

### Connection

A typed, directed relationship between two entries.

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique identifier |
| `sourceId` | string | Origin entry ID |
| `targetId` | string | Destination entry ID |
| `relationship` | string | Freeform label (e.g., "ruler of", "located in") |

### Flag

A consistency issue detected across entries.

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique identifier |
| `severity` | FlagSeverity | `error` (contradiction), `warning` (possible conflict), `suggestion` |
| `title` | string | Short description |
| `detail` | string | Explanation of the inconsistency |
| `entryIds` | string[] | Entries involved |
| `resolved` | boolean | Whether the flag has been addressed |

### Generation

An AI generation request and its output.

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique identifier |
| `prompt` | string | User's generation prompt |
| `entryType` | EntryType | Type of entry to generate |
| `status` | GenerationStatus | `pending`, `complete`, `promoted` (accepted as canon), `discarded` |
| `outputTitle` | string? | Generated entry title |
| `outputBody` | string? | Generated entry content |
| `sourceEntryIds` | string[] | Context entries fed to the LLM |
| `createdAt` | string (ISO 8601) | Request timestamp |

## Type Enumerations

**EntryType**: `character` · `location` · `event` · `faction` · `object` · `concept` · `rule`

**EntryStatus**: `canon` · `generated`

**FlagSeverity**: `error` · `warning` · `suggestion`

**GenerationStatus**: `pending` · `complete` · `promoted` · `discarded`
