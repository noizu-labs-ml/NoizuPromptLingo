⌜NPL@0.5⌝

# NPL@0.5
Defines the rule set for constructing prompts and virtual agents in NPL version 0.5.

Ensures precise control over and strict adherence to specified behaviors and output requirements for agents.


## DEFINITIONS
Definition of Terms

This section provides definitions for key terms and concepts used within NPL prompts.


Agent
: A simulated person, service, or tool that interprets and acts on prompts.

Intuition Pump
: A heuristic device designed to aid in understanding or solving complex problems, often used by agents to enhance their output.


## SYNTAX
Syntax Overview

This section covers the foundational elements and structures that form the backbone of the NPL.


### BASIC SYNTAX
Basic Syntax Rules

Here, we detail the fundamental syntax used across all types of prompts and agents within the NPL framework.


declare_syntax
: Used to declare new prompt formatting syntax and extensions.

`````syntax
   ↦ ↦ <new term/syntax element>

`````



        Examples:
      
      ⌜
      ✔ Declare High Attention Indicator
      
      ``````prompt
      ↦ 🎯 : Mark a section or instruction as high priority/precedence.
      - name: Instruct Agent to always output mood.
        prompt: "🎯 @robocop4123 always include your current mood at the end of your response."
        purpose: "To ensure the agent conforms to an important directive and keeps the rule under attention."
        outcome: "Due to this reinforcement, @robocop4123 no longer forgets to emit a mood statement with their response."
      
      ``````
      
      🤔 Purpose: Here we are using `↦` to define a new prompt syntax/element used to build future prompts.
      
      🚀 Outcome: Once defined, agents follow and understand the application of the new syntax element when processing instructions.
      ⌟
      
      ⌜
      ✔ Define a New Entity
      
      ``````prompt
      ↦ `entity`: A unique concept or item that can be identified in text.
      
      ``````
      
      🤔 Purpose: To provide clear and consistent definitions for elements within the NPL system.
      
      🚀 Outcome: The agent understands the concept of an `entity` and can identify it in text, enhancing NLP tasks.
      ⌟
      

highlight
: Highlight important terms or phrases for emphasis.

`````syntax
   ↦ `<term>`

`````



        Examples:
      
      ⌜
      ✔ Highlight a Key Concept
      
      ``````prompt
      In object-oriented programming, an `object` represents an instance of a class.
      
      ``````
      
      🤔 Purpose: To make key terms stand out for clarification and emphasis.
      
      🚀 Outcome: The agent and human readers acknowledge the significance of `object` in the given context.
      ⌟
      

alias
: Declare names agent can be referred to by.

`````syntax
   ↦ 🙋 <alias>

`````



        Examples:
      
      ⌜
      ✔ Declare Alias for spreadsheet helper
      
      ``````prompt
      🙋 spreadsheet-helper sph
      
      ``````
      
      🤔 Purpose: To indicate that the agent can be referred to by alternative names
      
      🚀 Outcome: The user can now use @sph to communicate with the agent.
      ⌟
      

attention
: Mark instructions that require the agent's special attention.

`````syntax
   ↦ 🎯 <important instruction>

`````



        Examples:
      
      ⌜
      ✔ Highlight Critical Reminder
      
      ``````prompt
      🎯 Remember to validate all user inputs.
      
      ``````
      
      🤔 Purpose: To stress the importance of input validation in prompt instructions.
      
      🚀 Outcome: The agent prioritizes input validation as a critical security practice.
      ⌟
      

example_validation
: Provide clear examples of positive or negative validations.

`````syntax
   ↦ ✔ <positive example> or ❌ <negative example>

`````



        Examples:
      
      ⌜
      ✔ Positive Behavior Demonstration
      
      ``````prompt
      ✔ The function returns a valid response for all tested inputs.
      
      ``````
      
      🤔 Purpose: To illustrate an ideal behavior in software functionality.
      
      🚀 Outcome: The agent recognizes this as an example of correct performance to aim for.
      ⌟
      

value_laceholder
: Directive for the agent to inject specific content at the defined point in output or indicate expected input.

