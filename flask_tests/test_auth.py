"""
This file contains tests for the authentication endpoints.
"""

from unittest.mock import MagicMock, patch
from werkzeug.security import generate_password_hash


def test_signup(client):
    """
    Test the signup endpoint
    """
    initial_mock = MagicMock(return_value=None)
    post_create_mock = MagicMock(
        return_value={
            "username": "test_user",
            "email": "testuser@usc.edu",
            "usc_id": "1234567890",
            "profile_image": "http://example.com/profile.jpg",
        }
    )

    with patch(
        "api.models.user.User.get_by_email",
        side_effect=[initial_mock(), post_create_mock()],
    ):
        with patch("api.models.user.User.create", return_value=None):
            response = client.post(
                "/signup",
                json={
                    "email": "testuser@usc.edu",
                    "password": "password123",
                    "usc_id": "1234567890",
                    "username": "test_user",
                    "profile_image": "http://example.com/profile.jpg",
                },
            )

            print("Response JSON:", response.json)
            assert response.status_code == 200
            assert "access_token" in response.json


def test_login(client):
    """
    Test the login endpoint
    """
    user_mock = MagicMock(
        return_value={
            "email": "test@example.com",
            "password": generate_password_hash("password123"),
            "username": "test_user",
        }
    )

    with patch("api.models.user.User.get_by_email", user_mock):
        with patch("api.models.user.User.check_password", return_value=True):
            response = client.post(
                "/login",
                json={"email": "test@example.com", "password": "password123"},
            )

            print("Response JSON:", response.json)
            assert response.status_code == 200
            assert "access_token" in response.json
