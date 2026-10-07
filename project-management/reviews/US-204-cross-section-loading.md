# Review: Cross-Section Loading with Additions and Subtractions

- **Story**: `project-management/user-stories/US-204-cross-section-loading.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Cross-section loading is implemented in the parser (whitespace-separated terms with leading `-` for subtraction, `src/npl_mcp/npl/parser.py:148-209`) and the resolver, which processes all additions before subtractions, warns (not errors) on subtracting non-loaded components, and returns components in stable first-occurrence order (`src/npl_mcp/npl/resolver.py:205-277`). Validation matches the story's error table closely: unknown section → NPLParseError listing valid sections (parser.py:113-116), unknown component → NPLResolveError listing available (resolver.py:198-203), `:+-1` → NPLParseError "Invalid priority format" (parser.py:124-137), empty → NPLParseError "Expression cannot be empty" (parser.py:174-175) — all verified live. The gap is again real-data slug keying: sections whose YAML components lack `slug:` fields (syntax, directives, prefixes, special-sections, prompt-sections) cannot be loaded by specific component, so expressions like `syntax#placeholder` fail and the corresponding subtractions become silent no-op warnings.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| AC-4.1: Mix sections via `syntax directive` | Partially Met | `syntax directives` works live; singular `directive` form errors ("Unknown section: 'directive'") — story examples use a section name that doesn't exist |
| AC-4.2: Subtract via `syntax -syntax#literal-string` | Partially Met | Expression parses and runs live, but `literal-string` is not loadable from real syntax.yaml (no slug fields), so the subtraction only logs a warning (`resolver.py:247-251`) |
| AC-4.3: Mix specific loads `syntax#placeholder pumps#intent-declaration` | Partially Met | `pumps#intent-declaration` resolves; `syntax#placeholder` raises NPLResolveError on real data (verified live) |
| AC-4.4: Validation for invalid sections/components/malformed | Met | All three error classes verified live: NPLParseError (`parser.py:113-116,101-106`), NPLResolveError (`resolver.py:198-203`), priority-format NPLParseError (`parser.py:124-137`) |
| AC-4.5: Clear error messages with helpful context | Met | Messages include valid-section list, expression format hints, and priority usage examples (parser.py:113-137); caveat: "Available components:" lists can be empty on slug-less sections |
| AC-4.6: Order of operations: sections, then additions, then subtractions | Met | Resolver processes additions then subtractions in order (`resolver.py:223-251`); non-loaded subtraction warns without error; stable output order (`resolver.py:253-277`) |

## Gaps / Risks

- Cross-cutting root cause (shared with US-201): resolver keys components on `slug` while five of eight conventions YAML files key components on `name` only — specific-component cross-section loads fail against real data.
- Empty "Available components:" in resolve errors reduces the helpfulness AC-4.5 credits.
- The story's error-table example `syntax#placeholder:-1` yields the specified NPLParseError (verified) — good parity there.
- `directive` singular appears throughout story examples but only `directives` is a valid section — story text should be normalized.

## BDD Scenario

```gherkin
Feature: Cross-section loading with additions and subtractions
  As a system builder using the NPLLoad MCP tool
  I want to compose custom NPL contexts across sections

  Scenario: Mix two full sections
    When I call NPLLoad with expression "syntax directives"
    Then components from both sections are returned in YAML order per section

  Scenario: Load a section and exclude a component
    When I call NPLLoad with expression "pumps -pumps#mood"
    Then all pumps except mood are returned
    When I call NPLLoad with expression "syntax -syntax#literal-string"
    Then syntax is returned and a warning notes literal-string was not in the loaded set

  Scenario: Invalid expression
    When I call NPLLoad with expression "syntax foobar"
    Then NPLParseError lists the valid sections
    When I call NPLLoad with expression "syntax#placeholder:-1"
    Then NPLParseError explains the :+N priority format

  Scenario: Specific component from a slug-less section
    When I call NPLLoad with expression "syntax#placeholder pumps#intent-declaration"
    Then today the call fails with NPLResolveError for 'placeholder' in section 'syntax'
```
