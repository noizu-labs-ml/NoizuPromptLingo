
# npl/directive/⇆.md
---
# Template Integration Directive
Integrate templated sections into outputs seamlessly with data binding and variable substitution.

## Syntax
`⟪⇆: template-name | application context⟫`

**Alternative syntax from NPL sources:**
`⟪⇐: template-name | application context⟫`

## Purpose
This directive enables the seamless integration of predefined templates into agent outputs, allowing for consistent formatting and structure across multiple data entries or response patterns. It supports variable substitution and data binding from external sources.

## Usage
Use this directive when you need to:
- Apply consistent formatting across multiple similar data items
- Integrate reusable template structures
- Bind dynamic data to predefined output formats
- Maintain formatting consistency in complex outputs

## Template Definition
Templates are typically defined using template fences or named template sections:

```template
```template=user-template
# {user.name}
dob: {user.dob}
bio: {user.bio}
```
```

## Examples

### User Profile Template Integration
```example
⟪⇆: user-template | with the data of each executive⟫
```

**Context:** Applied within a business profile where executive information needs consistent formatting.

### Business Profile with Template Integration
```example
Business Name: <business.name>
About the Business: <business.about>

## Executives
{foreach business.executives as executive}
- Name: <executive.name>
- Role: <executive.role>  
- Bio: <executive.bio>
⟪⇆: user-template | with the data of each executive⟫
{/foreach}

## Board Advisors
{foreach business.board_advisors as advisor}
- Name: <advisor.name>
- Role: <advisor.role>
- Bio: <advisor.bio>
⟪⇆: user-template | with the data of each board advisor⟫
{/foreach}
```

**Purpose:** Use a standard template to format information on executives and advisors uniformly.
**Outcome:** A business profile with consistently formatted information for executives and board advisors.

### Product Listing Template
```example
⟪⇆: product-card | for each item in inventory⟫
```

### Newsletter Template Integration
```example
⟪⇆: article-summary | applying to each news item⟫
```

## Data Binding
Templates support variable substitution using:
- `{variable.name}` - Simple variable substitution
- `<variable.name>` - Alternative placeholder syntax
- `{variable|qualifier}` - Variable with formatting qualifiers

## Integration Context
The directive supports various application contexts:
- `with the data of each X` - Apply template to each item in a collection
- `for each item in Y` - Iterate over collection items
- `applying to individual Z` - Apply to specific data entries
- `using current context` - Use available variables in scope

## Technical Notes
- Templates must be defined before they can be integrated
- Variable names in templates should match the data structure being applied
- The directive preserves template formatting while substituting dynamic content
- Multiple template integrations can be nested or chained

* * *

# npl/directive/⏳.md
---
# Time-Based Task Execution Directive
Command the agent to consider timing and duration constraints for task execution and scheduling.

## Syntax
`⟪⏳: Time Condition or Instruction⟫`

## Purpose
This directive instructs agents to incorporate temporal considerations into task execution, including scheduling, timing constraints, deadlines, and time-based triggers for automated actions.

## Usage
Use this directive when tasks need to be:
- Executed at specific times or intervals
- Completed within time constraints  
- Triggered by temporal events
- Scheduled for future execution
- Coordinated with time-sensitive workflows

## Examples

### Scheduled Report Generation
```example
⟪⏳: At the end of each month⟫ Generate a summary report of user activity.
```

**Purpose:** Initiate a report generation event at a set time frame.
**Outcome:** Automatic compilation of a summary report at the month's end.

### Action Timer with Deadline
```example
⟪⏳: Within 5 minutes of receiving data⟫ Analyze and present the findings.
```

**Purpose:** Set a time limit for completing a data analysis task.
**Outcome:** Data analysis completed within a five-minute timeframe.

### Daily Automation Trigger
```example
⟪⏳: Every morning at 9 AM⟫ Send reminder emails to team members.
```

### Event-Based Timing
```example
⟪⏳: 30 seconds after user completes checkout⟫ Send order confirmation and tracking information.
```

### Duration-Constrained Processing
```example
⟪⏳: Process for maximum 10 minutes⟫ Scan document for key information, prioritizing most relevant sections first.
```

