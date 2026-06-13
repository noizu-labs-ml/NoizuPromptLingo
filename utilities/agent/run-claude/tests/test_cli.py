"""Tests for run_claude.cli module."""

import pytest
from unittest.mock import patch
from run_claude.cli import main


class TestMain:
    """Tests for main CLI entry point."""

    def test_no_args_shows_help(self, capsys):
        """Running without arguments should show help and exit 0."""
        with patch("sys.argv", ["run-claude"]):
            result = main()
        assert result == 0
        captured = capsys.readouterr()
        assert "usage:" in captured.out.lower() or "run-claude" in captured.out

    def test_invalid_command_exits_with_error(self, capsys):
        """Running with invalid command should exit with error."""
        with patch("sys.argv", ["run-claude", "invalid-command"]):
            with pytest.raises(SystemExit) as exc_info:
                main()
        assert exc_info.value.code == 2
        captured = capsys.readouterr()
        assert "invalid choice" in captured.err


class TestEnvCommand:
    """Tests for the env command."""

    def test_env_missing_profile(self, capsys):
        """env command with nonexistent profile should error."""
        with patch("sys.argv", ["run-claude", "env", "nonexistent-profile"]):
            result = main()
        assert result == 1
        captured = capsys.readouterr()
        assert "not found" in captured.err.lower()

    def test_env_outputs_anthropic_vars(self, capsys):
        """env command should output ANTHROPIC_* environment variables."""
        with patch("sys.argv", ["run-claude", "env", "cerebras"]):
            result = main()
        assert result == 0
        captured = capsys.readouterr()
        output = captured.out

        # Should contain base URL and auth token
        assert "ANTHROPIC_BASE_URL=" in output
        assert "API_TIMEOUT_MS=" in output

    def test_env_outputs_model_mappings(self, capsys):
        """env command should output model tier mappings from profile."""
        with patch("sys.argv", ["run-claude", "env", "cerebras"]):
            result = main()
        assert result == 0
        captured = capsys.readouterr()
        output = captured.out

        # cerebras profile maps opus->gpt-oss-120b, sonnet->qwen-3-32b, haiku->llama3.1-8b
        assert "ANTHROPIC_DEFAULT_OPUS_MODEL=" in output
        assert "ANTHROPIC_DEFAULT_SONNET_MODEL=" in output
        assert "ANTHROPIC_DEFAULT_HAIKU_MODEL=" in output

    def test_env_cerebras_sub_profile_uses_pro_models(self, capsys):
        """cerebras-sub profile should map to cerebras/pro model variants."""
        with patch("sys.argv", ["run-claude", "env", "cerebras-sub"]):
            result = main()
        assert result == 0
        captured = capsys.readouterr()
        output = captured.out

        # cerebras-sub uses cerebras/pro with thinking tiers
        assert "ANTHROPIC_DEFAULT_OPUS_MODEL=cerebras/pro:thinking-high" in output
        assert "ANTHROPIC_DEFAULT_SONNET_MODEL=cerebras/pro:thinking-medium" in output
        assert "ANTHROPIC_DEFAULT_HAIKU_MODEL=cerebras/pro:instant" in output

    def test_env_export_flag_adds_export_prefix(self, capsys):
        """env --export should prefix lines with 'export'."""
        with patch("sys.argv", ["run-claude", "env", "cerebras", "--export"]):
            result = main()
        assert result == 0
        captured = capsys.readouterr()
        output = captured.out

        # Each line should start with 'export '
        for line in output.strip().split("\n"):
            assert line.startswith("export "), f"Line missing export prefix: {line}"


class TestProfilesCommand:
    """Tests for the profiles command."""

    def test_profiles_list(self, capsys):
        """profiles list should show available profiles."""
        with patch("sys.argv", ["run-claude", "profiles", "list"]):
            result = main()
        assert result == 0

    def test_profiles_show_missing(self, capsys):
        """profiles show with nonexistent profile should error."""
        with patch("sys.argv", ["run-claude", "profiles", "show", "nonexistent"]):
            result = main()
        assert result == 1


class TestModelsCommand:
    """Tests for the models command."""

    def test_models_list(self, capsys):
        """models list should show available model definitions."""
        with patch("sys.argv", ["run-claude", "models", "list"]):
            result = main()
        assert result == 0

    def test_models_show_missing(self, capsys):
        """models show with nonexistent model should error."""
        with patch("sys.argv", ["run-claude", "models", "show", "nonexistent"]):
            result = main()
        assert result == 1
