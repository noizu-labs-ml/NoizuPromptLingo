# Flat API

Cloud-based music notation API for creating, editing and managing musical scores programmatically with real-time collaboration and advanced export capabilities.

## Overview
- **Type**: REST API
- **Version**: v2.15.0 (Latest Stable)
- **Documentation**: https://flat.io/developers/api
- **Platform**: Cloud-based SaaS
- **Format**: JSON/MusicXML/MIDI
- **Repository**: https://github.com/FlatIO/api-client-js
- **Community**: https://help.flat.io/developers
- **Example Gallery**: https://flat.io/developers/examples

## Version Compatibility Matrix
| API Version | Node.js | Browser | Features |
|-------------|---------|---------|----------|
| v2.15.0 | >=14.x | ES2020+ | Full feature set |
| v2.14.x | >=12.x | ES2018+ | Legacy auth support |
| v2.13.x | >=10.x | ES2017+ | Basic operations only |

## Pricing Information
- **Free Tier**: 15 public scores, basic API access
- **Individual ($9.99/month)**: 100 scores, collaboration features
- **Education ($4.99/month)**: 500 scores, classroom tools
- **Enterprise (Custom)**: Unlimited, advanced integrations, SLA
- **API Rate Limits**: 1000 requests/hour (free), 10000/hour (paid)

## Complete Setup and Authentication

### 1. Installation and Dependencies
```bash
# Core package
npm install flat-api

# Optional dependencies for advanced features
npm install xmldom xpath musicxml-interfaces

# Development dependencies
npm install --save-dev @types/flat-api
```

### 2. Authentication Token Generation

#### Step 1: Create Flat.io Developer Account
1. Visit https://flat.io/developers
2. Sign up or log in to your account
3. Navigate to "Applications" section
4. Click "Create New Application"

#### Step 2: Generate OAuth2 Credentials
```javascript
// Application configuration
const appConfig = {
  client_id: 'your_client_id_here',
  client_secret: 'your_client_secret_here',
  redirect_uri: 'http://localhost:3000/callback',
  scope: 'scores.read scores.write scores.social'
};
```

#### Step 3: OAuth2 Flow Implementation
```javascript
const express = require('express');
const axios = require('axios');
const app = express();

// Step 3a: Redirect user to authorization URL
app.get('/auth', (req, res) => {
  const authUrl = `https://flat.io/auth/oauth/authorize?` +
    `client_id=${appConfig.client_id}&` +
    `redirect_uri=${encodeURIComponent(appConfig.redirect_uri)}&` +
    `response_type=code&` +
    `scope=${encodeURIComponent(appConfig.scope)}`;

  res.redirect(authUrl);
});

// Step 3b: Handle callback and exchange code for token
app.get('/callback', async (req, res) => {
  const { code } = req.query;

  try {
    const tokenResponse = await axios.post('https://flat.io/auth/oauth/token', {
      grant_type: 'authorization_code',
      client_id: appConfig.client_id,
      client_secret: appConfig.client_secret,
      redirect_uri: appConfig.redirect_uri,
      code: code
    });

    const accessToken = tokenResponse.data.access_token;
    console.log('Access Token:', accessToken);

    // Store token securely (database, encrypted storage, etc.)
    res.json({ success: true, token: accessToken });
  } catch (error) {
    console.error('Token exchange failed:', error.response.data);
    res.status(400).json({ error: 'Authentication failed' });
  }
});

app.listen(3000, () => {
  console.log('Auth server running on http://localhost:3000');
  console.log('Visit http://localhost:3000/auth to start OAuth flow');
});
```

### 3. API Client Configuration
```javascript
const Flat = require('flat-api');

// Initialize client with proper error handling
const client = new Flat.ApiClient();
client.basePath = 'https://api.flat.io/v2';

// Configure OAuth2 authentication
client.authentications['OAuth2'] = {
  type: 'oauth2',
  accessToken: process.env.FLAT_ACCESS_TOKEN || 'your_access_token_here'
};

