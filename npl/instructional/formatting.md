# Output Formatting Patterns and Templates
<!-- labels: [formatting, templates, output] -->

Comprehensive overview of NPL formatting conventions for structured output generation and template systems.

<!-- instructional: conceptual-explanation | level: 0 | labels: [formatting, overview] -->
## Purpose

NPL formatting patterns provide structured approaches to defining input/output shapes, examples, and reusable templates that control how agents generate responses. These patterns ensure consistency across different output types and enable precise specification of desired formats.

<!-- instructional: quick-reference | level: 0 | labels: [formatting, types] -->
## Core Formatting Types

| Type | Fence | Purpose |
|------|-------|---------|
| Template Definition | `⌜🧱 name⌝...⌞🧱 name⌟` | Reusable output structures |
| Input Syntax | ` ```input-syntax ` | Expected input structure |
| Output Syntax | ` ```output-syntax ` | Desired output structure |
| Combined Format | ` ```format ` | Complete I/O specification |
| Input Example | ` ```input-example ` | Actual input sample |
| Output Example | ` ```output-example ` | Actual output sample |
| General Example | ` ```example ` | Sample I/O pair |

### Template Definition
<!-- level: 1 | labels: [template, reusable] -->
```syntax
⌜🧱 template-name⌝
@with NPL@1.0
```template
<template structure with placeholders>
```
⌞🧱 template-name⌟
```

### Input/Output Specification
<!-- level: 0 | labels: [format, structure] -->

| Fence Type | Purpose |
|------------|---------|
| `input-syntax` | Expected input structure |
| `output-syntax` | Desired output structure |
| `format` | Complete specification |

### Example Structures
<!-- level: 0 | labels: [examples, demonstration] -->

| Fence Type | Purpose |
|------------|---------|
| `input-example` | Actual input sample |
| `output-example` | Actual output sample |
| `example` | Sample I/O pair |

<!-- instructional: usage-guideline | level: 0 | labels: [patterns, examples] -->
## Common Formatting Patterns

### Structured Data Layout
<!-- level: 0 -->
```example
Hello <user.name>,
Did you know [...|funny factoid].

Have a great day!
```

### Conditional Formatting
<!-- level: 1 -->
```example
{{if user.role == 'admin'}}
Welcome to the admin panel!
{{else}}
Welcome to the user dashboard!
{{/if}}
```

### Iterative Content Generation
<!-- level: 1 -->
```example
# User List
{{foreach users as user}}
## <user.name>
Role: <user.role>
Bio: [...2-3s|user description]
{{/foreach}}
```

### Template Integration
<!-- level: 1 -->
```example
Business Profile:
⟪⇆: user-template | with executive data⟫
```

---

<!-- instructional: quick-reference | level: 0 | labels: [size, qualifiers] -->
## Size and Content Qualifiers

### Size Indicators

| Marker | Meaning | Example |
|--------|---------|---------|
| `p` | paragraphs | `[...2p]` |
| `pg` | pages | `[...1pg]` |
| `l` | lines | `[...5l]` |
| `s` | sentences | `[...2-3s]` |
| `w` | words | `[...3-5w]` |
| `i` | items | `[...5i]` |
| `r` | rows | `[...10r]` |
| `t` | tokens | `[...100t]` |

### Content Qualifiers
<!-- level: 1 -->
```syntax
<term|qualifier>
[...|specific instructions]
{data|transformation rules}
```

---

<!-- instructional: conceptual-explanation | level: 1 | labels: [advanced, features] -->
## Advanced Formatting Features

### Table Formatting
```syntax
⟪📅: (column alignments and labels) | content description⟫
```

### Template Variables

| Style | Syntax | Purpose |
|-------|--------|---------|
| Simple | `<variable>` | Direct substitution |
| Qualified | `<variable\|qualifier>` | Constrained substitution |
| Sized | `<<size>:variable>` | Size-controlled content |
| Conditional | `{variable\|default}` | Fallback value |

### Content Omission

| Pattern | Purpose |
|---------|---------|
| `[...#unique-name]` | Named clipping (user-requestable continuation) |
| `[___]` | Simple omission (expected but omitted) |

---

<!-- instructional: usage-guideline | level: 1 | labels: [control, structure] -->
## Formatting Control Mechanisms

### Output Structure Definition
<!-- level: 1 -->
```format
Header: <title>
🎯 Key Point: [...1s|main message]

## Details
[...2-3p|supporting information]

## References
[...3-5i|related links or sources]
```

### Response Mode Integration
<!-- level: 1 -->
```example
📄➤ Summarize this document:
# <document.title>

**Overview**: [...2-3s|key summary]

**Main Points**:
- [...|point 1]
- [...|point 2]
- [...|point 3]

**Conclusion**: [...1s|final takeaway]
```

### Multi-Format Support
<!-- level: 2 -->
```template
{{if output_format == 'brief'}}
<title>: [...1s|summary]
{{else}}
# <title>
[...2-3p|detailed explanation]

## Key Points
[...5-7i|bullet list]
{{/if}}
```

---

<!-- instructional: integration-pattern | level: 1 | labels: [templates, reuse] -->
## Template Reuse and Inheritance

### Named Template Declaration
<!-- level: 1 -->
```syntax
⌜🧱 user-card⌝
@with NPL@1.0
**<user.name>** (<user.role>)
Contact: <user.email>
Bio: [...2s|user background]
⌞🧱 user-card⌟
```

### Template Application
<!-- level: 1 -->
```syntax
# Team Directory
{{foreach team_members as member}}
⟪⇆: user-card | with member data⟫
﹍
{{/foreach}}
```

---

<!-- instructional: best-practice | level: 1 | labels: [guidelines, quality] -->
## Best Practices

### Consistency Guidelines
- Use standardized size indicators across all templates
- Apply consistent placeholder naming conventions
- Maintain uniform formatting styles within template families

### Modularity Principles
- Create reusable templates for common output patterns
- Design templates that work across different content types
- Enable template composition for complex output structures

### User Experience Optimization
- Provide clear examples alongside format specifications
- Use meaningful placeholder names that indicate expected content
- Include fallback patterns for edge cases