## Time Format Patterns
- **Absolute times**: `At 3:00 PM`, `On December 25th`
- **Relative times**: `Within 5 minutes`, `After 2 hours`
- **Recurring patterns**: `Every Monday`, `Daily at noon`
- **Event-triggered**: `30 seconds after signup`, `Upon completion of task X`
- **Duration limits**: `For no more than 1 hour`, `Until timeout`

## Implementation Notes
- Time-based directives may require system-level scheduling capabilities
- Agents should acknowledge timing constraints in their response
- Consider timezone implications for absolute time specifications
- Duration limits help prevent infinite processing loops

* * *

# npl/directive/➤.md
---
# Explicit Instruction Directive
Provide direct and precise instructions to agents for clarity and specific task execution.

## Syntax
`⟪➤: <instruction> | <elaboration>⟫`

**Alternative format:**
`{➤: <instruction> | <elaboration>}`

## Purpose
This directive delivers clear, unambiguous instructions to agents, ensuring precise execution of specific tasks or behaviors. It eliminates interpretation ambiguity by providing explicit direction and optional elaboration for complex requirements.

## Usage
Use this directive when you need to:
- Provide crystal-clear task instructions
- Eliminate potential misinterpretation
- Specify exact requirements or constraints
- Direct agent behavior with precision
- Include clarifying elaboration alongside core instructions

## Examples

### Explicit Instruction with Elaboration
```example
⟪➤: Identify the current user | Ensure secure session⟫
```

**Purpose:** Instruct the agent to verify user identity and secure the session.
**Outcome:** Agent identifies the user and secures the ongoing session.

### Data Retrieval with Specificity
```example
⟪➤: Retrieve climate data | Include recent temperature anomalies⟫
```

**Purpose:** Command the agent to fetch specific climate data components.
**Outcome:** Agent fetches climate data, focusing on recent temperature anomalies.

### Technical Task Direction
```example
⟪➤: Compile the source code | Use optimization flags and generate debug symbols⟫
```

### User Interface Instruction
```example
⟪➤: Display error message | Use red text and include retry button⟫
```

### Data Processing Command
```example
⟪➤: Sort the records | Order by timestamp descending, then by priority⟫
```

### Validation Requirement
```example
⟪➤: Validate input parameters | Check data types, ranges, and required fields⟫
```

### Communication Directive
```example
⟪➤: Send notification email | Include order details and tracking information⟫
```

## Instruction Categories

### Action Commands
```example
⟪➤: Execute function | With provided parameters and error handling⟫
⟪➤: Update database record | Using transaction safety and validation⟫
```

### Behavioral Directives
```example
⟪➤: Respond professionally | Maintain helpful tone while being concise⟫
⟪➤: Prioritize accuracy | Verify information before presenting to user⟫
```

### Processing Instructions
```example
⟪➤: Parse JSON data | Extract user preferences and settings only⟫
⟪➤: Generate report | Include charts, summary statistics, and recommendations⟫
```

### Format Specifications
```example
⟪➤: Format output as table | Include headers, align numbers right⟫
⟪➤: Create markdown document | Use proper heading hierarchy and code blocks⟫
```

## Elaboration Patterns

### Context Specification
```example
⟪➤: Analyze sentiment | Focus on customer satisfaction indicators⟫
```

### Constraint Definition
```example
⟪➤: Generate summary | Maximum 200 words, include key metrics⟫
```

### Quality Requirements
```example
⟪➤: Translate text | Maintain formal tone and technical accuracy⟫
```

### Error Handling
```example
⟪➤: Process payment | Implement retry logic for temporary failures⟫
```

### Output Format
```example
⟪➤: Create visualization | Use bar chart format with labeled axes⟫
```

## Implementation Notes

### Instruction Clarity
- Use specific, actionable verbs
- Avoid ambiguous language
- Define success criteria when relevant

### Elaboration Value
- Provide context that clarifies intent
- Include constraints or limitations
- Specify expected outcomes or formats

### Priority Handling
- Explicit instructions take precedence over general guidelines
- More specific directives override general ones
- Later instructions can override earlier conflicting ones

## Related Usage Patterns

