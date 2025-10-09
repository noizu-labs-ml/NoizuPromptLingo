"""Additional tests to improve coverage of NPL MCP server."""

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


# ============================================================================
# Artifact Management - Coverage Gaps
# ============================================================================

@pytest.mark.asyncio
async def test_list_artifacts(artifact_manager):
    """Test listing all artifacts."""
    # Create multiple artifacts
    await artifact_manager.create_artifact(
        name="artifact-1",
        artifact_type="document",
        file_content=b"Content 1",
        filename="doc1.txt",
        created_by="alice"
    )

    await artifact_manager.create_artifact(
        name="artifact-2",
        artifact_type="image",
        file_content=b"Content 2",
        filename="img.png",
        created_by="bob"
    )

    await artifact_manager.create_artifact(
        name="artifact-3",
        artifact_type="code",
        file_content=b"Content 3",
        filename="code.py",
        created_by="charlie"
    )

    # List all artifacts
    artifacts = await artifact_manager.list_artifacts()

    assert len(artifacts) == 3
    assert all('id' in a for a in artifacts)
    assert all('name' in a for a in artifacts)
    assert all('type' in a for a in artifacts)

    # Check all artifacts are present (order may vary due to timing)
    names = [a['name'] for a in artifacts]
    assert set(names) == {'artifact-1', 'artifact-2', 'artifact-3'}


@pytest.mark.asyncio
async def test_get_artifact_history(artifact_manager):
    """Test getting revision history for an artifact."""
    # Create artifact with multiple revisions
    artifact = await artifact_manager.create_artifact(
        name="versioned",
        artifact_type="document",
        file_content=b"Version 1",
        filename="doc.txt",
        created_by="alice",
        purpose="Initial version"
    )

    await artifact_manager.add_revision(
        artifact_id=artifact["artifact_id"],
        file_content=b"Version 2",
        filename="doc.txt",
        created_by="bob",
        purpose="Updated by Bob"
    )

    await artifact_manager.add_revision(
        artifact_id=artifact["artifact_id"],
        file_content=b"Version 3",
        filename="doc.txt",
        created_by="charlie",
        purpose="Final version"
    )

    # Get history
    history = await artifact_manager.get_artifact_history(artifact["artifact_id"])

    assert len(history) == 3
    # Should be reverse chronological (newest first)
    assert history[0]['revision_num'] == 2
    assert history[0]['created_by'] == 'charlie'
    assert history[0]['purpose'] == 'Final version'

    assert history[1]['revision_num'] == 1
    assert history[1]['created_by'] == 'bob'

    assert history[2]['revision_num'] == 0
    assert history[2]['created_by'] == 'alice'


@pytest.mark.asyncio
async def test_get_artifact_by_specific_revision(artifact_manager):
    """Test retrieving a specific revision of an artifact."""
    # Create artifact with multiple revisions
    artifact = await artifact_manager.create_artifact(
        name="multi-version",
        artifact_type="document",
        file_content=b"Original Content",
        filename="doc.txt",
        created_by="alice"
    )

    await artifact_manager.add_revision(
        artifact_id=artifact["artifact_id"],
        file_content=b"Updated Content",
        filename="doc.txt",
        created_by="bob"
    )

    # Get specific revision (the original)
    revision_0 = await artifact_manager.get_artifact(
        artifact_id=artifact["artifact_id"],
        revision=0
    )

    # Decode and check content
    content_0 = base64.b64decode(revision_0["file_content"])
    assert content_0 == b"Original Content"
    assert revision_0["revision_num"] == 0
    assert revision_0["created_by"] == "alice"

    # Get latest revision
    revision_1 = await artifact_manager.get_artifact(
        artifact_id=artifact["artifact_id"],
        revision=1
    )

    content_1 = base64.b64decode(revision_1["file_content"])
    assert content_1 == b"Updated Content"
    assert revision_1["revision_num"] == 1
    assert revision_1["created_by"] == "bob"


