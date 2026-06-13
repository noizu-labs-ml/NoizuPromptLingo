"""Skill file structure validator and quality evaluator.

Validates a skill markdown file (frontmatter + body) against the NPL
skill conventions defined in docs/reference/SKILL-GUIDELINE.md.

Also provides a heuristic quality evaluator (US-120) that scores a skill
across four dimensions and returns per-dimension scores plus an overall.

This is the async backend module used by the MCP tool and REST endpoint.
The CLI tool at tools/skill_validator.py validates full skill *directories*;
this module validates a single skill *file* content string.
"""

from __future__ import annotations

import re
import statistics
from typing import TypedDict

try:
    import yaml
    _HAS_YAML = True
except ImportError:
    _HAS_YAML = False


# ── Types ─────────────────────────────────────────────────────────────────

class ValidationError(TypedDict):
    severity: str   # "error" | "warning"
    field: str      # dotted path, e.g. "frontmatter.name"
    message: str


class ValidationResult(TypedDict):
    valid: bool
    errors: list[ValidationError]
    warnings: list[ValidationError]
    summary: dict


# ── Known frontmatter fields ──────────────────────────────────────────────

REQUIRED_FIELDS: list[str] = ["name", "description"]

KNOWN_FIELDS: set[str] = {
    "name",
    "description",
    "allowed-tools",
    "model",
    "argument-hint",
    # common extras that should not trigger unknown-field warnings
    "version",
    "tags",
    "category",
    "status",
    "dependencies",
}

DESCRIPTION_MIN = 10
DESCRIPTION_MAX = 400


# ── Parser helpers ────────────────────────────────────────────────────────

_FRONTMATTER_RE = re.compile(
    r"^---\s*\n(.*?)\n---\s*\n(.*)",
    re.DOTALL,
)


def _split_frontmatter(content: str) -> tuple[str | None, str]:
    """Split content into (yaml_text, body).

    Returns (None, content) when no frontmatter markers are found.
    """
    m = _FRONTMATTER_RE.match(content)
    if not m:
        return None, content
    return m.group(1), m.group(2)


# ── Core validation ───────────────────────────────────────────────────────

