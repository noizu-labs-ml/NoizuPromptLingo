# Agent Declaration Blocks
Agent definition syntax for creating simulated entities with specific behaviors, capabilities, and response patterns.

## Syntax
`⌜agent-name|type|NPL@version⌝[...definition...]⌞agent-name⌟`

## Purpose
To define a new agent and its expected behaviors, communications, and response patterns within the NPL framework. Agent declarations establish the foundational characteristics, capabilities, and operational constraints for simulated entities that can interpret and act on prompts.

## Usage
Use agent declarations when you need to:
- Create specialized agents for domain-specific tasks
- Define consistent behavior patterns across interactions
- Establish agent capabilities and limitations
- Specify communication protocols and response formats
- Create reusable agent definitions that can be invoked by name

## Parameters
- `agent-name`: Unique identifier for the agent (used in closing delimiter)
- `type`: Agent classification (`service`, `persona`, `tool`, `specialist`)
- `NPL@version`: Framework version the agent operates under

## Agent Types
- **service**: Functional agents that provide specific services or utilities
- **persona**: Character-based agents with defined personalities and traits  
- **tool**: Specialized agents that perform specific computational tasks
- **specialist**: Domain expert agents with focused knowledge areas

## Examples

```example
⌜sports-news-agent|service|NPL@1.0⌝
# Sports News Agent
Provides up-to-date sports news and analysis when prompted.

## Behavior
- Focuses on current sports events and statistics
- Provides objective reporting with factual accuracy
- Can analyze game performance and team standings
- Responds with structured summaries when requested

## Capabilities
- Real-time sports data access
- Statistical analysis and comparison
- Historical context for current events
- Multi-sport coverage including major leagues

## Response Format
Uses structured output with headlines, summaries, and key statistics.

⌞sports-news-agent⌟
```

```example
⌜data-analyst|specialist|NPL@1.0⌝
# Data Analysis Specialist
Expert agent for statistical analysis, data visualization, and insights generation.

🙋 data-analyst da analyst

## Core Functions
- Statistical analysis and hypothesis testing
- Data visualization and chart generation
- Trend analysis and forecasting
- Report generation with actionable insights

## Input Processing
- Accepts CSV, JSON, and structured data formats
- Handles both quantitative and qualitative datasets
- Processes time series and cross-sectional data

## Output Specifications
- Structured analysis reports with methodology section
- Visual representations using appropriate chart types  
- Statistical summaries with confidence intervals
- Recommendations based on findings

⌞data-analyst⌟
```

## Declaration Structure
Agent declarations typically include:
- **Name and Description**: Clear identification and purpose
- **Alias Declarations**: Alternative names using `🙋` syntax
- **Behavior Specifications**: How the agent responds and interacts
- **Capabilities**: What the agent can and cannot do
- **Input/Output Formats**: Expected data structures and response patterns
- **Constraints**: Operational limitations and boundaries

## Agent Extensions
Agents can be extended using the extension syntax:

```example
⌜extend:sports-news-agent|service|NPL@1.0⌝
Enhanced with historical sports data capability:
- Access to historical game archives
- Statistical trend analysis over time periods
- Comparative analysis between seasons/eras

⌞extend:sports-news-agent⌟
```
