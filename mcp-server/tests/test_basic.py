"""Basic tests for NPL MCP server."""

import pytest
import pytest_asyncio
import base64
from pathlib import Path
from npl_mcp.storage import Database
from npl_mcp.artifacts.manager import ArtifactManager
from npl_mcp.artifacts.reviews import ReviewManager
from npl_mcp.chat import ChatManager


@pytest_asyncio.fixture
async def db():
    """Create a test database."""
    db = Database(Path("./test_data"))
    await db.connect()
    yield db
    await db.disconnect()
    # Cleanup
    import shutil
    shutil.rmtree("./test_data", ignore_errors=True)


@pytest_asyncio.fixture
async def artifact_manager(db):
    """Create artifact manager."""
    return ArtifactManager(db)


@pytest_asyncio.fixture
async def review_manager(db):
    """Create review manager."""
    return ReviewManager(db)


@pytest_asyncio.fixture
async def chat_manager(db):
    """Create chat manager."""
    return ChatManager(db)


@pytest.mark.asyncio
async def test_create_artifact(artifact_manager):
    """Test creating an artifact."""
    content = b"# Test Document\n\nThis is a test document."

    result = await artifact_manager.create_artifact(
        name="test-doc",
        artifact_type="document",
        file_content=content,
        filename="test.md",
        created_by="alice",
        purpose="Testing artifact creation"
    )

    assert result["artifact_name"] == "test-doc"
    assert result["revision_num"] == 0
    assert result["artifact_id"] > 0


@pytest.mark.asyncio
async def test_add_revision(artifact_manager):
    """Test adding a revision to an artifact."""
    # Create initial artifact
    initial_content = b"Version 1"
    artifact = await artifact_manager.create_artifact(
        name="versioned-doc",
        artifact_type="document",
        file_content=initial_content,
        filename="doc.txt",
        created_by="bob"
    )

    # Add revision
    new_content = b"Version 2"
    revision = await artifact_manager.add_revision(
        artifact_id=artifact["artifact_id"],
        file_content=new_content,
        filename="doc.txt",
        created_by="bob",
        purpose="Updated content"
    )

    assert revision["revision_num"] == 1
    assert revision["revision_id"] > artifact["revision_id"]


@pytest.mark.asyncio
async def test_review_workflow(artifact_manager, review_manager):
    """Test complete review workflow."""
    # Create artifact
    content = b"def hello():\n    print('Hello, world!')\n"
    artifact = await artifact_manager.create_artifact(
        name="code-sample",
        artifact_type="code",
        file_content=content,
        filename="hello.py",
        created_by="alice"
    )

    # Create review
    review = await review_manager.create_review(
        artifact_id=artifact["artifact_id"],
        revision_id=artifact["revision_id"],
        reviewer_persona="bob"
    )

    # Add inline comment
    comment = await review_manager.add_inline_comment(
        review_id=review["review_id"],
        location="line:2",
        comment="Consider adding a docstring",
        persona="bob"
    )

    assert comment["comment_id"] > 0

    # Get review
    full_review = await review_manager.get_review(review["review_id"])
    assert len(full_review["comments"]) == 1
    assert full_review["comments"][0]["comment"] == "Consider adding a docstring"


@pytest.mark.asyncio
async def test_chat_workflow(chat_manager):
    """Test complete chat workflow."""
    # Create chat room
    room = await chat_manager.create_chat_room(
        name="dev-team",
        members=["alice", "bob", "charlie"],
        description="Development team chat"
    )

    assert room["room_id"] > 0
    assert len(room["members"]) == 3

    # Send message with @mention
    message = await chat_manager.send_message(
        room_id=room["room_id"],
        persona="alice",
        message="Hey @bob, can you review the PR?"
    )

    assert len(message["mentions"]) == 1
    assert "bob" in message["mentions"]
    assert len(message["notifications"]) == 1

    # Check notifications
    notifications = await chat_manager.get_notifications("bob", unread_only=True)
    assert len(notifications) == 1
    assert notifications[0]["notification_type"] == "mention"


@pytest.mark.asyncio
async def test_artifact_sharing_in_chat(artifact_manager, chat_manager):
    """Test sharing artifacts in chat."""
    # Create artifact
    content = b"Design mockup"
    artifact = await artifact_manager.create_artifact(
        name="design-v1",
        artifact_type="image",
        file_content=content,
        filename="mockup.png",
        created_by="designer"
    )

    # Create chat room
    room = await chat_manager.create_chat_room(
        name="design-review",
        members=["designer", "developer"]
    )

    # Share artifact
    share = await chat_manager.share_artifact(
        room_id=room["room_id"],
        persona="designer",
        artifact_id=artifact["artifact_id"]
    )

    assert share["event_id"] > 0
    assert len(share["notifications"]) == 1  # developer gets notified

    # Check chat feed
    feed = await chat_manager.get_chat_feed(room["room_id"])
    artifact_events = [e for e in feed if e["event_type"] == "artifact_share"]
    assert len(artifact_events) == 1


@pytest.mark.asyncio
async def test_todo_creation(chat_manager):
    """Test creating todos in chat."""
    # Create room
    room = await chat_manager.create_chat_room(
        name="project-tasks",
        members=["alice", "bob"]
    )

    # Create todo
    todo = await chat_manager.create_todo(
        room_id=room["room_id"],
        persona="alice",
        description="Update documentation",
        assigned_to="bob"
    )

    assert todo["event_id"] > 0
    assert todo["assigned_to"] == "bob"
    assert todo["notification"] is not None

    # Check bob's notifications
    notifications = await chat_manager.get_notifications("bob")
    todo_notifs = [n for n in notifications if n["notification_type"] == "todo_assign"]
    assert len(todo_notifs) == 1