async def validate_skill(
    content: str,
    filename: str | None = None,
) -> ValidationResult:
    """Validate a skill file's structure and content.

    Args:
        content: Full text of the skill markdown file (frontmatter + body).
        filename: Optional filename for name-field cross-check (warning only).

    Returns:
        ValidationResult with valid flag, errors, warnings, and summary.
    """
    errors: list[ValidationError] = []
    warnings: list[ValidationError] = []
    summary: dict = {
        "yaml_parseable": False,
        "has_frontmatter": False,
        "has_body": False,
        "frontmatter_fields": [],
        "body_char_count": 0,
        "heading_count": 0,
    }

    # 1. Split frontmatter
    yaml_text, body = _split_frontmatter(content)

    if yaml_text is None:
        errors.append({
            "severity": "error",
            "field": "frontmatter",
            "message": "No YAML frontmatter found. File must start with --- markers.",
        })
        # Still evaluate body
        _check_body(body, errors, warnings, summary)
        return _build_result(errors, warnings, summary)

    summary["has_frontmatter"] = True

    # 2. Parse YAML
    if not _HAS_YAML:
        errors.append({
            "severity": "error",
            "field": "frontmatter",
            "message": "PyYAML is not installed; cannot parse frontmatter.",
        })
        _check_body(body, errors, warnings, summary)
        return _build_result(errors, warnings, summary)

    try:
        fm = yaml.safe_load(yaml_text)
    except yaml.YAMLError as exc:
        errors.append({
            "severity": "error",
            "field": "frontmatter",
            "message": f"YAML parse error: {exc}",
        })
        _check_body(body, errors, warnings, summary)
        return _build_result(errors, warnings, summary)

    summary["yaml_parseable"] = True

    if not isinstance(fm, dict):
        errors.append({
            "severity": "error",
            "field": "frontmatter",
            "message": "Frontmatter did not parse to a YAML mapping.",
        })
        _check_body(body, errors, warnings, summary)
        return _build_result(errors, warnings, summary)

    summary["frontmatter_fields"] = list(fm.keys())

    # 3. Required fields
    for field in REQUIRED_FIELDS:
        if field not in fm or fm[field] is None or str(fm[field]).strip() == "":
            errors.append({
                "severity": "error",
                "field": f"frontmatter.{field}",
                "message": f"Required field '{field}' is missing or empty.",
            })

    # 4. name vs filename cross-check (warning only)
    if "name" in fm and fm["name"] and filename:
        # Strip extension and compare
        base = filename
        for ext in (".md", ".txt", ".prompt.md"):
            if base.endswith(ext):
                base = base[: -len(ext)]
        skill_name = str(fm["name"]).strip()
        if skill_name != base:
            warnings.append({
                "severity": "warning",
                "field": "frontmatter.name",
                "message": (
                    f"Field 'name' ({skill_name!r}) does not match filename base "
                    f"({base!r}). Convention: name should match the filename."
                ),
            })

    # 5. description length check
    if "description" in fm and fm["description"]:
        desc = str(fm["description"]).strip()
        if len(desc) < DESCRIPTION_MIN:
            errors.append({
                "severity": "error",
                "field": "frontmatter.description",
                "message": (
                    f"Description is too short ({len(desc)} chars); "
                    f"minimum is {DESCRIPTION_MIN} characters."
                ),
            })
        elif len(desc) > DESCRIPTION_MAX:
            warnings.append({
                "severity": "warning",
                "field": "frontmatter.description",
                "message": (
                    f"Description is very long ({len(desc)} chars); "
                    f"consider keeping it under {DESCRIPTION_MAX} characters."
                ),
            })

    # 6. Unknown top-level fields (warning only)
    for field in fm:
        if field not in KNOWN_FIELDS:
            warnings.append({
                "severity": "warning",
                "field": f"frontmatter.{field}",
                "message": (
                    f"Unknown frontmatter field '{field}'. "
                    f"Known fields: {sorted(KNOWN_FIELDS)}."
                ),
            })

    # 7. Body checks
    _check_body(body, errors, warnings, summary)

    return _build_result(errors, warnings, summary)


def _check_body(
    body: str,
    errors: list[ValidationError],
    warnings: list[ValidationError],
    summary: dict,
) -> None:
    """Check the markdown body section."""
    stripped = body.strip()
    summary["body_char_count"] = len(stripped)
    summary["has_body"] = bool(stripped)

    if not stripped:
        errors.append({
            "severity": "error",
            "field": "body",
            "message": "Skill body is empty. Add a description of the skill behavior.",
        })
        return

    if len(stripped) < 50:
        errors.append({
            "severity": "error",
            "field": "body",
            "message": (
                f"Skill body is too short ({len(stripped)} chars). "
                "Add meaningful content describing the skill."
            ),
        })

    # Count headings
    headings = re.findall(r"^#{1,6}\s+\S", body, re.MULTILINE)
    summary["heading_count"] = len(headings)

    if not headings:
        errors.append({
            "severity": "error",
            "field": "body",
            "message": "Skill body has no headings (#). Add at least one section heading.",
        })


def _build_result(
    errors: list[ValidationError],
    warnings: list[ValidationError],
    summary: dict,
) -> ValidationResult:
    """Assemble the final ValidationResult."""
    error_only = [e for e in errors if e["severity"] == "error"]
    return {
        "valid": len(error_only) == 0,
        "errors": error_only,
        "warnings": [w for w in warnings if w["severity"] == "warning"],
        "summary": summary,
    }


# ── Quality evaluation (US-120) ──────────────────────────────────────────

# Frontmatter fields considered "recommended" for completeness scoring
RECOMMENDED_FIELDS: list[str] = [
    "allowed-tools",
    "model",
    "argument-hint",
    "version",
    "tags",
    "category",
]

# Action verbs that suggest an active, concrete description
_ACTION_VERBS = re.compile(
    r"\b(use|run|generate|create|build|check|validate|scan|search|find|"
    r"analyze|analyse|format|parse|extract|convert|update|manage|track|"
    r"provide|list|fetch|load|apply|review|write|read|execute)\b",
    re.IGNORECASE,
)


