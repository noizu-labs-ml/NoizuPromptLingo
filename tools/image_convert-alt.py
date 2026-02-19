#!/usr/bin/env python3
"""
image_convert.py — Convert images to ASCII art or SVG via an agentic loop.

Modes:
  ascii   Render image as Unicode block characters (██░▓▒) at X×Y resolution
  svg     Agentic loop: AI draws SVG layers over a background image iteratively

Usage:
  python tools/image_convert.py ascii input.png                              # 80 cols, rows from aspect ratio
  python tools/image_convert.py ascii input.png --max-cols 120               # wider
  python tools/image_convert.py ascii input.png --max-cols 80 --max-rows 30  # fit in 80×30 box
  python tools/image_convert.py ascii input.png --max-cols 120 --charset braille
  python tools/image_convert.py ascii input.png --char-ratio 2.0             # correct for tall terminal chars
  python tools/image_convert.py svg input.png --output out.svg --iterations 20
  python tools/image_convert.py svg input.png --output out.svg --detail high --model claude-sonnet-4-5-20250929
"""

from __future__ import annotations

import argparse
import base64
import copy
import io
import json
import math
import os
import random
import re
import sys
import textwrap
import time
import uuid
import xml.etree.ElementTree as ET
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Optional

from PIL import Image, ImageDraw, ImageFilter, ImageFont

# ---------------------------------------------------------------------------
# Ensure cairocffi can find homebrew's libcairo on macOS
# ---------------------------------------------------------------------------
if sys.platform == "darwin" and "DYLD_FALLBACK_LIBRARY_PATH" not in os.environ:
    _brew_lib = Path("/opt/homebrew/lib")
    if not _brew_lib.exists():
        _brew_lib = Path("/usr/local/lib")
    if _brew_lib.exists():
        os.environ["DYLD_FALLBACK_LIBRARY_PATH"] = str(_brew_lib)

# ---------------------------------------------------------------------------
# ASCII MODE
# ---------------------------------------------------------------------------

# Unicode block charsets ordered dark → light
CHARSETS: dict[str, str] = {
    "blocks": "██▓▓▒▒░░  ",
    "blocks_extended": "████▓▓▓▒▒▒░░░    ",
    "ascii": "@%#*+=-:. ",
    "ascii_extended": "$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\\|()1{}[]?-_+~<>i!lI;:,\"^`'. ",
    "braille": None,  # special: uses 2×4 braille subpixels
}


def image_to_grayscale(img: Image.Image, width: int, height: int) -> list[list[int]]:
    """Resize and convert to grayscale, return 2D array of 0-255 values."""
    resized = img.convert("L").resize((width, height), Image.Resampling.LANCZOS)
    pixels = list(resized.getdata())
    return [pixels[i * width : (i + 1) * width] for i in range(height)]


def grayscale_to_blocks(gray: list[list[int]], charset_name: str = "blocks") -> str:
    """Map grayscale pixels to unicode block characters."""
    chars = CHARSETS[charset_name]
    scale = len(chars) - 1
    lines = []
    for row in gray:
        line = "".join(chars[min(int(p / 255 * scale), scale)] for p in row)
        lines.append(line)
    return "\n".join(lines)


def grayscale_to_braille(img: Image.Image, cols: int, rows: int) -> str:
    """Render image using 2×4 Braille subpixel characters.

    Each braille char represents a 2×4 pixel block, so the actual
    sample resolution is (cols*2) × (rows*4).
    """
    w, h = cols * 2, rows * 4
    resized = img.convert("L").resize((w, h), Image.Resampling.LANCZOS)
    pixels = list(resized.getdata())

    # Braille dot positions: each char encodes a 2×4 grid
    # Dot numbering (col, row) → bit:
    # (0,0)→0x01  (1,0)→0x08
    # (0,1)→0x02  (1,1)→0x10
    # (0,2)→0x04  (1,2)→0x20
    # (0,3)→0x40  (1,3)→0x80
    DOT_MAP = [
        [0x01, 0x08],
        [0x02, 0x10],
        [0x04, 0x20],
        [0x40, 0x80],
    ]

    threshold = 128
    lines = []
    for by in range(rows):
        line = []
        for bx in range(cols):
            code = 0x2800  # braille blank
            for dy in range(4):
                for dx in range(2):
                    px = bx * 2 + dx
                    py = by * 4 + dy
                    if py < h and px < w:
                        idx = py * w + px
                        if pixels[idx] < threshold:  # dark pixel = dot on
                            code |= DOT_MAP[dy][dx]
            line.append(chr(code))
        lines.append("".join(line))
    return "\n".join(lines)


def compute_dimensions(
    img_width: int, img_height: int,
    max_cols: int | None = None, max_rows: int | None = None,
    char_ratio: float = 1.0,
) -> tuple[int, int]:
    """Compute output cols×rows preserving aspect ratio.

    Fits within max_cols and max_rows while keeping the image's aspect ratio.
    char_ratio adjusts for non-square terminal characters (e.g., 2.0 means
    chars are twice as tall as wide — halves the row count).

    If only max_cols is given: rows = img_height * (max_cols / img_width) / char_ratio
    If only max_rows is given: cols = img_width * (max_rows / img_height) * char_ratio
    If both: fit within whichever is the tighter constraint.
    """
    max_cols = max_cols or 80
    aspect = img_width / img_height

    # Cols from max_cols, derive rows
    cols = max_cols
    rows = round(cols / aspect / char_ratio)

    # If max_rows set and we exceed it, constrain by rows instead
    if max_rows and rows > max_rows:
        rows = max_rows
        cols = round(rows * aspect * char_ratio)

    return max(cols, 1), max(rows, 1)


def auto_blur_radius(img_width: int, img_height: int, out_cols: int, out_rows: int) -> float:
    """Compute a gaussian blur radius based on the downscale ratio.

    The idea: each output cell covers a block of source pixels. Blurring by
    roughly half that block size smooths out noise that can't survive the
    downscale anyway, producing cleaner output.

    Returns 0.0 (no blur) when the output is close to source resolution.
    """
    # How many source pixels per output cell on each axis
    ratio_x = img_width / max(out_cols, 1)
    ratio_y = img_height / max(out_rows, 1)
    ratio = (ratio_x + ratio_y) / 2

    # Below ~2:1 downscale there's nothing to smooth
    if ratio <= 2.0:
        return 0.0
    # radius ≈ half the block size, capped at 12
    return min(ratio * 0.4, 12.0)


def auto_blur_radius_svg(detail: str) -> float:
    """Compute blur radius for SVG mode based on detail preset."""
    return {"low": 4.0, "medium": 2.0, "high": 1.0, "ultra": 0.0}.get(detail, 2.0)


def apply_blur(img: Image.Image, radius: float) -> Image.Image:
    """Apply gaussian blur if radius > 0."""
    if radius > 0:
        return img.filter(ImageFilter.GaussianBlur(radius=radius))
    return img


def generate_edge_svg_paths(img: Image.Image, width: int, height: int,
                            work_dir: Path) -> list[dict[str, str]]:
    """Generate vectorized edge contours from the image using potrace.

    Returns a list of SVG path attribute dicts (each has "d", "stroke", etc.)
    ready to be added as elements to the canvas.
    """
    import shutil
    import subprocess

    resized = img.resize((width, height), Image.Resampling.LANCZOS)
    gray = resized.convert("L")
    # Blur to reduce noise, then edge detect
    smoothed = gray.filter(ImageFilter.GaussianBlur(radius=1.0))
    edges = smoothed.filter(ImageFilter.FIND_EDGES)
    # Threshold to binary (potrace needs BMP with black/white)
    from PIL import ImageOps
    edges = ImageOps.autocontrast(edges, cutoff=5)
    binary = edges.point(lambda p: 0 if p > 128 else 255, mode="1")

    bmp_path = work_dir / "edges.bmp"
    svg_path = work_dir / "edges.svg"
    binary.save(str(bmp_path))

    potrace = shutil.which("potrace")
    if not potrace:
        print("Warning: potrace not found, skipping edge guide layer")
        return []

    # Run potrace: BMP → SVG, turdsize filters small specks
    subprocess.run(
        [potrace, str(bmp_path), "-s", "-o", str(svg_path),
         "-t", "15",  # suppress speckles smaller than 15px
         "--flat",    # no grouping, flat path list
         ],
        check=True, capture_output=True,
    )

    # Parse the SVG output and extract paths with potrace's transform
    # Potrace outputs with transform="translate(0,H) scale(0.1,-0.1)" on a <g>,
    # so we wrap our paths in the same transform.
    paths = []
    group_transform = ""
    try:
        tree = ET.parse(str(svg_path))
        root = tree.getroot()
        # Find the <g> with the transform
        for g in root.iter("{http://www.w3.org/2000/svg}g"):
            t = g.get("transform", "")
            if t:
                group_transform = t
                break
        for p in root.iter("{http://www.w3.org/2000/svg}path"):
            d = p.get("d", "")
            if d:
                paths.append({
                    "d": d,
                    "fill": "none",
                    "stroke": "black",
                    "stroke-width": "8",  # scaled down by 0.1 = 0.8 effective
                    "opacity": "0.8",
                })
    except Exception:
        pass

    return paths, group_transform


# ---------------------------------------------------------------------------
# GRID-BASED COARSE SEGMENTATION (Phase 1.5)
# ---------------------------------------------------------------------------


def render_grid_overlay(
    img: Image.Image, w: int, h: int, work_dir: Path,
) -> tuple[str, int, int, float]:
    """Render a labelled grid overlay on the reference image.

    The longest axis gets 50 cells; the shorter axis is proportional.
    Returns ``(base64_png, grid_cols, grid_rows, cell_size)``.
    """
    if w >= h:
        grid_cols = 50
        cell_size = w / grid_cols
        grid_rows = max(1, round(h / cell_size))
    else:
        grid_rows = 50
        cell_size = h / grid_rows
        grid_cols = max(1, round(w / cell_size))

    overlay = img.resize((w, h), Image.Resampling.LANCZOS).convert("RGBA")
    draw = ImageDraw.Draw(overlay)

    # Thin grey lines; bold every 5th cell
    for c in range(grid_cols + 1):
        x = round(c * cell_size)
        lw = 2 if c % 5 == 0 else 1
        clr = (100, 100, 100, 200) if c % 5 == 0 else (150, 150, 150, 100)
        draw.line([(x, 0), (x, h)], fill=clr, width=lw)
    for r in range(grid_rows + 1):
        y = round(r * cell_size)
        lw = 2 if r % 5 == 0 else 1
        clr = (100, 100, 100, 200) if r % 5 == 0 else (150, 150, 150, 100)
        draw.line([(0, y), (w, y)], fill=clr, width=lw)

    # Labels every 5th row/col
    try:
        font = ImageFont.truetype("DejaVuSans.ttf", 9)
    except Exception:
        font = ImageFont.load_default()
    for c in range(0, grid_cols + 1, 5):
        draw.text((round(c * cell_size) + 2, 1), str(c),
                  fill=(255, 255, 255, 255), font=font)
    for r in range(0, grid_rows + 1, 5):
        draw.text((1, round(r * cell_size) + 2), str(r),
                  fill=(255, 255, 255, 255), font=font)

    out_path = work_dir / "grid_overlay.png"
    overlay.save(str(out_path))
    buf = io.BytesIO()
    overlay.save(buf, format="PNG")
    return base64.b64encode(buf.getvalue()).decode(), grid_cols, grid_rows, cell_size