// Add request interceptor for error handling
client.callApi = (function(originalCallApi) {
  return function(path, httpMethod, pathParams, queryParams, headerParams, formParams, bodyParam, authNames, contentTypes, accepts, returnType, callback) {
    const wrappedCallback = function(error, data, response) {
      if (error) {
        console.error(`Flat API Error [${httpMethod} ${path}]:`, {
          status: response ? response.status : 'Unknown',
          message: error.message,
          details: error.response ? error.response.text : 'No details'
        });
      }
      callback(error, data, response);
    };

    return originalCallApi.call(this, path, httpMethod, pathParams, queryParams, headerParams, formParams, bodyParam, authNames, contentTypes, accepts, returnType, wrappedCallback);
  };
})(client.callApi);
```

## Complete Working Example

### Data Preparation
```javascript
// Sample MusicXML content for a simple C major scale
const musicXMLContent = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE score-partwise PUBLIC "-//Recordare//DTD MusicXML 3.1 Partwise//EN" "http://www.musicxml.org/dtds/partwise.dtd">
<score-partwise version="3.1">
  <work>
    <work-title>C Major Scale</work-title>
  </work>
  <identification>
    <creator type="composer">API Example</creator>
  </identification>
  <part-list>
    <score-part id="P1">
      <part-name>Piano</part-name>
      <score-instrument id="P1-I1">
        <instrument-name>Piano</instrument-name>
      </score-instrument>
      <midi-instrument id="P1-I1">
        <midi-channel>1</midi-channel>
        <midi-program>1</midi-program>
      </midi-instrument>
    </score-part>
  </part-list>
  <part id="P1">
    <measure number="1">
      <attributes>
        <divisions>1</divisions>
        <key>
          <fifths>0</fifths>
        </key>
        <time>
          <beats>4</beats>
          <beat-type>4</beat-type>
        </time>
        <clef>
          <sign>G</sign>
          <line>2</line>
        </clef>
      </attributes>
      <note>
        <pitch>
          <step>C</step>
          <octave>4</octave>
        </pitch>
        <duration>1</duration>
        <type>quarter</type>
      </note>
      <note>
        <pitch>
          <step>D</step>
          <octave>4</octave>
        </pitch>
        <duration>1</duration>
        <type>quarter</type>
      </note>
      <note>
        <pitch>
          <step>E</step>
          <octave>4</octave>
        </pitch>
        <duration>1</duration>
        <type>quarter</type>
      </note>
      <note>
        <pitch>
          <step>F</step>
          <octave>4</octave>
        </pitch>
        <duration>1</duration>
        <type>quarter</type>
      </note>
    </measure>
  </part>
</score-partwise>`;

// Alternative: Generate simple score programmatically
function generateSimpleScore(title, notes) {
  return {
    title: title,
    data: {
      scoreData: musicXMLContent,
      format: 'musicxml'
    },
    privacy: 'public',
    sharingMode: 'read'
  };
}
```

