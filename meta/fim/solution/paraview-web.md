# ParaView Web NPL-FIM Solution

ParaView Web enables remote scientific visualization with server-side rendering for massive datasets.

## Installation

```bash
# Server setup
pip install paraview
npm install paraview-lite

# Client
npm install paraviewweb wslink
```

## Working Example

```javascript
// Client connection
import SmartConnect from 'wslink/src/SmartConnect';
import ParaViewWebClient from 'paraviewweb/src/IO/WebSocket/ParaViewWebClient';

const config = {
  sessionURL: 'ws://localhost:1234/ws',
  application: 'paraview'
};

const smartConnect = SmartConnect.newInstance({ config });
smartConnect.connect().then(connection => {
  const client = ParaViewWebClient.newInstance({ connection });

  // Load data
  client.session.call('pv.load', ['dataset.vtk']).then(() => {
    // Apply filters
    client.session.call('pv.contour', {
      dataset: 'dataset.vtk',
      isovalues: [0.5, 1.0, 1.5]
    });

    // Render
    client.viewport.render();
  });
});
```

## NPL-FIM Integration

```markdown
⟨npl:fim:paraview-web⟩
mode: remote-rendering
dataset: large_simulation
filters: [contour, streamlines]
collaboration: enabled
⟨/npl:fim:paraview-web⟩
```

## Key Features
- Remote rendering for TB-scale data
- 100+ visualization filters
- Collaborative sessions
- Cinema database export
- Python scripting

## Best Practices
- Use server clusters for large data
- Implement session pooling
- Cache filter pipelines
- Progressive rendering for interactivity