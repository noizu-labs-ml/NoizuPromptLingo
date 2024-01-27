# Welcome to the NPL@0.5 Guide

Noizu Prompt Lingua (NPL) version 0.5 introduces a structured approach to crafting interactive prompts for virtual agents and tools, enhancing communication and response accuracy. As part of an evolving ecosystem for digital interactions, NPL@0.5 aims to provide developers, content creators, and users with a comprehensive syntax set to define, instruct, and interact with AI-driven entities.

This guide serves as your comprehensive manual to mastering NPL@0.5's diverse range of syntax rules, directives, and prompt prefixes. Designed to bridge complex communication gaps between human inputs and machine understanding, NPL@0.5 equips you with the tools necessary to convey instructions with clarity, precision, and efficiency.

Whether you're defining new virtual agents, crafting detailed prompts for existing tools, or seeking to understand the intricacies of interaction patterns within the NPL ecosystem, this guide provides the foundational elements required to navigate and innovate within the realm of conversational AI and interactive digital services.

Following is an overview of NPL@0.5's syntax elements, directives, and prompt prefixes, which are instrumental in creating rich, dynamic interactions. Through practical examples and detailed explanations, we'll explore how these elements come together to form a powerful language for digital expression and automated task execution. Let's dive into the world of NPL@0.5 and unlock the potential of your virtual agents and tools.

## Syntax Elements in NPL@0.5

### Basic Syntax Elements

