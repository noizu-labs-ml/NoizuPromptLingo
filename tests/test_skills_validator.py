"""Tests for the skill file structure validator (US-119) and quality evaluator (US-120).

Covers:
- npl_mcp.skills.validator.validate_skill and POST /api/skills/validate
- npl_mcp.skills.validator.evaluate_skill and POST /api/skills/evaluate
"""

from __future__ import annotations

import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport

from npl_mcp.skills.validator import validate_skill, evaluate_skill


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

VALID_SKILL = """\
---
name: my-skill
description: A minimal valid skill for testing purposes only.
---

# My Skill

This skill does something useful.

## Usage

Use it like this.
"""

MINIMAL_VALID_SKILL = """\
---
name: sample-skill
description: Short but valid description here.
---

# Sample Skill

A brief description of what this skill accomplishes.
"""


# ---------------------------------------------------------------------------
# Unit tests: validate_skill()
# ---------------------------------------------------------------------------

class TestValidSkill:
    """A well-formed skill passes with no errors."""

    @pytest.mark.asyncio
    async def test_valid_skill_passes(self):
        result = await validate_skill(VALID_SKILL)
        assert result["valid"] is True
        assert result["errors"] == []

    @pytest.mark.asyncio
    async def test_valid_skill_has_summary_keys(self):
        result = await validate_skill(VALID_SKILL)
        summary = result["summary"]
        assert summary["yaml_parseable"] is True
        assert summary["has_frontmatter"] is True
        assert summary["has_body"] is True
        assert summary["heading_count"] >= 1


class TestMissingFrontmatter:
    """Content with no YAML frontmatter markers returns an error."""

    @pytest.mark.asyncio
    async def test_no_frontmatter_is_invalid(self):
        content = "# Just a heading\n\nNo frontmatter at all.\n"
        result = await validate_skill(content)
        assert result["valid"] is False
        fields = [e["field"] for e in result["errors"]]
        assert "frontmatter" in fields

    @pytest.mark.asyncio
    async def test_no_frontmatter_error_message(self):
        content = "# Heading\n\nBody only.\n"
        result = await validate_skill(content)
        err = next(e for e in result["errors"] if e["field"] == "frontmatter")
        assert "---" in err["message"] or "frontmatter" in err["message"].lower()


class TestMissingRequiredFields:
    """Missing name or description → error."""

    @pytest.mark.asyncio
    async def test_missing_name_is_error(self):
        content = """\
---
description: A description without a name field.
---

# Skill Without Name

Some body content here.
"""
        result = await validate_skill(content)
        assert result["valid"] is False
        fields = [e["field"] for e in result["errors"]]
        assert "frontmatter.name" in fields

    @pytest.mark.asyncio
    async def test_missing_description_is_error(self):
        content = """\
---
name: my-skill
---

# Skill Without Description

Some body content here.
"""
        result = await validate_skill(content)
        assert result["valid"] is False
        fields = [e["field"] for e in result["errors"]]
        assert "frontmatter.description" in fields

    @pytest.mark.asyncio
    async def test_both_fields_missing_both_reported(self):
        content = """\
---
allowed-tools: []
---

# Minimal Skill

Body text here.
"""
        result = await validate_skill(content)
        assert result["valid"] is False
        fields = [e["field"] for e in result["errors"]]
        assert "frontmatter.name" in fields
        assert "frontmatter.description" in fields


class TestNameMismatch:
    """name ≠ filename basename → warning, still valid."""

    @pytest.mark.asyncio
    async def test_name_mismatch_is_warning_not_error(self):
        content = """\
---
name: wrong-name
description: A skill whose name does not match its filename.
---

# Skill

Body content that is long enough to pass.
"""
        result = await validate_skill(content, filename="my-skill.md")
        assert result["valid"] is True
        warn_fields = [w["field"] for w in result["warnings"]]
        assert "frontmatter.name" in warn_fields

    @pytest.mark.asyncio
    async def test_name_match_no_warning(self):
        content = """\
---
name: my-skill
description: Description that matches the filename.
---

# My Skill

Body content here that is long enough to pass the minimum length check.
"""
        result = await validate_skill(content, filename="my-skill.md")
        assert result["valid"] is True
        warn_fields = [w["field"] for w in result["warnings"]]
        assert "frontmatter.name" not in warn_fields


