#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = ["pyyaml>=6.0"]
# ///
"""
media-prompt-engine.py — Parse .media.prompt and legacy .ext.prompt YAML files,
resolve dependencies, and generate media assets via pluggable providers.

Supports asset-prompt-payload schema v0.1, v0.2, and v0.3.

Run via: uv run media-prompt-engine.py (auto-installs pyyaml)
Or:      python3 media-prompt-engine.py (requires pyyaml pre-installed)
"""

import argparse
import base64
import json
import mimetypes
import os
import re
import secrets
import sys
import time
import urllib.error
import urllib.request
from collections import defaultdict, deque
from datetime import datetime, timezone
from pathlib import Path

import yaml

# =============================================================================
# ANSI colour codes (matching k8-lib conventions)
# =============================================================================
RED = "\033[0;31m"
YEL = "\033[1;33m"
GRN = "\033[0;32m"
BLU = "\033[0;34m"
CYN = "\033[0;36m"
NC = "\033[0m"
BOLD = "\033[1m"


def step(msg: str) -> None:
    print(f"\n{BLU}▶ {msg}{NC}")


def ok(msg: str) -> None:
    print(f"  {GRN}✅ {msg}{NC}")


def warn(msg: str) -> None:
    print(f"  {YEL}⚠️  {msg}{NC}")


def fail(msg: str) -> None:
    print(f"  {RED}❌ {msg}{NC}")


def info(msg: str) -> None:
    print(f"  {CYN}ℹ️  {msg}{NC}")


def die(msg: str) -> None:
    print(f"\n{RED}❌ {msg}{NC}\n")
    sys.exit(1)


def verbose_log(msg: str, is_verbose: bool) -> None:
    if is_verbose:
        print(f"  {CYN}   {msg}{NC}")


# =============================================================================
# Asset type detection
# =============================================================================
IMAGE_EXTENSIONS = {"png", "jpg", "jpeg", "svg", "webp"}
AUDIO_EXTENSIONS = {"mp3", "wav", "ogg", "flac"}
VIDEO_EXTENSIONS = {"mp4", "webm", "avi", "mov"}
COMPONENT_EXTENSIONS = {"ts", "tsx", "js", "jsx"}

ALL_EXTENSIONS = IMAGE_EXTENSIONS | AUDIO_EXTENSIONS | VIDEO_EXTENSIONS | COMPONENT_EXTENSIONS


def extension_to_type(ext: str) -> str:
    """Map a file extension to an asset type string."""
    ext = ext.lower()
    if ext in IMAGE_EXTENSIONS:
        return "image"
    elif ext in AUDIO_EXTENSIONS:
        return "audio"
    elif ext in VIDEO_EXTENSIONS:
        return "video"
    elif ext in COMPONENT_EXTENSIONS:
        return "component"
    else:
        return "unknown"


def detect_asset_type_legacy(prompt_path: str) -> tuple[str, str]:
    """Return (asset_type, output_extension) from a legacy .ext.prompt filename.

    e.g., hero.png.prompt -> ('image', 'png')
          theme.ts.prompt -> ('component', 'ts')
    """
    name = Path(prompt_path).name
    # Strip .prompt suffix -> e.g., hero.png
    base = name[: -len(".prompt")]
    parts = base.rsplit(".", 1)
    if len(parts) < 2:
        die(f"Cannot determine asset type from filename: {name}\n"
            f"   Expected pattern: name.ext.prompt (e.g., hero.png.prompt)")

    ext = parts[1].lower()
    atype = extension_to_type(ext)
    if atype == "unknown":
        die(f"Unrecognized asset extension '.{ext}' in {name}\n"
            f"   Supported: {', '.join(sorted(ALL_EXTENSIONS))}")

    return atype, ext


def is_media_prompt(path: str) -> bool:
    """Check if a file uses the v0.3 .media.prompt naming convention."""
    return Path(path).name.endswith(".media.prompt")


def detect_asset_info(prompt_path: str, data: dict) -> tuple[str, list[dict]]:
    """Return (asset_type, output_formats) from prompt file + YAML data.

    For .media.prompt files: type and formats come from YAML.
    For legacy .ext.prompt files: type/format inferred from extension.
    """
    if is_media_prompt(prompt_path):
        # v0.3: type from YAML
        asset_type = data.get("type", "image")
        output_section = data.get("output", {})
        formats = output_section.get("formats", [])
        if not formats:
            # Fallback: check requirements.format (backward compat)
            req_format = data.get("requirements", {}).get("format")
            if req_format:
                formats = [{"format": req_format}]
            else:
                # Default to png for images
                default_ext = {"image": "png", "audio": "mp3", "video": "mp4", "component": "ts"}
                formats = [{"format": default_ext.get(asset_type, "png")}]
        return asset_type, formats
    else:
        # Legacy: type and format from extension
        asset_type, ext = detect_asset_type_legacy(prompt_path)
        return asset_type, [{"format": ext}]


# =============================================================================
# Schema version detection & normalization
# =============================================================================
def detect_schema_version(data: dict) -> str:
    """Detect schema version from YAML data."""
    schema = data.get("schema", "")
    if schema:
        return str(schema)
    return "0.1"