# ============================================================================
# Review System - Coverage Gaps
# ============================================================================

@pytest.mark.asyncio
async def test_get_review_with_comments(artifact_manager, review_manager):
    """Test retrieving a review with all its comments."""
    # Create artifact
    artifact = await artifact_manager.create_artifact(
        name="code-review",
        artifact_type="code",
        file_content=b"def hello():\n    print('world')\n",
        filename="hello.py",
        created_by="alice"
    )

    # Create review
    review = await review_manager.create_review(
        artifact_id=artifact["artifact_id"],
        revision_id=artifact["revision_id"],
        reviewer_persona="bob"
    )

    # Add multiple comments
    await review_manager.add_inline_comment(
        review_id=review["review_id"],
        location="line:1",
        comment="Add docstring",
        persona="bob"
    )

    await review_manager.add_inline_comment(
        review_id=review["review_id"],
        location="line:2",
        comment="Use f-string instead",
        persona="bob"
    )

    # Get full review
    full_review = await review_manager.get_review(review["review_id"])

    assert full_review["id"] == review["review_id"]
    assert full_review["artifact_name"] == "code-review"
    assert full_review["reviewer_persona"] == "bob"
    assert len(full_review["comments"]) == 2

    # Check comments are in order
    assert full_review["comments"][0]["location"] == "line:1"
    assert full_review["comments"][1]["location"] == "line:2"


@pytest.mark.asyncio
async def test_complete_review(artifact_manager, review_manager):
    """Test completing a review."""
    # Create artifact and review
    artifact = await artifact_manager.create_artifact(
        name="final-doc",
        artifact_type="document",
        file_content=b"Document content",
        filename="doc.md",
        created_by="alice"
    )

    review = await review_manager.create_review(
        artifact_id=artifact["artifact_id"],
        revision_id=artifact["revision_id"],
        reviewer_persona="bob"
    )

    # Complete review
    result = await review_manager.complete_review(
        review_id=review["review_id"],
        overall_comment="Looks good overall, minor changes needed."
    )

    assert result["review_id"] == review["review_id"]
    assert result["status"] == "completed"
    assert result["overall_comment"] == "Looks good overall, minor changes needed."


@pytest.mark.asyncio
async def test_generate_annotated_artifact_single_reviewer(artifact_manager, review_manager):
    """Test generating annotated artifact with single reviewer."""
    # Create text artifact
    content = b"""# Project Report

## Introduction
This is the introduction section.

## Analysis
The analysis shows positive results.

## Conclusion
We recommend proceeding."""

    artifact = await artifact_manager.create_artifact(
        name="report",
        artifact_type="document",
        file_content=content,
        filename="report.md",
        created_by="alice"
    )

    # Create review with comments
    review = await review_manager.create_review(
        artifact_id=artifact["artifact_id"],
        revision_id=artifact["revision_id"],
        reviewer_persona="bob"
    )

    await review_manager.add_inline_comment(
        review_id=review["review_id"],
        location="line:4",
        comment="Expand on the introduction - add background",
        persona="bob"
    )

    await review_manager.add_inline_comment(
        review_id=review["review_id"],
        location="line:7",
        comment="Add specific metrics and data",
        persona="bob"
    )

    # Generate annotated version
    annotated = await review_manager.generate_annotated_artifact(
        artifact_id=artifact["artifact_id"],
        revision_id=artifact["revision_id"]
    )

    assert annotated["artifact_id"] == artifact["artifact_id"]
    assert annotated["artifact_name"] == "report"
    assert annotated["total_comments"] == 2
    assert "bob" in annotated["reviewers"]

    # Check annotated content has footnotes
    assert "[^bob-1]" in annotated["annotated_content"]
    assert "[^bob-2]" in annotated["annotated_content"]
    assert "# Review Comments" in annotated["annotated_content"]

    # Check reviewer files
    assert "bob" in annotated["reviewer_files"]
    bob_file = annotated["reviewer_files"]["bob"]
    assert "# Inline Comments by @bob" in bob_file
    assert "line:4" in bob_file
    assert "line:7" in bob_file