### Complete Workflow Example
```javascript
const Flat = require('flat-api');
const fs = require('fs').promises;

async function completeScoreWorkflow() {
  try {
    // Initialize APIs
    const scoreApi = new Flat.ScoreApi(client);
    const userApi = new Flat.UserApi(client);
    const classApi = new Flat.ClassApi(client);

    console.log('Starting complete score workflow...');

    // Step 1: Verify authentication
    const currentUser = await userApi.getUser();
    console.log(`Authenticated as: ${currentUser.username} (${currentUser.email})`);

    // Step 2: Create new score with error handling
    console.log('Creating new score...');
    const scoreData = {
      title: 'API Demo - C Major Scale',
      subtitle: 'Generated via Flat API',
      privacy: 'public',
      sharingMode: 'read',
      data: {
        scoreData: musicXMLContent,
        format: 'musicxml'
      }
    };

    const score = await scoreApi.createScore(scoreData);
    console.log(`Score created successfully: ${score.id}`);
    console.log(`View at: https://flat.io/score/${score.id}`);

    // Step 3: Add metadata and tags
    console.log('Adding metadata...');
    await scoreApi.updateScore(score.id, {
      description: 'A simple C major scale created via the Flat API for demonstration purposes.',
      tags: ['api-demo', 'c-major', 'scale', 'educational']
    });

    // Step 4: Add collaborator with proper error handling
    console.log('Adding collaborator...');
    try {
      await scoreApi.addScoreCollaborator(score.id, {
        user: 'demo-collaborator@example.com',
        aclRead: true,
        aclWrite: true,
        aclShare: false
      });
      console.log('Collaborator added successfully');
    } catch (error) {
      if (error.status === 404) {
        console.log('Collaborator not found, skipping...');
      } else {
        throw error;
      }
    }

    // Step 5: Create multiple export formats
    console.log('Generating exports...');
    const exports = await Promise.allSettled([
      scoreApi.getScoreRevisionPdf(score.id, 'last'),
      scoreApi.getScoreRevisionMidi(score.id, 'last'),
      scoreApi.getScoreRevisionMp3(score.id, 'last')
    ]);

    // Step 6: Save exports to files
    for (let i = 0; i < exports.length; i++) {
      const result = exports[i];
      const formats = ['pdf', 'midi', 'mp3'];

      if (result.status === 'fulfilled') {
        const filename = `score_${score.id}.${formats[i]}`;
        await fs.writeFile(filename, result.value);
        console.log(`Export saved: ${filename}`);
      } else {
        console.error(`Failed to generate ${formats[i]}:`, result.reason.message);
      }
    }

    // Step 7: Create embeddable widget
    console.log('Generating embed code...');
    const embedCode = `<iframe src="https://flat.io/embed/${score.id}?_embed=true" height="450" width="100%" frameborder="0" allowfullscreen allow="midi"></iframe>`;
    console.log('Embed code:', embedCode);

    // Step 8: Demonstrate version control
    console.log('Creating score revision...');
    const updatedScore = await scoreApi.updateScore(score.id, {
      title: 'API Demo - C Major Scale (Updated)',
      description: 'Updated version with enhanced metadata'
    });

    // Step 9: List all revisions
    const revisions = await scoreApi.getScoreRevisions(score.id);
    console.log(`Total revisions: ${revisions.length}`);
    revisions.forEach((rev, index) => {
      console.log(`  Revision ${index + 1}: ${rev.id} (${new Date(rev.creationDate).toISOString()})`);
    });

    // Step 10: Cleanup (optional)
    // await scoreApi.deleteScore(score.id);
    // console.log('Score deleted');

    return {
      scoreId: score.id,
      scoreUrl: `https://flat.io/score/${score.id}`,
      embedCode: embedCode,
      revisions: revisions.length
    };

  } catch (error) {
    console.error('Workflow failed:', {
      message: error.message,
      status: error.status,
      details: error.response ? error.response.text : 'No additional details'
    });
    throw error;
  }
}

// Execute the workflow
completeScoreWorkflow()
  .then(result => {
    console.log('Workflow completed successfully:', result);
    process.exit(0);
  })
  .catch(error => {
    console.error('Workflow failed:', error);
    process.exit(1);
  });
```

### Error Handling Best Practices
```javascript
// Comprehensive error handling wrapper
function withRetry(apiCall, maxRetries = 3, delay = 1000) {
  return async (...args) => {
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await apiCall(...args);
      } catch (error) {
        console.log(`Attempt ${attempt} failed:`, error.message);

        // Don't retry on client errors (4xx)
        if (error.status >= 400 && error.status < 500) {
          throw error;
        }

        // Don't retry on last attempt
        if (attempt === maxRetries) {
          throw error;
        }

        // Wait before retry with exponential backoff
        await new Promise(resolve => setTimeout(resolve, delay * attempt));
      }
    }
  };
}