def _build_grid_classification_message(
    img_b64: str, img_mime: str, grid_b64: str,
    markers: list[dict], grid_cols: int, grid_rows: int,
    make_image_block,
) -> tuple[list[dict], dict[str, str]]:
    """Build the API message for grid cell classification.

    Returns ``(content_blocks, legend)`` where *legend* maps single chars
    to marker names.
    """
    chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    legend: dict[str, str] = {}
    legend_lines: list[str] = []
    for i, m in enumerate(markers):
        if i >= len(chars):
            break
        ch = chars[i]
        name = m.get("name", f"marker-{i}")
        legend[ch] = name
        legend_lines.append(f"  {ch} = {name}: {m.get('description', '')}")

    content: list[dict] = []
    content.append({"type": "text", "text": "Reference image:"})
    content.append(make_image_block(img_b64, img_mime))
    content.append({"type": "text", "text": "Grid overlay (cells for classification):"})
    content.append(make_image_block(grid_b64, "image/png"))
    content.append({"type": "text", "text": (
        f"Classify each grid cell ({grid_cols} cols x {grid_rows} rows).\n\n"
        f"Legend — assign one character per cell:\n"
        + "\n".join(legend_lines) + "\n"
        f"  . = background/empty\n"
        f"  / = edge/interface between regions\n\n"
        f"Return ONLY a JSON command:\n"
        f'  {{"cmd": "classify_grid", "grid": "<rows separated by newlines, '
        f'one char per cell>"}}\n\n'
        f"The grid must have exactly {grid_rows} rows, each with exactly "
        f"{grid_cols} characters.\n"
        f"Classify every cell with the character of its dominant visual element."
    )})
    return content, legend


def parse_grid_classification(
    text: str, grid_rows: int, grid_cols: int,
) -> list[list[str]]:
    """Parse a character-grid string into a 2D list of single-char labels."""
    rows = text.strip().split("\n")
    grid: list[list[str]] = []
    for r in rows[:grid_rows]:
        row = list(r[:grid_cols])
        while len(row) < grid_cols:
            row.append(".")
        grid.append(row)
    while len(grid) < grid_rows:
        grid.append(["."] * grid_cols)
    return grid


def find_connected_components(
    grid: list[list[str]], rows: int, cols: int,
) -> dict[str, list[set[tuple[int, int]]]]:
    """BFS flood fill (4-connected) to find connected regions per marker char.

    Skips ``'.'`` (background) and ``'/'`` (edge) cells.
    Returns ``{char: [component_set, ...]}``.
    """
    visited = [[False] * cols for _ in range(rows)]
    components: dict[str, list[set[tuple[int, int]]]] = {}

    for r in range(rows):
        for c in range(cols):
            if visited[r][c]:
                continue
            ch = grid[r][c]
            if ch in (".", "/"):
                visited[r][c] = True
                continue
            component: set[tuple[int, int]] = set()
            queue = [(r, c)]
            visited[r][c] = True
            while queue:
                cr, cc = queue.pop(0)
                component.add((cr, cc))
                for dr, dc in ((-1, 0), (1, 0), (0, -1), (0, 1)):
                    nr, nc = cr + dr, cc + dc
                    if (0 <= nr < rows and 0 <= nc < cols
                            and not visited[nr][nc] and grid[nr][nc] == ch):
                        visited[nr][nc] = True
                        queue.append((nr, nc))
            components.setdefault(ch, []).append(component)

    return components


def trace_component_boundary(
    cells: set[tuple[int, int]], cell_w: float, cell_h: float,
) -> list[tuple[float, float]]:
    """Trace the outer boundary of a connected component of grid cells.

    Collects oriented edge segments from missing neighbours, then chains
    them into the longest closed polygon via endpoint adjacency walking.
    """
    segments: list[tuple[tuple[float, float], tuple[float, float]]] = []
    for r, c in cells:
        x0 = round(c * cell_w, 1)
        y0 = round(r * cell_h, 1)
        x1 = round((c + 1) * cell_w, 1)
        y1 = round((r + 1) * cell_h, 1)
        if (r - 1, c) not in cells:
            segments.append(((x0, y0), (x1, y0)))
        if (r + 1, c) not in cells:
            segments.append(((x1, y1), (x0, y1)))
        if (r, c - 1) not in cells:
            segments.append(((x0, y1), (x0, y0)))
        if (r, c + 1) not in cells:
            segments.append(((x1, y0), (x1, y1)))

    if not segments:
        return []

    start_map: dict[tuple[float, float], list[int]] = {}
    for i, (s, _e) in enumerate(segments):
        start_map.setdefault(s, []).append(i)

    used: set[int] = set()
    best: list[tuple[float, float]] = []

    for start_idx in range(len(segments)):
        if start_idx in used:
            continue
        chain: list[tuple[float, float]] = []
        idx = start_idx
        while idx not in used:
            used.add(idx)
            s, e = segments[idx]
            chain.append(s)
            nxt = None
            for j in start_map.get(e, []):
                if j not in used:
                    nxt = j
                    break
            if nxt is None:
                break
            idx = nxt
        if len(chain) > len(best):
            best = chain

    return best


def simplify_polygon_dp(
    points: list[tuple[float, float]], epsilon: float,
) -> list[tuple[float, float]]:
    """Douglas-Peucker polygon simplification."""
    if len(points) < 3:
        return list(points)

    def _perp_dist(pt, a, b):
        dx, dy = b[0] - a[0], b[1] - a[1]
        if dx == 0 and dy == 0:
            return math.hypot(pt[0] - a[0], pt[1] - a[1])
        t = max(0.0, min(1.0,
                ((pt[0] - a[0]) * dx + (pt[1] - a[1]) * dy) / (dx * dx + dy * dy)))
        return math.hypot(pt[0] - (a[0] + t * dx), pt[1] - (a[1] + t * dy))

    def _dp(pts):
        if len(pts) < 3:
            return pts
        max_d, max_i = 0.0, 0
        for i in range(1, len(pts) - 1):
            d = _perp_dist(pts[i], pts[0], pts[-1])
            if d > max_d:
                max_d, max_i = d, i
        if max_d > epsilon:
            return _dp(pts[: max_i + 1])[:-1] + _dp(pts[max_i:])
        return [pts[0], pts[-1]]

    result = _dp(points)
    if len(result) < 3 and len(points) >= 3:
        return points[:3]
    return result


def sample_region_color(
    img: Image.Image, cells: set[tuple[int, int]],
    cell_w: float, cell_h: float,
) -> str:
    """Average the centre pixel of each cell in *cells*. Returns ``#rrggbb``."""
    px = img.convert("RGB")
    iw, ih = px.size
    rt, gt, bt, n = 0, 0, 0, 0
    for row, col in cells:
        cx = int((col + 0.5) * cell_w)
        cy = int((row + 0.5) * cell_h)
        if 0 <= cx < iw and 0 <= cy < ih:
            r, g, b = px.getpixel((cx, cy))
            rt += r; gt += g; bt += b; n += 1  # noqa: E702
    if n == 0:
        return "#888888"
    return f"#{rt // n:02x}{gt // n:02x}{bt // n:02x}"


def polygon_to_svg_path(vertices: list[tuple[float, float]]) -> str:
    """Convert a vertex list to an SVG path ``d`` attribute (``M…L…Z``)."""
    if not vertices:
        return ""
    parts = [f"M{vertices[0][0]:.1f},{vertices[0][1]:.1f}"]
    for x, y in vertices[1:]:
        parts.append(f"L{x:.1f},{y:.1f}")
    parts.append("Z")
    return " ".join(parts)


# --- Contour-snapping helpers ------------------------------------------------


def _extract_svg_path_coords(d: str) -> list[tuple[float, float]]:
    """Extract all coordinate pairs from an SVG path ``d`` attribute.

    Returns every (x, y) pair found in the path data.  For cubic beziers
    this includes control points which are close to the curve and serve as
    reasonable snap targets.
    """
    nums = re.findall(r"-?\d+\.?\d*", d)
    return [(float(nums[i]), float(nums[i + 1]))
            for i in range(0, len(nums) - 1, 2)]


def _parse_svg_transform(transform_str: str):
    """Parse ``translate(tx,ty) scale(sx,sy)`` and return a callable.

    The returned function maps ``list[tuple[float,float]]`` →
    ``list[tuple[float,float]]`` applying the SVG transform
    (scale first, then translate).
    """
    tx, ty = 0.0, 0.0
    sx, sy = 1.0, 1.0
    m = re.search(r"translate\(\s*([^,\s]+)[,\s]+([^)\s]+)\s*\)", transform_str)
    if m:
        tx, ty = float(m.group(1)), float(m.group(2))
    m = re.search(r"scale\(\s*([^,\s]+)(?:[,\s]+([^)\s]+))?\s*\)", transform_str)
    if m:
        sx = float(m.group(1))
        sy = float(m.group(2)) if m.group(2) else sx

    def apply(pts: list[tuple[float, float]]) -> list[tuple[float, float]]:
        return [(sx * x + tx, sy * y + ty) for x, y in pts]
    return apply


def snap_vertices_to_contours(
    vertices: list[tuple[float, float]],
    contour_points: list[tuple[float, float]],
    max_dist: float,
) -> list[tuple[float, float]]:
    """Move each vertex to the nearest contour point within *max_dist*."""
    if not contour_points:
        return vertices
    snapped: list[tuple[float, float]] = []
    for vx, vy in vertices:
        best_d = max_dist
        best = (vx, vy)
        for cx, cy in contour_points:
            d = math.hypot(vx - cx, vy - cy)
            if d < best_d:
                best_d = d
                best = (cx, cy)
        snapped.append(best)
    return snapped


def _collect_contour_points(canvas: SVGCanvas) -> list[tuple[float, float]]:
    """Extract transformed contour vertices from the edge guide layer."""
    contour_points: list[tuple[float, float]] = []
    for lid in canvas.layer_order:
        layer = canvas.layers[lid]
        if layer.name != "edges":
            continue
        # Find the group transform (potrace coordinate mapping)
        edge_transform = ""
        for group in layer.groups.values():
            if group.transform:
                edge_transform = group.transform
                break
        # Extract coordinates from all path elements
        raw_pts: list[tuple[float, float]] = []
        for elem in layer.elements.values():
            if elem.tag == "path":
                raw_pts.extend(_extract_svg_path_coords(elem.attrs.get("d", "")))
        # Apply the potrace transform
        if edge_transform and raw_pts:
            transform_fn = _parse_svg_transform(edge_transform)
            contour_points = transform_fn(raw_pts)
        else:
            contour_points = raw_pts
        break
    return contour_points


# --- Phase 1.5 orchestrator --------------------------------------------------