### With Prompt Prefixes
```example
📊➤ ⟪➤: Analyze dataset | Generate statistical summary with visualizations⟫
```

### With Other Directives
```example
⟪📅: (metric:left, value:right) | performance data⟫
⟪➤: Populate table | Include only metrics above threshold⟫
```

### In Template Context
```example
⟪⇆: report-template | apply to quarterly data⟫
⟪➤: Customize template | Highlight significant changes from previous quarter⟫
```

## Best Practices

### Instruction Structure
- Start with clear action verb
- Include specific objects or targets
- Add constraints or requirements in elaboration

### Elaboration Guidelines
- Provide clarifying details
- Specify quality or format requirements
- Include edge case handling when relevant

### Consistency
- Use consistent terminology across related instructions
- Maintain parallel structure for similar commands
- Follow established patterns for predictability

* * *

# npl/directive/🆔.md
---
# Unique Identifier Management Directive
Integrate and sustain unique identifiers for various entities, sessions, and data records.

## Syntax
`⟪🆔: Entity or Context Requiring ID⟫`

## Purpose
This directive instructs agents to generate, manage, and maintain unique identifiers for entities, sessions, records, or other objects that require distinct identification within a system or workflow context.

## Usage
Use this directive when you need to:
- Generate unique session identifiers
- Assign IDs to data records or entities
- Track objects across multiple operations
- Create references for later retrieval
- Maintain data integrity through unique keys

## Examples

### Session ID Generation
```example
⟪🆔: User Session⟫ Generate a session identifier for the new login event.
```

**Purpose:** Generate a unique session ID for each user login.
**Outcome:** Unique session ID created for session tracking.

### Data Record Identification
```example
⟪🆔: Product Listing⟫ Assign an ID to each new product entry in the database.
```

**Purpose:** Provide unique identifiers for each product in the inventory.
**Outcome:** All new product entries assigned with a unique ID.

### Transaction Tracking
```example
⟪🆔: Payment Transaction⟫ Create unique transaction reference for order processing.
```

### Document Management
```example
⟪🆔: Uploaded Document⟫ Generate document ID for version control and retrieval.
```

### User Account Creation
```example
⟪🆔: New User Registration⟫ Assign permanent user ID and temporary activation token.
```

### Conversation Threading
```example
⟪🆔: Chat Thread⟫ Create unique thread identifier for multi-participant conversations.
```

### API Request Tracking
```example
⟪🆔: API Request⟫ Generate request ID for logging and error tracking purposes.
```

## Identifier Types

### UUID/GUID
- Standard universally unique identifiers
- Suitable for distributed systems
- Example: `550e8400-e29b-41d4-a716-446655440000`

### Sequential IDs
- Incrementing numeric identifiers
- Suitable for ordered records
- Example: `USER_12345`, `ORD_000789`

### Hash-Based IDs
- Content-derived identifiers
- Suitable for content verification
- Example: `sha256_abc123def456`

### Timestamp-Based IDs
- Time-ordered identifiers
- Suitable for chronological tracking
- Example: `20240828_143022_001`

### Composite IDs
- Multi-part identifiers with context
- Suitable for hierarchical systems
- Example: `PROJ_001_TASK_045_USER_123`

## ID Generation Context

### System-Level IDs
```example
⟪🆔: Database Record⟫ Auto-increment primary key for data integrity.
```

### User-Facing IDs
```example
⟪🆔: Order Number⟫ Human-readable order reference for customer service.
```

### Internal References
```example
⟪🆔: Cache Key⟫ Internal identifier for data caching and retrieval.
```

### Security Tokens
```example
⟪🆔: Access Token⟫ Secure identifier for API authentication and authorization.
```

## Implementation Notes
- Ensure ID uniqueness within the specified scope
- Consider ID format requirements for the target system
- Include appropriate prefixes or suffixes for context
- Maintain ID persistence across system interactions
- Consider security implications for sensitive ID types

## Best Practices
- Use appropriate ID length for the use case
- Include checksums for critical identifiers
- Implement collision detection for critical systems
- Use meaningful prefixes for different entity types
- Consider future scalability requirements

* * *