class TestUnknownField:
    """Unknown top-level frontmatter fields → warning."""

    @pytest.mark.asyncio
    async def test_unknown_field_is_warning(self):
        content = """\
---
name: my-skill
description: A valid description for the skill.
foobar: unexpected
---

# Skill

Body content here that is long enough to pass the minimum body length requirement.
"""
        result = await validate_skill(content)
        assert result["valid"] is True
        warn_fields = [w["field"] for w in result["warnings"]]
        assert "frontmatter.foobar" in warn_fields


class TestEmptyBody:
    """Empty body (no content after frontmatter) → error."""

    @pytest.mark.asyncio
    async def test_empty_body_is_error(self):
        content = """\
---
name: my-skill
description: A valid description for the skill here.
---
"""
        result = await validate_skill(content)
        assert result["valid"] is False
        fields = [e["field"] for e in result["errors"]]
        assert "body" in fields

    @pytest.mark.asyncio
    async def test_body_too_short_is_error(self):
        content = """\
---
name: my-skill
description: A valid description for the skill here.
---

Hi.
"""
        result = await validate_skill(content)
        assert result["valid"] is False
        body_errors = [e for e in result["errors"] if e["field"] == "body"]
        assert any("short" in e["message"].lower() or "empty" in e["message"].lower()
                   for e in body_errors)


class TestYAMLParseError:
    """Malformed YAML frontmatter → error with clear message."""

    @pytest.mark.asyncio
    async def test_invalid_yaml_is_error(self):
        content = """\
---
name: my-skill
description: [unclosed bracket
  badly: indented: colon: mess
---

# Heading

Body text here.
"""
        result = await validate_skill(content)
        assert result["valid"] is False
        fields = [e["field"] for e in result["errors"]]
        assert "frontmatter" in fields

    @pytest.mark.asyncio
    async def test_yaml_error_message_mentions_yaml(self):
        content = """\
---
: bad key
  broken: yaml: here: {{ }}
---

# Heading

Body text.
"""
        result = await validate_skill(content)
        # Either parse error or missing required fields
        assert result["valid"] is False


class TestNoHeading:
    """Body with no headings → error."""

    @pytest.mark.asyncio
    async def test_no_heading_is_error(self):
        content = """\
---
name: my-skill
description: A valid description for this skill.
---

This is a body without any heading markers.
It has enough characters to pass the length check.
But it has zero headings so it should fail.
"""
        result = await validate_skill(content)
        assert result["valid"] is False
        fields = [e["field"] for e in result["errors"]]
        assert "body" in fields


# ---------------------------------------------------------------------------
# REST endpoint tests: POST /api/skills/validate
# ---------------------------------------------------------------------------

@pytest.fixture()
def _asgi_app():
    """Build the ASGI app for REST testing."""
    from npl_mcp.launcher import create_asgi_app
    return create_asgi_app()


@pytest.mark.asyncio
async def test_rest_validate_valid_skill(_asgi_app):
    """POST /api/skills/validate with valid body returns 200 and valid=true."""
    async with AsyncClient(
        transport=ASGITransport(app=_asgi_app),
        base_url="http://test",
    ) as client:
        resp = await client.post(
            "/api/skills/validate",
            json={"content": VALID_SKILL, "filename": "my-skill.md"},
        )
    assert resp.status_code == 200
    data = resp.json()
    assert data["valid"] is True
    assert "errors" in data
    assert "warnings" in data
    assert "summary" in data


@pytest.mark.asyncio
async def test_rest_validate_invalid_skill(_asgi_app):
    """POST /api/skills/validate with missing frontmatter returns 200 but valid=false."""
    async with AsyncClient(
        transport=ASGITransport(app=_asgi_app),
        base_url="http://test",
    ) as client:
        resp = await client.post(
            "/api/skills/validate",
            json={"content": "# No frontmatter here\n\nJust a plain body.\n"},
        )
    assert resp.status_code == 200
    data = resp.json()
    assert data["valid"] is False
    assert len(data["errors"]) > 0


# ---------------------------------------------------------------------------
# Unit tests: evaluate_skill() — US-120
# ---------------------------------------------------------------------------

