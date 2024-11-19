"""
Contains tests for the Comment API endpoints.
"""

from unittest.mock import patch, MagicMock
import pytest
from google.api_core.exceptions import NotFound, GoogleAPICallError
from api.models.comment import Comment


def test_create_comment(client, auth_headers):
    """
    Test creating a comment for a post.
    """
    with patch("api.models.comment.Comment.create", return_value="mock_comment_id"):
        response = client.post(
            "/posts/1/comments",
            json={"content": "Test Comment"},
            headers=auth_headers,
        )

        assert response.status_code == 201
        assert response.json["comment_id"] == "mock_comment_id"


def test_create_comment_missing_content(client, auth_headers):
    """
    Test creating a comment with missing content.
    """
    response = client.post(
        "/posts/1/comments",
        json={},
        headers=auth_headers,
    )

    assert response.status_code == 400
    assert response.json["message"] == "Content is required"


def test_get_comments(client, auth_headers):
    """
    Test retrieving comments for a post.
    """
    mock_comment = MagicMock()
    mock_comment.to_dict.return_value = {
        "id": "1",
        "content": "Test Comment",
        "author": "test_user",
    }

    with patch(
        "api.models.comment.Comment.get_by_post", return_value=[mock_comment.to_dict()]
    ):
        response = client.get("/posts/1/comments", headers=auth_headers)

        assert response.status_code == 200
        assert len(response.json) == 1
        assert response.json[0]["content"] == "Test Comment"


def test_create_comment_nonexistent_post(client, auth_headers):
    """
    Test creating a comment for a non-existent post.
    """
    with patch(
        "api.models.comment.Comment.create", side_effect=NotFound("Post not found")
    ):
        response = client.post(
            "/posts/invalid_id/comments",
            json={"content": "Test Comment"},
            headers=auth_headers,
        )

        assert response.status_code == 404
        assert response.json["message"] == "404 Post not found"


def test_get_comments_nonexistent_post(client, auth_headers):
    """
    Test retrieving comments for a non-existent post.
    """
    with patch(
        "api.models.comment.Comment.get_by_post", side_effect=NotFound("Post not found")
    ):
        response = client.get("/posts/invalid_id/comments", headers=auth_headers)

        assert response.status_code == 404
        assert response.json["message"] == "404 Post not found"


def test_delete_comment_nonexistent_comment(client, auth_headers):
    """
    Test deleting a non-existent comment by its ID.
    """
    with patch(
        "api.models.comment.Comment.delete", side_effect=NotFound("Comment not found")
    ):
        response = client.delete("/posts/1/comments/invalid_id", headers=auth_headers)

        assert response.status_code == 404
        assert response.json["message"] == "404 Comment not found"


def test_create_comment_success():
    """
    Test successful creation of a comment.
    """
    with patch("api.models.comment.Comment.get_db") as mock_get_db:
        mock_db = MagicMock()
        mock_get_db.return_value = mock_db

        mock_post = MagicMock()
        mock_post.exists = True
        mock_db.collection.return_value.document.return_value.get.return_value = (
            mock_post
        )

        mock_comment_ref = MagicMock()
        mock_db.collection.return_value.document.return_value.collection.return_value.document.return_value = (
            mock_comment_ref
        )

        comment_id = Comment.create(
            "mock_post_id", {"email": "testuser@usc.edu"}, "Test Comment"
        )
        assert comment_id == mock_comment_ref.id


def test_create_comment_post_not_found():
    """
    Test creating a comment for a non-existent post.
    """
    with patch("api.models.comment.Comment.get_db") as mock_get_db:
        mock_db = MagicMock()
        mock_get_db.return_value = mock_db

        mock_post = MagicMock()
        mock_post.exists = False
        mock_db.collection.return_value.document.return_value.get.return_value = (
            mock_post
        )

        with pytest.raises(NotFound, match="Post with ID mock_post_id not found"):
            Comment.create(
                "mock_post_id", {"email": "testuser@usc.edu"}, "Test Comment"
            )


def test_create_comment_firestore_error():
    """
    Test Firestore error during comment creation.
    """
    with patch("api.models.comment.Comment.get_db") as mock_get_db:
        mock_db = MagicMock()
        mock_get_db.return_value = mock_db

        mock_post = MagicMock()
        mock_post.exists = True
        mock_db.collection.return_value.document.return_value.get.return_value = (
            mock_post
        )

        mock_db.collection.return_value.document.return_value.collection.return_value.document.side_effect = GoogleAPICallError(
            "Firestore error"
        )

        with pytest.raises(
            GoogleAPICallError, match="Firestore error while creating comment"
        ):
            Comment.create(
                "mock_post_id", {"email": "testuser@usc.edu"}, "Test Comment"
            )
