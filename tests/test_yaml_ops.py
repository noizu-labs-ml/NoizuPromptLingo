"""Tests for yaml_ops module."""

import pytest
from pathlib import Path

import sys
sys.path.insert(0, str(Path(__file__).parent.parent / "tools"))

from npl.yaml_ops import YAMLLoader


class TestSlugify:
    """Test YAMLLoader.slugify static method."""

    def test_basic_slugify(self):
        assert YAMLLoader.slugify("Hello World") == "hello-world"
        assert YAMLLoader.slugify("Test Name") == "test-name"

    def test_special_characters(self):
        assert YAMLLoader.slugify("Hello! World?") == "hello-world"
        assert YAMLLoader.slugify("Test (Name)") == "test-name"
        assert YAMLLoader.slugify("NPL@1.0") == "npl10"

    def test_multiple_spaces(self):
        assert YAMLLoader.slugify("Hello   World") == "hello-world"

    def test_underscores(self):
        assert YAMLLoader.slugify("hello_world") == "hello-world"

    def test_already_slug(self):
        assert YAMLLoader.slugify("hello-world") == "hello-world"

    def test_leading_trailing_spaces(self):
        assert YAMLLoader.slugify("  spaces  ") == "spaces"

    def test_empty_string(self):
        assert YAMLLoader.slugify("") == ""


class TestYAMLLoaderInit:
    """Test YAMLLoader initialization."""

    def test_init_with_path(self, tmp_path):
        """Should accept a Path object."""
        loader = YAMLLoader(tmp_path)
        assert loader.npl_dir == tmp_path

    def test_init_with_string(self, tmp_path):
        """Should accept a string path and convert to Path."""
        loader = YAMLLoader(str(tmp_path))
        assert loader.npl_dir == tmp_path
        assert isinstance(loader.npl_dir, Path)


class TestLoadFile:
    """Test YAMLLoader.load_file method."""

    def test_load_valid_yaml(self, tmp_path):
        """Should load and parse valid YAML."""
        yaml_file = tmp_path / "test.yaml"
        yaml_file.write_text("name: test\nvalue: 123")

        loader = YAMLLoader(tmp_path)
        result = loader.load_file(yaml_file)

        assert result == {"name": "test", "value": 123}

    def test_load_nonexistent_file(self, tmp_path):
        """Should return None for missing files."""
        loader = YAMLLoader(tmp_path)
        result = loader.load_file(tmp_path / "missing.yaml")
        assert result is None

    def test_load_empty_file(self, tmp_path):
        """Should return None for empty files."""
        yaml_file = tmp_path / "empty.yaml"
        yaml_file.write_text("")

        loader = YAMLLoader(tmp_path)
        result = loader.load_file(yaml_file)
        assert result is None


class TestLoadAll:
    """Test YAMLLoader.load_all method."""

    def test_load_all_from_directory(self, tmp_path):
        """Should load all YAML files in directory."""
        # Create test files
        (tmp_path / "file1.yaml").write_text("name: File One")
        (tmp_path / "file2.yaml").write_text("name: File Two")

        loader = YAMLLoader(tmp_path)
        result = loader.load_all()

        assert "file1" in result
        assert "file2" in result
        assert result["file1"]["content"]["name"] == "File One"
        assert result["file2"]["content"]["name"] == "File Two"

    def test_load_all_includes_metadata(self, tmp_path):
        """Should include path, filename, and digest metadata."""
        (tmp_path / "test.yaml").write_text("name: Test")

        loader = YAMLLoader(tmp_path)
        result = loader.load_all()

        assert "test" in result
        assert "path" in result["test"]
        assert "filename" in result["test"]
        assert "digest" in result["test"]
        assert "content" in result["test"]
        assert result["test"]["filename"] == "test.yaml"

    def test_load_all_recursive(self, tmp_path):
        """Should load YAML files from subdirectories."""
        subdir = tmp_path / "subdir"
        subdir.mkdir()
        (subdir / "nested.yaml").write_text("name: Nested")

        loader = YAMLLoader(tmp_path)
        result = loader.load_all()

        assert "subdir.nested" in result
        assert result["subdir.nested"]["content"]["name"] == "Nested"

    def test_load_all_empty_directory(self, tmp_path):
        """Should return empty dict for directory with no YAML files."""
        loader = YAMLLoader(tmp_path)
        result = loader.load_all()
        assert result == {}

    def test_load_all_nonexistent_directory(self, tmp_path):
        """Should return empty dict for nonexistent directory."""
        loader = YAMLLoader(tmp_path / "nonexistent")
        result = loader.load_all()
        assert result == {}

    def test_digest_changes_with_content(self, tmp_path):
        """Digest should change when file content changes."""
        yaml_file = tmp_path / "test.yaml"
        yaml_file.write_text("name: Version 1")

        loader = YAMLLoader(tmp_path)
        result1 = loader.load_all()
        digest1 = result1["test"]["digest"]

        yaml_file.write_text("name: Version 2")
        result2 = loader.load_all()
        digest2 = result2["test"]["digest"]

        assert digest1 != digest2


class TestComputeDigest:
    """Test YAMLLoader.compute_digest method."""

    def test_digest_is_hex_string(self, tmp_path):
        """Digest should be a hex string."""
        loader = YAMLLoader(tmp_path)
        digest = loader.compute_digest({"name": "test"})

        assert isinstance(digest, str)
        assert len(digest) == 64  # SHA256 hex length
        assert all(c in "0123456789abcdef" for c in digest)

    def test_same_content_same_digest(self, tmp_path):
        """Same content should produce same digest."""
        loader = YAMLLoader(tmp_path)
        d1 = loader.compute_digest({"name": "test", "value": 1})
        d2 = loader.compute_digest({"name": "test", "value": 1})
        assert d1 == d2

    def test_different_content_different_digest(self, tmp_path):
        """Different content should produce different digest."""
        loader = YAMLLoader(tmp_path)
        d1 = loader.compute_digest({"name": "test1"})
        d2 = loader.compute_digest({"name": "test2"})
        assert d1 != d2

    def test_key_order_doesnt_matter(self, tmp_path):
        """Key order should not affect digest (sorted internally)."""
        loader = YAMLLoader(tmp_path)
        d1 = loader.compute_digest({"a": 1, "b": 2})
        d2 = loader.compute_digest({"b": 2, "a": 1})
        assert d1 == d2


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