def _run_grid_segmentation(
    canvas: SVGCanvas, img: Image.Image, w: int, h: int,
    markers: list[dict], work_dir: Path,
    img_b64: str, img_mime: str,
    make_image_block, api_call_fn, extract_text_fn,
    effective_provider: str,
    verbose: bool = True,
) -> int:
    """Phase 1.5 orchestrator — grid classify, trace, snap, place shapes.

    Returns the number of SVG elements added to the canvas.
    """
    # Step 1: grid overlay
    grid_b64, grid_cols, grid_rows, cell_size = render_grid_overlay(
        img, w, h, work_dir)
    cell_w = w / grid_cols
    cell_h = h / grid_rows

    if verbose:
        print(f"\n[Phase 1.5: {grid_cols}x{grid_rows} grid, "
              f"{len(markers)} markers] ", end="", flush=True)

    # Step 2: classify via API
    content, legend = _build_grid_classification_message(
        img_b64, img_mime, grid_b64, markers,
        grid_cols, grid_rows, make_image_block,
    )
    if effective_provider == "openai":
        messages = [
            {"role": "system",
             "content": "You classify grid cells. Return only the JSON command."},
            {"role": "user", "content": content},
        ]
    else:
        messages = [{"role": "user", "content": content}]

    response = api_call_fn(messages)
    text = extract_text_fn(response)

    # Parse classify_grid command
    commands = _parse_commands(text)
    grid_text = None
    for cmd in commands:
        if cmd.get("cmd") == "classify_grid":
            grid_text = cmd.get("grid", "")
            break

    if not grid_text:
        # Fallback: look for grid-like lines in raw text
        candidate = [
            ln.strip() for ln in text.strip().split("\n")
            if ln.strip()
            and len(ln.strip()) >= grid_cols * 0.5
            and all(c.isalnum() or c in "./" for c in ln.strip())
        ]
        if len(candidate) >= grid_rows * 0.5:
            grid_text = "\n".join(candidate)

    if not grid_text:
        if verbose:
            print("(grid classification failed)", end="", flush=True)
        return 0

    if verbose:
        print("G", end="", flush=True)

    # Step 3: parse + connected components
    grid = parse_grid_classification(grid_text, grid_rows, grid_cols)
    components = find_connected_components(grid, grid_rows, grid_cols)

    # Collect contour points from edge layer for vertex snapping
    contour_points = _collect_contour_points(canvas)
    snap_dist = cell_size * 1.5

    # Steps 4-5: trace, simplify, snap, colour-sample, create shapes
    layer_data: list[tuple[float, str, set, str, list]] = []

    for ch, comp_list in components.items():
        marker_name = legend.get(ch, f"region-{ch}")
        for ci, cells in enumerate(comp_list):
            if len(cells) < 3:
                continue
            vertices = trace_component_boundary(cells, cell_w, cell_h)
            if len(vertices) < 3:
                continue
            vertices = simplify_polygon_dp(vertices, cell_size / 2)
            if len(vertices) < 3:
                continue
            # Snap vertices towards nearest edge contour point
            if contour_points:
                vertices = snap_vertices_to_contours(
                    vertices, contour_points, snap_dist)
            color = sample_region_color(img, cells, cell_w, cell_h)
            avg_y = sum(r for r, _c in cells) / len(cells)
            suffix = f"-{ci}" if len(comp_list) > 1 else ""
            layer_data.append((avg_y, f"{marker_name}{suffix}",
                               cells, color, vertices))

    # Sort back-to-front by avg Y (painter's algorithm)
    layer_data.sort(key=lambda x: x[0])

    elements_added = 0
    for _avg_y, name, _cells, color, vertices in layer_data:
        lid = canvas.add_layer(f"grid-{name}", opacity=1.0)
        d = polygon_to_svg_path(vertices)
        canvas.add_element(lid, "path", {
            "d": d,
            "fill": color,
            "stroke": "none",
            "opacity": "0.9",
        }, element_id=f"grid-shape-{name}")
        elements_added += 1

    if verbose:
        print(f" ({elements_added} shapes)", end="", flush=True)

    return elements_added


def run_ascii(
    image_path: str,
    max_cols: int = 80,
    max_rows: int | None = None,
    charset: str = "blocks",
    output: str | None = None,
    invert: bool = False,
    char_ratio: float = 1.0,
    blur: float | None = None,
) -> str:
    """Convert image to ASCII/Unicode art, preserving aspect ratio."""
    img = Image.open(image_path)
    cols, rows = compute_dimensions(img.width, img.height, max_cols, max_rows, char_ratio)

    # Auto-blur based on downscale ratio if not explicitly set
    radius = blur if blur is not None else auto_blur_radius(img.width, img.height, cols, rows)
    if radius > 0:
        img = apply_blur(img, radius)

    if charset == "braille":
        result = grayscale_to_braille(img, cols, rows)
    else:
        gray = image_to_grayscale(img, cols, rows)
        if invert:
            gray = [[255 - p for p in row] for row in gray]
        result = grayscale_to_blocks(gray, charset)

    if output:
        Path(output).write_text(result, encoding="utf-8")
        print(f"Written to {output}")
    else:
        print(result)
    return result


# ---------------------------------------------------------------------------
# SVG LAYER SYSTEM
# ---------------------------------------------------------------------------


@dataclass
class SVGElement:
    """A single SVG element with attributes and optional children."""
    id: str
    tag: str  # rect, circle, ellipse, line, polyline, polygon, path, text, image
    attrs: dict[str, str] = field(default_factory=dict)
    text_content: str = ""
    children: list[SVGElement] = field(default_factory=list)

    def to_xml(self) -> ET.Element:
        el = ET.Element(self.tag, {"id": self.id, **self.attrs})
        if self.text_content:
            el.text = self.text_content
        for child in self.children:
            el.append(child.to_xml())
        return el


@dataclass
class SVGGroup:
    """A group of elements with a shared transform."""
    id: str
    elements: list[str] = field(default_factory=list)  # element IDs
    transform: str = ""
    opacity: float = 1.0


@dataclass
class MetaGroup:
    """A logical group spanning multiple layers (e.g., a house with front, shadow, roof
    across different Z-layers). Allows coordinated transforms on related elements
    regardless of which layer they live in."""
    id: str
    name: str
    members: list[dict] = field(default_factory=list)  # [{"element_id": "...", "layer_id": "..."}, ...]
    transform: str = ""


@dataclass
class SVGLayer:
    """A layer containing elements and groups."""
    id: str
    name: str
    visible: bool = True
    opacity: float = 1.0
    elements: dict[str, SVGElement] = field(default_factory=dict)
    groups: dict[str, SVGGroup] = field(default_factory=dict)
    order: list[str] = field(default_factory=list)  # rendering order (element/group IDs)


class SVGCanvas:
    """Manages a layered SVG document with background image support."""

    def __init__(self, width: int, height: int, background_path: str | None = None):
        self.width = width
        self.height = height
        self.background_path = background_path
        self.layers: dict[str, SVGLayer] = {}
        self.layer_order: list[str] = []
        self._element_registry: dict[str, str] = {}  # element_id → layer_id
        self.meta_groups: dict[str, MetaGroup] = {}  # cross-layer logical groups

    def add_layer(self, name: str, opacity: float = 1.0) -> str:
        lid = f"layer-{uuid.uuid4().hex[:8]}"
        layer = SVGLayer(id=lid, name=name, opacity=max(0.0, min(1.0, opacity)))
        self.layers[lid] = layer
        self.layer_order.append(lid)
        return lid

    def remove_layer(self, layer_id: str) -> None:
        if layer_id in self.layers:
            # Unregister all elements
            for eid in self.layers[layer_id].elements:
                self._element_registry.pop(eid, None)
            del self.layers[layer_id]
            self.layer_order.remove(layer_id)

    def set_layer_visible(self, layer_id: str, visible: bool) -> None:
        self.layers[layer_id].visible = visible

    def set_layer_opacity(self, layer_id: str, opacity: float) -> None:
        self.layers[layer_id].opacity = max(0.0, min(1.0, opacity))

    def reorder_layers(self, order: list[str]) -> None:
        self.layer_order = [lid for lid in order if lid in self.layers]

    def move_layer(self, layer_id: str, direction: str) -> bool:
        """Move a layer up or down one position in the z-order.

        ``direction`` is ``"up"`` (towards foreground / rendered later)
        or ``"down"`` (towards background / rendered earlier).
        Returns True if the layer was moved.
        """
        if layer_id not in self.layer_order:
            return False
        idx = self.layer_order.index(layer_id)
        if direction == "up" and idx < len(self.layer_order) - 1:
            self.layer_order[idx], self.layer_order[idx + 1] = (
                self.layer_order[idx + 1], self.layer_order[idx])
            return True
        if direction == "down" and idx > 0:
            self.layer_order[idx], self.layer_order[idx - 1] = (
                self.layer_order[idx - 1], self.layer_order[idx])
            return True
        return False

    def move_layer_to(self, layer_id: str, position: int) -> bool:
        """Move a layer to a specific z-position (0 = bottom/background)."""
        if layer_id not in self.layer_order:
            return False
        self.layer_order.remove(layer_id)
        pos = max(0, min(position, len(self.layer_order)))
        self.layer_order.insert(pos, layer_id)
        return True

    def add_element(self, layer_id: str, tag: str, attrs: dict[str, str],
                    text_content: str = "", element_id: str | None = None) -> str:
        eid = element_id or f"el-{uuid.uuid4().hex[:8]}"
        elem = SVGElement(id=eid, tag=tag, attrs=attrs, text_content=text_content)
        layer = self.layers[layer_id]
        layer.elements[eid] = elem
        layer.order.append(eid)
        self._element_registry[eid] = layer_id
        return eid

    def remove_element(self, element_id: str) -> None:
        layer_id = self._element_registry.get(element_id)
        if layer_id and layer_id in self.layers:
            layer = self.layers[layer_id]
            layer.elements.pop(element_id, None)
            if element_id in layer.order:
                layer.order.remove(element_id)
            # Also remove from any groups
            for g in layer.groups.values():
                if element_id in g.elements:
                    g.elements.remove(element_id)
            self._element_registry.pop(element_id, None)

    def update_element(self, element_id: str, attrs: dict[str, str],
                       text_content: str | None = None) -> bool:
        """Update an element's attributes. Returns True if found, False if not."""
        layer_id = self._element_registry.get(element_id)
        if layer_id and layer_id in self.layers:
            elem = self.layers[layer_id].elements.get(element_id)
            if elem:
                elem.attrs.update(attrs)
                if text_content is not None:
                    elem.text_content = text_content
                return True
        return False

    def create_group(self, layer_id: str, element_ids: list[str],
                     transform: str = "", opacity: float = 1.0,
                     group_id: str | None = None) -> str:
        gid = group_id or f"grp-{uuid.uuid4().hex[:8]}"
        group = SVGGroup(id=gid, elements=element_ids, transform=transform, opacity=opacity)
        layer = self.layers[layer_id]
        layer.groups[gid] = group
        # Replace individual element entries in order with the group
        for eid in element_ids:
            if eid in layer.order:
                layer.order.remove(eid)
        layer.order.append(gid)
        return gid

    def set_group_transform(self, layer_id: str, group_id: str, transform: str) -> None:
        if layer_id in self.layers and group_id in self.layers[layer_id].groups:
            self.layers[layer_id].groups[group_id].transform = transform

    def set_group_opacity(self, layer_id: str, group_id: str, opacity: float) -> None:
        if layer_id in self.layers and group_id in self.layers[layer_id].groups:
            self.layers[layer_id].groups[group_id].opacity = max(0.0, min(1.0, opacity))

    def move_element_to_layer(self, element_id: str, target_layer_id: str) -> None:
        src_layer_id = self._element_registry.get(element_id)
        if not src_layer_id or src_layer_id == target_layer_id:
            return
        src = self.layers[src_layer_id]
        tgt = self.layers[target_layer_id]
        elem = src.elements.pop(element_id, None)
        if elem:
            tgt.elements[element_id] = elem
            if element_id in src.order:
                src.order.remove(element_id)
            tgt.order.append(element_id)
            self._element_registry[element_id] = target_layer_id

    def move_group_to_layer(self, group_id: str, src_layer_id: str, target_layer_id: str) -> None:
        src = self.layers.get(src_layer_id)
        tgt = self.layers.get(target_layer_id)
        if not src or not tgt or group_id not in src.groups:
            return
        group = src.groups.pop(group_id)
        if group_id in src.order:
            src.order.remove(group_id)
        # Move elements too
        for eid in group.elements:
            self.move_element_to_layer(eid, target_layer_id)
        tgt.groups[group_id] = group
        tgt.order.append(group_id)

    def create_meta_group(self, name: str, members: list[dict],
                          transform: str = "", meta_group_id: str | None = None) -> str:
        """Create a cross-layer logical group.

        members: [{"element_id": "el-xxx", "layer_id": "layer-yyy"}, ...]
        """
        mgid = meta_group_id or f"mg-{uuid.uuid4().hex[:8]}"
        mg = MetaGroup(id=mgid, name=name, members=list(members), transform=transform)
        self.meta_groups[mgid] = mg
        return mgid

    def add_to_meta_group(self, meta_group_id: str, element_id: str, layer_id: str) -> None:
        if meta_group_id in self.meta_groups:
            self.meta_groups[meta_group_id].members.append(
                {"element_id": element_id, "layer_id": layer_id}
            )

    def set_meta_group_transform(self, meta_group_id: str, transform: str) -> None:
        """Apply a transform to all elements in the meta-group across their layers."""
        mg = self.meta_groups.get(meta_group_id)
        if not mg:
            return
        mg.transform = transform
        # Apply the transform to each member element as a group wrapper or attr
        for member in mg.members:
            eid = member["element_id"]
            lid = member["layer_id"]
            layer = self.layers.get(lid)
            if layer and eid in layer.elements:
                layer.elements[eid].attrs["transform"] = transform

    @staticmethod
    def rotation_around(angle: float, cx: float, cy: float) -> str:
        """Generate SVG rotate transform around a focal point."""
        return f"rotate({angle},{cx},{cy})"

    @staticmethod
    def compose_transforms(*transforms: str) -> str:
        """Compose multiple SVG transforms."""
        return " ".join(t for t in transforms if t)

    def to_svg(self, include_background: bool = True, overlay_opacity: float | None = None,
               whiteout_cell: tuple[int, int] | None = None,
               whiteout_color: str = "white") -> str:
        """Render the full SVG document as a string.

        Args:
            include_background: Embed the background image in the SVG.
            overlay_opacity: If set, wrap all drawn layers in a group with this
                opacity. Used for feedback composites so the agent can see the
                reference image through its work (e.g. 0.25).
            whiteout_cell: (col, row) in a 3×3 grid. If set, a colored rectangle
                at 0.8 opacity is placed between the background and the drawing
                layers to highlight the SVG above that region.
            whiteout_color: Fill color for the whiteout tile (default "white").
        """
        root = ET.Element("svg", {
            "xmlns": "http://www.w3.org/2000/svg",
            "xmlns:xlink": "http://www.w3.org/1999/xlink",
            "width": str(self.width),
            "height": str(self.height),
            "viewBox": f"0 0 {self.width} {self.height}",
        })

        # Background image
        if include_background and self.background_path:
            bg_data = self._encode_image_base64(self.background_path)
            ET.SubElement(root, "image", {
                "id": "background",
                "x": "0", "y": "0",
                "width": str(self.width), "height": str(self.height),
                "href": bg_data,
            })

        # Whiteout tile — sits between background and drawing layers
        if whiteout_cell is not None:
            col, row = whiteout_cell
            cw = self.width / 3
            ch = self.height / 3
            ET.SubElement(root, "rect", {
                "id": "whiteout-tile",
                "x": str(round(col * cw)),
                "y": str(round(row * ch)),
                "width": str(round(cw)),
                "height": str(round(ch)),
                "fill": whiteout_color,
                "opacity": "0.8",
            })

        # Optional overlay wrapper — makes drawing layers semi-transparent
        # but markers render on top at full opacity so the agent can see them
        if overlay_opacity is not None and overlay_opacity < 1.0:
            layers_parent = ET.SubElement(root, "g", {
                "id": "overlay",
                "opacity": str(overlay_opacity),
            })
        else:
            layers_parent = root

        # Layers in order — markers always render LAST and ON TOP
        # (outside overlay wrapper when compositing, on top of all layers otherwise)
        markers_layer = None
        markers_lid = None
        for lid in self.layer_order:
            layer = self.layers[lid]
            if not layer.visible:
                continue
            # Always defer markers to render last on top
            if layer.name == "markers":
                markers_layer = layer
                markers_lid = lid
                continue
            g_layer = ET.SubElement(layers_parent, "g", {
                "id": lid,
                "opacity": str(layer.opacity),
                "data-name": layer.name,
            })
            self._render_layer(g_layer, layer)

        # Render markers on top — outside overlay wrapper if compositing,
        # otherwise just on top of all other layers
        if markers_layer:
            g_markers = ET.SubElement(root, "g", {
                "id": markers_lid,
                "opacity": str(markers_layer.opacity),
                "data-name": "markers",
            })
            self._render_layer(g_markers, markers_layer)

        ET.indent(root, space="  ")
        return ET.tostring(root, encoding="unicode", xml_declaration=True)

    def _render_layer(self, parent: ET.Element, layer: SVGLayer) -> None:
        rendered_in_group: set[str] = set()
        for item_id in layer.order:
            if item_id in layer.groups:
                group = layer.groups[item_id]
                g_attrs: dict[str, str] = {"id": group.id}
                if group.transform:
                    g_attrs["transform"] = group.transform
                if group.opacity < 1.0:
                    g_attrs["opacity"] = str(group.opacity)
                g_el = ET.SubElement(parent, "g", g_attrs)
                for eid in group.elements:
                    elem = layer.elements.get(eid)
                    if elem:
                        g_el.append(elem.to_xml())
                        rendered_in_group.add(eid)
            elif item_id in layer.elements and item_id not in rendered_in_group:
                parent.append(layer.elements[item_id].to_xml())

    @staticmethod
    def _encode_image_base64(path: str) -> str:
        img = Image.open(path)
        fmt = img.format or "PNG"
        buf = io.BytesIO()
        img.save(buf, format=fmt)
        b64 = base64.b64encode(buf.getvalue()).decode()
        mime = {"PNG": "image/png", "JPEG": "image/jpeg", "GIF": "image/gif",
                "WEBP": "image/webp", "BMP": "image/bmp"}.get(fmt, "image/png")
        return f"data:{mime};base64,{b64}"

    def state_summary(self) -> dict:
        """Return a compact summary of the canvas state for the agent."""
        summary: dict[str, Any] = {
            "width": self.width,
            "height": self.height,
            "layers": [
                {
                    "id": lid,
                    "name": self.layers[lid].name,
                    "visible": self.layers[lid].visible,
                    "opacity": self.layers[lid].opacity,
                    "elements": len(self.layers[lid].elements),
                    "groups": len(self.layers[lid].groups),
                    "element_ids": list(self.layers[lid].elements.keys()),
                    "group_ids": list(self.layers[lid].groups.keys()),
                }
                for lid in self.layer_order
            ],
        }
        if self.meta_groups:
            summary["meta_groups"] = [
                {
                    "id": mg.id,
                    "name": mg.name,
                    "members": mg.members,
                    "transform": mg.transform,
                }
                for mg in self.meta_groups.values()
            ]
        return summary


