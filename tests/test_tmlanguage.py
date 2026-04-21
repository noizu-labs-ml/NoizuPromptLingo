"""Tests for the npl-tmlanguage generator (US-222)."""

from __future__ import annotations

import json
import re
from pathlib import Path

import pytest
import yaml

from npl_mcp.scripts.tmlanguage import (
    build_grammar,
    extract_pump_tags,
    main,
    render_grammar,
)


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

@pytest.fixture
def conventions_dir(tmp_path: Path) -> Path:
    """Create a minimal conventions directory with a pumps.yaml."""
    conv = tmp_path / "conventions"
    conv.mkdir()

    pumps = {
        "name": "pumps",
        "components": [
            {
                "name": "Intent Declaration",
                "slug": "intent-declaration",
                "syntax": [
                    {"name": "intent-block", "syntax": "<npl-intent>\n  ...\n</npl-intent>"},
                ],
            },
            {
                "name": "Chain of Thought",
                "slug": "chain-of-thought",
                "syntax": [
                    {"name": "cot-block", "syntax": "<npl-cot>\n  ...\n</npl-cot>"},
                ],
            },
            {
                "name": "Mood",
                "slug": "mood",
                "syntax": [
                    {"name": "mood-self", "syntax": '<npl-mood mood="..." />'},
                ],
            },
        ],
    }
    (conv / "pumps.yaml").write_text(yaml.safe_dump(pumps), encoding="utf-8")
    return conv


@pytest.fixture
def empty_conventions_dir(tmp_path: Path) -> Path:
    conv = tmp_path / "empty-conv"
    conv.mkdir()
    return conv


# ---------------------------------------------------------------------------
# Pump tag extraction
# ---------------------------------------------------------------------------

class TestExtractPumpTags:
    def test_extracts_block_and_self_closing_tags(self, conventions_dir: Path):
        pumps = yaml.safe_load((conventions_dir / "pumps.yaml").read_text())
        tags = extract_pump_tags(pumps)
        assert "npl-intent" in tags
        assert "npl-cot" in tags
        assert "npl-mood" in tags

    def test_returns_sorted_unique_tags(self):
        pumps = {
            "components": [
                {"syntax": [{"syntax": "<npl-bbb>"}]},
                {"syntax": [{"syntax": "<npl-aaa>"}]},
                {"syntax": [{"syntax": "<npl-aaa>"}]},
            ]
        }
        tags = extract_pump_tags(pumps)
        assert tags == ["npl-aaa", "npl-bbb"]

    def test_empty_pumps_returns_empty(self):
        assert extract_pump_tags({}) == []
        assert extract_pump_tags({"components": []}) == []

    def test_handles_malformed_entries(self):
        # Non-dict components, non-dict syntax entries, non-string syntax values
        pumps = {
            "components": [
                "not-a-dict",
                {"syntax": ["not-a-dict"]},
                {"syntax": [{"syntax": 123}]},
                {"syntax": [{"syntax": "<npl-valid>"}]},
            ]
        }
        assert extract_pump_tags(pumps) == ["npl-valid"]


# ---------------------------------------------------------------------------
# Grammar structure
# ---------------------------------------------------------------------------