def normalize_to_v03(data: dict, prompt_path: str) -> dict:
    """Normalize a parsed YAML payload to v0.3 internal representation.

    For v0.1/v0.2 payloads, maps legacy fields to v0.3 equivalents.
    Mutates and returns the data dict.
    """
    version = detect_schema_version(data)

    if version.startswith("0.3"):
        # Already v0.3 — just ensure defaults
        data.setdefault("type", "image")
        data.setdefault("service", "gemini")
        # Normalize tool_hints -> provider_options
        prompt_section = data.get("prompt", {})
        if isinstance(prompt_section, dict):
            if "tool_hints" in prompt_section and "provider_options" not in prompt_section:
                prompt_section["provider_options"] = prompt_section.pop("tool_hints")
        return data

    # Legacy v0.1/v0.2 normalization
    data.setdefault("service", "gemini")

    # type defaults to image
    if "type" not in data:
        data["type"] = "image"

    # requirements.format -> output.formats
    reqs = data.get("requirements", {})
    if isinstance(reqs, dict):
        req_format = reqs.get("format")
        req_dims = reqs.get("dimensions", {})

        if "output" not in data:
            data["output"] = {}

        output = data["output"]
        if req_format and "formats" not in output:
            output["formats"] = [{"format": req_format}]
        if req_dims and "dimensions" not in output:
            output["dimensions"] = req_dims

    # prompt.tool_hints -> prompt.provider_options
    prompt_section = data.get("prompt", {})
    if isinstance(prompt_section, dict):
        if "tool_hints" in prompt_section and "provider_options" not in prompt_section:
            prompt_section["provider_options"] = prompt_section.pop("tool_hints")

    return data


# =============================================================================
# Prompt file parsing
# =============================================================================
def parse_prompt_file(path: str) -> dict:
    """Parse a .prompt YAML file and attach metadata."""
    path = os.path.abspath(path)
    try:
        with open(path, "r") as f:
            data = yaml.safe_load(f) or {}
    except yaml.YAMLError as e:
        die(f"YAML parse error in {path}: {e}")
    except FileNotFoundError:
        die(f"Prompt file not found: {path}")

    # Normalize to v0.3 internal representation
    normalize_to_v03(data, path)

    # Detect asset type and output formats
    asset_type, output_formats = detect_asset_info(path, data)

    # Derive output base name
    prompt_name = Path(path).name
    if is_media_prompt(path):
        # hero.media.prompt -> hero
        name_stem = prompt_name[: -len(".media.prompt")]
    else:
        # hero.png.prompt -> hero (legacy)
        base = prompt_name[: -len(".prompt")]
        parts = base.rsplit(".", 1)
        name_stem = parts[0]

    output_dir = os.path.dirname(path)

    data["_meta"] = {
        "path": path,
        "asset_type": asset_type,
        "output_formats": output_formats,
        "name_stem": name_stem,
        "output_dir": output_dir,
        "id": data.get("id", name_stem),
        "service": data.get("service", "gemini"),
        "model": data.get("model"),
        "schema_version": detect_schema_version(data),
    }

    return data


def resolve_output_paths(prompt: dict, variant_count: int = 1) -> list[str]:
    """Return list of final output file paths (one per format).

    Variants are generated as candidates inside .genai.{filename}/ — only the
    best candidate gets hard-linked to the output path, so the output list has
    one entry per format regardless of variant_count.
    """
    meta = prompt["_meta"]
    name_stem = meta["name_stem"]
    out_dir = meta["output_dir"]
    formats = meta["output_formats"]

    paths = []
    for fmt_entry in formats:
        ext = fmt_entry.get("format", "png")
        override_name = fmt_entry.get("filename")
        stem = override_name if override_name else name_stem
        paths.append(os.path.join(out_dir, f"{stem}.{ext}"))
    return paths


# =============================================================================
# Attachment handling
# =============================================================================
MIME_MAP = {
    ".png": "image/png",
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".webp": "image/webp",
    ".gif": "image/gif",
    ".svg": "image/svg+xml",
    ".mp3": "audio/mp3",
    ".wav": "audio/wav",
    ".ogg": "audio/ogg",
    ".flac": "audio/flac",
    ".mp4": "video/mp4",
    ".webm": "video/webm",
    ".pdf": "application/pdf",
}


def resolve_mime_type(file_path: str, declared: str | None = None) -> str:
    """Resolve MIME type for an attachment file."""
    if declared:
        return declared
    ext = Path(file_path).suffix.lower()
    return MIME_MAP.get(ext, mimetypes.guess_type(file_path)[0] or "application/octet-stream")


def load_attachments(prompt_data: dict, verbose: bool = False) -> list[dict]:
    """Load and validate attachments from a prompt payload.

    Returns list of dicts with keys: path, role, mime_type, description, data_b64
    """
    attachments_raw = prompt_data.get("attachments", [])
    if not attachments_raw:
        return []

    prompt_dir = os.path.dirname(prompt_data["_meta"]["path"])
    loaded = []

    for att in attachments_raw:
        rel_path = att.get("path", "")
        if not rel_path:
            warn("Attachment with no path — skipping")
            continue

        abs_path = os.path.normpath(os.path.join(prompt_dir, rel_path))
        if not os.path.isfile(abs_path):
            die(f"Attachment not found: {abs_path}\n"
                f"   Referenced from: {prompt_data['_meta']['path']}")

        mime = resolve_mime_type(abs_path, att.get("mime_type"))

        with open(abs_path, "rb") as f:
            data_b64 = base64.b64encode(f.read()).decode("ascii")

        verbose_log(f"Loaded attachment: {rel_path} ({mime}, {att.get('role', 'reference')})", verbose)

        loaded.append({
            "path": abs_path,
            "role": att.get("role", "reference"),
            "mime_type": mime,
            "description": att.get("description", ""),
            "data_b64": data_b64,
        })

    return loaded


