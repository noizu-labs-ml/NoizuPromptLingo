# Media Processing
Generate code and workflows for image, audio, and video manipulation tasks.
[FFmpeg Documentation](https://ffmpeg.org/documentation.html) | [PIL Documentation](https://pillow.readthedocs.io/)

## WWHW
**What**: Create scripts and workflows for media file processing and manipulation
**Why**: Automate media workflows, batch processing, format conversion, optimization
**How**: Generate FFmpeg commands, Python PIL/OpenCV code, batch processing scripts
**When**: Media pipeline development, content optimization, automated processing

## When to Use
- Batch image resizing and optimization
- Video format conversion and compression
- Audio processing and normalization
- Automated thumbnail generation
- Media metadata extraction and manipulation

## Key Outputs
`ffmpeg-commands`, `python-scripts`, `batch-workflows`, `optimization-configs`

## Quick Example
```bash
# Video conversion with optimization
ffmpeg -i input.mp4 \
  -c:v libx264 -preset medium -crf 23 \
  -c:a aac -b:a 128k \
  -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" \
  output.mp4

# Python image processing
from PIL import Image
import os

def batch_resize(input_dir, output_dir, size=(800, 600)):
    for filename in os.listdir(input_dir):
        if filename.lower().endswith(('.png', '.jpg', '.jpeg')):
            img = Image.open(os.path.join(input_dir, filename))
            img.thumbnail(size, Image.Resampling.LANCZOS)
            img.save(os.path.join(output_dir, filename), optimize=True)
```

## Extended Reference
- [OpenCV Python Tutorials](https://docs.opencv.org/4.x/d6/d00/tutorial_py_root.html)
- [MoviePy Documentation](https://moviepy.readthedocs.io/)
- [ImageMagick Command Line](https://imagemagick.org/script/command-line-tools.php)
- [Digital Image Processing by Gonzalez](https://www.amazon.com/Digital-Image-Processing-Rafael-Gonzalez/dp/0133356728)
- [FFmpeg Filters Documentation](https://ffmpeg.org/ffmpeg-filters.html)