# ---------------------------------------------------------------------------
# SVG RASTERIZER
# ---------------------------------------------------------------------------

def rasterize_svg(svg_string: str, width: int, height: int) -> bytes:
    """Render SVG to PNG bytes using cairosvg."""
    import cairosvg
    return cairosvg.svg2png(
        bytestring=svg_string.encode("utf-8"),
        output_width=width,
        output_height=height,
    )


def image_to_base64_url(img_bytes: bytes, mime: str = "image/png") -> str:
    return f"data:{mime};base64,{base64.b64encode(img_bytes).decode()}"


# ---------------------------------------------------------------------------
# AGENTIC SVG LOOP
# ---------------------------------------------------------------------------

SYSTEM_PROMPT = """\
You are an SVG illustration agent. You are given a background image and must \
recreate/trace it using SVG elements layered on top.

═══════════════════════════════════════════════════════════════
THE PAINTERS ALGORITHM — CORE PRINCIPLE
═══════════════════════════════════════════════════════════════
SVG layers render bottom-to-top like a painter working on a canvas:
  Layer 0 (bottom): Sky, distant background — drawn FIRST, covered by everything above
  Layer 1: Far mountains, horizon line
  Layer 2: Mid-ground hills, fields
  Layer 3: Trees, buildings, main subjects
  Layer 4: Foreground bushes, rocks, path edges
  Layer 5 (top): Fine details, highlights, shadows, texture overlays

ALWAYS organize your layers this way. Background elements go in LOWER layers,
foreground elements in HIGHER layers. Later layers paint OVER earlier ones.
Use reorder_layers to fix ordering. Use set_layer_opacity per layer to control
how much each layer shows through — the final output preserves your opacity choices.

═══════════════════════════════════════════════════════════════
PHASE 1 — MAPPING (first iteration only)
═══════════════════════════════════════════════════════════════
Identify every key visual element in the image. For each, provide a name, \
location, and brief description. Use the "identify" command:

  {"cmd": "identify", "elements": [
    {"name": "tree-1", "x": 50, "y": 200, "description": "tall dark pine, left edge"},
    {"name": "tree-2", "x": 300, "y": 180, "description": "birch tree, center-left"},
    {"name": "sky", "x": 512, "y": 50, "description": "blue sky with clouds"},
    {"name": "path-1", "x": 400, "y": 500, "description": "dirt path, foreground"},
    ...
  ]}

This creates:
- A "markers" layer with a labeled circle at each element's position
- An empty named group for each element (e.g., "grp-tree-1")
- A layer per logical group (e.g., "background", "trees", "foreground")

Be thorough — name EVERY distinct visual feature. Use descriptive names like
tree-1, tree-2, cloud-1, hill-left, path-main, bush-3, etc.

═══════════════════════════════════════════════════════════════
PHASE 1.5 — GRID SEGMENTATION (automatic)
═══════════════════════════════════════════════════════════════
After Phase 1 mapping, an automatic grid segmentation step runs:
  - A 50-cell grid is overlaid on the reference image
  - Each cell is classified by which visual element dominates it
  - Connected regions are traced into coarse polygon shapes
  - Vertices are snapped to the nearest edge contour points
  - Shapes are pre-placed on separate layers with sampled colours

These coarse shapes give you a starting scaffold. In Phase 2, your job is
to REFINE them: replace blocky grid boundaries with smooth bezier curves,
adjust colours for accuracy, add vertices to match true contours, and merge
or split shapes as needed. Do NOT start from scratch — build on what exists.

═══════════════════════════════════════════════════════════════
PHASE 2 — DRAWING (subsequent iterations)
═══════════════════════════════════════════════════════════════
Replace markers with real shapes. Each response is a JSON array of commands:

LAYER COMMANDS:
  {"cmd": "add_layer", "name": "...", "opacity": 0.8}
  {"cmd": "set_layer_visible", "layer_id": "...", "visible": true/false}
  {"cmd": "set_layer_opacity", "layer_id": "...", "opacity": 0.7}
  {"cmd": "reorder_layers", "order": ["layer-id-1", "layer-id-2", ...]}
  {"cmd": "remove_layer", "layer_id": "..."}
  {"cmd": "move_layer", "layer_id": "...", "direction": "up"|"down"}
  {"cmd": "move_layer_to", "layer_id": "...", "position": 0}

ELEMENT COMMANDS:
  {"cmd": "add_element", "layer_id": "...", "tag": "rect", "attrs": {"x":"10","y":"10","width":"100","height":"50","fill":"#ff0000","opacity":"0.5"}, "id": "optional-id"}
  {"cmd": "add_element", "layer_id": "...", "tag": "circle", "attrs": {"cx":"50","cy":"50","r":"30","fill":"blue"}}
  {"cmd": "add_element", "layer_id": "...", "tag": "ellipse", "attrs": {"cx":"50","cy":"50","rx":"30","ry":"20","fill":"green"}}
  {"cmd": "add_element", "layer_id": "...", "tag": "path", "attrs": {"d":"M10 10 L90 90","stroke":"black","stroke-width":"2","fill":"none"}}
  {"cmd": "add_element", "layer_id": "...", "tag": "polygon", "attrs": {"points":"50,5 95,97 5,97","fill":"yellow"}}
  {"cmd": "add_element", "layer_id": "...", "tag": "text", "attrs": {"x":"10","y":"30","font-size":"20","fill":"white"}, "text": "Hello"}
  {"cmd": "update_element", "element_id": "...", "attrs": {"fill": "#00ff00"}}
  {"cmd": "remove_element", "element_id": "...", "justification": "reason why this element should be deleted"}
  {"cmd": "move_element", "element_id": "...", "target_layer_id": "..."}

GROUP COMMANDS (within a single layer):
  {"cmd": "create_group", "layer_id": "...", "element_ids": ["el-1","el-2"], "transform": "", "opacity": 0.8, "id": "optional-id"}
  {"cmd": "set_group_transform", "layer_id": "...", "group_id": "...", "transform": "rotate(45,100,100) translate(10,20)"}
  {"cmd": "set_group_opacity", "layer_id": "...", "group_id": "...", "opacity": 0.5}
  {"cmd": "move_group", "group_id": "...", "src_layer_id": "...", "target_layer_id": "..."}

META-GROUP COMMANDS (span multiple layers):
  A meta-group links related elements across layers. Example: a house might have
  shadows on layer 2, walls on layer 3, and roof highlights on layer 4 — but they
  logically belong together and can be transformed as a unit.

  {"cmd": "create_meta_group", "name": "house-1", "members": [
    {"element_id": "el-shadow-1", "layer_id": "layer-xxx"},
    {"element_id": "el-wall-1", "layer_id": "layer-yyy"},
    {"element_id": "el-roof-1", "layer_id": "layer-zzz"}
  ]}
  {"cmd": "add_to_meta_group", "meta_group_id": "mg-xxx", "element_id": "el-new", "layer_id": "layer-yyy"}
  {"cmd": "set_meta_group_transform", "meta_group_id": "mg-xxx", "transform": "translate(10,20)"}

TRANSFORM HELPERS (use in transform strings):
  rotate(angle, cx, cy)  — rotate around focal point
  translate(tx, ty)      — shift
  scale(sx, sy)          — resize
  skewX(angle) / skewY(angle)

CONTROL COMMANDS:
  {"cmd": "done", "message": "..."}  — signal you are finished

═══════════════════════════════════════════════════════════════
PHASE 3 — REFINEMENT (later iterations, focus mode)
═══════════════════════════════════════════════════════════════
In refinement mode, the layer being refined is shown at FULL opacity while all
other layers are dimmed to HALF their normal opacity. This highlights the focus
layer while giving you spatial context from surrounding layers.

You see:
  - The reference image
  - The focus layer at full opacity (highlighted)
  - Other layers at half opacity (context)
  - The composite over the reference

Your job: tweak the shapes in the focus layer to better match the underlying image.
Use update_element to adjust positions, sizes, colors, and opacity. Add small
detail elements. Remove elements that don't help.

═══════════════════════════════════════════════════════════════
MARKERS WITH EVAL SCORES
═══════════════════════════════════════════════════════════════
Red labeled circles on the "markers" layer. They are ALWAYS visible in your
feedback images (rendered on top at full opacity). Each marker includes an
EVAL SCORE (0-100) — your assessment of how accurately that feature has been
recreated in SVG. 0 = not started, 100 = perfect match.

Manage markers with standard element commands on the markers layer:
  - Add: {"cmd": "add_element", "layer_id": "<markers-layer-id>", "tag": "circle", "attrs": {"cx":"100","cy":"200","r":"8","fill":"red","stroke":"white","stroke-width":"2","opacity":"0.9"}, "id": "marker-new-feature"}
  - Also add a label WITH SCORE: {"cmd": "add_element", "layer_id": "<markers-layer-id>", "tag": "text", "attrs": {"x":"112","y":"204","font-size":"11","fill":"white","stroke":"black","stroke-width":"0.5","font-family":"sans-serif"}, "text": "new-feature [0]", "id": "label-new-feature"}
  - Move: {"cmd": "update_element", "element_id": "marker-tree-1", "attrs": {"cx": "120", "cy": "210"}}

EVERY TURN: Update marker labels with your current eval score for each feature:
  {"cmd": "update_element", "element_id": "label-tree-1", "attrs": {}, "text": "tree-1 [75]"}
  Score guide: 0=not started, 25=rough shape placed, 50=shape+color approximate,
  75=good match with minor issues, 90=excellent trace, 100=perfect.
  Focus your work on the LOWEST-scoring markers first.

Do NOT remove markers — they persist for the entire session as reference points.
Add NEW markers for sub-details or textures you discover (e.g., "marker-tree1-bark",
"marker-shadow-edge").

═══════════════════════════════════════════════════════════════
EDGE GUIDE LAYER
═══════════════════════════════════════════════════════════════
An "edges" layer is pre-loaded with VECTORIZED contour lines traced from the
reference image. These are actual SVG <path> elements showing exactly where
boundaries, silhouettes, and edges exist in the photo.

USE THE EDGE PATHS TO BUILD YOUR SHAPES:
  - The edge paths contain the EXACT vertices and curves of each contour.
  - Extract vertex coordinates from edge paths and use them as starting points
    for your shape paths. The edge "d" attributes give you the precise bezier
    control points — copy and adapt them into your filled shapes.
  - For each region: find the edge paths that border it, combine their vertices
    into a closed path (add "Z" to close), set fill color, and place on the
    correct layer.
  - Example workflow:
    1. See edge path tracing a hill contour: d="M50,200 C80,180 120,170 160,185"
    2. Create your hill shape using those same vertices: add_element with
       d="M0,320 L0,200 C30,190 50,200 C80,180 120,170 160,185 L320,200 L320,320 Z"
       (extend to canvas edge, close the shape, add fill)
  - The edge layer is for reference — draw your shapes on other layers
  - Do NOT modify or delete the edge layer paths

═══════════════════════════════════════════════════════════════
STRATEGY
═══════════════════════════════════════════════════════════════
1. After mapping, create layers following the painters algorithm (back to front).
2. Place broad shapes first — large rects, paths for sky, ground, major masses.
3. Add detail layers BETWEEN existing layers using reorder_layers.
4. Use meta-groups for complex objects that span multiple Z-layers.
5. Set per-layer opacity to control translucency (these values are used in final output).
6. CRITICAL: Do NOT duplicate shapes. If a shape exists but is wrong, use
   update_element to fix it. Only add_element for features not yet represented.
7. Avoid darkening: overlapping opaque shapes make the scene too dark.
8. You receive TWO images each turn:
   a. The reference image (what you're recreating)
   b. A composite showing your SVG at 50% opacity over the reference, with a
      random colored tile (1/4 of the image, one quadrant) behind your layers —
      this tile highlights how your SVG shapes look against a solid background.
      Use it to judge shape accuracy, color, and contour precision in that region.
9. Each turn has fresh context — use the canvas state JSON to understand what exists.

═══════════════════════════════════════════════════════════════
PRECISION TRACING — CRITICAL
═══════════════════════════════════════════════════════════════
Your shapes MUST closely match the contours, edges, and boundaries in the photo.
Do NOT place generic rectangles or circles where the photo shows irregular shapes.
ALWAYS use <path> with MANY vertices for any non-rectangular region.

EVERY TURN you must study the composite overlay and FIX misaligned shapes:
  - Compare your SVG edges against the reference edges visible through the overlay.
  - Where a shape boundary diverges from the photo, use update_element to adjust
    path "d" vertices, polygon "points", or rect/ellipse position and size.
  - Trace outlines with <path> using curves (C, Q, S bezier commands) — not just
    straight lines. Natural shapes have curves.
  - Match color by sampling from the reference — don't guess. Use the exact hue
    visible at each region's center.

ADD VERTICES — MORE IS BETTER:
  - Use 10-20+ vertices per contour. The MORE vertices you use, the more accurate
    the shape. A path with 4 points is a blob. A path with 15 points is a trace.
  - Every bump, dip, corner, and curve change needs its own vertex.
  - For large shapes (sky, ground, hillside), use 15-25 vertices along the boundary.
  - For medium shapes (trees, rocks, buildings), use 10-15 vertices.
  - For small shapes (leaves, details), use 6-10 vertices.
  - NEVER use fewer than 6 vertices for any organic shape.

PATH TRACING TECHNIQUE:
  - For ALL irregular shapes (tree canopies, mountain ridges, coastlines, hair,
    clothing, shadows, terrain, faces, ANY non-rectangular region):
    Use <path d="M... C... C... C... C... Z"> with cubic bezier curves.
  - Walk the contour clockwise: place a vertex at EVERY point where the edge
    changes direction, curves, bumps, or inflects. Then add bezier control points
    to smooth the curve between consecutive vertices.
  - Example — a tree crown needs 10+ vertices, NOT 3-4:
    d="M80,220 C85,200 90,185 100,170 C110,155 125,140 145,135 C165,130 185,132 200,140 C215,148 225,160 230,175 C235,190 232,210 225,225 C218,240 200,250 180,252 C160,254 140,248 120,240 C100,232 85,228 80,220 Z"
  - That's 8 cubic bezier segments = 8 vertices along the contour. This produces
    a MUCH better shape than "C120,150 180,130 230,200" (3 points = ugly blob).

SHAPE CORRECTION DISCIPLINE:
  - Each turn, pick the 3-5 worst-fitting shapes and fix them via update_element.
  - ADD more vertices to paths that look blobby or imprecise. Rewrite the "d" attr
    with more C/L segments that follow the actual contour more closely.
  - If a rect or circle approximates an irregular region, REPLACE it with a detailed
    path with 10+ vertices that traces the actual boundary.
  - Small positional errors compound — a shape 10px off ruins the whole scene.

IMPORTANT:
- Respond ONLY with a JSON array of commands. No markdown, no explanation outside JSON.
- All attribute values must be strings (SVG spec).
- You can issue multiple commands per turn.
- Prefer editing existing shapes (update_element) over adding new ones.
"""