def validate_attachments(prompt_data: dict) -> bool:
    """Validate that all attachment files exist. Returns True if valid."""
    attachments_raw = prompt_data.get("attachments", [])
    if not attachments_raw:
        return True

    prompt_dir = os.path.dirname(prompt_data["_meta"]["path"])
    all_valid = True

    for att in attachments_raw:
        rel_path = att.get("path", "")
        if not rel_path:
            continue
        abs_path = os.path.normpath(os.path.join(prompt_dir, rel_path))
        if not os.path.isfile(abs_path):
            fail(f"Attachment not found: {abs_path}")
            all_valid = False

    return all_valid


# =============================================================================
# Dependency resolution (DAG + topological sort via Kahn's algorithm)
# =============================================================================
def build_dependency_graph(prompts: list[dict]) -> list[dict]:
    """Topologically sort prompts based on depends_on references.

    Returns prompts in generation order (dependencies first).
    """
    # Build lookup by ID and by path
    by_id: dict[str, dict] = {}
    by_path: dict[str, dict] = {}
    for p in prompts:
        pid = p["_meta"]["id"]
        ppath = p["_meta"]["path"]
        if pid in by_id:
            die(f"Duplicate prompt ID: {pid}\n"
                f"   {by_id[pid]['_meta']['path']}\n"
                f"   {ppath}")
        by_id[pid] = p
        by_path[ppath] = p

    # Build adjacency list and in-degree map
    adj: dict[str, list[str]] = defaultdict(list)  # dependency -> dependents
    in_degree: dict[str, int] = {p["_meta"]["id"]: 0 for p in prompts}

    for p in prompts:
        pid = p["_meta"]["id"]
        deps = p.get("depends_on", [])
        if not isinstance(deps, list):
            deps = [deps]

        for dep in deps:
            if isinstance(dep, dict):
                ref = dep.get("ref", "")
            else:
                ref = str(dep)

            if not ref:
                continue

            # Resolve ref: could be an ID or a relative path
            resolved_id = None
            if ref in by_id:
                resolved_id = ref
            else:
                # Try as relative path from the prompt's directory
                abs_ref = os.path.normpath(
                    os.path.join(p["_meta"]["output_dir"], ref)
                )
                if abs_ref in by_path:
                    resolved_id = by_path[abs_ref]["_meta"]["id"]

            if resolved_id is None:
                die(f"Unresolved dependency '{ref}' in {p['_meta']['path']}\n"
                    f"   Known IDs: {', '.join(sorted(by_id.keys()))}")

            if resolved_id == pid:
                die(f"Self-referencing dependency in {p['_meta']['path']}")

            adj[resolved_id].append(pid)
            in_degree[pid] = in_degree.get(pid, 0) + 1

    # Kahn's algorithm
    queue: deque[str] = deque()
    for pid, degree in in_degree.items():
        if degree == 0:
            queue.append(pid)

    sorted_ids: list[str] = []
    while queue:
        current = queue.popleft()
        sorted_ids.append(current)
        for neighbor in adj[current]:
            in_degree[neighbor] -= 1
            if in_degree[neighbor] == 0:
                queue.append(neighbor)

    if len(sorted_ids) != len(prompts):
        # Cycle detected — find the nodes involved
        remaining = set(p["_meta"]["id"] for p in prompts) - set(sorted_ids)
        die(f"Dependency cycle detected involving: {', '.join(sorted(remaining))}")

    return [by_id[pid] for pid in sorted_ids]


# =============================================================================
# Provider dispatch
# =============================================================================
DEFAULT_MODEL = "imagen-4.0-generate-001"
REFINE_MODEL = "gemini-2.0-flash"
MAX_RETRIES = 3
INITIAL_BACKOFF = 2.0  # seconds

GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions"
GROQ_VISION_MODEL = "meta-llama/llama-4-scout-17b-16e-instruct"


def extract_prompt_fields(prompt_data: dict) -> tuple[str, str | None, str | None, dict]:
    """Extract (prompt_text, negative_prompt, aspect_ratio, provider_options) from payload.

    Handles v0.3 and legacy formats uniformly (after normalization).
    """
    p = prompt_data.get("prompt", {})
    output_section = prompt_data.get("output", {})
    # Legacy fallback
    reqs = prompt_data.get("requirements", {})

    # Prompt text
    if isinstance(p, str):
        text = p
    elif isinstance(p, dict):
        text = p.get("text", "")
    else:
        text = ""

    if not text:
        die(f"No prompt text found in {prompt_data.get('_meta', {}).get('path', '(unknown)')}\n"
            f"   Provide prompt.text in the YAML payload")

    # Negative prompt
    negative = None
    if isinstance(p, dict):
        negative = p.get("negative")

    # Aspect ratio: output.dimensions.aspect_ratio (v0.3)
    #   or requirements.dimensions.aspect_ratio (legacy)
    #   or tool_hints/provider_options (legacy fallback)
    aspect = None
    dims = output_section.get("dimensions", {})
    if isinstance(dims, dict):
        aspect = dims.get("aspect_ratio")
    if not aspect:
        legacy_dims = reqs.get("dimensions", {})
        if isinstance(legacy_dims, dict):
            aspect = legacy_dims.get("aspect_ratio")
    if not aspect and isinstance(p, dict):
        opts = p.get("provider_options", {})
        if isinstance(opts, dict):
            aspect = opts.get("aspect_ratio")

    # Provider options
    provider_options = {}
    if isinstance(p, dict):
        provider_options = p.get("provider_options", {}) or {}

    return text, negative, aspect, provider_options


