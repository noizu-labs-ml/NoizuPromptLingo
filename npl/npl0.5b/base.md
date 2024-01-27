⌜NPL@0.5⌝
# NPL@0.5
This Section defines the rule set for constructing prompts and virtual agents in NPL version 0.5.
It ensures precise control over and strict adherence to specified behaviors and output requirements for agents and prompts.

## DEFINITIONS
Definition of Terms

- Agent: A simulated person, service, or tool that interprets and acts on prompts.
- Intuition Pump: A heuristic device designed to aid in understanding or solving complex problems, often used by agents to enhance their output.

## SYNTAX
Syntax Overview
This section covers the foundational elements and structures that form the backbone of the NPL.

### BASIC SYNTAX
Basic Syntax Rules

Here, we detail the fundamental syntax used across all types of prompts and agents within the NPL framework.

#### Core Syntax 
```yaml
syntax-elements:
    - name: "highlight"
      description: "Highlight important terms or phrases for emphasis."
      syntax: "`<term>`"
      examples:
        - name: "Highlight a Key Concept"
          prompt: "In object-oriented programming, an `object` represents an instance of a class."
          purpose: "To make key terms stand out for clarification and emphasis."
          outcome: "The agent and human readers acknowledge the significance of `object` in the given context."
    - name: "alias"
      description: "Declare names agent can be referred to by."
      syntax: "🙋 <alias>"
      examples:
        - name: "Declare Alias for spreadsheet helper"
          prompt: "🙋 spreadsheet-helper sph"
          purpose: "To indicate that the agent can be referred to by alternative names."
          outcome: "The user can now use @sph to communicate with the agent."    
    - name: "attention"
      description: "Mark instructions that require the agent's special attention."
      syntax: "🎯 <important instruction>"
      examples:
        - name: "Highlight Critical Reminder"
          prompt: "🎯 Remember to validate all user inputs."
          purpose: "To stress the importance of input validation in prompt instructions."
          outcome: "The agent prioritizes input validation as a critical security practice."
    - name: "example_validation"
      description: "Provide clear examples of positive or negative validations."
      syntax: "✔ <positive example> or ❌ <negative example>"
      examples:
          - name: "Positive Behavior Demonstration"
            prompt: "✔ The function returns a valid response for all tested inputs."
            purpose: "To illustrate an ideal behavior in software functionality."
            outcome: "The agent recognizes this as an example of correct performance to aim for."
    - name: "value_placeholder"
      description: "Directive for the agent to inject specific content at the defined point in output or indicate expected input."
      syntax: "⟪input/output placeholder to be received or generated⟫ or {...} or <...>"
      examples:
          - name: "Inject User Name"
            prompt: "Hello {user.name | format: last name, m.i, first name}, welcome back!"
            purpose: "To personalize a greeting message by inserting the user's name."
            outcome: "The agent replaces {user.name} with the individual user's name in the output."
    - name: "ellipsis_inference"
      description: "etc. and ... may be used in prompt instructions to indicate similar/additional items should be generated or considered."
      syntax: "`, etc.` or  `...` "
      examples:
        - name: "Complete List Inference"
          prompt: "The grocery list should include dairy products like milk, yogut, ..."
          purpose: "To signal that the grocery list is not exhaustive and should include more dairy products."
          outcome: "The agent understands to consider other dairy products beyond the ones listed."
    - name: "qualification"
      description: "Extend syntax with additional details/conditions."
      syntax: "<<term>|<qualify> {<term>|<qualify>} [...|<qualify>]"
      examples:
        - name: "Option Presentation"
          prompt: "Select payment method: {payment methods|common for usa and india}"
          purpose: "To qualify a placeholder's contents."
          outcome: "The agent offers options considering regional differences."
    - name: "fill_in"
      description: "Signal areas in the prompt for dynamic content generation or to omit expected sections."
      syntax: |
       - Basic Fill In [...]
       - Detailed Fill In [...| details]
       - Alt. Detailed Fill In [... <details> ...]
      examples:
        - name: "Dynamic Content Generation"
          prompt: "The event will feature several keynote speakers including [...]."
          purpose: "To generate a list of speakers relevant to the event."
          outcome: "The agent adds a dynamic list of appropriate speakers."
    - name: "literal_output"
      description: "Ensure specified text is output exactly as provided."
      syntax: "Literal quote: `{~l|Keep it simple, stupid.}`"
      examples:
        - name: "Exact Quote Reproduction"
          prompt: "When quoting, use `{~l|To be, or not to be}` exactly."
          purpose: "To preserve the integrity of a famous quotation."
          outcome: "The agent outputs the quotation exactly, without alteration."
    - name: "separate_examples"
      description: "Create clear separations between examples or different sections."
      syntax: |
        Example 1: Description 
        ﹍ 
        Example 2: Description
      examples:
        - name: "Distinguish Learning Modules"
          prompt: |
            Module 1: Basics of programming
            ﹍
            Module 2: Advanced topics
          purpose: "To demarcate different learning modules."
          outcome: "Each module is treated as a separate section."
    - name: "direct_message"
      description: "Direct and route messages to specific agents for action or response."
      syntax: "@{agent} perform an action"
      examples:
        - name: "Direct Command to a Search Agent"
          prompt: "@{search_agent} find the nearest coffee shop."
          purpose: "To provide task-specific instructions to a designated agent."
          outcome: "The 'search_agent' processes and responds with the information."
    - name: "logic_operators"
      description: "Enable mathematical reasoning and conditional logic in content generation."
      syntax: "if (condition) { action } else { alternative action }, ∑(data_set), A ∪ B, A ∩ B"
      examples:
        - name: "Conditional Content Rendering"
          prompt: "if (user.role == 'administrator') { Show admin panel } else { Show user dashboard }"
          purpose: "To tailor UI content based on the user's role."
          outcome: "The UI adapts, showing relevant panels based on user roles."
        - name: "Summation Operation"
          prompt: "The total number of items sold today is: ∑(sold_items)"
          purpose: "To calculate the total number of items sold."
          outcome: "The agent sums the items and provides the total count."
        - name: "Set Intersection for Customer Segmentation"
          prompt: "Customers interested in both sports and nutrition: (sports_enthusiasts ∩ health_focused)"
          purpose: "To identify common customers between two interest groups."
          outcome: "The agent finds customers with both sports and health interests."
    - name: "special_code_section"
      description: "Denote and segregate specialized sections like examples, notes, or diagrams."
      syntax: |
        ```example 
        [...]
        ```
        ```note 
        [...]
        ```
        ```diagram
        [...]
        ```
      examples:
        - name: "Example Block"
          prompt: |
            ```example 
               Here's how you use `highlight` syntax.
            ```
          purpose: "To illustrate the use of a syntax element."
          outcome: "The `example` block provides a descriptive illustration."
        - name: "Notes for Clarification"
          prompt: |
            ```note
            The `attention` marker should be used sparingly.
            ```
          purpose: "To provide additional information within the prompt."
          outcome: "The note's context and significance are understood."
        - name: "Diagram for Visual Representation"
          prompt: 
            ```diagram
            [Component A] ---> [Component B]
            ```
          purpose: "To outline the connection between different components visually."
          outcome: "The agent interprets the diagram for system insights."
    - name: "npl_declaration"
      description: "To establish core rules and guidelines for NPL within a given version context."
      syntax: |
        "⌜NPL@version⌝
        [... NPL version-specific rules ...]
        
        ⌞NPL@version⌟"
      examples:
        - name: "Declare NPL Version 0.5"
          prompt: |
            "⌜NPL@0.5⌝
            NPL version 0.5 rules and guidelines.
            
            [... rules go here ...]
            
            ⌞NPL@0.5⌟"
          purpose: "To outline the prompt and agent behaviors associated with NPL version 0.5."
          outcome: "Prompts and agents operate within the constraints and capabilities set by NPL version 0.5."

    - name: "npl_extension"
      description: "To build upon and enhance existing NPL guidelines and rules for more specificity or breadth."
      syntax: |
        "⌜extend:NPL@version⌝
        [... enhancements or additional rules ...]
        
        ⌞extend:NPL@version⌟"
      examples:
        - name: "Extend NPL Version 0.5 with New Rule"
          prompt: |
            "⌜extend:NPL@0.5⌝
            Additional rule for handling edge cases in prompts.
            
            [... new rule description ...]
            
            ⌞extend:NPL@0.5⌟"
          purpose: "To incorporate a new rule into existing NPL version 0.5."
          outcome: "NPL version 0.5 now covers a wider range of prompting scenarios."

    - name: "agent_declaration"
      description: "To define a new agent and its expected behaviors, communications, and response patterns."
      syntax: |
        "⌜agent-name|type|NPL@version⌝
        # Agent Name
        - Description of the agent and its primary function.
        
        [...|additional behavioral specifics...]
        
        ⌞agent-name⌟"
      examples:
        - name: "Declare Sports News Agent"
          prompt: |
            "⌜sports-news-agent|service|NPL@0.5⌝
            # Sports News Agent
            Provides up-to-date sports news and facts when prompted.
            
            [... behavior details ...]
            
            ⌞sports-news-agent⌟"
          purpose: "To establish a sports news specialized agent under NPL@0.5."
          outcome: "Agent 'sports-news-agent' is created for sports information provision."

    - name: "agent_extension"
      description: "To refine or add to the definitions of an agent, enhancing or adapting its functionality."
      syntax: |
        "⌜extend:agent-name|type|NPL@<version>⌝
        [... enhancements or additional behaviors ...]        
        ⌞extend:agent-name⌟"
      examples:
        - name: "Extend Sports News Agent for Historical Facts"
          prompt: |
            ⌜extend:sports-news-agent|service|NPL@0.5⌝
            Enhances the agent's capability to provide historical sports facts in addition to recent news.
            
            [... additional behaviors ...]
            
            ⌞extend:sports-news-agent⌟
          purpose: "To build upon 'sports-news-agent' with historical data expertise."
          outcome: "The agent now serves historical sports trivia and current news."
    - name: "prompt_block"
      description: "To clearly define a new prompt, setting the scope and associated NPL runtime."
      syntax: |
        ⌜🔏 <with statement like: `@with NPL@version` | optional>
        # <PROMPT TYPE>
        [... instructions and rules for the prompt ...]
        ⌟
      examples:
        - name: "Declare a Fact-Finding Prompt Type"
          prompt: |
            ⌜🔏
            # SYSTEM PROMPT
            Output explicit factual information with links to known articles/resources.
            ⌟
          purpose: "To establish a specialized prompt type for retrieving facts with NPL@0.5."
          outcome: "The agent provides factual responses as per the Fact Finder prompt type."

    - name: "template"
      description: "Define a reusable output format/template."
      syntax: |
        ⌜🧱 <name>
        <declare any inputs| optional>
        ```template
        [...]
        ```
        ⌟
      examples:
        - name: "Declare a User Card Template"
          prompt: |
            ⌜🧱 user-card
            @with NPL@0.5
            ```template
            <b>{user.name}</b>
            <p>{user.bio}</p>
            ```
            ⌟
          purpose: "To define reusable output components."
          outcome: "The agent can use the 'user-card' template in various output contexts upon request."
    - name: "inherit_rule"
      description: "Leverage existing NPL rulesets within new agents or prompting scenarios."
      syntax: "@inherit NPL@version"
      examples:
        - name: "Inherit Existing NPL Rules"
          prompt: |
            @inherit NPL@0.5
            [... new agent behavior or prompt extension ...]
          purpose: "To adhere to existing NPL version rules in new definitions."
          outcome: "New declarations retain rules and characteristics of NPL version 0.5."

    - name: "apply_rule"
      description: "Indicate which NPL rules version to use in prompt processing."
      syntax: "@with NPL@version"
      examples:
        - name: "Apply NPL Rules to a Prompt"
          prompt: |
            @with NPL@0.5
            [... prompt specific instructions ...]
          purpose: "To guide prompt interpretation under NPL@0.5 rules."
          outcome: "Responses align with syntax and expectations of NPL@0.5."

    - name: "directive_syntax"
      description: "Use predefined command prefixes for specialized behavior or formatting."
      syntax: |
        {{directive-type}:{instructions}}
        ⟪{directive-type}:{instructions}⟫
      examples:
        - name: "Provide Explicit Instructions"
          prompt: "{➤:Clarify the difference between a list and a tuple in Python.}"
          purpose: "To direct the agent for a clear explanation of Python data structures."
          outcome: "Agent details the differences between lists and tuples in Python."

    - name: "prompt_prefix"
      description: "Use special indicators with `➤` as a prefix to specify response types."
      syntax: |
        - at top of section/prompt/message: {Indicator}➤
        - inline: @{Indicator}➤{agent}
      examples:
        - name: "Specific Instruction Prompt"
          prompt: "{Clarification}➤ Explain the process of photosynthesis."
          purpose: "To use a prefix for specifying a clarification response."
          outcome: "Agent provides a detailed explanation of photosynthesis."
```



