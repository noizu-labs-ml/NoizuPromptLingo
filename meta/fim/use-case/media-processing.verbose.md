# NPL-FIM Media Processing Implementation Guide

## Overview
Comprehensive implementation guide for media processing using FFmpeg, Python PIL/OpenCV, and ImageMagick. Focus on practical commands and code samples for production-ready media workflows.

## Dependencies & Setup

### Core Requirements
```bash
# FFmpeg 6.0+ with codecs
sudo apt-get install ffmpeg libx264-dev libvpx-dev libopus-dev
ffmpeg -version  # Verify: ffmpeg version 6.0 or higher

# Python 3.10+ with media libraries
pip install Pillow==10.2.0 opencv-python==4.9.0 moviepy==1.0.3
pip install numpy==1.24.3 scipy==1.11.4 scikit-image==0.22.0

# ImageMagick 7.1+ with policy.xml configured
sudo apt-get install imagemagick libmagickwand-dev
convert -version  # Verify: ImageMagick 7.1.0 or higher
```

### Policy Configuration
```xml
<!-- /etc/ImageMagick-7/policy.xml adjustments -->
<policy domain="resource" name="memory" value="2GiB"/>
<policy domain="resource" name="disk" value="10GiB"/>
<policy domain="coder" rights="read|write" pattern="PDF" />
```

## FFmpeg Command Patterns

### Image Processing
```bash
# Basic crop - center 1920x1080 from 4K source
ffmpeg -i input.jpg -vf "crop=1920:1080" output.jpg

# Advanced resize with quality preservation
ffmpeg -i input.png -vf "scale=1920:1080:flags=lanczos" -q:v 2 output.jpg

# Batch convert with metadata preservation
for f in *.png; do
  ffmpeg -i "$f" -q:v 2 -metadata comment="Processed $(date)" "${f%.png}.jpg"
done

# Multi-format thumbnail generation
ffmpeg -i input.mp4 -ss 00:00:10 -vframes 1 -vf "scale=320:-1" thumb.jpg
```

### Video Transcoding
```bash
# H.264 optimization for web delivery
ffmpeg -i input.mov -c:v libx264 -preset slow -crf 23 \
  -c:a aac -b:a 128k -movflags +faststart output.mp4

# H.265/HEVC for 50% smaller files
ffmpeg -i input.mp4 -c:v libx265 -crf 28 -preset medium \
  -tag:v hvc1 -c:a copy output_hevc.mp4

# Adaptive bitrate ladder for streaming
ffmpeg -i input.mp4 \
  -map 0:v -map 0:a -c:v libx264 -preset fast \
  -b:v:0 5000k -maxrate:v:0 5350k -bufsize:v:0 7500k -s:v:0 1920x1080 \
  -b:v:1 2800k -maxrate:v:1 2996k -bufsize:v:1 4200k -s:v:1 1280x720 \
  -b:v:2 1400k -maxrate:v:2 1498k -bufsize:v:2 2100k -s:v:2 854x480 \
  -c:a aac -b:a 128k output_%v.mp4
```

### Audio Processing
```bash
# Normalize audio levels
ffmpeg -i input.mp3 -af loudnorm=I=-16:TP=-1.5:LRA=11 output.mp3

# Extract and convert audio
ffmpeg -i video.mp4 -vn -acodec libopus -b:a 96k audio.opus

# Merge audio tracks with ducking
ffmpeg -i voice.wav -i music.mp3 -filter_complex \
  "[1:a]volume=0.3[bg];[0:a][bg]amix=inputs=2:duration=shortest" \
  output.mp3
```

## Python PIL Implementation