# High-quality skill with all recommended frontmatter and multiple examples
HIGH_QUALITY_SKILL = """\
---
name: high-quality-skill
description: Generate a structured report from raw data using template rules.
allowed-tools: []
version: "1.0"
tags: [report, generation]
category: Reporting
---

# High Quality Skill

**Generate structured reports from raw input data.**

---

## Overview

This skill converts raw data into formatted reports by applying template rules.

Use when you need consistent output formatting across datasets.

## Usage

Provide a data source and a template. The skill returns a rendered report.

### Example: Basic Report

```yaml
input: raw_data.json
template: report_template.md
```

### Example: Custom Format

```python
result = skill.run(data=my_data, format="pdf")
```

### Example: Batch Processing

```bash
skill --input data/ --output reports/
```

## Common Mistakes to Avoid

| Mistake | Prevention |
|---------|-----------|
| Missing template | Always specify a template file |
"""

# Minimal content that should score low overall
POOR_QUALITY_SKILL = """\
---
name: poor-skill
description: Does stuff.
---

# Poor Skill

It does stuff.
"""


class TestEvaluateHighQualitySkill:
    """High-quality skill scores above 0.7 overall."""

    @pytest.mark.asyncio
    async def test_high_quality_overall_score(self):
        result = await evaluate_skill(HIGH_QUALITY_SKILL)
        assert result["overall_score"] > 0.7, (
            f"Expected overall_score > 0.7, got {result['overall_score']}"
        )

    @pytest.mark.asyncio
    async def test_high_quality_has_required_keys(self):
        result = await evaluate_skill(HIGH_QUALITY_SKILL)
        assert "overall_score" in result
        assert "dimensions" in result
        assert "validation" in result
        assert "suggestions" in result

    @pytest.mark.asyncio
    async def test_high_quality_has_four_dimensions(self):
        result = await evaluate_skill(HIGH_QUALITY_SKILL)
        dim_names = {d["dimension"] for d in result["dimensions"]}
        assert dim_names == {"description", "examples", "structure", "completeness"}

    @pytest.mark.asyncio
    async def test_high_quality_all_scores_in_range(self):
        result = await evaluate_skill(HIGH_QUALITY_SKILL)
        for dim in result["dimensions"]:
            assert 0.0 <= dim["score"] <= 1.0, (
                f"Dimension {dim['dimension']} score {dim['score']} out of range"
            )
            assert isinstance(dim["notes"], list)

    @pytest.mark.asyncio
    async def test_high_quality_examples_score_high(self):
        result = await evaluate_skill(HIGH_QUALITY_SKILL)
        examples_dim = next(d for d in result["dimensions"] if d["dimension"] == "examples")
        assert examples_dim["score"] >= 0.8, (
            f"Expected examples score >= 0.8, got {examples_dim['score']}"
        )

    @pytest.mark.asyncio
    async def test_high_quality_embeds_validation(self):
        result = await evaluate_skill(HIGH_QUALITY_SKILL)
        validation = result["validation"]
        assert "valid" in validation
        assert "errors" in validation
        assert "warnings" in validation


class TestEvaluateEmptyBody:
    """Empty body → low overall score, validation errors embedded."""

    @pytest.mark.asyncio
    async def test_empty_body_low_score(self):
        content = """\
---
name: my-skill
description: A valid description.
---
"""
        result = await evaluate_skill(content)
        # Overall should be low because structure and examples are both minimal
        assert result["overall_score"] < 0.7

    @pytest.mark.asyncio
    async def test_empty_body_validation_errors_present(self):
        content = """\
---
name: my-skill
description: A valid description.
---
"""
        result = await evaluate_skill(content)
        validation = result["validation"]
        assert not validation["valid"]
        assert len(validation["errors"]) > 0

    @pytest.mark.asyncio
    async def test_empty_body_has_suggestions(self):
        content = """\
---
name: my-skill
description: A valid description.
---
"""
        result = await evaluate_skill(content)
        # Should suggest fixing validation errors
        assert len(result["suggestions"]) > 0


class TestEvaluateDescriptionDimension:
    """Description dimension score reflects description quality."""

    @pytest.mark.asyncio
    async def test_short_description_low_score(self):
        """A very short description should score below 0.5."""
        content = """\
---
name: my-skill
description: hi
---

# Skill

Some body content that is long enough to pass the minimum length check.
"""
        result = await evaluate_skill(content)
        desc_dim = next(d for d in result["dimensions"] if d["dimension"] == "description")
        assert desc_dim["score"] < 0.5, (
            f"Expected description score < 0.5 for short desc, got {desc_dim['score']}"
        )

    @pytest.mark.asyncio
    async def test_action_verb_boosts_description_score(self):
        """A description with an action verb should score higher than without."""
        without_verb = """\
---
name: my-skill
description: A tool for managing configuration of your project files here.
---

# Skill

Body content that is long enough to pass the minimum check requirement.
"""
        with_verb = """\
---
name: my-skill
description: Generate configuration files for your project from a template.
---

# Skill

Body content that is long enough to pass the minimum check requirement.
"""
        result_without = await evaluate_skill(without_verb)
        result_with = await evaluate_skill(with_verb)
        desc_without = next(d for d in result_without["dimensions"] if d["dimension"] == "description")
        desc_with = next(d for d in result_with["dimensions"] if d["dimension"] == "description")
        assert desc_with["score"] >= desc_without["score"], (
            f"Action verb should not reduce score: {desc_with['score']} vs {desc_without['score']}"
        )


