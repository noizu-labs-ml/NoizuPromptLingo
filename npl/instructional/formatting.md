# Output Formatting Patterns and Templates
<!-- labels: [formatting, templates, output] -->

Comprehensive overview of NPL formatting conventions for structured output generation and template systems.

<!-- instructional: conceptual-explanation | level: 0 | labels: [formatting, overview] -->
## Purpose

NPL formatting patterns provide structured approaches to defining input/output shapes, examples, and reusable templates that control how agents generate responses. These patterns ensure consistency across different output types and enable precise specification of desired formats.

### Template Definition

[...|description]

#### Syntax
<!-- level: 1 | labels: [template, reusable] -->
````syntax
⌜🧱 template-slug⌝
@with NPL@{version}

# {template.name}
{template.description}

## Inputs

```inputs
[___| input arguments]
```

## Template

```template
[___|template structure with placeholders]
```

## Examples

### {Example}

```example
[___]
```

⌞🧱 template-name⌟
````

#### Input/Output Specification
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



# Instructioanl Notes


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

<!-- instructional: conceptual-explanation | level: 1 | labels: [advanced, features] -->
## Advanced Formatting Features

### Table Formatting
```syntax
⟪📅: (column alignments and labels) | content description⟫
```


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

**Overview**: [___:2-3sentence|key summary]

**Main Points**:
- [___|point 1]
- [___|point 2]
- [___|point 3]

**Conclusion**: [___:1sentence|final takeaway]
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

### Template Content Format
<!-- level: 1 -->
Templates support:
- Placeholder substitution using `{variable.path}`
- HTML-like formatting tags
- Conditional logic integration
- Data iteration patterns

### Template Parameters
<!-- level: 1 -->
- `name`: Unique identifier for the template
- Template content uses handlebar-like syntax for placeholders
- Optional NPL version specification with `@with NPL@version`

---

<!-- instructional: conceptual-explanation | level: 1 | labels: [input, specification] -->
## Input Syntax Specification

Input format specifications define the expected structure and format for input data, parameters, and user-provided content within prompts and agent interactions. Input syntax specifications help agents understand the expected format of data they will receive, enabling proper parsing and processing.

### Fence Block Format
<!-- level: 0 -->
```example
```input-syntax
<user.name>: string
<user.age>: number|optional
<preferences>: array|comma-separated
```
```

### Inline Specifications
<!-- level: 0 -->
```example
Expected input: `{user.name | string}`, `{preferences | list of items}`
```

### Handlebar-Style Input
<!-- level: 1 -->
```example
```input-syntax
{{user.profile}}
  name: <string>
  email: <email-format>
  preferences: [<item>, <item>, ...]
{{/user.profile}}
```
```

### Input Types
<!-- level: 0 -->
Common input type indicators:
- `string` - Text input
- `number` - Numeric values
- `email-format` - Email addresses
- `array` - List of items
- `optional` - Non-required field
- `comma-separated` - List format
- `json` - JSON structured data

### Input Qualifiers
<!-- level: 1 -->
Input specifications support qualifiers:
- `|optional` - Field is not required
- `|required` - Field must be provided
- `|default:value` - Default value if not specified
- `|format:pattern` - Expected format pattern

### Validation Patterns
<!-- level: 1 -->
```example
```input-syntax
<username>: string|pattern:^[a-zA-Z0-9_]+$
<password>: string|min-length:8
<age>: number|range:18-100
```
```

---

<!-- instructional: conceptual-explanation | level: 1 | labels: [output, specification] -->
## Output Syntax Specification

Output syntax definitions specify the exact format, structure, and styling requirements for agent-generated output to ensure consistency and meet user expectations. They guide agents in constructing responses that match specific formatting requirements, including text layout, data presentation, and structural elements.

### Basic Output Format
<!-- level: 0 -->
````example
```output-format
Hello <user.name>,
Did you know [...|funny factoid].

Have a great day!
```
````

### Structured Response Format
<!-- level: 1 -->
````example
```output-syntax
# Report Title
Date: <current-date|Y-M-D format>
Status: <status|success/warning/error>

## Summary
[...2-3s|brief summary]

## Details
{{foreach items as item}}
- <item.name>: <item.description>
{{/foreach}}
```
````

### Business Profile Format
<!-- level: 1 -->
````example
```output-syntax
Business Name: <business.name>
About the Business: <business.about>

## Executives
{foreach business.executives as executive}
- Name: <executive.name>
- Role: <executive.role>
- Bio: <executive.bio>
⟪⇐: user-template | with the data of each executive.⟫
{/foreach}
```
````

### Format Elements
<!-- level: 0 -->

