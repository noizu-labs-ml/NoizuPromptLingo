"""Tests for sync module (SyncManager class) - focusing on conditional logic."""

import pytest
from pathlib import Path
from unittest.mock import Mock, patch, MagicMock

import sys
sys.path.insert(0, str(Path(__file__).parent.parent / "tools"))

from npl.sync import SyncManager


class TestSyncManagerInit:
    """Test SyncManager initialization."""

    def test_init_with_npl_dir(self):
        """Should accept npl_dir path."""
        with patch('npl.sync.DBManager'):
            sync = SyncManager(Path("/test/npl"))
            assert sync.npl_dir == Path("/test/npl")

    def test_init_with_custom_db(self):
        """Should accept custom DBManager."""
        mock_db = Mock()
        sync = SyncManager(Path("/test/npl"), db=mock_db)
        assert sync.db is mock_db


class TestSyncDecision:
    """Test sync() method decision logic."""

    def test_sync_calls_populate_when_no_metadata(self):
        """Should call populate when convention-definitions metadata doesn't exist."""
        mock_db = Mock()
        mock_db.get_metadata.return_value = None

        with patch.object(SyncManager, 'populate') as mock_populate, \
             patch.object(SyncManager, 'refresh') as mock_refresh:
            sync = SyncManager(Path("/test"), db=mock_db)
            sync.sync()

            mock_populate.assert_called_once()
            mock_refresh.assert_not_called()

    def test_sync_calls_refresh_when_metadata_exists(self):
        """Should call refresh when convention-definitions metadata exists."""
        mock_db = Mock()
        mock_db.get_metadata.return_value = {"files": []}

        with patch.object(SyncManager, 'populate') as mock_populate, \
             patch.object(SyncManager, 'refresh') as mock_refresh:
            sync = SyncManager(Path("/test"), db=mock_db)
            sync.sync()

            mock_refresh.assert_called_once()
            mock_populate.assert_not_called()


class TestRefreshFallback:
    """Test refresh() fallback logic."""

    def test_refresh_falls_back_to_populate_when_no_metadata(self):
        """Should call populate if get_metadata returns None during refresh."""
        mock_db = Mock()
        mock_db.get_metadata.return_value = None

        with patch.object(SyncManager, 'populate') as mock_populate, \
             patch('npl.sync.YAMLLoader'):
            sync = SyncManager(Path("/test"), db=mock_db)
            sync.refresh()

            mock_populate.assert_called_once()


class TestFileChangeDetection:
    """Test file change detection in refresh."""

    def test_detects_new_files(self):
        """Should identify files not in existing metadata as new."""
        mock_db = Mock()
        mock_db.get_metadata.return_value = {
            "files": [{"name": "existing.yaml", "digest": "abc123"}]
        }

        mock_loader = Mock()
        mock_loader.load_all.return_value = {
            "existing": {
                "filename": "existing.yaml",
                "path": "/test/existing.yaml",
                "digest": "abc123",
                "content": {"name": "Existing", "components": []}
            },
            "newfile": {
                "filename": "newfile.yaml",
                "path": "/test/newfile.yaml",
                "digest": "def456",
                "content": {"name": "New", "components": []}
            }
        }

        with patch('npl.sync.YAMLLoader', return_value=mock_loader):
            sync = SyncManager(Path("/test"), db=mock_db)
            new, changed, deleted = sync._detect_changes(
                mock_db.get_metadata.return_value,
                mock_loader.load_all.return_value
            )

            assert "newfile" in new
            assert "existing" not in new
            assert len(changed) == 0

    def test_detects_changed_files(self):
        """Should identify files with different digest as changed."""
        mock_db = Mock()
        existing_meta = {
            "files": [{"name": "file.yaml", "digest": "old_digest"}]
        }

        current_data = {
            "file": {
                "filename": "file.yaml",
                "path": "/test/file.yaml",
                "digest": "new_digest",
                "content": {"name": "File", "components": []}
            }
        }

        sync = SyncManager(Path("/test"), db=mock_db)
        new, changed, deleted = sync._detect_changes(existing_meta, current_data)

        assert "file" in changed
        assert len(new) == 0

    def test_detects_deleted_files(self):
        """Should identify files in metadata but not on disk as deleted."""
        mock_db = Mock()
        existing_meta = {
            "files": [
                {"name": "kept.yaml", "digest": "abc"},
                {"name": "removed.yaml", "digest": "xyz"}
            ]
        }

        current_data = {
            "kept": {
                "filename": "kept.yaml",
                "path": "/test/kept.yaml",
                "digest": "abc",
                "content": {"name": "Kept", "components": []}
            }
        }

        sync = SyncManager(Path("/test"), db=mock_db)
        new, changed, deleted = sync._detect_changes(existing_meta, current_data)

        assert "removed.yaml" in deleted
        assert len(new) == 0
        assert len(changed) == 0


class TestEmptyDataHandling:
    """Test handling of empty or missing data."""

    def test_populate_handles_no_yaml_files(self, capsys):
        """Should handle case when no YAML files found."""
        mock_db = Mock()
        mock_loader = Mock()
        mock_loader.load_all.return_value = {}

        with patch('npl.sync.YAMLLoader', return_value=mock_loader):
            sync = SyncManager(Path("/test"), db=mock_db)
            sync.populate()

            captured = capsys.readouterr()
            assert "No YAML files" in captured.out

    def test_refresh_handles_no_yaml_files(self, capsys):
        """Should handle case when no YAML files found during refresh."""
        mock_db = Mock()
        mock_db.get_metadata.return_value = {"files": []}

        mock_loader = Mock()
        mock_loader.load_all.return_value = {}

        with patch('npl.sync.YAMLLoader', return_value=mock_loader):
            sync = SyncManager(Path("/test"), db=mock_db)
            sync.refresh()

            captured = capsys.readouterr()
            assert "No YAML files" in captured.out


class TestContextManager:
    """Test context manager support."""

    def test_context_manager_connects_and_closes(self):
        """Should connect on enter and close on exit."""
        mock_db = Mock()

        with patch('npl.sync.DBManager', return_value=mock_db):
            with SyncManager(Path("/test")) as sync:
                pass

            mock_db.connect.assert_called_once()
            mock_db.close.assert_called_once()


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
