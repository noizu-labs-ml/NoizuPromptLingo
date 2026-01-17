
# npl/formatting/input-example.md
---
# Input Example
Input example structures demonstrating expected data formats and usage patterns.

## Syntax
`input-example` fence blocks with realistic sample data

## Purpose
Provide concrete examples of expected input formats to clarify data structure requirements and guide proper usage of agents and templates.

## Usage
Input examples serve as reference implementations showing the exact format and content structure expected by agents, helping users understand how to properly format their requests.

## Examples

### User Profile Input
```example
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
```

### Natural Language Input
```example
```input-example
Generate a report about quarterly sales performance including:
- Revenue breakdown by region
- Top performing products
- Customer satisfaction metrics
- Recommendations for next quarter
```
```

### Structured Query Input
```example
```input-example
@search-agent find restaurants
location: "downtown Seattle"
cuisine: ["italian", "mexican", "asian"]
price_range: "$$-$$$"
dietary_restrictions: ["vegetarian options"]
```
```

### Template Data Input
```example
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
```

### Form Submission Input
```example
```input-example
username: techuser123
password: SecurePass789!
email: user@techcorp.com
full_name: Alice Rodriguez
department: Engineering
access_level: standard
newsletter_signup: true
```
```

### Multi-format Input
```example
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
```

## Input Validation Examples
```example
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
```

## Complex Structure Examples
```example
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
```

## See Also
- `./input-syntax.md` - Input format specifications
- `./output-example.md` - Output example structures
- `../fences/example.md` - Example fence patterns
- `../syntax/placeholder.md` - Placeholder usage patterns
* * *

# npl/formatting/input-syntax.md
---
# Input Syntax
Input format specifications for structured data entry and parameter definition.

## Syntax
`input-syntax` fence blocks or inline specifications

## Purpose
Define the expected structure and format for input data, parameters, and user-provided content within prompts and agent interactions.

## Usage
Input syntax specifications help agents understand the expected format of data they will receive, enabling proper parsing and processing.

## Examples

### Fence Block Format
```example
```input-syntax
<user.name>: string
<user.age>: number|optional
<preferences>: array|comma-separated
```
```

### Inline Specifications
```example
Expected input: `{user.name | string}`, `{preferences | list of items}`
```

### Handlebar-Style Input
```example
```input-syntax
{{user.profile}}
  name: <string>
  email: <email-format>
  preferences: [<item>, <item>, ...]
{{/user.profile}}
```
```

## Input Types
Common input type indicators:
- `string` - Text input
- `number` - Numeric values
- `email-format` - Email addresses
- `array` - List of items
- `optional` - Non-required field
- `comma-separated` - List format
- `json` - JSON structured data

## Qualifiers
Input specifications support qualifiers:
- `|optional` - Field is not required
- `|required` - Field must be provided
- `|default:value` - Default value if not specified
- `|format:pattern` - Expected format pattern

## Validation Patterns
```example
```input-syntax
<username>: string|pattern:^[a-zA-Z0-9_]+$
<password>: string|min-length:8
<age>: number|range:18-100
```
```

## See Also
- `./output-syntax.md` - Output format specifications
- `./input-example.md` - Input example structures
- `../syntax/placeholder.md` - Placeholder syntax patterns
* * *

# npl/formatting/output-example.md
---
# Output Example
Output example structures demonstrating expected response formats and presentation patterns.

## Syntax
`output-example` fence blocks with sample formatted responses

## Purpose
Provide concrete examples of expected output formats to demonstrate proper response structure, formatting, and content organization patterns that agents should follow.

## Usage
Output examples serve as reference implementations showing the exact format, style, and content structure that agents should produce, helping ensure consistency across responses.

## Examples

### Basic Response Format
```example
```output-example
Hello John Smith,
Did you know cats can rotate their ears 180 degrees to pinpoint the source of sounds?

Have a great day!
```
```

### Structured Report Format
```example
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
```

### Template-Integrated Output
```example
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
```

### Cat Facts Service Output
```example
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
```

### Table Formatting Output
```example
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
```

### Interactive Response Format
```example
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
```

### Error Response Format
```example
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
```

### Sentiment Analysis Output
```example
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
```

## See Also
- `./output-syntax.md` - Output format specifications  
- `./input-example.md` - Input example structures
- `../fences/example.md` - Example fence patterns
- `./template.md` - Reusable template definitions
* * *

# npl/formatting/output-syntax.md
---
# Output Syntax
Output format specifications defining the structure and style of agent responses.

## Syntax
`output-syntax`, `output-format` fence blocks or template definitions

## Purpose
Specify the exact format, structure, and styling requirements for agent-generated output to ensure consistency and meet user expectations.

## Usage
Output syntax definitions guide agents in constructing responses that match specific formatting requirements, including text layout, data presentation, and structural elements.

## Examples

### Basic Output Format
```example
```output-format
Hello <user.name>,
Did you know [...|funny factoid].

Have a great day!
```
```

### Structured Response Format
```example
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
```

### Business Profile Format
```example
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
```

## Format Elements

### Text Formatting
- `<term>` - Variable substitution
- `{term}` - Dynamic content placeholder
- `[...]` - Generated content sections
- `⟪...⟫` - Directive integration

### Size Indicators
- `[...1s]` - One sentence
- `[...2-3p]` - Two to three paragraphs
- `[...5w]` - Five words
- `[...3-5+r]` - Three to five or more rows

### Structure Elements
- Headers using `#`, `##`, `###`
- Lists using `-`, `*`, or numbered format
- Code blocks using triple backticks
- Table formatting specifications

## Template Integration
Output syntax can incorporate reusable templates:

```example
```output-syntax
{{template:user-card | for each team member}}
{{template:stats-summary | with current metrics}}
```
```

## Conditional Output
```example
```output-syntax
{{if user.role == 'admin'}}
## Admin Panel
[...admin-specific-content]
{{else}}
## User Dashboard  
[...user-specific-content]
{{/if}}
```
```

## See Also
- `./input-syntax.md` - Input format specifications
- `./output-example.md` - Output example structures
- `./template.md` - Reusable template definitions
- `../fences/format.md` - Format fence specifications
* * *

# npl/formatting/template.md
---
# Template
Reusable template definitions for consistent output formatting.

## Syntax
`⌜🧱 <name>` ... `⌟`

## Purpose
Define reusable output format/template that can be applied across multiple contexts to ensure consistent formatting and structure.

## Usage
Templates are declared using the special section syntax with the 🧱 emoji prefix, followed by the template name. The template content is defined within the declaration boundaries.

## Examples
```example
⌜🧱 user-card
@with NPL@1.0
```template
<b>{user.name}</b>
<p>{user.bio}</p>
```
⌟
```

## Template Integration
Templates can be integrated into outputs using directive syntax:

```example
⟪⇐: user-template | with the data of each executive.⟫
```

## Parameters
- `name`: Unique identifier for the template
- Template content uses handlebar-like syntax for placeholders
- Optional NPL version specification with `@with NPL@version`

## Template Content Format
Templates support:
- Placeholder substitution using `{variable.path}`
- HTML-like formatting tags
- Conditional logic integration
- Data iteration patterns

* * *