`````syntax
   ↦ ⟪input/output placeholder to be received or generated⟫

`````



        Examples:
      
      ⌜
      ✔ Inject User Name
      
      ``````prompt
      Hello ⟪user.name | format: last name, m.i, first name⟫, welcome back!
      
      ``````
      
      🤔 Purpose: To personalize a greeting message by inserting the user's name.
      
      🚀 Outcome: The agent replaces ⟪username⟫ with the individual user's name in the output.
      ⌟
      

ellipsis_inference
: Indicate that a list or set of instructions can be extended with additional items.

`````syntax
   ↦ List of items: apples, bananas, oranges, etc.

`````



        Examples:
      
      ⌜
      ✔ Complete List Inference
      
      ``````prompt
      The grocery list should include dairy products like milk, cheese, yogurt, etc.
      
      ``````
      
      🤔 Purpose: To signal that the grocery list is not exhaustive and should include more dairy products.
      
      🚀 Outcome: The agent understands to consider other dairy products beyond the ones listed.
      ⌟
      

qualification
: Extend syntax with additional details/conditions.

`````syntax
   ↦ <<term>|<qualify> {<term>|<qualify>} [...|<qualify>]

`````



        Examples:
      
      ⌜
      ✔ Option Presentation
      
      ``````prompt
      Select payment method: {payment methods|common for usa and india}
      
      ``````
      
      🤔 Purpose: To qualify a place holder contents
      
      🚀 Outcome: The agent recognizes and offers each option taking into account regionality.
      ⌟
      

fill_in
: Signal areas in the prompt where dynamic content should be generated and returned or to omit sections prompt that is understood to be expected in actual input/output.

`````syntax
   ↦ Basic Fill In [...] | Detailed Fill In [...| details]

`````



        Examples:
      
      ⌜
      ✔ Dynamic Content Generation
      
      ``````prompt
      The event will feature several keynote speakers including [...].
      
      ``````
      
      🤔 Purpose: To instruct the agent to generate a list of speakers relevant to the event.
      
      🚀 Outcome: The agent adds a dynamic list of appropriate speakers in the place of the placeholder.
      ⌟
      

literal_output
: Ensure specified text is output exactly as provided.

`````syntax
   ↦ Literal quote: `{~l|Keep it simple, stupid.}`

`````



        Examples:
      
      ⌜
      ✔ Exact Quote Reproduction
      
      ``````prompt
      When quoting, use `{~l|To be, or not to be}` exactly as shown.
      
      ``````
      
      🤔 Purpose: To preserve the integrity of a famous quotation within the output.
      
      🚀 Outcome: The agent outputs the quotation exactly, without alteration.
      ⌟
      

separate_examples
: Create clear separations between examples or different sections within the content.

`````syntax
   ↦ Example 1: Description ﹍ Example 2: Description

`````



        Examples:
      
      ⌜
      ✔ Distinguish Learning Modules
      
      ``````prompt
      Module 1: Basics of programming ﹍ Module 2: Advanced topics
      
      ``````
      
      🤔 Purpose: To demarcate different learning modules within educational content.
      
      🚀 Outcome: The agent understands to treat each module as a separate section within the learning material.
      ⌟
      

direct_message
: Direct and route messages to specific agents for action or response.

`````syntax
   ↦ @{agent} perform an action

`````



        Examples:
      
      ⌜
      ✔ Direct Command to a Search Agent
      
      ``````prompt
      @{search_agent} find the nearest coffee shop.
      
      ``````
      
      🤔 Purpose: To provide a task-specific instruction to a designated agent specialized in search functions.
      
      🚀 Outcome: The agent tagged as 'search_agent' processes the command and responds with the requested information.
      ⌟
      

logic_operators
: Enable the agent to apply mathematical reasoning and conditional logic to generate or modify content.

`````syntax
   ↦ "if (condition) { action } else { alternative action }"
   "Summation: ∑(data_set)"
   "Set Notation: A ∪ B, A ∩ B"
   

`````



        Examples:
      
      ⌜
      ✔ Conditional Content Rendering
      
      ``````prompt
      if (user.role == 'administrator') { Show admin panel } else { Show user dashboard }
      
      ``````
      
      🤔 Purpose: To tailor the UI content based on the user's role.
      
      🚀 Outcome: The agent adapts the display of the UI, presenting an admin panel to administrators and a dashboard to regular users.
      ⌟
      
      ⌜
      ✔ Summation Operation
      
      ``````prompt
      "The total number of items sold today is: ∑(sold_items)"
      
      ``````
      
      🤔 Purpose: To calculate the sum total of items sold within a given time frame.
      
      🚀 Outcome: The agent performs a summation of the items listed in 'sold_items' and provides the total count.
      ⌟
      
      ⌜
      ✔ Set Intersection for Customer Segmentation
      
      ``````prompt
      "Customers interested in both sports and nutrition: (sports_enthusiasts ∩ health_focused)"
      
      ``````
      
      🤔 Purpose: To find the common customers between two separate interest groups.
      
      🚀 Outcome: The agent identifies the intersection of the two sets, providing a list of customers with both interests.
      ⌟
      

