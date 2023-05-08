# GPT-Prototyper (gpt-pro)

GPT-Prototyper (gpt-pro) is a powerful tool designed to streamline the process of creating software prototypes. It allows developers to quickly generate prototypes based on input instructions like project requirements, user stories, mockups, and more.

## Key Features

1. **Rapid prototype generation**: gpt-pro enables developers to create prototypes in a fraction of the time it would take using traditional methods.

2. **YAML-like input**: Provide project information, user stories, requirements, and mockups in an easy-to-understand YAML-like format.

3. **Interactive environment**: The tool actively engages with users to clarify its understanding of the project requirements, ensuring that the prototype aligns with the desired outcome.

4. **Multiple output formats**: gpt-pro can output prototype code in various languages, including HTML, CSS, C#, Python, and others.

5. **Integration with other tools**: GPT-Prototyper can work seamlessly with other tools and services like GPT-FIM (Graphic Asset Generator/Editor), GPT-git (simulated git interface), and PromptLingo Assistant.

6. **Extensible behavior**: Users can request specific features or functionality to be added to the tool, making it a versatile solution for various projects.

## Usage

To use GPT-Prototyper, simply provide instructions in the following format:

```
@gpt-proto please provide a prototype based on these instructions
```instructions
 instructions: project: | [...] 
 output: gpt-git 
 stack: TailWind
 user-stories: 
   - story #1 | 
     as a [...] 
   - story #2 |
     as a [...] 
   - [...]
[...]
```

The tool will then review the instructions, ask brief clarification questions if needed, and generate the prototype as requested.

## Why is GPT-Prototyper useful?

GPT-Prototyper accelerates the development process by providing rapid prototyping based on user input. It helps developers quickly validate ideas and iterate on designs, ultimately leading to more efficient and successful projects. By utilizing an interactive environment and offering support for multiple output formats, GPT-Prototyper becomes an indispensable tool for any developer looking to streamline their workflow.

## Getting Started

To start using GPT-Prototyper, simply follow the usage instructions above and begin creating prototypes with ease.
```

-------------------------------------
Human here, this one still has a little ways to go, I had to go back and forth to nail down the requirements with it although I could have been more concise and specific in how I described the requirements. 
The end goal is to have an agent that can generate and from this type of generated mockup prepare actual code so you can iterate graphically before comitting to debugging/writting code with the tool. 

![image](https://user-images.githubusercontent.com/6298118/236786407-ab68febf-dac0-49c3-89ad-b403829818ab.png)


After a lot of back and forth from my original image spec below this got us to: 


![image](https://user-images.githubusercontent.com/6298118/236786142-f356a891-1a73-437d-9612-89dc62fcce3f.png)


https://user-images.githubusercontent.com/6298118/236786465-53a37899-6c0c-4e8f-aa8a-835b4a8378f9.mp4


