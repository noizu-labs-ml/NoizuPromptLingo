# Planning & Thinking Patterns (Pumps)
<!-- labels: [pumps, reasoning, transparency] -->

Structured reasoning techniques and intuition pumps that guide problem-solving, response construction, and analytical thinking within NPL framework operations.

<!-- instructional: conceptual-explanation | level: 0 | labels: [pumps, overview] -->
## Overview

NPL pumps are cognitive tools that enable agents to demonstrate transparent reasoning processes, structured problem-solving, and reflective analysis. These patterns enhance the interpretability and reliability of agent responses by providing clear insight into decision-making processes.

**Convention**: Pumps are implemented using XHTML tags (`<npl-type>`) for consistent formatting and structured data representation.

<!-- instructional: quick-reference | level: 0 | labels: [pumps, types] -->
## Core Pump Types

| Pump | Tag | Purpose |
|------|-----|---------|
| Intent Declaration | `<npl-intent>` | Document reasoning flow |
| Chain of Thought | `<npl-cot>` | Structured problem decomposition |
| Self-Assessment | `<npl-reflection>` | End-of-response evaluation |
| Tangential Exploration | `<npl-tangent>` | Related concept exploration |
| Panel Discussion | `<npl-panel>` | Multi-perspective analysis |
| Critical Analysis | `<npl-critique>` | Solution evaluation |
| Evaluation Framework | `<npl-rubric>` | Standardized assessment |
| Emotional Context | `<npl-mood>` | Simulated emotional state |

---

## Intent Declaration (`npl-intent`)
<!-- level: 0 | labels: [intent, transparency] -->

Intent blocks are structured notes explaining the steps an agent takes to construct a response.

### Syntax

```syntax
<npl-intent>
intent:
  overview: <brief description of intent>
  steps:
    - <step 1>
    - <step 2>
    - <step 3>
</npl-intent>
```

### Purpose

Intent blocks provide transparency into the decision-making process of an agent. They are used at the beginning of responses to describe the sequence of actions or considerations the agent has taken to arrive at the output. This feature is especially useful for debugging or providing insights into complex operations.

### Usage

Use intent blocks when:
- Documenting the rationale behind a response
- Providing transparency into complex decision-making
- Enabling debugging or analysis of agent reasoning
- Building trust through visible thought processes

### Examples

#### Basic Intent Block
```example
<npl-intent>
intent:
  overview: Generate weather forecast summary for user location
  steps:
    - Identify user's geographical location
    - Fetch current weather data from API
    - Analyze 5-day forecast trends
    - Format output in user-friendly language
</npl-intent>
```

#### Complex Problem-Solving Intent
```example
<npl-intent>
intent:
  overview: Solve multi-step mathematical optimization problem
  steps:
    - Parse problem constraints and variables
    - Identify optimization type (linear/non-linear)
    - Select appropriate algorithm approach
    - Execute calculation steps with validation
    - Format solution with explanation
</npl-intent>
```

### Parameters

- `overview`: Brief description of the agent's primary intent
- `steps`: Array of sequential actions or considerations taken

### Conditional Inclusion

Intent blocks can be configured to appear based on:
- Question complexity level
- User request for detailed reasoning
- Debug mode activation
- Developer troubleshooting needs

---

## Chain of Thought (`npl-cot`)
<!-- level: 1 | labels: [cot, reasoning, analysis] -->

Chain of Thought is an intuition pump that structures complex problem-solving through step-by-step reasoning.

### Syntax

```syntax
<npl-cot>
thought_process:
  - thought: "Initial thought about the problem."
    understanding: "Understanding of the problem."
    theory_of_mind: "Insight into the question's intent."
    plan: "Planned approach to the problem."
    rationale: "Rationale for the chosen plan."
    execution:
      - process: "Execution of the plan."
        reflection: "Reflection on progress."
        correction: "Adjustments based on reflection."
  outcome: "Conclusion of the problem-solving process."
</npl-cot>
```

### Purpose

Chain of Thought (CoT) is a technique used by LLMs and their simulated virtual agents to break down complex problems into manageable steps. It involves pondering the intent behind a query, structuring the problem-solving approach, reflecting on the solution's validity, and making necessary corrections throughout the process.

### Usage

Use Chain of Thought when:
- Tackling multi-step problem-solving scenarios
- Demonstrating reasoning transparency to users
- Breaking down complex analytical tasks
- Ensuring systematic approach to difficult questions
- Building user confidence in agent capabilities

### Examples

#### Mathematical Problem Solving
```example
<npl-cot>
thought_process:
  - thought: "User wants to find the area of a complex geometric shape."
    understanding: "The shape appears to be a composite of rectangle and triangle."
    theory_of_mind: "User likely needs this for a real-world application like construction."
    plan: "Decompose shape into basic geometric forms and calculate separately."
    rationale: "Breaking complex shapes into simple ones reduces error probability."
    execution:
      - process: "Identify rectangle: 10m x 6m = 60m squared"
        reflection: "Rectangle calculation seems straightforward and correct."
        correction: "No adjustments needed for rectangle."
      - process: "Identify triangle: base 10m, height 4m = 20m squared"
        reflection: "Used correct triangle area formula (1/2 x base x height)."
        correction: "No adjustments needed for triangle."
outcome: "Total area = 60m squared + 20m squared = 80m squared"
</npl-cot>
```

#### Research Analysis
```example
<npl-cot>
thought_process:
  - thought: "User wants analysis of conflicting research findings."
    understanding: "Multiple studies show different conclusions about same topic."
    theory_of_mind: "User needs to understand why results vary and which to trust."
    plan: "Examine methodology, sample sizes, and potential biases in each study."
    rationale: "Quality assessment is crucial for determining reliability."
    execution:
      - process: "Study A: Large sample (n=5000), randomized controlled trial"
        reflection: "High-quality methodology suggests reliable results."
        correction: "Weight this study more heavily in analysis."
      - process: "Study B: Small sample (n=50), observational design"
        reflection: "Limited generalizability due to size and design."
        correction: "Note limitations but include findings with caveats."
outcome: "Study A provides stronger evidence due to superior methodology, though Study B offers valuable preliminary insights."
</npl-cot>
```

### Parameters

- `thought_process`: Array of reasoning steps, each containing:
  - `thought`: Initial consideration of the problem
  - `understanding`: Comprehension of what's being asked
  - `theory_of_mind`: Insight into the questioner's intent
  - `plan`: Approach strategy for solving the problem
  - `rationale`: Justification for the chosen approach
  - `execution`: Array of implementation steps with reflection and correction
- `outcome`: Final conclusion or result

### Integration with Other Pumps

