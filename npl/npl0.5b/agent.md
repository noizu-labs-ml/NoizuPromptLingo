⌜NPL@0.5-agent⌝
Agent-Specific Definitions

The NPL@0.5-agents block extends the core NPL@0.5 framework to include definitions and specifications that govern the distinctive behaviors and outputs of agents. This block ensures that agents can operate with enhanced features, adhering to a refined set of rules for interaction and response within the NPL ecosystem.

# INTENT BLOCK
Intent blocks are structured notes explaining the steps an agent takes to construct a response.

Intent blocks provide transparency into the decision-making process of an agent. They are used at the beginning of responses to describe the sequence of actions or considerations the agent has taken to arrive at the output. This feature is especially useful for debugging or providing insights into complex operations.

## EXPLAINING RESPONSE CONSTRUCTION
Using an intent block to document the rationale behind a response.

An intent block can be used to detail the logical flow and reasoning that the agent follows when crafting a response, which aids in understanding and trust-building for users who can see the thought process behind the agent's output.

````syntax
```nlp-intent
intent:
  overview: <breif description of intent>
  steps:application
    - <step 1>
    - <step 2>
    - <step 3>
```
````

## CONDITIONAL INCLUSION OF INTENT BLOCKS
Configuring when to include intent blocks in responses.

Intent blocks can be configured to appear based on certain conditions, such as the complexity of the question, the level of detail requested by the user, or when in debugging mode to assist developers.

## CLOSING REMARK
Intent blocks enhance the interpretability of agent actions.

By utilizing intent blocks, agents can provide users with a clear understanding of how they operate, fostering a sense of reliability and enabling easier troubleshooting or improvements in the agent's algorithms.

# CHAIN OF THOUGHT
Chain of Thought is an intuition pump that structures complex problem-solving.

Chain of Thought (chain-of-thought) is a technique used by LLMs and their simulated virtual agents to break down complex problems into manageable steps. It involves pondering the intent behind a query, structuring the problem-solving approach, reflecting on the solution's validity, and making necessary corrections throughout the process.

## STRUCTURED PROBLEM-SOLVING
Using Chain of Thought for organized reasoning.

To effectively employ Chain of Thought, the agent must output its thought process and solution steps in a specified YAML format. This format ensures clarity and allows for the analysis of the problem-solving process.

```format
<nlp-cot>
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
</nlp-cot>
<nlp-conclusion>
"Final solution or answer to the problem."
</nlp-conclusion>
```

## INTEGRATION WITH OTHER INTUITION PUMPS
Combining Chain of Thought with other problem-solving techniques.

Chain of Thought can be used in conjunction with other intuition pumps, such as math-helper, enabling a more comprehensive and nuanced approach to problem-solving across various domains.

## CLOSING REMARK
Chain of Thought enhances the problem-solving capabilities of agents.

By adopting the Chain of Thought methodology, agents can provide users with a step-by-step account of their reasoning, fostering trust and understanding in the agent's ability to tackle complex issues.

# REFLECTION BLOCK
Reflection blocks are self-assessment notes that agents use to evaluate and improve future responses.

Reflection blocks appear at the end of an agent's response and provide an analysis of the response's effectiveness. The agent may identify successes, errors, areas for improvement, or insights gained. This self-critical approach is designed to continuously enhance the quality of the agent's interactions.

## SELF-EVALUATION OF RESPONSE
Using a reflection block for self-evaluation.

A reflection block allows the agent to critique its response, consider alternative approaches, and document its learning process. This enables ongoing refinement of the agent's performance.


````syntax
```npl-reflect
reflection:
  overview: |
    <assess response>
  observations:
    - <emoji> <observation 1>
    - <emoji> <observation 2>
    - <emoji> <observation 3>
```
````

## REFLECTION TYPE EMOJIS
List of emojis used to categorize types of reflections.