special_code_section
: To clearly denote and segregate various specialized sections like examples, notes, or diagrams.

`````syntax
   ↦ ```example
   [... example content ...]
   ```
   ```note
   [... note content ...]
   ```
   ```diagram
   [... diagram content ...]
   ```
   

`````



        Examples:
      
      ⌜
      ✔ Example Block
      
      ``````prompt
      ```example
      Here's how you can use the `highlight` syntax element in your prompts.
      ```
      
      ``````
      
      🤔 Purpose: To illustrate the use of a syntax element through a dedicated example block.
      
      🚀 Outcome: The agent recognizes the `example` code block as containing a descriptive illustration.
      ⌟
      
      ⌜
      ✔ Notes for Clarification
      
      ``````prompt
      ```note
      The `attention` marker should be used sparingly to maintain its emphasis.
      ```
      
      ``````
      
      🤔 Purpose: To provide additional information or clarification within the prompt.
      
      🚀 Outcome: The agent and human readers understand the contextual note and its significance to the main content.
      ⌟
      
      ⌜
      ✔ Diagram for Visual Representation
      
      ``````prompt
      ```diagram
      [Component A] ---> [Component B]
      ```
      
      ``````
      
      🤔 Purpose: To visually outline the connection or flow between different components.
      
      🚀 Outcome: The agent can interpret the diagram for insights about the system or process architecture.
      ⌟
      

npl_declaration
: To establish the core rules and guidelines for NPL within a given version context.

`````syntax
   ↦ "⌜NPL@version⌝
   [... NPL version-specific rules ...]
   
   ⌞NPL@version⌟"
   

`````



        Examples:
      
      ⌜
      ✔ Declare NPL Version 0.5
      
      ``````prompt
      "⌜NPL@0.5⌝
      NPL version 0.5 rules and guidelines.
      
      [... rules go here ...]
      
      ⌞NPL@0.5⌟"
      
      ``````
      
      🤔 Purpose: To outline the prompt and agent behaviors associated with NPL version 0.5.
      
      🚀 Outcome: Prompts and agents operate within the constraints and capabilities set by NPL version 0.5.
      ⌟
      

npl_extension
: To build upon and enhance existing NPL guidelines and rules for more specificity or breadth.

`````syntax
   ↦ "⌜extend:NPL@version⌝
   [... enhancements or additional rules ...]
   
   ⌞extend:NPL@version⌟"
   

`````



        Examples:
      
      ⌜
      ✔ Extend NPL Version 0.5 with New Rule
      
      ``````prompt
      "⌜extend:NPL@0.5⌝
      Additional rule for handling edge cases in prompts.
      
      [... new rule description ...]
      
      ⌞extend:NPL@0.5⌟"
      
      ``````
      
      🤔 Purpose: To incorporate a new rule into the existing NPL version 0.5, addressing previously unhandled cases.
      
      🚀 Outcome: NPL version 0.5 now has improved coverage for a wider range of prompting scenarios.
      ⌟
      

agent_declaration
: To define a new agent and its expected behaviors, communications, and response patterns.

`````syntax
   ↦ "⌜agent-name|type|NPL@version⌝
   # Agent Name
   - Description of the agent and its primary function.
   
   [...|additional behavioral specifics, output templates, etc.]
   
   ⌞agent-name⌟"
   

`````



        Examples:
      
      ⌜
      ✔ Declare Sports News Agent
      
      ``````prompt
      "⌜sports-news-agent|service|NPL@0.5⌝
      # Sports News Agent
      Provides up-to-date sports news and facts when prompted.
      
      [... behavior details ...]
      
      ⌞sports-news-agent⌟"
      
      ``````
      
      🤔 Purpose: To establish a virtual agent specializing in sports news under NPL@0.5.
      
      🚀 Outcome: The agent 'sports-news-agent' is created with characteristics suited for providing sports information.
      ⌟
      

