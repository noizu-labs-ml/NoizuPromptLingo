# VTK.js NPL-FIM Solution

VTK.js provides scientific visualization for medical imaging, engineering simulations, and data analysis.

## Installation

```bash
npm install @kitware/vtk.js
```

CDN:
```html
<script src="https://unpkg.com/@kitware/vtk.js"></script>
```

## Working Example

```javascript
import '@kitware/vtk.js/Rendering/Profiles/Volume';
import vtkFullScreenRenderWindow from '@kitware/vtk.js/Rendering/Misc/FullScreenRenderWindow';
import vtkVolume from '@kitware/vtk.js/Rendering/Core/Volume';
import vtkVolumeMapper from '@kitware/vtk.js/Rendering/Core/VolumeMapper';
import vtkHttpDataSetReader from '@kitware/vtk.js/IO/Core/HttpDataSetReader';

const fullScreenRenderer = vtkFullScreenRenderWindow.newInstance();
const renderer = fullScreenRenderer.getRenderer();
const renderWindow = fullScreenRenderer.getRenderWindow();

const reader = vtkHttpDataSetReader.newInstance();
reader.setUrl('/data/headsq.vti');
reader.loadData().then(() => {
  const mapper = vtkVolumeMapper.newInstance();
  mapper.setInputConnection(reader.getOutputPort());

  const actor = vtkVolume.newInstance();
  actor.setMapper(mapper);

  renderer.addVolume(actor);
  renderer.resetCamera();
  renderWindow.render();
});
```

## NPL-FIM Integration

```markdown
⟨npl:fim:vtk⟩
data: medical_volume
rendering: ray_casting
interaction: slice_planes
colormap: jet
⟨/npl:fim:vtk⟩
```

## Key Features
- Volume rendering with GPU ray casting
- DICOM medical image support
- Slice views (axial, sagittal, coronal)
- Surface extraction and contouring
- Scientific colormaps

## Best Practices
- Use LOD for large datasets
- Implement progressive loading
- Cache intermediate representations
- GPU memory management for volumes