@pytest.mark.asyncio
async def test_generate_annotated_artifact_multi_reviewer(artifact_manager, review_manager):
    """Test generating annotated artifact with multiple reviewers."""
    # Create artifact
    content = b"Line 1\nLine 2\nLine 3\nLine 4\n"

    artifact = await artifact_manager.create_artifact(
        name="multi-review-doc",
        artifact_type="document",
        file_content=content,
        filename="doc.txt",
        created_by="alice"
    )

    # Create reviews from multiple reviewers
    review_bob = await review_manager.create_review(
        artifact_id=artifact["artifact_id"],
        revision_id=artifact["revision_id"],
        reviewer_persona="bob"
    )

    review_charlie = await review_manager.create_review(
        artifact_id=artifact["artifact_id"],
        revision_id=artifact["revision_id"],
        reviewer_persona="charlie"
    )

    # Bob's comments
    await review_manager.add_inline_comment(
        review_id=review_bob["review_id"],
        location="line:1",
        comment="Bob's comment on line 1",
        persona="bob"
    )

    await review_manager.add_inline_comment(
        review_id=review_bob["review_id"],
        location="line:3",
        comment="Bob's comment on line 3",
        persona="bob"
    )

    # Charlie's comments
    await review_manager.add_inline_comment(
        review_id=review_charlie["review_id"],
        location="line:1",
        comment="Charlie's comment on line 1",
        persona="charlie"
    )

    await review_manager.add_inline_comment(
        review_id=review_charlie["review_id"],
        location="line:2",
        comment="Charlie's comment on line 2",
        persona="charlie"
    )

    # Generate annotated version
    annotated = await review_manager.generate_annotated_artifact(
        artifact_id=artifact["artifact_id"],
        revision_id=artifact["revision_id"]
    )

    assert annotated["total_comments"] == 4
    assert set(annotated["reviewers"]) == {"bob", "charlie"}

    # Check both reviewers have files
    assert "bob" in annotated["reviewer_files"]
    assert "charlie" in annotated["reviewer_files"]

    # Line 1 should have footnotes from both reviewers
    lines = annotated["annotated_content"].split('\n')
    # Both bob and charlie commented on line 1, so both should have footnotes
    assert "[^bob-1]" in lines[0] and ("[^charlie-1]" in lines[0] or "[^charlie-2]" in lines[0])


# ============================================================================
# Chat System - Coverage Gaps
# ============================================================================

@pytest.mark.asyncio
async def test_emoji_reaction(chat_manager):
    """Test adding emoji reactions to messages."""
    # Create room and send message
    room = await chat_manager.create_chat_room(
        name="reactions-test",
        members=["alice", "bob"]
    )

    message = await chat_manager.send_message(
        room_id=room["room_id"],
        persona="alice",
        message="Great work!"
    )

    # Add reaction
    reaction = await chat_manager.react_to_message(
        event_id=message["event_id"],
        persona="bob",
        emoji="👍"
    )

    assert reaction["event_id"] > 0
    assert reaction["target_event_id"] == message["event_id"]
    assert reaction["emoji"] == "👍"
    assert reaction["persona"] == "bob"

    # Get chat feed and verify reaction is there
    feed = await chat_manager.get_chat_feed(room["room_id"])
    reaction_events = [e for e in feed if e["event_type"] == "emoji_reaction"]
    assert len(reaction_events) == 1
    assert reaction_events[0]["data"]["emoji"] == "👍"


