"""Tests for config module."""

import os
import pytest
from pathlib import Path
from unittest.mock import patch

import sys
sys.path.insert(0, str(Path(__file__).parent.parent / "tools"))

from npl.config import Config, DEFAULT_SECTION_ORDER, get_npl_dir


class TestDefaultSectionOrder:
    """Test DEFAULT_SECTION_ORDER constant."""

    def test_has_components_key(self):
        """DEFAULT_SECTION_ORDER should have 'components' key."""
        assert "components" in DEFAULT_SECTION_ORDER

    def test_components_is_list(self):
        """Components should be a list."""
        assert isinstance(DEFAULT_SECTION_ORDER["components"], list)

    def test_contains_expected_sections(self):
        """Should contain expected section names."""
        expected = ["syntax", "directives", "prefixes"]
        for section in expected:
            assert section in DEFAULT_SECTION_ORDER["components"]


class TestConfig:
    """Test Config class."""

    def test_default_values(self):
        """Config should have sensible defaults."""
        config = Config()
        assert config.db_host == "localhost"
        assert config.db_port == "5432"
        assert config.db_name == "npl"
        assert config.db_user == "npl"

    def test_from_env_variables(self):
        """Config should read from environment variables."""
        with patch.dict(os.environ, {
            "NPL_DB_HOST": "testhost",
            "NPL_DB_PORT": "9999",
            "NPL_DB_NAME": "testdb",
            "NPL_DB_USER": "testuser",
            "NPL_DB_PASSWORD": "testpass"
        }):
            config = Config()
            assert config.db_host == "testhost"
            assert config.db_port == "9999"
            assert config.db_name == "testdb"
            assert config.db_user == "testuser"
            assert config.db_password == "testpass"

    def test_to_dict(self):
        """Config should convert to dict for psycopg2."""
        config = Config()
        d = config.to_dict()
        assert "host" in d
        assert "port" in d
        assert "database" in d
        assert "user" in d
        assert "password" in d

    def test_to_dict_maps_correctly(self):
        """to_dict should use psycopg2 key names."""
        with patch.dict(os.environ, {
            "NPL_DB_HOST": "myhost",
            "NPL_DB_NAME": "mydb"
        }):
            config = Config()
            d = config.to_dict()
            assert d["host"] == "myhost"
            assert d["database"] == "mydb"


class TestGetNplDir:
    """Test get_npl_dir function."""

    def test_explicit_path(self, tmp_path):
        """Should return explicit path when provided."""
        result = get_npl_dir(str(tmp_path))
        assert result == tmp_path

    def test_returns_path_object(self, tmp_path):
        """Should return Path object."""
        result = get_npl_dir(str(tmp_path))
        assert isinstance(result, Path)

    def test_none_returns_none_when_no_defaults_exist(self, tmp_path, monkeypatch):
        """Should return None when no default paths exist."""
        # Change to temp dir where no npl/ exists
        monkeypatch.chdir(tmp_path)
        # Mock home to non-existent path
        with patch.object(Path, 'home', return_value=tmp_path / "fakehome"):
            result = get_npl_dir(None)
            assert result is None

    def test_prefers_home_npl_over_local(self, tmp_path, monkeypatch):
        """Should prefer ~/.npl/npl over ./npl."""
        # Create both directories
        home_npl = tmp_path / "home" / ".npl" / "npl"
        home_npl.mkdir(parents=True)
        local_npl = tmp_path / "project" / "npl"
        local_npl.mkdir(parents=True)

        # Change to project dir
        monkeypatch.chdir(tmp_path / "project")

        with patch.object(Path, 'home', return_value=tmp_path / "home"):
            result = get_npl_dir(None)
            assert result == home_npl

    def test_falls_back_to_local_npl(self, tmp_path, monkeypatch):
        """Should use ./npl if ~/.npl/npl doesn't exist."""
        # Create only local directory
        local_npl = tmp_path / "npl"
        local_npl.mkdir()

        monkeypatch.chdir(tmp_path)

        with patch.object(Path, 'home', return_value=tmp_path / "fakehome"):
            result = get_npl_dir(None)
            assert result == local_npl


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
