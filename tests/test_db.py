"""Tests for db module (DBManager class) - focusing on conditional logic."""

import pytest
from pathlib import Path

import sys
sys.path.insert(0, str(Path(__file__).parent.parent / "tools"))

from npl.db import DBManager


class TestDBManagerInit:
    """Test DBManager initialization."""

    def test_init_default_config(self):
        """Should use default config when none provided."""
        db = DBManager()
        assert db.config is not None
        assert "host" in db.config
        assert db.conn is None

    def test_init_custom_config(self):
        """Should accept custom config dict."""
        custom_config = {
            "host": "customhost",
            "port": "1234",
            "database": "customdb",
            "user": "customuser",
            "password": "custompass"
        }
        db = DBManager(config=custom_config)
        assert db.config == custom_config


class TestDBManagerConnect:
    """Test DBManager.connect method."""

    def test_connect_raises_without_psycopg2(self):
        """Should raise ImportError if psycopg2 not installed."""
        import npl.db as db_module
        original = db_module.HAS_PSYCOPG2

        try:
            db_module.HAS_PSYCOPG2 = False
            db = DBManager()
            with pytest.raises(ImportError) as exc_info:
                db.connect()
            assert "psycopg2" in str(exc_info.value)
        finally:
            db_module.HAS_PSYCOPG2 = original


class TestReconstructData:
    """Test reconstruct_data static method with stubbed data."""

    def test_basic_reconstruction(self):
        """Should reconstruct basic section with components."""
        sections = [
            {"id": "syntax", "name": "Syntax", "version": "1.0",
             "value": {"name": "Syntax", "brief": "Core syntax", "description": "", "purpose": ""}}
        ]
        components = [
            {"id": "syntax.placeholder", "section": "syntax",
             "value": {"name": "Placeholder", "slug": "placeholder", "brief": "Var substitution"}}
        ]

        result = DBManager.reconstruct_data(sections, components, [])

        assert "syntax" in result
        assert result["syntax"]["content"]["name"] == "Syntax"
        assert len(result["syntax"]["content"]["components"]) == 1
        assert result["syntax"]["content"]["components"][0]["name"] == "Placeholder"

    def test_separates_instructional_items(self):
        """Should separate items with _instructional flag."""
        sections = [
            {"id": "test", "name": "Test", "version": "1.0",
             "value": {"name": "Test", "brief": "", "description": "", "purpose": ""}}
        ]
        components = [
            {"id": "test.comp", "section": "test",
             "value": {"name": "Component", "slug": "comp"}},
            {"id": "test.guide", "section": "test",
             "value": {"name": "Guide", "slug": "guide", "_instructional": True}}
        ]

        result = DBManager.reconstruct_data(sections, components, [])

        assert len(result["test"]["content"]["components"]) == 1
        assert result["test"]["content"]["components"][0]["name"] == "Component"
        assert len(result["test"]["content"]["instructional"]) == 1
        assert result["test"]["content"]["instructional"][0]["name"] == "Guide"

    def test_removes_instructional_flag(self):
        """Should remove _instructional flag from output."""
        sections = [
            {"id": "test", "name": "Test", "version": "1.0",
             "value": {"name": "Test", "brief": "", "description": "", "purpose": ""}}
        ]
        components = [
            {"id": "test.guide", "section": "test",
             "value": {"name": "Guide", "type": "best-practice", "_instructional": True}}
        ]

        result = DBManager.reconstruct_data(sections, components, [])

        instr = result["test"]["content"]["instructional"][0]
        assert "_instructional" not in instr
        assert instr["type"] == "best-practice"

    def test_adds_concepts_to_npl_section(self):
        """Should add concepts to npl section."""
        sections = [
            {"id": "npl", "name": "NPL", "version": "1.0",
             "value": {"name": "NPL", "brief": "", "description": "", "purpose": ""}}
        ]
        concepts = [
            {"name": "Concept 1", "description": "First concept"},
            {"name": "Concept 2", "description": "Second concept"}
        ]

        result = DBManager.reconstruct_data(sections, [], concepts)

        assert "concepts" in result["npl"]["content"]
        assert len(result["npl"]["content"]["concepts"]) == 2

    def test_adds_section_order_to_npl(self):
        """Should add section order metadata to npl section."""
        sections = [
            {"id": "npl", "name": "NPL", "version": "1.0",
             "value": {"name": "NPL", "brief": "", "description": "", "purpose": ""}}
        ]
        section_order = {"components": ["a", "b", "c"]}

        result = DBManager.reconstruct_data(sections, [], [], section_order)

        assert "npl" in result["npl"]["content"]
        assert result["npl"]["content"]["npl"]["section_order"] == section_order

    def test_empty_sections(self):
        """Should handle empty sections list."""
        result = DBManager.reconstruct_data([], [], [])
        assert result == {}

    def test_section_with_no_components(self):
        """Should handle section with no components."""
        sections = [
            {"id": "empty", "name": "Empty", "version": "1.0",
             "value": {"name": "Empty", "brief": "", "description": "", "purpose": ""}}
        ]

        result = DBManager.reconstruct_data(sections, [], [])

        assert "empty" in result
        assert result["empty"]["content"]["components"] == []
        assert result["empty"]["content"]["instructional"] == []


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
