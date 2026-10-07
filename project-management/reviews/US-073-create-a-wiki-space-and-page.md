# Review: Create a Wiki Space and Page

- **Story**: `project-management/user-stories/US-073-create-a-wiki-space-and-page.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Fully present on the Elixir backend. `Wiki.SpaceCreate` (`backend/lib/noizu_prompt_lingua/domains/wiki/tools/space_create.ex:20-58`) resolves org (and optional project), then inserts via `Wiki.create_space/1`; `Wiki.SpaceList` lists immediately. `Wiki.PageCreate` (`tools/page_create.ex:21-53`) creates a page with title/content under a validated space, auto-derives slug and appends a position (`wiki.ex:87-96`, `default_position/1` at `wiki.ex:300-313`), and pages are retrievable via `PageList`/`PageGet`/slug. Duplicate space names: `Schema.Wiki.Space` enforces `unique_constraint([:organization_id, :slug])` (`schema/wiki/space.ex:27`, index `idx_wiki_spaces_org_slug`) and `space_create.ex:45-47` surfaces the changeset errors. Note the uniqueness key is slug (name-derived), so two spaces can share a display `name` only if their slugs differ; same-name-implies-same-slug collisions are rejected. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| New Space with name + description appears in project's Space list immediately | Met | `space_create.ex:26-43` (insert returns created space); `space_list.ex` + `wiki.ex:16-25` list org/project-scoped spaces directly from the same table |
| New Page with title + body is listed under the Space and retrievable by title | Met | `page_create.ex:29-51` (validates space exists, inserts); `wiki.ex:56-64` `list_pages` scoped to space; `get_page_by_slug/2` (`wiki.ex:68-69`) and `PageGet` retrieve by slug derived from title |
| Duplicate-named Space rejected with clear naming-conflict error | Met | `schema/wiki/space.ex:27` unique constraint on (org, slug); `space_create.ex:45-47` returns `{:error, "Failed: [slug: {\"has already been taken\", ...}]"}` — message names the conflict, though it is a raw changeset-error inspect rather than polished prose |

## Gaps / Risks

- Duplicate-name detection is slug-based: "Deploy Notes" and "deploy  notes!" slugify to the same slug and conflict, while names differing after slugification can coexist — acceptable but worth documenting.
- Error strings use `inspect(changeset.errors)` (e.g. `space_create.ex:46`) — machine-readable but not user-friendly.
- No per-user permission check on create (unguarded tool, see US-072 review).

## BDD Scenario

```gherkin
Feature: Create a wiki space and page

  Scenario: Stand up project documentation
    When the agent calls Wiki.SpaceCreate with organization=<org>, project=<proj>, name="Runbooks", description="Ops docs"
    Then the response returns the new space id/slug
    And Wiki.SpaceList with project=<proj> includes "Runbooks" immediately

  Scenario: Add the first page
    When the agent calls Wiki.PageCreate with space=<Runbooks UUID>, title="Deploy Pipeline", content="# Steps..."
    Then Wiki.PageList(space=<Runbooks UUID>) lists "Deploy Pipeline"
    And Wiki.PageGet(page=<id>) returns the body; position defaults to 1

  Scenario: Duplicate space name
    Given a space "Runbooks" already exists in the org
    When Wiki.SpaceCreate is called again with name="Runbooks" (same slug)
    Then the call fails with a slug "has already been taken" changeset error
```
