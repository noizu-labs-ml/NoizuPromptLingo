# NPL Panel Group Chat (npl-panel-group-chat)

**Purpose**: Simulate dynamic expert collaboration with natural conversational flow and real-time interaction patterns.

## Syntax
```
<npl-panel-group-chat>
participants:
  - username: <handle>
    role: <expertise>
    status: <online|away|busy>
topic: <discussion_subject>
messages:
  - timestamp: <time>
    sender: <username>
    message: <content>
    reactions: [<emoji_responses>]
    reply_to: <message_reference>
thread_summary:
  key_insights: [<main_discoveries>]
  action_items: [<follow_up_tasks>]
  unresolved: [<open_questions>]
</npl-panel-group-chat>
```

## Key Features
- **Real-Time Flow**: Timestamp-based message ordering
- **Interactive Responses**: Direct replies and emoji reactions
- **Natural Language**: Casual yet focused communication
- **Emergent Insights**: Organic idea development through dialogue

## Communication Patterns
- **Rapid Exchange**: Quick back-and-forth collaboration
- **Threading**: Responses to specific earlier points
- **Social Cues**: @mentions, emojis, informal tone
- **Collaborative Building**: Ideas developed through interaction

## Minimal Example
```
<npl-panel-group-chat>
participants:
  - username: sarah_dev
    role: Frontend Developer
    status: online
  - username: alex_pm
    role: Product Manager
    status: online
topic: "Mobile app performance optimization"
messages:
  - timestamp: "14:32"
    sender: alex_pm
    message: "Users reporting 3s load times on mobile 📱"
    reactions: ["😰"]
  - timestamp: "14:33"
    sender: sarah_dev
    message: "@alex_pm Bundle size grew 40% this quarter"
    reactions: ["📈", "😬"]
    reply_to: "load time issue"
  - timestamp: "14:34"
    sender: sarah_dev
    message: "Code splitting could cut initial load by 60% 🚀"
    reactions: ["💡", "🎯"]
thread_summary:
  key_insights: ["Bundle size is main bottleneck", "Code splitting offers major improvement"]
  action_items: ["Implement code splitting", "Measure performance impact"]
  unresolved: ["Timeline for implementation?"]
</npl-panel-group-chat>
```

## Interaction Elements
- **Reactions**: 👍, 💡, 🔥, 🤔, 📊 (contextual feedback)
- **References**: @username mentions and reply threading
- **Timing**: Chronological message flow with timestamps
- **Status**: Participant availability and engagement level