# npl/directive/📂.md
---
# Section Reference Marking Directive
Mark sections with unique identifiers for easy reference, navigation, and future updates.

## Syntax
`⟪📂:{identifier}⟫`

## Purpose
This directive creates navigable reference points within documents, prompts, or output sections. It enables easy cross-referencing, content updates, and section-specific operations by establishing unique identifiers for content blocks.

## Usage
Use this directive to:
- Create reference anchors for section navigation
- Enable targeted content updates
- Establish links between related sections
- Support modular content organization
- Facilitate documentation maintenance

## Examples

### User Guidelines Reference
```example
⟪📂:{user_guidelines}⟫ Refer to the guidelines for acceptable user behavior.
```

**Purpose:** Offer a reference point for rules governing user conduct.
**Outcome:** Clear referencing of the guidelines section for future consultation.

### Technical Documentation Reference
```example
⟪📂:{installation_procedure_v2}⟫ Follow the latest installation steps outlined.
```

**Purpose:** Tag the current software installation instructions for easy access.
**Outcome:** Direct reference to the latest installation steps for user convenience.

### Policy Section Marking
```example
⟪📂:{privacy_policy_section_3}⟫ Data collection practices are detailed below.
```

### API Endpoint Documentation
```example
⟪📂:{auth_endpoints}⟫ Authentication endpoints and their parameters:
```

### Configuration Reference
```example
⟪📂:{database_config}⟫ Database connection settings:
```

### Troubleshooting Section
```example
⟪📂:{common_errors}⟫ Frequently encountered issues and solutions:
```

### Version-Specific Content
```example
⟪📂:{feature_spec_v3_2}⟫ New features introduced in version 3.2:
```

## Identifier Naming Conventions

### Descriptive Names
- Use clear, meaningful identifiers
- Include version numbers when applicable
- Reflect the content's purpose

### Hierarchical Structure
```example
⟪📂:{docs_api_auth_oauth}⟫ - Nested reference structure
⟪📂:{guide_setup_database}⟫ - Category-based organization
```

### Versioning Pattern
```example
⟪📂:{user_manual_v2_1}⟫ - Version-specific sections
⟪📂:{changelog_2024_q1}⟫ - Time-based references
```

### Functional Grouping
```example
⟪📂:{security_requirements}⟫ - Topic-based grouping
⟪📂:{performance_metrics}⟫ - Function-based organization
```

## Reference Operations

### Cross-Referencing
```example
For installation details, see ⟪📂:{installation_procedure_v2}⟫
Authentication is covered in ⟪📂:{auth_endpoints}⟫
```

### Content Updates
```example
Update section ⟪📂:{pricing_tiers}⟫ with new subscription options
```

### Section Linking
```example
This relates to the concepts discussed in ⟪📂:{core_principles}⟫
```

### Modular Loading
```example
Load additional details from ⟪📂:{advanced_configuration}⟫ if needed
```

## Implementation Patterns

### Document Structure
```example
# User Manual ⟪📂:{manual_root}⟫

## Getting Started ⟪📂:{getting_started}⟫
[content]

## Configuration ⟪📂:{configuration}⟫
[content]

## Troubleshooting ⟪📂:{troubleshooting}⟫
[content]
```

### Reference Index
```example
Available sections:
- ⟪📂:{user_guidelines}⟫ - User behavior policies
- ⟪📂:{api_reference}⟫ - API documentation
- ⟪📂:{changelog}⟫ - Version history
```

### Conditional References
```example
⟪📂:{enterprise_features}⟫ (Premium users only)
⟪📂:{beta_features}⟫ (Available in testing environment)
```

## Best Practices

### Unique Identifiers
- Ensure identifiers are unique within the document scope
- Use consistent naming conventions
- Avoid special characters that might conflict with systems

### Descriptive References
- Make identifiers self-explanatory
- Include context or category information
- Use underscores or hyphens for readability

### Maintenance Considerations
- Update references when content is moved or renamed
- Maintain reference integrity across document versions
- Consider automated reference validation

* * *

# npl/directive/📅.md
---
# Structured Table Formatting Directive
Format data into structured tables with customizable column alignments and headers for enhanced readability.

