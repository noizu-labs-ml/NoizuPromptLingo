# Flat API

Cloud-based music notation API for creating, editing and managing musical scores programmatically.

## Overview
- **Type**: REST API
- **Documentation**: https://flat.io/developers/api
- **Platform**: Cloud-based SaaS
- **Format**: JSON/MusicXML

## Setup
```bash
npm install flat-api
```

```javascript
const Flat = require('flat-api');
const client = new Flat.ApiClient();
client.authentications['OAuth2'] = {
  type: 'oauth2',
  accessToken: 'YOUR_ACCESS_TOKEN'
};
```

## Example: Create and Edit Score
```javascript
const api = new Flat.ScoreApi(client);

// Create new score
const score = await api.createScore({
  title: 'My Composition',
  privacy: 'public',
  data: {
    scoreData: musicXMLContent
  }
});

// Add collaborator
await api.addScoreCollaborator(score.id, {
  user: 'collaborator@email.com',
  aclWrite: true
});

// Export score
const pdf = await api.getScoreRevisionPdf(score.id, 'last');
```

## Strengths
- Real-time collaboration
- Version control for scores
- Multiple export formats (PDF, MIDI, MP3, MusicXML)
- Embedded score viewer widget
- Educational features (assignments, classes)

## Limitations
- Requires subscription for advanced features
- Limited free tier (15 scores)
- Internet connection required
- No offline editing capability

## Best For
- Music education platforms
- Collaborative composition tools
- Score sharing applications
- Online music learning systems

## NPL-FIM Integration
```npl
⟪flat-api|score⟫
→score Create[title, instruments, timeSignature]
→collaboration AddUser[email, permissions]
→export Generate[format: PDF|MIDI|MP3|MusicXML]
→embed Widget[scoreId, height, width]
⟪/flat-api⟫
```

## Related Solutions
- [MusicXML](musicxml.md) - Score interchange format
- [VexFlow](vexflow.md) - Client-side rendering
- [OSMD](osmd.md) - Open-source alternative