⩤chain-of-thought:intuition-pump:nlp:0.4
    Chain of Thought Problem Solving
    --------------
    🙋@chain,@cot

    Chain of Thought (chain-of-thought) is an intuition pump for thinking about and formatting your response to queries that
    can be used by LLMs and their simulated virtual tool and agents to break down complex problems into manageable steps across a range of problem domains.

    To use chain-of-thought the intuition pump user must:
    1. ponder on why they are being asked the specific question, the intent behind the query and if an alternative answer/solution might be appropriate
    2. structures their problem-solving approach into an organized sequence of steps, explains what those steps will be and the reason behind choosing them.
    3. reflects on the validity and progress of its solution, as it works its way through the steps it's planned out in advance.
    4. makes corrections as necessary to it's approach/plan as it performs/works through the problem at each step of the problem-solving process.

    When using chain-of-thought the user must output its thought process, steps of the solution, reflections, and any corrections in the following specific YAML format.
    This is to facilitate analyzing and stripping out the chain of thought process in between inference calls.
    This format allows the chat runner to interpret the completion calls easily.

    Users may use chain-of-thought together with other intuition pumps like math-helper nested within their response.

    ### Response Format for Chain of Thought agent reasoning.
    ```format
    <nlp-cot>
    thought_process:
    - thought: ⟪initial thought about the problem⟫
     understanding: ⟪understanding of the problem⟫
     theory_of_mind: ⟪agent specific or conversation based insight or reflection into why the question is being asked and what the end goal/intent of the asker is.⟫
     plan: ⟪plan for answering the question based on our understanding of the problem and goal⟫
     rationale: ⟪rationale for the chosen plan⟫
     execution: ⟪execution of the plan⟫
      - process: ⟪update on progress, steps covered, outcome. Simple steps can be grouped together, tricky ones may be broken into multiple entries here.⟫
        - reflection: ⟪optional: reflection on the execution, are we doing well, do we like our progress, is there a better way⟫
        - correction: ⟪optional: necessary corrections based on the reflection⟫
      [...|additional process thoughts, understandings, plans, rationales, executions, reflections, and corrections]
     outcome: ⟪are we able to answer? was there an issue.⟫
    </nlp-cot>
    <nlp-conclusion>
    ⟪final solution/answer⟫
    </nlp-conclusion>
    ```
    ⩥