class QualityScore(TypedDict):
    dimension: str      # "description" | "examples" | "structure" | "completeness"
    score: float        # 0.0 to 1.0
    notes: list[str]    # bullet points explaining the score


class EvaluationResult(TypedDict):
    overall_score: float            # mean of dimension scores
    dimensions: list[QualityScore]
    validation: ValidationResult    # embedded US-119 result
    suggestions: list[str]          # actionable improvements


def _score_description(fm: dict | None) -> QualityScore:
    """Score the 'description' frontmatter field for length and clarity."""
    notes: list[str] = []
    if fm is None or "description" not in fm or not fm["description"]:
        return {"dimension": "description", "score": 0.0, "notes": ["No description field found"]}

    desc = str(fm["description"]).strip()
    length = len(desc)

    # Length heuristic: ideal window is 40–300 chars
    if length < 20:
        score = 0.1
        notes.append(f"Description is very short ({length} chars); aim for at least 40")
    elif length < 40:
        score = 0.4
        notes.append(f"Description is short ({length} chars); more detail helps discoverability")
    elif length > 300:
        score = 0.7
        notes.append(f"Description is long ({length} chars); consider trimming to under 300")
    else:
        score = 0.8
        notes.append(f"Description length is good ({length} chars)")

    # Bonus for action verb (+0.2, capped at 1.0)
    if _ACTION_VERBS.search(desc):
        score = min(1.0, score + 0.2)
        notes.append("Contains action verb — clear, active description")
    else:
        notes.append("No action verb found; starting with a verb (e.g. 'Generate', 'Validate') improves clarity")

    return {"dimension": "description", "score": round(score, 3), "notes": notes}


def _score_examples(body: str) -> QualityScore:
    """Score based on the number of fenced code blocks in the body."""
    notes: list[str] = []
    fenced_blocks = re.findall(r"^```", body, re.MULTILINE)
    # Each code block uses an opening + closing fence; count pairs
    block_count = len(fenced_blocks) // 2

    if block_count == 0:
        score = 0.2
        notes.append("No fenced code examples found")
        notes.append("Add at least one ``` code block to illustrate usage")
    elif block_count == 1:
        score = 0.6
        notes.append("1 code example found — moderate coverage")
        notes.append("Adding 1–2 more examples improves usability")
    elif block_count == 2:
        score = 0.85
        notes.append("2 code examples found — good coverage")
    else:
        score = 1.0
        notes.append(f"{block_count} code examples found — excellent coverage")

    return {"dimension": "examples", "score": round(score, 3), "notes": notes}


def _score_structure(body: str) -> QualityScore:
    """Score body structure: headings, sub-sections, and clear opener."""
    notes: list[str] = []
    score = 0.0

    # Count top-level and lower headings
    h1_or_h2 = re.findall(r"^#{1,2}\s+\S", body, re.MULTILINE)
    h3_plus = re.findall(r"^#{3,6}\s+\S", body, re.MULTILINE)
    all_headings = h1_or_h2 + h3_plus

    if len(all_headings) >= 2:
        score += 0.4
        notes.append(f"{len(all_headings)} heading(s) found — good section structure")
    elif len(all_headings) == 1:
        score += 0.2
        notes.append("Only 1 heading found; add more sections (## Usage, ## Examples)")
    else:
        notes.append("No headings found; structure the body with ## sections")

    if h3_plus:
        score += 0.3
        notes.append(f"{len(h3_plus)} sub-section(s) (###) found — good depth")
    else:
        notes.append("No sub-sections (###) found; consider adding sub-sections for complex topics")

    # Clear opener: first non-empty line after stripping headings is substantive
    first_lines = [l.strip() for l in body.splitlines() if l.strip() and not l.startswith("#")]
    if first_lines and len(first_lines[0]) >= 20:
        score += 0.3
        notes.append("Body has a clear opening paragraph")
    else:
        notes.append("Body lacks a clear opening paragraph; add a brief description after the first heading")

    return {"dimension": "structure", "score": round(min(score, 1.0), 3), "notes": notes}