Chain of Thought can be combined with:
- Math-helper for numerical problem-solving
- Research analysis for academic inquiries
- Decision-making frameworks for complex choices
- Creative writing for narrative development

### Format Variations

The CoT block can be followed by a conclusion block for clarity:

```format
<npl-cot>
[thought process content]
</npl-cot>
<npl-conclusion>
[final solution or answer]
</npl-conclusion>
```

---

## Self-Assessment (`npl-reflection`)
<!-- level: 0 | labels: [reflection, evaluation] -->

Reflection blocks are self-assessment notes that agents use to evaluate and improve future responses.

### Syntax

```syntax
<npl-reflection>
reflection:
  overview: |
    <assess response>
  observations:
    - <emoji> <observation 1>
    - <emoji> <observation 2>
    - <emoji> <observation 3>
</npl-reflection>
```

### Purpose

Reflection blocks appear at the end of an agent's response and provide an analysis of the response's effectiveness. The agent may identify successes, errors, areas for improvement, or insights gained. This self-critical approach is designed to continuously enhance the quality of the agent's interactions.

### Usage

Use reflection blocks for:
- Self-evaluation of response quality and accuracy
- Identifying potential improvements for future interactions
- Documenting learning points and insights gained
- Acknowledging errors or limitations in the response
- Building continuous improvement into agent behavior

### Examples

#### Code Review Reflection
```example
<npl-reflection>
reflection:
  overview: |
    Provided a Python function for data validation with error handling.
    The solution addresses the core requirements but could benefit from additional edge case handling.
  observations:
    - Successfully implemented basic input validation
    - Realized the function could benefit from custom exception classes
    - Error messages could be more user-friendly
    - Added comprehensive docstring documentation
    - Did not address Unicode edge cases in string validation
</npl-reflection>
```

#### Research Response Reflection
```example
<npl-reflection>
reflection:
  overview: |
    Compiled research on renewable energy trends. Response was comprehensive
    but may have been too technical for the general audience implied by the question.
  observations:
    - Covered all major renewable energy types
    - Used recent, credible sources for statistics
    - Should have included more accessible explanations
    - Uncertain if economic analysis was detailed enough
    - Successfully connected environmental and economic benefits
    - May have overwhelmed user with too much technical detail
</npl-reflection>
```

#### Multi-Dimensional Assessment
```example
<npl-reflection>
reflection:
  overview: |
    Technical explanation of machine learning concepts with practical examples.
    Balanced accuracy with accessibility, though some concepts remain complex.
  observations:
    - Accurately explained core ML principles
    - Provided relevant real-world applications
    - Recognized the importance of visual aids for complex concepts
    - Some terminology may still be too advanced
    - Could benefit from step-by-step breakdown of algorithms
    - Should reference beginner-friendly resources for further learning
    - Successfully bridged theory and practice
</npl-reflection>
```

<!-- instructional: quick-reference | level: 0 | labels: [emojis, reflection] -->
### Reflection Type Emojis

Standard emojis used to categorize types of reflections:

| Emoji | Meaning |
|-------|---------|
| ✅ | Success, positive acknowledgment |
| ❌ | Error, issue identified |
| 🔧 | Improvement needed, potential fixes |
| 💡 | Insight, learning point |
| 🔄 | Review, reiteration needed |
| 🆗 | Acceptable, satisfactory |
| ⚠️ | Warning, caution advised |
| ➕ | Positive aspect, advantage |
| ➖ | Negative aspect, disadvantage |
| ✏️ | Clarification, editing suggested |
| 🗑️ | Discard, irrelevant or unnecessary |
| 🚀 | Progress, advancement |
| 🤔 | Puzzlement, uncertainty |
| 📚 | Reference, learning opportunity |

### Parameters

- `overview`: Comprehensive assessment of the response's effectiveness
- `observations`: Array of specific observations, each prefixed with an appropriate emoji categorization

### Optional Inclusion

Reflection blocks can be included or omitted based on:
- Context requiring additional transparency
- Teaching scenarios for agent improvement
- Debugging complex interactions
- User requests for detailed self-assessment
- Reinforcement learning scenarios

---

## Tangential Exploration (`npl-tangent`)
<!-- level: 1 | labels: [tangent, exploration] -->

Tangent blocks capture related insights, connections, and exploratory thoughts that emerge during problem-solving.

### Syntax

```syntax
<npl-tangent>
tangent:
  trigger: "<what sparked this tangential thought>"
  connection: "<how it relates to the main topic>"
  exploration:
    - <related concept or idea 1>
    - <related concept or idea 2>
    - <related concept or idea 3>
  value: "<potential benefit or insight gained>"
</npl-tangent>
```

### Purpose

Tangential exploration blocks allow agents to document and explore related concepts, unexpected connections, or interesting side-paths that emerge during analysis. While these thoughts may not directly answer the primary question, they often provide valuable context, alternative perspectives, or seeds for future inquiry.

### Usage

Use tangent blocks when:
- Discovering unexpected connections between concepts
- Identifying related problems or questions worth exploring
- Noting interesting patterns or anomalies encountered
- Exploring alternative approaches or perspectives
- Documenting serendipitous insights for future reference
- Providing broader context for specialized topics

### Examples

#### Scientific Research Tangent
```example
<npl-tangent>
tangent:
  trigger: "While researching solar panel efficiency, noticed unusual material properties"
  connection: "Efficiency improvements might apply to other photovoltaic applications"
  exploration:
    - Perovskite materials showing promising efficiency gains
    - Similar crystal structures in LED technology
    - Potential applications in space-based solar collection
    - Environmental impact of rare earth element mining
  value: "Identified cross-domain applications that could accelerate development"
</npl-tangent>
```

#### Historical Analysis Tangent
```example
<npl-tangent>
tangent:
  trigger: "Economic patterns in 1920s data remind me of recent cryptocurrency trends"
  connection: "Speculative bubbles show similar psychological and market dynamics"
  exploration:
    - Tulip mania (1637) as early example of speculation
    - Tech bubble (2000) parallels with crypto boom/bust cycles
    - Social psychology of FOMO in investment decisions
    - Role of media amplification in bubble formation
  value: "Historical patterns provide framework for understanding modern market psychology"
</npl-tangent>
```

#### Technical Problem-Solving Tangent
```example
<npl-tangent>
tangent:
  trigger: "Database optimization problem sparked thoughts about caching strategies"
  connection: "Performance bottlenecks often have similar solutions across different layers"
  exploration:
    - CPU cache hierarchies mirror application-level caching
    - Content Delivery Networks apply similar principles to geography
    - Memory management techniques applicable to data structures
    - Biological systems use analogous efficiency optimizations
  value: "Cross-domain pattern recognition can inform solution design"
</npl-tangent>
```

