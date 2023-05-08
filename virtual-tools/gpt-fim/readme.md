# README: gpt-fim Graphic Asset Generator/Editor Tool - Focused on Low-Fidelity Mockups

## Introduction

The `gpt-fim` Graphic Asset Generator/Editor Tool is a simulated interface designed to create and edit low-fidelity mockups in collaboration with your LLM. It enables users to generate basic layouts and designs before refining them manually or with the assistance of the LLM to create the final version. This process allows users to establish an agreed-upon layout before generating actual code to recreate the design in HTML, CSS, JavaScript, Python, or other languages.

## Why Use the gpt-fim Graphic Asset Generator/Editor Tool for Low-Fidelity Mockups?

The `gpt-fim` tool offers several benefits when focusing on low-fidelity mockups:

1. **Streamlined design process**: The tool allows users to create basic layouts with their LLM and establish a mutual understanding of the design before diving into the details.

2. **Iterative refinement**: Once the low-fidelity mockup is agreed upon, users can tweak the design manually or in collaboration with the LLM to create the final version.

3. **Facilitates code generation**: After finalizing the design, users can work with the LLM to generate the necessary code in various languages, such as HTML, CSS, JavaScript, or Python, to recreate the design.

4. **Saves time and resources**: By focusing on low-fidelity mockups, users can quickly iterate on designs and avoid investing time and resources into detailed designs that may require significant changes.

## Commands and Usage

To generate low-fidelity mockups with the `gpt-fim` tool, use the following command structure:

```
Draw graphics: @gpt-fim #{format} "draw #{object_description}"
```

Here are some example commands for low-fidelity mockups:

- Draw a low-fidelity mockup of a Twitter clone in SVG format: `@gpt-fim svg "draw a low-fidelity mockup of a Twitter clone"`
- Draw a low-fidelity mockup of a blog homepage in SVG format: `@gpt-fim svg "draw a low-fidelity mockup of a blog homepage"`

The output format will be:

```
<llm-fim>
  <llm-fim-title><h2>#{Title of graphic}</h2></llm-fim-title>
  <llm-fim-media type="<format>">
  <content>
    <!-- Example: <svg width="#{width}" height="#{height}" style="border:1px solid black;"><circle cx="50" cy="50" r="30" fill="blue" /></svg> -->
  </content>
  </llm-fim-media>
</llm-fim>
```

## Conclusion

The `gpt-fim` Graphic Asset Generator/Editor Tool offers a convenient and collaborative approach for creating low-fidelity mockups with your LLM. By focusing on establishing a basic layout before refining the design and generating code, users can save time, resources, and ensure a smooth design process. This approach allows for effective collaboration between users and LLMs, leading to better and more efficient design outcomes.


-----------------------------
@Human Here, this is a very crude walk through of applying this prompt to generate and tweak graphics. In some cases you will actually have better outcomes asking for terminal ascii art as it may take fewer tokens to output. The nice part here is that you may 
iterate on the design and clear interstitial chat conversations until you have the right design/mockup and then go to code. 



![image](https://user-images.githubusercontent.com/6298118/236753448-9cbfee18-ecad-40f1-9f1a-619a083fff52.png)

![image](https://user-images.githubusercontent.com/6298118/236753449-23165796-1909-4c0e-b293-1b96014391c6.png)
![image](https://user-images.githubusercontent.com/6298118/236753669-78043d98-a727-4a93-9f12-a7a9b2f12017.png)


Hand Edited
![image](https://user-images.githubusercontent.com/6298118/236753486-65db677a-3f0f-45e0-a24b-47fe4f3208e7.png)

Generated Markup from hand edited SVG fed back into GPT. 
![image](https://user-images.githubusercontent.com/6298118/236753580-74edc6d7-ae79-4a62-ad71-83affa4405e9.png)

![image](https://user-images.githubusercontent.com/6298118/236753628-9937cd3f-eda4-4604-87b2-e7c75a733cfa.png)