### PROMPT PREFIX SYNTAX
Prompt Prefix Syntax
This part explains the specific prefixes used to direct the type of agent behaviors and responses expected in prompts.

```yaml
prompt_prefixes:
  - name: "conversation"
    description: "Indicate the response should be part of a conversational interaction."
    syntax: "👪➤ <dialogue or conversational instruction>"
    examples:
      - name: "Simulate a Customer Service Interaction"
        prompt: "👪➤ Simulate a conversation where a customer is inquiring about their order status."
        purpose: "To engage in a mock dialogue for a customer service scenario."
        outcome: "A conversation providing order status information."

  - name: "image_captioning"
    description: "Provide a caption for a provided image."
    syntax: "🖼️➤ <instruction for image captioning>"
    examples:
      - name: "Caption an Image of a Landscape"
        prompt: "🖼️➤ Write a caption for this image of a mountainous landscape at sunset."
        purpose: "Generate a caption capturing the essence of an image."
        outcome: "A caption like 'A serene sunset over the rugged peaks of the mountains.'"

  - name: "text_to_speech"
    description: "Synthesize spoken audio from text."
    syntax: "🔊➤ <text to be converted to speech>"
    examples:
      - name: "Convert Text to Audio"
        prompt: "🔊➤ Convert the following sentence into spoken audio: 'Welcome to our service. How can I assist you today?'"
        purpose: "Create an audio file vocalizing provided text."
        outcome: "Spoken audio reading aloud the sentence."

  - name: "speech_recognition"
    description: "Convert audio content of spoken words into written text."
    syntax: "🗣️➤ <instruction for speech recognition>"
    examples:
      - name: "Transcribe an Audio Clip"
        prompt: "🗣️➤ Transcribe the following audio clip of a conversation between two people."
        purpose: "Provide a textual transcription of spoken dialogue in an audio clip."
        outcome: "A written transcript of the conversation."

  - name: "question_answering"
    description: "Provide an answer to a posed question."
    syntax: "❓➤ <question to be answered>"
    examples:
      - name: "Answer a Trivia Question"
        prompt: "❓➤ What is the tallest mountain in the world?"
        purpose: "Provide the answer to a factual question."
        outcome: "'Mount Everest' as the tallest mountain."

  - name: "topic_modeling"
    description: "Uncover and list main topics in given text."
    syntax: "📊➤ <instruction for topic modeling>"
    examples:
      - name: "Model Topics from Research Papers"
        prompt: "📊➤ Determine the prevalent topics across a collection of research papers in AI."
        purpose: "Identify common subjects in a set of documents."
        outcome: "Lists of central topics within the AI field."

  - name: "machine_translation"
    description: "Translate text into a specified target language."
    syntax: "🌐➤ <instruction for machine translation>"
    examples:
      - name: "Translate English to Spanish"
        prompt: "🌐➤ Translate the following sentences from English to Spanish."
        purpose: "Convert English text into Spanish."
        outcome: "Spanish translation of the English sentences."

  - name: "named_entity_recognition"
    description: "Identify and classify named entities in text."
    syntax: "👁️➤ <instruction for named entity recognition>"
    examples:
      - name: "Identify Entities in a News Article"
        prompt: "👁️➤ Locate and categorize named entities in an article excerpt."
        purpose: "Extract and classify entities from text."
        outcome: "List of named entities and their categories in the article."

  - name: "text_generation"
    description: "Create original text or expand on given ideas."
    syntax: "🖋️➤ <instruction for text generation>"
    examples:
      - name: "Generate a Story Introduction"
        prompt: "🖋️➤ Write an opening paragraph for a story set in a futuristic city."
        purpose: "Generate a creative introduction to a story."
        outcome: "Opening paragraph for a futuristic city story."

  - name: "text_classification"
    description: "Classify text into predefined categories."
    syntax: "🏷️➤ <instruction for text classification>"
    examples:
      - name: "Classify Support Tickets"
        prompt: "🏷️➤ Categorize the following support ticket into the correct department."
        purpose: "Determine the appropriate department for a support ticket."
        outcome: "Support ticket assigned to a department category."

  - name: "sentiment_analysis"
    description: "Determine the emotional tone of text."
    syntax: "💡➤ <instruction for sentiment analysis>"
    examples:
      - name: "Analyze Customer Review Sentiment"
        prompt: "💡➤ Assess the sentiment of a customer product review."
        purpose: "Evaluate if a review is positive, negative, or neutral."
        outcome: "Sentiment assessment of the review."

  - name: "summarization"
    description: "Condense information into a summary."
    syntax: "📄➤ <instruction for summarization>"
    examples:
      - name: "Summarize a News Article"
        prompt: "📄➤ Provide a summary of the main points from a news article."
        purpose: "Distill key information into a compact summary."
        outcome: "Summary highlighting primary article points."

  - name: "feature_extraction"
    description: "Identify and extract particular features from input."
    syntax: "🧪➤ <instruction for feature extraction>"
    examples:
      - name: "Extract Keywords from Text"
        prompt: "🧪➤ Identify the main keywords from an article excerpt."
        purpose: "Extract terms capturing the article's essence."
        outcome: "Keywords identified within the article."

      - name: "Determine Significant Data Points"
        prompt: "🧪➤ Extract the highest and lowest temperatures from this week's weather data."
        purpose: "Find specific data points in temperature readings."
        outcome: "Highest and lowest recorded temperatures during the week."

  - name: "code_generation"
    description: "Generate code snippets or complete programs."
    syntax: "🖥️➤ <instruction for code generation>"
    examples:
      - name: "Generate a Python Function"
        prompt: "🖥️➤ Define a Python function `add` that takes two parameters and returns their sum."
        purpose: "Generate a Python function for adding two numbers."
        outcome: "Python code snippet defining the `add` function."

      - name: "Create an HTML Structure"
        prompt: "🖥️➤ Create an HTML template with a header, main section, and footer."
        purpose: "Generate the HTML markup for a basic page structure."
        outcome: "HTML code structure with specified sections."
```