### Basic Image Operations
```python
from PIL import Image, ImageEnhance, ImageFilter
import os

def process_image(input_path, output_path):
    """Complete image processing pipeline"""
    with Image.open(input_path) as img:
        # Convert to RGB if needed
        if img.mode != 'RGB':
            img = img.convert('RGB')

        # Smart crop to aspect ratio
        target_ratio = 16/9
        width, height = img.size
        current_ratio = width/height

        if current_ratio > target_ratio:
            # Too wide
            new_width = int(height * target_ratio)
            left = (width - new_width) // 2
            img = img.crop((left, 0, left + new_width, height))
        elif current_ratio < target_ratio:
            # Too tall
            new_height = int(width / target_ratio)
            top = (height - new_height) // 2
            img = img.crop((0, top, width, top + new_height))

        # High-quality resize
        img = img.resize((1920, 1080), Image.Resampling.LANCZOS)

        # Enhancement pipeline
        enhancer = ImageEnhance.Sharpness(img)
        img = enhancer.enhance(1.2)

        enhancer = ImageEnhance.Contrast(img)
        img = enhancer.enhance(1.1)

        # Save with optimization
        img.save(output_path, 'JPEG', quality=92, optimize=True)

    return output_path

# Batch processing with progress
def batch_process(input_dir, output_dir):
    os.makedirs(output_dir, exist_ok=True)

    for filename in os.listdir(input_dir):
        if filename.lower().endswith(('.jpg', '.jpeg', '.png')):
            input_path = os.path.join(input_dir, filename)
            output_path = os.path.join(output_dir, f"processed_{filename}")
            process_image(input_path, output_path)
            print(f"Processed: {filename}")
```

### Advanced PIL Filters
```python
def apply_watermark(image_path, watermark_path, output_path):
    """Add watermark with transparency"""
    base = Image.open(image_path).convert('RGBA')
    watermark = Image.open(watermark_path).convert('RGBA')

    # Scale watermark to 10% of base image
    ratio = min(base.size) * 0.1 / max(watermark.size)
    new_size = tuple(int(dim * ratio) for dim in watermark.size)
    watermark = watermark.resize(new_size, Image.Resampling.LANCZOS)

    # Position at bottom-right with padding
    position = (base.width - watermark.width - 20,
                base.height - watermark.height - 20)

    # Composite with alpha
    base.paste(watermark, position, watermark)
    base.save(output_path, 'PNG')
```

## OpenCV Video Processing

### Real-time Video Pipeline
```python
import cv2
import numpy as np

def process_video_stream(input_path, output_path):
    """Frame-by-frame video processing"""
    cap = cv2.VideoCapture(input_path)

    # Get video properties
    fps = int(cap.get(cv2.CAP_PROP_FPS))
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

    # Setup output with H.264 codec
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(output_path, fourcc, fps, (width, height))

    frame_count = 0
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        # Apply processing
        frame = cv2.bilateralFilter(frame, 9, 75, 75)  # Denoise
        frame = cv2.convertScaleAbs(frame, alpha=1.1, beta=10)  # Brightness/contrast

        # Edge enhancement
        kernel = np.array([[-1,-1,-1],
                          [-1, 9,-1],
                          [-1,-1,-1]])
        frame = cv2.filter2D(frame, -1, kernel)

        out.write(frame)
        frame_count += 1

        if frame_count % 30 == 0:
            print(f"Processed {frame_count} frames")

    cap.release()
    out.release()
    cv2.destroyAllWindows()

def extract_frames(video_path, output_dir, interval=30):
    """Extract frames at specified intervals"""
    os.makedirs(output_dir, exist_ok=True)
    cap = cv2.VideoCapture(video_path)

    frame_num = 0
    saved = 0

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        if frame_num % interval == 0:
            output_path = os.path.join(output_dir, f"frame_{frame_num:06d}.jpg")
            cv2.imwrite(output_path, frame)
            saved += 1

        frame_num += 1

    cap.release()
    print(f"Extracted {saved} frames")
```

## ImageMagick Advanced Operations

### Complex Image Manipulation
```bash
# Create photo montage with labels
montage *.jpg -tile 4x3 -geometry 200x150+5+5 \
  -label '%f' -pointsize 10 montage.jpg

# Advanced color correction
convert input.jpg -modulate 100,120 -auto-level \
  -unsharp 0x1+1+0.05 output.jpg

# Batch resize with aspect preservation
mogrify -resize 1920x1080 -background white -gravity center \
  -extent 1920x1080 -quality 90 *.jpg

# Create animated GIF from video
convert input.mp4[0-100] -resize 480x -delay 10 -loop 0 output.gif
```