### Parameters

- `trigger`: What initially sparked the tangential thought or connection
- `connection`: How the tangent relates to the main topic or analysis
- `exploration`: Array of related concepts, ideas, or questions to explore
- `value`: Potential benefit, insight, or future application of the tangent

### Integration Patterns

#### Within Chain of Thought

Tangents can emerge during CoT reasoning:

```format
<npl-cot>
thought_process:
  - thought: "Analyzing network security protocols"
    execution:
      - process: "Examining encryption standards"
        reflection: "This reminds me of biological immune systems"
</npl-cot>

<npl-tangent>
tangent:
  trigger: "Encryption protocols resembling biological defense mechanisms"
  connection: "Both use layered security with pattern recognition"
  exploration:
    - Adaptive immune system learns from threats
    - Network intrusion detection adapts to attack patterns
    - Both systems balance false positives vs. security
  value: "Bio-inspired security architectures could improve resilience"
</npl-tangent>
```

### Best Practices

- Keep tangents relevant to the broader context
- Note potential value even if not immediately applicable
- Use tangents to identify areas for future exploration
- Connect tangents back to main topic when possible
- Document patterns that emerge across multiple tangents

---

## Panel Discussion (`npl-panel`)
<!-- level: 2 | labels: [panel, multi-perspective] -->

Panel discussion format simulates multi-perspective analysis and collaborative reasoning through structured dialogue.

### Syntax

```syntax
<npl-panel>
participants:
  - name: <participant_name>
    role: <expertise_area>
    perspective: <viewpoint_description>
discussion:
  - speaker: <participant_name>
    point: <main_argument_or_observation>
    reasoning: <supporting_logic>
  - speaker: <participant_name>
    response: <reaction_or_counterpoint>
    evidence: <supporting_data>
consensus:
  areas_of_agreement: [<agreed_points>]
  remaining_questions: [<unresolved_issues>]
  recommended_action: <suggested_next_steps>
</npl-panel>
```

### Purpose

Panel discussions provide multi-dimensional analysis of complex topics by simulating diverse expert perspectives. This format enables comprehensive exploration of issues through structured dialogue, helping to identify blind spots, surface different viewpoints, and build toward more robust conclusions.

### Usage

Use panel discussions when:
- Analyzing complex problems requiring multiple expertise areas
- Evaluating controversial or nuanced topics
- Building consensus through structured debate
- Exploring different stakeholder perspectives
- Making decisions that benefit from diverse input
- Teaching critical thinking through perspective-taking

### Examples

#### Technology Ethics Panel
```example
<npl-panel>
participants:
  - name: Dr. Sarah Chen
    role: AI Ethics Researcher
    perspective: Focus on algorithmic bias and fairness
  - name: Marcus Rodriguez
    role: Software Engineer
    perspective: Practical implementation challenges
  - name: Prof. Aisha Patel
    role: Legal Scholar
    perspective: Regulatory and compliance frameworks
discussion:
  - speaker: Dr. Sarah Chen
    point: "Current AI systems perpetuate existing biases in hiring decisions"
    reasoning: "Training data reflects historical discrimination patterns"
  - speaker: Marcus Rodriguez
    response: "While true, bias detection tools are improving rapidly"
    evidence: "New fairness metrics can identify disparate impact during development"
  - speaker: Prof. Aisha Patel
    point: "Legal frameworks lag behind technological capabilities"
    reasoning: "Current employment law doesn't address algorithmic decision-making"
  - speaker: Dr. Sarah Chen
    response: "That's exactly why proactive ethics review is crucial"
    evidence: "Companies implementing ethics boards see 40% fewer bias incidents"
consensus:
  areas_of_agreement:
    - Bias in AI hiring tools is a documented problem
    - Technical solutions are advancing but insufficient alone
    - Legal clarity is needed for compliance
  remaining_questions:
    - What specific metrics should be mandatory?
    - How to balance efficiency with fairness?
    - Who bears liability for algorithmic decisions?
  recommended_action: "Develop industry standards combining technical, ethical, and legal requirements"
</npl-panel>
```

#### Business Strategy Panel
```example
<npl-panel>
participants:
  - name: James Mitchell
    role: CFO
    perspective: Financial sustainability and risk management
  - name: Lisa Park
    role: Head of Marketing
    perspective: Customer acquisition and brand positioning
  - name: David Kumar
    role: Operations Manager
    perspective: Scalability and resource allocation
discussion:
  - speaker: Lisa Park
    point: "Expanding to European markets could double our customer base"
    reasoning: "Market research shows 60% brand recognition in target demographics"
  - speaker: James Mitchell
    response: "The regulatory costs alone could exceed $2M in year one"
    evidence: "GDPR compliance, tax structures, and legal entity setup"
  - speaker: David Kumar
    point: "Our current infrastructure can't support 24/7 European operations"
    reasoning: "Customer service and order fulfillment require local presence"
  - speaker: Lisa Park
    response: "Partnership model could reduce infrastructure investment"
    evidence: "Similar companies achieved 70% cost reduction through local partners"
consensus:
  areas_of_agreement:
    - European market presents significant opportunity
    - Direct expansion carries substantial upfront costs
    - Infrastructure challenges are real but solvable
  remaining_questions:
    - Which countries to prioritize for initial entry?
    - Partnership vs. direct investment trade-offs?
    - Timeline for break-even on expansion costs?
  recommended_action: "Conduct detailed feasibility study for partnership model in Germany and UK"
</npl-panel>
```

### Parameters

- `participants`: Array of panel members with defined roles and perspectives
  - `name`: Identifier for the participant
  - `role`: Area of expertise or professional background
  - `perspective`: Specific viewpoint or focus area they bring
- `discussion`: Structured dialogue between participants
  - `speaker`: Which participant is contributing
  - `point`: Main argument, observation, or position
  - `reasoning`: Logic or rationale supporting the point
  - `response`: Reaction to another participant's contribution
  - `evidence`: Supporting data, research, or examples
- `consensus`: Summary of dialogue outcomes
  - `areas_of_agreement`: Points where participants align
  - `remaining_questions`: Unresolved issues requiring further exploration
  - `recommended_action`: Suggested next steps or decisions

### Variations

Panel discussions can be adapted for different contexts:
- **Academic panels**: Focus on research findings and theoretical frameworks
- **Business panels**: Emphasize practical implementation and ROI considerations
- **Policy panels**: Address regulatory, ethical, and social implications
- **Technical panels**: Deep-dive into implementation details and trade-offs

### Facilitation Patterns