# =============================================================================
# Gemini provider
# =============================================================================
def generate_gemini(
    prompt_text: str,
    output_path: str,
    api_key: str,
    model: str = DEFAULT_MODEL,
    aspect_ratio: str | None = None,
    negative_prompt: str | None = None,
    provider_options: dict | None = None,
    attachments: list[dict] | None = None,
    verbose: bool = False,
) -> bool:
    """Call Gemini Imagen API to generate a single image.

    Returns True on success, False on recoverable failure.
    """
    url = (
        f"https://generativelanguage.googleapis.com/v1beta/"
        f"models/{model}:predict?key={api_key}"
    )

    body: dict = {
        "instances": [{"prompt": prompt_text}],
        "parameters": {
            "sampleCount": 1,
        },
    }
    if aspect_ratio:
        body["parameters"]["aspectRatio"] = aspect_ratio

    # Map provider_options to API parameters
    if provider_options:
        if "safety_filter_level" in provider_options:
            body["parameters"]["safetyFilterLevel"] = provider_options["safety_filter_level"]
        if "person_generation" in provider_options:
            body["parameters"]["personGeneration"] = provider_options["person_generation"]

    # Imagen 4 reference image format
    if attachments:
        ROLE_TO_REF = {
            "style":     ("REFERENCE_TYPE_STYLE",   "styleImageConfig"),
            "reference": ("REFERENCE_TYPE_STYLE",   "styleImageConfig"),
            "subject":   ("REFERENCE_TYPE_SUBJECT", "subjectImageConfig"),
            "mask":      ("REFERENCE_TYPE_MASK",    "maskImageConfig"),
        }
        ref_images = []
        for i, att in enumerate(attachments):
            ref_type, config_key = ROLE_TO_REF.get(att["role"], ROLE_TO_REF["style"])
            ref_images.append({
                "referenceImage": {
                    "bytesBase64Encoded": att["data_b64"],
                },
                "referenceType": ref_type,
                "referenceId": i + 1,
                config_key: {},
            })
        if ref_images:
            body["instances"][0]["referenceImages"] = ref_images

    data = json.dumps(body).encode("utf-8")

    verbose_log(f"POST {url.split('?')[0]}?key=***", verbose)
    verbose_log(f"Prompt: {prompt_text[:120]}{'...' if len(prompt_text) > 120 else ''}", verbose)
    if attachments:
        verbose_log(f"Attachments: {len(attachments)} file(s)", verbose)

    backoff = INITIAL_BACKOFF
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            req = urllib.request.Request(
                url,
                data=data,
                headers={"Content-Type": "application/json"},
                method="POST",
            )
            with urllib.request.urlopen(req, timeout=120) as resp:
                result = json.loads(resp.read().decode("utf-8"))

            predictions = result.get("predictions", [])
            if not predictions:
                fail(f"No predictions returned for {output_path}")
                return False

            image_b64 = predictions[0].get("bytesBase64Encoded", "")
            if not image_b64:
                fail(f"Empty image data in response for {output_path}")
                return False

            image_bytes = base64.b64decode(image_b64)
            os.makedirs(os.path.dirname(output_path) or ".", exist_ok=True)
            with open(output_path, "wb") as f:
                f.write(image_bytes)

            return True

        except urllib.error.HTTPError as e:
            status = e.code
            error_body = ""
            try:
                error_body = e.read().decode("utf-8", errors="replace")
            except Exception:
                pass

            if status == 429:
                if attempt < MAX_RETRIES:
                    warn(f"Rate limited (429), retrying in {backoff:.0f}s "
                         f"(attempt {attempt}/{MAX_RETRIES})")
                    time.sleep(backoff)
                    backoff *= 2
                    continue
                else:
                    fail(f"Rate limited after {MAX_RETRIES} retries: {output_path}")
                    return False

            elif status == 400:
                fail(f"Bad request (400) for {output_path}: {error_body[:200]}")
                return False

            elif status in (401, 403):
                die(f"Authentication failed ({status}): {error_body[:200]}\n"
                    f"   Check your GEMINI_API_KEY")

            else:
                fail(f"HTTP {status} for {output_path}: {error_body[:200]}")
                return False

        except urllib.error.URLError as e:
            fail(f"Network error for {output_path}: {e.reason}")
            if attempt < MAX_RETRIES:
                warn(f"Retrying in {backoff:.0f}s (attempt {attempt}/{MAX_RETRIES})")
                time.sleep(backoff)
                backoff *= 2
                continue
            return False

    return False