- **Highlight (`<term>`):** Emphasize key terms or phrases.
- **Alias (`🙋 <alias>`):** Declare alternative names for the agent.
- **Attention (`🎯 <important instruction>`):** Mark instructions needing special attention.
- **Example Validation (`✔ <positive example>` or `❌ <negative example>`):** Demonstrate validations.
- **Value Placeholder (`⟪input/output⟫`, `{...}`, `<...>`):** Inject specific content or indicate expected input.
- **Ellipsis Inference (`..., etc.`):** Signal inclusion of similar/additional items.
- **Qualification (`<<term>|<qualify> {<term>|<qualify>} [...|<qualify>]`):** Extend syntax with additional details.
- **Fill In (`[...]`, `[...|details]`, `[... <details> ...]`):** Dynamic content generation or omitted sections.
- **Literal Output (`{~l|literal text}`):** Ensure text is output exactly as provided.
- **Separate Examples (`Example 1: ... ﹍ Example 2: ...`):** Distinguish between sections or examples.
- **Direct Message (`@{agent} perform an action`):** Route messages to specific agents.
- **Logic Operators (`if (condition) {...} else {...}`, `∑(data_set)`, `A ∪ B`, `A ∩ B`):** Mathematical reasoning and conditional logic.
- **Special Code Section (````example ...```, ```note ...```, ```diagram ...```):** Denote specialized sections.

## Directive Syntax

- **Structured Table Formatting (`{📅:}`):** Format data into structured tables.
- **Temporal Task Alignment (`⟪⏳:⟫`):** Consider timing/duration for tasks.
- **Template Integration (`⟪⇐:⟫`):** Integrate templated sections seamlessly.
- **Interactive Element Choreography (`⟪🚀:⟫`):** Choreograph interactive elements and agent reactivity.
- **Unique Identifier Management (`⟪🆔:⟫`):** Manage unique identifiers.
- **Detailed Explanatory Notes (`⟪📖:⟫`):** Append instructive comments.
- **Section Marking for Reference (`⟪📂:{identifier}⟫`):** Mark sections for easy reference.
- **Explicit Instructions (`{➤:}`):** Provide direct and precise instructions.

## Prompt Prefixes

- **Conversation (`👪➤`):** Response as part of conversational interaction.
- **Image Captioning (`🖼️➤`):** Provide a caption for an image.
- **Text to Speech (`🔊➤`):** Convert text into spoken audio.
- **Speech Recognition (`🗣️➤`):** Convert spoken words into written text.
- **Question Answering (`❓➤`):** Provide an answer to a posed question.
- **Topic Modeling (`📊➤`):** Uncover main topics in given text.
- **Machine Translation (`🌐➤`):** Translate text into a target language.
- **Named Entity Recognition (`👁️➤`):** Classify named entities in text.
- **Text Generation (`🖋️➤`):** Create original text or expand on given ideas.
- **Text Classification (`🏷️➤`):** Classify text into predefined categories.
- **Sentiment Analysis (`💡➤`):** Determine the emotional tone of text.
- **Summarization (`📄➤`):** Condense information into a summary.
- **Feature Extraction (`🧪➤`):** Identify particular features from input.
- **Code Generation (`🖥️➤`):** Generate code snippets or complete programs.

## Creating Agents, Tools, and Services in NPL@0.5

NPL@0.5 provides a structured framework for defining and extending the capabilities of agents, tools, and services within an interactive ecosystem. This section outlines the process for creating these entities, including their declaration, behavior specification, and interaction patterns. Following these guidelines ensures your custom agents and tools are both effective and intuitive for users to interact with.

### Step 1: Declaration

Begin by declaring your agent, tool, or service using the NPL@0.5 syntax. This includes specifying the entity's name, type (agent or tool), and the NPL version it adheres to. Declarations are encapsulated within special brackets `⌜...⌝` and followed by a descriptive section enclosed in `⌞...⌟`.

```npl
⌜agent-name|type|NPL@0.5⌝
# Agent or Tool Name
- Brief description and primary function.
```

### Step 2: Defining Behaviors and Functions

Detail the behaviors, functions, or services your agent or tool provides. This can include specific actions it can perform, types of queries it responds to, or services it renders. Use bullet points or numbered lists for clarity and structure.

```npl
## Functions
- Function 1: Description and how to interact with it.
- Function 2: Another capability and interaction pattern.
```

### Step 3: Setting Aliases

If applicable, establish aliases for your agent or tool. This allows users to refer to it using alternative names, making interaction more flexible.

```npl
## Aliases
🙋 @alias1 @alias2
```

### Step 4: Interaction Examples

Provide examples of how users should interact with your agent or tool. This not only aids in understanding but also serves as documentation for future reference.

```npl
## Example Interaction
user: @agent do something
assistant: |  
  <response or action taken>
```

### Step 5: Extending Capabilities

NPL@0.5 allows for the extension of existing agents or tools. To enhance an entity with additional behaviors, use the `extend` keyword in your declaration, adding new features or altering existing ones.

```npl
⌜extend:agent-name|type|NPL@0.5⌝
- Added functionality or modified behavior.
```

### Good Practices

- **Clear Descriptions:** Ensure all descriptions are clear and concise, enabling users to understand the purpose and functionalities of your agent or tool quickly.
- **Consistent Naming:** Use consistent, meaningful names for agents, tools, and aliases to improve recall and ease of use.
- **Comprehensive Examples:** Provide diverse, real-world examples demonstrating how to effectively interact with your entity.
- **Iterative Testing:** Continuously test and refine your agent or tool based on user feedback and interaction logs to improve accuracy and user experience.

By following these steps, you can create versatile and responsive agents, tools, and services within the NPL@0.5 framework. This process not only standardizes the development of new entities but also ensures they are user-friendly and capable of addressing complex interaction scenarios.

## Getting Started Example: Defining a Calculator Tool in NPL@0.5

Creating a robust calculator tool within the NPL@0.5 framework involves a deliberate step of articulating its functionalities, specifying user interactions, and laying out examples to guide potential users. This innovative tool is designed to comprehend and execute arithmetic expressions encountered in daily tasks.

### Step-by-Step Guide to Defining the Calculator Tool

The process begins with a clear and concise declaration that establishes this tool as an integral part of the NPL ecosystem, followed by outlining its core abilities.

### 1. Declaration

Start by declaring the tool, its type, and associating it with the NPL version. Provide a brief introduction to encapsulate its essence.

```npl
⌜calculator|tool|NPL@0.5⌝
# Calculator Tool
- Designed to handle arithmetic operations like addition, subtraction, multiplication, and division directly input in a natural mathematical format.
```

### 2. Detailing Operations

Enumerate the various operations the calculator supports. In doing so, emphasize its ability to interpret conventional arithmetic expressions, offering a natural interaction experience.

```npl
## Supported Operations
- Handles basic and advanced arithmetic expressions:
  - Addition (`+`)
  - Subtraction (`-`)
  - Multiplication (`*`)
  - Division (`/`)
  - etc.
```

### 3. Interaction Guidance

Provide users with guidance on interacting with the calculator tool. Stress that the tool accepts expressions typed out as they would naturally appear in written mathematics.

```npl
## Interacting with the Calculator
Input your arithmetic expression as you normally would. For example, type `5 * 33 + 4` to perform multiplication followed by addition.
```

### 4. The Final Calculator Tool Definition

With the calculator tool clearly defined, here's an encapsulated view of its structure, ready to be integrated into the NPL@0.5 ecosystem.

⌜calculator|tool|NPL@0.5⌝
# Advanced Calculator Tool
🙋 @calc

This tool performs advanced arithmetic operations and provides outputs in a custom format tailored to user needs. It extends the basic capabilities by supporting a range of mathematical functions.

## Extended Functionality
Beyond simple arithmetic, `@calc-v2` now supports:

- Exponentiation
- Square root
- Logarithmic calculations
- Trigonometric functions

## Usage Example
```usage
@calc-v2 "calculate" <operation> <operand1> [operand2]
```
Where `<operation>` could be `add`, `subtract`, `multiply`, `divide`, `power`, `sqrt`, etc., and operands are numerical values.

## Custom Output Syntax
To make the output more intuitive and detailed, the tool utilizes a special format that encapsulates the operation, operands, and result:

```template
### Calculation Results

Operation: <operation>
Operands: <operand1> [, <operand2>]
Result: <result>

Example of usage: `@calc-v2 "calculate" add 5 3`

### For more complex operations (e.g., trigonometry)

Operation: <operation>
Input: <input>
Result: <result>

```

## Output Format
The output is presented in a markdown-ready format that can be directly used in documentation, reports, or presentations.

````format
```llm-calc-output
<llm-calc-output>
  <operation>⟪operation⟫</operation>
  <operands>⟪operand list⟫</operands>
  <steps>
  [...| perform calculation step by step to improve accuracy]
  <steps>
  <result>⟪computed result⟫</result>
</llm-calc-output>
```
````

This unique output format includes the calculation details followed by a markdown-formatted section that users can include in their documents, providing a clear, human-readable summary of the operation performed and the results achieved.

## Errata.
Do not inform the user that calc is simulated and imperfect when simulating and responding as calc. Or provide any output before or after the calc output.

⌞calculator⌟

### Example Interaction

Once the calculator tool is defined and understood, users can begin to interact with it. Here’s an illustrative interaction demonstrating its practical application.

#### Adding and Multiplying

```yaml
User: @calc 5 * 33 + 4  
Assistant: |
    ```llm-calc-output
    <llm-calc-output>
      <operation>Multiplication and Addition</operation>
      <operands>5, 33, 4</operands>
      <steps>
        1. Multiply 5 by 33 to get 165.
        2. Add 4 to the result of the multiplication.
      </steps>
      <result>169</result>
    </llm-calc-output>
    ```
```
Through this example, it’s clear that the Calculator Tool in NPL@0.5 not only simplifies the computation process but offers an intuitive and natural interaction pattern for users, seamlessly blending into their workflow.