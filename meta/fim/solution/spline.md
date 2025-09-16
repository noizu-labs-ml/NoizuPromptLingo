# Spline - 3D Design Tool & Runtime

## Installation
```bash
npm install @splinetool/runtime
```

## CDN
```html
<script type="module">
  import { Application } from 'https://unpkg.com/@splinetool/runtime@latest/build/runtime.js';
</script>
```

## Basic Integration
```html
<!-- Canvas container -->
<canvas id="canvas3d"></canvas>

<script type="module">
  import { Application } from '@splinetool/runtime';

  // Load Spline scene
  const canvas = document.getElementById('canvas3d');
  const app = new Application(canvas);

  // Load exported scene URL from Spline editor
  app.load('https://prod.spline.design/YOUR_SCENE_ID/scene.splinecode');
</script>
```

## Interaction & Events
```javascript
// Wait for load and access objects
app.load('YOUR_SCENE_URL').then(() => {
  // Access specific objects
  const cube = app.findObjectByName('Cube');

  // Modify properties
  cube.position.x = 10;
  cube.scale.set(2, 2, 2);

  // Add event listeners
  app.addEventListener('mouseDown', (e) => {
    if (e.target.name === 'Button') {
      console.log('Button clicked!');
      // Trigger animations or state changes
    }
  });

  // Trigger Spline events
  app.emitEvent('start', 'Animation1');

  // Access variables
  const score = app.getVariable('score');
  app.setVariable('score', score + 10);
});

// Responsive handling
window.addEventListener('resize', () => {
  app.setSize(window.innerWidth, window.innerHeight);
});
```

## React Integration
```jsx
import Spline from '@splinetool/react-spline';

export default function App() {
  return (
    <Spline
      scene="https://prod.spline.design/YOUR_SCENE_ID/scene.splinecode"
      onLoad={(spline) => {
        // Access Spline API
        const obj = spline.findObjectByName('cube');
      }}
      onMouseDown={(e) => {
        console.log('Clicked:', e.target.name);
      }}
    />
  );
}
```

## Strengths
- No-code 3D editor with intuitive interface
- Real-time collaboration
- Built-in interactions and states
- Exports to web runtime
- React/Vue/vanilla JS support

## Limitations
- Requires Spline editor for scene creation
- Limited programmatic scene generation
- Subscription required for advanced features
- Smaller community than traditional 3D libraries

## Best Use Cases
- Interactive 3D web experiences
- Landing pages with 3D elements
- Product showcases
- Design portfolios
- Marketing campaigns with 3D content