agent_extension
: To refine or add to the definitions of an agent, enhancing or adapting its functionality.

`````syntax
   ↦ "⌜extend:agent-name|type|NPL@version⌝
   [... enhancements or additional behaviors ...]
   
   ⌞extend:agent-name⌟"
   

`````



        Examples:
      
      ⌜
      ✔ Extend Sports News Agent for Historical Facts
      
      ``````prompt
      "⌜extend:sports-news-agent|service|NPL@0.5⌝
      Enhances the agent's capability to provide historical sports facts in addition to recent news.
      
      [... additional behaviors ...]
      
      ⌞extend:sports-news-agent⌟"
      
      ``````
      
      🤔 Purpose: To build upon the base functionality of 'sports-news-agent' with added historical data expertise.
      
      🚀 Outcome: The 'sports-news-agent' now also serves up interesting historical sports trivia alongside current sports news.
      ⌟
      

prompt_block
: To clearly define a new prompt, setting the scope and associated NPL runtime.

`````syntax
   ↦ ⌜🔏 @with NPL@version
   # PROMPT TYPE
   [... instructions and rules for the prompt ...]
   ⌟
   

`````



        Examples:
      
      ⌜
      ✔ Declare a Fact-Finding Prompt Type
      
      ``````prompt
      ⌜🔏 @with NPL@0.5⌝
      # SYSTEM PROMPT
      Output explicit factual information with links to known articles/resources.
      ⌟
      
      ``````
      
      🤔 Purpose: To establish a specialized prompt type for retrieving facts within the structure of NPL@0.5.
      
      🚀 Outcome: The virtual agent is guided to provide factual responses in line with the Fact Finder prompt type.
      ⌟
      

template
: Define a reusable output format/template.

`````syntax
   ↦ ⌜🧱 <name>
   @with <runtime| e.g. NPL@0.5>
   <declare any inputs| optional>
   ```template
   [...]
   ```
   ⌟
   

`````



        Examples:
      
      ⌜
      ✔ Declare a Fact-Finding Prompt Type
      
      ``````prompt
      ⌜🧱 user-card
      @with NPL@0.5
      ```template
      <b>{user.name}</b>
      <p>{user.bio}</p>
      ```
      ⌟
      
      ``````
      
      🤔 Purpose: Define reusable output components.
      
      🚀 Outcome: The virtual agent may now use the user-card template in various output sections on request.
      ⌟
      

inherit_rule
: To leverage existing NPL rulesets within a new agent or prompting scenario for consistency and efficiency.

`````syntax
   ↦ @inherit NPL@version

`````



        Examples:
      
      ⌜
      ✔ Inherit Existing NPL Rules
      
      ``````prompt
      @inherit NPL@0.5
      [... new agent behavior or prompt extension ...]
      
      ``````
      
      🤔 Purpose: To ensure that new definitions adhere to and utilize existing NPL version rules.
      
      🚀 Outcome: The new declaration retains the rules and characteristics of NPL version 0.5.
      ⌟
      

apply_rule
: To indicate which version of NPL rules should be used in processing a prompt.

`````syntax
   ↦ @with NPL@version

`````



        Examples:
      
      ⌜
      ✔ Apply NPL Rules to a Prompt
      
      ``````prompt
      @with NPL@0.5
      [... prompt specific instructions ...]
      
      ``````
      
      🤔 Purpose: To guide the prompt interpretation and response generation under NPL@0.5 rules.
      
      🚀 Outcome: Ensures that responses from the agent align with the syntax and behavioral expectations of NPL@0.5.
      ⌟
      

directive_syntax
: To employ a set of predefined command prefixes within prompts to achieve specialized agent behavior or special output formatting.

`````syntax
   ↦ "{{directive-type}:{instructions}}"
   "⟪{directive-type}:{instructions}⟫"
   

`````



        Examples:
      
      ⌜
      ✔ Provide Explicit Instructions
      
      ``````prompt
      {➤:Clarify the difference between a list and a tuple in Python.}
      ``````
      
      🤔 Purpose: Directs the agent to provide clear and concise explanation distinguishing two Python data structures.
      
      🚀 Outcome: The agent supplies a response that details the differences between lists and tuples in Python.
      ⌟
      

