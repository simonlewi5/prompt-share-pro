"""
Tests for the Post API endpoints
"""
from unittest.mock import patch


def test_create_post(client, auth_headers):
    """
    Test creating a post.
    """
    with patch("api.models.post.Post.create", return_value="mock_post_id"):
        response = client.post(
            "/posts",
            json={
                "title": "Test Post",
                "content": "This is a test post",
                "llm_kind": "OpenAI",
                "author_notes": "Notes",
            },
            headers=auth_headers,
        )
        assert response.status_code == 201
        assert response.json["post_id"] == "mock_post_id"


def test_get_posts(client, auth_headers):
    """
    Test retrieving all posts.
    """
    mock_post = {
        "id": "1",
        "title": "Test Post",
        "content": "This is a test post",
        "llm_kind": "OpenAI",
    }

    with patch("api.models.post.Post.get_all", return_value=[mock_post]):
        response = client.get("/posts", headers=auth_headers)

        assert response.status_code == 200
        assert len(response.json) == 1
        assert response.json[0]["title"] == "Test Post"
        assert response.json[0]["id"] == "1"


def test_get_post_by_user(client, auth_headers):
    """
    Test retrieving all posts by a specific user.
    """
    mock_post = {
        "id": "2",
        "title": "User Test Post",
        "content": "This is a test post by a specific user",
        "llm_kind": "OpenAI",
    }

    with patch("api.models.post.Post.get_by_user", return_value=[mock_post]):
        response = client.get("/posts/user/testuser@usc.edu", headers=auth_headers)

        assert response.status_code == 200
        assert len(response.json) == 1
        assert response.json[0]["title"] == "User Test Post"
        assert response.json[0]["id"] == "2"