// Usage example
const createScoreWithRetry = withRetry(scoreApi.createScore.bind(scoreApi));
```

## Advanced Features

### Batch Operations
```javascript
// Create multiple scores efficiently
async function createScoreBatch(scoreDataArray) {
  const promises = scoreDataArray.map(scoreData =>
    scoreApi.createScore(scoreData).catch(error => ({ error, scoreData }))
  );

  const results = await Promise.allSettled(promises);
  const successful = results.filter(r => r.status === 'fulfilled').map(r => r.value);
  const failed = results.filter(r => r.status === 'rejected').map(r => r.reason);

  return { successful, failed };
}
```

### Real-time Collaboration
```javascript
// WebSocket connection for real-time updates
const WebSocket = require('ws');

function subscribeToScoreUpdates(scoreId, accessToken) {
  const ws = new WebSocket(`wss://api.flat.io/v2/scores/${scoreId}/events`, {
    headers: {
      'Authorization': `Bearer ${accessToken}`
    }
  });

  ws.on('message', (data) => {
    const event = JSON.parse(data);
    console.log('Score update:', event);

    switch (event.type) {
      case 'score.revision.created':
        console.log('New revision created:', event.revision);
        break;
      case 'score.collaborator.added':
        console.log('Collaborator added:', event.user);
        break;
      case 'score.comment.added':
        console.log('Comment added:', event.comment);
        break;
    }
  });

  return ws;
}
```

## Strengths
- **Real-time Collaboration**: Live editing with multiple users, conflict resolution
- **Version Control**: Complete revision history with branching and merging
- **Multiple Export Formats**: PDF, MIDI, MP3, MusicXML, PNG with quality options
- **Embedded Score Viewer**: Responsive widget with playback capabilities
- **Educational Features**: Assignments, classes, progress tracking, gradebook integration
- **Advanced API**: RESTful design with webhooks, real-time events, batch operations
- **Cross-platform**: Works on web, mobile, and desktop applications
- **Professional Quality**: High-resolution exports, print-ready PDFs

## Limitations
- **Subscription Required**: Advanced features need paid plans ($9.99-$49.99/month)
- **Rate Limits**: 1000-10000 requests/hour depending on plan
- **Internet Dependency**: No offline editing or caching capabilities
- **File Size Limits**: 10MB per score on free tier, 50MB on paid plans
- **Limited Import Formats**: Primarily MusicXML, MIDI, and Flat's native format
- **Regional Restrictions**: Some features unavailable in certain countries

## Best For
- **Music Education Platforms**: Schools, conservatories, online learning systems
- **Collaborative Composition**: Band arrangements, orchestral works, songwriting teams
- **Score Sharing Applications**: Music publishers, composers, arrangers
- **Interactive Music Apps**: Practice tools, sight-reading trainers, theory apps
- **Content Management**: Digital music libraries, institutional repositories
- **Workflow Integration**: DAW plugins, notation software connectors

## NPL-FIM Integration
```npl
⟪flat-api|score-management⟫
→authentication OAuth2Flow[clientId, redirectUri, scope]
→score Create[title, musicXML, privacy, collaboration]
→collaboration AddUser[email, permissions: read|write|share]
→export Generate[format: PDF|MIDI|MP3|MusicXML, quality: draft|final]
→embed Widget[scoreId, height, width, autoplay: boolean]
→version CreateRevision[changes, description]
→realtime Subscribe[scoreId, events: revision|comment|collaboration]
→batch ProcessMultiple[operations[], maxConcurrency: number]
⟪/flat-api⟫
```

## Related Solutions
- [MusicXML](musicxml.md) - Standard score interchange format
- [VexFlow](vexflow.md) - Client-side music notation rendering
- [OSMD](osmd.md) - Open-source music display library
- [MuseScore API](musescore-api.md) - Alternative notation platform
- [Music21](music21.md) - Python toolkit for music analysis