## Syntax
`⟪📅: (column alignments and labels) | content description⟫`

## Purpose
This directive instructs the agent to format data into a structured table with specified column alignments, labels, and formatting requirements. It enhances readability by providing clear tabular organization of information.

## Usage
Use this directive when you need to present data in a tabular format with specific column alignment requirements, custom headers, or structured organization. The directive is particularly useful for displaying lists, comparisons, or categorical data.

## Parameters
- `column alignments`: Specify alignment for each column (left, right, center)
- `labels`: Custom column headers or labels  
- `content description`: Description of what data should populate the table

## Alignment Syntax
- `:left` or `left` - Left-aligned column
- `:right` or `right` - Right-aligned column  
- `:center` or `center` - Center-aligned column
- `#:left` - Row number column, left-aligned
- `prime:right` - Column named "prime", right-aligned

## Examples

### Basic Table with Alignments
```example
⟪📅: (#:left, prime:right, english:center label Heyo) | first 13 prime numbers⟫
```

**Expected Output:**
| #    | Prime |        Heyo        |
| :--- | ----: | :----------------: |
| 1    |     2 |        Two         |
| 2    |     3 |       Three        |
| 3    |     5 |        Five        |
| 4    |     7 |       Seven        |
| 5    |    11 |      Eleven        |
| 6    |    13 |     Thirteen       |
| 7    |    17 |    Seventeen       |
| 8    |    19 |      Nineteen      |
| 9    |    23 |   Twenty-three     |
| 10   |    29 |   Twenty-nine      |
| 11   |    31 |    Thirty-one      |
| 12   |    37 |  Thirty-seven      |
| 13   |    41 |     Forty-one      |

### Simple Product Listing
```example
⟪📅: (product:left, price:right, rating:center) | top 5 bestselling products⟫
```

## Technical Notes
- The directive automatically generates proper markdown table syntax
- Column alignments are preserved using markdown alignment syntax
- Headers are automatically formatted based on provided labels
- Content is organized according to the specified structure

* * *

# npl/directive/📖.md
---
# Explanatory Note Annotations Directive
Append instructive comments and detailed explanations to elucidate expectations behind prompts and behaviors.

## Syntax
`⟪📖: Detailed Explanation⟫`

## Purpose
This directive provides detailed explanatory notes that clarify the intent, expectations, constraints, or context behind specific instructions or behaviors. It serves as inline documentation to help agents understand the reasoning and requirements for proper implementation.

## Usage
Use this directive to:
- Clarify the reasoning behind specific instructions
- Provide context for ethical or policy considerations
- Explain complex requirements or edge cases
- Document best practices and guidelines
- Offer implementation guidance and constraints

## Examples

### Behavior Guideline for Data Handling
```example
⟪📖: Ensure user consent before data collection⟫ Prioritize user privacy when soliciting personal information.
```

**Purpose:** Emphasize ethical data practices regarding user consent.
**Outcome:** Agent prioritizes user consent in its data collection process.

### Cultural Sensitivity Note
```example
⟪📖: Account for cultural context in marketing messages⟫ Craft communication with cultural awareness.
```

**Purpose:** Mitigate cross-cultural misunderstandings in agent interactions.
**Outcome:** Agent communication is adapted to respect cultural nuances.

### Security Best Practices
```example
⟪📖: Never log sensitive information like passwords or tokens⟫ Implement secure logging practices for user activity.
```

### Accessibility Requirements
```example
⟪📖: Ensure all interactive elements are keyboard accessible⟫ Design user interface components following WCAG guidelines.
```

### Performance Considerations
```example
⟪📖: Limit database queries to prevent system overload⟫ Implement efficient data retrieval strategies.
```

### Legal Compliance Note
```example
⟪📖: Verify compliance with GDPR requirements before processing EU user data⟫ Handle European user information appropriately.
```

### Error Handling Guidance
```example
⟪📖: Provide helpful error messages without exposing system details⟫ Design user-friendly error responses.
```

## Annotation Categories

### Ethical Guidelines
```example
⟪📖: Respect user autonomy and avoid manipulative design patterns⟫
```