class TestBuildGrammar:
    def test_has_required_top_level_fields(self, conventions_dir: Path):
        g = build_grammar(conventions_dir)
        assert g["scopeName"] == "source.npl"
        assert g["name"]
        assert isinstance(g["patterns"], list) and len(g["patterns"]) > 0
        assert isinstance(g["repository"], dict)

    def test_repository_has_all_named_sections(self, conventions_dir: Path):
        g = build_grammar(conventions_dir)
        expected = {
            "framework-markers", "agent-markers", "pumps",
            "directives", "prefixes", "placeholders", "in-fill",
            "qualifiers", "highlights", "attention",
        }
        assert expected.issubset(set(g["repository"].keys()))

    def test_patterns_reference_only_existing_repository_keys(self, conventions_dir: Path):
        g = build_grammar(conventions_dir)
        repo_keys = set(g["repository"].keys())
        for p in g["patterns"]:
            if "include" in p:
                ref = p["include"].lstrip("#")
                assert ref in repo_keys, f"Pattern references missing repo key: {ref}"

    def test_pump_regex_uses_extracted_tags(self, conventions_dir: Path):
        g = build_grammar(conventions_dir)
        pump_block = g["repository"]["pumps"]["patterns"][0]
        # The begin regex should contain all extracted tags
        assert "npl-intent" in pump_block["begin"]
        assert "npl-cot" in pump_block["begin"]

    def test_falls_back_to_permissive_regex_when_no_tags(self, empty_conventions_dir: Path):
        g = build_grammar(empty_conventions_dir)
        pump_block = g["repository"]["pumps"]["patterns"][0]
        # Fallback pattern should accept any npl-* tag
        assert "npl-[a-z0-9-]+" in pump_block["begin"]

    def test_all_patterns_compile_as_python_regex(self, conventions_dir: Path):
        g = build_grammar(conventions_dir)
        for section_name, section in g["repository"].items():
            for pattern in section.get("patterns", []):
                for key in ("match", "begin", "end"):
                    if key in pattern:
                        # Just verify it compiles — tmLanguage uses Oniguruma but
                        # our regexes are also valid Python regex.
                        re.compile(pattern[key])


# ---------------------------------------------------------------------------
# Rendered JSON
# ---------------------------------------------------------------------------

class TestRenderGrammar:
    def test_rendered_is_valid_json(self, conventions_dir: Path):
        rendered = render_grammar(conventions_dir)
        parsed = json.loads(rendered)
        assert parsed["scopeName"] == "source.npl"

    def test_rendered_ends_with_newline(self, conventions_dir: Path):
        rendered = render_grammar(conventions_dir)
        assert rendered.endswith("\n")

    def test_rendered_is_deterministic(self, conventions_dir: Path):
        a = render_grammar(conventions_dir)
        b = render_grammar(conventions_dir)
        assert a == b


# ---------------------------------------------------------------------------
# CLI (main)
# ---------------------------------------------------------------------------

class TestMainCLI:
    def test_stdout_flag(self, conventions_dir: Path, capsys):
        rc = main(["--conventions", str(conventions_dir), "--stdout"])
        assert rc == 0
        captured = capsys.readouterr()
        parsed = json.loads(captured.out)
        assert parsed["scopeName"] == "source.npl"

    def test_writes_output_file(self, conventions_dir: Path, tmp_path: Path):
        out = tmp_path / "nested" / "npl.tmLanguage.json"
        rc = main(["--conventions", str(conventions_dir), "--out", str(out)])
        assert rc == 0
        assert out.exists()
        parsed = json.loads(out.read_text())
        assert parsed["scopeName"] == "source.npl"

    def test_check_reports_missing_file(self, conventions_dir: Path, tmp_path: Path, capsys):
        out = tmp_path / "nope.json"
        rc = main(["--conventions", str(conventions_dir), "--out", str(out), "--check"])
        assert rc == 1
        err = capsys.readouterr().err
        assert "does not exist" in err

    def test_check_reports_up_to_date(self, conventions_dir: Path, tmp_path: Path, capsys):
        out = tmp_path / "grammar.json"
        # First write
        assert main(["--conventions", str(conventions_dir), "--out", str(out)]) == 0
        # Then check
        rc = main(["--conventions", str(conventions_dir), "--out", str(out), "--check"])
        assert rc == 0
        assert "up to date" in capsys.readouterr().out

    def test_check_reports_stale(self, conventions_dir: Path, tmp_path: Path, capsys):
        out = tmp_path / "grammar.json"
        out.write_text('{"stale": true}\n', encoding="utf-8")
        rc = main(["--conventions", str(conventions_dir), "--out", str(out), "--check"])
        assert rc == 1
        assert "stale" in capsys.readouterr().err
