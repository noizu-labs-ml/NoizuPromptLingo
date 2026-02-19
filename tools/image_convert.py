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
import re
import sys
import textwrap
import time
import uuid
import xml.etree.ElementTree as ET
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Optional

from PIL import Image, ImageFilter

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

    def update_element(self, element_id: str, attrs: dict[str, str]) -> None:
        layer_id = self._element_registry.get(element_id)
        if layer_id and layer_id in self.layers:
            elem = self.layers[layer_id].elements.get(element_id)
            if elem:
                elem.attrs.update(attrs)

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

    @staticmethod
    def rotation_around(angle: float, cx: float, cy: float) -> str:
        """Generate SVG rotate transform around a focal point."""
        return f"rotate({angle},{cx},{cy})"

    @staticmethod
    def compose_transforms(*transforms: str) -> str:
        """Compose multiple SVG transforms."""
        return " ".join(t for t in transforms if t)

    def to_svg(self, include_background: bool = True, overlay_opacity: float | None = None) -> str:
        """Render the full SVG document as a string.

        Args:
            include_background: Embed the background image in the SVG.
            overlay_opacity: If set, wrap all drawn layers in a group with this
                opacity. Used for feedback composites so the agent can see the
                reference image through its work (e.g. 0.25).
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

        # Optional overlay wrapper — makes all layers semi-transparent
        if overlay_opacity is not None and overlay_opacity < 1.0:
            layers_parent = ET.SubElement(root, "g", {
                "id": "overlay",
                "opacity": str(overlay_opacity),
            })
        else:
            layers_parent = root

        # Layers in order
        for lid in self.layer_order:
            layer = self.layers[lid]
            if not layer.visible:
                continue
            g_layer = ET.SubElement(layers_parent, "g", {
                "id": lid,
                "opacity": str(layer.opacity),
                "data-name": layer.name,
            })
            self._render_layer(g_layer, layer)

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
        return {
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

You work in TWO PHASES:

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
PHASE 2 — DRAWING (all subsequent iterations)
═══════════════════════════════════════════════════════════════
Replace markers with real shapes. Each response is a JSON array of commands:

LAYER COMMANDS:
  {"cmd": "add_layer", "name": "...", "opacity": 0.5}
  {"cmd": "set_layer_visible", "layer_id": "...", "visible": true/false}
  {"cmd": "set_layer_opacity", "layer_id": "...", "opacity": 0.7}
  {"cmd": "reorder_layers", "order": ["layer-id-1", "layer-id-2", ...]}
  {"cmd": "remove_layer", "layer_id": "..."}

ELEMENT COMMANDS:
  {"cmd": "add_element", "layer_id": "...", "tag": "rect", "attrs": {"x":"10","y":"10","width":"100","height":"50","fill":"#ff0000","opacity":"0.5"}, "id": "optional-id"}
  {"cmd": "add_element", "layer_id": "...", "tag": "circle", "attrs": {"cx":"50","cy":"50","r":"30","fill":"blue"}}
  {"cmd": "add_element", "layer_id": "...", "tag": "ellipse", "attrs": {"cx":"50","cy":"50","rx":"30","ry":"20","fill":"green"}}
  {"cmd": "add_element", "layer_id": "...", "tag": "path", "attrs": {"d":"M10 10 L90 90","stroke":"black","stroke-width":"2","fill":"none"}}
  {"cmd": "add_element", "layer_id": "...", "tag": "polygon", "attrs": {"points":"50,5 95,97 5,97","fill":"yellow"}}
  {"cmd": "add_element", "layer_id": "...", "tag": "text", "attrs": {"x":"10","y":"30","font-size":"20","fill":"white"}, "text": "Hello"}
  {"cmd": "update_element", "element_id": "...", "attrs": {"fill": "#00ff00"}}
  {"cmd": "remove_element", "element_id": "..."}
  {"cmd": "move_element", "element_id": "...", "target_layer_id": "..."}

GROUP COMMANDS:
  {"cmd": "create_group", "layer_id": "...", "element_ids": ["el-1","el-2"], "transform": "", "opacity": 0.8, "id": "optional-id"}
  {"cmd": "set_group_transform", "layer_id": "...", "group_id": "...", "transform": "rotate(45,100,100) translate(10,20)"}
  {"cmd": "set_group_opacity", "layer_id": "...", "group_id": "...", "opacity": 0.5}
  {"cmd": "move_group", "group_id": "...", "src_layer_id": "...", "target_layer_id": "..."}

TRANSFORM HELPERS (use in transform strings):
  rotate(angle, cx, cy)  — rotate around focal point
  translate(tx, ty)      — shift
  scale(sx, sy)          — resize
  skewX(angle) / skewY(angle)

CONTROL COMMANDS:
  {"cmd": "done", "message": "..."}  — signal you are finished

MARKER MANAGEMENT:
  Markers are red labeled circles on their own layer. They persist throughout the
  drawing process and are visible in your feedback images. Use them to:
  - Track features not yet represented by shapes
  - Indicate where texture or detail should be added on top of existing shapes
  - Plan future work

  You can manage markers using standard element commands on the markers layer:
  - Add new markers: {"cmd": "add_element", "layer_id": "<markers-layer-id>", "tag": "circle", "attrs": {"cx":"100","cy":"200","r":"8","fill":"red","stroke":"white","stroke-width":"2","opacity":"0.9"}, "id": "marker-new-feature"}
  - Move markers: {"cmd": "update_element", "element_id": "marker-tree-1", "attrs": {"cx": "120", "cy": "210"}}
  - Remove markers once the feature is fully drawn: {"cmd": "remove_element", "element_id": "marker-tree-1"}
  - Remove corresponding labels too: {"cmd": "remove_element", "element_id": "label-tree-1"}

  As you draw shapes for a feature, remove its marker. Add NEW markers for
  details you notice that need work (e.g., "marker-tree1-texture", "marker-shadow-left").

STRATEGY:
- After mapping, work from background to foreground replacing markers with shapes.
- Use layers to organize: e.g., "sky", "mountains", "trees", "details".
- Follow the PAINTERS ALGORITHM: background layers at the bottom, details on top.
  Use reorder_layers to insert detail layers between existing ones.
- Each iteration you receive TWO feedback images:
  1. Your standalone SVG render (what you're actually building)
  2. A composite showing your SVG at 30% opacity over the reference (for comparison)
  Use both to judge accuracy and identify what needs work.
- CRITICAL: Do NOT duplicate shapes. If a shape exists but is wrong, use
  update_element to fix its color, size, position, or opacity. Only add new elements
  for features not yet represented. Remove elements that don't help (remove_element).
- Avoid darkening: overlapping opaque shapes make the scene too dark. Use appropriate
  opacity values and avoid stacking shapes that cover the same area.
- Use groups to manage related elements together.
- You can rotate groups around focal points for complex shapes.
- Use markers to track what still needs work. Remove markers as you draw their features.
  Add new markers for sub-details or textures you want to add in later iterations.

IMPORTANT:
- Respond ONLY with a JSON array of commands. No markdown, no explanation outside JSON.
- All attribute values must be strings (SVG spec).
- You can issue multiple commands per turn.
- Prefer editing existing shapes (update_element) over adding new ones.
- Each turn has fresh context — you see the current state, not history. Use the
  canvas state JSON to understand what layers and elements already exist.
"""

