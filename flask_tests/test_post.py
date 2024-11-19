"""
Post API tests
"""

from unittest.mock import patch, MagicMock


def test_create_post(client, auth_headers):
    """
    Test creating a post
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

        print("Response JSON:", response.json)
        assert response.status_code == 201
        assert response.json["post_id"] == "mock_post_id"


def test_get_posts(client, auth_headers):
    """
    Test retrieving all posts
    """
    mock_post = MagicMock()
    mock_post.to_dict.return_value = {
        "title": "Test Post",
        "content": "This is a test post",
        "llm_kind": "OpenAI",
    }
    mock_post.id = "1"

    with patch("api.models.post.Post.get_db") as mock_get_db:
        mock_db = MagicMock()
        mock_get_db.return_value = mock_db
        mock_db.collection.return_value.stream.return_value = [mock_post]

        response = client.get("/posts", headers=auth_headers)

        print("Response JSON:", response.json)
        assert response.status_code == 200
        assert len(response.json) == 1
        assert response.json[0]["title"] == "Test Post"
        assert response.json[0]["id"] == "1"
