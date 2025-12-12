"""Visual diff generation using pixelmatch algorithm.

Pure Python implementation of pixel-by-pixel image comparison
for visual regression testing.
"""

from dataclasses import dataclass
from enum import Enum
from typing import Tuple, Optional
from io import BytesIO

from PIL import Image


class DiffStatus(str, Enum):
    """Classification of visual diff severity."""
    IDENTICAL = "identical"  # 0% diff
    MINOR = "minor"          # 0.01% - 1%
    MODERATE = "moderate"    # 1% - 5%
    MAJOR = "major"          # > 5%


@dataclass
class DiffResult:
    """Result of visual comparison."""
    diff_image: bytes  # PNG bytes of diff visualization
    diff_percentage: float
    diff_pixels: int
    total_pixels: int
    dimensions_match: bool
    status: DiffStatus
    baseline_dimensions: Tuple[int, int]
    comparison_dimensions: Tuple[int, int]


def classify_diff(percentage: float) -> DiffStatus:
    """Classify diff percentage into severity status.

    Args:
        percentage: Percentage of pixels that differ (0-100)

    Returns:
        DiffStatus classification
    """
    if percentage == 0:
        return DiffStatus.IDENTICAL
    elif percentage < 1:
        return DiffStatus.MINOR
    elif percentage < 5:
        return DiffStatus.MODERATE
    else:
        return DiffStatus.MAJOR


def color_distance_yiq(
    r1: int, g1: int, b1: int,
    r2: int, g2: int, b2: int
) -> float:
    """Calculate perceptual color distance using YIQ color space.

    YIQ weights luminance (Y) more heavily than chrominance (I, Q),
    better matching human perception of color differences.

    Args:
        r1, g1, b1: First color RGB values (0-255)
        r2, g2, b2: Second color RGB values (0-255)

    Returns:
        Color distance (0 = identical, higher = more different)
    """
    # Convert to YIQ
    y1 = r1 * 0.29889531 + g1 * 0.58662247 + b1 * 0.11448223
    i1 = r1 * 0.59597799 - g1 * 0.27417610 - b1 * 0.32180189
    q1 = r1 * 0.21147017 - g1 * 0.52261711 + b1 * 0.31114694

    y2 = r2 * 0.29889531 + g2 * 0.58662247 + b2 * 0.11448223
    i2 = r2 * 0.59597799 - g2 * 0.27417610 - b2 * 0.32180189
    q2 = r2 * 0.21147017 - g2 * 0.52261711 + b2 * 0.31114694

    # Weighted distance (Y matters more)
    dy = y1 - y2
    di = i1 - i2
    dq = q1 - q2

    return 0.5053 * dy * dy + 0.299 * di * di + 0.1957 * dq * dq


def is_antialiased(
    pixels: bytes,
    x: int,
    y: int,
    width: int,
    height: int,
    other_pixels: bytes
) -> bool:
    """Check if a pixel is likely part of anti-aliasing.

    Examines neighboring pixels to detect anti-aliasing edges.

    Args:
        pixels: RGBA pixel data
        x, y: Pixel coordinates
        width, height: Image dimensions
        other_pixels: RGBA data of comparison image

    Returns:
        True if pixel appears to be anti-aliased
    """
    # Check a 3x3 neighborhood
    zeros = 0
    min_delta = 0.0
    max_delta = 0.0

    idx = (y * width + x) * 4
    r, g, b = pixels[idx], pixels[idx + 1], pixels[idx + 2]

    for dy in range(-1, 2):
        for dx in range(-1, 2):
            if dx == 0 and dy == 0:
                continue

            nx, ny = x + dx, y + dy
            if nx < 0 or nx >= width or ny < 0 or ny >= height:
                continue

            nidx = (ny * width + nx) * 4

            # Check same image
            nr, ng, nb = pixels[nidx], pixels[nidx + 1], pixels[nidx + 2]
            delta = color_distance_yiq(r, g, b, nr, ng, nb)

            if delta == 0:
                zeros += 1
            if delta < min_delta:
                min_delta = delta
            if delta > max_delta:
                max_delta = delta

            # Check other image
            onr, ong, onb = other_pixels[nidx], other_pixels[nidx + 1], other_pixels[nidx + 2]
            delta = color_distance_yiq(r, g, b, onr, ong, onb)

            if delta == 0:
                zeros += 1
            if delta < min_delta:
                min_delta = delta
            if delta > max_delta:
                max_delta = delta

    # Anti-aliased pixels have few identical neighbors and moderate range
    if zeros > 2:
        return False
    if min_delta == 0 and max_delta == 0:
        return False

    return (max_delta - min_delta) > 50


