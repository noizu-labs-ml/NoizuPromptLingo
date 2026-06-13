# User Story: Quick Form Fill for Developers

**ID**: US-020
**Persona**: P-003 (Vibe Coder)
**Priority**: Medium
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a **vibe coder**,
I want to **quickly fill web forms using AI assistance**,
So that **I do not have to repeatedly enter the same test data manually**.

## Acceptance Criteria

### Core Functionality
- [ ] Can fill specific form field by selector with `browser_fill(selector, value)`
- [ ] Can fill multiple fields in one command using field mapping: `browser_fill_form({"#email": "test@example.com", "#password": "pass123"})`
- [ ] Supports typing simulation with configurable delay: `browser_type(selector, text, delay_ms=50)`
- [ ] Works with dynamically rendered forms (waits for elements to be available)
- [ ] Returns structured feedback: `{filled: ["#email", "#password"], failed: [], duration_ms: 234}`

### Quick Access Patterns
- [ ] Can save form profiles: `save_form_profile(name="login-test-user", data={...})`
- [ ] Can apply saved profile: `fill_from_profile(name="login-test-user")`
- [ ] Lists available profiles: `list_form_profiles() → ["login-test-user", "registration-basic", ...]`
- [ ] Profiles stored in session-scoped or global scope (user configurable)

### Field Discovery
- [ ] Can query fillable fields on current page: `browser_query_elements("input, textarea, select")`
- [ ] Returns field metadata: `{selector, type, name, placeholder, required, current_value}`
- [ ] Can auto-detect form structure and suggest field mappings

## Workflow Example

**Scenario**: Developer needs to test login flow repeatedly during development.

```python
# First time: Discover fields
fields = browser_query_elements("input")
# Returns: [{"selector": "#email", "type": "email"}, {"selector": "#password", "type": "password"}]

# Fill manually
browser_fill_form({"#email": "test@example.com", "#password": "testpass123"})

# Save as profile for reuse
save_form_profile(name="login-test-user", data={
    "#email": "test@example.com",
    "#password": "testpass123"
})

# Later sessions: Quick fill
fill_from_profile(name="login-test-user")
# Takes ~200ms vs ~30s manual typing
```

**Quick Access Advantage**:
- Manual typing: ~30-60 seconds per form
- Profile-based fill: ~200-500ms
- **Time saved**: ~150x faster for repeated testing

## Notes

- **Developer productivity**: Eliminates repetitive manual data entry during testing
- **Profile library**: Ship common test profiles with project (e.g., `.npl/form-profiles/`)
- **Use cases**: Login forms, registration, checkout flows, search filters, config panels
- **Safety**: Profiles stored locally, never transmitted to external services

## Technical Considerations

### Field Discovery
- Use `querySelectorAll("input, textarea, select")` to find fillable elements
- Extract metadata: `name`, `id`, `type`, `placeholder`, `required` attributes
- Handle shadow DOM and iframes if needed

### Profile Storage
- Store profiles as JSON files in `.npl/form-profiles/{name}.json`
- Structure: `{"url_pattern": "*/login", "fields": {"#email": "...", ...}, "metadata": {...}}`
- Support both session-scoped (temporary) and persistent profiles

### Typing Simulation
- Character-by-character typing with configurable delay (default 50ms)
- Triggers input events, change events, and keyboard events
- Necessary for forms with JavaScript validation on keystroke

## Related Commands

### Browser Tools
- `browser_fill(selector, value)` - Fill single field instantly
- `browser_fill_form(field_map)` - Fill multiple fields from mapping
- `browser_type(selector, text, delay_ms)` - Type with character-by-character simulation
- `browser_query_elements(css_selector)` - Discover fillable fields

### Profile Management
- `save_form_profile(name, data, scope="session"|"global")` - Save reusable profile
- `fill_from_profile(name)` - Apply saved profile to current form
- `list_form_profiles()` - Show available profiles
- `delete_form_profile(name)` - Remove saved profile

## Examples

### Basic Form Fill
```python
# Fill login form
browser_fill_form({
    "#email": "developer@example.com",
    "#password": "dev123",
    "#remember-me": True
})
```

### With Typing Simulation
```python
# Trigger keystroke validation
browser_type("#search-query", "test query", delay_ms=100)
```

### Profile-Based Workflow
```python
# Save profile
save_form_profile("checkout-test", {
    "#cc-number": "4242424242424242",
    "#cc-exp": "12/28",
    "#cc-cvv": "123"
})

# Reuse across sessions
fill_from_profile("checkout-test")
```
