# FFmpeg.wasm
## Video Processing in the Browser

### Description
FFmpeg.wasm is a WebAssembly port of FFmpeg, enabling comprehensive video and audio processing directly in web browsers without server-side infrastructure.

**Repository**: https://github.com/ffmpegwasm/ffmpeg.wasm

### Installation
```bash
npm install @ffmpeg/ffmpeg @ffmpeg/core
```

### Loading and Initialization
```javascript
import { FFmpeg } from '@ffmpeg/ffmpeg';
import { fetchFile, toBlobURL } from '@ffmpeg/util';

const ffmpeg = new FFmpeg();
await ffmpeg.load({
  coreURL: await toBlobURL(baseURL + 'ffmpeg-core.js', 'text/javascript'),
  wasmURL: await toBlobURL(baseURL + 'ffmpeg-core.wasm', 'application/wasm'),
});
```

### Video Conversion Example
```javascript
// Convert video to GIF
await ffmpeg.writeFile('input.mp4', await fetchFile(videoFile));
await ffmpeg.exec(['-i', 'input.mp4', '-vf', 'fps=10,scale=320:-1', 'output.gif']);
const data = await ffmpeg.readFile('output.gif');
const url = URL.createObjectURL(new Blob([data.buffer], { type: 'image/gif' }));
```

### Strengths
- **Full FFmpeg Power**: Complete FFmpeg functionality in browser
- **No Server Required**: Entirely client-side processing
- **Privacy-First**: User data never leaves their device
- **Broad Format Support**: Handles virtually all media formats
- **Command-Line Compatible**: Uses familiar FFmpeg syntax

### Limitations
- **Large Download**: Core WASM file ~30MB
- **Performance**: Slower than native FFmpeg (typically 2-10x)
- **Memory Constraints**: Limited by browser memory allocation
- **Thread Limitations**: Single-threaded in most browsers

### Best For
- **Client-Side Video Processing**: Trimming, conversion, compression
- **Privacy-Sensitive Applications**: Medical, legal, personal content
- **Offline-First Apps**: Progressive web applications
- **Quick Prototypes**: Testing video workflows without backend

### NPL-FIM Integration Pattern
```yaml
fim_interface: ffmpeg-wasm
processor_type: video
execution_context: browser
capabilities:
  - transcode
  - filter
  - extract_frames
  - generate_thumbnails
  - audio_processing
constraints:
  max_file_size: 2GB
  threading: single
  performance_ratio: 0.1-0.5x_native
```

### Quick Start Template
```javascript
async function processVideo(inputFile) {
  const ffmpeg = new FFmpeg();
  await ffmpeg.load();
  await ffmpeg.writeFile('input.mp4', await fetchFile(inputFile));
  await ffmpeg.exec(['-i', 'input.mp4', '-c:v', 'libx264', '-preset', 'fast', 'output.mp4']);
  return await ffmpeg.readFile('output.mp4');
}
```