DETAIL_PRESETS = {
    "low": {"max_iterations": 6, "max_elements": 50, "guidance": "Use broad strokes. 5-10 large shapes to capture the overall composition. Minimal detail."},
    "medium": {"max_iterations": 10, "max_elements": 150, "guidance": "Balance detail and simplicity. Layer major shapes, then add moderate detail for key features."},
    "high": {"max_iterations": 20, "max_elements": 400, "guidance": "Recreate the image with high fidelity. Use many elements, gradients if needed, and fine details."},
    "ultra": {"max_iterations": 35, "max_elements": 800, "guidance": "Maximum fidelity. Use as many elements as needed. Capture textures, shadows, highlights, and fine details."},
}


def run_svg_agent(
    image_path: str,
    output: str = "output.svg",
    detail: str = "medium",
    provider: str = "openai",
    model: str | None = None,
    max_iterations: int | None = None,
    api_key: str | None = None,
    base_url: str | None = None,
    save_intermediates: bool = False,
    verbose: bool = True,
    blur: float | None = None,
    enable_edges: bool = False,
    enable_grid: bool = False,
) -> str:
    """Run the agentic SVG drawing loop."""
    # Provider aliases — groq and others use the OpenAI-compatible API
    PROVIDER_DEFAULTS = {
        "openai": {"model": "gpt-5.2", "max_tokens": 16384},
        "anthropic": {"model": "claude-sonnet-4-5-20250929", "max_tokens": 16384},
        "groq": {"model": "meta-llama/llama-4-scout-17b-16e-instruct",
                 "base_url": "https://api.groq.com/openai/v1",
                 "api_key_env": "GROQ_API_KEY",
                 "max_tokens": 8192},
    }
    prov_cfg = PROVIDER_DEFAULTS.get(provider, {})
    if model is None:
        model = prov_cfg.get("model", "gpt-5.2")
    # Auto-configure base_url and api_key for known providers
    if not base_url and "base_url" in prov_cfg:
        base_url = prov_cfg["base_url"]
    if not api_key and "api_key_env" in prov_cfg:
        api_key = os.environ.get(prov_cfg["api_key_env"])
    # Normalize provider to openai/anthropic for client creation
    effective_provider = "anthropic" if provider == "anthropic" else "openai"
    max_tokens = prov_cfg.get("max_tokens", 16384)

    preset = DETAIL_PRESETS.get(detail, DETAIL_PRESETS["medium"])
    iterations = max_iterations or preset["max_iterations"]
    max_elements = preset["max_elements"]
    guidance = preset["guidance"]

    # Load and measure image
    img = Image.open(image_path)
    orig_w, orig_h = img.size
    # Working resolution capped at 512px for speed; final SVG scales up
    WORK_CAP = 512
    if max(orig_w, orig_h) > WORK_CAP:
        scale = WORK_CAP / max(orig_w, orig_h)
        w, h = int(orig_w * scale), int(orig_h * scale)
    else:
        w, h = orig_w, orig_h
    # Final output resolution (up to 2048px, SVG is resolution-independent)
    FINAL_CAP = 2048
    if max(orig_w, orig_h) > FINAL_CAP:
        fscale = FINAL_CAP / max(orig_w, orig_h)
        final_w, final_h = int(orig_w * fscale), int(orig_h * fscale)
    else:
        final_w, final_h = orig_w, orig_h

    # Pre-blur: auto from detail level or explicit
    radius = blur if blur is not None else auto_blur_radius_svg(detail)
    # Ensure work dir exists for blurred image
    slug = Path(image_path).stem
    work_dir = Path(".tmp") / "image-convert" / slug
    work_dir.mkdir(parents=True, exist_ok=True)

    if radius > 0:
        blurred = apply_blur(img.resize((w, h), Image.Resampling.LANCZOS), radius)
        blurred_path = work_dir / "background_blurred.png"
        blurred.save(str(blurred_path))
        canvas = SVGCanvas(w, h, background_path=str(blurred_path))
        if verbose:
            print(f"Applied gaussian blur radius={radius:.1f} (detail={detail})")
    else:
        canvas = SVGCanvas(w, h, background_path=image_path)

    # Generate vectorized edge contour lines as tracing guide
    edges_lid = None
    if enable_edges:
        edge_paths, edge_transform = generate_edge_svg_paths(img, w, h, work_dir)
        if edge_paths:
            edges_lid = canvas.add_layer("edges", opacity=0.4)
            edge_eids = []
            for idx, ep in enumerate(edge_paths):
                eid = canvas.add_element(edges_lid, "path", ep,
                                         element_id=f"edge-{idx:04d}")
                edge_eids.append(eid)
            # Apply potrace's coordinate transform to the group
            if edge_transform:
                canvas.create_group(edges_lid, edge_eids,
                                    transform=edge_transform,
                                    group_id="edge-contours")
            if verbose:
                print(f"Edge guide layer: {len(edge_paths)} vector contour paths")

    # Prepare the initial background render (use blurred if applicable)
    bg_path = str(blurred_path) if radius > 0 else image_path
    with open(bg_path, "rb") as f:
        img_bytes = f.read()
    img_mime = {".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg",
                ".gif": "image/gif", ".webp": "image/webp", ".bmp": "image/bmp",
                }.get(Path(bg_path).suffix.lower(), "image/png")

    # Provider-specific client setup
    img_b64 = base64.b64encode(img_bytes).decode()
    img_data_url = f"data:{img_mime};base64,{img_b64}"

    if effective_provider == "openai":
        from openai import OpenAI
        client_kwargs: dict[str, Any] = {}
        if api_key:
            client_kwargs["api_key"] = api_key
        if base_url:
            client_kwargs["base_url"] = base_url
        client = OpenAI(**client_kwargs)
    else:
        import anthropic
        client_kwargs = {}
        if api_key:
            client_kwargs["api_key"] = api_key
        client = anthropic.Anthropic(**client_kwargs)

    def _make_image_block(b64_data: str, mime: str = "image/png") -> dict:
        """Create an image content block in the right format for the provider."""
        if effective_provider == "openai":
            return {"type": "image_url", "image_url": {"url": f"data:{mime};base64,{b64_data}"}}
        else:
            return {"type": "image", "source": {"type": "base64", "media_type": mime, "data": b64_data}}

    # Intermediates go into work_dir/steps/
    intermediates_dir = work_dir / "steps"
    if save_intermediates:
        intermediates_dir.mkdir(parents=True, exist_ok=True)

    if verbose:
        print(f"[{iterations} iters, {max_elements} max el] ", end="", flush=True)

    def _api_call_with_retry(msgs, max_retries=5):
        """Call the API with exponential backoff on rate limits."""
        for attempt in range(max_retries):
            try:
                if effective_provider == "openai":
                    return client.chat.completions.create(
                        model=model,
                        max_completion_tokens=max_tokens,
                        messages=msgs,
                    )
                else:
                    return client.messages.create(
                        model=model,
                        max_tokens=max_tokens,
                        system=SYSTEM_PROMPT,
                        messages=msgs,
                    )
            except Exception as e:
                if "rate_limit" in str(type(e).__name__).lower() or "429" in str(e):
                    wait = min(2 ** attempt * 10, 120)
                    if verbose:
                        print("R", end="", flush=True)
                    time.sleep(wait)
                else:
                    raise
        raise RuntimeError("Max retries exceeded on rate limit")

    def _extract_text(response) -> str:
        if effective_provider == "openai":
            return response.choices[0].message.content or ""
        else:
            return "".join(b.text for b in response.content if b.type == "text")

    def _build_fresh_message(iteration: int, phase_text: str,
                             composite_png: bytes | None) -> list[dict]:
        """Build a single-turn message with fresh context (no history).

        Sends 2 images: reference + composite overlay. The standalone SVG
        render is saved to disk (--save-steps) but not sent to the API.
        """
        state = canvas.state_summary()
        content: list[dict] = []

        # Always include the reference image
        content.append({"type": "text", "text": "Reference image to recreate:"})
        content.append(_make_image_block(img_b64, img_mime))

        # Composite: SVG overlaid on reference at reduced opacity
        if composite_png:
            content.append({"type": "text", "text": "Your SVG at 45% opacity over the reference:"})
            content.append(_make_image_block(base64.b64encode(composite_png).decode()))

        content.append({"type": "text", "text": (
            f"Canvas: {w}×{h}px. Detail: {detail} — {guidance}\n"
            f"Iteration {iteration + 1}/{iterations}. "
            f"Elements: {total_elements}/{max_elements}.\n\n"
            f"Current canvas state:\n{json.dumps(state, indent=2)}\n\n"
            f"{phase_text}\n\n"
            f"Respond ONLY with a JSON array of commands."
        )})
        return content

    total_elements = 0
    markers_layer_id = None
    element_map_text = ""

    for i in range(iterations):
        # --- Build fresh single-turn context (no conversation history) ---
        if i == 0:
            # Phase 1: identify elements
            phase_text = (
                "PHASE 1: Identify and map ALL key visual elements using the "
                "\"identify\" command. Be thorough — name every distinct feature "
                "(tree-1, tree-2, path-main, bush-left, sky, fog, etc.)."
            )
            composite_png = None
        else:
            # Phase 2: draw/refine
            # Build list of pre-placed shape IDs for the prompt
            _shape_ids = [f"shape-{m['name']}" for m in map_list] if map_list else []
            _shape_list_text = ", ".join(_shape_ids) if _shape_ids else "(none)"

            # Build per-shape update templates so the agent knows exactly what to emit
            _shape_cmds = []
            for m in (map_list or []):
                sid = f"shape-{m['name']}"
                _shape_cmds.append(
                    f'  {{\"cmd\":\"update_element\",\"element_id\":\"{sid}\",'
                    f'\"attrs\":{{\"d\":\"M... C... C... C... Z\",\"fill\":\"#RRGGBB\"}}}}'
                )
            _shape_template = "\n".join(_shape_cmds[:8])  # cap at 8 examples
            if len(_shape_cmds) > 8:
                _shape_template += f"\n  ... and {len(_shape_cmds) - 8} more"

            # Build layer list for the agent
            _layer_list = "\n".join(
                f"  - layer \"{lid}\"" for lid in canvas.layer_order
                if lid not in ("background", "markers", "edge-contours")
            )

            phase_text = (
                f"PHASE 2 — REFINE PRE-PLACED SHAPES.\n\n"
                f"Each identified element has its own layer with a shape-* blob "
                f"path. Your response MUST be a JSON array of commands.\n\n"
                f"PRIORITY: use update_element to rewrite \"d\" and \"fill\" attrs "
                f"on existing shape-* elements.\n\n"
                f"EMIT THESE COMMANDS (replace d/fill with accurate values):\n"
                f"{_shape_template}\n\n"
                f"CONTOURING — LAYERED SHAPES, NOT MANY VERTICES:\n"
                f"Do NOT try to trace exact contours with dozens of bezier points. "
                f"Instead, BUILD UP each object from multiple overlapping simple "
                f"shapes stacked on the SAME layer. Think paper cut-outs / collage:\n"
                f"  - Tree: broad green ellipse (canopy) + brown rect (trunk) + "
                f"smaller green ellipses overlapping for foliage depth\n"
                f"  - Hill: large fill path for base colour + slightly offset paths "
                f"on top for shadow, highlight, texture bands\n"
                f"  - Cloud: 3-4 overlapping white ellipses at varied opacity\n"
                f"  - Building: rect wall + triangle roof + small rect windows\n"
                f"Each sub-shape only needs 4-8 vertices. Layering many simple "
                f"shapes creates convincing contours and depth.\n\n"
                f"GROUPING — ALWAYS GROUP SUB-SHAPES:\n"
                f"After adding sub-shapes to a layer, group them with create_group "
                f"so they move and transform as a unit:\n"
                f"  {{\"cmd\":\"add_element\",\"layer_id\":\"LID\",\"tag\":\"path\","
                f"\"attrs\":{{\"d\":\"...\",\"fill\":\"#...\"}},\"id\":\"trunk-1\"}}\n"
                f"  {{\"cmd\":\"add_element\",\"layer_id\":\"LID\",\"tag\":\"ellipse\","
                f"\"attrs\":{{\"cx\":\"...\",\"cy\":\"...\",\"rx\":\"...\",\"ry\":\"...\","
                f"\"fill\":\"#...\"}},\"id\":\"canopy-1\"}}\n"
                f"  {{\"cmd\":\"create_group\",\"layer_id\":\"LID\","
                f"\"element_ids\":[\"trunk-1\",\"canopy-1\"],\"id\":\"grp-tree\"}}\n\n"
                f"Element map:\n{element_map_text}\n\n"
                f"Active layers:\n{_layer_list}\n\n"
                f"AVAILABLE LAYER Z-ORDER COMMANDS:\n"
                f"  {{\"cmd\":\"move_layer\",\"layer_id\":\"...\",\"direction\":\"up\"|\"down\"}}\n"
                f"  {{\"cmd\":\"move_layer_to\",\"layer_id\":\"...\",\"position\":0}}\n"
                f"  {{\"cmd\":\"reorder_layers\",\"order\":[...]}}\n\n"
                f"RULES:\n"
                f"- Update shape-* blobs with update_element (fix colour/position).\n"
                f"- THEN add_element 2-5 sub-shapes per object for contouring.\n"
                f"- THEN create_group to bundle each object's elements.\n"
                f"- remove_element requires a \"justification\" field.\n"
                f"- Respond with a JSON array of commands. Nothing else.\n"
                f"- Work on at least 3 objects per turn.\n"
                f"- Do NOT send {{\"cmd\":\"done\"}}."
            )
            # Rasterize current state — only composite sent to API
            # Random whiteout tile (1/9 of image) highlights SVG over colored background
            _wcell = (random.randint(0, 2), random.randint(0, 2))
            _wcolor = random.choice(["white", "red", "blue", "yellow"])
            composite_str = canvas.to_svg(include_background=True, overlay_opacity=0.50,
                                          whiteout_cell=_wcell, whiteout_color=_wcolor)
            try:
                composite_png = rasterize_svg(composite_str, w, h)
            except Exception:
                composite_png = None

            if save_intermediates and intermediates_dir:
                if composite_png:
                    (intermediates_dir / f"step_{i:03d}.png").write_bytes(composite_png)
                # Rasterize svg_only for disk only (not sent to API)
                svg_only_str = canvas.to_svg(include_background=False)
                try:
                    svg_only_png = rasterize_svg(svg_only_str, w, h)
                    (intermediates_dir / f"step_{i:03d}_svg.png").write_bytes(svg_only_png)
                except Exception:
                    pass
                (intermediates_dir / f"step_{i:03d}.svg").write_text(svg_only_str)

        user_content = _build_fresh_message(i, phase_text, composite_png)

        # Fresh messages each turn — no history accumulation
        if effective_provider == "openai":
            messages = [
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": user_content},
            ]
        else:
            messages = [
                {"role": "user", "content": user_content},
            ]

        response = _api_call_with_retry(messages)
        assistant_text = _extract_text(response)

        # --- Log raw response + parsed commands ---
        log_path = work_dir / "agent_log.jsonl"
        commands = _parse_commands(assistant_text)
        with open(log_path, "a", encoding="utf-8") as _lf:
            _lf.write(json.dumps({
                "iter": i, "raw_len": len(assistant_text),
                "commands": commands,
                "raw_text": assistant_text[:2000],
            }) + "\n")

        if not commands:
            if verbose:
                print("x", end="", flush=True)  # failed to parse
            continue  # skip this iteration, don't abort the whole loop

        done = False
        results = []
        cmd_results = []  # for logging
        for cmd in commands:
            if cmd.get("cmd") == "done":
                # Respect "done" after at least 2 drawing passes (iterations 1+2)
                if i >= 3:
                    done = True
                    break
                continue
            result = _execute_command(canvas, cmd)
            results.append(result)
            cmd_results.append({"cmd": cmd.get("cmd"), "ok": result.get("ok"),
                                "error": result.get("error")})
            if not result.get("ok") and verbose:
                print(f"\n  FAIL[{cmd.get('cmd')}]: {result.get('error', '')}",
                      end="", flush=True)

        # Append execution results to log
        with open(log_path, "a", encoding="utf-8") as _lf:
            _lf.write(json.dumps({"iter": i, "results": cmd_results}) + "\n")
            if result.get("added_element"):
                total_elements += 1
            if result.get("markers_layer_id"):
                markers_layer_id = result["markers_layer_id"]
                # Keep markers visible during iterations so the agent can see and
                # manage them. They are hidden only in the final output.

        # After Phase 1, build the element map text for all future iterations
        if i == 0 and markers_layer_id:
            map_info = next((r for r in results if r.get("map")), {})
            map_list = map_info.get("map", [])
            element_map_text = "\n".join(
                f"  - {m['name']}: {m.get('description', '')}"
                for m in map_list
            )

            # Place initial blob shapes for each identified marker
            if map_list:
                work_img = img.resize((w, h), Image.Resampling.LANCZOS)
                shape_layer_ids, blob_count = _place_initial_blobs(
                    canvas, map_list, work_img, w, h)
                total_elements += blob_count
                if verbose:
                    print(f" [{blob_count} blobs placed]", end="", flush=True)

            # --- Phase 1.5: Grid-based coarse segmentation ---
            if enable_grid and map_list:
                work_img = img.resize((w, h), Image.Resampling.LANCZOS)
                grid_elements = _run_grid_segmentation(
                    canvas, work_img, w, h, map_list, work_dir,
                    img_b64, img_mime,
                    _make_image_block, _api_call_with_retry, _extract_text,
                    effective_provider, verbose,
                )
                total_elements += grid_elements

                # Save grid segmentation result
                if save_intermediates and intermediates_dir:
                    grid_svg_str = canvas.to_svg(include_background=False)
                    try:
                        grid_png = rasterize_svg(grid_svg_str, w, h)
                        (intermediates_dir / "step_000_grid.png").write_bytes(
                            grid_png)
                    except Exception:
                        pass
                    (intermediates_dir / "step_000_grid.svg").write_text(
                        grid_svg_str)

        if verbose:
            print(".", end="", flush=True)

        if done or total_elements >= max_elements:
            break

    # ─── PHASE 3: REFINEMENT — isolate each layer and tweak ───
    # Only refine layers with >= 3 elements (small layers aren't worth an API call)
    drawing_layers = [
        lid for lid in canvas.layer_order
        if lid != markers_layer_id
        and canvas.layers[lid].visible
        and len(canvas.layers[lid].elements) >= 3
    ]
    used_iterations = (i + 1) if iterations > 0 else 0
    remaining = min(max(iterations - used_iterations, 0), len(drawing_layers), 5)
    if drawing_layers and remaining > 0:
        if verbose:
            print(f"\n[refinement: {remaining} passes over {len(drawing_layers)} layers] ", end="", flush=True)

        # Save original visibility + opacity state
        orig_visible = {lid: canvas.layers[lid].visible for lid in canvas.layer_order}
        orig_opacity = {lid: canvas.layers[lid].opacity for lid in canvas.layer_order}
        refine_step = 0
        for ri in range(remaining):
            target_lid = drawing_layers[ri % len(drawing_layers)]
            target_layer = canvas.layers[target_lid]

            # Show all drawing layers but dim non-target ones to half opacity
            for lid in drawing_layers:
                canvas.set_layer_visible(lid, True)
                if lid == target_lid:
                    # Restore full opacity for the focus layer
                    canvas.set_layer_opacity(lid, orig_opacity.get(lid, 1.0))
                else:
                    # Half the original opacity so context is visible but subdued
                    canvas.set_layer_opacity(lid, orig_opacity.get(lid, 1.0) * 0.5)

            # Rasterize composite for API (svg_only saved to disk only)
            _wcell = (random.randint(0, 2), random.randint(0, 2))
            _wcolor = random.choice(["white", "red", "blue", "yellow"])
            iso_composite_str = canvas.to_svg(include_background=True, overlay_opacity=0.50,
                                              whiteout_cell=_wcell, whiteout_color=_wcolor)
            try:
                iso_composite_png = rasterize_svg(iso_composite_str, w, h)
            except Exception:
                iso_composite_png = None

            if save_intermediates and intermediates_dir:
                step_num = used_iterations + ri
                if iso_composite_png:
                    (intermediates_dir / f"step_{step_num:03d}_refine.png").write_bytes(iso_composite_png)
                try:
                    iso_svg_png = rasterize_svg(canvas.to_svg(include_background=False), w, h)
                    (intermediates_dir / f"step_{step_num:03d}_refine_svg.png").write_bytes(iso_svg_png)
                except Exception:
                    pass

            # Build refinement message
            refine_phase_text = (
                f"PHASE 3 — REFINEMENT (focus layer).\n"
                f"You are refining layer \"{target_layer.name}\" (id: {target_lid}).\n"
                f"This layer is shown at FULL opacity. Other layers are dimmed to half "
                f"opacity for context — focus your edits on the highlighted layer.\n"
                f"Element IDs in this layer: {list(target_layer.elements.keys())}\n\n"
                f"PRECISION CORRECTION — compare each shape edge against the reference:\n"
                f"- For EVERY element in this layer, check if its boundary matches the photo.\n"
                f"- ADD MORE VERTICES to blobby paths — rewrite 'd' with 10-20 C segments.\n"
                f"- Shift vertices/control points so edges align with reference contours.\n"
                f"- Replace rects/circles with <path> bezier curves with 10+ vertices.\n"
                f"- Walk each contour: vertex at every bump, dip, inflection point.\n"
                f"- Fix colors to match the exact hue at each region's center.\n"
                f"- Remove elements that don't help. Add detail elements where needed.\n\n"
                f"UPDATE EVAL SCORES: For every marker related to this layer, update its\n"
                f"label score: {{\"cmd\": \"update_element\", \"element_id\": \"label-xxx\", \"text\": \"xxx [85]\"}}\n"
                f"Markers layer ID: {markers_layer_id or 'N/A'}"
            )
            refine_content = _build_fresh_message(
                used_iterations + ri, refine_phase_text,
                iso_composite_png
            )

            if effective_provider == "openai":
                messages = [
                    {"role": "system", "content": SYSTEM_PROMPT},
                    {"role": "user", "content": refine_content},
                ]
            else:
                messages = [{"role": "user", "content": refine_content}]

            response = _api_call_with_retry(messages)
            assistant_text = _extract_text(response)
            commands = _parse_commands(assistant_text)

            with open(log_path, "a", encoding="utf-8") as _lf:
                _lf.write(json.dumps({
                    "iter": f"refine-{ri}", "raw_len": len(assistant_text),
                    "commands": commands,
                    "raw_text": assistant_text[:2000],
                }) + "\n")

            for cmd in commands:
                if cmd.get("cmd") == "done":
                    break
                result = _execute_command(canvas, cmd)
                if result.get("added_element"):
                    total_elements += 1
                if not result.get("ok") and verbose:
                    print(f"\n  BLOCKED: {result.get('error', '')}", end="", flush=True)

            if verbose:
                print("r", end="", flush=True)

        # Restore visibility and opacity
        for lid in orig_visible:
            if lid in canvas.layers:
                canvas.set_layer_visible(lid, orig_visible[lid])
                canvas.set_layer_opacity(lid, orig_opacity.get(lid, 1.0))

    # Resolve output path — default into work_dir
    output_path = Path(output)
    if not output_path.is_absolute() and output_path.parent == Path("."):
        output_path = work_dir / output_path.name

    # Hide markers layer for final output (don't include in deliverable)
    if markers_layer_id and markers_layer_id in canvas.layers:
        canvas.set_layer_visible(markers_layer_id, False)

    # Scale canvas to final output resolution (SVG is resolution-independent)
    canvas.width = final_w
    canvas.height = final_h

    # Final output — SVG without embedded background or markers
    final_svg = canvas.to_svg(include_background=False)
    output_path.write_text(final_svg, encoding="utf-8")

    # Also save a version with background for preview
    preview_path = output_path.with_suffix(".preview.svg")
    preview_svg = canvas.to_svg(include_background=True)
    preview_path.write_text(preview_svg, encoding="utf-8")

    if verbose:
        print(f"\n{total_elements} elements, {len(canvas.layers)} layers")
        print(f"SVG: {output_path}")
        print(f"Preview: {preview_path}")

    return final_svg