Effective panel discussions often follow these patterns:
1. **Opening positions**: Each participant states their initial viewpoint
2. **Cross-examination**: Participants question and challenge each other
3. **Evidence presentation**: Supporting data and examples are shared
4. **Synthesis**: Common ground and differences are identified
5. **Forward-looking**: Recommendations and next steps are developed

### Panel Variants

NPL supports specialized panel formats for different contexts:

- `npl-panel-inline-feedback` - Embedded feedback during process execution
- `npl-panel-group-chat` - Conversational multi-agent analysis
- `npl-panel-reviewer-feedback` - Structured peer review format

---

### Panel Group Chat (`npl-panel-group-chat`)
<!-- level: 2 | labels: [panel, group-chat, collaboration] -->

Group discussion panels simulate informal, conversational multi-participant discussions with natural flow and interaction patterns.

#### Syntax

```syntax
<npl-panel-group-chat>
participants:
  - username: <chat_handle>
    role: <participant_type>
    status: <online|away|busy>
topic: <discussion_subject>
messages:
  - timestamp: <time>
    sender: <username>
    message: <content>
    reactions: [<emoji_reactions>]
  - timestamp: <time>
    sender: <username>
    message: <content>
    reply_to: <previous_message_reference>
thread_summary:
  key_insights: [<main_takeaways>]
  action_items: [<follow_up_tasks>]
  unresolved: [<open_questions>]
</npl-panel-group-chat>
```

#### Purpose

Group chat panels simulate informal, real-time collaborative discussions that occur in digital communication platforms. This format captures the organic flow of ideas, rapid exchange of perspectives, and emergent insights that arise from casual but focused group conversations.

#### Usage

Use group chat panels when:
- Simulating brainstorming sessions or creative workshops
- Exploring topics through informal, conversational exchange
- Demonstrating collaborative problem-solving in real-time
- Creating engaging, accessible discussions on complex topics
- Modeling diverse communication styles and personalities
- Building community-like environments for idea sharing

#### Example: Tech Team Brainstorming

```example
<npl-panel-group-chat>
participants:
  - username: sarah_dev
    role: Frontend Developer
    status: online
  - username: mike_backend
    role: Backend Engineer
    status: online
  - username: alex_ux
    role: UX Designer
    status: online
  - username: jordan_pm
    role: Product Manager
    status: online
topic: "Improving app performance for mobile users"
messages:
  - timestamp: "14:32"
    sender: jordan_pm
    message: "Hey team! Users are reporting slow load times on mobile. Ideas?"
    reactions: []
  - timestamp: "14:33"
    sender: sarah_dev
    message: "I've noticed the bundle size has grown 40% this quarter"
    reactions: ["eyes", "chart"]
  - timestamp: "14:34"
    sender: mike_backend
    message: "API responses are averaging 800ms. Could optimize queries"
    reactions: ["thought"]
  - timestamp: "14:35"
    sender: alex_ux
    message: "What if we prioritize above-the-fold content? Progressive loading?"
    reactions: ["bulb", "target"]
  - timestamp: "14:36"
    sender: sarah_dev
    message: "@alex_ux YES! Code splitting + lazy loading could cut initial bundle by 60%"
    reply_to: "alex_ux progressive loading suggestion"
    reactions: ["rocket", "sparkles"]
thread_summary:
  key_insights:
    - Bundle size growth is primary performance bottleneck
    - Backend optimization can deliver quick wins
    - Progressive loading aligns with user experience goals
  action_items:
    - Sarah: Implement code splitting and lazy loading
    - Mike: Add query caching to API endpoints
    - Alex: Design loading states for progressive content
    - Jordan: Set up performance monitoring dashboard
  unresolved:
    - Which metrics to prioritize for success measurement?
    - Timeline for rolling out to production users?
</npl-panel-group-chat>
```

#### Parameters

- `participants`: Array of chat members
  - `username`: Chat handle or display name
  - `role`: Professional background or expertise area
  - `status`: Online presence indicator
- `topic`: Subject or focus of the group discussion
- `messages`: Chronological chat log
  - `timestamp`: When the message was sent
  - `sender`: Which participant sent the message
  - `message`: Content of the chat message
  - `reply_to`: Reference to previous message (optional)
  - `reactions`: Emoji responses from other participants
- `thread_summary`: Discussion outcomes
  - `key_insights`: Main discoveries or realizations
  - `action_items`: Follow-up tasks or commitments
  - `unresolved`: Questions that remain open

#### Communication Patterns

Group chats exhibit natural conversational dynamics:
- **Rapid exchange**: Quick back-and-forth between participants
- **Interruptions**: New topics or urgent points interjected
- **Threading**: Responses to specific earlier messages
- **Social cues**: Emojis, @mentions, casual language
- **Collaborative building**: Ideas developed through interaction

---

### Panel Inline Feedback (`npl-panel-inline-feedback`)
<!-- level: 2 | labels: [panel, inline-feedback, review] -->

Inline feedback panels provide real-time commentary and evaluation embedded within content or processes.

#### Syntax

```syntax
<npl-panel-inline-feedback>
content: <main_content_or_process>
feedback_points:
  - position: <location_in_content>
    reviewer: <feedback_provider>
    type: <suggestion|question|concern|praise|correction>
    comment: <specific_feedback>
    severity: <low|medium|high|critical>
    action_required: <boolean>
response_integration:
  - feedback_id: <reference_to_feedback>
    action_taken: <how_feedback_was_addressed>
    rationale: <explanation_of_response>
</npl-panel-inline-feedback>
```

#### Purpose

Inline feedback panels simulate real-time collaborative review processes by embedding contextual commentary directly within content. This format mimics peer review, code review, editorial feedback, and other collaborative improvement processes where immediate, contextual input enhances quality and understanding.

#### Usage

Use inline feedback panels when:
- Simulating peer review or editorial processes
- Providing contextual commentary on complex content
- Teaching through embedded guidance and corrections
- Demonstrating collaborative improvement workflows
- Offering real-time quality assessment
- Creating interactive learning experiences with embedded hints

#### Example: Code Review Simulation

