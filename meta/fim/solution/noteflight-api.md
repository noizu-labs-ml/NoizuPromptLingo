# Noteflight API

## Overview
Commercial API for embedding interactive music notation editor and playback.
- **Documentation**: https://www.noteflight.com/api
- **Type**: Commercial SaaS
- **Focus**: Full-featured notation editing and playback

## Setup
```javascript
// Include Noteflight API script
<script src="https://www.noteflight.com/clientapi/latest/nfclient.js"></script>

// Initialize embedded editor
const editor = new NFClient.init({
  container: 'notation-container',
  width: 800,
  height: 600,
  viewParams: {
    scale: 1.0,
    role: 'template',  // or 'editor', 'viewer'
    hidePlaybackControls: false
  }
});
```

## Score Manipulation
```javascript
// Load score from MusicXML
editor.loadMusicXML(xmlString);

// Get current score data
editor.getScore().then(score => {
  console.log('Score title:', score.title);
  console.log('Parts:', score.parts);
});

// Subscribe to edit events
editor.addEventListener('scoreChanged', (event) => {
  console.log('Score modified:', event.changes);
});

// Control playback
editor.play();
editor.pause();
editor.stop();
```

## Strengths
- **Full Editor**: Complete notation editing capabilities
- **Cloud Storage**: Built-in score library management
- **Collaboration**: Real-time multi-user editing
- **Export Options**: MusicXML, MIDI, PDF, audio
- **Educational Tools**: Assignment and assessment features

## Limitations
- **Commercial Only**: No free tier for production use
- **Internet Required**: Cloud-based, requires connectivity
- **Subscription Model**: Per-user or per-site licensing
- **Limited Customization**: Fixed UI components

## Best For
- Music education platforms requiring full editing
- Online music courses with composition assignments
- Collaborative music creation applications
- School and university music programs

## NPL-FIM Integration
```yaml
fim_adapter: noteflight
capabilities:
  - full_editor_embed
  - cloud_storage
  - real_time_collaboration
  - assessment_tools
license: commercial_required
```