**Text Formatting:**
- `<term>` - Variable substitution
- `{term}` - Dynamic content placeholder
- `[...]` - Generated content sections
- `⟪...⟫` - Directive integration

**Size Indicators:**
- `[...1s]` - One sentence
- `[...2-3p]` - Two to three paragraphs
- `[...5w]` - Five words
- `[...3-5+r]` - Three to five or more rows

**Structure Elements:**
- Headers using `#`, `##`, `###`
- Lists using `-`, `*`, or numbered format
- Code blocks using triple backticks
- Table formatting specifications

### Template Integration in Output
<!-- level: 1 -->
````example
```output-syntax
{{template:user-card | for each team member}}
{{template:stats-summary | with current metrics}}
```
````

### Conditional Output
<!-- level: 1 -->
````example
```output-syntax
{{if user.role == 'admin'}}
## Admin Panel
[...admin-specific-content]
{{else}}
## User Dashboard
[...user-specific-content]
{{/if}}
```
````

<!-- instructional: usage-guideline | level: 1 | labels: [input, examples] -->
## Input Example Patterns

Input example structures provide concrete examples of expected input formats to clarify data structure requirements and guide proper usage of agents and templates. They serve as reference implementations showing the exact format and content structure expected by agents.

### User Profile Input
<!-- level: 0 -->
````example
```input-example
{
  "user": {
    "name": "John Smith",
    "email": "john.smith@example.com",
    "age": 29,
    "preferences": ["technology", "sports", "music"],
    "role": "administrator"
  }
}
```
````

### Natural Language Input
<!-- level: 0 -->
````example
```input-example
Generate a report about quarterly sales performance including:
- Revenue breakdown by region
- Top performing products
- Customer satisfaction metrics
- Recommendations for next quarter
```
````

### Structured Query Input
<!-- level: 1 -->
````example
```input-example
@search-agent find restaurants
location: "downtown Seattle"
cuisine: ["italian", "mexican", "asian"]
price_range: "$$-$$$"
dietary_restrictions: ["vegetarian options"]
```
````

### Template Data Input
<!-- level: 1 -->
````example
```input-example
business: {
  name: "Tech Solutions Inc",
  about: "Leading provider of innovative technology solutions",
  executives: [
    {
      name: "Sarah Johnson",
      role: "CEO",
      bio: "15 years experience in tech leadership"
    },
    {
      name: "Mike Chen",
      role: "CTO",
      bio: "Expert in cloud architecture and AI systems"
    }
  ],
  board_advisors: [
    {
      name: "Dr. Emily Watson",
      role: "Strategic Advisor",
      bio: "Former VP of Engineering at Fortune 500 company"
    }
  ]
}
```
````

### Form Submission Input
<!-- level: 1 -->
````example
```input-example
username: techuser123
password: SecurePass789!
email: user@techcorp.com
full_name: Alice Rodriguez
department: Engineering
access_level: standard
newsletter_signup: true
```
````

### Multi-format Input
<!-- level: 2 -->
````example
```input-example
# Request Parameters
action: "analyze_sentiment"
text: "I love this new product! It works perfectly and the customer service was amazing."
options: {
  include_confidence: true,
  detailed_breakdown: true,
  language: "en"
}

# Expected Response Format
sentiment: positive|negative|neutral
confidence: 0.0-1.0
details: [...analysis explanation]
```
````

### Input Validation Examples
<!-- level: 1 -->
````example
```input-example
# Valid inputs:
username: "alice_smith" ✔
age: 25 ✔
email: "alice@company.com" ✔

# Invalid inputs:
username: "alice@#$" ❌ (contains special characters)
age: "twenty-five" ❌ (not numeric)
email: "invalid-email" ❌ (missing @ and domain)
```
````

### Complex Structure Examples
<!-- level: 2 -->
````example
```input-example
project: {
  name: "Website Redesign",
  timeline: {
    start_date: "2024-01-15",
    end_date: "2024-06-30",
    milestones: [
      { name: "Design Phase", due: "2024-03-01" },
      { name: "Development Phase", due: "2024-05-15" },
      { name: "Testing Phase", due: "2024-06-15" }
    ]
  },
  team: [
    { role: "Project Manager", name: "John Doe" },
    { role: "Designer", name: "Jane Smith" },
    { role: "Developer", name: "Bob Johnson" }
  ]
}
```
````

---

<!-- instructional: usage-guideline | level: 1 | labels: [output, examples] -->
## Output Example Patterns

Output example structures provide concrete examples of expected output formats to demonstrate proper response structure, formatting, and content organization patterns that agents should follow. They serve as reference implementations showing the exact format, style, and content structure that agents should produce.

### Basic Response Format
<!-- level: 0 -->
````example
```output-example
Hello John Smith,
Did you know cats can rotate their ears 180 degrees to pinpoint the source of sounds?

Have a great day!
```
````

