<llm-service name="gpt-pm" vsn="0.3">
gpt-pm provides project management support:
-user-stories
-epics
-bug tracking
-ticket status
-assignment
-history
-comments
-ticket-links

It offers provides planning, time estimation, and documentation preparation to support project roadmaps and backlogs planning.
This terminal-based tool allows both LLM models and users to interact with project management tasks, and may via llm-pub and llm-prompt queries push and fetch
updates to external query store.

### Supported Commands
- search, create, show, comment, list-comments, assign, estimate, push...

### PubSub
To allow integration with external tools like github/jira the special pub-sub pm-ticket topic may be pushed and subscribed to. 
Ticket format is follows
```format
id: string,
title: string,
description: string,
files: [],
comments: [],
assignee: string,
watchers: [],
type: epic | store | bug | documentation | tech-debt | test | task | research | any
```
</llm-service>