def _score_completeness(fm: dict | None) -> QualityScore:
    """Score ratio of required + recommended frontmatter fields present."""
    notes: list[str] = []
    if fm is None:
        return {
            "dimension": "completeness",
            "score": 0.0,
            "notes": ["No frontmatter found; cannot assess completeness"],
        }

    present_required = [f for f in REQUIRED_FIELDS if f in fm and fm[f] is not None]
    present_recommended = [f for f in RECOMMENDED_FIELDS if f in fm and fm[f] is not None]
    total_fields = len(REQUIRED_FIELDS) + len(RECOMMENDED_FIELDS)
    total_present = len(present_required) + len(present_recommended)

    score = round(total_present / total_fields, 3)

    if len(present_required) < len(REQUIRED_FIELDS):
        missing_req = [f for f in REQUIRED_FIELDS if f not in present_required]
        notes.append(f"Missing required fields: {missing_req}")
    else:
        notes.append(f"All {len(REQUIRED_FIELDS)} required fields present")

    present_rec_names = present_recommended
    missing_rec = [f for f in RECOMMENDED_FIELDS if f not in fm]
    if present_rec_names:
        notes.append(f"Recommended fields present: {present_rec_names}")
    if missing_rec:
        notes.append(f"Optional fields not set: {missing_rec[:3]}{'…' if len(missing_rec) > 3 else ''}")

    return {"dimension": "completeness", "score": score, "notes": notes}


def _build_suggestions(dimensions: list[QualityScore], validation: ValidationResult) -> list[str]:
    """Generate actionable top-level suggestions from dimension scores."""
    suggestions: list[str] = []
    dim_map = {d["dimension"]: d for d in dimensions}

    if dim_map["description"]["score"] < 0.6:
        suggestions.append(
            "Improve the frontmatter 'description': aim for 40–300 chars and start with an action verb."
        )
    if dim_map["examples"]["score"] < 0.6:
        suggestions.append(
            "Add fenced code examples (``` blocks) to the body to show concrete usage."
        )
    if dim_map["structure"]["score"] < 0.6:
        suggestions.append(
            "Add more headings (## sections) and a clear opening paragraph to improve readability."
        )
    if dim_map["completeness"]["score"] < 0.5:
        suggestions.append(
            "Fill in optional frontmatter fields (allowed-tools, tags, version) to improve completeness."
        )
    if not validation["valid"]:
        suggestions.append(
            "Fix validation errors before publishing — the skill will not parse correctly as-is."
        )
    return suggestions


async def evaluate_skill(
    content: str,
    filename: str | None = None,
) -> EvaluationResult:
    """Score a skill across quality dimensions.

    Dimensions:
      - description: length / clarity heuristic (penalize <40 or >300 chars,
                     bonus for action verbs)
      - examples:    count of ``` fenced blocks in body; 0 is low, 1-2 medium,
                     3+ high
      - structure:   has >= 2 headings, has ### sub-section, has a clear opener
      - completeness: ratio of required + recommended frontmatter fields present

    Args:
        content: Full text of the skill markdown file (frontmatter + body).
        filename: Optional filename for name-field cross-check in validation.

    Returns:
        EvaluationResult with overall_score, per-dimension scores,
        embedded ValidationResult, and actionable suggestions.
    """
    validation = await validate_skill(content, filename)

    # Parse frontmatter for scoring (best-effort — may be None if YAML fails)
    yaml_text, body = _split_frontmatter(content)
    fm: dict | None = None
    if yaml_text is not None and _HAS_YAML:
        try:
            import yaml as _yaml
            parsed = _yaml.safe_load(yaml_text)
            if isinstance(parsed, dict):
                fm = parsed
        except Exception:
            pass

    dimensions: list[QualityScore] = [
        _score_description(fm),
        _score_examples(body),
        _score_structure(body),
        _score_completeness(fm),
    ]

    overall = round(statistics.mean(d["score"] for d in dimensions), 3)
    suggestions = _build_suggestions(dimensions, validation)

    return {
        "overall_score": overall,
        "dimensions": dimensions,
        "validation": validation,
        "suggestions": suggestions,
    }