### Python ImageMagick Integration
```python
from wand.image import Image as WandImage
from wand.display import display

def advanced_transform(input_path, output_path):
    """Complex transformations with ImageMagick"""
    with WandImage(filename=input_path) as img:
        # Liquid rescale (content-aware resizing)
        img.liquid_rescale(width=int(img.width*0.5),
                          height=int(img.height*0.5))

        # Advanced blur with mask
        img.blur(radius=0, sigma=3)

        # Color quantization
        img.quantize(number_colors=256, colorspace='rgb',
                    treedepth=0, dither=True)

        img.save(filename=output_path)
```

## Production Pipeline Examples

### Complete Media Workflow
```python
import subprocess
import json

class MediaPipeline:
    """Production-ready media processing pipeline"""

    def __init__(self):
        self.ffmpeg_path = 'ffmpeg'
        self.ffprobe_path = 'ffprobe'

    def analyze_media(self, input_path):
        """Get comprehensive media information"""
        cmd = [
            self.ffprobe_path, '-v', 'error',
            '-show_format', '-show_streams',
            '-print_format', 'json', input_path
        ]

        result = subprocess.run(cmd, capture_output=True, text=True)
        return json.loads(result.stdout)

    def optimize_for_web(self, input_path, output_path):
        """Web-optimized video conversion"""
        # Analyze source
        info = self.analyze_media(input_path)
        duration = float(info['format']['duration'])

        # Calculate optimal bitrate
        target_size_mb = min(100, duration * 0.5)  # 0.5 MB per second max
        bitrate = int((target_size_mb * 8192) / duration)

        cmd = [
            self.ffmpeg_path, '-i', input_path,
            '-c:v', 'libx264', '-preset', 'medium',
            '-b:v', f'{bitrate}k', '-maxrate', f'{int(bitrate*1.5)}k',
            '-bufsize', f'{bitrate*2}k',
            '-c:a', 'aac', '-b:a', '128k',
            '-movflags', '+faststart',
            '-y', output_path
        ]

        subprocess.run(cmd, check=True)
        return output_path

    def generate_preview(self, video_path, output_dir):
        """Create preview assets"""
        os.makedirs(output_dir, exist_ok=True)

        # Thumbnail at 10%
        cmd = [
            self.ffmpeg_path, '-i', video_path,
            '-ss', '00:00:05', '-vframes', '1',
            '-vf', 'scale=640:-1',
            os.path.join(output_dir, 'thumbnail.jpg')
        ]
        subprocess.run(cmd, check=True)

        # Animated preview
        cmd = [
            self.ffmpeg_path, '-i', video_path,
            '-vf', 'fps=10,scale=320:-1', '-t', '5',
            os.path.join(output_dir, 'preview.gif')
        ]
        subprocess.run(cmd, check=True)

# Usage
pipeline = MediaPipeline()
pipeline.optimize_for_web('input.mov', 'output.mp4')
pipeline.generate_preview('output.mp4', 'previews/')
```

### Parallel Batch Processing
```python
from concurrent.futures import ProcessPoolExecutor
import multiprocessing

def parallel_image_processing(input_dir, output_dir, max_workers=None):
    """High-performance parallel processing"""
    if max_workers is None:
        max_workers = multiprocessing.cpu_count()

    files = [f for f in os.listdir(input_dir)
             if f.lower().endswith(('.jpg', '.png'))]

    def process_single(filename):
        input_path = os.path.join(input_dir, filename)
        output_path = os.path.join(output_dir, f"proc_{filename}")

        # Your processing logic here
        process_image(input_path, output_path)
        return filename

    with ProcessPoolExecutor(max_workers=max_workers) as executor:
        results = list(executor.map(process_single, files))

    print(f"Processed {len(results)} files using {max_workers} workers")
```

## Performance Optimization Tips

1. **Memory Management**: Use streaming for large files, process in chunks
2. **GPU Acceleration**: Enable NVENC/VAAPI for hardware encoding
3. **Caching Strategy**: Implement LRU cache for frequently accessed media
4. **Format Selection**: Choose optimal codecs (H.265 for size, H.264 for compatibility)
5. **Progressive Enhancement**: Generate multiple quality levels for adaptive delivery

This implementation guide provides production-ready code for immediate use in media processing workflows.