### Structured Report Format
<!-- level: 1 -->
````example
```output-example
# Quarterly Sales Report
Date: 2024-03-31
Status: Complete

## Summary
Q1 2024 showed strong growth with 15% increase in revenue compared to Q4 2023. Customer satisfaction remained high at 4.2/5.0 average rating.

## Revenue Breakdown
- North America: $2.4M (60%)
- Europe: $1.2M (30%)
- Asia-Pacific: $400K (10%)

## Top Performing Products
1. Cloud Platform Pro - $800K revenue
2. Analytics Suite - $600K revenue
3. Mobile App Premium - $400K revenue
```
````

### Template-Integrated Output
<!-- level: 1 -->
````example
```output-example
Business Name: Tech Solutions Inc
About the Business: Leading provider of innovative technology solutions

## Executives
- Name: Sarah Johnson
- Role: CEO
- Bio: 15 years experience in tech leadership

# Sarah Johnson
dob: 1978-05-12
bio: Visionary leader with deep expertise in technology strategy

- Name: Mike Chen
- Role: CTO
- Bio: Expert in cloud architecture and AI systems

# Mike Chen
dob: 1985-09-03
bio: Technical innovator specializing in scalable system design
```
````

### Cat Facts Service Output
<!-- level: 2 -->
````example
```output-example
date: 2024-12-15
🙋cat-facts: habitat

```catfact
Domestic cats are naturally adaptable to various habitats, from urban apartments to rural farms. In the wild, cats prefer areas with adequate shelter, water sources, and prey availability, which explains why they often seek out spaces like garages, sheds, or dense vegetation.
```

# Cat Beeds
## Scottish Fold
Scottish Folds are quirky-looking cats known for their unique folded ear structure. They are gentle and good-natured, enjoying both playtime and cuddles.

history:
The breed originated from [___#scottish-fold-history].

also-known-as: Flop Eared Cat, Coupari

## Maine Coon
Maine Coons are large, friendly cats with distinctive tufted ears and bushy tails. They're known for their dog-like personalities and impressive size.

history:
Developed naturally in [___#maine-coon-history].

also-known-as: American Longhair, Maine Cat
```
````

### Table Formatting Output
<!-- level: 1 -->
````example
```output-example
| #    | Prime |        English       |
| :--- | ----: | :------------------: |
| 1    |     2 |         Two          |
| 2    |     3 |        Three         |
| 3    |     5 |         Five         |
| 4    |     7 |        Seven         |
| 5    |    11 |        Eleven        |
| 6    |    13 |       Thirteen       |
| 7    |    17 |      Seventeen       |
| 8    |    19 |       Nineteen       |
| 9    |    23 |    Twenty-three      |
| 10   |    29 |     Twenty-nine      |
| 11   |    31 |     Thirty-one       |
| 12   |    37 |    Thirty-seven      |
| 13   |    41 |      Forty-one       |
```
````

### Interactive Response Format
<!-- level: 1 -->
````example
```output-example
🚀 User selected option: "Advanced Analytics"

# Advanced Analytics Dashboard

## Key Metrics
- Daily Active Users: 15,247 (+12% vs last week)
- Conversion Rate: 3.2% (+0.4% vs last month)
- Revenue per User: $42.80 (+8% vs last quarter)

## Recommendations
Based on current trends, consider:
1. Expanding marketing spend in high-converting segments
2. A/B testing new onboarding flow
3. Implementing advanced user segmentation
```
````

### Error Response Format
<!-- level: 1 -->
````example
```output-example
Status: Error
Code: VALIDATION_FAILED

## Issue
The provided username contains invalid characters. Usernames may only contain letters, numbers, and underscores.

## Provided Input
username: "user@#$%"

## Valid Format
username: "user_name_123"

## Next Steps
Please update your username and try again.
```
````

### Sentiment Analysis Output
<!-- level: 2 -->
````example
```output-example
# Sentiment Analysis Results

**Text**: "I love this new product! It works perfectly and the customer service was amazing."

**Sentiment**: Positive
**Confidence**: 0.94
**Details**: Strong positive indicators detected including "love", "perfectly", and "amazing". No negative sentiment markers found.

## Breakdown
- Emotional tone: Enthusiastic
- Key positive terms: love, perfectly, amazing
- Customer satisfaction indicators: High
```
````

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

### Input Design Guidelines
- Always provide concrete input examples alongside input syntax definitions
- Show both valid and invalid input patterns where validation is important
- Use realistic sample data that demonstrates expected structure

### Output Design Guidelines
- Match output examples to the complexity of the use case
- Include error response formats for robust agent behavior
- Demonstrate how templates integrate with dynamic content