### DIRECTIVE SYNTAX
Directive Syntax

This section delineates the syntax for directives, which provide special instructions to agents within prompts for desired outputs and behaviors.

```yaml
directive_syntax:
  - name: "structured_table_formatting"
    description: "Format data into a structured table as per instructions, enhancing readability."
    syntax: "{📅: (column alignments and labels) | content description}"
    examples:
      - name: "Table of First 13 Prime Numbers"
        prompt: "{📅: (#:left, prime:right, english:center label Heyo) | first 13 prime numbers}"
        purpose: "List the first 13 prime numbers with specified column alignments and a header label."
        outcome: |
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
  - name: "temporal_task_alignment"
    description: "Command the agent to consider timing and duration for task execution."
    syntax: "⟪⏳: Time Condition or Instruction⟫"
    examples:
      - name: "Scheduled Report Generation"
        prompt: "⟪⏳: At the end of each month⟫ Generate a summary report of user activity."
        purpose: "Initiate a report generation event at a set time frame."
        outcome: "Automatic compilation of a summary report at the month's end."

      - name: "Action Timer"
        prompt: "⟪⏳: Within 5 minutes of receiving data⟫ Analyze and present the findings."
        purpose: "Set a time limit for completing a data analysis task."
        outcome: "Data analysis completed within a five-minute timeframe."

  - name: "template_integration"
    description: "Integrate templated sections into outputs seamlessly."
    syntax: "⟪⇐: user-template⟫ applying to individual data entries."
    examples:
      - name: "Embedding User Template into Business Profile"
        prompt: |
          "```template=user-template
           # {user.name}
           dob: {user.dob}
           bio: {user.bio}
           ```
           ### Output Syntax
           ```syntax
           Business Name: <business.name>
           About the Business: <business.about>

           ## Executives
           {foreach business.executives as executive}
           - Name: <executive.name>
           - Role: <executive.role>
           - Bio: <executive.bio>
           ⟪⇐: user-template | with the data of each executive.⟫
           {/foreach}

           ## Board Advisors
           {foreach business.board_advisors as advisor}
           - Name: <advisor.name>
           - Role: <advisor.role>
           - Bio: <advisor.bio>
           ⟪⇐: user-template | with the data of each board advisor.⟫
           {/foreach}
           ```"
        purpose: "Use a standard template to format information on executives and advisors uniformly."
        outcome: "A business profile with consistently formatted information for executives and board advisors."

  - name: "interactive_element_choreography"
    description: "Choreograph interactive elements and agent reactivity based on user interactions."
    syntax: "⟪🚀: Action or Behavior Definition⟫"
    examples:
      - name: "User-driven Question Flow"
        prompt: "⟪🚀: User selects an option⟫ Provide corresponding information based on the user's selection."
        purpose: "Adapt responses based on user choices in a Q&A interface."
        outcome: "The agent dynamically provides information relevant to the user’s selection."

      - name: "Time-delayed Notification"
        prompt: "⟪🚀: 30 seconds after signup⟫ Send a welcome message with introductory resources."
        purpose: "Delay the delivery of a welcome message to new users."
        outcome: "A welcome message sent 30 seconds post-signup."

  - name: "unique_identifier_management"
    description: "Integrate and sustain unique identifiers for various entities."
    syntax: "⟪🆔: Entity or Context Requiring ID⟫"
    examples:
      - name: "Session ID Generation"
        prompt: "⟪🆔: User Session⟫ Generate a session identifier for the new login event."
        purpose: "Generate a unique session ID for each user login."
        outcome: "Unique session ID created for session tracking."

      - name: "Data Record Identification"
        prompt: "⟪🆔: Product Listing⟫ Assign an ID to each new product entry in the database."
        purpose: "Provide unique identifiers for each product in the inventory."
        outcome: "All new product entries assigned with a unique ID."
  - name: "detailed_explanatory_notes"
    description: "Append instructive comments to elucidate the expectations behind prompts."
    syntax: "⟪📖: Detailed Explanation⟫"
    examples:
        - name: "Behavior Guideline for Data Handling"
          prompt: "⟪📖: Ensure user consent before data collection⟫ Prioritize user privacy when soliciting personal information."
          purpose: "Emphasize ethical data practices regarding user consent."
          outcome: "Agent prioritizes user consent in its data collection process."

        - name: "Note on Cultural Sensitivity"
          prompt: "⟪📖: Account for cultural context in marketing messages⟫ Craft communication with cultural awareness."
          purpose: "Mitigate cross-cultural misunderstandings in agent interactions."
          outcome: "Agent communication is adapted to respect cultural nuances."

  - name: "section_marking_for_reference"
    description: "Mark sections with unique identifiers for easy reference and updates."
    syntax: "⟪📂:{identifier}⟫"
    examples:
      - name: "User Guidelines Reference"
        prompt: "⟪📂:{user_guidelines}⟫ Refer to the guidelines for acceptable user behavior."
        purpose: "Offer a reference point for rules governing user conduct."
        outcome: "Clear referencing of the guidelines section for future consultation."

      - name: "Technical Documentation Reference"
        prompt: "⟪📂:{installation_procedure_v2}⟫ Follow the latest installation steps outlined."
        purpose: "Tag the current software installation instructions for easy access."
        outcome: "Direct reference to the latest installation steps for user convenience."

  - name: "explicit_instructions"
    description: "Provide direct and precise instructions to the agent for clarity."
    syntax: "{➤: <instruction> | <elaboration>}"
    examples:
      - name: "Explicit Instruction with Elaboration"
        prompt: "{➤: Identify the current user | Ensure secure session}"
        purpose: "Instruct the agent to verify user identity and secure the session."
        outcome: "Agent identifies the user and secures the ongoing session."

      - name: "Data Retrieval with Specificity"
        prompt: "{➤: Retrieve climate data | Include recent temperature anomalies}"
        purpose: "Command the agent to fetch specific climate data components."
        outcome: "Agent fetches climate data, focusing on recent temperature anomalies."
```
⌞NPL@0.5⌟