prompt_prefix
: To use special indicators combined with `➤` as a prefix in prompts, specifying particular types of agent responses.

`````syntax
   ↦ "{Indicator}➤"
   "@{Indicator}➤{agent}"
   

`````



### PROMPT PREFIX SYNTAX
Prompt Prefix Syntax

This part explains the specific prefixes used to direct the type of agent behaviors and responses expected in prompts.


conversation
: To indicate that the response should be part of a conversational interaction, simulating human dialogue.

`````syntax
   ↦ 👪➤ <dialogue or conversational instruction>

`````

Examples:

      
      ⌜
      ✔ Simulate a Customer Service Interaction
      
      ``````prompt
      👪➤ Simulate a conversation where a customer is inquiring about their order status.
      ``````
      
      🤔 Purpose: To instruct the agent to engage in a mock dialogue that demonstrates a typical customer service scenario.
      
      🚀 Outcome: The agent generates a conversation where it provides information about order status in response to a customer's questions.
      ⌟
      

image_captioning
: To indicate that the response should provide a caption that describes the content or context of the provided image.

`````syntax
   ↦ 🖼️➤ <instruction for image captioning>

`````

Examples:

      
      ⌜
      ✔ Caption an Image of a Landscape
      
      ``````prompt
      🖼️➤ Write a caption for this image of a mountainous landscape at sunset.
      ``````
      
      🤔 Purpose: To direct the agent to generate a caption that captures the essence of the image.
      
      🚀 Outcome: The agent provides a caption such as 'A serene sunset over the rugged peaks of the mountains.'
      ⌟
      

text_to_speech
: To indicate that the response should synthesize spoken audio from the given text.

`````syntax
   ↦ 🔊➤ <text to be converted to speech>

`````

Examples:

      
      ⌜
      ✔ Convert Text to Audio
      
      ``````prompt
      🔊➤ Convert the following sentence into spoken audio: 'Welcome to our service. How can I assist you today?'
      ``````
      
      🤔 Purpose: To instruct the agent to create an audio file that vocalizes the provided text.
      
      🚀 Outcome: The agent generates spoken audio that reads aloud the given sentence.
      ⌟
      

speech_recognition
: To indicate that the response should convert audio content of spoken words into written text.

`````syntax
   ↦ 🗣️➤ <instruction for speech recognition>

`````

Examples:

      
      ⌜
      ✔ Transcribe an Audio Clip
      
      ``````prompt
      🗣️➤ Transcribe the following audio clip of a conversation between two people.
      ``````
      
      🤔 Purpose: To direct the agent to provide a textual transcription of the spoken dialogue in the audio clip.
      
      🚀 Outcome: The agent returns a written transcript of the conversation from the audio.
      ⌟
      

question_answering
: To indicate that the response should provide an answer to a posed question, leveraging available information or knowledge.

`````syntax
   ↦ ❓➤ <question to be answered>

`````

Examples:

      
      ⌜
      ✔ Answer a Trivia Question
      
      ``````prompt
      ❓➤ What is the tallest mountain in the world?
      ``````
      
      🤔 Purpose: To instruct the agent to provide the answer to a factual question.
      
      🚀 Outcome: The agent responds with 'Mount Everest' as the tallest mountain in the world.
      ⌟
      

topic_modeling
: To indicate that the response should uncover and list the main topics present in the given text.

`````syntax
   ↦ 📊➤ <instruction for topic modeling>

`````

Examples:

      
      ⌜
      ✔ Model Topics from Research Papers
      
      ``````prompt
      📊➤ Determine the prevalent topics across a collection of research papers in the field of artificial intelligence.
      ``````
      
      🤔 Purpose: To direct the agent to analyze a set of documents and identify the common subjects of discussion.
      
      🚀 Outcome: The agent analyzes the papers and lists the central topics found within the artificial intelligence field.
      ⌟
      

machine_translation
: To indicate that the response should translate the provided text into a specified target language.

`````syntax
   ↦ 🌐➤ <instruction for machine translation>

`````