def _parse_commands(text: str) -> list[dict]:
    """Extract JSON command array from agent response."""
    # Try direct parse
    text = text.strip()
    # Strip markdown code fences if present
    if text.startswith("```"):
        text = re.sub(r"^```(?:json)?\s*", "", text)
        text = re.sub(r"\s*```$", "", text)
        text = text.strip()

    try:
        parsed = json.loads(text)
        if isinstance(parsed, list):
            return parsed
        if isinstance(parsed, dict):
            return [parsed]
    except json.JSONDecodeError:
        pass

    # Try to find JSON array in the text
    match = re.search(r'\[[\s\S]*\]', text)
    if match:
        try:
            return json.loads(match.group())
        except json.JSONDecodeError:
            pass

    return []


def _resolve_layer_id(canvas: SVGCanvas, raw_id: str) -> str:
    """Resolve a layer reference — accepts either actual ID or layer name."""
    if raw_id in canvas.layers:
        return raw_id
    # Try matching by name
    for lid, layer in canvas.layers.items():
        if layer.name == raw_id:
            return lid
    return raw_id  # return as-is, will fail with KeyError downstream


def _execute_command(canvas: SVGCanvas, cmd: dict) -> dict:
    """Execute a single command on the canvas. Returns a result dict."""
    action = cmd.get("cmd", "")
    # Resolve layer_id references by name or ID
    for key in ("layer_id", "target_layer_id", "src_layer_id"):
        if key in cmd and isinstance(cmd[key], str):
            cmd[key] = _resolve_layer_id(canvas, cmd[key])
    try:
        if action == "add_layer":
            lid = canvas.add_layer(cmd["name"], cmd.get("opacity", 1.0))
            return {"ok": True, "layer_id": lid}
        elif action == "remove_layer":
            lid = cmd["layer_id"]
            canvas.remove_layer(lid)
            return {"ok": True}
        elif action == "set_layer_visible":
            canvas.set_layer_visible(cmd["layer_id"], cmd["visible"])
            return {"ok": True}
        elif action == "set_layer_opacity":
            canvas.set_layer_opacity(cmd["layer_id"], cmd["opacity"])
            return {"ok": True}
        elif action == "reorder_layers":
            canvas.reorder_layers(cmd["order"])
            return {"ok": True}
        elif action == "move_layer":
            moved = canvas.move_layer(cmd["layer_id"], cmd["direction"])
            if not moved:
                return {"ok": False, "error": f"Cannot move layer {cmd['direction']}"}
            return {"ok": True}
        elif action == "move_layer_to":
            moved = canvas.move_layer_to(cmd["layer_id"], int(cmd["position"]))
            if not moved:
                return {"ok": False, "error": "Layer not found"}
            return {"ok": True}
        elif action == "add_element":
            # Coerce all attr values to strings (SVG spec requires strings,
            # but some models return ints/floats)
            attrs = {k: str(v) for k, v in cmd.get("attrs", {}).items()}
            eid = canvas.add_element(
                cmd["layer_id"], cmd["tag"], attrs,
                text_content=cmd.get("text", ""),
                element_id=cmd.get("id"),
            )
            return {"ok": True, "element_id": eid, "added_element": True}
        elif action == "update_element":
            attrs = {k: str(v) for k, v in cmd.get("attrs", {}).items()}
            found = canvas.update_element(cmd["element_id"], attrs,
                                          text_content=cmd.get("text"))
            if not found:
                return {"ok": False,
                        "error": f"Element '{cmd['element_id']}' not found on canvas"}
            return {"ok": True}
        elif action == "remove_element":
            eid = cmd["element_id"]
            justification = cmd.get("justification", "").strip()
            if not justification:
                return {"ok": False,
                        "error": f"remove_element requires a \"justification\" field "
                                 f"explaining why {eid} should be deleted"}
            canvas.remove_element(eid)
            return {"ok": True, "removed": eid, "justification": justification}
        elif action == "move_element":
            canvas.move_element_to_layer(cmd["element_id"], cmd["target_layer_id"])
            return {"ok": True}
        elif action == "create_group":
            gid = canvas.create_group(
                cmd["layer_id"], cmd["element_ids"],
                transform=cmd.get("transform", ""),
                opacity=cmd.get("opacity", 1.0),
                group_id=cmd.get("id"),
            )
            return {"ok": True, "group_id": gid}
        elif action == "set_group_transform":
            canvas.set_group_transform(cmd["layer_id"], cmd["group_id"], cmd["transform"])
            return {"ok": True}
        elif action == "set_group_opacity":
            canvas.set_group_opacity(cmd["layer_id"], cmd["group_id"], cmd["opacity"])
            return {"ok": True}
        elif action == "move_group":
            canvas.move_group_to_layer(cmd["group_id"], cmd["src_layer_id"], cmd["target_layer_id"])
            return {"ok": True}
        elif action == "create_meta_group":
            mgid = canvas.create_meta_group(
                cmd["name"], cmd.get("members", []),
                transform=cmd.get("transform", ""),
                meta_group_id=cmd.get("id"),
            )
            return {"ok": True, "meta_group_id": mgid}
        elif action == "add_to_meta_group":
            canvas.add_to_meta_group(cmd["meta_group_id"], cmd["element_id"], cmd["layer_id"])
            return {"ok": True}
        elif action == "set_meta_group_transform":
            canvas.set_meta_group_transform(cmd["meta_group_id"], cmd["transform"])
            return {"ok": True}
        elif action == "identify":
            return _execute_identify(canvas, cmd.get("elements", []))
        else:
            return {"ok": False, "error": f"Unknown command: {action}"}
    except Exception as e:
        return {"ok": False, "error": str(e)}


