"""Database management for NPL MCP server."""

import aiosqlite
import os
from pathlib import Path
from typing import Optional


class Database:
    """Manages SQLite database connection and initialization."""

    def __init__(self, data_dir: Optional[Path] = None):
        """Initialize database manager.

        Args:
            data_dir: Directory for data storage. Defaults to ./data
        """
        if data_dir is None:
            data_dir = Path(os.environ.get("NPL_MCP_DATA_DIR", "./data"))

        self.data_dir = Path(data_dir)
        self.data_dir.mkdir(parents=True, exist_ok=True)

        self.db_path = self.data_dir / "npl-mcp.db"
        self.artifacts_dir = self.data_dir / "artifacts"
        self.chats_dir = self.data_dir / "chats"

        # Ensure subdirectories exist
        self.artifacts_dir.mkdir(parents=True, exist_ok=True)
        self.chats_dir.mkdir(parents=True, exist_ok=True)

        self._connection: Optional[aiosqlite.Connection] = None

    async def connect(self):
        """Connect to the database and initialize schema."""
        self._connection = await aiosqlite.connect(self.db_path)
        self._connection.row_factory = aiosqlite.Row
        await self._initialize_schema()

    async def disconnect(self):
        """Close database connection."""
        if self._connection:
            await self._connection.close()
            self._connection = None

    async def _initialize_schema(self):
        """Initialize database schema from SQL file."""
        schema_path = Path(__file__).parent / "schema.sql"
        with open(schema_path, 'r') as f:
            schema_sql = f.read()

        await self._connection.executescript(schema_sql)
        await self._connection.commit()

    @property
    def connection(self) -> aiosqlite.Connection:
        """Get the database connection."""
        if self._connection is None:
            raise RuntimeError("Database not connected. Call connect() first.")
        return self._connection

    async def execute(self, sql: str, parameters=None):
        """Execute a SQL statement.

        Args:
            sql: SQL statement to execute
            parameters: Optional parameters for the statement

        Returns:
            Cursor object
        """
        if parameters is None:
            parameters = ()
        cursor = await self.connection.execute(sql, parameters)
        await self.connection.commit()
        return cursor

    async def fetchone(self, sql: str, parameters=None):
        """Execute SQL and fetch one row.

        Args:
            sql: SQL query
            parameters: Optional query parameters

        Returns:
            Single row or None
        """
        if parameters is None:
            parameters = ()
        async with self.connection.execute(sql, parameters) as cursor:
            return await cursor.fetchone()

    async def fetchall(self, sql: str, parameters=None):
        """Execute SQL and fetch all rows.

        Args:
            sql: SQL query
            parameters: Optional query parameters

        Returns:
            List of rows
        """
        if parameters is None:
            parameters = ()
        async with self.connection.execute(sql, parameters) as cursor:
            return await cursor.fetchall()

    def get_artifact_path(self, artifact_name: str, revision_num: int,
                         filename: str) -> Path:
        """Get the file path for an artifact revision.

        Args:
            artifact_name: Name of the artifact
            revision_num: Revision number
            filename: Filename for this revision

        Returns:
            Path object for the artifact file
        """
        artifact_dir = self.artifacts_dir / artifact_name
        artifact_dir.mkdir(parents=True, exist_ok=True)

        # Use format: revision-{num}-{filename}
        return artifact_dir / f"revision-{revision_num}-{filename}"

    def get_artifact_meta_path(self, artifact_name: str,
                              revision_num: int) -> Path:
        """Get the metadata file path for an artifact revision.

        Args:
            artifact_name: Name of the artifact
            revision_num: Revision number

        Returns:
            Path object for the metadata file
        """
        artifact_dir = self.artifacts_dir / artifact_name
        artifact_dir.mkdir(parents=True, exist_ok=True)

        return artifact_dir / f"revision-{revision_num}.meta.md"

    async def __aenter__(self):
        """Async context manager entry."""
        await self.connect()
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """Async context manager exit."""
        await self.disconnect()