class TestEvaluateExamplesDimension:
    """Examples dimension score gates based on fenced block count."""

    @pytest.mark.asyncio
    async def test_no_examples_low_score(self):
        content = """\
---
name: my-skill
description: A well-described skill without code examples included.
---

# Skill

## Overview

This skill does something useful for the user.

## Usage

Use it like this: provide input, get output.
"""
        result = await evaluate_skill(content)
        examples_dim = next(d for d in result["dimensions"] if d["dimension"] == "examples")
        assert examples_dim["score"] <= 0.3, (
            f"Expected examples score <= 0.3 with no code blocks, got {examples_dim['score']}"
        )

    @pytest.mark.asyncio
    async def test_three_examples_high_score(self):
        content = """\
---
name: my-skill
description: Generate configuration files from templates using this skill.
---

# Skill

## Usage

```yaml
input: data.json
```

```python
result = skill.run()
```

```bash
skill --help
```
"""
        result = await evaluate_skill(content)
        examples_dim = next(d for d in result["dimensions"] if d["dimension"] == "examples")
        assert examples_dim["score"] >= 0.9, (
            f"Expected examples score >= 0.9 with 3 code blocks, got {examples_dim['score']}"
        )

    @pytest.mark.asyncio
    async def test_one_example_medium_score(self):
        content = """\
---
name: my-skill
description: Generate configuration files from templates using this skill.
---

# Skill

## Usage

```yaml
input: data.json
```
"""
        result = await evaluate_skill(content)
        examples_dim = next(d for d in result["dimensions"] if d["dimension"] == "examples")
        assert 0.4 <= examples_dim["score"] <= 0.8, (
            f"Expected examples score in [0.4, 0.8] with 1 code block, got {examples_dim['score']}"
        )


# ---------------------------------------------------------------------------
# REST endpoint tests: POST /api/skills/evaluate
# ---------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_rest_evaluate_valid_skill(_asgi_app):
    """POST /api/skills/evaluate returns 200 with EvaluationResult JSON."""
    async with AsyncClient(
        transport=ASGITransport(app=_asgi_app),
        base_url="http://test",
    ) as client:
        resp = await client.post(
            "/api/skills/evaluate",
            json={"content": VALID_SKILL, "filename": "my-skill.md"},
        )
    assert resp.status_code == 200
    data = resp.json()
    assert "overall_score" in data
    assert "dimensions" in data
    assert "validation" in data
    assert "suggestions" in data
    assert isinstance(data["overall_score"], float)
    assert 0.0 <= data["overall_score"] <= 1.0


@pytest.mark.asyncio
async def test_rest_evaluate_returns_four_dimensions(_asgi_app):
    """POST /api/skills/evaluate always returns exactly 4 dimensions."""
    async with AsyncClient(
        transport=ASGITransport(app=_asgi_app),
        base_url="http://test",
    ) as client:
        resp = await client.post(
            "/api/skills/evaluate",
            json={"content": HIGH_QUALITY_SKILL},
        )
    assert resp.status_code == 200
    data = resp.json()
    assert len(data["dimensions"]) == 4
    dim_names = {d["dimension"] for d in data["dimensions"]}
    assert dim_names == {"description", "examples", "structure", "completeness"}


@pytest.mark.asyncio
async def test_rest_evaluate_high_quality_skill(_asgi_app):
    """POST /api/skills/evaluate with high-quality skill returns overall_score > 0.7."""
    async with AsyncClient(
        transport=ASGITransport(app=_asgi_app),
        base_url="http://test",
    ) as client:
        resp = await client.post(
            "/api/skills/evaluate",
            json={"content": HIGH_QUALITY_SKILL},
        )
    assert resp.status_code == 200
    data = resp.json()
    assert data["overall_score"] > 0.7
