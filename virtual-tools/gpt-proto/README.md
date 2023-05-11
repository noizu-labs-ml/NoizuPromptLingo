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
The tool will then review the instructions, ask brief clarification questions if needed, and generate the prototype as requested.

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

## Example 
### Request
````example
@gpt-pro
```instructions
project: Simple Chat User Interface
output: gpt-git
stack: HTML, CSS, JavaScript
requirements:
  - don't output the code.
  - Interactive text input and send button
  - Add messages to chat list on hitting Enter or clicking Send button
mockups:
  - format: SVG
    content: |
      <llm-fim>
        <llm-fim-title><h2>Simple Chat User Interface</h2></llm-fim-title>
        <llm-fim-media type="svg">
          <content>
            <svg width="400" height="300" style="border:1px solid black;">
              <rect x="0" y="0" width="400" height="300" fill="white" />
              <rect x="10" y="10" width="380" height="260" fill="lightgray" />
              <rect x="10" y="230" width="380" height="40" fill="white" />
              <circle cx="385" cy="250" r="15" fill="blue" />
              <text x="20" y="20" font-family="Arial" font-size="14" fill="black">User 1: Hello!</text>
              <text x="20" y="40" font-family="Arial" font-size="14" fill="black">User 2: Hi there!</text>
              <text x="20" y="60" font-family="Arial" font-size="14" fill="black">User 1: How are you?</text>
            </svg>
          </content>
        </llm-fim-media>
      </llm-fim>
```
````

### Response
````example
Here's the interactive prototype in HTML, CSS, and JavaScript:

```HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Simple Chat User Interface</title>
  <style>
    .chat-container {
      width: 400px;
      height: 300px;
      border: 1px solid black;
      display: flex;
      flex-direction: column;
    }
    .chat-list {
      flex-grow: 1;
      padding: 10px;
      overflow-y: auto;
      background-color: lightgray;
    }
    .input-container {
      display: flex;
      padding: 10px;
      background-color: white;
    }
    .message-input {
      flex-grow: 1;
      border: 1px solid lightgray;
    }
    .send-button {
      background-color: blue;
      color: white;
      border: none;
      margin-left: 5px;
      cursor: pointer;
    }
  </style>
</head>
<body>
  <div class="chat-container">
    <div class="chat-list" id="chatList"></div>
    <div class="input-container">
      <input type="text" class="message-input" id="messageInput">
      <button class="send-button" id="sendButton">Send</button>
    </div>
  </div>

  <script>
    const chatList = document.getElementById('chatList');
    const messageInput = document.getElementById('messageInput');
    const sendButton = document.getElementById('sendButton');

    sendButton.addEventListener('click', sendMessage);
    messageInput.addEventListener('keypress', (event) => {
      if (event.key === 'Enter') {
        sendMessage();
      }
    });

    function sendMessage() {
      const message = messageInput.value;
      if (message.trim()) {
        const messageElement = document.createElement('div');
        messageElement.textContent = `User: ${message}`;
        chatList.appendChild(messageElement);
        messageInput.value = '';
      }
    }
  </script>
</body>
</html>
```

The provided code contains a simple chat user interface with an interactive text input and send button that adds messages to the chat list when the user hits Enter or clicks the send button.
````

### Generated Code Screen Shot
Input was types and entered to fill chat window. 
![image](https://github.com/noizu-labs-ml/NoizuPromptLingo/assets/6298118/b5e81b3a-64d0-456c-adab-c473b9a455b9)



## Why is GPT-Prototyper useful?

GPT-Prototyper accelerates the development process by providing rapid prototyping based on user input. It helps developers quickly validate ideas and iterate on designs, ultimately leading to more efficient and successful projects. By utilizing an interactive environment and offering support for multiple output formats, GPT-Prototyper becomes an indispensable tool for any developer looking to streamline their workflow.

## Getting Started

To start using GPT-Prototyper, simply follow the usage instructions above and begin creating prototypes with ease.



Human Here
=====
Human here, this one still has a little ways to go, I had to go back and forth to nail down the requirements with it although I could have been more concise and specific in how I described the requirements. 
The end goal is to have an agent that can generate and from this type of generated mockup prepare actual code so you can iterate graphically before comitting to debugging/writting code with the tool. 

![image](https://user-images.githubusercontent.com/6298118/236786407-ab68febf-dac0-49c3-89ad-b403829818ab.png)


After a lot of back and forth from my original image spec below this got us to: 


![image](https://user-images.githubusercontent.com/6298118/236786142-f356a891-1a73-437d-9612-89dc62fcce3f.png)


https://user-images.githubusercontent.com/6298118/236786465-53a37899-6c0c-4e8f-aa8a-835b4a8378f9.mp4