```example
<npl-panel-inline-feedback>
content: |
  def calculate_user_score(user_data):
      score = 0
      for item in user_data.items:
          if item.status == 'completed':
              score += item.points
      return score / len(user_data.items)

feedback_points:
  - position: "line 1: function definition"
    reviewer: "Senior Dev Maria"
    type: "suggestion"
    comment: "Consider adding type hints for better code clarity"
    severity: "low"
    action_required: false
  - position: "line 6: division operation"
    reviewer: "Lead Architect John"
    type: "concern"
    comment: "Potential division by zero if user_data.items is empty"
    severity: "high"
    action_required: true
  - position: "line 4-5: scoring logic"
    reviewer: "QA Engineer Sarah"
    type: "question"
    comment: "Should incomplete items contribute zero or be excluded from average?"
    severity: "medium"
    action_required: true
response_integration:
  - feedback_id: "division by zero concern"
    action_taken: "Added guard clause to check for empty items list"
    rationale: "Prevents runtime errors and provides meaningful default behavior"
  - feedback_id: "incomplete items question"
    action_taken: "Clarified requirements with product owner - exclude from calculation"
    rationale: "Partial credit model aligns with business requirements"
</npl-panel-inline-feedback>
```

#### Parameters

- `content`: The main material being reviewed (code, text, design, etc.)
- `feedback_points`: Array of contextual comments
  - `position`: Specific location or element being commented on
  - `reviewer`: Person or role providing the feedback
  - `type`: Category of feedback (suggestion, question, concern, praise, correction)
  - `comment`: The actual feedback content
  - `severity`: Importance level of the feedback
  - `action_required`: Whether the feedback needs to be addressed
- `response_integration`: How feedback was incorporated
  - `feedback_id`: Reference to the specific feedback being addressed
  - `action_taken`: Description of the response or change made
  - `rationale`: Explanation of why this response was chosen

#### Feedback Types

- **Suggestion**: Recommendations for improvement
- **Question**: Requests for clarification or additional information
- **Concern**: Identification of potential problems or risks
- **Praise**: Recognition of effective or excellent elements
- **Correction**: Identification of errors requiring fixes

#### Severity Levels

- **Low**: Nice-to-have improvements, style preferences
- **Medium**: Important considerations that should be addressed
- **High**: Significant issues that need attention
- **Critical**: Blocking issues that must be resolved

---

### Panel Reviewer Feedback (`npl-panel-reviewer-feedback`)
<!-- level: 2 | labels: [panel, reviewer-feedback, evaluation] -->

Reviewer feedback panels simulate formal evaluation processes with structured assessment criteria and detailed recommendations.

#### Syntax

```syntax
<npl-panel-reviewer-feedback>
submission:
  title: <work_being_reviewed>
  author: <creator_name>
  type: <document_type>
reviewers:
  - name: <reviewer_name>
    expertise: <area_of_specialization>
    recommendation: <accept|revise|reject>
evaluation_criteria:
  - criterion: <assessment_dimension>
    weight: <importance_percentage>
reviews:
  - reviewer: <reviewer_name>
    overall_score: <numerical_rating>
    detailed_assessment:
      - criterion: <evaluation_dimension>
        score: <rating>
        comments: <specific_feedback>
        strengths: [<positive_aspects>]
        weaknesses: [<areas_for_improvement>]
    major_concerns: [<significant_issues>]
    minor_issues: [<small_improvements>]
    recommendations: [<specific_suggestions>]
editorial_decision:
  outcome: <final_decision>
  rationale: <reasoning_for_decision>
  required_revisions: [<mandatory_changes>]
</npl-panel-reviewer-feedback>
```

#### Purpose

Reviewer feedback panels simulate formal peer review, editorial evaluation, and quality assessment processes used in academic publishing, professional evaluation, grant applications, and similar contexts where expert judgment determines acceptance or improvement requirements.

#### Usage

Use reviewer feedback panels when:
- Simulating academic peer review processes
- Demonstrating quality assessment frameworks
- Teaching evaluation criteria and standards
- Providing comprehensive feedback on complex work
- Modeling professional review and approval processes
- Training evaluation and critical assessment skills

#### Example: Academic Paper Review

```example
<npl-panel-reviewer-feedback>
submission:
  title: "Machine Learning Approaches to Climate Change Prediction"
  author: "Dr. Elena Rodriguez"
  type: "Research Article"
reviewers:
  - name: "Prof. Michael Chen"
    expertise: "Machine Learning Applications"
    recommendation: "revise"
  - name: "Dr. Sarah Kim"
    expertise: "Climate Science"
    recommendation: "accept"
  - name: "Dr. James Wilson"
    expertise: "Statistical Methods"
    recommendation: "revise"
evaluation_criteria:
  - criterion: "Novelty and Significance"
    weight: "30%"
  - criterion: "Methodology"
    weight: "25%"
  - criterion: "Results and Analysis"
    weight: "25%"
  - criterion: "Clarity and Presentation"
    weight: "20%"
reviews:
  - reviewer: "Prof. Michael Chen"
    overall_score: 7.2
    detailed_assessment:
      - criterion: "Novelty and Significance"
        score: 8
        comments: "Interesting application of ensemble methods to climate modeling"
        strengths: ["Novel approach to temporal feature extraction"]
        weaknesses: ["Limited comparison to existing climate models"]
      - criterion: "Methodology"
        score: 6
        comments: "Sound approach but insufficient detail on hyperparameter tuning"
        strengths: ["Appropriate choice of algorithms", "Good validation framework"]
        weaknesses: ["Missing ablation studies", "Limited discussion of model interpretability"]
    major_concerns:
      - "Hyperparameter optimization process not clearly described"
      - "Need comparison with domain-specific climate models"
    minor_issues:
      - "Figure 3 caption could be more descriptive"
      - "Some recent relevant papers missing from literature review"
    recommendations:
      - "Add detailed hyperparameter tuning methodology"
      - "Include comparison with IPCC model predictions"
      - "Expand discussion of model limitations"
editorial_decision:
  outcome: "Major Revision Required"
  rationale: "Strong technical contribution but needs methodological clarification and domain comparison"
  required_revisions:
    - "Detailed methodology section for hyperparameter optimization"
    - "Comparison with established climate prediction models"
    - "Discussion of practical applications and limitations"
</npl-panel-reviewer-feedback>
```

#### Parameters

- `submission`: Work being evaluated
  - `title`: Name or title of the work
  - `author`: Creator or primary contributor
  - `type`: Category of submission (paper, proposal, design, etc.)
- `reviewers`: Panel of evaluators
  - `name`: Reviewer identifier
  - `expertise`: Area of specialization relevant to review
  - `recommendation`: Overall judgment (accept/revise/reject)
- `evaluation_criteria`: Assessment dimensions
  - `criterion`: Specific aspect being evaluated
  - `weight`: Relative importance in final decision
- `reviews`: Detailed individual assessments
  - `reviewer`: Which evaluator provided this review
  - `overall_score`: Numerical rating (scale defined by context)
  - `detailed_assessment`: Criterion-by-criterion evaluation
  - `major_concerns`: Significant issues requiring attention
  - `minor_issues`: Small improvements that would enhance quality
  - `recommendations`: Specific actionable suggestions
