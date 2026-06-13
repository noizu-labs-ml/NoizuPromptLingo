# Server for mydraft

Stores the documents in Google Cloud storage and provides a websocket interface for live collaboration over yjs.

### Self hosting

```
docker build -t mydraft/app .
docker run --name mydraft -d -p 8001:8001 -v ${PWD}/localFileStore:/mydraft/localFileStore mydraft/app
```