@pytest.mark.asyncio
async def test_message_reply_chain(chat_manager):
    """Test replying to messages."""
    # Create room
    room = await chat_manager.create_chat_room(
        name="thread-test",
        members=["alice", "bob", "charlie"]
    )

    # Original message
    msg1 = await chat_manager.send_message(
        room_id=room["room_id"],
        persona="alice",
        message="What do you think about the design?"
    )

    # Reply to message
    msg2 = await chat_manager.send_message(
        room_id=room["room_id"],
        persona="bob",
        message="I like it!",
        reply_to_id=msg1["event_id"]
    )

    # Another reply
    msg3 = await chat_manager.send_message(
        room_id=room["room_id"],
        persona="charlie",
        message="Agreed!",
        reply_to_id=msg1["event_id"]
    )

    # Get feed
    feed = await chat_manager.get_chat_feed(room["room_id"])

    # Should have 6 events: 3 joins + 3 messages
    message_events = [e for e in feed if e["event_type"] == "message"]
    assert len(message_events) == 3


# ============================================================================
# Error Handling Tests
# ============================================================================

@pytest.mark.asyncio
async def test_duplicate_artifact_name_error(artifact_manager):
    """Test error when creating duplicate artifact name."""
    # Create first artifact
    await artifact_manager.create_artifact(
        name="unique-name",
        artifact_type="document",
        file_content=b"Content",
        filename="doc.txt",
        created_by="alice"
    )

    # Try to create another with same name
    with pytest.raises(ValueError, match="already exists"):
        await artifact_manager.create_artifact(
            name="unique-name",
            artifact_type="document",
            file_content=b"Different content",
            filename="doc2.txt",
            created_by="bob"
        )


@pytest.mark.asyncio
async def test_invalid_artifact_id_error(artifact_manager):
    """Test error when using invalid artifact ID."""
    with pytest.raises(ValueError, match="not found"):
        await artifact_manager.add_revision(
            artifact_id=99999,
            file_content=b"Content",
            filename="test.txt",
            created_by="alice"
        )


@pytest.mark.asyncio
async def test_invalid_review_id_error(review_manager):
    """Test error when using invalid review ID."""
    with pytest.raises(ValueError, match="not found"):
        await review_manager.add_inline_comment(
            review_id=99999,
            location="line:1",
            comment="Test comment",
            persona="alice"
        )


@pytest.mark.asyncio
async def test_non_member_chat_access_error(chat_manager):
    """Test error when non-member tries to send message."""
    # Create room with specific members
    room = await chat_manager.create_chat_room(
        name="private-room",
        members=["alice", "bob"]
    )

    # Try to send message as non-member
    with pytest.raises(ValueError, match="not a member"):
        await chat_manager.send_message(
            room_id=room["room_id"],
            persona="charlie",
            message="Can I join?"
        )


@pytest.mark.asyncio
async def test_duplicate_room_name_error(chat_manager):
    """Test error when creating duplicate chat room name."""
    # Create first room
    await chat_manager.create_chat_room(
        name="team-room",
        members=["alice", "bob"]
    )

    # Try to create another with same name
    with pytest.raises(ValueError, match="already exists"):
        await chat_manager.create_chat_room(
            name="team-room",
            members=["charlie", "dave"]
        )


@pytest.mark.asyncio
async def test_get_artifact_history_invalid_id(artifact_manager):
    """Test error when getting history for invalid artifact."""
    with pytest.raises(ValueError, match="not found"):
        await artifact_manager.get_artifact_history(99999)


@pytest.mark.asyncio
async def test_get_nonexistent_revision(artifact_manager):
    """Test error when getting non-existent revision."""
    # Create artifact with one revision
    artifact = await artifact_manager.create_artifact(
        name="test-artifact",
        artifact_type="document",
        file_content=b"Content",
        filename="doc.txt",
        created_by="alice"
    )

    # Try to get revision that doesn't exist
    with pytest.raises(ValueError, match="not found"):
        await artifact_manager.get_artifact(
            artifact_id=artifact["artifact_id"],
            revision=99
        )