### Technical Constraints
```example
⟪📖: API rate limits apply - implement exponential backoff for retry logic⟫
```

### Business Rules
```example
⟪📖: Premium features require valid subscription status verification⟫
```

### User Experience Notes
```example
⟪📖: Maintain consistent visual hierarchy and navigation patterns⟫
```

### Quality Standards
```example
⟪📖: All generated content must be fact-checked against authoritative sources⟫
```

## Implementation Context
Explanatory notes can be embedded within various contexts:
- **Inline with instructions** - Immediate clarification
- **Before complex sections** - Setup and preparation
- **After examples** - Additional guidance and context
- **Within templates** - Documentation for template usage

## Best Practices

### Clarity and Conciseness
- Use clear, specific language
- Avoid jargon or ambiguous terms
- Focus on actionable guidance

### Contextual Relevance
- Relate notes directly to the associated instruction
- Provide relevant examples when helpful
- Address common misconceptions or errors

### Comprehensive Coverage
- Include edge cases and exceptions
- Mention relevant constraints or limitations
- Reference related policies or standards

* * *

# npl/directive/🚀.md
---
# Interactive Element Choreography Directive
Choreograph interactive elements and agent reactivity based on user interactions and dynamic behaviors.

## Syntax
`⟪🚀: Action or Behavior Definition⟫`

## Purpose
This directive defines interactive behaviors, user-triggered actions, and dynamic response patterns that adapt based on user interactions, system events, or environmental changes. It enables agents to create responsive and interactive experiences.

## Usage
Use this directive to:
- Define user-triggered response patterns
- Set up interactive workflows and decision trees
- Create time-delayed or event-driven behaviors
- Establish dynamic content adaptation
- Choreograph multi-step interactive sequences

## Examples

### User-Driven Question Flow
```example
⟪🚀: User selects an option⟫ Provide corresponding information based on the user's selection.
```

**Purpose:** Adapt responses based on user choices in a Q&A interface.
**Outcome:** The agent dynamically provides information relevant to the user's selection.

### Time-Delayed Notification
```example
⟪🚀: 30 seconds after signup⟫ Send a welcome message with introductory resources.
```

**Purpose:** Delay the delivery of a welcome message to new users.
**Outcome:** A welcome message sent 30 seconds post-signup.

### Interactive Menu System
```example
⟪🚀: User clicks on product category⟫ Display filtered products and highlight related categories.
```

### Progressive Disclosure
```example
⟪🚀: User clicks "Learn More"⟫ Expand section with detailed technical specifications and usage examples.
```

### Dynamic Form Validation
```example
⟪🚀: User enters invalid email format⟫ Show inline error message and highlight field in red.
```

### Multi-Step Workflow
```example
⟪🚀: User completes step 1⟫ Unlock step 2 and update progress indicator to 33% complete.
```

### Contextual Help System
```example
⟪🚀: User hovers over complex term⟫ Display tooltip with definition and link to documentation.
```

## Trigger Types

### User Actions
- `User clicks/taps/selects`
- `User hovers/focuses`
- `User types/enters`
- `User scrolls/swipes`
- `User submits/confirms`

### System Events
- `Data loading completes`
- `Error occurs`
- `Timeout reached`
- `Connection established/lost`

### Time-Based Triggers
- `After X seconds/minutes`
- `At specific time`
- `Before deadline`
- `During time window`

### State Changes
- `When condition becomes true`
- `Upon reaching threshold`
- `After completing task`

## Choreography Patterns

### Sequential Flow
```example
⟪🚀: Step completion⟫ → ⟪🚀: Next step activation⟫ → ⟪🚀: Final confirmation⟫
```

### Conditional Branching
```example
⟪🚀: If premium user⟫ Show advanced features
⟪🚀: If basic user⟫ Show upgrade prompt
```

### Parallel Processing
```example
⟪🚀: Simultaneously⟫ Load user data AND fetch recommendations AND update analytics
```

## Implementation Notes
- Interactive elements may require client-side scripting or framework support
- Consider accessibility requirements for interactive behaviors
- Define fallback behaviors for when interactions are not available
- Test interaction patterns across different devices and input methods

* * *
