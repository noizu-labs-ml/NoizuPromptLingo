"""
File I/O utilities for npl_persona.

Provides safe file operations with proper error handling, replacing the
50+ raw open() calls scattered throughout the original codebase.
"""

import os
import shutil
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Generic, TypeVar, Union

T = TypeVar("T")
E = TypeVar("E", bound=Exception)


@dataclass
class FileError(Exception):
    """File operation error with context."""
    path: Path
    operation: str
    message: str
    cause: Exception = None

    def __str__(self) -> str:
        base = f"{self.operation} failed for {self.path}: {self.message}"
        if self.cause:
            base += f" (caused by: {self.cause})"
        return base


@dataclass
class Ok(Generic[T]):
    """Success result container."""
    value: T

    def is_ok(self) -> bool:
        return True

    def is_err(self) -> bool:
        return False

    def unwrap(self) -> T:
        return self.value

    def unwrap_or(self, default: T) -> T:
        return self.value


@dataclass
class Err(Generic[E]):
    """Error result container."""
    error: E

    def is_ok(self) -> bool:
        return False

    def is_err(self) -> bool:
        return True

    def unwrap(self) -> None:
        raise self.error

    def unwrap_or(self, default: T) -> T:
        return default


Result = Union[Ok[T], Err[E]]


class FileManager:
    """
    Safe file I/O with encoding and error handling.

    All operations return Result types to force explicit error handling.
    """

    def __init__(self, encoding: str = "utf-8"):
        """
        Initialize file manager.

        Args:
            encoding: Default encoding for text files
        """
        self.encoding = encoding

    def read(self, path: Path) -> Result[str, FileError]:
        """
        Read file contents safely.

        Args:
            path: Path to file to read

        Returns:
            Ok(content) on success, Err(FileError) on failure
        """
        try:
            with open(path, "r", encoding=self.encoding) as f:
                return Ok(f.read())
        except FileNotFoundError as e:
            return Err(FileError(
                path=path,
                operation="read",
                message="File not found",
                cause=e
            ))
        except PermissionError as e:
            return Err(FileError(
                path=path,
                operation="read",
                message="Permission denied",
                cause=e
            ))
        except UnicodeDecodeError as e:
            return Err(FileError(
                path=path,
                operation="read",
                message=f"Encoding error: {e.reason}",
                cause=e
            ))
        except Exception as e:
            return Err(FileError(
                path=path,
                operation="read",
                message=str(e),
                cause=e
            ))

    def write(self, path: Path, content: str) -> Result[None, FileError]:
        """
        Write content to file safely.

        Args:
            path: Path to file to write
            content: Content to write

        Returns:
            Ok(None) on success, Err(FileError) on failure
        """
        try:
            with open(path, "w", encoding=self.encoding) as f:
                f.write(content)
            return Ok(None)
        except PermissionError as e:
            return Err(FileError(
                path=path,
                operation="write",
                message="Permission denied",
                cause=e
            ))
        except OSError as e:
            return Err(FileError(
                path=path,
                operation="write",
                message=str(e),
                cause=e
            ))

    def write_atomic(self, path: Path, content: str) -> Result[None, FileError]:
        """
        Write content atomically (write to temp file, then rename).

        This prevents partial writes and data corruption.

        Args:
            path: Path to file to write
            content: Content to write

        Returns:
            Ok(None) on success, Err(FileError) on failure
        """
        try:
            # Write to temp file in same directory (for atomic rename)
            dir_path = path.parent
            fd, temp_path = tempfile.mkstemp(dir=dir_path, suffix=".tmp")

            try:
                with os.fdopen(fd, "w", encoding=self.encoding) as f:
                    f.write(content)

                # Atomic rename
                os.replace(temp_path, path)
                return Ok(None)

            except Exception as e:
                # Clean up temp file on error
                try:
                    os.unlink(temp_path)
                except OSError:
                    pass
                raise e

        except PermissionError as e:
            return Err(FileError(
                path=path,
                operation="write_atomic",
                message="Permission denied",
                cause=e
            ))
        except OSError as e:
            return Err(FileError(
                path=path,
                operation="write_atomic",
                message=str(e),
                cause=e
            ))

    def append(self, path: Path, content: str) -> Result[None, FileError]:
        """
        Append content to file.

        Args:
            path: Path to file to append to
            content: Content to append

        Returns:
            Ok(None) on success, Err(FileError) on failure
        """
        try:
            with open(path, "a", encoding=self.encoding) as f:
                f.write(content)
            return Ok(None)
        except PermissionError as e:
            return Err(FileError(
                path=path,
                operation="append",
                message="Permission denied",
                cause=e
            ))
        except OSError as e:
            return Err(FileError(
                path=path,
                operation="append",
                message=str(e),
                cause=e
            ))

    def ensure_dir(self, path: Path) -> Result[None, FileError]:
        """
        Create directory if it doesn't exist.

        Args:
            path: Path to directory to create

        Returns:
            Ok(None) on success, Err(FileError) on failure
        """
        try:
            path.mkdir(parents=True, exist_ok=True)
            return Ok(None)
        except PermissionError as e:
            return Err(FileError(
                path=path,
                operation="mkdir",
                message="Permission denied",
                cause=e
            ))
        except OSError as e:
            return Err(FileError(
                path=path,
                operation="mkdir",
                message=str(e),
                cause=e
            ))

    def exists(self, path: Path) -> bool:
        """Check if path exists."""
        return path.exists()

    def delete(self, path: Path) -> Result[None, FileError]:
        """
        Delete a file.

        Args:
            path: Path to file to delete

        Returns:
            Ok(None) on success, Err(FileError) on failure
        """
        try:
            path.unlink()
            return Ok(None)
        except FileNotFoundError:
            return Ok(None)  # Already gone, that's fine
        except PermissionError as e:
            return Err(FileError(
                path=path,
                operation="delete",
                message="Permission denied",
                cause=e
            ))
        except OSError as e:
            return Err(FileError(
                path=path,
                operation="delete",
                message=str(e),
                cause=e
            ))

    def copy(self, src: Path, dst: Path) -> Result[None, FileError]:
        """
        Copy a file, preserving metadata.

        Args:
            src: Source file path
            dst: Destination file path

        Returns:
            Ok(None) on success, Err(FileError) on failure
        """
        try:
            shutil.copy2(src, dst)
            return Ok(None)
        except FileNotFoundError as e:
            return Err(FileError(
                path=src,
                operation="copy",
                message="Source file not found",
                cause=e
            ))
        except PermissionError as e:
            return Err(FileError(
                path=dst,
                operation="copy",
                message="Permission denied",
                cause=e
            ))
        except OSError as e:
            return Err(FileError(
                path=src,
                operation="copy",
                message=str(e),
                cause=e
            ))

    def stat(self, path: Path) -> Result[os.stat_result, FileError]:
        """
        Get file statistics.

        Args:
            path: Path to file

        Returns:
            Ok(stat_result) on success, Err(FileError) on failure
        """
        try:
            return Ok(path.stat())
        except FileNotFoundError as e:
            return Err(FileError(
                path=path,
                operation="stat",
                message="File not found",
                cause=e
            ))
        except PermissionError as e:
            return Err(FileError(
                path=path,
                operation="stat",
                message="Permission denied",
                cause=e
            ))


# Default file manager instance
default_manager = FileManager()


# Convenience functions using default manager
def read_file(path: Path) -> Result[str, FileError]:
    """Read file using default manager."""
    return default_manager.read(path)


def write_file(path: Path, content: str) -> Result[None, FileError]:
    """Write file using default manager."""
    return default_manager.write(path, content)


def ensure_dir(path: Path) -> Result[None, FileError]:
    """Create directory using default manager."""
    return default_manager.ensure_dir(path)