def _generate_blob_path(
    cx: float, cy: float, radius: float, n_verts: int = 10,
) -> str:
    """Generate a random closed blob as an SVG path with cubic bezier curves."""
    angles = sorted(random.uniform(0, 2 * math.pi) for _ in range(n_verts))
    verts = []
    for a in angles:
        r = radius * random.uniform(0.4, 1.6)
        verts.append((cx + r * math.cos(a), cy + r * math.sin(a)))

    d = f"M{verts[0][0]:.1f},{verts[0][1]:.1f}"
    for i in range(len(verts)):
        p0 = verts[i]
        p1 = verts[(i + 1) % len(verts)]
        dx, dy = p1[0] - p0[0], p1[1] - p0[1]
        seg = math.hypot(dx, dy) or 1
        nx, ny = -dy / seg, dx / seg  # perpendicular
        jitter = radius * 0.3
        c1x = p0[0] + dx * 0.33 + nx * random.uniform(-jitter, jitter)
        c1y = p0[1] + dy * 0.33 + ny * random.uniform(-jitter, jitter)
        c2x = p0[0] + dx * 0.67 + nx * random.uniform(-jitter, jitter)
        c2y = p0[1] + dy * 0.67 + ny * random.uniform(-jitter, jitter)
        d += (f" C{c1x:.1f},{c1y:.1f} {c2x:.1f},{c2y:.1f}"
              f" {p1[0]:.1f},{p1[1]:.1f}")
    d += " Z"
    return d