def pixelmatch(
    img1_rgba: bytes,
    img2_rgba: bytes,
    width: int,
    height: int,
    threshold: float = 0.1,
    include_aa: bool = False,
    diff_color: Tuple[int, int, int] = (255, 0, 0),
    aa_color: Tuple[int, int, int] = (255, 165, 0),
) -> Tuple[int, bytearray]:
    """Compare two images pixel by pixel.

    Args:
        img1_rgba: First image RGBA pixel data
        img2_rgba: Second image RGBA pixel data
        width: Image width
        height: Image height
        threshold: Color sensitivity (0.0 = exact, 1.0 = very tolerant)
        include_aa: Count anti-aliased pixels as differences
        diff_color: RGB color for different pixels (default: red)
        aa_color: RGB color for anti-aliased pixels (default: orange)

    Returns:
        Tuple of (diff_pixel_count, diff_image_rgba)
    """
    # Scale threshold to color distance range
    max_delta = 35215  # Max YIQ distance for extreme colors
    threshold_sq = threshold * threshold * max_delta

    # Output image
    output = bytearray(width * height * 4)
    diff_count = 0

    for y in range(height):
        for x in range(width):
            idx = (y * width + x) * 4

            r1, g1, b1, a1 = img1_rgba[idx:idx + 4]
            r2, g2, b2, a2 = img2_rgba[idx:idx + 4]

            # Calculate color distance
            delta = color_distance_yiq(r1, g1, b1, r2, g2, b2)

            if delta > threshold_sq:
                # Check anti-aliasing
                if not include_aa and (
                    is_antialiased(img1_rgba, x, y, width, height, img2_rgba) or
                    is_antialiased(img2_rgba, x, y, width, height, img1_rgba)
                ):
                    # Mark as AA diff (orange)
                    output[idx] = aa_color[0]
                    output[idx + 1] = aa_color[1]
                    output[idx + 2] = aa_color[2]
                    output[idx + 3] = 255
                else:
                    # Mark as real diff (red)
                    output[idx] = diff_color[0]
                    output[idx + 1] = diff_color[1]
                    output[idx + 2] = diff_color[2]
                    output[idx + 3] = 255
                    diff_count += 1
            else:
                # No difference - show dimmed original
                output[idx] = r1 // 3
                output[idx + 1] = g1 // 3
                output[idx + 2] = b1 // 3
                output[idx + 3] = 255

    return diff_count, output


def compare_screenshots(
    baseline_bytes: bytes,
    comparison_bytes: bytes,
    threshold: float = 0.1,
    include_aa: bool = False,
) -> DiffResult:
    """Compare two screenshot images.

    Args:
        baseline_bytes: PNG bytes of baseline screenshot
        comparison_bytes: PNG bytes of comparison screenshot
        threshold: Color sensitivity (0.0 = exact, 1.0 = very tolerant)
        include_aa: Count anti-aliased pixels as differences

    Returns:
        DiffResult with diff image and statistics

    Raises:
        ValueError: If images cannot be loaded
    """
    # Load images
    try:
        baseline_img = Image.open(BytesIO(baseline_bytes)).convert("RGBA")
        comparison_img = Image.open(BytesIO(comparison_bytes)).convert("RGBA")
    except Exception as e:
        raise ValueError(f"Failed to load images: {e}")

    baseline_dims = (baseline_img.width, baseline_img.height)
    comparison_dims = (comparison_img.width, comparison_img.height)

    # Check dimension match
    if baseline_dims != comparison_dims:
        # Create a diff image showing the mismatch
        max_width = max(baseline_dims[0], comparison_dims[0])
        max_height = max(baseline_dims[1], comparison_dims[1])

        diff_img = Image.new("RGBA", (max_width, max_height), (128, 0, 128, 255))

        # Save diff image
        diff_buffer = BytesIO()
        diff_img.save(diff_buffer, format="PNG")

        return DiffResult(
            diff_image=diff_buffer.getvalue(),
            diff_percentage=100.0,
            diff_pixels=max_width * max_height,
            total_pixels=max_width * max_height,
            dimensions_match=False,
            status=DiffStatus.MAJOR,
            baseline_dimensions=baseline_dims,
            comparison_dimensions=comparison_dims,
        )

    # Get pixel data
    width, height = baseline_dims
    baseline_rgba = baseline_img.tobytes()
    comparison_rgba = comparison_img.tobytes()

    # Run pixelmatch
    diff_count, diff_rgba = pixelmatch(
        baseline_rgba,
        comparison_rgba,
        width,
        height,
        threshold=threshold,
        include_aa=include_aa,
    )

    # Create diff image
    diff_img = Image.frombytes("RGBA", (width, height), bytes(diff_rgba))
    diff_buffer = BytesIO()
    diff_img.save(diff_buffer, format="PNG", compress_level=6)

    # Calculate statistics
    total_pixels = width * height
    diff_percentage = (diff_count / total_pixels) * 100 if total_pixels > 0 else 0
    status = classify_diff(diff_percentage)

    return DiffResult(
        diff_image=diff_buffer.getvalue(),
        diff_percentage=round(diff_percentage, 4),
        diff_pixels=diff_count,
        total_pixels=total_pixels,
        dimensions_match=True,
        status=status,
        baseline_dimensions=baseline_dims,
        comparison_dimensions=comparison_dims,
    )