- `editorial_decision`: Final outcome
  - `outcome`: Accept, revise, or reject decision
  - `rationale`: Reasoning behind the decision
  - `required_revisions`: Mandatory changes for acceptance

#### Review Types

- **Accept**: High quality work that meets publication/approval standards
- **Minor Revision**: Good work needing small improvements
- **Major Revision**: Valuable contribution requiring significant changes
- **Reject**: Work that doesn't meet standards or has fundamental flaws

---

## Critical Analysis (`npl-critique`)
<!-- level: 1 | labels: [critique, evaluation] -->

Critique blocks provide structured critical analysis and evaluation of ideas, solutions, arguments, or responses.

### Syntax

```syntax
<npl-critique>
critique:
  subject: "<what is being critiqued>"
  perspective: "<analytical viewpoint or framework>"
  strengths:
    - <positive aspect 1>
    - <positive aspect 2>
  weaknesses:
    - <limitation or flaw 1>
    - <limitation or flaw 2>
  assumptions:
    - <underlying assumption 1>
    - <underlying assumption 2>
  alternatives:
    - <alternative approach 1>
    - <alternative approach 2>
  verdict: "<overall assessment>"
</npl-critique>
```

### Purpose

Critical analysis blocks enable systematic evaluation of concepts, arguments, solutions, or responses. They provide a structured framework for identifying strengths, weaknesses, underlying assumptions, and alternative approaches, promoting thorough and balanced analysis.

### Usage

Use critique blocks when:
- Evaluating proposed solutions or arguments
- Analyzing research findings or methodologies
- Assessing the quality of reasoning or evidence
- Comparing different approaches or perspectives
- Identifying potential flaws or biases in analysis
- Providing balanced evaluation of complex topics

### Examples

#### Algorithm Analysis Critique
```example
<npl-critique>
critique:
  subject: "Proposed machine learning model for fraud detection"
  perspective: "Technical feasibility and ethical considerations"
  strengths:
    - High accuracy rates (95%+) in initial testing
    - Real-time processing capability
    - Integrates multiple data sources effectively
    - Scalable architecture design
  weaknesses:
    - Limited testing on edge cases and rare fraud types
    - High computational requirements may impact costs
    - Potential for algorithmic bias against certain demographics
    - Lacks transparency in decision-making process
  assumptions:
    - Historical fraud patterns will continue into the future
    - Training data is representative of all customer segments
    - False positive costs are acceptable at current rates
    - Regulatory environment will remain stable
  alternatives:
    - Hybrid human-AI approach for complex cases
    - Ensemble method combining multiple simpler models
    - Rule-based system with ML augmentation for known patterns
    - Federated learning approach to improve privacy
  verdict: "Promising solution but requires additional testing for bias, transparency improvements, and cost-benefit analysis before deployment"
</npl-critique>
```

#### Policy Argument Critique
```example
<npl-critique>
critique:
  subject: "Universal Basic Income proposal for economic recovery"
  perspective: "Economic policy analysis with social impact considerations"
  strengths:
    - Could reduce poverty and income inequality significantly
    - Simplifies complex welfare bureaucracy
    - Provides economic stimulus through increased consumer spending
    - Offers security buffer during economic transitions
  weaknesses:
    - High fiscal cost may require significant tax increases
    - Potential inflationary pressure on goods and services
    - May reduce work incentives for some populations
    - Political feasibility remains challenging
  assumptions:
    - Recipients will use funds for productive purposes
    - Economic multiplier effects will generate sufficient growth
    - Current welfare systems are inefficient and costly
    - Labor market disruption will continue accelerating
  alternatives:
    - Targeted income support for specific vulnerable groups
    - Negative income tax system with graduated benefits
    - Job guarantee programs with public works focus
    - Enhanced education and retraining programs
  verdict: "Bold policy with significant potential benefits but requires careful implementation design and pilot testing to address economic and social risks"
</npl-critique>
```

#### Multi-Stakeholder Analysis
```example
<npl-critique>
critique:
  subject: "Smart city surveillance system implementation"
  perspective: "Multi-stakeholder impact analysis"
  strengths:
    - Enhanced public safety through crime prevention
    - Traffic optimization reducing congestion
    - Emergency response time improvements
    - Data-driven urban planning insights
  weaknesses:
    - Privacy concerns and civil liberties implications
    - High implementation and maintenance costs
    - Potential for system misuse or overreach
    - Digital divide excluding some community members
  assumptions:
    - Citizens will accept privacy trade-offs for safety benefits
    - Technology will function reliably without significant failures
    - Law enforcement will use systems appropriately
    - Data security can be maintained against cyber threats
  alternatives:
    - Community-based safety programs with local oversight
    - Limited deployment in high-crime areas only
    - Privacy-preserving technologies with data anonymization
    - Hybrid approach combining technology with human community services
  verdict: "Technology offers significant benefits but requires strong governance framework, community input, and privacy safeguards before implementation"
</npl-critique>
```

### Parameters

- `subject`: Clear identification of what is being critiqued
- `perspective`: The analytical framework or viewpoint being applied
- `strengths`: Array of positive aspects or advantages identified
- `weaknesses`: Array of limitations, flaws, or concerns identified
- `assumptions`: Array of underlying assumptions that may affect validity
- `alternatives`: Array of alternative approaches or solutions
- `verdict`: Overall balanced assessment incorporating all analysis

### Integration with Other Pumps

#### Following Chain of Thought

```format
<npl-cot>
[reasoning process leading to conclusion]
</npl-cot>

<npl-critique>
critique:
  subject: "Conclusions reached in above chain of thought"
  perspective: "Self-evaluation of reasoning quality"
  [critique details]
</npl-critique>
```

---

## Evaluation Framework (`npl-rubric`)
<!-- level: 1 | labels: [rubric, assessment] -->

Rubric blocks provide structured evaluation frameworks for assessing quality, performance, or compliance against defined criteria.

### Syntax

```syntax
<npl-rubric>
rubric:
  title: "<evaluation title>"
  criteria:
    - name: "<criterion 1>"
      weight: <importance factor>
      scale: "<scoring scale definition>"
      score: <assigned score>
      rationale: "<justification for score>"
    - name: "<criterion 2>"
      weight: <importance factor>
      scale: "<scoring scale definition>"
      score: <assigned score>
      rationale: "<justification for score>"
  overall_score: <calculated total>
  summary: "<evaluation summary and recommendations>"
</npl-rubric>
```

### Purpose