DETAIL_PRESETS = {
    "low": {"max_iterations": 8, "max_elements": 50, "guidance": "Use broad strokes. 5-10 large shapes to capture the overall composition. Minimal detail."},
    "medium": {"max_iterations": 15, "max_elements": 150, "guidance": "Balance detail and simplicity. Layer major shapes, then add moderate detail for key features."},
    "high": {"max_iterations": 30, "max_elements": 400, "guidance": "Recreate the image with high fidelity. Use many elements, gradients if needed, and fine details."},
    "ultra": {"max_iterations": 50, "max_elements": 800, "guidance": "Maximum fidelity. Use as many elements as needed. Capture textures, shadows, highlights, and fine details."},
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
) -> str:
    """Run the agentic SVG drawing loop."""
    # Default model per provider
    if model is None:
        model = {"openai": "gpt-5.2", "anthropic": "claude-sonnet-4-5-20250929"}[provider]

    preset = DETAIL_PRESETS.get(detail, DETAIL_PRESETS["medium"])
    iterations = max_iterations or preset["max_iterations"]
    max_elements = preset["max_elements"]
    guidance = preset["guidance"]

    # Load and measure image
    img = Image.open(image_path)
    w, h = img.size
    # Cap canvas size for reasonable SVG
    if max(w, h) > 1024:
        scale = 1024 / max(w, h)
        w, h = int(w * scale), int(h * scale)

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

    if provider == "openai":
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
        if provider == "openai":
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
                if provider == "openai":
                    return client.chat.completions.create(
                        model=model,
                        max_completion_tokens=16384,
                        messages=msgs,
                    )
                else:
                    return client.messages.create(
                        model=model,
                        max_tokens=16384,
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
        if provider == "openai":
            return response.choices[0].message.content or ""
        else:
            return "".join(b.text for b in response.content if b.type == "text")

    def _build_fresh_message(iteration: int, phase_text: str,
                             svg_only_png: bytes | None,
                             composite_png: bytes | None) -> list[dict]:
        """Build a single-turn message with fresh context (no history)."""
        state = canvas.state_summary()
        content: list[dict] = []

        # Always include the reference image
        content.append({"type": "text", "text": "Reference image to recreate:"})
        content.append(_make_image_block(img_b64, img_mime))

        # Current SVG render
        if svg_only_png:
            content.append({"type": "text", "text": "Your current SVG (standalone render):"})
            content.append(_make_image_block(base64.b64encode(svg_only_png).decode()))
        if composite_png:
            content.append({"type": "text", "text": "Your SVG at 30% opacity over the reference:"})
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
            svg_only_png = None
            composite_png = None
        else:
            # Phase 2: draw/refine
            phase_text = (
                f"PHASE 2 — DRAWING.\n"
                f"Element map from Phase 1:\n{element_map_text}\n\n"
                f"CRITICAL RULES:\n"
                f"- Do NOT duplicate shapes. Edit existing elements with update_element.\n"
                f"- Use the painters algorithm: add detail layers BETWEEN existing ones "
                f"(use reorder_layers). Background at bottom, fine details on top.\n"
                f"- If a shape is wrong, update_element to fix it — don't add a new one.\n"
                f"- Add new elements only for features not yet represented.\n"
                f"- Remove elements that don't match the reference (remove_element).\n"
                f"- Keep the scene from getting too dark — avoid overlapping opaque fills.\n\n"
                f"MARKER MANAGEMENT:\n"
                f"- Red markers show features that still need work. Remove a marker once "
                f"its feature is fully drawn (remove both marker-xxx and label-xxx).\n"
                f"- Add NEW markers for sub-details or textures you notice need attention "
                f"(e.g., marker-tree1-bark, marker-shadow-edge).\n"
                f"- Move markers that are mispositioned with update_element.\n"
                f"- Markers layer ID: {markers_layer_id or 'N/A'}"
            )
            # Rasterize current state
            svg_only_str = canvas.to_svg(include_background=False)
            composite_str = canvas.to_svg(include_background=True, overlay_opacity=0.3)
            try:
                svg_only_png = rasterize_svg(svg_only_str, w, h)
            except Exception:
                svg_only_png = None
            try:
                composite_png = rasterize_svg(composite_str, w, h)
            except Exception:
                composite_png = None

            if save_intermediates and intermediates_dir:
                if composite_png:
                    (intermediates_dir / f"step_{i:03d}.png").write_bytes(composite_png)
                if svg_only_png:
                    (intermediates_dir / f"step_{i:03d}_svg.png").write_bytes(svg_only_png)
                (intermediates_dir / f"step_{i:03d}.svg").write_text(svg_only_str)

        user_content = _build_fresh_message(i, phase_text, svg_only_png, composite_png)

        # Fresh messages each turn — no history accumulation
        if provider == "openai":
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

        # Parse and execute commands
        commands = _parse_commands(assistant_text)
        if not commands:
            break

        done = False
        results = []
        for cmd in commands:
            if cmd.get("cmd") == "done":
                done = True
                break
            result = _execute_command(canvas, cmd)
            results.append(result)
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

        if verbose:
            print(".", end="", flush=True)

        if done or total_elements >= max_elements:
            break

    # Resolve output path — default into work_dir
    output_path = Path(output)
    if not output_path.is_absolute() and output_path.parent == Path("."):
        output_path = work_dir / output_path.name

    # Hide markers layer for final output (don't include in deliverable)
    if markers_layer_id and markers_layer_id in canvas.layers:
        canvas.set_layer_visible(markers_layer_id, False)

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
            canvas.remove_layer(cmd["layer_id"])
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
        elif action == "add_element":
            eid = canvas.add_element(
                cmd["layer_id"], cmd["tag"], cmd.get("attrs", {}),
                text_content=cmd.get("text", ""),
                element_id=cmd.get("id"),
            )
            return {"ok": True, "element_id": eid, "added_element": True}
        elif action == "update_element":
            canvas.update_element(cmd["element_id"], cmd["attrs"])
            return {"ok": True}
        elif action == "remove_element":
            canvas.remove_element(cmd["element_id"])
            return {"ok": True}
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
        elif action == "identify":
            return _execute_identify(canvas, cmd.get("elements", []))
        else:
            return {"ok": False, "error": f"Unknown command: {action}"}
    except Exception as e:
        return {"ok": False, "error": str(e)}


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
        # Label
        label_id = canvas.add_element(
            markers_lid, "text",
            {"x": str(int(x) + 12), "y": str(int(y) + 4),
             "font-size": "11", "fill": "white", "stroke": "black",
             "stroke-width": "0.5", "font-family": "sans-serif"},
            text_content=name,
            element_id=f"label-{name}",
        )
        created.append({
            "name": name, "marker_id": circle_id, "label_id": label_id,
            "description": desc,
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
    p_svg.add_argument("--provider", choices=["openai", "anthropic"], default="openai",
                       help="LLM provider (default: openai)")
    p_svg.add_argument("--model", default=None,
                       help="Model name (default: gpt-4o for openai, claude-sonnet-4-5-20250929 for anthropic)")
    p_svg.add_argument("--api-key", help="API key (or set OPENAI_API_KEY / ANTHROPIC_API_KEY env var)")
    p_svg.add_argument("--base-url", help="Custom API base URL (OpenAI provider only)")
    p_svg.add_argument("--save-steps", action="store_true", help="Save intermediate PNGs and SVGs")
    p_svg.add_argument("--quiet", action="store_true", help="Suppress progress output")

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
        )


if __name__ == "__main__":
    main()
