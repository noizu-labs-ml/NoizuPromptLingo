# AT-005: Web route artifact access

**Category**: End-to-End
**Related FR**: FR-003
**Status**: Not Started

## Description

Validates that artifacts can be accessed via web routes with correct content types and file streaming.

## Test Implementation

```python
async def test_web_artifact_access():
    """Test accessing artifact via web route."""
    # Setup - create artifact
    file_content = b"test image data"
    artifact = await create_artifact(
        name="test-image",
        artifact_type="image",
        file_content_base64=base64.b64encode(file_content).decode(),
        filename="test.png",
        created_by="user"
    )
    artifact_id = artifact["artifact_id"]

    # Action - HTTP GET request
    response = await client.get(f"/artifact/{artifact_id}")

    # Assert
    assert response.status_code == 200
    assert response.headers["content-type"] == "image/png"
    assert response.content == file_content

    # Test API endpoint
    api_response = await client.get(f"/api/artifact/{artifact_id}")
    assert api_response.status_code == 200
    json_data = api_response.json()
    assert json_data["artifact_id"] == artifact_id
    assert json_data["name"] == "test-image"
```

## Acceptance Criteria

- [ ] GET /artifact/{id} returns file content
- [ ] Content-Type header matches file type
- [ ] GET /api/artifact/{id} returns JSON metadata
- [ ] 404 returned for invalid artifact ID
- [ ] Large files stream correctly without memory issues

## Coverage

Covers:
- Web route functionality
- Content-Type detection
- File streaming
- API endpoint responses
- Error handling for invalid IDs