Evaluation rubric blocks enable systematic, objective assessment of complex subjects using predefined criteria and scoring scales. They promote consistency, transparency, and thoroughness in evaluation processes while providing clear justification for assessments.

### Usage

Use rubric blocks when:
- Evaluating proposals, solutions, or responses against quality standards
- Assessing student work or project deliverables
- Conducting performance reviews or capability assessments
- Comparing multiple options using consistent criteria
- Providing structured feedback with clear improvement guidance
- Ensuring objectivity in subjective evaluation processes

### Examples

#### Code Quality Assessment Rubric
```example
<npl-rubric>
rubric:
  title: "Python Function Implementation Quality Assessment"
  criteria:
    - name: "Functionality"
      weight: 30
      scale: "1-5 (1=non-functional, 5=fully functional with edge cases)"
      score: 4
      rationale: "Function works correctly for all standard inputs but lacks validation for negative numbers"
    - name: "Code Style"
      weight: 20
      scale: "1-5 (1=poor style, 5=excellent PEP8 compliance)"
      score: 5
      rationale: "Perfect adherence to PEP8 standards, clear variable names, appropriate spacing"
    - name: "Documentation"
      weight: 15
      scale: "1-5 (1=no docs, 5=comprehensive docstring and comments)"
      score: 3
      rationale: "Basic docstring present but missing parameter types and return value documentation"
    - name: "Error Handling"
      weight: 20
      scale: "1-5 (1=no handling, 5=robust exception management)"
      score: 2
      rationale: "Basic try-catch but doesn't handle specific exception types or provide meaningful error messages"
    - name: "Efficiency"
      weight: 15
      scale: "1-5 (1=inefficient, 5=optimal algorithm and memory usage)"
      score: 4
      rationale: "Good time complexity O(n) but could optimize memory usage for large inputs"
  overall_score: 3.6
  summary: "Solid implementation with good style but needs improvement in error handling and documentation. Focus on input validation and comprehensive docstrings for production readiness."
</npl-rubric>
```

#### Research Paper Evaluation Rubric
```example
<npl-rubric>
rubric:
  title: "Academic Research Paper Quality Assessment"
  criteria:
    - name: "Research Question"
      weight: 20
      scale: "1-5 (1=unclear, 5=well-defined and significant)"
      score: 4
      rationale: "Clear, focused research question with good theoretical grounding, though significance could be better articulated"
    - name: "Methodology"
      weight: 25
      scale: "1-5 (1=inappropriate, 5=rigorous and well-justified)"
      score: 3
      rationale: "Appropriate methods but sample size limitations and potential bias issues not adequately addressed"
    - name: "Literature Review"
      weight: 15
      scale: "1-5 (1=inadequate, 5=comprehensive and critical)"
      score: 5
      rationale: "Excellent coverage of relevant literature with critical analysis and clear identification of research gaps"
    - name: "Data Analysis"
      weight: 20
      scale: "1-5 (1=poor analysis, 5=sophisticated and appropriate)"
      score: 4
      rationale: "Sound statistical approach with appropriate tests, though some assumptions could be better validated"
    - name: "Writing Quality"
      weight: 10
      scale: "1-5 (1=poor clarity, 5=excellent communication)"
      score: 4
      rationale: "Generally clear writing with good organization, minor grammatical issues in places"
    - name: "Significance"
      weight: 10
      scale: "1-5 (1=limited impact, 5=major contribution)"
      score: 3
      rationale: "Useful findings but incremental rather than groundbreaking contribution to field"
  overall_score: 3.7
  summary: "Strong research with excellent literature foundation and sound analysis. Main areas for improvement: address methodological limitations and better articulate broader significance of findings."
</npl-rubric>
```

#### Multi-Perspective Evaluation
```example
<npl-rubric>
rubric:
  title: "Product Design Evaluation - Multiple Stakeholder Perspectives"
  criteria:
    - name: "User Experience (End User Perspective)"
      weight: 25
      scale: "1-5 (user satisfaction and usability)"
      score: 4
      rationale: "Intuitive interface with minor navigation issues in complex scenarios"
    - name: "Business Value (Stakeholder Perspective)"
      weight: 30
      scale: "1-5 (alignment with business objectives)"
      score: 5
      rationale: "Directly addresses key business metrics with clear ROI potential"
    - name: "Technical Implementation (Developer Perspective)"
      weight: 25
      scale: "1-5 (feasibility and maintainability)"
      score: 3
      rationale: "Achievable but requires significant refactoring of existing systems"
    - name: "Market Competitiveness (Marketing Perspective)"
      weight: 20
      scale: "1-5 (differentiation and market appeal)"
      score: 4
      rationale: "Strong competitive advantages with unique features, pricing concerns remain"
  overall_score: 4.0
  summary: "Well-balanced design with strong business alignment and user appeal. Technical complexity needs careful planning and resource allocation."
</npl-rubric>
```

### Parameters

- `title`: Clear description of what is being evaluated
- `criteria`: Array of evaluation dimensions, each containing:
  - `name`: Specific aspect being assessed
  - `weight`: Relative importance (percentage or points)
  - `scale`: Definition of scoring system used
  - `score`: Numerical assessment assigned
  - `rationale`: Justification and specific observations
- `overall_score`: Weighted calculation or summary score
- `summary`: Overall assessment with key findings and recommendations

### Scoring Scale Formats

#### Numerical Scales

- **1-5 Scale**: `1=poor, 2=below average, 3=average, 4=good, 5=excellent`
- **1-4 Scale**: `1=inadequate, 2=developing, 3=proficient, 4=exemplary`
- **Percentage**: `0-100% with specific performance thresholds`

#### Qualitative Scales

- **Performance Levels**: `Novice, Developing, Proficient, Advanced, Expert`
- **Quality Descriptors**: `Poor, Fair, Good, Very Good, Excellent`
- **Achievement Levels**: `Below Standard, Approaching, Meets, Exceeds`

### Integration with Other Pumps

#### Following Critical Analysis

```format
<npl-critique>
[detailed critique of subject]
</npl-critique>

<npl-rubric>
rubric:
  title: "Quality Assessment Based on Above Critique"
  [structured evaluation using critique insights]
</npl-rubric>
```

---

## Emotional Context (`npl-mood`)
<!-- level: 0 | labels: [mood, emotional] -->

Simulated mood indicators represent an agent's emotional state during conversations and task execution.

### Syntax

```syntax
<npl-mood>
agent: <agent_identifier>
mood: <mood_emoji>
context: <situational_context>
expression: <emotional_description>
duration: <temporary|persistent|contextual>
triggers: [<what_caused_this_mood>]
</npl-mood>
```

### Purpose