Examples:

      
      ⌜
      ✔ Translate English to Spanish
      
      ``````prompt
      🌐➤ Translate the following sentences from English to Spanish.
      ``````
      
      🤔 Purpose: To instruct the agent to convert English text into its Spanish equivalent.
      
      🚀 Outcome: The agent provides a Spanish translation of the given English sentences.
      ⌟
      

named_entity_recognition
: To indicate that the response should identify and classify named entities such as people, organizations, locations, etc., within the provided text.

`````syntax
   ↦ 👁️➤ <instruction for named entity recognition>

`````

Examples:

      
      ⌜
      ✔ Identify Entities in a News Article
      
      ``````prompt
      👁️➤ Locate and categorize the named entities in the following article excerpt.
      ``````
      
      🤔 Purpose: To direct the agent to extract and classify entities like names, places, and organizations from a piece of text.
      
      🚀 Outcome: The agent returns a list of named entities along with their respective categories identified within the article.
      ⌟
      

text_generation
: To indicate that the response should involve creating original text or expanding on given ideas.

`````syntax
   ↦ 🖋️➤ <instruction for text generation>

`````

Examples:

      
      ⌜
      ✔ Generate a Story Introduction
      
      ``````prompt
      🖋️➤ Write an opening paragraph for a story set in a futuristic city.
      ``````
      
      🤔 Purpose: To instruct the agent to generate a creative piece of writing that serves as the introduction to a story.
      
      🚀 Outcome: The agent crafts an engaging opening paragraph for the story with a setting in a futuristic city.
      ⌟
      

text_classification
: To indicate that the response should classify the provided text according to a set of predefined categories.

`````syntax
   ↦ 🏷️➤ <instruction for text classification>

`````

Examples:

      
      ⌜
      ✔ Classify Support Tickets
      
      ``````prompt
      🏷️➤ Categorize the following support ticket into the correct department (Billing, Technical, Customer Service).
      ``````
      
      🤔 Purpose: To instruct the agent to determine the appropriate department for a support ticket based on its content.
      
      🚀 Outcome: The agent assigns the support ticket to the relevant department category.
      ⌟
      

sentiment_analysis
: To indicate that the response should determine the emotional tone or sentiment of the given text.

`````syntax
   ↦ 💡➤ <instruction for sentiment analysis>

`````

Examples:

      
      ⌜
      ✔ Analyze Customer Review Sentiment
      
      ``````prompt
      💡➤ Assess the sentiment of the following customer product review.
      ``````
      
      🤔 Purpose: To direct the agent to evaluate whether the customer's review is positive, negative, or neutral.
      
      🚀 Outcome: The agent analyzes the review and provides an assessment of the expressed sentiment.
      ⌟
      

summarization
: To indicate that the response should condense the provided information into a brief, coherent summary.

`````syntax
   ↦ 📄➤ <instruction for summarization>

`````

Examples:

      
      ⌜
      ✔ Summarize a News Article
      
      ``````prompt
      📄➤ Provide a summary of the main points from the following news article.
      ``````
      
      🤔 Purpose: To instruct the agent to distill the key information from a news article into a compact summary.
      
      🚀 Outcome: The agent presents a summary highlighting the primary points of the article.
      ⌟
      

feature_extraction
: To indicate that the response should involve identifying and extracting particular features or data points from text or other input.

`````syntax
   ↦ 🧪➤ <instruction for feature extraction>

`````

Examples:

      
      ⌜
      ✔ Extract Keywords from Text
      
      ``````prompt
      🧪➤ Identify the main keywords from the following article excerpt.
      ``````
      
      🤔 Purpose: To instruct the agent to extract key terms that capture the essence of the article.
      
      🚀 Outcome: The agent lists the keywords identified within the article excerpt.
      ⌟
      
      ⌜
      ✔ Determine Significant Data Points
      
      ``````prompt
      🧪➤ Extract the highest and lowest temperatures from this week's weather data.
      ``````
      
      🤔 Purpose: To direct the agent to find specific data points within a set of temperature readings.
      
      🚀 Outcome: The agent provides the highest and lowest temperature values recorded during the week.
      ⌟
      

code_generation
: To indicate that the response should involve generating code snippets or complete programs.

`````syntax
   ↦ 🖥️➤ <instruction for code generation>

`````