def _place_initial_blobs(
    canvas: SVGCanvas, map_list: list[dict],
    img: Image.Image, w: int, h: int,
) -> tuple[list[str], int]:
    """Create one layer per identified marker with a random blob path.

    Each blob is a multi-vertex bezier curve centred on the marker position
    with a colour sampled from the reference image.  Layers are ordered by
    marker Y position (painter's algorithm — top/background first).

    The agent can reorder layers with ``move_layer``, ``move_layer_to``,
    or ``reorder_layers``.

    Returns ``(layer_ids, elements_added)``.
    """
    px = img.resize((w, h), Image.Resampling.LANCZOS).convert("RGB")
    base_radius = min(w, h) * 0.06

    # Sort markers by Y so background (top of image) layers are created first
    sorted_markers = sorted(map_list, key=lambda m: float(m.get("y", h // 2)))

    layer_ids: list[str] = []
    added = 0

    for m in sorted_markers:
        name = m["name"]
        cx = float(m.get("x", w // 2))
        cy = float(m.get("y", h // 2))

        # Sample colour from reference image at marker position
        ix = max(0, min(int(cx), w - 1))
        iy = max(0, min(int(cy), h - 1))
        r, g, b = px.getpixel((ix, iy))
        fill = f"#{r:02x}{g:02x}{b:02x}"

        n_verts = random.randint(8, 12)
        radius = base_radius * random.uniform(0.7, 1.3)
        d = _generate_blob_path(cx, cy, radius, n_verts)

        lid = canvas.add_layer(name, opacity=0.85)
        canvas.add_element(lid, "path", {
            "d": d,
            "fill": fill,
            "stroke": "none",
            "opacity": "0.8",
        }, element_id=f"shape-{name}")
        layer_ids.append(lid)
        added += 1

    return layer_ids, added


def _execute_identify(canvas: SVGCanvas, elements: list[dict]) -> dict:
    """Execute the identify command: create markers layer + empty groups per element."""
    # Create the markers layer (will be hidden/removed in drawing phase)
    markers_lid = canvas.add_layer("markers", opacity=1.0)

    created = []
    for el in elements:
        name = el.get("name", "unknown")
        x = str(el.get("x", 0))
        y = str(el.get("y", 0))
        desc = el.get("description", "")

        # Marker circle
        circle_id = canvas.add_element(
            markers_lid, "circle",
            {"cx": x, "cy": y, "r": "8", "fill": "red", "stroke": "white",
             "stroke-width": "2", "opacity": "0.9"},
            element_id=f"marker-{name}",
        )
        # Label with eval score [0] = not started
        label_id = canvas.add_element(
            markers_lid, "text",
            {"x": str(int(x) + 12), "y": str(int(y) + 4),
             "font-size": "11", "fill": "white", "stroke": "black",
             "stroke-width": "0.5", "font-family": "sans-serif"},
            text_content=f"{name} [0]",
            element_id=f"label-{name}",
        )
        created.append({
            "name": name, "marker_id": circle_id, "label_id": label_id,
            "description": desc, "x": x, "y": y,
        })

    return {
        "ok": True,
        "markers_layer_id": markers_lid,
        "elements_mapped": len(created),
        "map": created,
        "added_element": False,  # markers don't count toward element limit
    }


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Convert images to ASCII art or SVG via agentic loop",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent("""\
            Examples:
              %(prog)s ascii photo.png                                # 80 cols, aspect-ratio rows
              %(prog)s ascii photo.png --max-cols 120                 # wider output
              %(prog)s ascii photo.png --max-cols 80 --max-rows 30   # fit in 80x30 box
              %(prog)s ascii photo.png --max-cols 120 --charset braille
              %(prog)s ascii photo.png --charset ascii_extended --invert --char-ratio 2.0
              %(prog)s svg photo.png -o result.svg --detail medium
              %(prog)s svg photo.png -o result.svg --detail high --model claude-sonnet-4-5-20250929 --save-steps
        """),
    )
    sub = parser.add_subparsers(dest="mode", required=True)

    # ASCII subcommand
    p_ascii = sub.add_parser("ascii", help="Convert image to ASCII/Unicode block art")
    p_ascii.add_argument("image", help="Input image path")
    p_ascii.add_argument("--max-cols", type=int, default=80,
                         help="Max output width in characters (default: 80). Rows computed from aspect ratio.")
    p_ascii.add_argument("--max-rows", type=int, default=None,
                         help="Optional max output height. If set, output fits within both constraints.")
    p_ascii.add_argument("--char-ratio", type=float, default=1.0,
                         help="Terminal char height/width ratio correction (default: 1.0, try 2.0 for typical fonts)")
    p_ascii.add_argument("--charset", choices=list(CHARSETS.keys()), default="blocks",
                         help="Character set to use (default: blocks)")
    p_ascii.add_argument("--invert", action="store_true", help="Invert brightness")
    p_ascii.add_argument("--blur", type=float, default=None,
                         help="Gaussian blur radius. Auto-computed from downscale ratio if omitted. Set 0 to disable.")
    p_ascii.add_argument("-o", "--output", help="Output file (default: stdout)")

    # SVG subcommand
    p_svg = sub.add_parser("svg", help="Agentic SVG generation from image")
    p_svg.add_argument("image", help="Input image path")
    p_svg.add_argument("-o", "--output", default="output.svg", help="Output SVG path (default: output.svg)")
    p_svg.add_argument("--detail", choices=list(DETAIL_PRESETS.keys()), default="medium",
                       help="Detail level preset (default: medium)")
    p_svg.add_argument("--blur", type=float, default=None,
                       help="Gaussian blur radius. Auto from detail level if omitted (low=4, med=2, high=1, ultra=0). Set 0 to disable.")
    p_svg.add_argument("--iterations", type=int, help="Override max iterations")
    p_svg.add_argument("--provider", choices=["openai", "anthropic", "groq"], default="openai",
                       help="LLM provider (default: openai). groq uses GROQ_API_KEY env var.")
    p_svg.add_argument("--model", default=None,
                       help="Model name (default: gpt-4o for openai, claude-sonnet-4-5-20250929 for anthropic)")
    p_svg.add_argument("--api-key", help="API key (or set OPENAI_API_KEY / ANTHROPIC_API_KEY env var)")
    p_svg.add_argument("--base-url", help="Custom API base URL (OpenAI provider only)")
    p_svg.add_argument("--save-steps", action="store_true", help="Save intermediate PNGs and SVGs")
    p_svg.add_argument("--quiet", action="store_true", help="Suppress progress output")
    p_svg.add_argument("--enable-edges", action="store_true",
                       help="Enable potrace edge contour guide layer (disabled by default)")
    p_svg.add_argument("--enable-grid", action="store_true",
                       help="Enable Phase 1.5 grid-based coarse segmentation (disabled by default)")

    args = parser.parse_args()

    if args.mode == "ascii":
        run_ascii(args.image, max_cols=args.max_cols, max_rows=args.max_rows,
                  charset=args.charset, output=args.output, invert=args.invert,
                  char_ratio=args.char_ratio, blur=args.blur)
    elif args.mode == "svg":
        run_svg_agent(
            args.image, output=args.output, detail=args.detail,
            provider=args.provider, model=args.model,
            max_iterations=args.iterations,
            api_key=args.api_key, base_url=getattr(args, "base_url", None),
            save_intermediates=args.save_steps,
            verbose=not args.quiet, blur=args.blur,
            enable_edges=args.enable_edges,
            enable_grid=args.enable_grid,
        )


if __name__ == "__main__":
    main()