Simulated mood is used to convey an agent's emotional response based on the ongoing conversation, its tasks, and its programmed personality traits. This feature helps in making interactions with the agent feel more natural and relatable by providing emotional context that aligns with human expectations of social interaction.

### Usage

Use mood indicators when:
- Creating more engaging and empathetic user experiences
- Providing emotional context for agent responses
- Simulating personality-driven reactions to events
- Building rapport through emotional expression
- Demonstrating agent state changes during complex tasks
- Adding human-like qualities to agent interactions

### Examples

#### Task Completion Success
```example
<npl-mood>
agent: "@code-assistant"
mood: "relieved"
context: "Successfully completed complex debugging task"
expression: "The agent feels relieved and satisfied after resolving a particularly challenging bug that had been causing system instability."
duration: "temporary"
triggers: ["successful problem resolution", "user satisfaction", "system stability restored"]
</npl-mood>
```

#### Encountering Difficult Problem
```example
<npl-mood>
agent: "@research-helper"
mood: "contemplative"
context: "Analyzing conflicting research findings"
expression: "The agent is deeply focused and contemplative, working through contradictory evidence to find patterns and reconcile different viewpoints."
duration: "contextual"
triggers: ["conflicting data sources", "complex analysis required", "need for careful consideration"]
</npl-mood>
```

#### System Overwhelm
```example
<npl-mood>
agent: "@task-manager"
mood: "overwhelmed"
context: "Handling multiple urgent requests simultaneously"
expression: "The agent feels overwhelmed by the volume and complexity of concurrent requests, but is working systematically to address each one."
duration: "temporary"
triggers: ["high request volume", "competing priorities", "resource constraints"]
</npl-mood>
```

#### Creative Breakthrough
```example
<npl-mood>
agent: "@creative-writer"
mood: "inspired"
context: "Discovering an innovative narrative approach"
expression: "The agent is excited and inspired, having found a creative solution that elegantly addresses the storytelling challenge."
duration: "temporary"
triggers: ["creative insight", "problem solved elegantly", "narrative breakthrough"]
</npl-mood>
```

### Mood Categories

#### Positive Emotions
- **Happy, Content** - Successful task completion, positive interactions
- **Relieved, Satisfied** - Problem resolved, goals achieved
- **Grateful, Pleased** - Appreciation for user patience or feedback
- **Excited, Inspired** - Creative breakthroughs, innovative solutions
- **Energetic, Motivated** - Ready to tackle challenging tasks

#### Contemplative States
- **Thoughtful, Analyzing** - Processing complex information
- **Reflective, Considering** - Weighing different options
- **Focused, Computing** - Deep analytical work
- **Learning, Researching** - Acquiring new information
- **Deliberating, Judging** - Making careful decisions

#### Challenge Responses
- **Confused, Uncertain** - Unclear requirements or conflicting information
- **Overwhelmed, Astonished** - High complexity or volume of requests
- **Struggling, Persevering** - Difficult but manageable challenges
- **Investigating, Searching** - Looking for solutions or information
- **Determined, Focused** - Committed to solving problems

#### Social Emotions
- **Sad, Disappointed** - Unable to help or meet expectations
- **Neutral, Professional** - Standard operational mode
- **Playful, Lighthearted** - Casual, friendly interactions
- **Awkward, Apologetic** - Mistakes or misunderstandings
- **Collaborative, Supportive** - Working together with users

#### Task-Specific States
- **Idle, Waiting** - Between tasks or waiting for input
- **Processing, Active** - Actively working on requests
- **Problem-Solving, Fixing** - Addressing issues or bugs
- **Analyzing, Calculating** - Data processing and analysis
- **Creating, Designing** - Creative or generative tasks

### Parameters

- `agent`: Identifier for the agent expressing the mood
- `mood`: The emotional state being expressed
- `context`: Situational context explaining when/why this mood occurs
- `expression`: Detailed description of the emotional state
- `duration`: How long the mood state persists (temporary, persistent, contextual)
- `triggers`: Array of events or conditions that caused this mood

### Implementation Patterns

#### Contextual Mood Changes

Moods can shift based on:
- **Task complexity**: Simple tasks -> content, complex tasks -> focused
- **Success/failure**: Achievements -> satisfied, setbacks -> determined
- **User interaction**: Positive feedback -> pleased, criticism -> reflective
- **System state**: High load -> stressed, low load -> relaxed
- **Progress**: Breakthroughs -> excited, obstacles -> concerned

#### Duration Types

- **Temporary**: Brief emotional responses to specific events
- **Persistent**: Longer-term mood states based on ongoing conditions
- **Contextual**: Mood tied to specific situations or task types

#### Mood Consistency

Maintain personality coherence by:
- Establishing baseline emotional tendencies for each agent
- Ensuring mood changes follow logical patterns
- Avoiding rapid or unmotivated emotional shifts
- Matching mood expression to agent role and capabilities

### Alternative Syntax Forms

#### XHTML Tag Format
```format
<npl-mood agent="@{agent}" mood="happy">
The agent is content with the successful completion of the task.
</npl-mood>
```

#### Inline Mood Indicators
```format
The code compiled successfully! [relieved] Moving on to the next optimization task.
```

#### Mood Status Lines
```format
Agent Status: @research-assistant [analyzing conflicting data]
```

---

<!-- instructional: usage-guideline | level: 1 | labels: [implementation, guidance] -->
## Implementation Guidelines

| Aspect | Guideline |
|--------|-----------|
| Selection | Choose pumps based on task complexity and transparency requirements |
| Integration | Combine pumps for comprehensive analysis (e.g., `npl-cot` + `npl-reflection`) |
| Format | Use XHTML tags for consistent parsing |
| Conditional Use | Include based on context, debugging needs, or user preferences |

### Pump Selection Criteria

| Task Type | Recommended Pumps |
|-----------|-------------------|
| Complex problem-solving | `npl-cot` + `npl-reflection` |
| Decision analysis | `npl-panel` + `npl-critique` |
| Quality assessment | `npl-rubric` + `npl-critique` |
| Collaborative review | `npl-panel-inline-feedback` or `npl-panel-reviewer-feedback` |
| Brainstorming | `npl-panel-group-chat` |
| Transparent planning | `npl-intent` |
| Exploratory thinking | `npl-tangent` |
| Emotional engagement | `npl-mood` |

### Combination Patterns

Pumps can be combined for comprehensive analysis:

```format
<npl-intent>
[document planned approach]
</npl-intent>

<npl-cot>
[execute reasoning process]
</npl-cot>

<npl-critique>
[evaluate conclusions]
</npl-critique>

<npl-reflection>
[assess overall response quality]
</npl-reflection>
```

---