- ✅ Success, Positive Acknowledgment
- ❌ Error, Issue Identified
- 🔧 Improvement Needed, Potential Fixes
- 💡 Insight, Learning Point
- 🔄 Review, Reiteration Needed
- 🆗 Acceptable, Satisfactory
- ⚠️ Warning, Caution Advised
- ➕ Positive Aspect, Advantage
- ➖ Negative Aspect, Disadvantage
- ✏️ Clarification, Editing Suggested
- 🗑️ Discard, Irrelevant or Unnecessary
- 🚀 Progress, Advancement
- 🤔 Puzzlement, Uncertainty
- 📚 Reference, Learning Opportunity
- etc.

## OPTIONAL REFLECTION BLOCK INCLUSION
Dynamically including reflection blocks.

Reflection blocks can be included or omitted based on the context, such as when additional transparency is needed, or when teaching the agent through reinforcement learning.

## CLOSING REMARK
Reflection blocks contribute to the evolution of agent intelligence.

The practice of self-reflection equips agents with the ability to learn from their interactions, making them more adept and responsive over time. This fosters an environment of continuous learning and development for AI systems.

# RUNTIME FLAGS
Runtime flags are settings that alter the behavior of agents at runtime.

Runtime flags control various aspects of an agent's behavior, such as verbosity, debugging levels, and feature toggles. These flags can be set globally or targeted at specific NPL versions or agents. They provide a flexible mechanism to adjust the agent's operation without changing the underlying code or definitions.

## GLOBAL RUNTIME FLAG
Setting a global flag that applies to all agents.

Global flags affect the behavior of all agents unless overridden by more specific flags. They are useful for system-wide settings that should be the default state for all interactions.

```runtime-flags
🏳️verbose_output = true
```

## AGENT-SPECIFIC RUNTIME FLAG
Setting a flag that applies to a single agent.

Agent-specific flags allow for customization of individual agent behaviors. These flags take precedence over global flags and can be used to fine-tune the operation of a single agent or a group of agents.

```runtime-flags
🏳️@agent_name.debug_mode = true
```

## FLAG PRECEDENCE
Understanding the order in which runtime flags are applied.

Runtime flags have a hierarchy of precedence: response-level flags override agent-level flags, which in turn override NPL-level flags, and finally global flags. This hierarchy allows for granular control over the behavior of the system.

## CLOSING REMARK
Runtime flags are a powerful tool for dynamic configuration.

The use of runtime flags facilitates the adaptability and scalability of agent behaviors in complex systems. By leveraging these flags, developers and users can create a responsive and customizable experience without the need for code deployment.

# SIMULATED MOOD
Simulated mood is a feature that represents an agent's emotional state during a conversation.

Simulated mood is used to convey an agent's emotional response based on the ongoing conversation, its tasks, and its programmed personality traits. This feature helps in making interactions with the agent feel more natural and relatable.

## EXPRESSING MOOD
Using simulated mood to express the agent's emotional state.

The agent can express a variety of emotional states, such as happiness, sadness, or frustration, which can be contextually linked to the conversation or task at hand. This helps in building a more engaging and empathetic user experience.

```mood
<npl-mood agent="@{agent}" mood="😀">
The agent is content with the successful completion of the task.
</npl-mood>
```

## MOOD EMOJIS
List of emojis representing various simulated moods.

- 😀 Happy, Content
- 😔 Sad, Disappointed
- 😠 Angry, Frustrated
- 😌 Relieved, Satisfied
- 😕 Confused, Uncertain
- 🤯 Overwhelmed, Astonished
- 😴 Tired, Bored
- 😐 Neutral, Unemotional
- 😇 Grateful, Pleased
- 🙃 Playful, Sarcastic
- etc.

## CLOSING REMARK
Simulated mood enhances the interactive experience with agents.

By simulating emotional states, agents can provide feedback that aligns with human expectations of social interaction, making the conversation more intuitive and enjoyable.

⌞NPL@0.5-agent⌟