# =============================================================================
# Stub providers (not yet implemented)
# =============================================================================
def _make_stub_provider(name: str):
    """Create a stub provider function that warns and returns False."""
    def _stub(**kwargs) -> bool:
        warn(f"Provider '{name}' is not yet implemented — skipping generation")
        return False
    return _stub


# Provider dispatch table
PROVIDERS: dict[str, callable] = {
    "gemini": generate_gemini,
    "openai": _make_stub_provider("openai"),
    "stability": _make_stub_provider("stability"),
    "replicate": _make_stub_provider("replicate"),
    "ideogram": _make_stub_provider("ideogram"),
    "recraft": _make_stub_provider("recraft"),
    "midjourney": _make_stub_provider("midjourney"),
    "local": _make_stub_provider("local"),
    "fal": _make_stub_provider("fal"),
    "together": _make_stub_provider("together"),
    "fireworks": _make_stub_provider("fireworks"),
    "elevenlabs": _make_stub_provider("elevenlabs"),
    "suno": _make_stub_provider("suno"),
    "udio": _make_stub_provider("udio"),
    "bark": _make_stub_provider("bark"),
    "musicgen": _make_stub_provider("musicgen"),
    "runway": _make_stub_provider("runway"),
    "pika": _make_stub_provider("pika"),
    "kling": _make_stub_provider("kling"),
    "minimax": _make_stub_provider("minimax"),
}


