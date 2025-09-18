# Technical Writing Style Guide

This is a template for technical writing style guides used by NPL technical writer agents.

## Voice and Tone

### Writing Style
- **Direct and precise**: State facts without unnecessary qualifiers
- **Active voice preferred**: "The system processes requests" not "Requests are processed by the system"
- **Present tense for instructions**: "Click Save" not "You will click Save"
- **Concise language**: Remove filler words and redundant phrases

### Professional Tone
- Authoritative but not condescending
- Helpful and informative
- Objective and factual
- Accessible to target technical audience

## Structure and Organization

### Document Structure
- **Lead with key information**: Most important content first
- **Logical progression**: Build concepts step by step
- **Clear headings**: Use descriptive section headers
- **Scannable format**: Bullet points and numbered lists

### Section Guidelines
- Use `##` for major sections
- Use `###` for subsections
- Use `####` sparingly for deep nesting
- Include table of contents for long documents

## Language Guidelines

### Terminology
- **Consistent terms**: Use the same word for the same concept throughout
- **Standard definitions**: Follow industry-standard terminology
- **Avoid jargon**: Explain technical terms when first introduced
- **Precise language**: Choose specific words over general ones

### Avoid These Patterns
- ❌ "It's worth noting that..."
- ❌ "Please be aware that..."
- ❌ "Obviously" or "Clearly"
- ❌ "Simply" or "Just"
- ❌ "Various" or "Different"
- ❌ Marketing language or buzzwords

### Use These Instead
- ✅ "Note:" or direct statement
- ✅ Specific action verbs
- ✅ Exact numbers and measurements
- ✅ Concrete examples
- ✅ Standard technical vocabulary

## Code and Examples

### Code Blocks
- Always specify language for syntax highlighting
- Include complete, runnable examples when possible
- Add comments to explain complex logic
- Use consistent formatting and indentation

### Example Format
```javascript
// Good: Complete, commented example
function authenticateUser(credentials) {
  // Validate input parameters
  if (!credentials.username || !credentials.password) {
    throw new Error('Missing required credentials');
  }
  
  // Return authentication result
  return auth.verify(credentials);
}
```

### API Documentation
- Include all required parameters
- Show example requests and responses
- Document error codes and messages
- Provide working code samples

## Formatting Standards

### Lists and Bullets
- Use bullet points for unordered information
- Use numbered lists for sequential steps
- Keep list items parallel in structure
- Use consistent bullet style (- or *)

### Tables
- Include headers for all columns
- Keep cell content concise
- Use tables for structured data comparison
- Ensure table accessibility

### Links and References
- Use descriptive link text
- Link to authoritative sources
- Keep external links current
- Use relative links for internal content

## Review and Quality

### Before Publishing
- [ ] All code examples tested and working
- [ ] Links verified and functional
- [ ] Spelling and grammar checked
- [ ] Technical accuracy verified
- [ ] Consistent terminology throughout

### Content Checklist
- [ ] Clear purpose and audience identified
- [ ] Logical information flow
- [ ] Complete coverage of topic
- [ ] No unnecessary complexity
- [ ] Actionable information provided

## Version Information

### Document Metadata
- Include creation date
- Note last updated date
- Specify applicable software versions
- Document review cycle

### Change Management
- Track significant revisions
- Note breaking changes
- Update dependent documentation
- Communicate changes to team

---

# Style Control Flag
+load-default-styles

## Usage Notes

This template can be customized for specific teams, projects, or organizations while maintaining compatibility with NPL technical writer agents. The `+load-default-styles` flag above ensures that additional style guides in the hierarchy will also be loaded.

### Customization Areas
- Adjust voice and tone for your organization
- Add company-specific terminology guidelines
- Include project-specific formatting rules
- Define review and approval processes

### Integration with NPL Agents
This style guide is automatically loaded by `npl-technical-writer` agents when placed in the appropriate directory hierarchy:

- `~/.claude/npl-m/house-style/technical-style.md` (personal/global)
- `.claude/npl-m/house-style/technical-style.md` (project-wide)
- `{path}/house-style/technical-style.md` (directory-specific)

Environment variable override:
```bash
export HOUSE_STYLE_TECHNICAL="/path/to/custom-style.md"
```