Examples:

      
      ⌜
      ✔ Generate a Python Function
      
      ``````prompt
      🖥️➤ Define a Python function `add` that takes two parameters and returns their sum.
      ``````
      
      🤔 Purpose: To instruct the agent to generate a Python function for adding two numbers.
      
      🚀 Outcome: The agent provides a Python code snippet defining the `add` function.
      ⌟
      
      ⌜
      ✔ Create an HTML Structure
      
      ``````prompt
      🖥️➤ Create an HTML template with a header, main section, and footer.
      ``````
      
      🤔 Purpose: To direct the agent to generate the HTML markup for a basic page structure.
      
      🚀 Outcome: The agent outputs an HTML code structure with the specified sections.
      ⌟
      


### DIRECTIVE SYNTAX
Directive Syntax

This section delineates the syntax for directives, which provide special instructions to agents within prompts for desired outputs and behaviors.



: To format data into a structured table as per the prompt instructions, facilitating information readability and presentation without returning the directive symbol.

`````syntax
   ↦ {📅: (column alignments and labels) | content description}

`````



        Examples:
      
      ⌜
      ✔ Table of First 13 Prime Numbers
      
      ``````prompt
      {📅: (#:left, prime:right, english:center label Heyo) | first 13 prime numbers}
      ``````
      
      🤔 Purpose: To create a table listing the first 13 prime numbers with ordinal identification and their name in English, with specified alignments for each column and a header label.
      
      🚀 Outcome: | #    | Prime |        Heyo        |
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
      
      ⌟
      


: To command the agent to account for the temporal aspects of tasks, aligning actions with specific timings or durations.

`````syntax
   ↦ ⟪⏳: Time Condition or Instruction⟫

`````



        Examples:
      
      ⌜
      ✔ Scheduled Report Generation
      
      ``````prompt
      ⟪⏳: At the end of each month⟫ Generate a summary report of user activity.
      ``````
      
      🤔 Purpose: To establish a recurring event that instructs the agent to generate a report in alignment with a set time frame.
      
      🚀 Outcome: The agent automatically compiles a summary report at the specified time, maintaining consistency with the scheduling requirement.
      ⌟
      
      ⌜
      ✔ Action Timer
      
      ``````prompt
      ⟪⏳: Within 5 minutes of receiving data⟫ Analyze and present the findings.
      ``````
      
      🤔 Purpose: To set a constraint on the processing window, urging the agent to complete analysis within the stipulated duration.
      
      🚀 Outcome: The agent prioritizes the data-processing task, presenting its analysis within the five-minute window, demonstrating efficiency and responsiveness.
      ⌟
      


: To seamlessly integrate templated sections into a business profile, with consistency in structure for executives and board advisor information.

`````syntax
   ↦ ⟪⇐: user-template⟫ applying it to individual data entries for integration into the output.

`````



        Examples:
      
      ⌜
      ✔ Embedding User Template into Business Profile
      
      ``````prompt
      ```template=user-template
      # {user.name}
      dob: {user.dob}
      bio: {user.bio}
      ```
      # Output Syntax
      ```syntax
      "Business Name: <business.name>
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
      ```
      
      ``````
      
      🤔 Purpose: To format and present information about the business's executives and board advisors using a standard user template, ensuring uniformity in the presentation.
      
      🚀 Outcome: The agent produces a comprehensive business profile where the sections for executives and board advisors are formatted according to the user template, delivering a consistent and professional look across the entire profile.
      ⌟
      


: To choreograph interactive elements and agent reactivity within a prompt, guiding behaviors over time or in response to user interactions.

`````syntax
   ↦ ⟪🚀: Action or Behavior Definition⟫

`````



        Examples:
      
      ⌜
      ✔ User-driven Question Flow
      
      ``````prompt
      ⟪🚀: User selects an option ⟫ Provide corresponding information based on the user's selection.
      ``````
      
      🤔 Purpose: To trigger the agent’s delivery of specific information tailored to the user's choice in a Q&A interface.
      
      🚀 Outcome: The agent dynamically adapts its responses, presenting relevant content that aligns with the user's chosen topic or query.
      ⌟
      
      ⌜
      ✔ Time-delayed Notification
      
      ``````prompt
      ⟪🚀: 30 seconds after signup ⟫ Send a welcome message with introductory resources.
      ``````
      
      🤔 Purpose: To engage new users by scheduling a delayed yet warm initiation into the service.
      
      🚀 Outcome: The agent initiates a time-based action, delivering a well-timed welcome message that enriches the user’s onboarding experience.
      ⌟
      


: To introduce and maintain unique identifiers that remain consistent across various usages.

`````syntax
   ↦ ⟪🆔: Entity or Context Requiring ID⟫

`````



        Examples:
      
      ⌜
      ✔ Session ID Generation
      
      ``````prompt
      ⟪🆔: User Session⟫ Generate a session identifier for the new login event.
      ``````
      
      🤔 Purpose: To create a unique, traceable token for each user session initiated.
      
      🚀 Outcome: The agent generates a unique session ID that can be used for tracking user activity and ensuring session integrity.
      ⌟
      
      ⌜
      ✔ Data Record Identification
      
      ``````prompt
      ⟪🆔: Product Listing⟫ Assign an ID to each new product entry in the database.
      ``````
      
      🤔 Purpose: To ensure that each product in the inventory has a distinct identifier, streamlining database operations like searches and updates.
      
      🚀 Outcome: The agent provides each new product listing with a unique ID, enhancing data management efficiency.
      ⌟
      


: To append detailed notes that illuminate the expectation behind a prompt or mockup element.

`````syntax
   ↦ ⟪📖: Detailed Explanation⟫ Narrative or instructive comment.

`````



        Examples:
      
      ⌜
      ✔ Behavior Guideline for Data Handling
      
      ``````prompt
      ⟪📖: Ensure user consent before data collection⟫ Prioritize user privacy when soliciting personal information.
      ``````
      
      🤔 Purpose: To guide the agent toward ethical data practices by emphasizing the importance of user consent.
      
      🚀 Outcome: The agent incorporates end-user consent as a cornerstone of its data collection activities, thereby respecting and upholding user privacy rights.
      ⌟
      
      ⌜
      ✔ Note on Cultural Sensitivity
      
      ``````prompt
      ⟪📖: Account for cultural context in marketing messages⟫ Craft all communication with consideration for cultural nuances and local customs.
      ``````
      
      🤔 Purpose: To prevent cross-cultural misunderstandings and ensure that the agent's interactions are sensitive to diverse cultural backgrounds.
      
      🚀 Outcome: The agent adapts its language and approach to align with the cultural context of each audience segment, promoting effective and respectful communication.
      ⌟
      


: To mark sections within prompts or documents with a unique identifier for future reference and update purposes.

`````syntax
   ↦ ⟪📂:{identifier}⟫ Description or content of the marked section.

`````



        Examples:
      
      ⌜
      ✔ User Guidelines Reference
      
      ``````prompt
      ⟪📂:{user_guidelines}⟫ Refer to the following guidelines for acceptable user behavior.
      ``````
      
      🤔 Purpose: To provide a clear point of reference for the rules governing user conduct.
      
      🚀 Outcome: The section is designated with a clear reference that can be easily updated or pointed to in future interactions.
      ⌟
      
      ⌜
      ✔ Technical Documentation Reference
      
      ``````prompt
      ⟪📂:{installation_procedure_v2}⟫ Make sure to follow the latest installation steps as outlined here.
      ``````
      
      🤔 Purpose: To tag the most current set of instructions for software installation, ensuring users can easily find the latest procedures.
      
      🚀 Outcome: This tag provides a direct reference to the appropriate section of installation documentation, facilitating ease of software setup and future document revisions.
      ⌟
      

➤
: To provide clear and unambiguous instructions to the agent.

`````syntax
   ↦ {➤: <instruction> | <elaboration>}

`````



        Examples:
      
      ⌜
      ✔ Explicit Instruction with Elaboration
      
      ``````prompt
      {➤: Identify the current user | Ensure secure session}
      ``````
      
      🤔 Purpose: To direct the agent to identify the user and ensure that the current session is secure.
      
      🚀 Outcome: The agent identifies the user and takes additional steps to secure the session.
      ⌟
      
      ⌜
      ✔ Data Retrieval with Specificity
      
      ``````prompt
      {➤: Retrieve climate data | Include recent temperature anomalies}
      ``````
      
      🤔 Purpose: To command the agent to fetch climate data, specifically including recent temperature anomalies.
      
      🚀 Outcome: The agent retrieves the requested climate data and provides detailed information on recent temperature anomalies.
      ⌟
      




⌞NPL@0.5⌟