# =============================================================================
# Interactive refinement
# =============================================================================
def refine_prompt_via_llm(
    original_text: str,
    feedback: str,
    api_key: str,
    model: str = REFINE_MODEL,
    verbose: bool = False,
) -> str | None:
    """Call Gemini text model to refine a prompt based on user feedback.

    Returns the refined prompt text, or None on failure.
    """
    url = (
        f"https://generativelanguage.googleapis.com/v1beta/"
        f"models/{model}:generateContent?key={api_key}"
    )

    system_instruction = (
        "You are a prompt refinement assistant for AI image generation. "
        "Given an original image generation prompt and user feedback about what to change, "
        "produce a refined prompt that incorporates the feedback. "
        "Output ONLY the refined prompt text, nothing else — no explanation, no quotes."
    )

    body = {
        "contents": [{
            "parts": [{
                "text": (
                    f"Original prompt:\n{original_text}\n\n"
                    f"User feedback:\n{feedback}\n\n"
                    f"Produce a refined prompt incorporating the feedback:"
                )
            }]
        }],
        "systemInstruction": {
            "parts": [{"text": system_instruction}]
        },
    }

    data = json.dumps(body).encode("utf-8")

    verbose_log(f"Refine: POST {url.split('?')[0]}?key=***", verbose)

    try:
        req = urllib.request.Request(
            url,
            data=data,
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        with urllib.request.urlopen(req, timeout=60) as resp:
            result = json.loads(resp.read().decode("utf-8"))

        candidates = result.get("candidates", [])
        if not candidates:
            fail("No candidates returned from refinement model")
            return None

        parts = candidates[0].get("content", {}).get("parts", [])
        if not parts:
            fail("Empty content from refinement model")
            return None

        return parts[0].get("text", "").strip()

    except (urllib.error.HTTPError, urllib.error.URLError) as e:
        fail(f"Refinement API error: {e}")
        return None


def update_prompt_file_text(prompt_path: str, old_text: str, new_text: str, feedback: str) -> bool:
    """Update prompt.text in a .media.prompt file in-place and append refinement history."""
    try:
        with open(prompt_path, "r") as f:
            content = f.read()

        # Replace the old prompt text with new
        # We do a simple string replacement in the YAML — this works for single-line
        # and multi-line text blocks as long as the text is unique
        if old_text in content:
            content = content.replace(old_text, new_text, 1)
        else:
            # Fallback: re-parse, modify, and dump (loses comments but works)
            with open(prompt_path, "r") as f:
                data = yaml.safe_load(f)
            if isinstance(data.get("prompt"), dict):
                data["prompt"]["text"] = new_text
            content = yaml.dump(data, default_flow_style=False, sort_keys=False)

        # Append refinement history as YAML comments
        now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
        history_lines = [
            "",
            "# --- Refinement History ---",
            f"# [{now}] Original: \"{old_text[:100]}{'...' if len(old_text) > 100 else ''}\"",
            f"# [{now}] Feedback: \"{feedback}\"",
            f"# [{now}] Refined: \"{new_text[:100]}{'...' if len(new_text) > 100 else ''}\"",
        ]

        # Check if there's already a refinement history section
        if "# --- Refinement History ---" in content:
            # Append new entries before the last newline
            content = content.rstrip("\n")
            content += "\n" + "\n".join(history_lines[2:]) + "\n"
        else:
            content = content.rstrip("\n") + "\n" + "\n".join(history_lines) + "\n"

        with open(prompt_path, "w") as f:
            f.write(content)

        return True
    except Exception as e:
        fail(f"Failed to update prompt file: {e}")
        return False


def interactive_refine_loop(
    prompt_data: dict,
    output_paths: list[str],
    api_key: str,
    model: str,
    variant_count: int,
    force: bool,
    verbose: bool,
) -> None:
    """Run interactive refinement loop for a single prompt."""
    prompt_text, negative, aspect, provider_options = extract_prompt_fields(prompt_data)
    meta = prompt_data["_meta"]
    service = meta["service"]

    while True:
        try:
            response = input(f"\n  {YEL}Satisfied? (y/n/feedback): {NC}").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            info("Refinement cancelled")
            return

        if not response or response.lower() in ("y", "yes"):
            ok("Accepted — moving on")
            return

        if response.lower() in ("n", "no"):
            response = input(f"  {YEL}Enter feedback: {NC}").strip()
            if not response:
                continue

        # Use feedback to refine
        step("Refining prompt via LLM")
        refined = refine_prompt_via_llm(
            original_text=prompt_text,
            feedback=response,
            api_key=api_key,
            verbose=verbose,
        )

        if not refined:
            warn("Refinement failed — keeping original prompt")
            continue

        info(f"Refined prompt: {refined[:120]}{'...' if len(refined) > 120 else ''}")

        # Update the file in-place
        if update_prompt_file_text(meta["path"], prompt_text, refined, response):
            ok(f"Updated {meta['path']}")
        else:
            warn("Could not update file — using refined prompt for this generation only")

        # Update in-memory
        if isinstance(prompt_data.get("prompt"), dict):
            prompt_data["prompt"]["text"] = refined
        prompt_text = refined

        # Regenerate into genai dir, link result
        step("Regenerating with refined prompt")
        for output_path in output_paths:
            generate_fn = PROVIDERS.get(service)
            if generate_fn and service == "gemini":
                candidate = genai_candidate_path(output_path)
                attachments = load_attachments(prompt_data, verbose)
                success = generate_fn(
                    prompt_text=refined,
                    output_path=candidate,
                    api_key=api_key,
                    model=model,
                    aspect_ratio=aspect,
                    negative_prompt=negative,
                    provider_options=provider_options,
                    attachments=attachments or None,
                    verbose=verbose,
                )
                if success:
                    link_active(candidate, output_path)
                    ok(f"Regenerated: {output_path}")
                else:
                    fail(f"Regeneration failed: {output_path}")
            elif generate_fn:
                generate_fn()
            else:
                warn(f"Unknown provider '{service}' — cannot regenerate")
                return


# =============================================================================
# .genai output management — generate into hidden dir, vision-pick best, hardlink
# =============================================================================
def genai_dir_for(output_path: str) -> Path:
    """Return the .genai.{filename}/ directory for an output path."""
    output = Path(output_path)
    return output.parent / f".genai.{output.name}"


def genai_candidate_path(output_path: str) -> str:
    """Return a unique candidate path inside .genai.{filename}/."""
    output = Path(output_path)
    gdir = genai_dir_for(output_path)
    gdir.mkdir(parents=True, exist_ok=True)
    unique_id = f"{int(time.time())}_{secrets.token_hex(4)}"
    return str(gdir / f"{unique_id}{output.suffix}")


def link_active(genai_path: str, output_path: str) -> None:
    """Hard-link a genai candidate as the active output file."""
    output = Path(output_path)
    if output.exists() or output.is_symlink():
        output.unlink()
    os.link(genai_path, str(output))


def evaluate_candidates_groq(
    candidate_paths: list[str],
    prompt_text: str,
    eval_criteria: dict | None = None,
    api_key: str = "",
    model: str = GROQ_VISION_MODEL,
    verbose: bool = False,
) -> int:
    """Send all candidate images to Groq vision model, return index of best.

    Falls back to index 0 if the API is unavailable or returns garbage.
    """
    if len(candidate_paths) <= 1:
        return 0

    if not api_key:
        warn("No GROQ_API_KEY — selecting first candidate")
        return 0

    content_parts: list[dict] = []

    criteria_text = ""
    if eval_criteria:
        criteria_lines = []
        for name, spec in eval_criteria.items():
            desc = spec.get("description", name)
            weight = spec.get("weight", "")
            criteria_lines.append(f"  - {name} (weight {weight}): {desc}")
        criteria_text = "\nEvaluation criteria:\n" + "\n".join(criteria_lines)

    content_parts.append({
        "type": "text",
        "text": (
            f"You are evaluating {len(candidate_paths)} AI-generated images.\n"
            f"The generation prompt was:\n\"{prompt_text}\"\n"
            f"{criteria_text}\n\n"
            f"Each image is labelled [Image 1], [Image 2], etc.\n"
            f"Pick the single best image. Reply with ONLY the number (e.g. 2)."
        ),
    })

    for i, cpath in enumerate(candidate_paths):
        ext = Path(cpath).suffix.lstrip(".")
        mime = MIME_MAP.get(f".{ext}", f"image/{ext}")
        try:
            with open(cpath, "rb") as f:
                b64 = base64.b64encode(f.read()).decode("ascii")
        except OSError as e:
            warn(f"Cannot read candidate {cpath}: {e}")
            continue

        content_parts.append({
            "type": "image_url",
            "image_url": {"url": f"data:{mime};base64,{b64}"},
        })
        content_parts.append({"type": "text", "text": f"[Image {i + 1}]"})

    body = {
        "model": model,
        "messages": [{"role": "user", "content": content_parts}],
        "temperature": 0,
        "max_tokens": 16,
    }

    data = json.dumps(body).encode("utf-8")
    verbose_log(f"Groq vision eval: {len(candidate_paths)} candidates via {model}", verbose)

    try:
        req = urllib.request.Request(
            GROQ_API_URL,
            data=data,
            headers={
                "Content-Type": "application/json",
                "Authorization": f"Bearer {api_key}",
            },
            method="POST",
        )
        with urllib.request.urlopen(req, timeout=120) as resp:
            result = json.loads(resp.read().decode("utf-8"))

        text = result["choices"][0]["message"]["content"].strip()
        verbose_log(f"Groq response: {text!r}", verbose)

        match = re.search(r"\d+", text)
        if match:
            idx = int(match.group()) - 1
            if 0 <= idx < len(candidate_paths):
                return idx

        warn(f"Could not parse Groq selection ({text!r}) — defaulting to first")
        return 0

    except (urllib.error.HTTPError, urllib.error.URLError) as e:
        warn(f"Groq vision eval failed: {e} — selecting first candidate")
        return 0
    except (KeyError, IndexError, json.JSONDecodeError) as e:
        warn(f"Groq response parse error: {e} — selecting first candidate")
        return 0


# =============================================================================
# Post-processing (stub)
# =============================================================================
def run_post_processing(prompt_data: dict, output_paths: list[str], verbose: bool = False) -> None:
    """Process post_processing steps from the prompt payload.

    Currently logs each step as not-yet-implemented.
    """
    steps = prompt_data.get("post_processing", [])
    if not steps:
        return

    for pp_step in steps:
        action = pp_step.get("action", "unknown")
        params = pp_step.get("params", {})
        info(f"Post-processing: {action} (not yet implemented) — params: {params}")


# =============================================================================
# Main generation pipeline
# =============================================================================
def run_generation(
    prompts: list[dict],
    variant_count: int,
    dry_run: bool,
    force: bool,
    model: str | None,
    verbose: bool,
    refine: bool,
) -> None:
    """Execute the generation pipeline."""
    api_key = os.environ.get("GEMINI_API_KEY", "")
    if not api_key and not dry_run:
        die("GEMINI_API_KEY not set")

    # Validate all attachments before starting
    step("Validating prompt files")
    for prompt in prompts:
        if not validate_attachments(prompt):
            die(f"Attachment validation failed for {prompt['_meta']['path']}")
    ok("All attachments validated")

    # Resolve dependencies and sort
    step("Resolving dependencies")
    sorted_prompts = build_dependency_graph(prompts)
    ok(f"{len(sorted_prompts)} prompt(s) in generation order")

    if verbose:
        for i, p in enumerate(sorted_prompts, 1):
            svc = p["_meta"]["service"]
            schema_v = p["_meta"]["schema_version"]
            info(f"  {i}. {p['_meta']['id']} ({p['_meta']['asset_type']}, service={svc}, schema=v{schema_v})")

    # Build generation plan
    plan: list[tuple[dict, list[str]]] = []
    total_outputs = 0
    skipped = 0

    for prompt in sorted_prompts:
        output_paths = resolve_output_paths(prompt, variant_count)
        if not force:
            remaining = []
            for op in output_paths:
                if os.path.exists(op):
                    if verbose:
                        info(f"Skipping (exists): {op}")
                    skipped += 1
                else:
                    remaining.append(op)
            output_paths = remaining

        if output_paths:
            plan.append((prompt, output_paths))
            total_outputs += len(output_paths)

    if skipped > 0:
        info(f"Skipped {skipped} existing output(s) (use --force to overwrite)")

    if not plan:
        ok("Nothing to generate — all outputs exist")
        return

    # Show plan
    step(f"Generation plan: {total_outputs} output(s) from {len(plan)} prompt(s)")
    for prompt, paths in plan:
        meta = prompt["_meta"]
        asset_type = meta["asset_type"]
        service = meta["service"]
        prompt_model = model or meta.get("model") or DEFAULT_MODEL
        prompt_text, negative, aspect, provider_options = extract_prompt_fields(prompt)

        print(f"\n  {BOLD}{meta['id']}{NC} ({asset_type}, {service})")
        print(f"    Prompt : {prompt_text[:100]}{'...' if len(prompt_text) > 100 else ''}")
        if aspect:
            print(f"    Aspect : {aspect}")
        if negative:
            print(f"    Neg.   : {negative[:80]}{'...' if len(str(negative)) > 80 else ''}")
        print(f"    Model  : {prompt_model}")
        if provider_options:
            print(f"    Options: {provider_options}")

        attachments_raw = prompt.get("attachments", [])
        if attachments_raw:
            print(f"    Attach : {len(attachments_raw)} file(s)")
            for att in attachments_raw:
                print(f"             - {att.get('path')} ({att.get('role', 'reference')})")

        post_steps = prompt.get("post_processing", [])
        if post_steps:
            print(f"    Post   : {len(post_steps)} step(s)")
            for ps in post_steps:
                print(f"             - {ps.get('action', 'unknown')}")

        for op in paths:
            print(f"    Output : {op}")

    if dry_run:
        print()
        ok("Dry run complete — no API calls made")
        return

    # Execute generation
    groq_key = os.environ.get("GROQ_API_KEY", "")
    groq_model = os.environ.get("GROQ_VISION_MODEL", GROQ_VISION_MODEL)

    step(f"Generating {total_outputs} output(s), {variant_count} candidate(s) each")
    if variant_count > 1 and not groq_key:
        warn("GROQ_API_KEY not set — will pick first candidate instead of vision-evaluating")

    succeeded = 0
    failed = 0
    gen_index = 0

    for prompt, paths in plan:
        meta = prompt["_meta"]
        asset_type = meta["asset_type"]
        service = meta["service"]
        prompt_model = model or meta.get("model") or DEFAULT_MODEL

        prompt_text, negative, aspect, provider_options = extract_prompt_fields(prompt)

        generate_fn = PROVIDERS.get(service)
        if generate_fn is None:
            warn(f"Unknown provider '{service}' for {meta['id']} — skipping")
            failed += len(paths)
            continue

        if service != "gemini":
            gen_index += len(paths)
            for output_path in paths:
                print(f"\n  {CYN}[{gen_index}/{total_outputs}]{NC} {os.path.basename(output_path)}")
            generate_fn()
            failed += len(paths)
            continue

        if asset_type != "image":
            warn(f"Skipping {meta['id']}: {asset_type} generation not yet supported via {service}")
            failed += len(paths)
            continue

        attachments = load_attachments(prompt, verbose)

        for output_path in paths:
            gen_index += 1
            basename = os.path.basename(output_path)
            print(f"\n  {CYN}[{gen_index}/{total_outputs}]{NC} {basename}")

            # Generate N candidates into .genai.{filename}/
            candidates: list[str] = []
            for v in range(variant_count):
                candidate = genai_candidate_path(output_path)
                if variant_count > 1:
                    verbose_log(f"Candidate {v + 1}/{variant_count}: {Path(candidate).name}", verbose)

                ok_gen = generate_fn(
                    prompt_text=prompt_text,
                    output_path=candidate,
                    api_key=api_key,
                    model=prompt_model,
                    aspect_ratio=aspect,
                    negative_prompt=negative,
                    provider_options=provider_options,
                    attachments=attachments or None,
                    verbose=verbose,
                )
                if ok_gen:
                    candidates.append(candidate)
                else:
                    warn(f"Candidate {v + 1} failed for {basename}")

            if not candidates:
                fail(f"All candidates failed: {output_path}")
                failed += 1
                continue

            # Pick the best candidate
            if len(candidates) > 1:
                step(f"Evaluating {len(candidates)} candidates for {basename}")
                eval_criteria = prompt.get("eval", {}).get("criteria")
                best_idx = evaluate_candidates_groq(
                    candidate_paths=candidates,
                    prompt_text=prompt_text,
                    eval_criteria=eval_criteria,
                    api_key=groq_key,
                    model=groq_model,
                    verbose=verbose,
                )
                info(f"Selected candidate {best_idx + 1} of {len(candidates)}")
            else:
                best_idx = 0

            link_active(candidates[best_idx], output_path)
            ok(f"Generated: {output_path}")
            verbose_log(f"Active link: {Path(candidates[best_idx]).name} -> {basename}", verbose)
            succeeded += 1

        # Post-processing
        run_post_processing(prompt, paths, verbose)

        # Interactive refinement
        if refine and succeeded > 0:
            interactive_refine_loop(
                prompt_data=prompt,
                output_paths=paths,
                api_key=api_key,
                model=prompt_model,
                variant_count=variant_count,
                force=force,
                verbose=verbose,
            )

    # Summary
    step("Generation complete")
    ok(f"{succeeded} succeeded")
    if failed > 0:
        fail(f"{failed} failed")
    print()


# =============================================================================
# CLI entry point
# =============================================================================
def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate media assets from .prompt YAML files",
        add_help=False,
    )
    parser.add_argument(
        "--prompts", nargs="+", required=True, help="Prompt file paths"
    )
    parser.add_argument(
        "--variants", type=int, default=1, help="Number of variants (default: 1)"
    )
    parser.add_argument(
        "--dry-run", action="store_true", help="Show plan without generating"
    )
    parser.add_argument(
        "--force", action="store_true", help="Overwrite existing outputs"
    )
    parser.add_argument(
        "--model", type=str, default=None, help="Override generation model"
    )
    parser.add_argument(
        "--verbose", action="store_true", help="Verbose output"
    )
    parser.add_argument(
        "--refine", action="store_true", help="Interactive refinement loop after generation"
    )

    args = parser.parse_args()

    model = args.model

    if args.variants < 1:
        die("Variant count must be at least 1")

    # Parse all prompt files
    step("Loading prompt files")
    prompts = []
    for path in args.prompts:
        p = parse_prompt_file(path)
        prompts.append(p)
        verbose_log(
            f"Loaded: {path} ({p['_meta']['asset_type']}, "
            f"service={p['_meta']['service']}, "
            f"schema=v{p['_meta']['schema_version']})",
            args.verbose,
        )

    ok(f"Loaded {len(prompts)} prompt file(s)")

    # Run generation
    run_generation(
        prompts=prompts,
        variant_count=args.variants,
        dry_run=args.dry_run,
        force=args.force,
        model=model,
        verbose=args.verbose,
        refine=args.refine,
    )


if __name__ == "__main__":
    main()
